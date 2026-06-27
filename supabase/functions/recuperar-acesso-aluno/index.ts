import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const allowedOrigin = Deno.env.get("SITE_URL") ?? "";
const genericMessage = {
  message: "Se os dados corresponderem a um cadastro ativo, enviaremos as instrucoes ao e-mail institucional."
};

function headers(origin: string | null) {
  const permittedOrigin = origin === allowedOrigin ? origin : allowedOrigin;
  return {
    "Access-Control-Allow-Origin": permittedOrigin,
    "Access-Control-Allow-Headers": "authorization, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Content-Type": "application/json",
    "Vary": "Origin"
  };
}

function genericResponse(origin: string | null) {
  return new Response(JSON.stringify(genericMessage), { status: 200, headers: headers(origin) });
}

async function sha256(value: string) {
  const data = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(digest), byte => byte.toString(16).padStart(2, "0")).join("");
}

Deno.serve(async request => {
  const origin = request.headers.get("origin");
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: headers(origin) });
  }
  if (request.method !== "POST" || !allowedOrigin || origin !== allowedOrigin) {
    return genericResponse(origin);
  }

  try {
    const { cpf, dataNascimento } = await request.json();
    const normalizedCpf = String(cpf ?? "").replace(/\D/g, "");
    const birthdate = String(dataNascimento ?? "");
    if (!/^\d{11}$/.test(normalizedCpf) || !/^\d{4}-\d{2}-\d{2}$/.test(birthdate)) {
      return genericResponse(origin);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const rateLimitSecret = Deno.env.get("RECOVERY_RATE_LIMIT_SECRET")!;
    if (!supabaseUrl || !serviceRoleKey || !anonKey || !rateLimitSecret) {
      return genericResponse(origin);
    }

    const clientIp = request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? "unknown";
    const requestHash = await sha256(`${clientIp}:${normalizedCpf}:${rateLimitSecret}`);
    const admin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false }
    });
    const { data, error } = await admin.rpc("solicitar_recuperacao_aluno", {
      p_cpf: normalizedCpf,
      p_data_nascimento: birthdate,
      p_chave_hash: requestHash
    });
    const email = !error && Array.isArray(data) ? data[0]?.email_institucional : null;

    if (email) {
      const publicAuth = createClient(supabaseUrl, anonKey, {
        auth: { persistSession: false, autoRefreshToken: false }
      });
      await publicAuth.auth.resetPasswordForEmail(email, {
        redirectTo: `${allowedOrigin}/redefinir_senha.html`
      });
    }
  } catch (_) {
    // A resposta permanece generica para impedir enumeracao de cadastros.
  }

  return genericResponse(origin);
});

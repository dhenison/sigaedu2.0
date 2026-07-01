-- ==============================================================================
-- SIGAEDU — Script de Schema do Banco de Dados + RLS (Supabase)
-- Execute no Editor SQL do seu projeto Supabase.
-- ==============================================================================

-- Habilita extensão de UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. ESCOLAS (Tenants)
CREATE TABLE IF NOT EXISTS public.escolas (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome        TEXT NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.escolas ENABLE ROW LEVEL SECURITY;

-- 2. USUÁRIOS (Admin, Coordenador, Secretaria, Professor)
CREATE TABLE IF NOT EXISTS public.usuarios (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    escola_id   UUID REFERENCES public.escolas(id) ON DELETE CASCADE, -- NULL para Super Admin
    nome        TEXT NOT NULL,
    email       TEXT UNIQUE NOT NULL,
    perfil      TEXT NOT NULL CHECK (perfil IN ('super_admin', 'admin', 'coordenador', 'secretaria', 'professor')),
    created_at  TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;

-- 3. TURMAS
CREATE TABLE IF NOT EXISTS public.turmas (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    escola_id     UUID REFERENCES public.escolas(id) ON DELETE CASCADE NOT NULL,
    nome          TEXT NOT NULL,
    turno         TEXT NOT NULL CHECK (turno IN ('Manhã', 'Tarde', 'Noite')),
    tipo          TEXT NOT NULL, -- Ex: 'Ensino Médio', 'Ensino Fundamental'
    vagas         INTEGER DEFAULT 35,
    created_at    TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.turmas ENABLE ROW LEVEL SECURITY;

-- 4. ALUNOS
CREATE TABLE IF NOT EXISTS public.alunos (
  id uuid not null default gen_random_uuid (),
  escola_id uuid not null,
  turma_id uuid null,
  nome text not null,
  cpf text not null,
  data_nascimento date not null,
  email text not null,
  contato text null,
  tipo_responsavel text null,
  nome_responsavel text null,
  parentesco_responsavel text null,
  utiliza_transporte boolean null default false,
  rota text null,
  senha text null,
  avatar text null,
  aee_atendido boolean null default false,
  aee_especificidades text[] null,
  aee_outra_especificidade text null,
  created_at timestamp with time zone null default now(),
  auth_user_id uuid null,
  email_institucional text null,
  constraint alunos_pkey primary key (id),
  constraint alunos_auth_user_id_key unique (auth_user_id),
  constraint alunos_email_key unique (email),
  constraint alunos_auth_user_id_fkey foreign KEY (auth_user_id) references auth.users (id) on delete set null,
  constraint alunos_escola_id_fkey foreign KEY (escola_id) references public.escolas (id) on delete CASCADE,
  constraint alunos_turma_id_fkey foreign KEY (turma_id) references public.turmas (id) on delete set null
);

CREATE UNIQUE INDEX IF NOT EXISTS alunos_email_institucional_unique ON public.alunos USING btree (lower(email_institucional))
WHERE (email_institucional IS NOT NULL);

ALTER TABLE public.alunos ENABLE ROW LEVEL SECURITY;

-- 5. BOLETINS
CREATE TABLE IF NOT EXISTS public.boletins (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    escola_id       UUID REFERENCES public.escolas(id) ON DELETE CASCADE NOT NULL,
    aluno_id        UUID REFERENCES public.alunos(id) ON DELETE CASCADE NOT NULL,
    turma_id        UUID REFERENCES public.turmas(id) ON DELETE CASCADE NOT NULL,
    ano             INTEGER NOT NULL,
    periodo         TEXT NOT NULL, -- Ex: '1º Bimestre', '2º Bimestre', etc.
    pdf_base64      TEXT NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT unique_aluno_periodo UNIQUE (aluno_id, ano, periodo)
);

ALTER TABLE public.boletins ENABLE ROW LEVEL SECURITY;

-- 6. FREQUENCIAS
CREATE TABLE IF NOT EXISTS public.frequencias (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    escola_id       UUID REFERENCES public.escolas(id) ON DELETE CASCADE NOT NULL,
    turma_id        UUID REFERENCES public.turmas(id) ON DELETE CASCADE NOT NULL,
    data            DATE NOT NULL,
    registrado_por  UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    presencas       JSONB NOT NULL, -- Estrutura: { "aluno_id": "P"/"F"/"S" }
    created_at      TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT unique_turma_data UNIQUE (turma_id, data)
);

ALTER TABLE public.frequencias ENABLE ROW LEVEL SECURITY;

-- 7. OCORRÊNCIAS
CREATE TABLE IF NOT EXISTS public.ocorrencias (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    escola_id       UUID REFERENCES public.escolas(id) ON DELETE CASCADE NOT NULL,
    aluno_id        UUID REFERENCES public.alunos(id) ON DELETE CASCADE NOT NULL,
    turma_id        UUID REFERENCES public.turmas(id) ON DELETE CASCADE NOT NULL,
    data            DATE NOT NULL,
    tipo            TEXT NOT NULL,
    descricao       TEXT NOT NULL,
    responsavel     TEXT NOT NULL,
    status          TEXT DEFAULT 'Pendente' CHECK (status IN ('Pendente', 'Tratada')),
    providencias    TEXT,
    evidencia_url   TEXT,
    created_at      TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.ocorrencias ENABLE ROW LEVEL SECURITY;

-- 8. SOLICITAÇÕES
CREATE TABLE IF NOT EXISTS public.solicitacoes (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    escola_id       UUID REFERENCES public.escolas(id) ON DELETE CASCADE NOT NULL,
    tipo            TEXT NOT NULL,
    data_solicitacao DATE NOT NULL DEFAULT CURRENT_DATE,
    requerente      TEXT NOT NULL,
    detalhes        TEXT NOT NULL,
    status          TEXT DEFAULT 'Pendente',
    respostas       JSONB DEFAULT '[]'::jsonb,
    created_at      TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.solicitacoes ENABLE ROW LEVEL SECURITY;

-- 9. AEE REGISTROS
CREATE TABLE IF NOT EXISTS public.aee_registros (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    escola_id       UUID REFERENCES public.escolas(id) ON DELETE CASCADE NOT NULL,
    aluno_id        UUID REFERENCES public.alunos(id) ON DELETE CASCADE NOT NULL,
    tipo_documento  TEXT NOT NULL, -- Ex: 'PEI', 'Estudo de Caso'
    responsavel     TEXT NOT NULL,
    data_registro   DATE NOT NULL DEFAULT CURRENT_DATE,
    dados           JSONB NOT NULL, -- Estrutura dinâmica para os campos do formulário
    created_at      TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.aee_registros ENABLE ROW LEVEL SECURITY;

-- 10. AEE TIPIFICIDADES (Customizadas)
CREATE TABLE IF NOT EXISTS public.aee_tipificidades (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    escola_id       UUID REFERENCES public.escolas(id) ON DELETE CASCADE NOT NULL,
    nome            TEXT NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT unique_escola_tipificidade UNIQUE (escola_id, nome)
);

ALTER TABLE public.aee_tipificidades ENABLE ROW LEVEL SECURITY;

-- 11. AGENDA / CALENDÁRIO
CREATE TABLE IF NOT EXISTS public.agenda (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    escola_id       UUID REFERENCES public.escolas(id) ON DELETE CASCADE NOT NULL,
    turma_id        UUID REFERENCES public.turmas(id) ON DELETE CASCADE, -- NULL se geral
    titulo          TEXT NOT NULL,
    descricao       TEXT NOT NULL,
    data_evento     DATE NOT NULL,
    imagem_url      TEXT,
    created_at      TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.agenda ENABLE ROW LEVEL SECURITY;


-- ==============================================================================
-- POLÍTICAS DE SEGURANÇA (RLS)
-- Garante que nenhum dado seja exposto entre diferentes escolas (Tenants)
-- ==============================================================================

-- Função auxiliar para obter a escola do usuário autenticado
CREATE OR REPLACE FUNCTION public.obter_escola_usuario()
RETURNS UUID AS $$
BEGIN
    RETURN (SELECT escola_id FROM public.usuarios WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função auxiliar para verificar se o usuário autenticado é Super Admin
CREATE OR REPLACE FUNCTION public.eh_super_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.usuarios 
        WHERE id = auth.uid() AND perfil = 'super_admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- POLÍTICAS: ESCOLAS
CREATE POLICY "Usuários veem sua própria escola" ON public.escolas
    FOR SELECT TO authenticated USING (public.eh_super_admin() OR id = public.obter_escola_usuario());

-- POLÍTICAS: USUÁRIOS
CREATE POLICY "Usuários veem colegas da mesma escola" ON public.usuarios
    FOR SELECT TO authenticated USING (public.eh_super_admin() OR escola_id = public.obter_escola_usuario() OR id = auth.uid());

-- POLÍTICAS: TURMAS
CREATE POLICY "Isolamento de Turmas por Escola" ON public.turmas
    FOR ALL TO authenticated 
    USING (public.eh_super_admin() OR escola_id = public.obter_escola_usuario())
    WITH CHECK (public.eh_super_admin() OR escola_id = public.obter_escola_usuario());

-- POLÍTICAS: ALUNOS
CREATE POLICY "Isolamento de Alunos por Escola" ON public.alunos
    FOR ALL TO authenticated 
    USING (public.eh_super_admin() OR escola_id = public.obter_escola_usuario())
    WITH CHECK (public.eh_super_admin() OR escola_id = public.obter_escola_usuario());

-- POLÍTICAS: BOLETINS
CREATE POLICY "Isolamento de Boletins por Escola" ON public.boletins
    FOR ALL TO authenticated 
    USING (public.eh_super_admin() OR escola_id = public.obter_escola_usuario())
    WITH CHECK (public.eh_super_admin() OR escola_id = public.obter_escola_usuario());

-- POLÍTICAS: FREQUENCIAS
CREATE POLICY "Isolamento de Frequencias por Escola" ON public.frequencias
    FOR ALL TO authenticated 
    USING (public.eh_super_admin() OR escola_id = public.obter_escola_usuario())
    WITH CHECK (public.eh_super_admin() OR escola_id = public.obter_escola_usuario());

-- POLÍTICAS: OCORRÊNCIAS
CREATE POLICY "Isolamento de Ocorrencias por Escola" ON public.ocorrencias
    FOR ALL TO authenticated 
    USING (public.eh_super_admin() OR escola_id = public.obter_escola_usuario())
    WITH CHECK (public.eh_super_admin() OR escola_id = public.obter_escola_usuario());

-- POLÍTICAS: SOLICITAÇÕES
CREATE POLICY "Isolamento de Solicitacoes por Escola" ON public.solicitacoes
    FOR ALL TO authenticated 
    USING (public.eh_super_admin() OR escola_id = public.obter_escola_usuario())
    WITH CHECK (public.eh_super_admin() OR escola_id = public.obter_escola_usuario());

-- POLÍTICAS: AEE REGISTROS
CREATE POLICY "Isolamento de AEE Registros por Escola" ON public.aee_registros
    FOR ALL TO authenticated 
    USING (public.eh_super_admin() OR escola_id = public.obter_escola_usuario())
    WITH CHECK (public.eh_super_admin() OR escola_id = public.obter_escola_usuario());

-- POLÍTICAS: AEE TIPIFICIDADES
CREATE POLICY "Isolamento de AEE Tipificidades por Escola" ON public.aee_tipificidades
    FOR ALL TO authenticated 
    USING (public.eh_super_admin() OR escola_id = public.obter_escola_usuario())
    WITH CHECK (public.eh_super_admin() OR escola_id = public.obter_escola_usuario());

-- POLÍTICAS: AGENDA
CREATE POLICY "Isolamento de Agenda por Escola" ON public.agenda
    FOR ALL TO authenticated 
    USING (public.eh_super_admin() OR escola_id = public.obter_escola_usuario())
    WITH CHECK (public.eh_super_admin() OR escola_id = public.obter_escola_usuario());

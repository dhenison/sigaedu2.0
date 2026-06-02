-- ==============================================================================
-- SIGAEDU — Script de Migração Inicial (SaaS Multi-Tenant Core)
-- Execute no Editor SQL do seu projeto Supabase
-- ==============================================================================

-- 1. Habilita extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Cria a tabela de escolas (Os Tenants)
CREATE TABLE IF NOT EXISTS public.escolas (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome            TEXT NOT NULL,
    cnpj            TEXT UNIQUE NOT NULL,
    subdominio      TEXT UNIQUE NOT NULL, -- Ex: 'barrao.sigaedu.com.br'
    plano           TEXT DEFAULT 'basico', -- 'basico', 'premium', 'avancado'
    status          TEXT DEFAULT 'ativo', -- 'ativo', 'suspenso'
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Cria a tabela de usuários vinculados à escola
CREATE TABLE IF NOT EXISTS public.usuarios (
    id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    escola_id       UUID REFERENCES public.escolas(id) ON DELETE CASCADE, -- NULL apenas para Super Admin Global
    nome            TEXT NOT NULL,
    email           TEXT UNIQUE NOT NULL,
    perfil          TEXT NOT NULL, -- 'super_admin', 'admin', 'coordenador', 'secretaria', 'professor'
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Habilita RLS em escolas e usuários
ALTER TABLE public.escolas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;

-- Políticas para Escolas
CREATE POLICY "Super admin total e usuários vêem sua própria escola" ON public.escolas
    FOR SELECT USING (
        (SELECT perfil FROM public.usuarios WHERE id = auth.uid()) = 'super_admin'
        OR id = (SELECT escola_id FROM public.usuarios WHERE id = auth.uid())
    );

CREATE POLICY "Apenas Super Admin pode gerenciar escolas" ON public.escolas
    FOR ALL USING (
        (SELECT perfil FROM public.usuarios WHERE id = auth.uid()) = 'super_admin'
    );

-- 4. Tabela de Boletins Individuais (Atualizada para Multi-Tenant)
CREATE TABLE IF NOT EXISTS public.boletins (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    escola_id       UUID REFERENCES public.escolas(id) ON DELETE CASCADE,
    aluno_id        UUID REFERENCES public.alunos(id) ON DELETE CASCADE,
    turma_id        UUID REFERENCES public.turmas(id) ON DELETE CASCADE,
    ano             INTEGER NOT NULL,
    periodo         TEXT NOT NULL, -- Ex: '1º Bimestre', '2º Bimestre', etc.
    pdf_base64      TEXT NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_aluno_periodo UNIQUE (aluno_id, ano, periodo)
);

-- Habilita RLS nos Boletins
ALTER TABLE public.boletins ENABLE ROW LEVEL SECURITY;

-- Política de isolamento do boletim por escola
CREATE POLICY "Isolamento de Boletins por Escola" ON public.boletins
    AS RESTRICTIVE
    USING (
        (SELECT perfil FROM public.usuarios WHERE id = auth.uid()) = 'super_admin'
        OR escola_id = (SELECT escola_id FROM public.usuarios WHERE id = auth.uid())
    );

-- 5. RPC de Busca Segura para o Aplicativo do Aluno
CREATE OR REPLACE FUNCTION public.obter_boletim_aluno(
    p_matricula TEXT
)
RETURNS TABLE (
    id UUID,
    ano INTEGER,
    periodo TEXT,
    pdf_base64 TEXT,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Validação de entrada
    IF p_matricula IS NULL OR TRIM(p_matricula) = '' THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT b.id, b.ano, b.periodo, b.pdf_base64, b.created_at
    FROM public.boletins b
    JOIN public.alunos a ON a.id = b.aluno_id
    WHERE LOWER(TRIM(a.matricula)) = LOWER(TRIM(p_matricula))
    ORDER BY b.ano DESC, b.periodo ASC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.obter_boletim_aluno(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.obter_boletim_aluno(TEXT) TO authenticated;

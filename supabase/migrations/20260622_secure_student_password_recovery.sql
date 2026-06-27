-- Recuperacao segura do Portal do Aluno.
-- A Edge Function acessa esta RPC com service_role; o navegador nunca recebe dados do aluno.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER TABLE public.alunos
  ADD COLUMN IF NOT EXISTS auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS email_institucional TEXT,
  ADD COLUMN IF NOT EXISTS data_nascimento DATE;

CREATE UNIQUE INDEX IF NOT EXISTS alunos_email_institucional_unique
  ON public.alunos (LOWER(email_institucional))
  WHERE email_institucional IS NOT NULL;

CREATE TABLE IF NOT EXISTS public.recuperacao_acesso_tentativas (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  chave_hash TEXT NOT NULL,
  criada_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.recuperacao_acesso_tentativas ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS recuperacao_acesso_tentativas_busca
  ON public.recuperacao_acesso_tentativas (chave_hash, criada_em DESC);

CREATE OR REPLACE FUNCTION public.solicitar_recuperacao_aluno(
  p_cpf TEXT,
  p_data_nascimento DATE,
  p_chave_hash TEXT
)
RETURNS TABLE (email_institucional TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_cpf IS NULL OR p_data_nascimento IS NULL OR p_chave_hash IS NULL THEN
    RETURN;
  END IF;

  IF LENGTH(REGEXP_REPLACE(p_cpf, '\D', '', 'g')) <> 11 THEN
    RETURN;
  END IF;

  IF (
    SELECT COUNT(*)
    FROM public.recuperacao_acesso_tentativas t
    WHERE t.chave_hash = p_chave_hash
      AND t.criada_em > NOW() - INTERVAL '15 minutes'
  ) >= 5 THEN
    RETURN;
  END IF;

  INSERT INTO public.recuperacao_acesso_tentativas (chave_hash)
  VALUES (p_chave_hash);

  RETURN QUERY
  SELECT a.email_institucional
  FROM public.alunos a
  WHERE REGEXP_REPLACE(a.cpf, '\D', '', 'g') = REGEXP_REPLACE(p_cpf, '\D', '', 'g')
    AND a.data_nascimento = p_data_nascimento
    AND a.auth_user_id IS NOT NULL
    AND a.email_institucional IS NOT NULL
  LIMIT 1;
END;
$$;

REVOKE ALL ON FUNCTION public.solicitar_recuperacao_aluno(TEXT, DATE, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.solicitar_recuperacao_aluno(TEXT, DATE, TEXT) FROM anon;
REVOKE ALL ON FUNCTION public.solicitar_recuperacao_aluno(TEXT, DATE, TEXT) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.solicitar_recuperacao_aluno(TEXT, DATE, TEXT) TO service_role;

REVOKE ALL ON TABLE public.recuperacao_acesso_tentativas FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, DELETE ON TABLE public.recuperacao_acesso_tentativas TO service_role;

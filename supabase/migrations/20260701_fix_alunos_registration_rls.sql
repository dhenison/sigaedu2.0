-- ==============================================================================
-- SIGAEDU - Correção de RLS para cadastro de alunos
-- Execute no SQL Editor do Supabase se o cadastro de Novo Aluno retornar erro
-- de policy/RLS ou se o aluno nao aparecer na tabela public.alunos.
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.sigaedu_escola_usuario()
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT escola_id
  FROM public.usuarios
  WHERE id = auth.uid()
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.sigaedu_eh_super_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.usuarios
    WHERE id = auth.uid()
      AND perfil = 'super_admin'
  );
$$;

ALTER TABLE public.escolas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.turmas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alunos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "SigaEDU escolas select" ON public.escolas;
CREATE POLICY "SigaEDU escolas select"
ON public.escolas
FOR SELECT
TO authenticated
USING (
  public.sigaedu_eh_super_admin()
  OR id = public.sigaedu_escola_usuario()
);

DROP POLICY IF EXISTS "SigaEDU usuarios select" ON public.usuarios;
CREATE POLICY "SigaEDU usuarios select"
ON public.usuarios
FOR SELECT
TO authenticated
USING (
  public.sigaedu_eh_super_admin()
  OR id = auth.uid()
  OR escola_id = public.sigaedu_escola_usuario()
);

DROP POLICY IF EXISTS "SigaEDU turmas por escola" ON public.turmas;
CREATE POLICY "SigaEDU turmas por escola"
ON public.turmas
FOR ALL
TO authenticated
USING (
  public.sigaedu_eh_super_admin()
  OR escola_id = public.sigaedu_escola_usuario()
)
WITH CHECK (
  public.sigaedu_eh_super_admin()
  OR escola_id = public.sigaedu_escola_usuario()
);

DROP POLICY IF EXISTS "SigaEDU alunos por escola" ON public.alunos;
CREATE POLICY "SigaEDU alunos por escola"
ON public.alunos
FOR ALL
TO authenticated
USING (
  public.sigaedu_eh_super_admin()
  OR escola_id = public.sigaedu_escola_usuario()
)
WITH CHECK (
  public.sigaedu_eh_super_admin()
  OR escola_id = public.sigaedu_escola_usuario()
);

GRANT EXECUTE ON FUNCTION public.sigaedu_escola_usuario() TO authenticated;
GRANT EXECUTE ON FUNCTION public.sigaedu_eh_super_admin() TO authenticated;

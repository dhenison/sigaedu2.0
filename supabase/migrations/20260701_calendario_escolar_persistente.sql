-- SIGAEDU - Calendario escolar persistente por escola
-- Execute no SQL Editor do Supabase para salvar selecoes do calendario definitivamente
-- e permitir integracao com Agenda e Frequencia.

ALTER TABLE public.agenda
  ADD COLUMN IF NOT EXISTS tipo TEXT NOT NULL DEFAULT 'Agendamento';

CREATE TABLE IF NOT EXISTS public.calendario_escolar (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  escola_id   UUID REFERENCES public.escolas(id) ON DELETE CASCADE NOT NULL,
  data        DATE NOT NULL,
  ano         INTEGER NOT NULL,
  estado      INTEGER NOT NULL DEFAULT 0 CHECK (estado BETWEEN 0 AND 4),
  observacao  TEXT,
  created_by  UUID REFERENCES auth.users(id) ON DELETE SET NULL DEFAULT auth.uid(),
  updated_by  UUID REFERENCES auth.users(id) ON DELETE SET NULL DEFAULT auth.uid(),
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT calendario_escolar_escola_data_unique UNIQUE (escola_id, data)
);

CREATE INDEX IF NOT EXISTS calendario_escolar_escola_ano_idx
  ON public.calendario_escolar (escola_id, ano, data);

CREATE UNIQUE INDEX IF NOT EXISTS agenda_calendario_escolar_unique
  ON public.agenda (escola_id, data_evento, tipo)
  WHERE tipo = 'CalendarioEscolar';

ALTER TABLE public.calendario_escolar ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Isolamento de Calendario Escolar por Escola" ON public.calendario_escolar;
CREATE POLICY "Isolamento de Calendario Escolar por Escola"
ON public.calendario_escolar
FOR ALL TO authenticated
USING (public.eh_super_admin() OR escola_id = public.obter_escola_usuario())
WITH CHECK (public.eh_super_admin() OR escola_id = public.obter_escola_usuario());

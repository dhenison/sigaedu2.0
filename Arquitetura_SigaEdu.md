# Arquitetura SaaS Multi-Tenant — SigaEdu

Este documento descreve as diretrizes de arquitetura de software, isolamento de dados e segurança do ecossistema SaaS **SigaEdu**, projetado para rodar em larga escala para múltiplas escolas com o menor custo de infraestrutura possível.

---

## 1. O Conceito Multi-Tenant no SigaEdu

O SigaEdu utiliza a estratégia de **Banco de Dados Único com Isolamento por Row-Level Security (RLS)** no PostgreSQL (Supabase). Todas as escolas parceiras (os Tenants) compartilham a mesma base de dados, mas o próprio servidor de banco de dados isola as informações de forma robusta e transparente.

### Vantagens do RLS no SigaEdu
* **Custo Mínimo**: Um único cluster de banco de dados Supabase é capaz de atender centenas de escolas contratantes, economizando milhares de reais em servidores.
* **Segurança no Banco de Dados**: A segurança é tratada diretamente no banco de dados. Um usuário da **Escola A** nunca conseguirá ler ou alterar registros da **Escola B**, mesmo se houver falhas no frontend das aplicações.
* **Atualização Imediata**: Novas tabelas, correções de bugs ou melhorias aplicadas no backend entram em vigor para todos os colégios e aplicativos simultaneamente.

---

## 2. Modelagem das Tabelas SaaS no Supabase

Todas as tabelas operacionais do SigaEdu (alunos, turmas, diários de classe, boletins, ocorrências) possuem uma coluna `escola_id` referenciando a escola contratante.

### 2.1 Tabela `public.escolas` (Cadastro de Escolas Parceiras)
```sql
CREATE TABLE public.escolas (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome            TEXT NOT NULL,
    cnpj            TEXT UNIQUE NOT NULL,
    subdominio      TEXT UNIQUE NOT NULL, -- Ex: 'barrao.sigaedu.com.br'
    plano           TEXT DEFAULT 'basico', -- 'basico', 'premium', 'avancado'
    status          TEXT DEFAULT 'ativo', -- 'ativo', 'suspenso'
    created_at      TIMESTAMPTZ DEFAULT NOW()
);
```

### 2.2 Tabela `public.usuarios` (Equipe Escolar e Administradores)
```sql
CREATE TABLE public.usuarios (
    id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    escola_id       UUID REFERENCES public.escolas(id) ON DELETE CASCADE, -- NULL apenas para Super Admin Global do SaaS
    nome            TEXT NOT NULL,
    email           TEXT UNIQUE NOT NULL,
    perfil          TEXT NOT NULL, -- 'super_admin', 'admin', 'coordenador', 'secretaria', 'professor'
    created_at      TIMESTAMPTZ DEFAULT NOW()
);
```

### 2.3 Exemplo de Regra de Isolamento RLS (Tabela `alunos`)
```sql
-- Habilita Row-Level Security
ALTER TABLE public.alunos ENABLE ROW LEVEL SECURITY;

-- Política Estrita de Isolamento de Escolas
CREATE POLICY "SigaEdu School Isolation" ON public.alunos
AS RESTRICTIVE
USING (
    -- Permite acesso total se for o Super Admin Global do SaaS OR se pertencer à mesma escola do registro
    (SELECT perfil FROM public.usuarios WHERE id = auth.uid()) = 'super_admin'
    OR escola_id = (SELECT escola_id FROM public.usuarios WHERE id = auth.uid())
);
```

---

## 3. Visão do Super Administrador (Painel do Franqueador)

O **SigaEdu** possui uma interface dedicada para o dono da plataforma (Super Admin):
* **Faturamento e Assinaturas**: Permite cadastrar novas escolas parceiras, configurar mensalidades e suspender contas por atraso ou inadimplência.
* **Personificação de Acesso (Impersonate)**: O painel do Super Admin exibe um dropdown com a lista de escolas ativas. Ao selecionar uma escola, o sistema carrega os dados e a interface daquele colégio específico, permitindo prestar suporte técnico imediato e realizar auditorias de forma extremamente simples.

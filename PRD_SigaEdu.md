# Documento de Requisitos de Produto (PRD) — SaaS SigaEdu

Este documento reúne todas as especificações funcionais, regras de negócios, modelagem de dados e arquitetura de permissões do ecossistema **SigaEdu**, um sistema SaaS (Software as a Service) multi-tenant de gestão escolar de alta performance.

---

## 1. Visão Geral do SigaEdu

O **SigaEdu** é uma solução educacional completa que visa digitalizar e otimizar processos pedagógicos e administrativos em escolas de ensino básico, médio e técnico. A plataforma é composta por três frentes integradas em tempo real com o banco de dados centralizado Supabase PostgreSQL:

1. **Painel Web SigaEdu (Navegador)**: Painel administrativo premium, com alto contraste e design responsivo, utilizado pelo corpo pedagógico (Super Admin, Administradores da Escola e Secretaria).
2. **App SigaEdu Corporativo (Mobile)**: Aplicativo móvel para professores e coordenadores realizarem chamadas diárias, lançarem notas, visualizarem horários e registrarem ocorrências em tempo real.
3. **App SigaEdu do Aluno (Mobile)**: Aplicativo móvel e PWA puramente de consulta (read-only) para estudantes e pais acompanharem boletins binários (Base64), faltas, agendas e quadros de medalhas.

---

## 2. Estrutura de Módulos e Permissões (RBAC)

O SigaEdu possui um controle estrito de acessos baseado em perfis (Role-Based Access Control - RBAC) integrado à nuvem.

| Funcionalidade / Aba | ID do Elemento | Administrador da Escola | Coordenador | Secretaria | Professor |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **Dashboard** | `page-dashboard` | Visualiza / Edita | Visualiza / Edita | Visualiza / Edita | - |
| **Agenda Pedagógica** | `page-agenda` | Visualiza / Edita | Visualiza / Edita | Visualiza / Não Edita | Visualiza / Não Edita |
| **Turmas** | `page-turmas` | Visualiza / Edita | Visualiza / Edita | Visualiza / Não Edita | Visualiza / Não Edita |
| **Alunos** | `page-alunos` | Visualiza / Edita | Visualiza / Edita | Visualiza / Não Edita | - |
| **Boletins** | `page-boletins` | Visualiza / Edita | Visualiza / Edita | Visualiza / Edita | Visualiza / Edita |
| **Frequência** | `page-frequencia` | Visualiza / Edita | Visualiza / Edita | - | Visualiza / Edita |
| **Solicitações** | `page-solicitacoes` | Visualiza / Edita | Visualiza / Edita | Visualiza / Edita | Visualiza / Edita |
| **Horários de Aula** | `page-horarios` | Visualiza / Edita | Visualiza / Não Edita | Visualiza / Não Edita | Visualiza / Não Edita |
| **Topo do Saber** | `page-topo-saber` | Visualiza / Edita | Visualiza / Edita | Visualiza / Edita | Visualiza / Edita |
| **Transporte** | `page-transporte` | Visualiza / Edita | Visualiza / Edita | Visualiza / Edita | - |
| **Ocorrências** | `page-ocorrencias` | Visualiza / Edita | Visualiza / Edita | - | Visualiza / Edita |
| **Livros Didáticos** | `page-livros` | Visualiza / Edita | Visualiza / Edita | Visualiza / Edita | - |

---

## 3. Especificação Detalhada de Módulos (SigaEdu)

### 3.1 Módulo de Boletins Inteligentes
* **Upload e Divisão Lote**: O administrador faz o upload do arquivo PDF completo da turma.
* **Mapeamento Resiliente**: O algoritmo analisa o texto extraído das páginas (PDF.js). Busca por CPF/Matrícula ou pelas palavras principais do nome do aluno (desconsiderando preposições e números). Caso não encontre texto, aplica fallback para a ordem alfabética exata de alunos ativos.
* **Segurança de Cache**: O binário do PDF é clonado via `.slice(0)` antes de passar pelo leitor, contornando erros de `detached ArrayBuffer` no navegador e mantendo os bytes intactos para processamento pelo PDF-Lib.
* **Salva em Lote**: Grava o PDF unificado na tabela de turmas (`boletins_turmas`) e recorta em Base64 sequencial enviando à tabela individual de alunos (`boletins`).

### 3.2 Ficha do Aluno e Migração de Turma
* **Timeline Pedagógica**: Reúne todo o histórico do aluno (faltas, devoluções, ocorrências cadastradas e dados cadastrais).
* **Migração Automática**: Ao transferir o aluno para uma nova turma, o sistema executa um `UPDATE` síncrono no banco na tabela `boletins` para todas as linhas pertencentes àquele `aluno_id`, alterando a chave `turma_id` em lote e mantendo relatórios estatísticos da nova turma íntegros.

### 3.3 Diário e Frequência Trancada
* **Lançamento de Falta**: O professor realiza a chamada direto pelo smartphone.
* **Bloqueio de Edição**: Frequências com status "Consolidado" ou "Finalizado" são trancadas. O desbloqueio exige a digitação da senha mestra administrativa: `RVS@gestor#2026`.

### 3.4 Ocorrências e Livros Didáticos
* **Ocorrências**: Cadastro de episódios disciplinares com vinculação na timeline do aluno e fluxo de tratamento e soluções pela coordenação.
* **Livros Didáticos**: Registro de entrega e devolução de obras por disciplina e aluno, com alertas de pendências ativas no cadastro do estudante.

---

## 4. O Aplicativo do Aluno SigaEdu
Interface puramente de visualização (read-only) com tema escuro premium:
* **Dashboard do Aluno**: Boas-vindas personalizadas, foto cadastrada e painel de acesso com cards glassmorphism.
* **Minhas Notas (Boletins)**: Busca os boletins individuais (PDF Base64) via RPC segura no banco de dados (`obter_boletim_aluno`). Abre o arquivo diretamente na tela ou gera um Blob para celulares.
* **Grade de Horários**: Visualização rápida da grade de aulas segmentada por turnos (Manhã, Tarde, Noite).
* **Agenda**: Atividades pedagógicas e avaliações agendadas exibidas com badges e alertas dinâmicos de proximidade (*"Hoje"*, *"Amanhã"*, *"N dias"*).
* **Topo do Saber**: Lista dinâmica das olimpíadas de conhecimento em que a escola participa, com cronômetro para as provas, link para edital oficial e o Quadro de Medalhistas pesquisável da escola.

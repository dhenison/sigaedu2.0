# PRD de Telas e Estrutura de UI — SigaEdu

Este documento é o **Especificador Visual de Telas e Componentes** do Painel Administrativo do **SigaEdu**. Ele descreve detalhadamente a estrutura de blocos, campos, botões, estados de interação e hierarquia de cada tela, permitindo que você o copie e cole diretamente no prompt do **Stitch** para gerar os layouts visuais completos.

---

## TELA 1: Login Unificado SigaEdu

### 🎨 Estilo e Atmosfera Visual (Modo Escuro Premium)
* **Fundo**: `#090D16` (Azul escuro cósmico profundo).
* **Card Central**: Glassmorphism (`rgba(17, 24, 39, 0.7)`), borda fina branca translúcida (`rgba(255,255,255,0.08)`), desfoque `backdrop-filter: blur(20px)`, cantos arredondados de `24px`.

### 🧱 Estrutura de Elementos (De cima para baixo)
1. **Espaço para Logo (Logo Box)**:
   * Retângulo centralizado (`150px` x `45px`) com o logotipo do **SigaEdu** em vetor de cor branca brilhante.
2. **Subtítulo de Identidade**:
   * Texto: *"Acesso Inteligente à Gestão Escolar"*. Fonte `Inter`, cor `#94A3B8`, tamanho `12px`, centralizado.
3. **Campo 1: E-mail de Acesso**:
   * Rótulo (Label): *"E-mail"* (Tamanho `11px`, negrito, cor `#64748B`, caixa alta).
   * Input: Fundo escuro fosco (`rgba(255,255,255,0.02)`), borda `#1E293B`, texto branco `#FFFFFF`, cantos `10px`, ícone de envelope sutil à esquerda.
4. **Campo 2: Senha**:
   * Rótulo (Label): *"Senha"*.
   * Input: Igual ao anterior, com ícone de cadeado e botão *"👁️ Mostrar"* ocultar senha à direita.
5. **Botão de Ação Principal (Entrar)**:
   * Texto: *"Entrar na Plataforma ➔"*.
   * Estilo: Gradiente linear Índigo para Ciano (`linear-gradient(135deg, #4F46E5, #06B6D4)`), fonte `Outfit`, tamanho `13px`, negrito, cantos `10px`, efeito de elevação no hover.
6. **Footer do Card**:
   * Link: *"Esqueceu sua senha? Recuperar acesso"* (Tamanho `11px`, cor `#6366F1` para `#06B6D4` no hover).

---

## TELA 2: Painel Principal SaaS (Super Admin)

### 🎨 Estilo e Atmosfera Visual
* **Estrutura**: Sidebar fixa à esquerda (`260px`) + Header fixo superior + Canvas de Conteúdo Central (Grid de 12 colunas).

### 🧱 Estrutura de Elementos (Componentes)

#### 1. Sidebar (Menu Lateral)
* **Logo Space**: Topo com logotipo branco do **SigaEdu**.
* **Itens de Menu**: Botões com ícones vetoriais modernos e texto ao lado:
  * `[📊 Dashboard SaaS]`, `[🏫 Escolas Parceiras]`, `[💳 Planos e Faturamento]`, `[⚙️ Configurações SaaS]`.
  * *Hover State*: Fundo suave ciano translúcido (`rgba(6,182,212,0.08)`) e borda esquerda neon ativa de `3px`.

#### 2. Header (Barra Superior)
* **Seletor de Escola (Impersonate)**: Dropdown em CSS translúcido:
  * Rótulo: *"Visualizar Contexto de Escola:"*.
  * Selector: `[ Dropdown: Selecione Escola A | Escola B | Escola C ]`.
* **Perfil do Franqueador**: Nome "Administrador Geral" e avatar circular do Super Admin.

#### 3. Cards de Métricas Consolidadas (Grid Superior: 4 colunas cada)
* **Card 1: Faturamento Mensal (MRR)**: Título, Valor gigante (`R$ 48.500,00` em verde néon) e badge de crescimento (`+12.4%`).
* **Card 2: Escolas Ativas**: Título, Número gigante (`32 Escolas`) e badge (`Sem inadimplências`).
* **Card 3: Alunos Atendidos**: Título, Número gigante (`12.850 Alunos`).

#### 4. Tabela de Gestão de Escolas (Grade de 12 colunas)
* **Filtros e Ações**: Barra de busca e botão primário `[+ Adicionar Nova Escola]`.
* **Tabela de Dados**:
  * Colunas: *Escola (Nome e CNPJ)*, *Plano (Básico/Premium)*, *Status (Badge Ativo/Pendente)*, *Usuários*, *Ações*.
  * Ações da Linha: Botão `[👁️ Acessar Painel]` (Personifica a escola) e `[⚙️ Configurações de Faturamento]`.

#### 5. Modal de Confirmação por Senha Mestre (Double-Lock)
* **Estrutura**: Fundo escuro com desfoque total de fundo (`backdrop-filter: blur(12px)`). Caixa central contendo:
  * Título: *"🔐 Confirmação de Segurança Requerida"*.
  * Mensagem: *"Digite a senha mestra do sistema para executar esta ação crítica."*
  * Input: Campo de senha centralizado.
  * Botões: `[Cancelar]` em cinza e `[Confirmar Ação]` em gradiente ciano.

---

## TELA 3: Painel Local da Escola (School Admin Dashboard)

### 🧱 Estrutura de Elementos

#### 1. Sidebar Local
* **Logo Space**: Selo ou brasão da escola ativa.
* **Itens de Menu**:
  * `[📊 Painel Geral]`, `[🏫 Turmas e Grades]`, `[👥 Alunos e Timeline]`, `[📤 Enviar Boletins]`, `[📅 Frequência e Diários]`, `[⚠️ Ocorrências]`, `[📚 Livros Didáticos]`.

#### 2. Grid de Métricas Locais (4 colunas cada)
* **Card 1: Alunos Ativos**: Número de matriculados ativos da unidade.
* **Card 2: Ocorrências em Aberto**: Contador de casos pendentes de tratamento pedagógico.
* **Card 3: Boletins Publicados**: Percentual de boletins carregados no período letivo corrente.

#### 3. Quadro de Avisos e Atividades (Layout Dividido: 8 colunas e 4 colunas)
* **Bloco Principal (8 Colunas)**: Timeline de atividades recentes e solicitações pedagógicas pendentes.
* **Bloco Secundário (4 Colunas)**: Quadro de comunicados gerais com prioridades de badges coloridos.

---

## TELA 4: Módulo de Boletins Inteligentes

### 🧱 Estrutura de Elementos

#### 1. Filtros Iniciais (Barra Horizontal Superior)
* Dropdown 1: Selecionar Turma.
* Dropdown 2: Selecionar Ano Letivo.
* Dropdown 3: Selecionar Período Letivo (1º ao 4º Bimestre, Recuperação, Final).

#### 2. A Área de Dropzone (Upload do PDF Completo)
* **Estilo**: Caixa grande tracejada (`border: 2px dashed #334155`), fundo fosco, com animação pulsante leve.
* **Componentes Internos**:
  * Ícone gigante de arquivo PDF na cor vermelha/índigo.
  * Texto central: *"Clique ou arraste o arquivo PDF completo da turma aqui"* (Tamanho `13px`, negrito).
  * Subtexto: *"Tamanho máximo de arquivo: 10MB. Apenas formato PDF."*

#### 3. Modal de Progresso de Upload e Divisão (Backdrop Blur)
* **Fundo**: Preto absoluto translúcido (`rgba(0,0,0,0.85)`).
* **Card Central**: Fundo branco de alta visibilidade com borda preta.
* **Elementos Internos**:
  * Título: *"💾 Gravando Boletins no Banco..."*.
  * Barra de Progresso: Barra azul horizontal que se preenche de `0%` a `100%` dinamicamente.
  * Contador textual: *"Processando: [Nome do Aluno] (5 de 32 boletins salvos)"*.

#### 4. Grid de Mapeamento das Páginas (Visualização da Análise)
* **Cartão de Página**: Para cada página encontrada no PDF, exibe um mini-cartão contendo:
  * Cabeçalho: *"Página N"*.
  * Botão: *"👁️ Ver Página"* (Abre preview em canvas).
  * Dropdown: Seleção do Aluno associado (Busca inteligente pré-selecionada).
  * Badge de correspondência: `🟢 Matrícula`, `🔵 Nome`, ou `🟡 Manual` (Fallback alfabético).
  * Checkbox: *"Ignorar esta página"*.

---

## TELA 5: Módulo de Alunos e Ficha Individual

### 🧱 Estrutura de Elementos

#### 1. Tela de Lista de Alunos
* Barra de busca integrada com ícone de lupa.
* Filtro por série e turma.
* Grid contendo cartões dos estudantes.

#### 2. Ficha do Aluno (Visualização Modal Grande)
* **Cabeçalho da Ficha**: Foto do aluno à esquerda, nome completo (`Outfit Bold`), Matrícula e Turma.
* **Abas do Painel**:
  * **Aba 1: 🕒 Timeline Pedagógica**: Fluxo cronológico vertical de ocorrências, faltas e históricos de alteração.
  * **Aba 2: 📊 Boletins**:
    * Tabela contendo a lista de boletins publicados por ano/período.
    * Botões de ação alinhados à direita: `[👁️ Ver]`, `[📥 Baixar]` e `[🖨️ Imprimir]`.
  * **Botão de Mudança de Turma**:
    * Botão `[🔄 Mudar de Turma]` no cabeçalho.
    * Abre um modal compacto com o selector `[Selecione a Nova Turma]` e botão `[Confirmar Transferência]`.

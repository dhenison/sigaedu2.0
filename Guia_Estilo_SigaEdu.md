# Guia de Estilo e Design System — SigaEdu

Este documento define as diretrizes estéticas, paleta de cores sofisticadas, tipografia, grid responsivo, espaçamentos e especificações de UI para você gerar os layouts e telas do **Painel Administrativo do SigaEdu** diretamente no **Stitch**.

---

## 1. Conceito Estético: *Premium Tech & Glassmorphism*

O design visual do SigaEdu deve transmitir sofisticação, inovação e robustez. Adotaremos um estilo de **Design Minimalista de Alta Tecnologia** com toques de **Glassmorphism** (efeito de vidro fosco/translúcido) no tema escuro e um visual **Ultra-Clean de Alto Contraste** no tema claro.

---

## 2. Paleta de Cores Sofisticadas (SigaEdu Palette)

Evitaremos cores puras ou genéricas. Utilizaremos tonalidades HSL ajustadas para evocar sofisticação e conforto visual durante longas horas de uso do corpo escolar:

### 🌌 Tema Escuro (Modo Noturno Premium)
* **Fundo da Interface (Base Background)**: `#090D16` (Azul Escuro Cósmico Profundo).
* **Fundo de Cartões e Painéis (Card Background)**: `rgba(17, 24, 39, 0.6)` com desfoque de fundo de `blur(12px)`.
* **Cor Primária/Marca (Imperial Indigo)**: `#4F46E5` / `#6366F1` (Índigo Luminoso).
* **Cor de Destaque/Ação (Luminous Teal)**: `#06B6D4` / `#0EA5E9` (Ciano Cristalino).
* **Bordas Delicadas (Border Stroke)**: `rgba(255, 255, 255, 0.08)` (Branco Translúcido).
* **Texto Principal**: `#F1F5F9` (Off-white de alto contraste).
* **Texto Secundário**: `#94A3B8` (Cinza Muted).

### ☀️ Tema Claro (Modo Corporativo Clínico)
* **Fundo da Interface**: `#F8FAFC` (Cinza Gelo Suave).
* **Fundo de Cartões e Painéis**: `#FFFFFF` (Branco Puro).
* **Cor Primária/Marca (Deep Navy)**: `#1E1B4B` (Azul Escuro Imperial).
* **Cor de Destaque/Ação**: `#0284C7` (Azul Oceano Profundo).
* **Bordas Delicadas**: `#E2E8F0` (Cinza Suave).
* **Texto Principal**: `#0F172A` (Preto Slate).
* **Texto Secundário**: `#475569` (Cinza Escuro de Alta Legibilidade).

---

## 3. Tipografia Premium

Utilizaremos duas fontes do Google Fonts perfeitamente harmonizadas:

1. **Heading (Títulos e Destaques)**: **`Outfit`**
   * *Estilo*: Moderna, geométrica, com cantos ligeiramente arredondados. Evoca sofisticação tecnológica.
   * *Pesos recomendados*: `750 (Bold)` para títulos de seção, `800 (Extra Bold)` para o nome da escola.
2. **Body (Textos, Tabelas e Formulários)**: **`Inter`**
   * *Estilo*: Tipografia neo-grotesca extremamente legível e limpa. Perfeita para dados complexos, notas e números de diários.
   * *Pesos recomendados*: `400 (Regular)` para textos normais, `600 (Semi Bold)` para rótulos de botões.

---

## 4. Grade de Layout e Estrutura Responsiva (Stitch Grid)

O painel deve ser estruturado em um grid flexível de **12 colunas** com calhas (*gutters*) de `16px` no mobile e `24px` no desktop.

```
+-----------------------------------------------------------------------------------+
|  [LOGO SPACE] |  🏫 Escola Selecionada [Dropdown v]             [👤 Meu Perfil v] |
|  MENU LATERAL |-------------------------------------------------------------------|
|               |  📚 DASHBOARD DE MÉTRICAS (Grid de 12 Colunas)                    |
|  - Dashboard  |  +--------------------+ +--------------------+ +-----------------+ |
|  - Alunos     |  | Card 1 (4 colunas) | | Card 2 (4 colunas) | | Card 3 (4 col.) | |
|  - Boletins   |  +--------------------+ +--------------------+ +-----------------+ |
|  - Frequência |                                                                   |
|               |  +-----------------------------------+ +------------------------+ |
|               |  | Lista de Chamadas (8 colunas)     | | Alertas (4 colunas)    | |
|               |  +-----------------------------------+ +------------------------+ |
+-----------------------------------------------------------------------------------+
```

### 4.1 Menu Lateral Flutuante (Sidebar)
* **Espaço para Logo (Logo Box)**:
  * Localizado no topo do menu lateral.
  * *Dimensões*: Área retangular de `180px` de largura por `50px` de altura, com cantos arredondados de `12px` e borda suave.
  * Suporta o logotipo oficial do **SigaEdu** com transparência ou o brasão personalizado da escola selecionada.
* **Comportamento Responsivo**:
  * **Desktop (>1024px)**: Menu lateral fixado na esquerda (`width: 260px`). Exibe ícones e rótulos de texto com fontes elegantes.
  * **Tablet (768px a 1023px)**: Recolhe para modo compacto (`width: 80px`), ocultando os textos e exibindo apenas os ícones sofisticados.
  * **Mobile (<767px)**: O menu se oculta completamente. O acesso é feito através de um botão de menu hambúrguer na barra superior flutuante.

### 4.2 A Barra Superior de Contexto (Header)
* **Lado Esquerdo (Foco Multi-Tenant)**:
  * Exibe o dropdown de seleção de escolas com fundo translúcido e bordas de vidro se o perfil for `super_admin`.
  * Exibe o nome e o selo/badge do colégio ativo em fonte `Outfit (Bold)` se for perfil da escola.
* **Lado Direito (Ações do Usuário)**:
  * Avatar do usuário com foto circular ou inicial do nome estilizada.
  * Indicador visual do perfil ativo (Ex: badge verde para *Administrador*, roxo para *Professor*, azul para *Secretária*).

---

## 5. Diretrizes de Componentes Visuais no Stitch

Para gerar as telas no Stitch com a máxima sofisticação, siga estas especificações de componentes:

### A. Cartões de Métricas (Dashboard Cards)
* **Borda**: `border-radius: 16px`.
* **Sombra (Shadow)**: Efeito de profundidade sutil `box-shadow: 0 4px 30px rgba(0, 0, 0, 0.1)`.
* **Efeito Hover (Interatividade)**:
  * `transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1)`
  * Ao passar o mouse, o cartão se eleva ligeiramente (`transform: translateY(-4px)`) e a borda se ilumina com a cor de destaque (Teal/Ciano).

### B. Tabelas de Dados (Legibilidade Superior)
* **Estilo**: Sem bordas verticais, apenas linhas horizontais finas (`1px solid var(--border-color)`).
* **Nitidez**: Fundo de linhas alternadas com opacidade sutil de `2%` para melhorar a escaneabilidade dos dados de boletins ou frequência dos alunos.

### C. Botões Premium (Buttons UI)
* **Cores**: Gradientes lineares discretos (ex: Índigo para Ciano).
* **Cantos**: `border-radius: 10px` para uma estética corporativa contemporânea.

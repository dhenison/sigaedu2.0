# Workflow de Integração Contínua via GitHub — SigaEdu

Este documento descreve o fluxo de trabalho (Workflow CI/CD) profissional e integrado para o desenvolvimento do **SigaEdu**, conectando o seu Agente de Inteligência Artificial, o GitHub e o Google Studio (Android Studio / Project IDX) para visualização e compilação das telas do aplicativo.

---

## 1. O Fluxo de Trabalho Integrado (Sincronização via GitHub)

O **GitHub** será a ponte centralizadora de sincronização de todo o seu projeto. Ele permite que as alterações de código feitas em ambientes diferentes se fundam de forma limpa e automática.

```
       +------------------------------------------------------+
       |                REPOSITÓRIO NO GITHUB                 |
       |                (Nuvem Central Segura)                |
       +------------------------------------------------------+
                     ^                            |
           (git push | Ações de IA)     (git pull | Sincronização)
                     |                            v
+-----------------------------+          +-----------------------------+
| 1. AGENTE CODIFICADOR (Aqui) |          | 2. GOOGLE STUDIO (Seu PC)    |
|    (Desenvolvimento de IA)   |          |    (Visualização & Compilar)|
|                             |          |                             |
| - Programação de Lógica     |          | - Emuladores de Celular     |
| - Correção de Bugs e RLS    |          | - Testes Visuais em Android |
| - Geração de Migrações      |          | - Geração de APK/App Bundle |
+-----------------------------+          +-----------------------------+
                     |                            |
                     v                            v
          +------------------+          +------------------+
          |  Supabase Cloud  |          | Google Play / iOS|
          |  (Banco e APIs)  |          | (Lojas de Apps)  |
          +------------------+          +------------------+
```

---

## 2. Passo a Passo do Ciclo de Desenvolvimento (Ciclo de Ouro)

Para que o desenvolvimento flua de forma extremamente organizada e livre de conflitos de código:

### Passo 1: Desenvolvimento da Lógica (Aqui no Agente)
* Nós trabalhamos juntos aqui. Você me pede alterações na lógica do diário de classe, segurança RLS, correções sintáticas ou novas APIs.
* Eu realizo as modificações diretamente nos arquivos locais do projeto.
* Validamos o código (ex: checking com node) e realizamos o **`git push`** para enviar a versão mais recente e estável do SigaEdu para o seu repositório no GitHub.

---

### Passo 2: Sincronização Automática da Web (Vercel / Netlify)
* A hospedagem web do Painel do SigaEdu (Vercel ou Netlify) está conectada ao seu repositório do GitHub.
* Assim que realizamos o `git push` no Passo 1, a hospedagem detecta a mudança e atualiza o Painel de Controle na Web automaticamente em menos de 10 segundos!

---

### Passo 3: Visualização e Testes Mobile (No Google Studio / IDX / Android Studio)
* No seu computador, você abre o **Google Studio** (Android Studio ou o ambiente de nuvem Project IDX).
* Você executa o comando **`git pull`** (ou clica em sincronizar) para baixar imediatamente as últimas atualizações de código que nós criamos e enviamos para o GitHub.
* No Google Studio, você abre o emulador de celular (Android/iOS) e visualiza instantaneamente os aplicativos do Professor e do Aluno rodando com a última lógica atualizada, realizando testes visuais, ajustes de tela e compilações oficiais para as lojas de aplicativos.

---

## 3. Principais Vantagens deste Workflow

1. **Separação de Papéis de Alta Produtividade**: A inteligência artificial foca na escrita de código correto, algoritmos de leitura de PDFs e banco de dados. Você foca em testar visualmente no emulador do Google Studio, desenhar telas no Stitch e comercializar o produto.
2. **Histórico Seguro de Versões**: Se alguma alteração não funcionar como o esperado durante os testes visuais, o GitHub permite "voltar no tempo" para a versão anterior estável com um único clique.
3. **Escalabilidade de Equipe**: Se amanhã você contratar mais programadores ou designers para o SigaEdu, todos trabalharão na mesma infraestrutura do GitHub sem atropelar o código uns dos outros.

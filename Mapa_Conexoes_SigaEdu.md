# Mapa de Conexões e Fluxo de Dados — SigaEdu

Este documento descreve graficamente e conceitualmente **o que se conecta com o que** no ecossistema SaaS **SigaEdu**, explicando o fluxo de dados em tempo real.

---

## 1. O Fluxo de Dados Unificado

No SigaEdu, **todos os aplicativos e painéis se conectam a uma única fonte centralizada de verdade**: o banco de dados unificado Supabase. Isso elimina a necessidade de sincronizações lentas ou redundâncias de banco de dados.

```
                     +------------------------------------------+
                     |        BANCO DE DADOS CENTRAL            |
                     |         (Supabase PostgreSQL)            |
                     |                                          |
                     |   - escolas        - turmas              |
                     |   - alunos         - boletins            |
                     |   - diários        - ocorrências         |
                     +------------------------------------------+
                                   /     |      \
                                  /      |       \
                                 /       |        \
    +-----------------------------+      |      +-----------------------------+
    | A. PAINEL WEB (Navegador)   |      |      | C. APP DO ALUNO (Mobile)    |
    |    - Administrador / Sec    |      |      |    - Estudantes e Pais      |
    |                             |      |      |                             |
    | - Cadastra Escolas (SaaS)   |      |      | - Consulta de notas (RPC)   |
    | - Importa Boletins          |      |      | - Visualiza cronograma      |
    | - Emite documentações       |      |      | - Quadro de medalhistas     |
    +-----------------------------+      |      +-----------------------------+
                                         |
                       +---------------------------------+
                       | B. APP CORPORATIVO (Mobile)     |
                       |    - Professores / Coord        |
                       |                                 |
                       | - Chamada escolar em tempo real |
                       | - Lançamento de avaliações      |
                       | - Registro de ocorrências       |
                       +---------------------------------+
```

---

## 2. Mapa Detalhado das Conexões

### A. Painel Web Administrativo SigaEdu
* **Protocolo**: HTTPS (REST API).
* **Conexão**: Comunica-se diretamente com o Supabase Central. Envia credenciais do administrador ou secretário escolar, que são validadas de forma restritiva pela regra RLS do `escola_id`.
* **Fluxo de Escrita/Leitura**: Total (leitura e gravação de todos os dados operacionais daquela escola).

### B. Aplicativo SigaEdu Corporativo (Professores e Coordenadores)
* **Protocolo**: HTTPS + WebSockets (Realtime).
* **Conexão**: O aplicativo mobile instalado nos celulares dos professores cria conexões persistentes WebSocket com o Supabase.
* **Sincronização em Tempo Real**: Quando um coordenador aprova ou tranca um diário de classe no painel, o professor visualiza a alteração na hora no celular. Quando o professor realiza a chamada na classe, os dados são enviados diretamente à tabela central.

### C. Aplicativo SigaEdu do Aluno
* **Protocolo**: HTTPS (Leitura segura via RPC).
* **Conexão**: O aplicativo mobile instalado no aparelho do estudante realiza chamadas à API do Supabase.
* **Segurança de Acesso**: Para garantir o sigilo completo, as notas e arquivos Base64 de boletins são requisitados através da função protegida Postgres RPC (`obter_boletim_aluno`). Isso impede que requisições maliciosas acessem boletins de outros alunos. O acesso é estritamente de visualização (Read-Only).

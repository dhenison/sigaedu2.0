# Design de Fluxo e Segurança: Painel Principal SaaS SigaEdu

Este documento descreve as diretrizes de UX, segurança e engenharia de software para o desenvolvimento do **Painel Principal SaaS SigaEdu (Super Admin)** e sua integração com os **Painéis Individuais das Escolas**.

---

## 1. A Estrutura de Painéis Proposta

A sua visão de fluxo de controle está **100% correta e é altamente segura**. A divisão proposta é o padrão ouro na indústria SaaS:

```
                      +---------------------------------------+
                      |    PAINEL SAAS SIGAEDU — PRINCIPAL    |
                      |       (Visão do Franqueador / Você)   |
                      |                                       |
                      | - Gestão de Escolas (CNPJ, Contratos) |
                      | - Faturamento Geral e Assinaturas     |
                      | - [ 🔍 Dropdown: Selecionar Escola ]  |
                      +---------------------------------------+
                                          |
                        (Ao selecionar a Escola e digitar a senha)
                                          v
                      +---------------------------------------+
                      |     PAINEL DA ESCOLA (Selecionada)    |
                      |  (Visão do Diretor / Secretaria Local)|
                      |                                       |
                      | - Cadastro de Alunos e Matrículas     |
                      | - Chamadas Diárias e Boletins         |
                      | - Configurações Locais                |
                      +---------------------------------------+
```

---

## 2. Como Funciona a Personificação (Impersonation)

Para que você, como dono do SaaS, consiga gerenciar e auditar as escolas parceiras de forma simples:
1. **Login como Super Admin**: Você faz login no Painel Principal usando seu e-mail global de desenvolvedor/franqueador.
2. **O Seletor de Escola**: No cabeçalho (Header) do sistema, um componente de seleção dinâmico (`<select>`) carrega a listagem de todas as escolas cadastradas na tabela `public.escolas`.
3. **Impersonação de Contexto (Frontend)**: 
   * Ao selecionar "Escola A", o frontend atualiza a variável global `currentEscolaId` em memória.
   * O sistema limpa as telas ativas e faz uma nova requisição ao Supabase filtrando pelo ID da "Escola A".
   * A interface se transforma instantaneamente, exibindo os alunos, professores e dados daquela unidade, exatamente como se você fosse o Diretor daquela escola.
4. **Bloqueio de Escrita por RLS (Segurança)**: Embora você possa ver a tela, as políticas de segurança do banco de dados (RLS) garantem que apenas requisições autenticadas com perfil `super_admin` ou `admin` daquela respectiva escola consigam salvar dados, mantendo a integridade do sistema.

---

## 3. Camada de Segurança "Double-Lock" (Duplo Trancamento por Senha)

A sua sugestão de trancar certas configurações sensíveis com a **Senha do Administrador do Sistema** é uma prática recomendada de segurança da informação (Double-Lock). 

Isso evita cliques acidentais e garante que, mesmo se você deixar o painel Super Admin aberto no computador, ninguém consiga realizar alterações críticas.

### Onde a Senha do Sistema será exigida?
* **Ações Críticas no Painel Principal**:
  * Cadastrar uma nova escola parceira no SaaS.
  * Suspender ou reativar manualmente a assinatura de uma escola (bloquear acesso por inadimplência).
  * Excluir permanentemente o cadastro de uma escola parceira (o que apaga em cascata todos os alunos, notas e boletins dela).
  * Visualizar relatórios de faturamento consolidado de todas as escolas.

### Exemplo de Lógica no Frontend (`js/app.js`):
```javascript
// Constante com a senha mestre global do sistema (criptografada ou validada no banco/RPC)
const SYSTEM_MASTER_PASS = 'SigaEdu@SaaS#2026';

function executarAcaoCritica(callbackAcao) {
  const digitada = prompt('🔐 AÇÃO CRÍTICA DO SISTEMA!\nDigite a senha do Administrador do Sistema para prosseguir:');
  
  if (digitada === SYSTEM_MASTER_PASS) {
    callbackAcao();
  } else {
    showToast('Acesso negado. Senha do sistema incorreta.', 'erro');
  }
}

// Exemplo de aplicação na exclusão de escola
function deletarEscola(escolaId) {
  executarAcaoCritica(async () => {
    const confirmacao = confirm('⚠️ Atenção: Esta ação é IRREVERSÍVEL e apagará TODOS os dados desta escola. Confirma?');
    if (confirmacao) {
      showLoading('Excluindo escola do sistema...');
      const { error } = await supabaseClient.from('escolas').delete().eq('id', escolaId);
      hideLoading();
      if (!error) {
        showToast('Escola excluída com sucesso!', 'sucesso');
        renderListaEscolasSaaS();
      }
    }
  });
}
```

---

## 4. O Fluxo de Inicialização Inteligente

Ao desenvolver a tela de login unificada da sua plataforma web, a inicialização funcionará assim:

1. **Usuário faz Login**: O e-mail e senha são enviados ao Supabase Auth.
2. **Checagem de Perfil**: O sistema lê a tabela `public.usuarios` buscando o `perfil` correspondente ao UUID logado.
3. **Roteamento de Painel**:
   * **Se `perfil === 'super_admin'`**: O sistema renderiza o **Painel Principal SaaS SigaEdu** (dropdown de seleção de escolas parceiras, faturamento geral e ações restritas à senha mestre).
   * **Se `perfil === 'admin' | 'coordenador' | 'secretaria' | 'professor'`**: O sistema bloqueia a visualização do SaaS geral e renderiza diretamente o **Painel Local da Escola** à qual o usuário pertence (usando a FK `escola_id` dele).

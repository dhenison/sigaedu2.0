# Infraestrutura Serverless Cloud — SigaEdu

Este documento descreve as especificações de infraestrutura e hospedagem recomendadas para colocar o **SigaEdu** no ar, garantindo que o sistema rode 24 horas por dia, 7 dias por semana, com **custo operacional próximo a zero** e zero necessidade de manutenção física.

---

## 1. A Filosofia Serverless do SigaEdu

Diferente de sistemas legados de gestão que exigem o aluguel de servidores dedicados complexos (VPS como AWS EC2 ou servidores locais nas escolas), o **SigaEdu** utiliza um modelo **100% Serverless (Sem Servidores para Gerenciar)**. 

Toda a segurança física de rede, redundância elétrica e backups automáticos são delegados a grandes provedores de infraestrutura global (AWS, Cloudflare e Supabase), permitindo que você se concentre na evolução do negócio e na aquisição de escolas parceiras.

---

## 2. Os Três Pilares da Infraestrutura SigaEdu

### Pilar 1: O Backend (Supabase Cloud BaaS)
O **Supabase** atua como a infraestrutura de backend autogerenciada do SigaEdu:
* **Banco de Dados (PostgreSQL + RLS)**: O cérebro da plataforma, com backups contínuos e isolamento automático de escolas.
* **Módulo de Autenticação (Auth)**: Lida com todos os registros, logins, controle de senhas de professores e secretaria de forma segura.
* **Storage (Nuvem de Arquivos)**: Armazena as imagens de perfil de alunos/professores e arquivos em PDF de boletins.
* **Edge Functions (TypeScript)**: Scripts serverless acionados sob demanda (ex: integração de pagamento para mensalidades ou disparo automático de WhatsApp).

### Pilar 2: Hospedagem Frontend (Vercel ou Netlify CDNs)
O Painel de Controle Web do colégio é estático e distribuído via rede CDN global:
* **Hospedagem Estática**: Vercel ou Netlify (URLs personalizadas: `colegioa.sigaedu.com.br`, `colegiob.sigaedu.com.br`).
* **CI/CD Integrado**: Integrado diretamente ao Git (GitHub). Sempre que você enviar um commit para a branch `main`, a Vercel compila e atualiza o painel para todos os colégios contratantes em segundos, sem interromper o funcionamento.
* **Certificado SSL Gratuito**: Gerado e renovado automaticamente de forma ilimitada para todos os subdomínios dos colégios contratantes.

### Pilar 3: Aplicativos Móveis (iOS & Android)
* **Execução Nativa**: Os aplicativos compilados (seja para Professores ou para Alunos) rodam diretamente no hardware do smartphone.
* **Comunicação Direta**: Os apps conectam-se diretamente com a API do **Supabase** via criptografia HTTPS e conexões WebSocket rápidas para atualizações em tempo real. Não há necessidade de intermediar o tráfego por nenhum servidor próprio seu, eliminando gargalos de rede.

---

## 3. Benefícios Econômicos para a Comercialização do SigaEdu

1. **Custo Operacional Inicial de R$ 0,00 (Zero)**:
   * Os planos gratuitos do **Supabase** (que inclui banco de dados, storage e auth) e da **Vercel/Netlify** cobrem perfeitamente a fase de testes e os primeiros colégios parceiros.
   * Você só passará a pagar taxas (como a assinatura mensal de R$ 125,00 do Supabase Pro) quando seu volume de dados e o faturamento das licenças das escolas parceiras já estiverem consolidados e altos.
2. **Escalabilidade Automática**:
   * O sistema aguenta de 10 a 10.000 usuários ativos sem que você precise reconfigurar memória de servidores. Os provedores de nuvem dimensionam a banda automaticamente.
3. **Segurança de Nível Bancário**:
   * O ecossistema roda sob a segurança de infraestrutura da AWS e Cloudflare, blindado contra ataques de invasão (DDoS) de forma nativa.

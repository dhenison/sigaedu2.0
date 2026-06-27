# Recuperacao segura do Portal do Aluno

1. Execute `migrations/20260622_secure_student_password_recovery.sql` no projeto Supabase.
2. Garanta que cada aluno tenha `auth_user_id`, `email_institucional`, `cpf` e `data_nascimento` preenchidos.
3. Configure os segredos da Edge Function:
   - `SITE_URL`: origem exata do portal, sem barra final.
   - `RECOVERY_RATE_LIMIT_SECRET`: valor aleatorio longo e privado.
4. Publique a funcao `recuperar-acesso-aluno`.
5. Adicione `${SITE_URL}/redefinir_senha.html` a lista de Redirect URLs do Supabase Auth.
6. Preencha `supabase-config.js` somente com a URL do projeto e a chave `anon` publica.

Nunca coloque `SUPABASE_SERVICE_ROLE_KEY` no HTML, JavaScript publico ou repositorio. A senha do aluno deve existir apenas no Supabase Auth e nunca em uma tabela de alunos.

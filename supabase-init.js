// SigaEDU — Supabase Client Initialization and Authentication Guard
(function() {
  const currentPath = window.location.pathname;
  const currentPage = currentPath.split('/').pop() || 'index.html';

  // Páginas públicas que não precisam de autenticação administrativa
  const publicPages = ['index.html', 'login.html', 'portal_aluno.html', 'redefinir_senha.html'];
  const isPublicPage = publicPages.some(page => currentPage.startsWith(page));

  // 1. Inicializa o cliente Supabase se estiver disponível globalmente
  if (!window.supabase) {
    console.error("Supabase SDK não está carregado. Verifique os scripts da página.");
    return;
  }

  const config = window.SIGAEDU_CONFIG;
  if (!config || !config.supabaseUrl || !config.supabaseAnonKey) {
    console.error("Configurações do Supabase não encontradas.");
    return;
  }

  const supabase = window.supabase.createClient(config.supabaseUrl, config.supabaseAnonKey);
  window.supabaseClient = supabase; // Exporta globalmente

  if (isPublicPage) {
    return; // Não executa o fluxo de autenticação em páginas públicas
  }

  // 2. Verifica a sessão local
  const sessionData = localStorage.getItem('sigaedu_user_session');
  if (!sessionData) {
    window.location.href = "login.html";
    return;
  }

  let session;
  try {
    session = JSON.parse(sessionData);
  } catch(e) {
    localStorage.removeItem('sigaedu_user_session');
    window.location.href = "login.html";
    return;
  }

  window.userSession = session; // Exporta sessão globalmente

  // 3. Atualiza os dados de perfil no cabeçalho dinamicamente
  document.addEventListener("DOMContentLoaded", function() {
    // Procura o bloco do perfil do usuário no cabeçalho
    const profileContainers = document.querySelectorAll("header .flex.items-center.gap-sm.pl-sm");
    
    profileContainers.forEach(container => {
      // Nome do usuário
      const nameEl = container.querySelector(".text-right p.text-label-md");
      if (nameEl) nameEl.textContent = session.profile.nome;
      
      // Papel/Perfil do usuário
      const roleEl = container.querySelector(".text-right p.text-label-sm");
      if (roleEl) {
        const perfisTraduzidos = {
          'super_admin': 'Super Admin',
          'admin': 'Administrador',
          'coordenador': 'Coordenador',
          'secretaria': 'Secretaria',
          'professor': 'Professor'
        };
        roleEl.textContent = perfisTraduzidos[session.profile.perfil] || session.profile.perfil;
      }

      // Imagem do perfil (avatar)
      const imgEl = container.querySelector("img");
      if (imgEl && session.profile.avatar) {
        imgEl.src = session.profile.avatar;
        imgEl.alt = `${session.profile.nome} - ${session.profile.perfil}`;
      }
    });

    // 4. Fluxo de Seleção de Escola para Super Admin
    if (session.profile.perfil === 'super_admin') {
      inicializarSeletorEscolasSuperAdmin();
    } else {
      // Usuário comum herda a escola do seu próprio perfil de forma fixa
      const escolaFixa = {
        id: session.profile.escola_id,
        nome: "Minha Escola" // Nome genérico ou carregado
      };
      localStorage.setItem('sigaedu_selected_escola', JSON.stringify(escolaFixa));
      window.selectedEscola = escolaFixa;
    }
  });

  // Função para carregar e controlar a seleção de escolas do Super Admin
  async function inicializarSeletorEscolasSuperAdmin() {
    try {
      // 1. Busca todas as escolas do banco
      const { data: escolas, error } = await supabase
        .from('escolas')
        .select('*')
        .order('nome', { ascending: true });

      if (error) throw error;

      if (!escolas || escolas.length === 0) {
        alert("Nenhuma escola cadastrada no banco de dados! Crie pelo menos uma escola no painel do Supabase.");
        return;
      }

      // 2. Injeta o seletor visual no Header (ao lado do avatar no topo direito)
      const headerRight = document.querySelector("header .flex.items-center.gap-md:last-child");
      if (headerRight) {
        const switcherWrapper = document.createElement("div");
        switcherWrapper.className = "hidden sm:flex items-center bg-surface-container-high rounded-xl px-sm py-1.5 border border-surface-variant/50 focus-within:border-primary transition-all mr-sm";
        
        let activeEscola = null;
        const storedEscola = localStorage.getItem('sigaedu_selected_escola');
        if (storedEscola) {
          activeEscola = JSON.parse(storedEscola);
        }

        const optionsHtml = escolas.map(esc => {
          const isSelected = activeEscola && activeEscola.id === esc.id ? 'selected' : '';
          return `<option value="${esc.id}" ${isSelected}>${esc.nome}</option>`;
        }).join('');

        switcherWrapper.innerHTML = `
          <span class="material-symbols-outlined text-primary text-[20px] mr-xs">school</span>
          <select id="escola-switcher-select" class="bg-transparent border-none focus:ring-0 text-body-sm font-bold text-primary p-0 cursor-pointer outline-none">
            <option value="" disabled ${!activeEscola ? 'selected' : ''}>Selecionar Escola...</option>
            ${optionsHtml}
          </select>
        `;

        headerRight.insertBefore(switcherWrapper, headerRight.firstChild);

        // Event listener para troca de escola
        const selectEl = document.getElementById("escola-switcher-select");
        selectEl.addEventListener("change", function(e) {
          const escId = e.target.value;
          const esc = escolas.find(x => x.id === escId);
          if (esc) {
            localStorage.setItem('sigaedu_selected_escola', JSON.stringify(esc));
            window.location.reload();
          }
        });
      }

      // 3. Força a escolha se nenhuma escola estiver ativa
      const storedEscola = localStorage.getItem('sigaedu_selected_escola');
      if (!storedEscola) {
        mostrarModalEscolhaEscola(escolas);
      } else {
        window.selectedEscola = JSON.parse(storedEscola);
      }

    } catch (err) {
      console.error("Erro ao carregar seletor de escolas: ", err);
    }
  }

  // Cria um Modal Overlay caso o Super Admin ainda não tenha selecionado uma escola ativa
  function mostrarModalEscolhaEscola(escolas) {
    const modalHtml = `
      <div id="super-admin-school-modal" class="fixed inset-0 z-[99999] flex items-center justify-center bg-black/60 backdrop-blur-md">
        <div class="bg-white rounded-2xl p-lg max-w-md w-full shadow-2xl border border-surface-variant flex flex-col items-center text-center">
          <span class="material-symbols-outlined text-primary text-[64px] mb-sm">domain</span>
          <h2 class="text-headline-md font-extrabold text-primary">Selecione uma Escola</h2>
          <p class="text-body-md text-on-surface-variant mt-xs mb-lg">Como usuário Master, selecione qual unidade escolar deseja gerenciar e visualizar agora.</p>
          
          <select id="modal-escola-select" class="w-full border border-surface-variant rounded-xl p-md text-body-md font-bold text-primary outline-none focus:border-primary transition-all mb-lg">
            <option value="" disabled selected>Escolha a escola...</option>
            ${escolas.map(esc => `<option value="${esc.id}">${esc.nome}</option>`).join('')}
          </select>

          <button id="modal-escola-confirm" class="w-full py-4 bg-primary text-white rounded-xl font-extrabold hover:bg-primary/95 hover:scale-[1.02] active:scale-[0.98] transition-all disabled:opacity-50" disabled>
            CONFIRMAR SELEÇÃO
          </button>
        </div>
      </div>
    `;

    document.body.insertAdjacentHTML('beforeend', modalHtml);

    const selectEl = document.getElementById("modal-escola-select");
    const confirmBtn = document.getElementById("modal-escola-confirm");

    selectEl.addEventListener("change", () => {
      confirmBtn.disabled = !selectEl.value;
    });

    confirmBtn.addEventListener("click", () => {
      const escId = selectEl.value;
      const esc = escolas.find(x => x.id === escId);
      if (esc) {
        localStorage.setItem('sigaedu_selected_escola', JSON.stringify(esc));
        window.location.reload();
      }
    });
  }

})();

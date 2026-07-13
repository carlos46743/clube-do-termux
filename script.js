/* ============================================
   Clube do Termux — Scripts
   Animações: Terminal, Scroll Reveal, Counters
   ============================================ */

document.addEventListener('DOMContentLoaded', () => {

  // ============================================
  // 1. TERMINAL ANIMADO (Typewriter Effect)
  // ============================================

  const terminalBody = document.getElementById('terminalBody');
  const commands = [
    'pkg update && pkg upgrade',
    'pkg install git',
    'pkg install python',
    'pkg install nodejs',
    'git clone https://github.com/...',
    'cd projeto',
    'bash install.sh'
  ];

  let cmdIndex = 0;
  let charIndex = 0;
  let isDeleting = false;
  let currentLine = null;

  function typeCommand() {
    if (!terminalBody) return;

    if (!currentLine) {
      currentLine = document.createElement('div');
      currentLine.className = 'terminal__line';
      const promptSpan = document.createElement('span');
      promptSpan.className = 'terminal__prompt';
      promptSpan.textContent = '$';
      const cmdSpan = document.createElement('span');
      cmdSpan.className = 'terminal__cmd';
      const cursorSpan = document.createElement('span');
      cursorSpan.className = 'terminal__cursor';
      cursorSpan.textContent = '▊';
      currentLine.appendChild(promptSpan);
      currentLine.appendChild(cmdSpan);
      // Remove cursor from last line before adding new one
      const existingCursors = terminalBody.querySelectorAll('.terminal__cursor');
      existingCursors.forEach(c => c.remove());
      // Find the last .terminal__line and store cmdSpan reference
      terminalBody.appendChild(currentLine);
      window.__cmdSpan = cmdSpan;
    }

    const cmdSpan = window.__cmdSpan || currentLine.querySelector('.terminal__cmd');
    const fullCmd = commands[cmdIndex];

    if (!isDeleting) {
      // Typing forward
      if (charIndex < fullCmd.length) {
        charIndex++;
        cmdSpan.textContent = fullCmd.substring(0, charIndex);
        const delay = Math.random() * 60 + 40;
        setTimeout(typeCommand, delay);
      } else {
        // Finished typing command
        isDeleting = true;
        setTimeout(typeCommand, 1500);
      }
    } else {
      // Deleting backward
      if (charIndex > 0) {
        charIndex--;
        cmdSpan.textContent = fullCmd.substring(0, charIndex);
        setTimeout(typeCommand, 30);
      } else {
        // Move to next command
        isDeleting = false;
        cmdIndex = (cmdIndex + 1) % commands.length;
        currentLine = null;
        setTimeout(typeCommand, 400);
      }
    }
  }

  setTimeout(typeCommand, 600);

  // ============================================
  // 2. DADOS DOS CARDS (Skills, Tutoriais, Benefícios)
  // ============================================

  const skills = [
    { name: 'Personalização do Termux', icon: 'terminal' },
    { name: 'Ubuntu no Termux', icon: 'ubuntu' },
    { name: 'Kali Linux', icon: 'kali' },
    { name: 'Debian', icon: 'debian' },
    { name: 'Arch Linux', icon: 'arch' },
    { name: 'Python', icon: 'python' },
    { name: 'Bash', icon: 'bash' },
    { name: 'Shell Script', icon: 'shell' },
    { name: 'Git', icon: 'git' },
    { name: 'GitHub', icon: 'github' },
    { name: 'Node.js', icon: 'node' },
    { name: 'PHP', icon: 'php' },
    { name: 'Docker', icon: 'docker' },
    { name: 'Inteligência Artificial', icon: 'ai' },
    { name: 'Hermes', icon: 'hermes' },
    { name: 'Agentes de IA', icon: 'agents' },
    { name: 'MCP', icon: 'mcp' },
    { name: 'Automações', icon: 'automation' },
    { name: 'APIs', icon: 'api' },
    { name: 'Servidores Linux', icon: 'server' }
  ];

  const tutorials = [
    {
      emoji: '🐧',
      title: 'Personalize o Termux igual ao Kali Linux',
      desc: 'Transforme seu terminal em uma ferramenta profissional com temas, cores e ferramentas do Kali.'
    },
    {
      emoji: '📱',
      title: 'Instale Ubuntu no Android',
      desc: 'Rode Ubuntu completo dentro do Termux sem root. Aprenda o passo a passo detalhado.'
    },
    {
      emoji: '🤖',
      title: 'Hermes AI no Termux',
      desc: 'Instale e configure o Hermes, um assistente de IA poderoso, diretamente no seu celular.'
    },
    {
      emoji: '📊',
      title: 'GitHub para iniciantes',
      desc: 'Aprenda Git e GitHub do zero: commits, branches, pull requests e muito mais.'
    },
    {
      emoji: '⚡',
      title: 'Automatize tarefas com Bash',
      desc: 'Crie scripts Bash para automatizar backups, instalações e tarefas do dia a dia.'
    }
  ];

  const benefits = [
    'Conteúdo gratuito',
    'Atualizações semanais',
    'Projetos completos',
    'Código aberto',
    'IA no celular',
    'Linux sem root'
  ];

  // ============================================
  // 3. POPULAR GRADE DE SKILLS
  // ============================================

  const skillsGrid = document.getElementById('skillsGrid');
  if (skillsGrid) {
    skills.forEach(skill => {
      const card = document.createElement('div');
      card.className = 'card';
      card.innerHTML = `
        <div class="card__icon">${getIcon(skill.icon)}</div>
        <div class="card__title">${skill.name}</div>
      `;
      skillsGrid.appendChild(card);
    });
  }

  // ============================================
  // 4. POPULAR TUTORIAIS
  // ============================================

  const tutorialsGrid = document.getElementById('tutorialsGrid');
  if (tutorialsGrid) {
    tutorials.forEach(t => {
      const card = document.createElement('article');
      card.className = 'tutorial-card';
      card.innerHTML = `
        <div class="tutorial-card__img">${t.emoji}</div>
        <div class="tutorial-card__body">
          <h3 class="tutorial-card__title">${t.title}</h3>
          <p class="tutorial-card__desc">${t.desc}</p>
          <a href="#" class="tutorial-card__link">Ver tutorial &rarr;</a>
        </div>
      `;
      tutorialsGrid.appendChild(card);
    });
  }

  // ============================================
  // 5. POPULAR BENEFÍCIOS
  // ============================================

  const benefitsGrid = document.getElementById('benefitsGrid');
  if (benefitsGrid) {
    benefits.forEach(text => {
      const card = document.createElement('div');
      card.className = 'benefit-card';
      card.innerHTML = `
        <svg class="benefit-card__icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="20 6 9 17 4 12"/>
        </svg>
        <span class="benefit-card__text">${text}</span>
      `;
      benefitsGrid.appendChild(card);
    });
  }

  // ============================================
  // 6. SCROLL REVEAL
  // ============================================

  const revealElements = document.querySelectorAll('.reveal');

  const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        revealObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.15, rootMargin: '0px 0px -40px 0px' });

  revealElements.forEach(el => revealObserver.observe(el));

  // ============================================
  // 7. COUNTER ANIMATION (Estatísticas)
  // ============================================

  const statNumbers = document.querySelectorAll('.stat__number');

  const counterObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const el = entry.target;
        const target = parseInt(el.getAttribute('data-target'), 10);
        animateCounter(el, target);
        counterObserver.unobserve(el);
      }
    });
  }, { threshold: 0.5 });

  statNumbers.forEach(el => counterObserver.observe(el));

  function animateCounter(el, target) {
    const duration = 2000;
    const step = Math.max(1, Math.floor(target / 60));
    let current = 0;

    function update() {
      current += step;
      if (current >= target) {
        el.textContent = target;
        return;
      }
      el.textContent = current;
      requestAnimationFrame(update);
    }

    update();
  }

  // ============================================
  // 8. MOBILE MENU
  // ============================================

  const menuToggle = document.getElementById('menuToggle');
  const nav = document.getElementById('nav');

  if (menuToggle && nav) {
    menuToggle.addEventListener('click', () => {
      menuToggle.classList.toggle('active');
      nav.classList.toggle('open');
    });

    // Close menu on link click
    nav.querySelectorAll('.nav__link').forEach(link => {
      link.addEventListener('click', () => {
        menuToggle.classList.remove('active');
        nav.classList.remove('open');
      });
    });
  }

  // ============================================
  // 9. SVG ICONS
  // ============================================

  function getIcon(name) {
    const icons = {

      terminal: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><polyline points="4 17 10 11 4 5"/><line x1="12" y1="19" x2="20" y2="19"/></svg>`,

      ubuntu: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="3"/><circle cx="4" cy="12" r="1.5"/><circle cx="20" cy="12" r="1.5"/><circle cx="12" cy="4" r="1.5"/><circle cx="12" cy="20" r="1.5"/></svg>`,

      kali: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>`,

      debian: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 002 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><circle cx="12" cy="12" r="3"/></svg>`,

      arch: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><polygon points="12 2 3 22 12 18 21 22 12 2"/></svg>`,

      python: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><path d="M12 9H8a2 2 0 00-2 2v6a2 2 0 002 2h8a2 2 0 002-2v-3"/><path d="M16 5h-4a2 2 0 00-2 2v2"/><rect x="14" y="3" width="4" height="6" rx="1"/><circle cx="18" cy="16" r="1.5"/><circle cx="6" cy="16" r="1.5"/></svg>`,

      bash: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><path d="M4 17l6-6-6-6"/><path d="M12 19h8"/></svg>`,

      shell: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>`,

      git: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><circle cx="18" cy="18" r="3"/><circle cx="6" cy="6" r="3"/><path d="M13 6h3a2 2 0 012 2v7"/><line x1="6" y1="9" x2="6" y2="21"/></svg>`,

      github: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 00-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0020 4.77 5.07 5.07 0 0019.91 1S18.73.65 16 2.48a13.38 13.38 0 00-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 005 4.77a5.44 5.44 0 00-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 009 18.13V22"/></svg>`,

      node: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>`,

      php: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><circle cx="12" cy="12" r="10"/><path d="M8 12h2"/><path d="M14 12h2"/><path d="M9 9l1 6"/><path d="M14 9l1 6"/></svg>`,

      docker: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><rect x="10" y="8" width="4" height="4" rx="1"/><rect x="15" y="8" width="4" height="4" rx="1"/><rect x="5" y="13" width="4" height="4" rx="1"/><rect x="10" y="13" width="4" height="4" rx="1"/><rect x="15" y="13" width="4" height="4" rx="1"/><path d="M3 17h18"/><path d="M3 21h18"/></svg>`,

      ai: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><path d="M12 2a4 4 0 014 4c0 2-2 3-4 5-2-2-4-3-4-5a4 4 0 014-4z"/><path d="M6 17a3 3 0 013-3h6a3 3 0 013 3v2H6v-2z"/><circle cx="12" cy="12" r="10"/></svg>`,

      hermes: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>`,

      agents: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>`,

      mcp: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><rect x="2" y="2" width="8" height="8" rx="2"/><rect x="14" y="2" width="8" height="8" rx="2"/><rect x="2" y="14" width="8" height="8" rx="2"/><rect x="14" y="14" width="8" height="8" rx="2"/></svg>`,

      automation: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>`,

      api: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><polyline points="16 3 21 3 21 8"/><line x1="4" y1="20" x2="21" y2="3"/><polyline points="21 16 21 21 16 21"/><line x1="15" y1="15" x2="21" y2="21"/><line x1="4" y1="4" x2="9" y2="9"/></svg>`,

      server: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="40" height="40"><rect x="2" y="2" width="20" height="8" rx="2" ry="2"/><rect x="2" y="14" width="20" height="8" rx="2" ry="2"/><line x1="6" y1="6" x2="6.01" y2="6"/><line x1="6" y1="18" x2="6.01" y2="18"/></svg>`

    };

    return icons[name] || icons.terminal;
  }

});

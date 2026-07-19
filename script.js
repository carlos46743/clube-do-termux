document.addEventListener('DOMContentLoaded', () => {
  const typingEl = document.getElementById('typing');
  const cursorEl = document.getElementById('cursor');
  const text = './redes-sociais.sh --connect';

  if (typingEl) {
    let i = 0;
    function type() {
      if (i < text.length) {
        typingEl.textContent += text[i];
        i++;
        setTimeout(type, 35 + Math.random() * 25);
      }
    }
    setTimeout(type, 600);
  }

  const revealElements = document.querySelectorAll('.reveal');
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry, i) => {
      if (entry.isIntersecting) {
        setTimeout(() => {
          entry.target.classList.add('visible');
        }, 400 + i * 100);
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1 });

  revealElements.forEach(el => observer.observe(el));
});

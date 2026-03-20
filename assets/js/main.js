/* =========================================
   Mayaan Bavivaddi Portfolio — main.js
   ========================================= */

document.addEventListener('DOMContentLoaded', () => {

  // ── CUSTOM CURSOR ──────────────────────────────────────────────
  const cursor    = document.getElementById('cursor');
  const cursorDot = document.getElementById('cursorDot');

  if (window.matchMedia('(hover: hover)').matches) {
    document.addEventListener('mousemove', e => {
      const x = e.clientX, y = e.clientY;
      cursor.style.left    = x + 'px';
      cursor.style.top     = y + 'px';
      cursorDot.style.left = x + 'px';
      cursorDot.style.top  = y + 'px';
    });

    const hoverTargets = 'a, button, .hobby-card, .achievement-card, .talent-card, .gallery-item, .fav-card, .dream-card';
    document.querySelectorAll(hoverTargets).forEach(el => {
      el.addEventListener('mouseenter', () => {
        cursor.style.width       = '36px';
        cursor.style.height      = '36px';
        cursor.style.borderColor = 'var(--green)';
      });
      el.addEventListener('mouseleave', () => {
        cursor.style.width       = '18px';
        cursor.style.height      = '18px';
        cursor.style.borderColor = 'var(--pink)';
      });
    });
  }

  // ── STARFIELD CANVAS ────────────────────────────────────────────
  const canvas = document.getElementById('starfield');
  const ctx    = canvas.getContext('2d');
  let stars    = [];

  function resizeCanvas() {
    canvas.width  = window.innerWidth;
    canvas.height = window.innerHeight;
  }
  resizeCanvas();
  window.addEventListener('resize', () => { resizeCanvas(); initStars(); });

  function initStars() {
    stars = [];
    const count = Math.floor((canvas.width * canvas.height) / 5000);
    for (let i = 0; i < count; i++) {
      stars.push({
        x:       Math.random() * canvas.width,
        y:       Math.random() * canvas.height,
        r:       Math.random() * 1.5 + 0.3,
        alpha:   Math.random(),
        speed:   Math.random() * 0.008 + 0.003,
        dir:     Math.random() > 0.5 ? 1 : -1,
      });
    }
  }
  initStars();

  // Shooting stars
  const shootingStars = [];
  function spawnShootingStar() {
    shootingStars.push({
      x:      Math.random() * canvas.width,
      y:      -20,
      len:    Math.random() * 80 + 40,
      speed:  Math.random() * 6 + 4,
      angle:  Math.PI / 5,
      alpha:  1,
      life:   0,
      maxLife: Math.random() * 80 + 60,
    });
  }
  setInterval(spawnShootingStar, 2800);

  function drawFrame() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Twinkling stars
    stars.forEach(s => {
      s.alpha += s.speed * s.dir;
      if (s.alpha > 1 || s.alpha < 0.1) s.dir *= -1;
      ctx.beginPath();
      ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(232,244,255,${s.alpha})`;
      ctx.fill();
    });

    // Shooting stars
    for (let i = shootingStars.length - 1; i >= 0; i--) {
      const ss = shootingStars[i];
      ss.x    += Math.cos(ss.angle) * ss.speed;
      ss.y    += Math.sin(ss.angle) * ss.speed;
      ss.life++;
      ss.alpha = Math.max(0, 1 - ss.life / ss.maxLife);

      const grad = ctx.createLinearGradient(
        ss.x, ss.y,
        ss.x - Math.cos(ss.angle) * ss.len,
        ss.y - Math.sin(ss.angle) * ss.len
      );
      grad.addColorStop(0, `rgba(79,195,247,${ss.alpha})`);
      grad.addColorStop(1, 'rgba(79,195,247,0)');
      ctx.beginPath();
      ctx.strokeStyle = grad;
      ctx.lineWidth   = 1.5;
      ctx.moveTo(ss.x, ss.y);
      ctx.lineTo(ss.x - Math.cos(ss.angle) * ss.len, ss.y - Math.sin(ss.angle) * ss.len);
      ctx.stroke();

      if (ss.life >= ss.maxLife) shootingStars.splice(i, 1);
    }

    requestAnimationFrame(drawFrame);
  }
  drawFrame();

  // ── SCROLL REVEAL ───────────────────────────────────────────────
  const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        revealObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1 });
  document.querySelectorAll('.reveal').forEach(el => revealObserver.observe(el));

  // ── NAVBAR SCROLL SHADOW ─────────────────────────────────────────
  const navbar = document.getElementById('navbar');
  window.addEventListener('scroll', () => {
    navbar.style.boxShadow = window.scrollY > 20
      ? '0 4px 30px rgba(0,0,0,0.4)'
      : 'none';
  });

  // ── MOBILE HAMBURGER ─────────────────────────────────────────────
  const hamburger = document.getElementById('hamburger');
  const navLinks  = document.getElementById('navLinks');
  hamburger.addEventListener('click', () => {
    hamburger.classList.toggle('open');
    navLinks.classList.toggle('open');
  });
  document.querySelectorAll('.nav-link').forEach(link => {
    link.addEventListener('click', () => {
      hamburger.classList.remove('open');
      navLinks.classList.remove('open');
    });
  });

  // ── CLICK PARTICLE BURST ─────────────────────────────────────────
  document.addEventListener('click', e => {
    const colors = ['var(--pink)', 'var(--blue)', 'var(--green)'];
    for (let i = 0; i < 8; i++) {
      const p      = document.createElement('div');
      const color  = colors[Math.floor(Math.random() * colors.length)];
      const size   = Math.random() * 8 + 4;
      const angle  = Math.random() * Math.PI * 2;
      const dist   = Math.random() * 60 + 30;
      p.style.cssText = `
        position:fixed;z-index:9998;
        width:${size}px;height:${size}px;border-radius:50%;
        background:${color};
        left:${e.clientX - size / 2}px;top:${e.clientY - size / 2}px;
        pointer-events:none;
        transition:transform .6s ease,opacity .6s ease;
      `;
      document.body.appendChild(p);
      requestAnimationFrame(() => {
        p.style.transform = `translate(${Math.cos(angle) * dist}px,${Math.sin(angle) * dist}px) scale(0)`;
        p.style.opacity   = '0';
      });
      setTimeout(() => p.remove(), 700);
    }
  });

  // ── ACTIVE NAV LINK HIGHLIGHT ─────────────────────────────────────
  const sections = document.querySelectorAll('section[id], div[id]');
  const navLinkEls = document.querySelectorAll('.nav-link');
  const highlightNav = () => {
    let current = '';
    sections.forEach(sec => {
      if (window.scrollY >= sec.offsetTop - 100) current = sec.id;
    });
    navLinkEls.forEach(link => {
      link.style.color = link.getAttribute('href') === `#${current}` ? 'var(--blue)' : '';
    });
  };
  window.addEventListener('scroll', highlightNav, { passive: true });

});

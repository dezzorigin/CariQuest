// CariQuest landing — interaksi kecil, tanpa framework.
// 1. Saring quest menurut status. 2. Salin email/kata sandi demo.
// 3. Menu seluler. Hormati prefers-reduced-motion (CSS yang menangani).
(function () {
  'use strict';

  // ── Saring quest ─────────────────────────────────────────────
  var buttons = document.querySelectorAll('.filter');
  var cards = document.querySelectorAll('#quest-list .ticket');
  var emptyNote = document.getElementById('empty-note');

  function applyFilter(status) {
    var visible = 0;
    cards.forEach(function (card) {
      var show = status === 'semua' || card.dataset.status === status;
      card.hidden = !show;
      if (show) visible += 1;
    });
    emptyNote.hidden = visible !== 0;
    buttons.forEach(function (btn) {
      var active = btn.dataset.filter === status;
      btn.classList.toggle('is-active', active);
      btn.setAttribute('aria-pressed', active ? 'true' : 'false');
    });
  }

  buttons.forEach(function (btn) {
    btn.setAttribute('aria-pressed',
      btn.classList.contains('is-active') ? 'true' : 'false');
    btn.addEventListener('click', function () {
      applyFilter(btn.dataset.filter);
    });
  });

  // ── Salin ke clipboard ───────────────────────────────────────
  function wireCopy(selector) {
    document.querySelectorAll(selector).forEach(function (el) {
      el.addEventListener('click', function () {
        var text = el.dataset.copy;
        var done = function () {
          el.classList.add('copied');
          var original = el.textContent;
          el.textContent = 'Disalin';
          setTimeout(function () {
            el.classList.remove('copied');
            el.textContent = original;
          }, 1500);
        };
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(text).then(done, function () {
            fallbackCopy(text);
            done();
          });
        } else {
          fallbackCopy(text);
          done();
        }
      });
    });
  }

  function fallbackCopy(text) {
    var ta = document.createElement('textarea');
    ta.value = text;
    ta.setAttribute('readonly', '');
    ta.style.position = 'absolute';
    ta.style.left = '-9999px';
    document.body.appendChild(ta);
    ta.select();
    try { document.execCommand('copy'); } catch (e) { /* abaikan */ }
    document.body.removeChild(ta);
  }

  wireCopy('.copy-email');
  wireCopy('.copy-pass');

  // ── Menu seluler ─────────────────────────────────────────────
  var toggle = document.querySelector('.nav-toggle');
  var mobileNav = document.getElementById('nav-mobile');
  if (toggle && mobileNav) {
    toggle.addEventListener('click', function () {
      var open = mobileNav.hidden;
      mobileNav.hidden = !open;
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      toggle.setAttribute('aria-label', open ? 'Tutup menu' : 'Buka menu');
    });
    mobileNav.querySelectorAll('a').forEach(function (link) {
      link.addEventListener('click', function () {
        mobileNav.hidden = true;
        toggle.setAttribute('aria-expanded', 'false');
      });
    });
  }
})();

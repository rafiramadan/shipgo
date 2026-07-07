// Included on every protected page. Edge Middleware already blocks unauthenticated
// requests server-side — this script is UX polish on top: it fills the topbar with the
// real logged-in user, wires the logout action, and redirects client-side as a fallback
// if a cached copy of the page is ever served without a valid session.
(function () {
  function initials(name) {
    if (!name) return '?';
    const parts = name.trim().split(/\s+/);
    return ((parts[0]?.[0] || '') + (parts[1]?.[0] || '')).toUpperCase();
  }

  function renderUser(user) {
    const nameEl = document.getElementById('tbUserName');
    const roleEl = document.getElementById('tbUserRole');
    const avatarEl = document.getElementById('tbAvatarInitials');
    if (nameEl) nameEl.textContent = user.name;
    if (roleEl) roleEl.textContent = user.role;
    if (avatarEl) avatarEl.textContent = initials(user.name);
  }

  function wireLogoutMenu() {
    const trigger = document.getElementById('tbUser');
    const menu = document.getElementById('tbUserMenu');
    if (!trigger || !menu) return;
    trigger.addEventListener('click', (e) => {
      e.stopPropagation();
      menu.classList.toggle('open');
    });
    document.addEventListener('click', () => menu.classList.remove('open'));
    menu.addEventListener('click', (e) => e.stopPropagation());
    const logoutBtn = document.getElementById('tbLogoutBtn');
    if (logoutBtn) logoutBtn.addEventListener('click', window.shipgoLogout);
  }

  window.shipgoLogout = function () {
    fetch('/api/auth/logout', { method: 'POST', credentials: 'same-origin' }).finally(() => {
      window.location.href = '/login.html';
    });
  };

  async function init() {
    try {
      const res = await fetch('/api/auth/session', { credentials: 'same-origin' });
      if (!res.ok) {
        window.location.href = '/login.html?next=' + encodeURIComponent(location.pathname);
        return;
      }
      const data = await res.json();
      window.shipgoUser = data.user;
      renderUser(data.user);
      wireLogoutMenu();
      document.dispatchEvent(new CustomEvent('shipgo:auth', { detail: data.user }));
    } catch (e) {
      window.location.href = '/login.html';
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();

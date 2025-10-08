// Scripts/user.js — Coco Website frontend logic

console.log('User.js started!');

const output = document.getElementById('output');
const token = () => localStorage.getItem('token');

async function api(path, method = 'GET', body) {
  const opts = { method, headers: {} };
  if (body) {
    opts.headers['Content-Type'] = 'application/json';
    opts.body = JSON.stringify(body);
  }
  if (token()) opts.headers['Authorization'] = `Bearer ${token()}`;
  const res = await fetch(path, opts);
  const text = await res.text();
  try { return JSON.parse(text); } catch { return text; }
}

// Helper to safely attach event listeners
function on(id, event, handler) {
  const el = document.getElementById(id);
  if (el) el.addEventListener(event, handler);
}

// --- Auto-login on page load ---
window.addEventListener('DOMContentLoaded', async () => {
  if (token()) {
    try {
      const me = await api('/me');
      console.log(me);
      if (me && !me.error) {
        document.getElementById('protectedActions')?.classList.remove('hidden');
        if (output) output.textContent = `Welcome back, ${me.username || 'User'}!`;
        const controls = document.getElementById('user-controls');
        if(controls) {
            if (me.role === 'admin') controls.innerHTML = `<p style="color: brown; box-shadow: none;">Welcome back, <a href="${window.location.origin}/admin/users/${me.username}">${me.username || 'User'}</a>!</p><a href="http://127.0.0.1:5500/Create Account/" class="content-only-a"><button class="special-button">Manage Account</button></a>`;
            else controls.innerHTML = `<p style="color: brown; box-shadow: none;">Welcome back, <a href="${window.location.origin}/users/${me.username}">${me.username || 'User'}</a>!</p><a href="http://127.0.0.1:5500/Create Account/" class="content-only-a"><button class="special-button">Manage Account</button></a>`;
        }
      } else {
        // Token invalid or expired — clear it
        localStorage.removeItem('token');
      }
    } catch {
      localStorage.removeItem('token');
    }
  }
});

// --- Register ---
on('registerForm', 'submit', async e => {
  e.preventDefault();
  const fd = new FormData(e.target);
  const res = await api('/register', 'POST', {
    username: fd.get('username'),
    email: fd.get('email'),
    password: fd.get('password')
  });
  if (output) output.textContent = res;
});

// --- Login ---
on('loginForm', 'submit', async e => {
  e.preventDefault();
  const fd = new FormData(e.target);
  const res = await api('/login', 'POST', {
    username: fd.get('username'),
    password: fd.get('password')
  });
  if (res.token) {
    localStorage.setItem('token', res.token);
    document.getElementById('protectedActions')?.classList.remove('hidden');
    if (output) output.textContent = 'Logged in!';
  } else {
    if (output) output.textContent = res;
  }
});

// --- Forgot Password ---
on('forgotForm', 'submit', async e => {
  e.preventDefault();
  const fd = new FormData(e.target);
  const res = await api('/forgot-password', 'POST', { email: fd.get('email') });
  if (output) output.textContent = res;
});

// --- Reset Password ---
if (location.pathname.startsWith('/reset-password/')) {
  document.getElementById('resetForm')?.classList.remove('hidden');
  on('resetForm', 'submit', async e => {
    e.preventDefault();
    const fd = new FormData(e.target);
    const tokenParam = location.pathname.split('/').pop();
    const res = await api(`/reset-password/${tokenParam}`, 'POST', { password: fd.get('password') });
    if (output) output.textContent = res;
  });
}

// --- Get My Profile ---
on('meBtn', 'click', async () => {
  const res = await api('/me');
  if (output) output.textContent = JSON.stringify(res, null, 2);
});

// --- Admin Access ---
on('adminBtn', 'click', async () => {
  const res = await api('/admin');
  if (output) output.textContent = res;
});

// --- Logout ---
on('logoutBtn', 'click', async () => {
  await api('/logout', 'POST');
  localStorage.removeItem('token');
  document.getElementById('protectedActions')?.classList.add('hidden');
  if (output) output.textContent = 'Logged out';
});

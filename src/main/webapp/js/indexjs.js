/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


        // Mobile menu toggle
        const mobileMenuBtn = document.getElementById('mobile-menu-btn');
        const mobileMenu = document.getElementById('mobile-menu');

        mobileMenuBtn.addEventListener('click', () => {
            mobileMenu.classList.toggle('hidden');
        });

        // Catalog filtering
        function filterBooks(category) {
            const tabs = document.querySelectorAll('.catalog-tab');
            tabs.forEach(tab => {
                tab.classList.remove('bg-zinc-900', 'text-white');
                tab.classList.add('bg-zinc-200', 'text-zinc-700');
            });
            event.target.classList.remove('bg-zinc-200', 'text-zinc-700');
            event.target.classList.add('bg-zinc-900', 'text-white');

            const cards = document.querySelectorAll('.book-card');
            cards.forEach(card => {
                if (category === 'all' || card.getAttribute('data-category') === category) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        }

        // Search trigger
        function triggerSearch() {
            const query = document.getElementById('quick-search').value.trim();
            if (query) {
                showModal("Catalog Search", `Searching catalog for "${query}". Matching records found in reference database.`);
            } else {
                showModal("Catalog Search", "Please enter a search term, title, or ISBN to search the library archives.");
            }
        }

        // Auth tab switcher
        function switchAuthTab(tab) {
            const loginForm = document.getElementById('form-login');
            const registerForm = document.getElementById('form-register');
            const loginBtn = document.getElementById('btn-login-tab');
            const registerBtn = document.getElementById('btn-register-tab');

            if (tab === 'login') {
                loginForm.classList.remove('hidden');
                registerForm.classList.add('hidden');
                loginBtn.classList.add('bg-zinc-900', 'text-white');
                loginBtn.classList.remove('text-zinc-700');
                registerBtn.classList.remove('bg-zinc-900', 'text-white');
                registerBtn.classList.add('text-zinc-700');
            } else {
                loginForm.classList.add('hidden');
                registerForm.classList.remove('hidden');
                registerBtn.classList.add('bg-zinc-900', 'text-white');
                registerBtn.classList.remove('text-zinc-700');
                loginBtn.classList.remove('bg-zinc-900', 'text-white');
                loginBtn.classList.add('text-zinc-700');
            }
        }

        // Real-time password strength validator
        function validatePasswordStrength() {
            const val = document.getElementById('reg-password').value;
            
            const hasLength = val.length >= 8;
            const hasUpper = /[A-Z]/.test(val);
            const hasLower = /[a-z]/.test(val);
            const hasNumber = /[0-9]/.test(val);
            const hasSymbol = /[!@#$%^&*(),.?":{}|<>]/.test(val);

            updateRequirementItem('req-length', hasLength);
            updateRequirementItem('req-upper', hasUpper);
            updateRequirementItem('req-lower', hasLower);
            updateRequirementItem('req-number', hasNumber);
            updateRequirementItem('req-symbol', hasSymbol);

            checkPasswordMatch();
        }

        function updateRequirementItem(elementId, isValid) {
            const el = document.getElementById(elementId);
            const icon = el.querySelector('i');
            if (isValid) {
                el.classList.remove('text-zinc-400');
                el.classList.add('text-emerald-700', 'font-medium');
                icon.className = 'fa-solid fa-circle-check mr-2 text-emerald-600';
            } else {
                el.classList.remove('text-emerald-700', 'font-medium');
                el.classList.add('text-zinc-400');
                icon.className = 'fa-solid fa-circle-xmark mr-2 text-zinc-400';
            }
        }

        // Confirm password matching validator
        function checkPasswordMatch() {
            const pass = document.getElementById('reg-password').value;
            const confirmPass = document.getElementById('reg-confirm-password').value;
            const errorElement = document.getElementById('match-error');

            if (confirmPass.length > 0 && pass !== confirmPass) {
                errorElement.classList.remove('hidden');
                return false;
            } else {
                errorElement.classList.add('hidden');
                return true;
            }
        }

        // Form handlers
        async function handleLogin(e) {
    e.preventDefault();
    const form = e.target;
    const email = form.querySelector('input[type="text"], input[type="email"]').value.trim();
    const password = form.querySelector('input[type="password"]').value;

    try {
        const response = await fetch(`${window.contextPath || ''}/api/auth`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `action=login&email=${encodeURIComponent(email)}&password=${encodeURIComponent(password)}`
        });

        const data = await response.json();

        if (data.status === 'success') {
            showModal("Sign-In Successful", data.message);
            setTimeout(() => {
                window.location.href = (window.contextPath || '') + data.redirect;
            }, 1200);
        } else {
            showModal("Login Failed", data.message, true);
        }
    } catch (err) {
        showModal("Error", "Server connection failed", true);
        console.error(err);
    }
}

async function handleRegister(e) {
    e.preventDefault();
    const form = e.target;
    const name = form.querySelector('input[name="FullName"]').value.trim();
    const email = form.querySelector('input[type="email"]').value.trim();
    const password = form.querySelector('#reg-password').value;
    const confirmPass = form.querySelector('#reg-confirm-password').value;
    const role = form.querySelector('select[name="role"]').value;   // MEMBER or ADMIN

    // Password validation
    const hasLength = password.length >= 8;
    const hasUpper = /[A-Z]/.test(password);
    const hasLower = /[a-z]/.test(password);
    const hasNumber = /[0-9]/.test(password);
    const hasSymbol = /[!@#$%^&*(),.?":{}|<>]/.test(password);

    if (!hasLength || !hasUpper || !hasLower || !hasNumber || !hasSymbol) {
        showModal("Weak Password Error", "Please ensure your password satisfies all security guidelines.", true);
        return;
    }

    if (password !== confirmPass) {
        showModal("Password Mismatch", "Passwords do not match.", true);
        return;
    }

    try {
        const response = await fetch(`${window.contextPath || ''}/api/auth`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `action=register&name=${encodeURIComponent(name)}&email=${encodeURIComponent(email)}&password=${encodeURIComponent(password)}&role=${role}`
        });

        const data = await response.json();

        if (data.status === 'success') {
            showModal("Registration Successful", data.message);
            setTimeout(() => switchAuthTab('login'), 1500);
        } else {
            showModal("Registration Failed", data.message, true);
        }
    } catch (err) {
        showModal("Error", "Server connection failed", true);
        console.error(err);
    }
}

        // Modal helpers
        function showModal(title, message, isError = false) {
            document.getElementById('modal-title').innerText = title;
            document.getElementById('modal-message').innerText = message;
            const iconEl = document.getElementById('modal-icon');
            if (isError) {
                iconEl.className = 'w-12 h-12 rounded-full bg-rose-100 text-rose-600 mx-auto flex items-center justify-center text-xl';
                iconEl.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i>';
            } else {
                iconEl.className = 'w-12 h-12 rounded-full bg-zinc-100 text-zinc-900 mx-auto flex items-center justify-center text-xl';
                iconEl.innerHTML = '<i class="fa-solid fa-circle-check"></i>';
            }
            document.getElementById('notification-modal').classList.remove('hidden');
        }

        function closeModal() {
            document.getElementById('notification-modal').classList.add('hidden');
        }
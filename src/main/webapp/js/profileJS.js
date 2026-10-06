/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


 const BASE_PATH = window.contextPath || '';

document.addEventListener('DOMContentLoaded', () => {
    loadProfile();
});

function toggleMobileNav() {
    const drawer = document.getElementById('mobile-nav-drawer');
    const icon = document.getElementById('mobile-nav-icon');
    if (drawer.classList.contains('hidden')) {
        drawer.classList.remove('hidden');
        icon.className = 'fa-solid fa-xmark text-lg';
    } else {
        drawer.classList.add('hidden');
        icon.className = 'fa-solid fa-bars text-lg';
    }
}

async function loadProfile() {
    try {
        const response = await fetch(`${BASE_PATH}/api/profile`);
        if (response.status === 401) {
            window.location.href = BASE_PATH + '/index.jsp';
            return;
        }
        if (!response.ok) throw new Error("Failed to load profile");

        const data = await response.json();

        // Display values
        document.getElementById('display-member-name').innerText = data.name || 'Member';
        document.getElementById('input-name').value = data.name || '';
        document.getElementById('input-email').value = data.email || '';
        document.getElementById('input-phone').value = data.phone || '';

        // Header avatar initials
        const initials = (data.name || 'M').split(' ').map(w => w[0]).join('').substring(0, 2).toUpperCase();
        document.querySelectorAll('.w-8.h-8, .w-9.h-9').forEach(el => {
            if (el.classList.contains('rounded-full')) el.innerText = initials;
        });

        // Header name
        document.querySelectorAll('p.text-xs.font-bold.text-zinc-900').forEach(el => {
            if (el.innerText.includes('Eleanor') || el.innerText.includes('Dr.')) {
                el.innerText = data.name;
            }
        });

    } catch (err) {
        console.error(err);
        showModal("Error", "Could not load profile data.");
    }
}

function handleAvatarUpload(event) {
    const file = event.target.files[0];
    if (file) {
        const reader = new FileReader();
        reader.onload = function (e) {
            document.getElementById('profile-avatar-preview').src = e.target.result;
            showModal("Portrait Updated", "Your new reader portrait has been uploaded successfully (preview only).");
        };
        reader.readAsDataURL(file);
    }
}

async function handleProfileUpdate(event) {
    event.preventDefault();

    const name = document.getElementById('input-name').value.trim();
    const email = document.getElementById('input-email').value.trim();
    const phone = document.getElementById('input-phone').value.trim();

    try {
        const response = await fetch(`${BASE_PATH}/api/profile`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `action=updateProfile&name=${encodeURIComponent(name)}&email=${encodeURIComponent(email)}&phone=${encodeURIComponent(phone)}`
        });

        const data = await response.json();

        if (data.status === 'success') {
            document.getElementById('display-member-name').innerText = name;
            showModal("Profile Saved", data.message);
        } else {
            showModal("Error", data.message || "Update failed");
        }
    } catch (err) {
        console.error(err);
        showModal("Error", "Server connection failed");
    }
}

async function handlePasswordChange(event) {
    event.preventDefault();

    const currentPass = document.getElementById('current-password').value;
    const newPass = document.getElementById('new-password').value;
    const confirmPass = document.getElementById('confirm-password').value;

    if (newPass !== confirmPass) {
        showModal("Password Mismatch", "The new passwords entered do not match.");
        return;
    }

    if (newPass.length < 8) {
        showModal("Security Requirement", "New password must be at least 8 characters long.");
        return;
    }

    try {
        const response = await fetch(`${BASE_PATH}/api/profile`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `action=changePassword&currentPassword=${encodeURIComponent(currentPass)}&newPassword=${encodeURIComponent(newPass)}`
        });

        const data = await response.json();

        if (data.status === 'success') {
            document.getElementById('security-form').reset();
            showModal("Credentials Updated", data.message);
        } else {
            showModal("Error", data.message || "Password change failed");
        }
    } catch (err) {
        console.error(err);
        showModal("Error", "Server connection failed");
    }
}

function showModal(title, message) {
    document.getElementById('modal-title').innerText = title;
    document.getElementById('modal-message').innerText = message;
    document.getElementById('notification-modal').classList.remove('hidden');
}

function closeModal() {
    document.getElementById('notification-modal').classList.add('hidden');
}
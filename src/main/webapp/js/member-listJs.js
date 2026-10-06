/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

const BASE_PATH = window.contextPath || '';

let currentDeleteId = null;
let currentDeleteElement = null;

document.addEventListener('DOMContentLoaded', () => {
    loadMembers();

    // Delete Confirmation Modal Button Event Listener
    const confirmDeleteBtn = document.getElementById('confirm-delete-btn');
    if (confirmDeleteBtn) {
        confirmDeleteBtn.addEventListener('click', async () => {
            if (!currentDeleteId) return;
            
            const memberId = currentDeleteId;
            const element = currentDeleteElement;
            closeDeleteModal();

            try {
                const response = await fetch(`${BASE_PATH}/api/members?id=${memberId}`, {
                    method: 'DELETE'
                });

                const data = await response.json();

                if (data.status === 'success') {
                    if (element) {
                        element.remove();
                    }
                    showActionNotice("Member Removed", data.message || "Member has been deleted successfully.");
                    loadMembers();
                } else {
                    showActionNotice("Error", data.message || "Failed to delete member.");
                }
            } catch (err) {
                console.error(err);
                showActionNotice("Error", "Server connection failed while deleting.");
            }
        });
    }
});

// Mobile Menu
const mobileMenuBtn = document.getElementById('mobile-menu-btn');
const mobileMenu = document.getElementById('mobile-menu');
const menuIcon = document.getElementById('menu-icon');
if (mobileMenuBtn && mobileMenu) {
    mobileMenuBtn.addEventListener('click', () => {
        mobileMenu.classList.toggle('hidden');
        if (menuIcon) {
            menuIcon.className = mobileMenu.classList.contains('hidden') ? "fa-solid fa-bars" : "fa-solid fa-xmark";
        }
    });
}

async function loadMembers() {
    try {
        const response = await fetch(`${BASE_PATH}/api/members`);
        if (!response.ok) throw new Error("Failed to load members");

        const members = await response.json();
        renderMembers(members);
    } catch (err) {
        console.error(err);
        showActionNotice("Error", "Could not load members from database.");
    }
}

function renderMembers(members) {
    const tableBody = document.getElementById('members-table-body');
    const gridContainer = document.getElementById('members-grid-container');

    tableBody.innerHTML = '';
    gridContainer.innerHTML = '';

    if (!members || members.length === 0) {
        tableBody.innerHTML = `<tr><td colspan="5" class="p-8 text-center text-zinc-400 italic">No members found.</td></tr>`;
        return;
    }

    members.forEach(m => {
        const roleDisplay = m.role === 'ADMIN' ? 'Admin' : (m.membershipType || 'Member');
        const phoneDisplay = m.phone || 'Not Provided';

        // ===== Table Row =====
        const tr = document.createElement('tr');
        tr.className = "hover:bg-zinc-50/50 transition-colors";
        tr.innerHTML = `
            <td data-label="Full Name" class="p-2 sm:p-6 font-medium text-zinc-900 cursor-pointer hover:underline"
                onclick="viewMemberDetails(${m.memberId})">
                ${escapeHtml(m.name)}
            </td>
            <td data-label="Email" class="p-2 sm:p-6 text-zinc-600 font-mono text-xs">${escapeHtml(m.email)}</td>
            <td data-label="Phone" class="p-2 sm:p-6 text-zinc-500 text-xs">${escapeHtml(phoneDisplay)}</td>
            <td data-label="Role" class="p-2 sm:p-6">
                <span class="role-badge px-3 py-1 ${m.role === 'ADMIN' ? 'bg-zinc-900 text-white' : 'bg-zinc-100 text-zinc-900'} text-[10px] font-bold uppercase rounded-full">
                    ${escapeHtml(roleDisplay)}
                </span>
            </td>
            <td data-label="Actions" class="p-2 sm:p-6 text-right space-x-1 sm:space-x-2">
                <button onclick="viewMemberDetails(${m.memberId})"
                        class="text-zinc-600 hover:text-zinc-900 p-2" title="View Details">
                    <i class="fa-solid fa-id-card"></i>
                </button>
                <button onclick="deleteMember(${m.memberId}, this.closest('tr'))" class="text-rose-600 hover:text-rose-800 p-2" title="Remove">
                    <i class="fa-solid fa-trash-can"></i>
                </button>
            </td>
        `;
        tableBody.appendChild(tr);

        // ===== Grid Card =====
        const card = document.createElement('div');
        card.className = "bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col justify-between hover:shadow-md transition-all";
        card.innerHTML = `
            <div class="space-y-3">
                <div class="flex items-center justify-between">
                    <span class="px-3 py-1 ${m.role === 'ADMIN' ? 'bg-zinc-900 text-white' : 'bg-zinc-100 text-zinc-900'} text-[10px] font-bold uppercase rounded-full">
                        ${escapeHtml(roleDisplay)}
                    </span>
                    <button onclick="deleteMember(${m.memberId}, this.closest('.bg-white'))" class="text-rose-500 hover:text-rose-700 text-xs p-1">
                        <i class="fa-solid fa-trash-can"></i>
                    </button>
                </div>
                <h3 class="font-editorial text-xl font-medium text-zinc-900 cursor-pointer hover:underline"
                    onclick="viewMemberDetails(${m.memberId})">
                    ${escapeHtml(m.name)}
                </h3>
                <p class="text-xs font-mono text-zinc-600">${escapeHtml(m.email)}</p>
                <p class="text-xs text-zinc-500">
                    <i class="fa-solid fa-phone mr-1 text-zinc-400"></i> ${escapeHtml(phoneDisplay)}
                </p>
            </div>
            <div class="pt-6 mt-6 border-t border-zinc-100">
                <button onclick="viewMemberDetails(${m.memberId})"
                        class="w-full py-2.5 bg-zinc-900 text-white rounded-full text-xs font-bold uppercase tracking-widest hover:bg-zinc-800 transition-all text-center">
                    View Details
                </button>
            </div>
        `;
        gridContainer.appendChild(card);
    });
}

function viewMemberDetails(memberId) {
    window.location.href = `${BASE_PATH}/admin/members/member-details.jsp?id=${memberId}`;
}

function escapeHtml(text) {
    if (!text) return '';
    return text.replace(/&/g, "&amp;")
               .replace(/</g, "&lt;")
               .replace(/>/g, "&gt;")
               .replace(/"/g, "&quot;")
               .replace(/'/g, "&#039;");
}

function setMemberView(viewMode) {
    const tableContainer = document.getElementById('members-table-container');
    const gridContainer = document.getElementById('members-grid-container');
    const btnTable = document.getElementById('view-btn-table');
    const btnGrid = document.getElementById('view-btn-grid');

    if (viewMode === 'table') {
        tableContainer.classList.remove('hidden');
        gridContainer.classList.add('hidden');
        btnTable.className = 'px-4 py-2 bg-white text-zinc-900 text-xs font-bold uppercase rounded-full shadow-sm transition-all';
        btnGrid.className = 'px-4 py-2 text-zinc-600 hover:text-zinc-900 text-xs font-bold uppercase rounded-full transition-all';
    } else {
        tableContainer.classList.add('hidden');
        gridContainer.classList.remove('hidden');
        btnGrid.className = 'px-4 py-2 bg-white text-zinc-900 text-xs font-bold uppercase rounded-full shadow-sm transition-all';
        btnTable.className = 'px-4 py-2 text-zinc-600 hover:text-zinc-900 text-xs font-bold uppercase rounded-full transition-all';
    }
}

function openAddMemberModal() {
    document.getElementById('add-member-modal').classList.remove('hidden');
    generateRandomPassword();
}

function closeAddMemberModal() {
    document.getElementById('add-member-modal').classList.add('hidden');
    document.getElementById('add-member-form').reset();
}

function generateRandomPassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#$%&*!';
    let pass = '';
    for (let i = 0; i < 10; i++) {
        pass += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    document.getElementById('member-password').value = "AUR-" + pass;
}

// Custom Delete Modal Trigger
function deleteMember(memberId, element) {
    currentDeleteId = memberId;
    currentDeleteElement = element;
    document.getElementById('delete-confirm-modal').classList.remove('hidden');
}

function closeDeleteModal() {
    document.getElementById('delete-confirm-modal').classList.add('hidden');
    currentDeleteId = null;
    currentDeleteElement = null;
}

function showActionNotice(title, message) {
    document.getElementById('modal-title').innerText = title;
    document.getElementById('modal-message').innerText = message;
    document.getElementById('notification-modal').classList.remove('hidden');
}

function closeModal() {
    document.getElementById('notification-modal').classList.add('hidden');
}

// Live search
const searchInput = document.getElementById('admin-member-search');
if (searchInput) {
    searchInput.addEventListener('input', (e) => {
        const term = e.target.value.toLowerCase();
        document.querySelectorAll('#members-table-body tr').forEach(row => {
            row.style.display = row.innerText.toLowerCase().includes(term) ? '' : 'none';
        });
    });
}
/* 
 * Author List JS - Connected to real backend with Pagination
 */

let specializationMap = {}; // ID থেকে Name mapping রাখার জন্য
let authorsList = []; // মূল অথর ডেটা সংরক্ষণ করার জন্য
let currentAuthorPage = 1;
const rowsPerPage = 10; // প্রতি পেজে কয়টি আইটেম দেখাবে

document.addEventListener('DOMContentLoaded', () => {
    loadSpecializations().then(() => {
        loadAuthorsFromDB();
    });
    
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

    // Search functionality setup (Database level with debounce)
    let searchTimeout;
    const searchInput = document.getElementById('admin-author-search');
    if (searchInput) {
        searchInput.addEventListener('input', (e) => {
            clearTimeout(searchTimeout);
            const term = e.target.value.trim();
            
            searchTimeout = setTimeout(async () => {
                if (term === '') {
                    loadAuthorsFromDB();
                    return;
                }
                try {
                    const response = await fetch(`${getBaseUrl()}/AuthorServlet?action=search&term=${encodeURIComponent(term)}`);
                    if (!response.ok) return;
                    const authors = await response.json();
                    authorsList = authors;
                    currentAuthorPage = 1; // সার্চের সময় প্রথম পেজে রিসেট হবে
                    renderAuthorsUI();
                } catch (err) {
                    console.error("Database search error:", err);
                }
            }, 300); 
        });
    }
});

// ========== Render Authors with Pagination ==========
function renderAuthorsUI() {
    const tableBody = document.getElementById('authors-table-body');
    const gridContainer = document.getElementById('authors-grid-container');
    if (!tableBody || !gridContainer) return;

    tableBody.innerHTML = '';
    gridContainer.innerHTML = '';

    const totalPages = Math.ceil(authorsList.length / rowsPerPage) || 1;
    if (currentAuthorPage > totalPages) currentAuthorPage = totalPages;
    if (currentAuthorPage < 1) currentAuthorPage = 1;

    const startIdx = (currentAuthorPage - 1) * rowsPerPage;
    const paginatedItems = authorsList.slice(startIdx, startIdx + rowsPerPage);

    if (paginatedItems.length === 0) {
        tableBody.innerHTML = `
            <tr>
                <td colspan="5" class="p-8 text-center text-zinc-400 text-xs uppercase tracking-widest">
                    No authors found in the registry.
                </td>
            </tr>
        `;
        gridContainer.innerHTML = `
            <div class="col-span-full p-8 text-center text-zinc-400 text-xs uppercase tracking-widest bg-white border border-zinc-200 rounded-3xl">
                No authors found in the registry.
            </div>
        `;
        renderPaginationControls(0);
        return;
    }

    paginatedItems.forEach(a => {
        const specDisplay = specializationMap[a.specializationId] || (a.specializationId ? `ID: ${a.specializationId}` : 'N/A');

        // Table Row
        const tr = document.createElement('tr');
        tr.className = "hover:bg-zinc-50/50 transition-colors";
        tr.innerHTML = `
            <td class="p-4 sm:p-6 font-medium text-zinc-900 cursor-pointer hover:underline" onclick="fetchAuthorProfile('${a.fullName}')">${a.fullName}</td>
            <td class="p-4 sm:p-6 text-zinc-600 text-xs uppercase">${a.nationality || ''}</td>
            <td class="p-4 sm:p-6 text-zinc-600 text-xs uppercase">${specDisplay}</td>
            <td class="p-4 sm:p-6 text-zinc-500 text-xs max-w-xs truncate">${a.biography || ''}</td>
            <td class="p-4 sm:p-6 text-right space-x-2">
                <button onclick="fetchAuthorProfile('${a.fullName}')" class="text-zinc-600 hover:text-zinc-900 p-2" title="View Profile"><i class="fa-solid fa-id-card"></i></button>
                <button onclick="deleteRow(this, ${a.authorId})" class="text-rose-600 hover:text-rose-800 p-2" title="Remove"><i class="fa-solid fa-trash-can"></i></button>
            </td>
        `;
        tableBody.appendChild(tr);

        // Grid Card
        const card = document.createElement('div');
        card.className = "bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col justify-between hover:shadow-md transition-all";
        card.innerHTML = `
            <div class="space-y-3">
                <div class="flex items-center justify-between">
                    <span class="px-3 py-1 bg-zinc-100 text-zinc-900 text-[10px] font-bold uppercase rounded-full">${a.nationality || ''}</span>
                    <button onclick="deleteRow(this, ${a.authorId})" class="text-rose-500 hover:text-rose-700 text-xs"><i class="fa-solid fa-trash-can"></i></button>
                </div>
                <h3 class="font-editorial text-xl font-medium text-zinc-900">${a.fullName}</h3>
                <p class="text-xs font-semibold text-zinc-500 uppercase">${specDisplay}</p>
                <p class="text-xs text-zinc-600 leading-relaxed">${a.biography || ''}</p>
            </div>
            <div class="pt-6 mt-6 border-t border-zinc-100 flex items-center justify-between">
                <button onclick="fetchAuthorProfile('${a.fullName}')" class="w-full py-2.5 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all text-center">
                    View Profile
                </button>
            </div>
        `;
        gridContainer.appendChild(card);
    });

    renderPaginationControls(totalPages);
}

// ========== Pagination UI Generator (1, 2, 3...) ==========
function renderPaginationControls(totalPages) {
    let paginationContainer = document.getElementById('authors-pagination-container');
    
    if (!paginationContainer) {
        paginationContainer = document.createElement('div');
        paginationContainer.id = 'authors-pagination-container';
        paginationContainer.className = 'flex items-center justify-center space-x-2 pt-6 pb-2';
        
        const mainContent = document.getElementById('tab-authors');
        if (mainContent) mainContent.appendChild(paginationContainer);
    }

    if (totalPages <= 1) {
        paginationContainer.innerHTML = '';
        return;
    }

    let html = `
        <button onclick="changeAuthorPage(${currentAuthorPage - 1})" ${currentAuthorPage === 1 ? 'disabled' : ''} 
            class="px-3.5 py-2 rounded-full text-xs font-bold tracking-widest uppercase bg-white border border-zinc-200 text-zinc-700 hover:bg-zinc-100 disabled:opacity-40 disabled:cursor-not-allowed transition-all">
            <i class="fa-solid fa-chevron-left mr-1"></i> Prev
        </button>
    `;

    for (let i = 1; i <= totalPages; i++) {
        const isActive = i === currentAuthorPage;
        const btnClass = isActive 
            ? "w-9 h-9 rounded-full text-xs font-bold bg-zinc-900 text-white shadow-sm transition-all" 
            : "w-9 h-9 rounded-full text-xs font-bold bg-white border border-zinc-200 text-zinc-700 hover:bg-zinc-100 transition-all";
        
        html += `<button onclick="changeAuthorPage(${i})" class="${btnClass}">${i}</button>`;
    }

    html += `
        <button onclick="changeAuthorPage(${currentAuthorPage + 1})" ${currentAuthorPage === totalPages ? 'disabled' : ''} 
            class="px-3.5 py-2 rounded-full text-xs font-bold tracking-widest uppercase bg-white border border-zinc-200 text-zinc-700 hover:bg-zinc-100 disabled:opacity-40 disabled:cursor-not-allowed transition-all">
            Next <i class="fa-solid fa-chevron-right ml-1"></i>
        </button>
    `;

    paginationContainer.innerHTML = html;
}

function changeAuthorPage(page) {
    currentAuthorPage = page;
    renderAuthorsUI();
    window.scrollTo({ top: 200, behavior: 'smooth' });
}

const getBaseUrl = () => window.contextPath || '/SmartLibrary';

async function loadSpecializations() {
    try {
        const response = await fetch(`${getBaseUrl()}/SpecializationServlet`);
        if (!response.ok) return;
        const specs = await response.json();
        const select = document.getElementById('author-specialization');
        const loadingSpan = document.getElementById('specialization-loading');
        
        specializationMap = {}; 
        if (select) {
            select.innerHTML = '<option value="" disabled selected>Select Scholarly Specialization...</option>';
            specs.forEach(s => {
                specializationMap[s.specializationId] = s.name; 
                const opt = document.createElement('option');
                opt.value = s.name;
                opt.textContent = s.name;
                select.appendChild(opt);
            });
        }
        if (loadingSpan) loadingSpan.textContent = 'Loaded';
    } catch (e) {
        console.error("Error loading specializations:", e);
    }
}

async function loadAuthorsFromDB() {
    try {
        const response = await fetch(`${getBaseUrl()}/AuthorServlet?action=getAll`);
        if (!response.ok) return;
        const authors = await response.json();
        
        authorsList = authors; // মূল অ্যারেতে ডেটা সেভ করা হলো
        currentAuthorPage = 1;
        renderAuthorsUI();

        const searchInput = document.getElementById('admin-author-search');
        if (searchInput && searchInput.value) {
            searchInput.dispatchEvent(new Event('input'));
        }
    } catch (e) {
        console.error("Error loading authors:", e);
    }
}

function openAddAuthorModal() {
    const modal = document.getElementById('add-author-modal');
    if (modal) modal.classList.remove('hidden');
}

function closeAddAuthorModal() {
    const modal = document.getElementById('add-author-modal');
    if (modal) modal.classList.add('hidden');
}

async function handleAuthorSubmit(event) {
    event.preventDefault();
    const formData = new FormData(event.target);
    try {
        const response = await fetch(`${getBaseUrl()}/AuthorServlet`, {
            method: 'POST',
            body: new URLSearchParams(formData)
        });
        if (response.ok) {
            closeAddAuthorModal();
            event.target.reset();
            loadAuthorsFromDB();
        }
    } catch (e) {
        console.error("Error submitting author:", e);
    }
}

let currentDeleteId = null;

async function deleteRow(element, id) {
    currentDeleteId = id;
    const modalTitle = document.getElementById('modal-title');
    const modalMessage = document.getElementById('modal-message');
    const modalIcon = document.getElementById('modal-icon');
    const modalIconContainer = document.getElementById('modal-icon-container');
    const singleBox = document.getElementById('single-action-box');
    const dualBox = document.getElementById('dual-action-box');
    const modal = document.getElementById('notification-modal');

    if (!modal) return;

    modalTitle.textContent = 'Remove Author';
    modalMessage.textContent = 'Are you sure you want to remove this author from the scholarly registry?';
    
    modalIconContainer.className = 'w-12 h-12 rounded-full bg-rose-50 text-rose-600 mx-auto flex items-center justify-center text-xl';
    modalIcon.className = 'fa-solid fa-triangle-exclamation';

    singleBox.classList.add('hidden');
    dualBox.classList.remove('hidden');

    modal.classList.remove('hidden');

    const confirmBtn = document.getElementById('modal-confirm-btn');
    const newConfirmBtn = confirmBtn.cloneNode(true);
    confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);

    document.getElementById('modal-confirm-btn').addEventListener('click', async () => {
        closeModal();
        if (!currentDeleteId) return;
        try {
            const response = await fetch(`${getBaseUrl()}/AuthorServlet?action=delete&id=${currentDeleteId}`);
            if (response.ok) {
                loadAuthorsFromDB();
                showNotice('Author Removed', 'Author deleted successfully', 'check');
            }
        } catch (e) {
            console.error("Error deleting author:", e);
        }
    });
}

function setAuthorView(viewType) {
    const tableContainer = document.getElementById('authors-table-container');
    const gridContainer = document.getElementById('authors-grid-container');
    const btnTable = document.getElementById('view-btn-table');
    const btnGrid = document.getElementById('view-btn-grid');

    if (viewType === 'table') {
        tableContainer.classList.remove('hidden');
        gridContainer.classList.add('hidden');
        btnTable.className = "px-3 sm:px-4 py-2 rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase bg-white text-zinc-900 shadow-sm transition-all flex items-center gap-1.5 sm:gap-2";
        btnGrid.className = "px-3 sm:px-4 py-2 rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase text-zinc-500 hover:text-zinc-900 transition-all flex items-center gap-1.5 sm:gap-2";
    } else {
        tableContainer.classList.add('hidden');
        gridContainer.classList.remove('hidden');
        btnGrid.className = "px-3 sm:px-4 py-2 rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase bg-white text-zinc-900 shadow-sm transition-all flex items-center gap-1.5 sm:gap-2";
        btnTable.className = "px-3 sm:px-4 py-2 rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase text-zinc-500 hover:text-zinc-900 transition-all flex items-center gap-1.5 sm:gap-2";
    }
}

async function fetchAuthorProfile(name) {
    try {
        const response = await fetch(`${getBaseUrl()}/AuthorServlet?action=getProfile&name=${encodeURIComponent(name)}`);
        if (!response.ok) return;
        const profile = await response.json();
        
        const specDisplay = specializationMap[profile.specializationId] || (profile.specializationId ? `ID: ${profile.specializationId}` : 'N/A');

        document.getElementById('profile-modal-name').textContent = profile.fullName || name;
        document.getElementById('profile-modal-nationality').textContent = profile.nationality || 'N/A';
        document.getElementById('profile-modal-specialization').textContent = specDisplay;
        document.getElementById('profile-modal-bio').textContent = profile.biography || 'No biography available.';
        
        const modal = document.getElementById('author-profile-modal');
        if (modal) modal.classList.remove('hidden');
    } catch (e) {
        console.error("Error fetching profile:", e);
    }
}

function closeAuthorProfileModal() {
    const modal = document.getElementById('author-profile-modal');
    if (modal) modal.classList.add('hidden');
}

function closeModal() {
    const modal = document.getElementById('notification-modal');
    if (modal) modal.classList.add('hidden');
}
const BASE_PATH = window.contextPath || '';

let categoriesList = []; 
let currentCategoryPage = 1;
const rowsPerPage = 10; 
let categoryIdToDelete = null; // Delete korar ID store korar jonno

document.addEventListener('DOMContentLoaded', () => {
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

    // Confirmation Modal er Delete Button e click korle API call hobe
    const confirmDeleteBtn = document.getElementById('confirm-delete-btn');
    if (confirmDeleteBtn) {
        confirmDeleteBtn.addEventListener('click', () => {
            if (categoryIdToDelete !== null) {
                executeDeleteCategory(categoryIdToDelete);
                closeDeleteConfirmModal();
            }
        });
    }

    loadCategories();
});

// Database theke category load korar function (Search query soho)
async function loadCategories() {
    const searchInput = document.getElementById('admin-category-search');
    const searchTerm = searchInput ? searchInput.value.trim() : '';
    
    let url = `${BASE_PATH}/api/categories`;
    if (searchTerm !== '') {
        url += `?search=${encodeURIComponent(searchTerm)}`;
    }

    try {
        const response = await fetch(url);
        if (response.ok) {
            const categories = await response.json();
            categoriesList = categories; 
            currentCategoryPage = 1;
            renderCategoriesUI();
        }
    } catch (e) {
        console.error("Error loading categories:", e);
    }
}

// ========== Render Categories with Pagination ==========
function renderCategoriesUI() {
    const tableBody = document.getElementById('categories-table-body');
    const gridContainer = document.getElementById('categories-grid-container');
    
    if (!tableBody || !gridContainer) return;

    tableBody.innerHTML = '';
    gridContainer.innerHTML = '';

    const totalPages = Math.ceil(categoriesList.length / rowsPerPage) || 1;
    if (currentCategoryPage > totalPages) currentCategoryPage = totalPages;
    if (currentCategoryPage < 1) currentCategoryPage = 1;

    const startIdx = (currentCategoryPage - 1) * rowsPerPage;
    const paginatedItems = categoriesList.slice(startIdx, startIdx + rowsPerPage);

    if (paginatedItems.length === 0) {
        tableBody.innerHTML = `
            <tr>
                <td colspan="3" class="p-8 text-center text-zinc-400 text-xs uppercase tracking-widest">
                    No categories found in the taxonomy repository.
                </td>
            </tr>
        `;
        gridContainer.innerHTML = `
            <div class="col-span-full p-8 text-center text-zinc-400 text-xs uppercase tracking-widest bg-white border border-zinc-200 rounded-3xl">
                No categories found in the taxonomy repository.
            </div>
        `;
        renderPaginationControls(0);
        return;
    }

    paginatedItems.forEach(cat => {
        const name = cat.categoryName || '';
        const description = cat.description || '';
        const id = cat.categoryId;

        // ========== Table Row ==========
        const tr = document.createElement('tr');
        tr.className = 'hover:bg-zinc-50/50 transition-colors';
        tr.innerHTML = `
            <td class="p-4 sm:p-6 font-medium text-zinc-900 cursor-pointer hover:underline"></td>
            <td class="p-4 sm:p-6 text-zinc-500 text-xs truncate max-w-[200px] sm:max-w-xs"></td>
            <td class="p-4 sm:p-6 text-right space-x-1 sm:space-x-2">
                <button class="text-zinc-600 hover:text-zinc-900 p-2 view-btn" title="View Details">
                    <i class="fa-solid fa-folder-open"></i>
                </button>
                <button class="text-rose-600 hover:text-rose-800 p-2 delete-btn" title="Remove">
                    <i class="fa-solid fa-trash-can"></i>
                </button>
            </td>
        `;

        tr.cells[0].textContent = name;
        tr.cells[0].onclick = () => fetchCategoryDetails(name, description);
        tr.cells[1].textContent = description;
        tr.querySelector('.view-btn').onclick = () => fetchCategoryDetails(name, description);
        tr.querySelector('.delete-btn').onclick = () => promptDeleteCategory(id);

        tableBody.appendChild(tr);

        // ========== Grid Card ==========
        const card = document.createElement('div');
        card.className = 'bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col justify-between hover:shadow-md transition-all';
        card.innerHTML = `
            <div class="space-y-3">
                <div class="flex items-center justify-end">
                    <button class="text-rose-500 hover:text-rose-700 text-xs p-1 card-delete">
                        <i class="fa-solid fa-trash-can"></i>
                    </button>
                </div>
                <h3 class="font-editorial text-xl font-medium text-zinc-900 cursor-pointer hover:underline card-title"></h3>
                <p class="text-xs text-zinc-600 leading-relaxed card-desc"></p>
            </div>
            <div class="pt-6 mt-6 border-t border-zinc-100 flex items-center justify-between">
                <button class="w-full py-2.5 bg-zinc-900 text-white rounded-full text-xs font-bold uppercase tracking-widest hover:bg-zinc-800 transition-all text-center card-view">
                    View Details
                </button>
            </div>
        `;
        card.querySelector('.card-title').textContent = name;
        card.querySelector('.card-title').onclick = () => fetchCategoryDetails(name, description);
        card.querySelector('.card-desc').textContent = description;
        card.querySelector('.card-view').onclick = () => fetchCategoryDetails(name, description);
        card.querySelector('.card-delete').onclick = () => promptDeleteCategory(id);
        gridContainer.appendChild(card);
    });

    renderPaginationControls(totalPages);
}

// ========== Pagination UI Generator (1, 2, 3...) ==========
function renderPaginationControls(totalPages) {
    let paginationContainer = document.getElementById('categories-pagination-container');
    
    if (!paginationContainer) {
        paginationContainer = document.createElement('div');
        paginationContainer.id = 'categories-pagination-container';
        paginationContainer.className = 'flex items-center justify-center space-x-2 pt-6 pb-2';
        
        const mainContent = document.getElementById('tab-categories');
        if (mainContent) mainContent.appendChild(paginationContainer);
    }

    if (totalPages <= 1) {
        paginationContainer.innerHTML = '';
        return;
    }

    let html = `
        <button onclick="changeCategoryPage(${currentCategoryPage - 1})" ${currentCategoryPage === 1 ? 'disabled' : ''} 
            class="px-3.5 py-2 rounded-full text-xs font-bold tracking-widest uppercase bg-white border border-zinc-200 text-zinc-700 hover:bg-zinc-100 disabled:opacity-40 disabled:cursor-not-allowed transition-all">
            <i class="fa-solid fa-chevron-left mr-1"></i> Prev
        </button>
    `;

    for (let i = 1; i <= totalPages; i++) {
        const isActive = i === currentCategoryPage;
        const btnClass = isActive 
            ? "w-9 h-9 rounded-full text-xs font-bold bg-zinc-900 text-white shadow-sm transition-all" 
            : "w-9 h-9 rounded-full text-xs font-bold bg-white border border-zinc-200 text-zinc-700 hover:bg-zinc-100 transition-all";
        
        html += `<button onclick="changeCategoryPage(${i})" class="${btnClass}">${i}</button>`;
    }

    html += `
        <button onclick="changeCategoryPage(${currentCategoryPage + 1})" ${currentCategoryPage === totalPages ? 'disabled' : ''} 
            class="px-3.5 py-2 rounded-full text-xs font-bold tracking-widest uppercase bg-white border border-zinc-200 text-zinc-700 hover:bg-zinc-100 disabled:opacity-40 disabled:cursor-not-allowed transition-all">
            Next <i class="fa-solid fa-chevron-right ml-1"></i>
        </button>
    `;

    paginationContainer.innerHTML = html;
}

function changeCategoryPage(page) {
    currentCategoryPage = page;
    renderCategoriesUI();
    window.scrollTo({ top: 200, behavior: 'smooth' });
}

function setCategoryView(viewMode) {
    const tableContainer = document.getElementById('categories-table-container');
    const gridContainer = document.getElementById('categories-grid-container');
    const btnTable = document.getElementById('view-btn-table');
    const btnGrid = document.getElementById('view-btn-grid');

    if (viewMode === 'table') {
        tableContainer.classList.remove('hidden');
        gridContainer.classList.add('hidden');
        btnTable.className = 'px-3.5 sm:px-4 py-2 bg-white text-zinc-900 text-[11px] sm:text-xs font-bold uppercase rounded-full shadow-sm transition-all';
        btnGrid.className = 'px-3.5 sm:px-4 py-2 text-zinc-600 hover:text-zinc-900 text-[11px] sm:text-xs font-bold uppercase rounded-full transition-all';
    } else {
        tableContainer.classList.add('hidden');
        gridContainer.classList.remove('hidden');
        btnGrid.className = 'px-3.5 sm:px-4 py-2 bg-white text-zinc-900 text-[11px] sm:text-xs font-bold uppercase rounded-full shadow-sm transition-all';
        btnTable.className = 'px-3.5 sm:px-4 py-2 text-zinc-600 hover:text-zinc-900 text-[11px] sm:text-xs font-bold uppercase rounded-full transition-all';
    }
}

function openAddCategoryModal() {
    document.getElementById('add-category-modal').classList.remove('hidden');
}

function closeAddCategoryModal() {
    document.getElementById('add-category-modal').classList.add('hidden');
    document.getElementById('add-category-form').reset();
}

async function handleCategorySubmit(event) {
    event.preventDefault();
    const formData = new FormData(event.target);

    try {
        const response = await fetch(`${BASE_PATH}/api/categories`, {
            method: 'POST',
            body: new URLSearchParams(formData)
        });

        if (response.ok) {
            closeAddCategoryModal();
            loadCategories();
            showActionNotice("Category Created", "Category has been successfully saved to DB.");
        } else {
            showActionNotice("Error", "Failed to save category to server.");
        }
    } catch (e) {
        console.error("Error submitting category:", e);
        showActionNotice("Error", "Network or server error occurred.");
    }
}

// Delete Confirmation Modal Handler Functions
function promptDeleteCategory(id) {
    categoryIdToDelete = id;
    document.getElementById('delete-confirm-modal').classList.remove('hidden');
}

function closeDeleteConfirmModal() {
    categoryIdToDelete = null;
    document.getElementById('delete-confirm-modal').classList.add('hidden');
}

async function executeDeleteCategory(id) {
    try {
        const response = await fetch(`${BASE_PATH}/api/categories?id=${id}`, {
            method: 'DELETE'
        });
        if (response.ok) {
            loadCategories();
            showActionNotice("Registry Updated", "Category removed from database successfully.");
        } else {
            showActionNotice("Error", "Failed to remove category.");
        }
    } catch (e) {
        console.error("Error deleting category:", e);
    }
}

function fetchCategoryDetails(name, description) {
    document.getElementById('details-modal-name').innerText = name;
    document.getElementById('details-modal-desc').innerText = description;
    document.getElementById('category-details-modal').classList.remove('hidden');
}

function closeCategoryDetailsModal() {
    document.getElementById('category-details-modal').classList.add('hidden');
}

function showActionNotice(title, message) {
    document.getElementById('modal-title').innerText = title;
    document.getElementById('modal-message').innerText = message;
    document.getElementById('notification-modal').classList.remove('hidden');
}

function closeModal() {
    document.getElementById('notification-modal').classList.add('hidden');
}

// Database-driven Search Event Listener with Debounce
let searchTimer;
const searchInput = document.getElementById('admin-category-search');
if (searchInput) {
    searchInput.addEventListener('input', () => {
        clearTimeout(searchTimer);
        searchTimer = setTimeout(() => {
            loadCategories(); 
        }, 300); 
    });
}
/* 
 * Admin Dashboard JS - Connected to real Hibernate backend with Pagination
 * Author: Suprakash + Monami help 😊
 */

let books = [];
let currentView = 'table';
let searchQuery = '';
let currentPage = 1;
const rowsPerPage = 10; // প্রতি পেজে কয়টি আইটেম দেখাবে

const BASE_URL = window.APP_CONTEXT || '';

// ========== Mobile Menu ==========
const mobileMenuBtn = document.getElementById('mobile-menu-btn');
const mobileMenu = document.getElementById('mobile-menu');
const menuIcon = document.getElementById('menu-icon');

if (mobileMenuBtn && mobileMenu) {
    mobileMenuBtn.addEventListener('click', () => {
        mobileMenu.classList.toggle('hidden');
        if (menuIcon) {
            menuIcon.className = mobileMenu.classList.contains('hidden') 
                ? "fa-solid fa-bars" 
                : "fa-solid fa-xmark";
        }
    });
}

// ========== Fetch Dashboard Data ==========
async function fetchBooksData() {
    const tableBody = document.getElementById('books-table-body');

    if (tableBody) {
        tableBody.innerHTML = `
            <tr>
                <td colspan="4" class="p-8 text-center text-zinc-400 text-xs uppercase tracking-widest">
                    <i class="fa-solid fa-circle-notch fa-spin mr-2"></i> Loading inventory from sanctuary...
                </td>
            </tr>
        `;
    }

    try {
        const response = await fetch(`${BASE_URL}/api/dashboard-books`);
        if (!response.ok) throw new Error("Failed to load books");

        const data = await response.json();

        books = (data.books || []).map(b => ({
            id: b.id,
            title: b.title,
            author: b.author,
            category: b.category,
            available: b.available
        }));

        document.getElementById('stat-total-books').textContent = data.totalBooks || 0;
        document.getElementById('stat-issued-books').textContent = data.issuedBooks || 0;

        currentPage = 1; // ডেটা রিফ্রেশ হলে প্রথম পেজে রিসেট হবে
        renderBooks();
    } catch (err) {
        console.error("Dashboard fetch error:", err);
        showActionNotice("Error", "Could not load books from server.");
        if (tableBody) {
            tableBody.innerHTML = `
                <tr>
                    <td colspan="4" class="p-8 text-center text-rose-500 text-xs uppercase tracking-widest">
                        Failed to load inventory data.
                    </td>
                </tr>
            `;
        }
    }
}

// ========== View Switch ==========
function setView(view) {
    currentView = view;
    const btnTable = document.getElementById('view-btn-table');
    const btnGrid = document.getElementById('view-btn-grid');
    const containerTable = document.getElementById('view-container-table');
    const containerGrid = document.getElementById('view-container-grid');

    if (view === 'table') {
        btnTable.className = "px-3 sm:px-4 py-2 rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase bg-white text-zinc-900 shadow-sm transition-all flex items-center gap-1.5 sm:gap-2";
        btnGrid.className = "px-3 sm:px-4 py-2 rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase text-zinc-500 hover:text-zinc-900 transition-all flex items-center gap-1.5 sm:gap-2";
        containerTable.classList.remove('hidden');
        containerGrid.classList.add('hidden');
    } else {
        btnGrid.className = "px-3 sm:px-4 py-2 rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase bg-white text-zinc-900 shadow-sm transition-all flex items-center gap-1.5 sm:gap-2";
        btnTable.className = "px-3 sm:px-4 py-2 rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase text-zinc-500 hover:text-zinc-900 transition-all flex items-center gap-1.5 sm:gap-2";
        containerGrid.classList.remove('hidden');
        containerTable.classList.add('hidden');
    }
    renderBooks();
}

function filterBooks() {
    searchQuery = document.getElementById('admin-book-search').value.toLowerCase().trim();
    currentPage = 1; // সার্চ করার সময় প্রথম পেজে রিসেট হবে
    renderBooks();
}

// ========== Render Books with Pagination ==========
function renderBooks() {
    const filtered = books.filter(b => 
        b.title.toLowerCase().includes(searchQuery) || 
        b.author.toLowerCase().includes(searchQuery) ||
        b.category.toLowerCase().includes(searchQuery)
    );

    // প্যাগিনেশন ক্যালকুলেশন
    const totalPages = Math.ceil(filtered.length / rowsPerPage) || 1;
    if (currentPage > totalPages) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;

    const startIdx = (currentPage - 1) * rowsPerPage;
    const paginatedItems = filtered.slice(startIdx, startIdx + rowsPerPage);

    const tableBody = document.getElementById('books-table-body');
    const gridContainer = document.getElementById('view-container-grid');
    
    tableBody.innerHTML = '';
    gridContainer.innerHTML = '';

    if (paginatedItems.length === 0) {
        tableBody.innerHTML = `
            <tr>
                <td colspan="4" class="p-8 text-center text-zinc-400 text-xs uppercase tracking-widest">
                    No volumes found in the sanctuary.
                </td>
            </tr>
        `;
        gridContainer.innerHTML = `
            <div class="col-span-full p-8 text-center text-zinc-400 text-xs uppercase tracking-widest bg-white border border-zinc-200 rounded-3xl">
                No volumes found in the sanctuary.
            </div>
        `;
        renderPaginationControls(0);
        return;
    }

paginatedItems.forEach(book => {
    
        // 'CHECKED OUT' লজিক বাদ দিয়ে শুধুমাত্র কয়টি কপি আছে তা দেখানোর জন্য
        const isAvailable = parseInt(book.available) > 0;
    const badgeClass = isAvailable ? 'bg-emerald-100 text-emerald-900' : 'bg-amber-100 text-amber-900';
    const badgeText = `${book.available} COPIES AVAILABLE`;

        // Table Row
        const row = document.createElement('tr');
        row.className = 'hover:bg-zinc-50/50 transition-colors';
        row.innerHTML = `
            <td class="p-4 sm:p-6 font-medium text-zinc-900">
                ${book.title} <span class="block text-xs font-normal text-zinc-500">${book.author}</span>
            </td>
            <td class="p-4 sm:p-6 text-zinc-600 text-xs uppercase">${book.category}</td>
            <td class="p-4 sm:p-6">
                <span class="px-3 py-1 ${badgeClass} text-[10px] font-bold uppercase rounded-full">${badgeText}</span>
            </td>
            <td class="p-4 sm:p-6 text-right space-x-2">
                <button onclick="editBook(${book.id})" class="text-zinc-600 hover:text-zinc-900 p-2" title="Edit">
    <i class="fa-solid fa-pen-to-square"></i>
</button>
                <button onclick="deleteBook(${book.id})" class="text-rose-600 hover:text-rose-800 p-2">
                    <i class="fa-solid fa-trash-can"></i>
                </button>
            </td>
        `;
        tableBody.appendChild(row);

        // Grid Card
        const card = document.createElement('div');
        card.className = 'bg-white border border-zinc-200 rounded-3xl p-5 shadow-sm flex flex-col justify-between space-y-4 hover:border-zinc-300 transition-all';
        card.innerHTML = `
            <div class="space-y-4">
                <div class="relative w-full h-52 rounded-2xl overflow-hidden bg-zinc-100">
                    <img src="https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?q=80&w=600&auto=format&fit=crop" 
                         alt="${book.title}" class="w-full h-full object-cover">
                    <div class="absolute top-3 left-3">
                        <span class="px-3 py-1 ${badgeClass} text-[10px] font-bold tracking-wider uppercase rounded-full shadow-sm">${badgeText}</span>
                    </div>
                </div>
                <div>
                    <span class="text-[10px] font-bold tracking-widest uppercase text-zinc-500">${book.category}</span>
                    <h3 class="font-editorial text-xl font-medium text-zinc-900 mt-0.5 leading-snug">${book.title}</h3>
                    <p class="text-xs text-zinc-500 mt-1">${book.author} • ID #${book.id}</p>
                </div>
            </div>
            <div class="flex items-center justify-between pt-4 border-t border-zinc-100 text-xs">
                <span class="text-zinc-500 text-[11px]">Sanctuary Shelf</span>
                <div class="flex items-center space-x-1">
                    <button onclick="editBook(${book.id})" class="text-zinc-600 hover:text-zinc-900 p-2" title="Edit">
    <i class="fa-solid fa-pen-to-square"></i>
</button>
                    <button onclick="deleteBook(${book.id})" class="text-rose-600 hover:text-rose-800 p-2" title="Delete">
                        <i class="fa-solid fa-trash-can"></i>
                    </button>
                </div>
            </div>
        `;
        gridContainer.appendChild(card);
    });
    renderPaginationControls(totalPages);
}

// ========== Pagination UI Generator (1, 2, 3...) ==========
function renderPaginationControls(totalPages) {
    let paginationContainer = document.getElementById('pagination-container');
    
    // যদি পেজিনেশন কন্টেইনার আগে থেকে না থাকে, তবে টেবিল ও গ্রিডের নিচে এটি ইনজেক্ট করে দেবো
    if (!paginationContainer) {
        paginationContainer = document.createElement('div');
        paginationContainer.id = 'pagination-container';
        paginationContainer.className = 'flex items-center justify-center space-x-2 pt-6 pb-2';
        
        // মেইন সেকশনের নিচে যুক্ত করা
        const mainContent = document.getElementById('tab-books');
        if (mainContent) mainContent.appendChild(paginationContainer);
    }

    if (totalPages <= 1) {
        paginationContainer.innerHTML = '';
        return;
    }

    let html = `
        <button onclick="changePage(${currentPage - 1})" ${currentPage === 1 ? 'disabled' : ''} 
            class="px-3.5 py-2 rounded-full text-xs font-bold tracking-widest uppercase bg-white border border-zinc-200 text-zinc-700 hover:bg-zinc-100 disabled:opacity-40 disabled:cursor-not-allowed transition-all">
            <i class="fa-solid fa-chevron-left mr-1"></i> Prev
        </button>
    `;

    for (let i = 1; i <= totalPages; i++) {
        const isActive = i === currentPage;
        const btnClass = isActive 
            ? "w-9 h-9 rounded-full text-xs font-bold bg-zinc-900 text-white shadow-sm transition-all" 
            : "w-9 h-9 rounded-full text-xs font-bold bg-white border border-zinc-200 text-zinc-700 hover:bg-zinc-100 transition-all";
        
        html += `<button onclick="changePage(${i})" class="${btnClass}">${i}</button>`;
    }

    html += `
        <button onclick="changePage(${currentPage + 1})" ${currentPage === totalPages ? 'disabled' : ''} 
            class="px-3.5 py-2 rounded-full text-xs font-bold tracking-widest uppercase bg-white border border-zinc-200 text-zinc-700 hover:bg-zinc-100 disabled:opacity-40 disabled:cursor-not-allowed transition-all">
            Next <i class="fa-solid fa-chevron-right ml-1"></i>
        </button>
    `;

    paginationContainer.innerHTML = html;
}

function changePage(page) {
    currentPage = page;
    renderBooks();
    // পেজ বদলালে স্ক্রিন সামান্য উপরে স্ক্রোল করবে যেন দেখতে সুবিধা হয়
    window.scrollTo({ top: 300, behavior: 'smooth' });
}

// ========== Categories for Modal ==========
async function fetchCategoriesFromDatabase() {
    const categorySelect = document.getElementById('book-category');
    try {
        const response = await fetch(`${BASE_URL}/api/categories`);
        if (!response.ok) throw new Error("Failed to load categories");

        const categories = await response.json();
        categorySelect.innerHTML = '<option value="" disabled selected>Select a category</option>';
        
        categories.forEach(cat => {
            const option = document.createElement('option');
            option.value = cat.categoryName;
            option.textContent = cat.categoryName;
            categorySelect.appendChild(option);
        });
    } catch (e) {
        console.error(e);
        categorySelect.innerHTML = '<option value="General">General</option>';
    }
}

function openAddBookModal() {
    fetchCategoriesFromDatabase();
    document.getElementById('add-book-modal').classList.remove('hidden');
}

function closeAddBookModal() {
    document.getElementById('add-book-modal').classList.add('hidden');
    document.getElementById('add-book-form').reset();
}

// ========== Add Book ==========
async function handleBookSubmit(event) {
    event.preventDefault();

    const formData = new URLSearchParams();
    formData.append('title', document.getElementById('book-title').value.trim());
    formData.append('author', document.getElementById('book-author').value.trim());
    formData.append('category', document.getElementById('book-category').value);
    formData.append('copies', document.getElementById('book-copies').value);
    formData.append('available', document.getElementById('book-available').value);

    try {
        const response = await fetch(`${BASE_URL}/api/books`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        });

        const result = await response.json();

        if (result.status === 'success') {
            closeAddBookModal();
            await fetchBooksData();
            showActionNotice("Volume Registered", result.message || "Book added successfully via Hibernate.");
        } else {
            showActionNotice("Error", result.message || "Something went wrong");
        }
    } catch (e) {
        console.error(e);
        showActionNotice("Error", "Network or server error occurred.");
    }
}

// ========== Edit Book ==========
async function editBook(id) {
    // Find the book from current list
    const book = books.find(b => b.id === id);
    if (!book) {
        showActionNotice("Error", "Book not found in current list");
        return;
    }

    // Load categories first
    await loadCategoriesForEdit();

    // Fill the form
    document.getElementById('edit-book-id').value = book.id;
    document.getElementById('edit-book-title').value = book.title || '';
    document.getElementById('edit-book-author').value = book.author || '';
    document.getElementById('edit-book-copies').value = book.quantity || book.available || 1;
    document.getElementById('edit-book-available').value = book.available || 0;

    // Set category
    const catSelect = document.getElementById('edit-book-category');
    if (catSelect) {
        // Try to select matching category
        for (let opt of catSelect.options) {
            if (opt.value === book.category) {
                opt.selected = true;
                break;
            }
        }
    }

    document.getElementById('edit-book-modal').classList.remove('hidden');
}

function closeEditBookModal() {
    document.getElementById('edit-book-modal').classList.add('hidden');
    document.getElementById('edit-book-form').reset();
}

async function loadCategoriesForEdit() {
    const categorySelect = document.getElementById('edit-book-category');
    try {
        const response = await fetch(`${BASE_URL}/api/categories`);
        if (!response.ok) throw new Error("Failed to load categories");

        const categories = await response.json();
        categorySelect.innerHTML = '<option value="" disabled>Select a category</option>';
        
        categories.forEach(cat => {
            const option = document.createElement('option');
            option.value = cat.categoryName;
            option.textContent = cat.categoryName;
            categorySelect.appendChild(option);
        });
    } catch (e) {
        console.error(e);
        categorySelect.innerHTML = '<option value="General">General</option>';
    }
}

async function handleBookUpdate(event) {
    event.preventDefault();

    const id = document.getElementById('edit-book-id').value;
    const title = document.getElementById('edit-book-title').value.trim();
    const author = document.getElementById('edit-book-author').value.trim();
    const category = document.getElementById('edit-book-category').value;
    const copies = document.getElementById('edit-book-copies').value;
    const available = document.getElementById('edit-book-available').value;

    if (!id || !title || !author || !category) {
        showActionNotice("Error", "Please fill all required fields");
        return;
    }

    const formData = new URLSearchParams();
    formData.append('action', 'update');
    formData.append('id', id);
    formData.append('title', title);
    formData.append('author', author);
    formData.append('category', category);
    formData.append('copies', copies);
    formData.append('available', available);

    try {
        const response = await fetch(`${BASE_URL}/api/books`, {
            method: 'POST',   // ← important: POST use korchi
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        });

        const result = await response.json();

        if (result.status === 'success') {
            closeEditBookModal();
            await fetchBooksData();
            showActionNotice("Volume Updated", result.message || "Book updated successfully.");
        } else {
            showActionNotice("Error", result.message || "Update failed");
        }
    } catch (e) {
        console.error(e);
        showActionNotice("Error", "Network or server error occurred.");
    }
}

// ========== Delete Book ==========
let currentDeleteBookId = null;

async function deleteBook(id) {
    currentDeleteBookId = id;
    const modalTitle = document.getElementById('modal-title');
    const modalMessage = document.getElementById('modal-message');
    const modalIcon = document.getElementById('modal-icon');
    const modalIconContainer = document.getElementById('modal-icon-container');
    const singleBox = document.getElementById('single-action-box');
    const dualBox = document.getElementById('dual-action-box');
    const modal = document.getElementById('notification-modal');

    if (!modal) return;

    modalTitle.textContent = 'Remove Volume';
    modalMessage.textContent = 'Are you sure you want to delete this volume from the sanctuary?';
    
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
        if (!currentDeleteBookId) return;

        try {
            const response = await fetch(`${BASE_URL}/api/books?id=${currentDeleteBookId}`, {
                method: 'DELETE'
            });
            const result = await response.json();
            
            if (response.ok && result.status === 'success') {
                await fetchBooksData();
                showActionNotice("Volume Removed", result.message || "Book deleted successfully via Hibernate.");
            } else {
                showActionNotice("Error", result.message || "Could not delete volume.");
            }
        } catch (e) {
            console.error(e);
            showActionNotice("Error", "Network or server error occurred.");
        }
    });
}

// ========== Notification Modal ==========
function showActionNotice(title, message, iconType = 'check') {
    const modalTitle = document.getElementById('modal-title');
    const modalMessage = document.getElementById('modal-message');
    const modalIcon = document.getElementById('modal-icon');
    const modalIconContainer = document.getElementById('modal-icon-container');
    const singleBox = document.getElementById('single-action-box');
    const dualBox = document.getElementById('dual-action-box');
    const modal = document.getElementById('notification-modal');

    if (!modal) return;

    modalTitle.innerText = title;
    modalMessage.innerText = message;

    if (iconType === 'check') {
        modalIconContainer.className = 'w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 mx-auto flex items-center justify-center text-xl';
        modalIcon.className = 'fa-solid fa-circle-check';
    } else {
        modalIconContainer.className = 'w-12 h-12 rounded-full bg-zinc-100 text-zinc-900 mx-auto flex items-center justify-center text-xl';
        modalIcon.className = 'fa-solid fa-circle-info';
    }

    dualBox.classList.add('hidden');
    singleBox.classList.remove('hidden');
    modal.classList.remove('hidden');
}

function closeModal() {
    const modal = document.getElementById('notification-modal');
    if (modal) modal.classList.add('hidden');
}

// ========== On Page Load ==========
document.addEventListener('DOMContentLoaded', () => {
    fetchBooksData();
});
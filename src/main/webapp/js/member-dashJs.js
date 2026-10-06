/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

/* 
 * Member Dashboard JS - Fixed Version
 */

// ==================== XSS SAFE ESCAPE ====================
function esc(str) {
    if (str == null) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

// ==================== MOBILE NAV ====================
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

// ==================== TAB SWITCHER ====================
function switchTab(tabId) {
    const tabs = document.querySelectorAll('.dashboard-tab');
    tabs.forEach(tab => {
        tab.classList.remove('border-zinc-900', 'text-zinc-950');
        tab.classList.add('border-transparent', 'text-zinc-400');
    });
    const targetTab = document.getElementById('tab-' + tabId);
    if (targetTab) {
        targetTab.classList.remove('border-transparent', 'text-zinc-400');
        targetTab.classList.add('border-zinc-900', 'text-zinc-950');
    }

    const contents = document.querySelectorAll('.dashboard-content');
    contents.forEach(content => content.classList.add('hidden'));
    const targetContent = document.getElementById('content-' + tabId);
    if (targetContent) {
        targetContent.classList.remove('hidden');
    }

    if (tabId === 'history') {
        renderHistory();
    }
    if (tabId === 'status') {
        loadStatusRequests();
    }
}

// ==================== ACTIVE LOANS ====================
async function loadActiveLoans() {
    try {
        const basePath = window.contextPath || '';
        const response = await fetch(`${window.location.origin}${basePath}/api/member/loans`);
        if (!response.ok) throw new Error("Failed to fetch active loans");
        
        const loans = await response.json();
        renderActiveLoans(loans);
    } catch (error) {
        console.error("Error loading active loans:", error);
        renderActiveLoans([]);
    }
}

function renderActiveLoans(loans) {
    const container = document.getElementById('active-loans-container');
    if (!container) return;

    const tabBtn = document.getElementById('tab-loans');
    if (tabBtn) tabBtn.innerText = `Active Loans (${loans ? loans.length : 0})`;

    container.innerHTML = '';

    if (!loans || loans.length === 0) {
        container.innerHTML = `
            <div class="col-span-full bg-white border border-zinc-200 rounded-2xl p-10 text-center text-zinc-400 text-xs uppercase tracking-widest shadow-sm">
                No active loans found
            </div>`;
        return;
    }

    loans.forEach(loan => {
        const isOverdue = loan.status === 'OVERDUE';
        const safeTitle = esc(loan.title);
        const card = document.createElement('div');
        card.className = "bg-white border border-zinc-200 rounded-2xl p-5 sm:p-6 shadow-sm flex flex-col justify-between space-y-4";
        card.innerHTML = `
            <div class="flex items-start justify-between">
                <div class="flex items-center space-x-3 sm:space-x-4">
                    <div class="w-14 h-18 sm:w-16 sm:h-20 bg-zinc-100 rounded-lg overflow-hidden shrink-0 border border-zinc-200">
                        <img src="${esc(loan.img)}" alt="${safeTitle}" class="w-full h-full object-cover">
                    </div>
                    <div>
                        <div class="flex items-center gap-2 flex-wrap">
                            <span class="${isOverdue ? 'bg-red-100 text-red-900' : 'bg-emerald-100 text-emerald-900'} text-[9px] font-bold uppercase tracking-widest px-2.5 py-1 rounded-full">
                                Due: ${esc(loan.dueDate)}
                            </span>
                            ${isOverdue ? '<span class="bg-rose-600 text-white text-[9px] font-bold uppercase tracking-widest px-2.5 py-1 rounded-full">Overdue</span>' : ''}
                        </div>
                        <h3 class="font-editorial text-base sm:text-lg font-medium text-zinc-900 mt-2">${safeTitle}</h3>
                        <p class="text-[11px] sm:text-xs text-zinc-500">${esc(loan.author)} • Call # ${esc(loan.callNo)}</p>
                    </div>
                </div>
            </div>
            <div class="border-t border-zinc-100 pt-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 text-xs">
                <span class="text-zinc-500">Checked out: ${esc(loan.issueDate)}</span>
                <button onclick='renewLoan(${loan.issueId}, ${JSON.stringify(String(loan.title || ""))})' 
    class="w-full sm:w-auto px-4 py-2 border border-zinc-900 rounded-full font-bold tracking-widest uppercase hover:bg-zinc-900 hover:text-white transition-all text-center">
    Renew Loan
</button>
            </div>
        `;
        container.appendChild(card);
    });
}

// ==================== BORROWING HISTORY ====================
let currentHistoryPage = 1;
const itemsPerPage = 4;
let currentHistoryView = 'table';
let cachedHistoryData = [];

async function loadBorrowingHistory() {
    try {
        const basePath = window.contextPath || '';
        const response = await fetch(`${window.location.origin}${basePath}/api/member/history`);
        if (!response.ok) throw new Error("Failed to fetch borrowing history");
        
        cachedHistoryData = await response.json();
        renderHistory();
    } catch (error) {
        console.error("Error loading borrowing history:", error);
        cachedHistoryData = [];
        renderHistory();
    }
}

function setHistoryView(view) {
    currentHistoryView = view;
    const btnTable = document.getElementById('history-btn-table');
    const btnGrid = document.getElementById('history-btn-grid');
    const containerTable = document.getElementById('history-container-table');
    const containerGrid = document.getElementById('history-container-grid');

    if (!btnTable || !btnGrid || !containerTable || !containerGrid) return;

    if (view === 'table') {
        btnTable.className = "flex-1 sm:flex-none px-5 py-2 rounded-full text-xs font-bold tracking-wider uppercase transition-all bg-zinc-900 text-white shadow-sm flex items-center justify-center space-x-2";
        btnGrid.className = "flex-1 sm:flex-none px-5 py-2 rounded-full text-xs font-bold tracking-wider uppercase transition-all text-zinc-600 hover:text-zinc-900 flex items-center justify-center space-x-2";
        containerTable.classList.remove('hidden');
        containerGrid.classList.add('hidden');
    } else {
        btnGrid.className = "flex-1 sm:flex-none px-5 py-2 rounded-full text-xs font-bold tracking-wider uppercase transition-all bg-zinc-900 text-white shadow-sm flex items-center justify-center space-x-2";
        btnTable.className = "flex-1 sm:flex-none px-5 py-2 rounded-full text-xs font-bold tracking-wider uppercase transition-all text-zinc-600 hover:text-zinc-900 flex items-center justify-center space-x-2";
        containerGrid.classList.remove('hidden');
        containerTable.classList.add('hidden');
    }
    renderHistory();
}

function changeHistoryPage(page) {
    const totalPages = Math.ceil(cachedHistoryData.length / itemsPerPage) || 1;
    if (page < 1 || page > totalPages) return;
    currentHistoryPage = page;
    renderHistory();
}

function renderHistory() {
    const totalRecords = cachedHistoryData.length;
    const totalPages = Math.ceil(totalRecords / itemsPerPage) || 1;
    
    if (currentHistoryPage > totalPages) currentHistoryPage = totalPages || 1;
    
    const startIndex = (currentHistoryPage - 1) * itemsPerPage;
    const endIndex = Math.min(startIndex + itemsPerPage, totalRecords);
    const paginatedItems = cachedHistoryData.slice(startIndex, endIndex);

    const infoElem = document.getElementById('pagination-info');
    if (infoElem) {
        infoElem.innerText = totalRecords > 0 
            ? `Showing items ${startIndex + 1}-${endIndex} of ${totalRecords} records (Page ${currentHistoryPage} of ${totalPages})`
            : `No archival records found`;
    }

    const tableBody = document.getElementById('history-table-body');
    const gridContainer = document.getElementById('history-container-grid');
    if (!tableBody || !gridContainer) return;

    tableBody.innerHTML = '';
    gridContainer.innerHTML = '';

    if (totalRecords === 0) {
        tableBody.innerHTML = `<tr><td colspan="5" class="py-10 text-center text-zinc-400 text-xs uppercase tracking-widest">No past borrowing history found</td></tr>`;
        gridContainer.innerHTML = `<div class="col-span-full bg-white border border-zinc-200 rounded-2xl p-10 text-center text-zinc-400 text-xs uppercase tracking-widest shadow-sm">No past borrowing history found</div>`;
        renderPaginationButtons(0);
        return;
    }

    paginatedItems.forEach(item => {
        const safeTitle = esc(item.title);
        const safeAuthor = esc(item.author);
        const issueDate = esc(item.issueDate);
        const returnDate = esc(item.returnDate || 'N/A');
        const fineAmount = item.fineAmount || 0.00;
        const penaltyText = fineAmount > 0 ? `$${fineAmount.toFixed(2)} (Fined)` : `$0.00 (On time)`;
        const isFined = fineAmount > 0;
        const statusText = esc(item.status || 'Returned');
        const imgUrl = item.img ? esc(item.img) : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=300&q=80';

        // Table Row
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td class="py-3 sm:py-4 font-medium text-zinc-900 flex items-center space-x-3 pr-4">
                <img src="${imgUrl}" class="w-8 h-10 object-cover rounded border border-zinc-200 shrink-0 hidden sm:block" alt="Book cover">
                <div>
                    <p class="font-medium text-zinc-900">${safeTitle}</p>
                    <span class="text-zinc-500 font-normal text-[11px]">${safeAuthor}</span>
                </div>
            </td>
            <td class="py-2 sm:py-4 pr-4">${issueDate}</td>
            <td class="py-2 sm:py-4 pr-4">${returnDate}</td>
            <td class="py-2 sm:py-4 pr-4"><span class="${isFined ? 'text-amber-700 font-bold' : 'text-zinc-600'}">${penaltyText}</span></td>
            <td class="py-2 sm:py-4"><span class="${isFined ? 'text-amber-700' : 'text-emerald-600'} font-bold uppercase tracking-wider">${statusText}</span></td>
        `;
        tableBody.appendChild(tr);

        // Grid Card
        const card = document.createElement('div');
        card.className = "bg-white border border-zinc-200 rounded-2xl p-5 shadow-sm flex flex-col justify-between space-y-4";
        card.innerHTML = `
            <div class="flex items-start space-x-4">
                <div class="w-14 h-18 bg-zinc-100 rounded-lg overflow-hidden shrink-0 border border-zinc-200">
                    <img src="${imgUrl}" class="w-full h-full object-cover" alt="Book cover">
                </div>
                <div class="space-y-1">
                    <span class="${isFined ? 'bg-amber-100 text-amber-900' : 'bg-emerald-100 text-emerald-900'} text-[9px] font-bold uppercase tracking-widest px-2.5 py-1 rounded-full">${statusText}</span>
                    <h4 class="font-editorial text-base font-medium text-zinc-900 mt-1">${safeTitle}</h4>
                    <p class="text-[11px] text-zinc-500">${safeAuthor}</p>
                </div>
            </div>
            <div class="border-t border-zinc-100 pt-3 text-[11px] space-y-1 text-zinc-600">
                <div class="flex justify-between"><span>Checked Out:</span><span class="font-medium text-zinc-800">${issueDate}</span></div>
                <div class="flex justify-between"><span>Returned On:</span><span class="font-medium text-zinc-800">${returnDate}</span></div>
                <div class="flex justify-between"><span>Late Penalty:</span><span class="font-medium ${isFined ? 'text-amber-700' : 'text-zinc-800'}">${penaltyText}</span></div>
            </div>
        `;
        gridContainer.appendChild(card);
    });

    renderPaginationButtons(totalPages);
}

function renderPaginationButtons(totalPages) {
    const paginationContainer = document.getElementById('pagination-buttons');
    if (!paginationContainer) return;
    paginationContainer.innerHTML = '';

    if (totalPages <= 1) return;

    const prevBtn = document.createElement('button');
    prevBtn.className = `px-3 py-1.5 rounded-lg text-xs font-bold border border-zinc-300 transition-all ${currentHistoryPage === 1 ? 'opacity-40 cursor-not-allowed' : 'hover:bg-zinc-900 hover:text-white'}`;
    prevBtn.innerHTML = '<i class="fa-solid fa-chevron-left text-[10px]"></i>';
    prevBtn.onclick = () => changeHistoryPage(currentHistoryPage - 1);
    paginationContainer.appendChild(prevBtn);

    for (let p = 1; p <= totalPages; p++) {
        if (p === 1 || p === totalPages || (p >= currentHistoryPage - 1 && p <= currentHistoryPage + 1)) {
            const pageBtn = document.createElement('button');
            pageBtn.className = `w-8 h-8 rounded-lg text-xs font-bold transition-all ${p === currentHistoryPage ? 'bg-zinc-900 text-white shadow-sm' : 'border border-zinc-200 text-zinc-700 hover:bg-zinc-100'}`;
            pageBtn.innerText = p;
            pageBtn.onclick = () => changeHistoryPage(p);
            paginationContainer.appendChild(pageBtn);
        } else if (p === currentHistoryPage - 2 || p === currentHistoryPage + 2) {
            const ellipsis = document.createElement('span');
            ellipsis.className = "px-1 text-zinc-400 text-xs";
            ellipsis.innerText = '…';
            paginationContainer.appendChild(ellipsis);
        }
    }

    const nextBtn = document.createElement('button');
    nextBtn.className = `px-3 py-1.5 rounded-lg text-xs font-bold border border-zinc-300 transition-all ${currentHistoryPage === totalPages ? 'opacity-40 cursor-not-allowed' : 'hover:bg-zinc-900 hover:text-white'}`;
    nextBtn.innerHTML = '<i class="fa-solid fa-chevron-right text-[10px]"></i>';
    nextBtn.onclick = () => changeHistoryPage(currentHistoryPage + 1);
    paginationContainer.appendChild(nextBtn);
}

// ==================== REQUEST STATUS ====================
let currentStatusView = 'table';

async function loadStatusRequests() {
    try {
        const basePath = window.contextPath || '';
        const response = await fetch(`${window.location.origin}${basePath}/api/member/requests`);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        if (Array.isArray(data)) {
            renderStatus(data);
        } else {
            renderStatus([]);
        }
    } catch (error) {
        console.error("Failed to load request statuses:", error);
        renderStatus([]);
    }
}

function setStatusView(view) {
    currentStatusView = view;
    const btnTable = document.getElementById('status-btn-table');
    const btnGrid = document.getElementById('status-btn-grid');
    const containerTable = document.getElementById('status-container-table');
    const containerGrid = document.getElementById('status-container-grid');

    if (!btnTable || !btnGrid || !containerTable || !containerGrid) return;

    if (view === 'table') {
        btnTable.className = "flex-1 sm:flex-none px-5 py-2 rounded-full text-xs font-bold tracking-wider uppercase transition-all bg-zinc-900 text-white shadow-sm flex items-center justify-center space-x-2";
        btnGrid.className = "flex-1 sm:flex-none px-5 py-2 rounded-full text-xs font-bold tracking-wider uppercase transition-all text-zinc-600 hover:text-zinc-900 flex items-center justify-center space-x-2";
        containerTable.classList.remove('hidden');
        containerGrid.classList.add('hidden');
    } else {
        btnGrid.className = "flex-1 sm:flex-none px-5 py-2 rounded-full text-xs font-bold tracking-wider uppercase transition-all bg-zinc-900 text-white shadow-sm flex items-center justify-center space-x-2";
        btnTable.className = "flex-1 sm:flex-none px-5 py-2 rounded-full text-xs font-bold tracking-wider uppercase transition-all text-zinc-600 hover:text-zinc-900 flex items-center justify-center space-x-2";
        containerGrid.classList.remove('hidden');
        containerTable.classList.add('hidden');
    }
}

function getStatusBadgeClass(status) {
    switch ((status || '').toUpperCase()) {
        case 'APPROVED':  return 'bg-emerald-100 text-emerald-900';
        case 'CANCELLED': 
        case 'REJECTED':  return 'bg-red-100 text-red-900';
        case 'PENDING':
        default:          return 'bg-amber-100 text-amber-900';
    }
}

function getStatusTextClass(status) {
    switch ((status || '').toUpperCase()) {
        case 'APPROVED':  return 'text-emerald-600';
        case 'CANCELLED': 
        case 'REJECTED':  return 'text-red-600';
        case 'PENDING':
        default:          return 'text-amber-700';
    }
}

function renderStatus(requests = []) {
    const tableBody = document.getElementById('status-table-body');
    const gridContainer = document.getElementById('status-container-grid');
    if (!tableBody || !gridContainer) return;

    tableBody.innerHTML = '';
    gridContainer.innerHTML = '';

    if (!requests || requests.length === 0) {
        tableBody.innerHTML = `
            <tr>
                <td colspan="3" class="py-10 text-center text-zinc-400 text-xs uppercase tracking-widest">No borrowing requests found</td>
            </tr>`;
        gridContainer.innerHTML = `
            <div class="col-span-full bg-white border border-zinc-200 rounded-2xl p-10 text-center text-zinc-400 text-xs uppercase tracking-widest shadow-sm">No borrowing requests found</div>`;
        return;
    }

    requests.forEach(item => {
        const status = (item.status || 'PENDING').toUpperCase();
        const imgHtml = item.img
            ? `<img src="${item.img}" class="w-8 h-10 object-cover rounded border border-zinc-200 shrink-0 hidden sm:block" alt="Book cover">`
            : `<div class="w-8 h-10 bg-zinc-100 rounded border border-zinc-200 shrink-0 hidden sm:flex items-center justify-center text-zinc-400 text-[10px]"><i class="fa-solid fa-book"></i></div>`;

        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td class="py-3 sm:py-4 font-medium text-zinc-900 flex items-center space-x-3 pr-4">
                ${imgHtml}
                <div>
                    <p class="font-medium text-zinc-900">${esc(item.title)}</p>
                    <span class="text-zinc-500 font-normal text-[11px]">${esc(item.author)}</span>
                </div>
            </td>
            <td class="py-2 sm:py-4 pr-4">${esc(item.requestedOn)}</td>
            <td class="py-2 sm:py-4">
                <span class="${getStatusTextClass(status)} font-bold uppercase tracking-wider">${status}</span>
            </td>
        `;
        tableBody.appendChild(tr);

        const card = document.createElement('div');
        card.className = "bg-white border border-zinc-200 rounded-2xl p-5 shadow-sm flex flex-col justify-between space-y-4";
        card.innerHTML = `
            <div class="flex items-start space-x-4">
                <div class="w-14 h-18 bg-zinc-100 rounded-lg overflow-hidden shrink-0 border border-zinc-200 flex items-center justify-center text-zinc-400">
                    ${item.img ? `<img src="${item.img}" class="w-full h-full object-cover" alt="Book cover">` : `<i class="fa-solid fa-book"></i>`}
                </div>
                <div class="space-y-1">
                    <span class="${getStatusBadgeClass(status)} text-[9px] font-bold uppercase tracking-widest px-2.5 py-1 rounded-full">${status}</span>
                    <h4 class="font-editorial text-base font-medium text-zinc-900 mt-1">${esc(item.title)}</h4>
                    <p class="text-[11px] text-zinc-500">${esc(item.author)}</p>
                </div>
            </div>
            <div class="border-t border-zinc-100 pt-3 text-[11px] space-y-1 text-zinc-600">
                <div class="flex justify-between"><span>Request Date:</span><span class="font-medium text-zinc-800">${esc(item.requestedOn)}</span></div>
            </div>
        `;
        gridContainer.appendChild(card);
    });
}

// ==================== MODAL & OTHER ====================
async function renewLoan(issueId, bookTitle) {
    if (!confirm(`Do you want to request renewal for "${bookTitle}"?`)) return;

    try {
        const basePath = window.contextPath || '';
        const formData = new URLSearchParams();
        formData.append('issueId', issueId);

        const response = await fetch(`${window.location.origin}${basePath}/api/member/renew`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData
        });

        const result = await response.json();

        if (result.status === 'success') {
            showModal("Renewal Request Submitted", result.message);
            loadActiveLoans();
            // Optional: status tab e o dekhate chaile
            // loadStatusRequests();
        } else {
            showModal("Renewal Failed", result.message || "Something went wrong.");
        }
    } catch (error) {
        console.error("Renew error:", error);
        showModal("Error", "Could not submit renewal request.");
    }
}

function returnDigitalCopy(bookTitle) {
    showModal("Digital License Revoked & Returned", `The digital copy license for "${bookTitle}" has been successfully released back to the library server. Access token terminated.`);
}

function openCheckoutModal() {
    showModal("New Borrowing Request", "Please navigate to the Public Catalog on the main portal to submit a new volume checkout request.");
}

function showModal(title, message) {
    const mTitle = document.getElementById('modal-title');
    const mMsg = document.getElementById('modal-message');
    const mModal = document.getElementById('notification-modal');
    if (mTitle) mTitle.innerText = title;
    if (mMsg) mMsg.innerText = message;
    if (mModal) mModal.classList.remove('hidden');
}

function closeModal() {
    const mModal = document.getElementById('notification-modal');
    if (mModal) mModal.classList.add('hidden');
}

// ==================== PAGE LOAD ====================
document.addEventListener("DOMContentLoaded", () => {
    loadActiveLoans();
    loadBorrowingHistory();
});
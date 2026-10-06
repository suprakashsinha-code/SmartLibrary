let currentTab = 'requests';
let currentViewMode = 'table';
let currentPage = 1;
const itemsPerPage = 10;
let currentSelectedRecordId = null;
let currentSelectedNumericId = null;

let databaseRecords = {
    requests: [],
    issued: [],
    overdue: [],
    history: []
};

const BASE_PATH = window.contextPath || '';

// ========== Load Real Data from Backend ==========
async function loadCirculationData() {
    try {
        const response = await fetch(`${BASE_PATH}/admin/get-circulation-data`);
        if (!response.ok) throw new Error("Failed to load data");

        const data = await response.json();
        databaseRecords.requests = data.requests || [];
        databaseRecords.issued = data.issued || [];
        databaseRecords.overdue = data.overdue || [];
        databaseRecords.history = data.history || [];

        updateCounters();
        renderActiveView();
    } catch (err) {
        console.error("Error loading circulation data:", err);
        // FIXED: showNotification now works (no more null element crash)
        showNotification("Error", "Could not load data from server.");
    }
}

// ========== Mobile Menu ==========
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

function filterByTab(tabName) {
    currentTab = tabName;
    currentPage = 1;

    ['requests', 'issued', 'overdue', 'history'].forEach(t => {
        const btn = document.getElementById(`tab-btn-${t}`);
        if (btn) {
            btn.className = t === tabName
                ? 'flex-1 sm:flex-none px-4 py-2 bg-white text-zinc-900 text-xs font-bold uppercase rounded-full shadow-sm transition-all whitespace-nowrap'
                : 'flex-1 sm:flex-none px-4 py-2 text-zinc-600 hover:text-zinc-900 text-xs font-bold uppercase rounded-full transition-all whitespace-nowrap';
        }
    });

    const headings = {
        requests: 'Book Borrow Requests',
        issued: 'Currently Issued Books',
        overdue: 'Overdue Circulation Records',
        history: 'Circulation Archive & History'
    };
    document.getElementById('section-heading').innerText = headings[tabName];

    renderTableHeaders();
    renderActiveView();
}

function switchViewMode(mode) {
    currentViewMode = mode;
    const btnTable = document.getElementById('view-mode-btn-table');
    const btnGrid = document.getElementById('view-mode-btn-grid');
    const tableContainer = document.getElementById('issues-table-container');
    const gridContainer = document.getElementById('issues-grid-container');

    if (mode === 'table') {
        btnTable.className = 'px-4 py-2 bg-white text-zinc-900 text-xs font-bold uppercase rounded-full shadow-sm transition-all flex items-center space-x-1.5';
        btnGrid.className = 'px-4 py-2 text-zinc-600 hover:text-zinc-900 text-xs font-bold uppercase rounded-full transition-all flex items-center space-x-1.5';
        tableContainer.classList.remove('hidden');
        gridContainer.classList.add('hidden');
    } else {
        btnGrid.className = 'px-4 py-2 bg-white text-zinc-900 text-xs font-bold uppercase rounded-full shadow-sm transition-all flex items-center space-x-1.5';
        btnTable.className = 'px-4 py-2 text-zinc-600 hover:text-zinc-900 text-xs font-bold uppercase rounded-full transition-all flex items-center space-x-1.5';
        gridContainer.classList.remove('hidden');
        tableContainer.classList.add('hidden');
    }
    renderActiveView();
}

function renderTableHeaders() {
    const headerRow = document.getElementById('table-header-row');
    if (currentTab === 'requests') {
        headerRow.innerHTML = `
            <th class="p-4 sm:p-6">Request ID</th>
            <th class="p-4 sm:p-6">Book Title</th>
            <th class="p-4 sm:p-6">Member Name</th>
            <th class="p-4 sm:p-6">Type</th>
            <th class="p-4 sm:p-6">Requested</th>
            <th class="p-4 sm:p-6">Status</th>
            <th class="p-4 sm:p-6 text-right">Action</th>
        `;
    } else if (currentTab === 'issued' || currentTab === 'overdue') {
        headerRow.innerHTML = `
            <th class="p-4 sm:p-6">Issue ID</th>
            <th class="p-4 sm:p-6">Book Title</th>
            <th class="p-4 sm:p-6">Member Name</th>
            <th class="p-4 sm:p-6">Issue Date</th>
            <th class="p-4 sm:p-6">Due Date</th>
            <th class="p-4 sm:p-6">Condition</th>
            <th class="p-4 sm:p-6 text-right">Action</th>
        `;
    } else {
        headerRow.innerHTML = `
            <th class="p-4 sm:p-6">History ID</th>
            <th class="p-4 sm:p-6">Book Title</th>
            <th class="p-4 sm:p-6">Member Name</th>
            <th class="p-4 sm:p-6">Type</th>
            <th class="p-4 sm:p-6">Returned Date</th>
            <th class="p-4 sm:p-6">Status</th>
            <th class="p-4 sm:p-6 text-right">Action</th>
        `;
    }
}

function renderActiveView() {
    const data = databaseRecords[currentTab] || [];
    const searchTerm = (document.getElementById('issue-search-input')?.value || '').toLowerCase();

    const filteredData = data.filter(item =>
        (item.id || '').toLowerCase().includes(searchTerm) ||
        (item.book || '').toLowerCase().includes(searchTerm) ||
        (item.member || '').toLowerCase().includes(searchTerm)
    );

    const totalPages = Math.ceil(filteredData.length / itemsPerPage) || 1;
    if (currentPage > totalPages) currentPage = totalPages;

    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedData = filteredData.slice(startIndex, startIndex + itemsPerPage);

    if (currentViewMode === 'table') {
        renderTableBody(paginatedData);
    } else {
        renderGridView(paginatedData);
    }

    renderPaginationControls(filteredData.length, totalPages);
}

function renderTableBody(data) {
    const tbody = document.getElementById('issues-table-body');
    if (data.length === 0) {
        tbody.innerHTML = `<tr><td colspan="7" class="p-8 text-center text-zinc-400 italic">No records found in this category.</td></tr>`;
        return;
    }

    let html = '';
    data.forEach(item => {
        if (currentTab === 'requests') {
            html += `
                <tr class="hover:bg-zinc-50/70 transition-colors cursor-pointer" onclick="openRequestDetailsModal('${item.id}', ${item.requestId})">
                    <td class="p-4 sm:p-6 font-mono text-xs font-bold text-zinc-900">${item.id}</td>
                    <td class="p-4 sm:p-6 font-medium text-zinc-900">${item.book}</td>
                    <td class="p-4 sm:p-6 text-zinc-700">${item.member}</td>
                    <td class="p-4 sm:p-6"><span class="px-2 py-0.5 bg-zinc-100 text-zinc-800 text-[10px] font-bold uppercase rounded-full">${item.type}</span></td>
                    <td class="p-4 sm:p-6 text-xs text-zinc-600">${item.requested}</td>
                    <td class="p-4 sm:p-6"><span class="px-3 py-1 bg-amber-50 text-amber-800 text-[10px] font-bold uppercase rounded-full border border-amber-200">${item.status}</span></td>
                    <td class="p-4 sm:p-6 text-right" onclick="event.stopPropagation()">
                        <button onclick="openRequestDetailsModal('${item.id}', ${item.requestId})" class="px-5 py-2.5 bg-zinc-900 text-white rounded-full text-xs font-bold uppercase tracking-widest hover:bg-zinc-800 transition-all shadow-sm whitespace-nowrap">View / Edit</button>
                    </td>
                </tr>
            `;
        } else if (currentTab === 'issued' || currentTab === 'overdue') {
            const statusClass = currentTab === 'overdue' ? 'bg-rose-50 text-rose-800 border-rose-200' : 'bg-emerald-50 text-emerald-800 border-emerald-200';
            html += `
                <tr class="hover:bg-zinc-50/70 transition-colors">
                    <td class="p-4 sm:p-6 font-mono text-xs font-bold text-zinc-900">${item.id}</td>
                    <td class="p-4 sm:p-6 font-medium text-zinc-900">${item.book}</td>
                    <td class="p-4 sm:p-6 text-zinc-700">${item.member}</td>
                    <td class="p-4 sm:p-6 text-xs text-zinc-600">${item.issueDate}</td>
                    <td class="p-4 sm:p-6 text-xs font-semibold text-zinc-900">${item.dueDate}</td>
                    <td class="p-4 sm:p-6"><span class="px-3 py-1 ${statusClass} text-[10px] font-bold uppercase rounded-full border">${item.status}</span></td>
                    <td class="p-4 sm:p-6 text-right">
                        <button onclick="returnBookRecord(${item.issueId})" class="px-4 py-2.5 bg-emerald-600 text-white rounded-full text-xs font-bold uppercase tracking-widest hover:bg-emerald-700 transition-all shadow-sm whitespace-nowrap">Mark Returned</button>
                    </td>
                </tr>
            `;
        } else {
            html += `
                <tr class="hover:bg-zinc-50/70 transition-colors">
                    <td class="p-4 sm:p-6 font-mono text-xs font-bold text-zinc-900">${item.id}</td>
                    <td class="p-4 sm:p-6 font-medium text-zinc-900">${item.book}</td>
                    <td class="p-4 sm:p-6 text-zinc-700">${item.member}</td>
                    <td class="p-4 sm:p-6"><span class="px-2 py-0.5 bg-zinc-100 text-zinc-800 text-[10px] font-bold uppercase rounded-full">${item.type}</span></td>
                    <td class="p-4 sm:p-6 text-xs text-zinc-600">${item.returnedDate || item.issueDate}</td>
                    <td class="p-4 sm:p-6"><span class="px-3 py-1 bg-zinc-100 text-zinc-800 text-[10px] font-bold uppercase rounded-full">${item.status}</span></td>
                    <td class="p-4 sm:p-6 text-right">
                        <span class="text-xs text-zinc-400 font-medium">Archived</span>
                    </td>
                </tr>
            `;
        }
    });
    tbody.innerHTML = html;
}

function renderGridView(data) {
    const gridContainer = document.getElementById('issues-grid-container');
    if (data.length === 0) {
        gridContainer.innerHTML = `<div class="col-span-full p-8 text-center text-zinc-400 italic bg-white rounded-3xl border border-zinc-200">No records found.</div>`;
        return;
    }

    let html = '';
    data.forEach(item => {
        const isReq = currentTab === 'requests';
        const isOverdue = currentTab === 'overdue';
        const statusBg = isReq ? 'bg-amber-50 text-amber-800 border-amber-200' : (isOverdue ? 'bg-rose-50 text-rose-800 border-rose-200' : 'bg-emerald-50 text-emerald-800 border-emerald-200');

        // FIXED: only show a Return button when this record actually has an issueId
        // (history records are archived and have no issueId)
        let actionButton;
        if (isReq) {
            actionButton = `
                <button onclick="openRequestDetailsModal('${item.id}', ${item.requestId})" class="px-5 py-2.5 bg-zinc-900 text-white rounded-full text-xs font-bold uppercase tracking-widest hover:bg-zinc-800 transition-all shadow-sm">
                    View / Edit
                </button>`;
        } else if (item.issueId) {
            actionButton = `
                <button onclick="returnBookRecord(${item.issueId})" class="text-emerald-600 hover:text-emerald-800 text-xs font-bold uppercase">
                    <i class="fa-solid fa-circle-check mr-1"></i> Return
                </button>`;
        } else {
            actionButton = `<span class="text-xs text-zinc-400 font-medium">Archived</span>`;
        }

        html += `
            <div class="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col justify-between space-y-4 hover:shadow-md transition-all">
                <div class="space-y-3">
                    <div class="flex items-center justify-between">
                        <span class="font-mono text-xs font-bold text-zinc-400">${item.id}</span>
                        <span class="px-3 py-1 ${statusBg} text-[10px] font-bold uppercase rounded-full border">${item.status || 'Active'}</span>
                    </div>
                    <div>
                        <span class="px-2.5 py-0.5 bg-zinc-100 text-zinc-700 text-[9px] font-bold uppercase rounded-full">${item.type || 'Physical'}</span>
                        <h3 class="font-editorial text-xl font-medium text-zinc-900 mt-1">${item.book}</h3>
                    </div>
                    <div class="bg-zinc-50 p-3 rounded-2xl border border-zinc-100 space-y-1 text-xs">
                        <div>Borrower: <strong class="text-zinc-900">${item.member}</strong></div>
                        <div>Date: <strong class="text-zinc-700">${item.requested || item.issueDate || item.returnedDate}</strong></div>
                    </div>
                </div>
                <div class="pt-4 border-t border-zinc-100 flex items-center justify-between">
                    ${actionButton}
                </div>
            </div>
        `;
    });
    gridContainer.innerHTML = html;
}

function renderPaginationControls(totalItems, totalPages) {
    const paginationInfo = document.getElementById('pagination-info');
    const buttonsContainer = document.getElementById('pagination-buttons');

    if (totalItems === 0) {
        paginationInfo.innerText = `Showing 0 entries`;
        buttonsContainer.innerHTML = '';
        return;
    }

    const startRecord = (currentPage - 1) * itemsPerPage + 1;
    const endRecord = Math.min(currentPage * itemsPerPage, totalItems);
    paginationInfo.innerText = `Showing ${startRecord} to ${endRecord} of ${totalItems} entries`;

    let buttonsHtml = '';
    buttonsHtml += `<button onclick="changePage(${currentPage - 1})" ${currentPage === 1 ? 'disabled class="px-3 py-1.5 text-xs font-bold uppercase rounded-xl bg-zinc-100 text-zinc-400 cursor-not-allowed"' : 'class="px-3 py-1.5 text-xs font-bold uppercase rounded-xl bg-zinc-100 text-zinc-700 hover:bg-zinc-200 transition-all"'}>Prev</button>`;

    for (let i = 1; i <= totalPages; i++) {
        if (i === currentPage) {
            buttonsHtml += `<button class="px-3.5 py-1.5 text-xs font-bold uppercase rounded-xl bg-zinc-900 text-white shadow-sm">${i}</button>`;
        } else {
            buttonsHtml += `<button onclick="changePage(${i})" class="px-3.5 py-1.5 text-xs font-bold uppercase rounded-xl bg-zinc-100 text-zinc-700 hover:bg-zinc-200 transition-all">${i}</button>`;
        }
    }

    buttonsHtml += `<button onclick="changePage(${currentPage + 1})" ${currentPage === totalPages ? 'disabled class="px-3 py-1.5 text-xs font-bold uppercase rounded-xl bg-zinc-100 text-zinc-400 cursor-not-allowed"' : 'class="px-3 py-1.5 text-xs font-bold uppercase rounded-xl bg-zinc-100 text-zinc-700 hover:bg-zinc-200 transition-all"'}>Next</button>`;

    buttonsContainer.innerHTML = buttonsHtml;
}

function changePage(page) {
    currentPage = page;
    renderActiveView();
}

function openRequestDetailsModal(recordId, numericId) {
    currentSelectedRecordId = recordId;
    currentSelectedNumericId = numericId;

    const record = databaseRecords.requests.find(r => r.id === recordId);
    if (!record) return;

    document.getElementById('modal-req-id').innerText = record.id;
    document.getElementById('modal-member-name').innerText = record.member;
    document.getElementById('modal-member-id').innerText = record.memberId;
    document.getElementById('modal-req-type').innerText = record.type;
    document.getElementById('modal-book-title').innerText = record.book;
    document.getElementById('modal-book-isbn').innerText = record.isbn ? `ISBN: ${record.isbn}` : '';
    document.getElementById('modal-req-date').innerText = record.requested;
    document.getElementById('modal-req-status').innerText = record.status;
    document.getElementById('modal-admin-remark').value = '';

    const issueBtn = document.getElementById('btn-issue-action');
    issueBtn.style.display = 'block';
    issueBtn.innerText = record.type === 'ONLINE' ? '[ Approve Access ]' : '[ Issue Book ]';

    document.getElementById('request-details-modal').classList.remove('hidden');
}

function closeRequestModal() {
    document.getElementById('request-details-modal').classList.add('hidden');
}

// ========== Real Backend Action with Instant UI Refresh ==========
async function handleRequestAction(actionType) {
    const remark = document.getElementById('modal-admin-remark').value;

    let backendAction = 'APPROVE_ONLY';
    if (actionType === 'cancel') backendAction = 'CANCELLED';
    if (actionType === 'issue') backendAction = 'ISSUE';

    try {
        const response = await fetch(`${BASE_PATH}/admin/process-request`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `requestId=${currentSelectedNumericId}&action=${backendAction}&adminRemark=${encodeURIComponent(remark)}`
        });

        const data = await response.json();
        closeRequestModal();

        if (data.status === 'success') {
            // FIXED: showNotification no longer crashes on null elements,
            // and it is wrapped in try/catch so a toast failure can never
            // block the data refresh again.
            try {
                showNotification("Success", data.message || "Request processed successfully.");
            } catch (e) {
                console.error("Toast error:", e);
            }

            // Instant refresh from server — no page reload needed
            await loadCirculationData();

            if (backendAction === 'ISSUE') {
                filterByTab('issued');
            } else {
                filterByTab('requests');
            }
        } else {
            showNotification("Error", data.message || "Operation failed.");
        }
    } catch (error) {
        closeRequestModal();
        showNotification("Connection Error", "Unable to communicate with server.");
        console.error(error);
    }
}

let currentReturnIssueId = null;

// ========== Return Book with Custom Confirmation Modal ==========
async function returnBookRecord(issueId) {
    currentReturnIssueId = issueId;
    const modalTitle = document.getElementById('modal-title');
    const modalMessage = document.getElementById('modal-message');
    const modalIcon = document.getElementById('modal-icon');
    const modalIconContainer = document.getElementById('modal-icon-container');
    const singleBox = document.getElementById('single-action-box');
    const dualBox = document.getElementById('dual-action-box');
    const modal = document.getElementById('notification-modal');

    if (!modal) return;

    modalTitle.textContent = 'Mark as Returned';
    modalMessage.textContent = 'Are you sure you want to mark this book as returned?';

    modalIconContainer.className = 'w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 mx-auto flex items-center justify-center text-xl';
    modalIcon.className = 'fa-solid fa-circle-check';

    // FIXED: toggle hidden/flex properly so the confirmation buttons actually appear
    singleBox.classList.add('hidden');
    dualBox.classList.remove('hidden');
    dualBox.classList.add('flex');
    modal.classList.remove('hidden');

    const confirmBtn = document.getElementById('modal-confirm-btn');
    const newConfirmBtn = confirmBtn.cloneNode(true);
    confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);

    document.getElementById('modal-confirm-btn').addEventListener('click', async () => {
        closeModal();
        if (!currentReturnIssueId) return;

        try {
            const response = await fetch(`${BASE_PATH}/admin/return-book`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `issueId=${currentReturnIssueId}`
            });

            const data = await response.json();

            if (data.status === 'success') {
                showActionNotice("Success", data.message || "Book returned successfully.", 'check');
                await loadCirculationData();   // instant refresh, no page reload
            } else {
                showActionNotice("Error", data.message || "Failed to return book.", 'info');
            }
        } catch (error) {
            showActionNotice("Connection Error", "Unable to communicate with server.", 'info');
            console.error(error);
        }
    });
}

// ========== Notification Helper matching Dashboard style ==========
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

    // FIXED: hide dual box correctly (remove flex as well)
    dualBox.classList.add('hidden');
    dualBox.classList.remove('flex');
    singleBox.classList.remove('hidden');
    modal.classList.remove('hidden');
}

function closeModal() {
    const modal = document.getElementById('notification-modal');
    if (modal) modal.classList.add('hidden');
}

function updateCounters() {
    document.getElementById('stat-requests-count').innerText = databaseRecords.requests.length;
    document.getElementById('stat-issued-count').innerText = databaseRecords.issued.length;
    document.getElementById('stat-overdue-count').innerText = databaseRecords.overdue.length;
    document.getElementById('stat-history-count').innerText = databaseRecords.history.length;

    document.getElementById('tab-btn-requests').innerText = `Requests (${databaseRecords.requests.length})`;
    document.getElementById('tab-btn-issued').innerText = `Issued (${databaseRecords.issued.length})`;
    document.getElementById('tab-btn-overdue').innerText = `Overdue (${databaseRecords.overdue.length})`;
    document.getElementById('tab-btn-history').innerText = `History (${databaseRecords.history.length})`;
}

// ========== FIXED: these IDs did not exist in the JSP, which crashed the
// success handler BEFORE loadCirculationData() could run. Now they delegate
// to the real notification modal. ==========
function showNotification(title, message) {
    showActionNotice(title, message, 'check');
}

function closeNotificationModal() {
    closeModal();
}

const searchInput = document.getElementById('issue-search-input');
if (searchInput) {
    searchInput.addEventListener('input', () => {
        currentPage = 1;
        renderActiveView();
    });
}

window.addEventListener('DOMContentLoaded', () => {
    loadCirculationData();
    filterByTab('requests');
});
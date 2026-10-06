/* 
 * member-detailsJs.js
 * Dynamic Member Dossier - Aurelia Library
 */

let historyData = [];
let currentPage = 1;
const itemsPerPage = 2;

// Date format helper (2026-09-01 → Sep 01, 2026)
function formatDate(dateStr) {
    if (!dateStr || dateStr === "N/A") return "N/A";
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-US', {
        month: 'short',
        day: '2-digit',
        year: 'numeric'
    });
}

// Status badge class for Active / Inactive
function getStatusBadge(status) {
    if (status === "ACTIVE") {
        return {
            text: "Active Member",
            class: "bg-emerald-600 text-white"
        };
    } else {
        return {
            text: "Inactive Member",
            class: "bg-rose-600 text-white"
        };
    }
}

// Due date status for active books
function getDueStatus(dueDateStr, status) {
    if (status === "OVERDUE") {
        return {
            text: "Overdue",
            class: "bg-rose-50 text-rose-800 border-rose-200"
        };
    }
    const due = new Date(dueDateStr);
    const today = new Date();
    const diffDays = Math.ceil((due - today) / (1000 * 60 * 60 * 24));

    if (diffDays < 0) {
        return {
            text: "Overdue",
            class: "bg-rose-50 text-rose-800 border-rose-200"
        };
    } else if (diffDays <= 5) {
        return {
            text: `Due in ${diffDays} Days`,
            class: "bg-amber-50 text-amber-800 border-amber-200"
        };
    } else {
        return {
            text: "On Time",
            class: "bg-emerald-50 text-emerald-800 border-emerald-200"
        };
    }
}

// ========== Render Active Books ==========
function renderActiveBooks(activeBooks) {
    const grid = document.getElementById('present-books-grid');
    const countBadge = document.getElementById('present-count-badge');

    if (!activeBooks || activeBooks.length === 0) {
        grid.innerHTML = `
            <div class="col-span-full text-center py-12 text-zinc-500">
                <i class="fa-solid fa-book-open text-3xl mb-3 opacity-40"></i>
                <p class="text-sm">No books currently checked out.</p>
            </div>
        `;
        countBadge.textContent = "0 Active";
        return;
    }

    countBadge.textContent = `${activeBooks.length} Active`;

    grid.innerHTML = activeBooks.map(book => {
        const dueInfo = getDueStatus(book.dueDate, book.status);
        return `
            <div class="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col justify-between space-y-4">
                <div class="flex items-start justify-between">
                    <div class="space-y-1">
                        <span class="px-2.5 py-0.5 ${dueInfo.class} text-[10px] font-bold uppercase rounded-full border">${dueInfo.text}</span>
                        <h4 class="font-editorial text-xl font-medium text-zinc-900">${book.title}</h4>
                        <p class="text-xs text-zinc-500 uppercase">Author: ${book.author}</p>
                    </div>
                    <span class="text-zinc-400 text-xs font-mono">ISBN: ${book.isbn || 'N/A'}</span>
                </div>
                <div class="pt-4 border-t border-zinc-100 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 text-xs text-zinc-600">
                    <span>Checked Out: <strong class="text-zinc-900">${formatDate(book.issueDate)}</strong></span>
                    <span>Due Date: <strong class="${book.status === 'OVERDUE' ? 'text-rose-600' : 'text-zinc-900'}">${formatDate(book.dueDate)}</strong></span>
                </div>
            </div>
        `;
    }).join('');
}

// ========== Render History Table (with pagination) ==========
function renderHistoryTable() {
    const tbody = document.getElementById('history-table-body');
    const totalPages = Math.ceil(historyData.length / itemsPerPage) || 1;

    if (currentPage > totalPages) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;

    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const currentItems = historyData.slice(startIndex, endIndex);

    tbody.innerHTML = '';

    if (currentItems.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="4" class="p-8 text-center text-zinc-500 text-sm">
                    No borrowing history found.
                </td>
            </tr>
        `;
    } else {
        currentItems.forEach(item => {
            const tr = document.createElement('tr');
            tr.className = "hover:bg-zinc-50/50 transition-colors";
            tr.innerHTML = `
                <td class="p-4 sm:p-6">
                    <p class="font-medium text-zinc-900">${item.title}</p>
                    <span class="text-xs text-zinc-500">${item.author}</span>
                </td>
                <td class="p-4 sm:p-6 text-xs text-zinc-600">${formatDate(item.borrowed)}</td>
                <td class="p-4 sm:p-6 text-xs text-zinc-600">${formatDate(item.returned)}</td>
                <td class="p-4 sm:p-6">
                    <span class="px-2.5 py-1 ${item.badgeClass} text-[10px] font-bold uppercase rounded-full border">${item.status}</span>
                </td>
            `;
            tbody.appendChild(tr);
        });
    }

    const showingEnd = Math.min(endIndex, historyData.length);
    document.getElementById('history-total-info').textContent =
        historyData.length === 0
            ? "No records"
            : `Showing Records ${startIndex + 1}-${showingEnd} of ${historyData.length}`;

    document.getElementById('current-page-num').textContent = currentPage;
    document.getElementById('total-pages-num').textContent = totalPages;

    renderPaginationControls(totalPages);
}

// ========== Pagination Buttons ==========
function renderPaginationControls(totalPages) {
    const container = document.getElementById('pagination-buttons');
    container.innerHTML = '';

    // PREV
    const prevBtn = document.createElement('button');
    prevBtn.className = `px-4 py-2 border rounded-full text-xs font-bold uppercase tracking-widest transition-all ${
        currentPage === 1
            ? 'border-zinc-200 text-zinc-300 cursor-not-allowed'
            : 'border-zinc-300 text-zinc-700 hover:bg-zinc-900 hover:text-white'
    }`;
    prevBtn.innerHTML = `<i class="fa-solid fa-chevron-left mr-1"></i> Prev`;
    prevBtn.disabled = currentPage === 1;
    prevBtn.onclick = () => {
        if (currentPage > 1) {
            currentPage--;
            renderHistoryTable();
        }
    };
    container.appendChild(prevBtn);

    // Page numbers
    for (let i = 1; i <= totalPages; i++) {
        const pageBtn = document.createElement('button');
        pageBtn.className = i === currentPage
            ? "w-9 h-9 flex items-center justify-center rounded-full bg-zinc-900 text-white text-xs font-bold shadow-sm"
            : "w-9 h-9 flex items-center justify-center rounded-full border border-zinc-300 text-zinc-700 text-xs font-bold hover:bg-zinc-100 transition-all";
        pageBtn.textContent = i;
        pageBtn.onclick = () => {
            currentPage = i;
            renderHistoryTable();
        };
        container.appendChild(pageBtn);
    }

    // NEXT
    const nextBtn = document.createElement('button');
    nextBtn.className = `px-4 py-2 border rounded-full text-xs font-bold uppercase tracking-widest transition-all ${
        currentPage === totalPages
            ? 'border-zinc-200 text-zinc-300 cursor-not-allowed'
            : 'border-zinc-300 text-zinc-700 hover:bg-zinc-900 hover:text-white'
    }`;
    nextBtn.innerHTML = `Next <i class="fa-solid fa-chevron-right ml-1"></i>`;
    nextBtn.disabled = currentPage === totalPages;
    nextBtn.onclick = () => {
        if (currentPage < totalPages) {
            currentPage++;
            renderHistoryTable();
        }
    };
    container.appendChild(nextBtn);
}

// ========== Main Load ==========
document.addEventListener('DOMContentLoaded', () => {
    const urlParams = new URLSearchParams(window.location.search);
    const memberId = urlParams.get('id');

    if (!memberId) {
        document.getElementById('member-dossier-container').innerHTML = `
            <div class="text-center py-20">
                <p class="text-rose-600 font-medium text-lg">Member ID missing in URL!</p>
                <p class="text-sm text-zinc-500 mt-2">Please open like: member-details.jsp?id=1</p>
            </div>
        `;
        return;
    }

    // Loading state
    document.getElementById('present-books-grid').innerHTML = `
        <div class="col-span-full text-center py-10 text-zinc-400">
            <i class="fa-solid fa-spinner fa-spin text-2xl mb-2"></i>
            <p class="text-sm">Loading member data...</p>
        </div>
    `;

    fetch(`${window.contextPath}/api/member-details?id=${memberId}`)
        .then(res => res.json())
        .then(data => {
            if (data.error) {
                document.getElementById('member-dossier-container').innerHTML = `
                    <div class="text-center py-20">
                        <p class="text-rose-600 font-medium text-lg">${data.error}</p>
                    </div>
                `;
                return;
            }

            // ===== Profile Fill =====
            document.getElementById('member-id-tag').textContent = "ID: " + data.memberId;
            document.getElementById('member-name').textContent = data.name;
            document.getElementById('member-email').textContent = data.email;
            document.getElementById('member-phone').textContent = data.phone;
            document.getElementById('member-tier').textContent = data.membershipType;
            document.getElementById('member-joined').textContent = formatDate(data.membershipDate);

            // Status badge
            const statusInfo = getStatusBadge(data.status);
            const statusBadge = document.getElementById('member-status-badge');
            statusBadge.textContent = statusInfo.text;
            statusBadge.className = `absolute -bottom-2 -right-2 px-3 py-1 ${statusInfo.class} text-[10px] font-bold uppercase rounded-full tracking-wider shadow-sm`;

            // ===== Active Books =====
            renderActiveBooks(data.activeBooks || []);

            // ===== History =====
            historyData = data.historyBooks || [];
            currentPage = 1;
            renderHistoryTable();

            console.log("Member dossier loaded successfully for ID:", data.memberId);
        })
        .catch(err => {
            console.error(err);
            document.getElementById('member-dossier-container').innerHTML = `
                <div class="text-center py-20">
                    <p class="text-rose-600 font-medium text-lg">Failed to load data</p>
                    <p class="text-sm text-zinc-500 mt-2">${err.message}</p>
                </div>
            `;
        });
});
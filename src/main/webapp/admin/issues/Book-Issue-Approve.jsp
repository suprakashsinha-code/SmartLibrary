<%-- 
    Document   : Book-Issue-Approve
    Created on : 24 Sept 2026, 9:19:09 pm
    Author     : Suprakash
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Prevent browser caching
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies

    // Check if user is logged in
    if (session.getAttribute("userName") == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AURELIA | Book Issue & Circulation Management</title>
        <!-- Tailwind CSS CDN -->
        <script src="https://cdn.tailwindcss.com"></script>
        <!-- Google Fonts: Playfair Display for editorial headings & Inter for body -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
        <!-- FontAwesome for icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/adminNavCss.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Book-Issue-ApprovedCss.css">
        <script>
    window.contextPath = '${pageContext.request.contextPath}';
</script>
    </head>
    <body class="selection:bg-zinc-900 selection:text-zinc-100 overflow-x-hidden min-h-screen flex flex-col justify-between">

        <!-- Sticky Header Navigation matching Aurelia Theme -->
        <jsp:include page="/include/adminNav.jsp" />

        <!-- Main Content Area -->
        <main class="flex-grow max-w-7xl w-full mx-auto px-4 sm:px-6 py-6 sm:py-10 md:py-14 space-y-6 sm:space-y-8">

            <!-- Top Stats Counter Bar -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-3 sm:gap-4 bg-white border border-zinc-200 rounded-3xl p-4 sm:p-6 shadow-sm">
                <div class="p-3 sm:p-4 rounded-2xl bg-zinc-50 border border-zinc-100 text-center cursor-pointer hover:bg-zinc-100/80 transition-all active:scale-95" onclick="filterByTab('requests')">
                    <p class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Requests</p>
                    <p class="font-editorial text-2xl sm:text-3xl font-bold text-zinc-900 mt-1" id="stat-requests-count">0</p>
                </div>
                <div class="p-3 sm:p-4 rounded-2xl bg-zinc-50 border border-zinc-100 text-center cursor-pointer hover:bg-zinc-100/80 transition-all active:scale-95" onclick="filterByTab('issued')">
                    <p class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Issued</p>
                    <p class="font-editorial text-2xl sm:text-3xl font-bold text-zinc-900 mt-1" id="stat-issued-count">0</p>
                </div>
                <div class="p-3 sm:p-4 rounded-2xl bg-zinc-50 border border-zinc-100 text-center cursor-pointer hover:bg-zinc-100/80 transition-all active:scale-95" onclick="filterByTab('overdue')">
                    <p class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Overdue</p>
                    <p class="font-editorial text-2xl sm:text-3xl font-bold text-rose-600 mt-1" id="stat-overdue-count">0</p>
                </div>
                <div class="p-3 sm:p-4 rounded-2xl bg-zinc-50 border border-zinc-100 text-center cursor-pointer hover:bg-zinc-100/80 transition-all active:scale-95" onclick="filterByTab('history')">
                    <p class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">History</p>
                    <p class="font-editorial text-2xl sm:text-3xl font-bold text-zinc-900 mt-1" id="stat-history-count">0</p>
                </div>
            </div>

            <!-- Header & Action Toolbar with Table/Grid and Tabs -->
            <div class="flex flex-col md:flex-row md:items-end justify-between gap-4 border-b border-zinc-200 pb-6">
                <div>
                    <p class="text-xs font-bold tracking-widest uppercase text-zinc-500">Database Circulation Logs</p>
                    <h1 id="section-heading" class="font-editorial text-2xl sm:text-3xl md:text-4xl font-normal text-zinc-900 uppercase">Book Borrow Requests</h1>
                </div>
                <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
                    <!-- Tab Switching Navigation Buttons -->
                    <div class="bg-zinc-200/70 p-1 rounded-full flex items-center space-x-1 overflow-x-auto w-full sm:w-auto scrollbar-none">
                        <button onclick="filterByTab('requests')" id="tab-btn-requests" class="flex-1 sm:flex-none px-4 py-2 bg-white text-zinc-900 text-xs font-bold uppercase rounded-full shadow-sm transition-all whitespace-nowrap">Requests (0)</button>
                        <button onclick="filterByTab('issued')" id="tab-btn-issued" class="flex-1 sm:flex-none px-4 py-2 text-zinc-600 hover:text-zinc-900 text-xs font-bold uppercase rounded-full transition-all whitespace-nowrap">Issued (0)</button>
                        <button onclick="filterByTab('overdue')" id="tab-btn-overdue" class="flex-1 sm:flex-none px-4 py-2 text-zinc-600 hover:text-zinc-900 text-xs font-bold uppercase rounded-full transition-all whitespace-nowrap">Overdue (0)</button>
                        <button onclick="filterByTab('history')" id="tab-btn-history" class="flex-1 sm:flex-none px-4 py-2 text-zinc-600 hover:text-zinc-900 text-xs font-bold uppercase rounded-full transition-all whitespace-nowrap">History (0)</button>
                    </div>
                </div>
            </div>

            <!-- Search Bar and View Mode (Table vs Grid) Toolbar -->
            <div class="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4 bg-white border border-zinc-200 rounded-3xl p-4 sm:p-6 shadow-sm">
                <div class="flex items-center space-x-3 flex-grow">
                    <i class="fa-solid fa-magnifying-glass text-zinc-400"></i>
                    <input type="text" id="issue-search-input" placeholder="Search circulation records by ID, book title, or member name..." class="w-full bg-transparent text-sm text-zinc-900 focus:outline-none">
                </div>
                <!-- View Mode Toggle (Table / Grid) -->
                <div class="bg-zinc-200/70 p-1 rounded-full flex items-center space-x-1 self-start sm:self-auto">
                    <button onclick="switchViewMode('table')" id="view-mode-btn-table" class="px-4 py-2 bg-white text-zinc-900 text-xs font-bold uppercase rounded-full shadow-sm transition-all flex items-center space-x-1.5">
                        <i class="fa-solid fa-table-list text-xs"></i>
                        <span>Table</span>
                    </button>
                    <button onclick="switchViewMode('grid')" id="view-mode-btn-grid" class="px-4 py-2 text-zinc-600 hover:text-zinc-900 text-xs font-bold uppercase rounded-full transition-all flex items-center space-x-1.5">
                        <i class="fa-solid fa-grip text-xs"></i>
                        <span>Grid</span>
                    </button>
                </div>
            </div>

            <!-- Table View Container -->
            <div id="issues-table-container" class="bg-white border border-zinc-200 rounded-3xl shadow-sm overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse min-w-[700px]">
                        <thead>
                            <tr id="table-header-row" class="bg-zinc-50 border-b border-zinc-200 text-[11px] font-bold uppercase tracking-widest text-zinc-500">
                                <th class="p-4 sm:p-6">Request ID</th>
                                <th class="p-4 sm:p-6">Book Title</th>
                                <th class="p-4 sm:p-6">Member Name</th>
                                <th class="p-4 sm:p-6">Type</th>
                                <th class="p-4 sm:p-6">Requested</th>
                                <th class="p-4 sm:p-6">Status</th>
                                <th class="p-4 sm:p-6 text-right">Action</th>
                            </tr>
                        </thead>
                        <tbody id="issues-table-body" class="divide-y divide-zinc-100 text-sm">
                            <!-- Dynamic rows populated via JS -->
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Grid View Container -->
            <div id="issues-grid-container" class="hidden grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
                <!-- Dynamic grid cards populated via JS -->
            </div>

            <!-- Pagination Bar -->
            <div id="pagination-container" class="flex flex-col sm:flex-row items-center justify-between bg-white border border-zinc-200 rounded-2xl px-6 py-4 shadow-sm gap-4">
                <p class="text-xs text-zinc-500 font-medium" id="pagination-info">Showing 1 to 3 of 3 entries</p>
                <div id="pagination-buttons" class="flex items-center space-x-1.5"></div>
            </div>

        </main>

        <!-- Request Details & Edit Mode Modal -->
        <div id="request-details-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4 overflow-y-auto">
            <div class="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-8 shadow-2xl space-y-6 my-auto max-h-[90vh] overflow-y-auto">
                <div class="flex items-center justify-between border-b border-zinc-100 pb-4">
                    <div>
                        <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-500" id="modal-subtitle-type">Book Borrow Request</span>
                        <h3 id="modal-req-id" class="font-editorial text-2xl font-medium text-zinc-900">REQ-1021</h3>
                    </div>
                    <button onclick="closeRequestModal()" class="text-zinc-400 hover:text-zinc-900 p-2">
                        <i class="fa-solid fa-xmark text-lg"></i>
                    </button>
                </div>

                <div class="space-y-4 text-sm">
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div class="bg-zinc-50 p-4 rounded-2xl border border-zinc-100 space-y-1">
                            <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block">Member</span>
                            <p id="modal-member-name" class="font-medium text-zinc-900">Eleanor Vance</p>
                            <p id="modal-member-id" class="text-xs text-zinc-500 font-mono">MEM-1042</p>
                        </div>
                        <div class="bg-zinc-50 p-4 rounded-2xl border border-zinc-100 space-y-1">
                            <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block">Borrow Type</span>
                            <p id="modal-req-type" class="font-semibold text-zinc-900 uppercase">Physical</p>
                        </div>
                    </div>

                    <div class="bg-zinc-50 p-4 rounded-2xl border border-zinc-100 space-y-1">
                        <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block">Book Details</span>
                        <p id="modal-book-title" class="font-medium text-zinc-900">Java Programming</p>
                        <p id="modal-book-isbn" class="text-xs text-zinc-500 font-mono">ISBN: 978-0134685991 | 3 copies available</p>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div class="bg-zinc-50 p-4 rounded-2xl border border-zinc-100 space-y-1">
                            <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block">Requested Date</span>
                            <p id="modal-req-date" class="font-medium text-zinc-900">Sep 24, 2026</p>
                        </div>
                        <div class="bg-zinc-50 p-4 rounded-2xl border border-zinc-100 space-y-1">
                            <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block">Current Status</span>
                            <p id="modal-req-status" class="font-bold text-amber-600 uppercase">Pending</p>
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Admin Remark / Notes</label>
                        <input type="text" id="modal-admin-remark" placeholder="Enter optional admin remarks..." class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                    </div>
                </div>

                <div id="modal-action-buttons" class="pt-4 flex flex-col sm:flex-row items-center justify-between gap-3 border-t border-zinc-100">
                    <button onclick="handleRequestAction('cancel')" class="w-full sm:flex-1 py-3 bg-zinc-100 text-zinc-700 hover:bg-zinc-200 rounded-full text-xs font-bold tracking-widest uppercase transition-all">
                        [ Cancel ]
                    </button>
                    <button onclick="handleRequestAction('approve')" class="w-full sm:flex-1 py-3 bg-amber-600 text-white hover:bg-amber-700 rounded-full text-xs font-bold tracking-widest uppercase transition-all shadow-sm">
                        [ Approve ]
                    </button>
                    <button id="btn-issue-action" onclick="handleRequestAction('issue')" class="w-full sm:flex-1 py-3 bg-zinc-900 text-white hover:bg-zinc-800 rounded-full text-xs font-bold tracking-widest uppercase transition-all shadow-sm">
                        [ Issue Book ]
                    </button>
                </div>
            </div>
        </div>

        <!-- Notification Modal -->
        <!-- Notification / Action Modal -->
    <div id="notification-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-sm w-full p-6 sm:p-8 text-center shadow-2xl space-y-4">
            <div id="modal-icon-container" class="w-12 h-12 rounded-full bg-zinc-100 text-zinc-900 mx-auto flex items-center justify-center text-xl">
                <i id="modal-icon" class="fa-solid fa-circle-check"></i>
            </div>
            <h3 id="modal-title" class="font-editorial text-2xl font-medium text-zinc-900">Notice</h3>
            <p id="modal-message" class="text-xs text-zinc-600 leading-relaxed whitespace-pre-line"></p>
            
            <div id="single-action-box">
                <button onclick="closeModal()" class="w-full py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all">
                    Dismiss
                </button>
            </div>
            
            <div id="dual-action-box" class="hidden items-center space-x-3 w-full pt-2">
                <button type="button" onclick="closeModal()" class="w-1/2 py-3 bg-zinc-100 text-zinc-700 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200 transition-all">
                    Cancel
                </button>
                <button id="modal-confirm-btn" type="button" class="w-1/2 py-3 bg-rose-600 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-rose-700 transition-all shadow-sm">
                    Confirm
                </button>
            </div>
        </div>
    </div>

        <!-- Footer -->
        <footer class="bg-zinc-900 text-zinc-400 py-12 border-t border-zinc-800 mt-16">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 flex flex-col md:flex-row items-center justify-between text-xs text-zinc-500 gap-4 text-center md:text-left">
                <p>&copy; 2026 Aurelia Library & Knowledge Sanctuary. Circulation Registry Active.</p>
                <div class="flex flex-wrap justify-center space-x-6">
                    <a href="admin_authors.html" class="hover:text-white transition-colors">Authors Management</a>
                    <a href="member-details.jsp" class="hover:text-white transition-colors">Member Dossiers</a>
                </div>
            </div>
        </footer>
        <script src="${pageContext.request.contextPath}/js/adminNavJs.js"></script>
        <script src="${pageContext.request.contextPath}/js/Book-Issue_ApprovedJS.js"></script>
    </body>
</html>
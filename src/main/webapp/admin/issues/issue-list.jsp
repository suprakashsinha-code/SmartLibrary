<%-- 
    Document   : issue-list
    Created on : 22 Sept 2026, 7:57:35 pm
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
    <title>AURELIA | Circulation Issue Details & Fine Management</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Fonts: Playfair Display for editorial headings & Inter for body -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <!-- FontAwesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/adminNavCss.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/issue-listCss.css">
    <style>
        
    </style>
</head>
<body class="selection:bg-zinc-900 selection:text-zinc-100 overflow-x-hidden min-h-screen flex flex-col justify-between">

    <!-- Sticky Header Navigation matching Aurelia Theme -->
<jsp:include page="/include/adminNav.jsp" />

    <!-- Main Content Area -->
    <main class="flex-grow max-w-7xl w-full mx-auto px-4 sm:px-6 py-6 sm:py-12 md:py-16 space-y-8 sm:space-y-10">
        
        <!-- Search and Query Bar for Database Retrieval -->
        <section class="bg-white border border-zinc-200 rounded-3xl p-5 sm:p-8 shadow-sm">
            <div class="max-w-2xl mx-auto text-center space-y-3 sm:space-y-4">
                <span class="text-[10px] sm:text-xs font-bold tracking-widest uppercase text-zinc-500">Database Search & GET Retrieval</span>
                <h1 class="font-editorial text-2xl sm:text-4xl font-normal text-zinc-900 uppercase">Issue Record Lookup</h1>
                <p class="text-xs text-zinc-500">Query specific circulation logs, return schedules, and overdue fine status via backend database identifiers.</p>
                
                <!-- GET Form to Query Record -->
                <form method="GET" action="issue-details.jsp" onsubmit="handleQuerySubmit(event)" class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 pt-2">
                    <div class="relative flex-grow">
                        <span class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-zinc-400">
                            <i class="fa-solid fa-magnifying-glass"></i>
                        </span>
                        <input type="text" id="query-issue-id" name="issueId" placeholder="Enter Issue ID (e.g. ISS-9012)..." class="w-full pl-11 pr-4 py-3 sm:py-3.5 bg-zinc-50 border border-zinc-200 rounded-full text-xs sm:text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                    </div>
                    <button type="submit" class="px-6 py-3.5 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-sm whitespace-nowrap">
                        Fetch Record (GET)
                    </button>
                </form>
            </div>
        </section>

        <!-- Main Dossier Container -->
        <div id="issue-record-container" class="space-y-6 sm:space-y-8">
            
            <!-- Header Toolbar & View Toggles for Associated Records (Table vs Grid) -->
            <div class="flex flex-col lg:flex-row lg:items-end justify-between gap-4 border-b border-zinc-200 pb-6">
                <div>
                    <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Active Circulation Dossier</span>
                    <h2 id="dossier-header-title" class="font-editorial text-2xl sm:text-3xl font-medium text-zinc-900">Record: ISS-9012</h2>
                </div>
                <div class="flex flex-wrap items-center gap-2 sm:gap-3">
                    <!-- View Toggle Buttons (Table / Grid) -->
                    <div class="bg-zinc-200/70 p-1 rounded-full flex items-center space-x-1">
                        <button onclick="setDetailView('table')" id="view-btn-table" class="px-3 sm:px-4 py-2 bg-white text-zinc-900 text-[11px] sm:text-xs font-bold uppercase rounded-full shadow-sm transition-all"><i class="fa-solid fa-table-list mr-1"></i> Table</button>
                        <button onclick="setDetailView('grid')" id="view-btn-grid" class="px-3 sm:px-4 py-2 text-zinc-600 hover:text-zinc-900 text-[11px] sm:text-xs font-bold uppercase rounded-full transition-all"><i class="fa-solid fa-grip mr-1"></i> Grid</button>
                    </div>
                    <button onclick="openReturnModal()" class="px-4 sm:px-6 py-2.5 sm:py-3 bg-zinc-900 text-white rounded-full text-[11px] sm:text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-sm whitespace-nowrap">
                        <i class="fa-solid fa-circle-check mr-1.5"></i> Process Return
                    </button>
                </div>
            </div>

            <!-- Section 1: Detailed Metadata Grid -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 sm:gap-8">
                <!-- Book & Category Card -->
                <div class="bg-white border border-zinc-200 rounded-3xl p-5 sm:p-8 shadow-sm space-y-4 md:col-span-2 flex flex-col justify-between">
                    <div class="space-y-3">
                        <div class="flex flex-wrap items-center justify-between gap-2">
                            <span id="record-category" class="px-3 py-1 bg-zinc-100 text-zinc-800 text-[10px] font-bold uppercase rounded-full">Philosophy / Epistemology</span>
                            <span id="record-status-badge" class="px-3 py-1 bg-amber-50 text-amber-800 text-[10px] font-bold uppercase rounded-full border border-amber-200">Due in 4 Days</span>
                        </div>
                        <div>
                            <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block">Book Title & Reference</span>
                            <h3 id="record-book-title" class="font-editorial text-xl sm:text-2xl font-medium text-zinc-900 mt-1">Critique of Pure Reason</h3>
                            <p id="record-author" class="text-xs text-zinc-500 uppercase mt-0.5">Author: Immanuel Kant (ISBN: 978-0141)</p>
                        </div>
                    </div>
                    
                    <div class="bg-zinc-50 p-4 rounded-2xl border border-zinc-100 grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
                        <div>
                            <span class="text-[9px] font-bold uppercase tracking-widest text-zinc-400 block">Borrowing Member</span>
                            <p id="record-member-name" class="font-medium text-zinc-900 mt-0.5">Eleanor Vance (MEM-1042)</p>
                        </div>
                        <div>
                            <span class="text-[9px] font-bold uppercase tracking-widest text-zinc-400 block">Contact Email</span>
                            <p id="record-member-email" class="font-medium text-zinc-900 mt-0.5 break-all">eleanor.vance@scholarly.org</p>
                        </div>
                    </div>
                </div>

                <!-- Date & Fine Assessment Card -->
                <div class="bg-white border border-zinc-200 rounded-3xl p-5 sm:p-8 shadow-sm space-y-4 flex flex-col justify-between">
                    <div>
                        <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block mb-3">Schedule & Fine Status</span>
                        <div class="space-y-3 text-xs">
                            <div class="flex justify-between border-b border-zinc-100 pb-2">
                                <span class="text-zinc-500">Issue Date:</span>
                                <strong id="record-issue-date" class="text-zinc-900">Oct 12, 2026</strong>
                            </div>
                            <div class="flex justify-between border-b border-zinc-100 pb-2">
                                <span class="text-zinc-500">Due Date:</span>
                                <strong id="record-due-date" class="text-rose-600">Nov 02, 2026</strong>
                            </div>
                            <div class="flex justify-between border-b border-zinc-100 pb-2">
                                <span class="text-zinc-500">Return Date:</span>
                                <strong id="record-return-date" class="text-zinc-600 italic">Pending Return</strong>
                            </div>
                            <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center pt-1 gap-1">
                                <span class="text-zinc-500 font-bold uppercase">Calculated Fine:</span>
                                <strong id="record-fine-amount" class="text-emerald-700 font-mono text-right">$0.00 (On Schedule)</strong>
                            </div>
                        </div>
                    </div>

                    <button onclick="calculateFineStatus()" class="w-full py-3 bg-zinc-100 text-zinc-900 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200 transition-all">
                        <i class="fa-solid fa-calculator mr-1"></i> Calculate Fine (GET)
                    </button>
                </div>
            </div>

            <!-- Section 2: Associated Items Table View Container -->
            <div id="detail-table-container" class="bg-white border border-zinc-200 rounded-3xl shadow-sm overflow-hidden">
                <div class="p-5 sm:p-6 border-b border-zinc-100 flex flex-col sm:flex-row sm:items-center justify-between gap-2">
                    <h3 class="font-editorial text-lg sm:text-xl font-medium text-zinc-900">Circulation History Breakdown (Table)</h3>
                    <span class="text-[11px] text-zinc-500">Clickable rows for database inspection</span>
                </div>
                <div class="overflow-x-auto w-full">
                    <table class="w-full text-left border-collapse min-w-[750px]">
                        <thead>
                            <tr class="bg-zinc-50 border-b border-zinc-200 text-[11px] font-bold uppercase tracking-widest text-zinc-500">
                                <th class="p-4 sm:p-6">Log ID / Ref</th>
                                <th class="p-4 sm:p-6">Book Title & Author</th>
                                <th class="p-4 sm:p-6">Member ID</th>
                                <th class="p-4 sm:p-6">Issue & Due Schedule</th>
                                <th class="p-4 sm:p-6">Fine Condition</th>
                                <th class="p-4 sm:p-6 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="detail-table-body" class="divide-y divide-zinc-100 text-sm">
                            <tr class="hover:bg-zinc-50/50 transition-colors cursor-pointer" onclick="loadIssueRecord('ISS-9012')">
                                <td class="p-4 sm:p-6 font-mono text-xs font-bold text-zinc-900">ISS-9012</td>
                                <td class="p-4 sm:p-6">
                                    <div class="font-medium text-zinc-900">Critique of Pure Reason</div>
                                    <div class="text-xs text-zinc-500">Immanuel Kant</div>
                                </td>
                                <td class="p-4 sm:p-6 text-xs text-zinc-600 font-mono">MEM-1042</td>
                                <td class="p-4 sm:p-6 text-xs text-zinc-600">
                                    <div>Out: Oct 12, 2026</div>
                                    <div class="text-rose-600 font-semibold">Due: Nov 02, 2026</div>
                                </td>
                                <td class="p-4 sm:p-6">
                                    <span class="px-3 py-1 bg-amber-50 text-amber-800 text-[10px] font-bold uppercase rounded-full border border-amber-200 whitespace-nowrap">Due in 4 Days ($0.00)</span>
                                </td>
                                <td class="p-4 sm:p-6 text-right space-x-1" onclick="event.stopPropagation()">
                                    <button onclick="loadIssueRecord('ISS-9012')" class="text-zinc-600 hover:text-zinc-900 p-2" title="View"><i class="fa-solid fa-id-card"></i></button>
                                    <button onclick="openReturnModal('ISS-9012')" class="text-emerald-600 hover:text-emerald-800 p-2" title="Return & Fine"><i class="fa-solid fa-circle-check"></i></button>
                                </td>
                            </tr>
                            <tr class="hover:bg-zinc-50/50 transition-colors cursor-pointer" onclick="loadIssueRecord('ISS-9015')">
                                <td class="p-4 sm:p-6 font-mono text-xs font-bold text-zinc-900">ISS-9015</td>
                                <td class="p-4 sm:p-6">
                                    <div class="font-medium text-zinc-900">Structure of Scientific Revolutions</div>
                                    <div class="text-xs text-zinc-500">Thomas Kuhn</div>
                                </td>
                                <td class="p-4 sm:p-6 text-xs text-zinc-600 font-mono">MEM-2089</td>
                                <td class="p-4 sm:p-6 text-xs text-zinc-600">
                                    <div>Out: Oct 18, 2026</div>
                                    <div class="text-zinc-900 font-semibold">Due: Nov 18, 2026</div>
                                </td>
                                <td class="p-4 sm:p-6">
                                    <span class="px-3 py-1 bg-emerald-50 text-emerald-800 text-[10px] font-bold uppercase rounded-full border border-emerald-200 whitespace-nowrap">On Time ($0.00)</span>
                                </td>
                                <td class="p-4 sm:p-6 text-right space-x-1" onclick="event.stopPropagation()">
                                    <button onclick="loadIssueRecord('ISS-9015')" class="text-zinc-600 hover:text-zinc-900 p-2" title="View"><i class="fa-solid fa-id-card"></i></button>
                                    <button onclick="openReturnModal('ISS-9015')" class="text-emerald-600 hover:text-emerald-800 p-2" title="Return & Fine"><i class="fa-solid fa-circle-check"></i></button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Section 3: Associated Items Grid View Container (Hidden by Default) -->
            <div id="detail-grid-container" class="hidden grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                <!-- Grid Card 1 -->
                <div class="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col justify-between space-y-4 hover:shadow-md transition-all cursor-pointer" onclick="loadIssueRecord('ISS-9012')">
                    <div class="space-y-3">
                        <div class="flex items-center justify-between">
                            <span class="font-mono text-xs font-bold text-zinc-400">ISS-9012</span>
                            <span class="px-3 py-1 bg-amber-50 text-amber-800 text-[10px] font-bold uppercase rounded-full border border-amber-200">Due in 4 Days</span>
                        </div>
                        <div>
                            <span class="px-2.5 py-0.5 bg-zinc-100 text-zinc-700 text-[9px] font-bold uppercase rounded-full">Philosophy</span>
                            <h3 class="font-editorial text-xl font-medium text-zinc-900 mt-1">Critique of Pure Reason</h3>
                        </div>
                        <div class="bg-zinc-50 p-3 rounded-2xl border border-zinc-100 space-y-1 text-xs">
                            <div>Borrower: <strong class="text-zinc-900">Eleanor Vance (MEM-1042)</strong></div>
                            <div>Due: <strong class="text-rose-600">Nov 02, 2026</strong></div>
                            <div>Fine Status: <strong class="text-emerald-700">$0.00</strong></div>
                        </div>
                    </div>
                    <div class="pt-4 border-t border-zinc-100 flex items-center justify-between" onclick="event.stopPropagation()">
                        <button onclick="loadIssueRecord('ISS-9012')" class="px-4 py-2 bg-zinc-900 text-white rounded-full text-[10px] font-bold uppercase tracking-widest hover:bg-zinc-800 transition-all">
                            View Record
                        </button>
                        <button onclick="openReturnModal('ISS-9012')" class="text-emerald-600 hover:text-emerald-800 text-xs font-bold uppercase">
                            <i class="fa-solid fa-circle-check mr-1"></i> Return
                        </button>
                    </div>
                </div>

                <!-- Grid Card 2 -->
                <div class="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col justify-between space-y-4 hover:shadow-md transition-all cursor-pointer" onclick="loadIssueRecord('ISS-9015')">
                    <div class="space-y-3">
                        <div class="flex items-center justify-between">
                            <span class="font-mono text-xs font-bold text-zinc-400">ISS-9015</span>
                            <span class="px-3 py-1 bg-emerald-50 text-emerald-800 text-[10px] font-bold uppercase rounded-full border border-emerald-200">On Time</span>
                        </div>
                        <div>
                            <span class="px-2.5 py-0.5 bg-zinc-100 text-zinc-700 text-[9px] font-bold uppercase rounded-full">Physics</span>
                            <h3 class="font-editorial text-xl font-medium text-zinc-900 mt-1">Structure of Scientific Revolutions</h3>
                        </div>
                        <div class="bg-zinc-50 p-3 rounded-2xl border border-zinc-100 space-y-1 text-xs">
                            <div>Borrower: <strong class="text-zinc-900">Julian Sterling (MEM-2089)</strong></div>
                            <div>Due: <strong class="text-zinc-900">Nov 18, 2026</strong></div>
                            <div>Fine Status: <strong class="text-emerald-700">$0.00</strong></div>
                        </div>
                    </div>
                    <div class="pt-4 border-t border-zinc-100 flex items-center justify-between" onclick="event.stopPropagation()">
                        <button onclick="loadIssueRecord('ISS-9015')" class="px-4 py-2 bg-zinc-900 text-white rounded-full text-[10px] font-bold uppercase tracking-widest hover:bg-zinc-800 transition-all">
                            View Record
                        </button>
                        <button onclick="openReturnModal('ISS-9015')" class="text-emerald-600 hover:text-emerald-800 text-xs font-bold uppercase">
                            <i class="fa-solid fa-circle-check mr-1"></i> Return
                        </button>
                    </div>
                </div>
            </div>

        </div>

    </main>

    <!-- Return & Fine Processing Modal (POST Endpoint Form) -->
    <div id="return-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-8 shadow-2xl space-y-6 max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between border-b border-zinc-100 pb-4">
                <div>
                    <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Circulation Settlement</span>
                    <h3 class="font-editorial text-xl sm:text-2xl font-medium text-zinc-900">Process Return & Fine (POST)</h3>
                </div>
                <button onclick="closeReturnModal()" class="text-zinc-400 hover:text-zinc-900 p-2">
                    <i class="fa-solid fa-xmark text-lg"></i>
                </button>
            </div>

            <!-- POST Form communicating with database endpoint -->
            <form id="return-form" method="POST" action="/api/issues/return" onsubmit="handleReturnFormSubmit(event)" class="space-y-4">
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Issue Reference ID *</label>
                    <input type="text" id="modal-issue-id" name="issueId" value="ISS-9012" readonly class="w-full px-4 py-3 bg-zinc-100 border border-zinc-200 rounded-xl text-sm text-zinc-900 font-mono focus:outline-none">
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Actual Return Date *</label>
                        <input type="date" id="modal-return-date" name="returnDate" required class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Assessed Fine ($) *</label>
                        <input type="text" id="modal-fine-amount" name="fineAmount" value="$0.00" readonly class="w-full px-4 py-3 bg-zinc-100 border border-zinc-200 rounded-xl text-sm text-emerald-700 font-mono font-bold focus:outline-none">
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Condition Remarks & Fine Notes</label>
                    <textarea id="modal-remarks" name="remarks" rows="3" placeholder="Enter condition remarks or fine payment method..." class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors resize-none"></textarea>
                </div>

                <!-- Form Action Buttons -->
                <div class="pt-4 flex flex-col sm:flex-row items-center gap-3">
                    <button type="button" onclick="closeReturnModal()" class="w-full sm:w-1/2 py-3 bg-zinc-100 text-zinc-700 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200 transition-all">
                        Cancel
                    </button>
                    <button type="submit" class="w-full sm:w-1/2 py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-sm">
                        Confirm Return (POST)
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Notification Modal -->
    <div id="notification-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-sm w-full p-6 sm:p-8 text-center shadow-2xl space-y-4">
            <div class="w-12 h-12 rounded-full bg-zinc-100 text-zinc-900 mx-auto flex items-center justify-center text-xl">
                <i class="fa-solid fa-circle-check" id="modal-icon"></i>
            </div>
            <h3 id="modal-title" class="font-editorial text-2xl font-medium text-zinc-900">Notice</h3>
            <p id="modal-message" class="text-xs text-zinc-600 leading-relaxed whitespace-pre-line"></p>
            <button onclick="closeModal()" class="w-full py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all">
                Dismiss
            </button>
        </div>
    </div>

    <!-- Footer -->
    <footer class="bg-zinc-900 text-zinc-400 py-10 sm:py-12 border-t border-zinc-800 mt-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 flex flex-col md:flex-row items-center justify-between text-xs text-zinc-500 gap-4 text-center md:text-left">
            <p>&copy; 2026 Aurelia Library & Knowledge Sanctuary. Circulation Details Active.</p>
            <div class="flex flex-wrap justify-center space-x-6">
                <a href="issue-list.jsp" class="hover:text-white transition-colors">Issue Directory</a>
                <a href="member-details.jsp" class="hover:text-white transition-colors">Member Dossiers</a>
            </div>
        </div>
    </footer>
<script src="${pageContext.request.contextPath}/js/adminNavJs.js"></script>
<script src="${pageContext.request.contextPath}/js/issue-listJs.js"></script>
    </body>
</html>

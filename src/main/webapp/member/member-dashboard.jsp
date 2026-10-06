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
    <title>AURELIA | Member Portal & Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-dash.css">
    <script>window.contextPath = '<%= request.getContextPath() %>';</script>
</head>
<body class="selection:bg-zinc-900 selection:text-zinc-100 overflow-x-hidden min-h-screen flex flex-col justify-between">

    <header class="w-full border-b border-zinc-200 bg-[#FBFBFA]/95 backdrop-blur-md sticky top-0 z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 h-16 md:h-20 flex items-center justify-between gap-4">
            <a href="<%= request.getContextPath()%>/index.jsp" class="font-editorial text-lg sm:text-2xl tracking-wider font-bold text-zinc-900 uppercase flex items-center gap-2 shrink-0">
                <span>AURELIA</span>
                <span class="text-[9px] sm:text-xs font-sans tracking-normal font-normal text-zinc-500 uppercase border border-zinc-300 px-2 py-0.5 rounded-full">Member Portal</span>
            </a>

            <div class="hidden sm:flex items-center space-x-4 md:space-x-6">
                <a href="<%= request.getContextPath()%>/member/profile.jsp" class="flex items-center space-x-2.5 hover:opacity-85 transition-opacity cursor-pointer">
                    <div class="w-8 h-8 rounded-full bg-zinc-900 text-white flex items-center justify-center font-bold text-xs">
                        <%
                            String fullName = (String) session.getAttribute("userName");
                            String initials = "M";
                            if (fullName != null && !fullName.trim().isEmpty()) {
                                String[] parts = fullName.trim().split("\\s+");
                                initials = (parts.length == 1) ? parts[0].substring(0, 1).toUpperCase() : (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1)).toUpperCase();
                            }
                            out.print(initials);
                        %>
                    </div>
                    <div class="text-left leading-tight">
                        <p class="text-xs font-bold text-zinc-900"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Member" %></p>
                        <p class="text-[10px] text-zinc-500 uppercase tracking-widest"><%= "ADMIN".equals(session.getAttribute("userRole")) ? "Administrator" : "Member" %></p>
                    </div>
                </a>
                <a href="<%= request.getContextPath()%>/logout" class="inline-flex items-center justify-center px-4 py-1.5 border border-zinc-300 text-xs font-bold tracking-widest uppercase rounded-full hover:bg-zinc-900 hover:text-white transition-all">
                    <span>Sign Out</span>
                </a>
            </div>

            <button onclick="toggleMobileNav()" class="sm:hidden p-2 text-zinc-800 focus:outline-none" aria-label="Toggle navigation menu">
                <i id="mobile-nav-icon" class="fa-solid fa-bars text-lg"></i>
            </button>
        </div>

        <div id="mobile-nav-drawer" class="hidden sm:hidden border-t border-zinc-200 bg-[#FBFBFA] px-4 py-4 space-y-4">
            <a href="<%= request.getContextPath()%>/member/profile.jsp" class="flex items-center space-x-3 pb-3 border-b border-zinc-100 hover:opacity-85 transition-opacity cursor-pointer">
                <div class="w-9 h-9 rounded-full bg-zinc-900 text-white flex items-center justify-center font-bold text-xs shrink-0"><%= initials %></div>
                <div>
                    <p class="text-xs font-bold text-zinc-900"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Member" %></p>
                    <p class="text-[10px] text-zinc-500 uppercase tracking-widest"><%= "ADMIN".equals(session.getAttribute("userRole")) ? "Administrator" : "Member" %></p>
                </div>
            </a>
            <a href="<%= request.getContextPath()%>/logout" class="block w-full text-center px-4 py-2.5 border border-zinc-300 text-xs font-bold tracking-widest uppercase rounded-full hover:bg-zinc-900 hover:text-white transition-all">
                Sign Out
            </a>
        </div>
    </header>

    <main class="flex-grow max-w-7xl w-full mx-auto px-4 sm:px-6 py-6 sm:py-8 md:py-12">
        <div class="bg-white border border-zinc-200 rounded-2xl sm:rounded-3xl p-5 sm:p-8 md:p-10 mb-8 shadow-sm flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
            <div class="space-y-2">
                <p class="text-[10px] sm:text-xs font-bold tracking-widest uppercase text-zinc-500">Active Session / JPA Principal</p>
                <h1 class="font-editorial text-2xl sm:text-3xl md:text-4xl font-normal text-zinc-900">
                    Welcome back, <%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Member" %>.
                </h1>
                <p class="text-zinc-600 text-xs sm:text-sm font-light leading-relaxed">Your membership is fully verified.</p>
            </div>
            <div class="flex flex-wrap gap-3 w-full md:w-auto">
                <a href="<%= request.getContextPath()%>/member/catalog" class="w-full md:w-auto px-6 py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-md flex items-center justify-center">
                    <i class="fa-solid fa-plus mr-2"></i>New Borrowing Request
                </a>
            </div>
        </div>

        <div class="flex border-b border-zinc-200 mb-8 overflow-x-auto no-scrollbar space-x-6 sm:space-x-8 text-xs font-bold tracking-widest uppercase shrink-0">
            <button onclick="switchTab('loans')" id="tab-loans" class="dashboard-tab pb-4 border-b-2 border-zinc-900 text-zinc-950 transition-all whitespace-nowrap">Active Loans (2)</button>
            <button onclick="switchTab('status')" id="tab-status" class="dashboard-tab pb-4 border-b-2 border-transparent text-zinc-400 hover:text-zinc-700 transition-all whitespace-nowrap">Request Status</button>
            <button onclick="switchTab('history')" id="tab-history" class="dashboard-tab pb-4 border-b-2 border-transparent text-zinc-400 hover:text-zinc-700 transition-all whitespace-nowrap">Borrowing History</button>
        </div>

        <div id="content-loans" class="dashboard-content space-y-6">
            <div id="active-loans-container" class="grid grid-cols-1 md:grid-cols-2 gap-6"></div>
        </div>

        <div id="content-status" class="dashboard-content space-y-6 hidden">
            <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 bg-white border border-zinc-200 p-4 sm:p-6 rounded-2xl shadow-sm">
                <div>
                    <h3 class="font-editorial text-lg sm:text-xl font-medium text-zinc-900">Borrowing Request Status</h3>
                    <p class="text-xs text-zinc-500 mt-1">Track the lifecycle of your submitted requests.</p>
                </div>
                <div class="flex items-center bg-zinc-100 p-1.5 rounded-full border border-zinc-200 shrink-0 w-full sm:w-auto justify-center">
                    <button onclick="setStatusView('table')" id="status-btn-table" class="flex-1 sm:flex-none px-5 py-2 rounded-full text-xs font-bold tracking-wider uppercase transition-all bg-zinc-900 text-white shadow-sm flex items-center justify-center space-x-2"><span>Table</span></button>
                    <button onclick="setStatusView('grid')" id="status-btn-grid" class="flex-1 sm:flex-none px-5 py-2 rounded-full text-xs font-bold tracking-wider uppercase transition-all text-zinc-600 hover:text-zinc-900 flex items-center justify-center space-x-2"><span>Grid</span></button>
                </div>
            </div>
            <div id="status-container-table" class="bg-white border border-zinc-200 rounded-2xl p-4 sm:p-6 shadow-sm overflow-x-auto w-full">
                <table class="w-full text-left text-xs text-zinc-700 min-w-[550px]">
                    <thead class="border-b border-zinc-200 uppercase tracking-widest text-zinc-400 font-semibold">
                        <tr><th class="pb-3 pr-4">Book Title & Author</th><th class="pb-3 pr-4">Request Date</th><th class="pb-3">Status</th></tr>
                    </thead>
                    <tbody class="divide-y divide-zinc-100" id="status-table-body"></tbody>
                </table>
            </div>
            <div id="status-container-grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 hidden"></div>
        </div>

        <div id="content-history" class="dashboard-content space-y-6 hidden">
            <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 bg-white border border-zinc-200 p-4 sm:p-6 rounded-2xl shadow-sm">
                <div>
                    <h3 class="font-editorial text-lg sm:text-xl font-medium text-zinc-900">Archival Borrowing Records</h3>
                </div>
                <div class="flex items-center bg-zinc-100 p-1.5 rounded-full border border-zinc-200 shrink-0 w-full sm:w-auto justify-center">
                    <button onclick="setHistoryView('table')" id="history-btn-table" class="flex-1 sm:flex-none px-5 py-2 rounded-full text-xs font-bold tracking-wider uppercase transition-all bg-zinc-900 text-white shadow-sm flex items-center justify-center space-x-2"><span>Table</span></button>
                    <button onclick="setHistoryView('grid')" id="history-btn-grid" class="flex-1 sm:flex-none px-5 py-2 rounded-full text-xs font-bold tracking-wider uppercase transition-all text-zinc-600 hover:text-zinc-900 flex items-center justify-center space-x-2"><span>Grid</span></button>
                </div>
            </div>
            <div id="history-container-table" class="bg-white border border-zinc-200 rounded-2xl p-4 sm:p-6 shadow-sm overflow-x-auto w-full">
                <table class="w-full text-left text-xs text-zinc-700 min-w-[550px]">
                    <thead class="border-b border-zinc-200 uppercase tracking-widest text-zinc-400 font-semibold">
                        <tr><th class="pb-3 pr-4">Book Title & Author</th><th class="pb-3 pr-4">Checked Out</th><th class="pb-3 pr-4">Returned On</th><th class="pb-3 pr-4">Late Penalty</th><th class="pb-3">Status</th></tr>
                    </thead>
                    <tbody class="divide-y divide-zinc-100" id="history-table-body"></tbody>
                </table>
            </div>
            <div id="history-container-grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 hidden"></div>
            <div class="flex flex-col sm:flex-row items-center justify-between bg-white border border-zinc-200 rounded-2xl p-4 sm:p-5 shadow-sm gap-4">
                <p class="text-xs text-zinc-500 text-center sm:text-left" id="pagination-info">Showing items 1-4 of 38 records</p>
                <div class="flex flex-wrap items-center justify-center gap-1.5" id="pagination-buttons"></div>
            </div>
        </div>
    </main>

    <footer class="bg-zinc-900 text-zinc-400 py-10 sm:py-12 border-t border-zinc-800 mt-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 flex flex-col md:flex-row items-center justify-between text-xs text-zinc-500 gap-4 text-center md:text-left">
            <p>&copy; 2026 Aurelia Library. Secure JPA Session Active.</p>
            <div class="flex flex-wrap justify-center space-x-6">
                <a href="<%= request.getContextPath()%>/index.jsp" class="hover:text-white transition-colors">Return to Public Portal</a>
            </div>
        </div>
    </footer>

    <div id="notification-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-sm w-full p-6 text-center shadow-2xl space-y-4">
            <div class="w-12 h-12 rounded-full bg-zinc-100 text-zinc-900 mx-auto flex items-center justify-center text-xl"><i class="fa-solid fa-circle-check"></i></div>
            <h3 id="modal-title" class="font-editorial text-2xl font-medium text-zinc-900">Notice</h3>
            <p id="modal-message" class="text-xs text-zinc-600 leading-relaxed whitespace-pre-line"></p>
            <button onclick="closeModal()" class="w-full py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all">Dismiss</button>
        </div>
    </div>

<script src="${pageContext.request.contextPath}/js/member-dashJs.js"></script>
</body>
</html>
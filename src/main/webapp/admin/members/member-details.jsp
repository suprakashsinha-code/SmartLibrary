<%-- 
    Document   : member-details
    Created on : 22 Sept 2026, 7:57:12 pm
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
        <title>AURELIA | Members Management Directory</title>
        <!-- Tailwind CSS CDN -->
        <script src="https://cdn.tailwindcss.com"></script>
        <!-- Google Fonts: Playfair Display for editorial headings & Inter for body -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
        <!-- FontAwesome for icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/adminNavCss.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-detailsCss.css">
        <script>
    window.contextPath = '${pageContext.request.contextPath}';
</script>
    </head>
    <body>
        <body class="selection:bg-zinc-900 selection:text-zinc-100 overflow-x-hidden min-h-screen flex flex-col justify-between">
            <jsp:include page="/include/adminNav.jsp" />


    <main class="flex-grow max-w-7xl w-full mx-auto px-4 sm:px-6 py-6 sm:py-12 md:py-16 space-y-8 sm:space-y-10">
        
        <!-- Dynamic Member Dossier Container -->
        <div id="member-dossier-container" class="space-y-8">
            
            <!-- Section 1: Member Profile & Overview Card -->
            <div class="bg-white border border-zinc-200 rounded-3xl p-6 sm:p-8 shadow-sm grid grid-cols-1 md:grid-cols-3 gap-8 items-center">
                <!-- Member Avatar & Primary Badge -->
                <div class="flex flex-col items-center md:items-start space-y-4 border-b md:border-b-0 md:border-r border-zinc-100 pb-6 md:pb-0 md:pr-8">
                    <div class="relative">
                        <img id="member-avatar" src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400" alt="Member Avatar" class="w-32 h-32 sm:w-36 sm:h-36 object-cover rounded-2xl shadow-md border-2 border-zinc-200">
                        <span id="member-status-badge" class="absolute -bottom-2 -right-2 px-3 py-1 bg-emerald-600 text-white text-[10px] font-bold uppercase rounded-full tracking-wider shadow-sm">Active Member</span>
                    </div>
                    <div class="text-center md:text-left">
                        <span id="member-id-tag" class="text-[10px] font-bold uppercase tracking-widest text-zinc-400">ID: MEM-1042</span>
                        <h2 id="member-name" class="font-editorial text-2xl font-medium text-zinc-900">Eleanor Vance</h2>
                    </div>
                </div>

                <!-- Member Contact & Membership Metadata -->
                <div class="space-y-4 md:col-span-2 grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div class="bg-zinc-50 p-4 rounded-2xl border border-zinc-100 space-y-1">
                        <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block">Email Address</span>
                        <p id="member-email" class="text-sm font-medium text-zinc-900 truncate">eleanor.vance@scholarly.org</p>
                    </div>
                    <div class="bg-zinc-50 p-4 rounded-2xl border border-zinc-100 space-y-1">
                        <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block">Phone Contact</span>
                        <p id="member-phone" class="text-sm font-medium text-zinc-900">+1 (555) 382-9102</p>
                    </div>
                    <div class="bg-zinc-50 p-4 rounded-2xl border border-zinc-100 space-y-1">
                        <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block">Membership Tier</span>
                        <p id="member-tier" class="text-sm font-medium text-zinc-900 uppercase">Lifetime Research Fellow</p>
                    </div>
                    <div class="bg-zinc-50 p-4 rounded-2xl border border-zinc-100 space-y-1">
                        <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block">Registered Since</span>
                        <p id="member-joined" class="text-sm font-medium text-zinc-900">September 14, 2023</p>
                    </div>
                </div>
            </div>

            <!-- Section 2: Present Status (Currently Borrowed Books) -->
            <div class="space-y-4">
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-zinc-200 pb-4">
                    <div>
                        <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Active Checkouts</span>
                        <h3 class="font-editorial text-2xl font-normal text-zinc-900">Books Currently Checked Out</h3>
                    </div>
                    <span id="present-count-badge" class="px-3 py-1 bg-zinc-900 text-white text-xs font-bold rounded-full self-start sm:self-auto">2 Active</span>
                </div>

                <div id="present-books-grid" class="grid grid-cols-1 md:grid-cols-2 gap-6">

            </div>

            <!-- Section 3: Borrowing History Status with Pagination -->
            <div class="space-y-4">
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-zinc-200 pb-4">
                    <div>
                        <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Archival Log</span>
                        <h3 class="font-editorial text-2xl font-normal text-zinc-900">Complete Borrowing History</h3>
                    </div>
                    <span id="history-total-info" class="text-xs font-bold uppercase tracking-wider text-zinc-500">Showing Records 1-2 of 7</span>
                </div>

                <div class="bg-white border border-zinc-200 rounded-3xl shadow-sm overflow-hidden flex flex-col justify-between">
                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse min-w-[650px]">
                            <thead>
                                <tr class="bg-zinc-50 border-b border-zinc-200 text-[11px] font-bold uppercase tracking-widest text-zinc-500">
                                    <th class="p-4 sm:p-6">Book Title & Author</th>
                                    <th class="p-4 sm:p-6">Borrowed Date</th>
                                    <th class="p-4 sm:p-6">Returned Date</th>
                                    <th class="p-4 sm:p-6">Status / Fine</th>
                                </tr>
                            </thead>
                            <tbody id="history-table-body" class="divide-y divide-zinc-100 text-sm">
                                <!-- Dynamically rendered rows via JavaScript -->
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination Footer Control -->
                    <div class="px-6 py-4 bg-zinc-50/50 border-t border-zinc-200 flex flex-col sm:flex-row items-center justify-between gap-4">
                        <div class="text-xs text-zinc-500">
                            Page <span id="current-page-num" class="font-bold text-zinc-900">1</span> of <span id="total-pages-num" class="font-bold text-zinc-900">4</span>
                        </div>
                        <div class="flex items-center space-x-2" id="pagination-buttons">
                            <!-- Rendered dynamically -->
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-zinc-900 text-zinc-400 py-12 border-t border-zinc-800 mt-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 flex flex-col md:flex-row items-center justify-between text-xs text-zinc-500 gap-4 text-center md:text-left">
            <p>&copy; 2026 Aurelia Library & Knowledge Sanctuary. Member Dossier Active.</p>
            <div class="flex flex-wrap justify-center space-x-6">
                <a href="index.html" class="hover:text-white transition-colors">Home Portal</a>
                <a href="admin_authors.html" class="hover:text-white transition-colors">Management Directory</a>
            </div>
        </div>
    </footer>
<script src="${pageContext.request.contextPath}/js/adminNavJs.js"></script>
        <script src="${pageContext.request.contextPath}/js/member-detailsJs.js"></script>
    </body>
</html>

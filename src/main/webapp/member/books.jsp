<%@ page contentType="text/html" pageEncoding="UTF-8"%>
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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AURELIA | Books & Knowledge Repository</title>
        <!-- Tailwind CSS CDN -->
        <script src="https://cdn.tailwindcss.com"></script>
        <!-- Google Fonts -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
        <!-- FontAwesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-bookCss.css">
        <script>
            var contextPath = "${pageContext.request.contextPath}";
        </script>
    </head>
    <body class="selection:bg-zinc-900 selection:text-zinc-100 overflow-x-hidden min-h-screen flex flex-col justify-between">

        <!-- Responsive Header -->
        <header class="w-full border-b border-zinc-200 bg-[#FBFBFA]/95 backdrop-blur-md sticky top-0 z-50">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 h-16 md:h-20 flex items-center justify-between gap-4">
                <a href="${pageContext.request.contextPath}/index.jsp" class="font-editorial text-lg sm:text-2xl tracking-wider font-bold text-zinc-900 uppercase flex items-center gap-2 shrink-0">
                    <span>AURELIA</span>
                    <span class="text-[9px] sm:text-xs font-sans tracking-normal font-normal text-zinc-500 uppercase border border-zinc-300 px-2 py-0.5 rounded-full">Member Portal</span>
                </a>

                <div class="hidden sm:flex items-center space-x-3 md:space-x-5">
                    <a href="${pageContext.request.contextPath}/member/member-dashboard.jsp" class="inline-flex items-center justify-center px-4 py-1.5 border border-zinc-900 bg-zinc-900 text-white text-xs font-bold tracking-widest uppercase rounded-full hover:bg-zinc-800 transition-all"><span>Dashboard</span></a>
                    <a href="${pageContext.request.contextPath}/member/profile.jsp" class="flex items-center space-x-2.5 border-l border-zinc-200 pl-4 hover:opacity-80 transition-opacity">
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
                            <p class="text-xs font-bold text-zinc-900"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Member"%></p>
                            <p class="text-[10px] text-zinc-500 uppercase tracking-widest"><%= "ADMIN".equals(session.getAttribute("userRole")) ? "Administrator" : "Member"%></p>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/logout" class="inline-flex items-center justify-center px-4 py-1.5 border border-zinc-300 text-xs font-bold tracking-widest uppercase rounded-full hover:bg-zinc-900 hover:text-white transition-all">
                        <span>Sign Out</span>
                    </a>
                </div>

                <button onclick="toggleMobileNav()" class="sm:hidden p-2 text-zinc-800 focus:outline-none"><i id="mobile-nav-icon" class="fa-solid fa-bars text-lg"></i></button>
            </div>

            <div id="mobile-nav-drawer" class="hidden sm:hidden border-t border-zinc-200 bg-[#FBFBFA] px-4 py-4 space-y-4">
                <a href="${pageContext.request.contextPath}/member/profile.jsp" class="flex items-center space-x-3 pb-3 border-b border-zinc-100">
                    <div class="w-9 h-9 rounded-full bg-zinc-900 text-white flex items-center justify-center font-bold text-xs shrink-0"><%= initials%></div>
                    <div>
                        <p class="text-xs font-bold text-zinc-900"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Member"%></p>
                        <p class="text-[10px] text-zinc-500 uppercase tracking-widest"><%= "ADMIN".equals(session.getAttribute("userRole")) ? "Administrator" : "Member"%></p>
                    </div>
                </a>
                <div class="flex flex-col space-y-2">
                    <a href="${pageContext.request.contextPath}/member/member-dashboard.jsp" class="w-full text-center px-4 py-2.5 bg-zinc-900 text-white text-xs font-bold tracking-widest uppercase rounded-full">Dashboard</a>
                    <a href="${pageContext.request.contextPath}/logout" class="w-full text-center px-4 py-2.5 border border-zinc-300 text-xs font-bold tracking-widest uppercase rounded-full">Sign Out</a>
                </div>
            </div>
        </header>

        <!-- Circulation Policy Banner -->
        <div id="loan-policy-banner" class="bg-zinc-900 text-zinc-100 border-b border-zinc-800 py-3 px-4 sm:px-6">
            <div class="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-2 text-center sm:text-left">
                <div class="flex items-center space-x-3 text-xs sm:text-sm">
                    <span class="flex h-2 w-2 rounded-full bg-amber-400 animate-pulse shrink-0"></span>
                    <p>
                        <span class="font-bold uppercase tracking-wider text-amber-300">Circulation Policy Note:</span> 
                        Standard loan duration requires borrowed volumes to be returned within 
                        <strong id="policy-days-display" class="underline decoration-amber-400 underline-offset-4 font-semibold">14 days</strong> of acquisition. 
                        Renewals are subject to admin approval.
                    </p>
                </div>
                <div class="text-[11px] text-zinc-400 whitespace-nowrap">
                    Managed by Library Administration
                </div>
            </div>
        </div>

        <!-- Admin Configuration Panel -->
        <div id="admin-panel" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
            <div class="bg-white rounded-3xl max-w-md w-full p-6 sm:p-8 shadow-2xl space-y-6">
                <div class="flex items-center justify-between border-b border-zinc-200 pb-4">
                    <div class="flex items-center space-x-2">
                        <div class="w-9 h-9 rounded-full bg-zinc-900 text-white flex items-center justify-center text-sm">
                            <i class="fa-solid fa-sliders"></i>
                        </div>
                        <h3 class="font-editorial text-xl font-bold text-zinc-900">Admin Configuration</h3>
                    </div>
                    <button onclick="toggleAdminPanel()" class="text-zinc-400 hover:text-zinc-900 p-2">
                        <i class="fa-solid fa-xmark text-lg"></i>
                    </button>
                </div>
                <div class="space-y-4">
                    <p class="text-xs text-zinc-600 leading-relaxed">
                        Configure the circulating return window for all member checkouts. This updates the prominent loan notice across the repository in real-time.
                    </p>
                    <div class="space-y-2">
                        <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700">Select Return Period</label>
                        <div class="grid grid-cols-2 gap-3">
                            <button onclick="setLoanDays(7)" id="preset-7" class="py-3 px-4 rounded-xl border border-zinc-300 text-xs font-bold uppercase tracking-wider text-zinc-800 hover:border-zinc-900 transition-all">
                                7 Days
                            </button>
                            <button onclick="setLoanDays(14)" id="preset-14" class="py-3 px-4 rounded-xl border border-zinc-900 bg-zinc-900 text-white text-xs font-bold uppercase tracking-wider transition-all">
                                14 Days
                            </button>
                        </div>
                    </div>
                    <div class="space-y-2 pt-2">
                        <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700">Custom Return Duration (Days)</label>
                        <div class="flex items-center space-x-2">
                            <input type="number" id="custom-days-input" min="1" max="90" value="14" 
                                   class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900">
                            <button onclick="applyCustomDays()" class="px-5 py-3 bg-zinc-900 text-white rounded-xl text-xs font-bold uppercase tracking-widest hover:bg-zinc-800 transition-all shrink-0">
                                Apply
                            </button>
                        </div>
                    </div>
                </div>
                <div class="border-t border-zinc-200 pt-4">
                    <button onclick="toggleAdminPanel()" class="w-full py-3 bg-zinc-100 text-zinc-900 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200 transition-all">
                        Close Panel
                    </button>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <main class="flex-grow max-w-7xl w-full mx-auto px-4 sm:px-6 py-8 sm:py-12 md:py-16">

            <div class="max-w-3xl mb-10 sm:mb-14 space-y-3">
                <p class="text-xs font-bold tracking-widest uppercase text-zinc-500">Comprehensive Library Index</p>
                <h1 class="font-editorial text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-normal text-zinc-900 uppercase leading-tight">
                    Explore Books & Vault Acquisitions
                </h1>
                <p class="text-zinc-600 text-sm sm:text-base font-light leading-relaxed">
                    Browse our entire catalog of physical volumes and reference monographs loaded securely from database.
                </p>
            </div>

            <!-- Search + Category Filter -->
            <div class="bg-white border border-zinc-200 rounded-2xl sm:rounded-3xl p-4 sm:p-6 mb-10 shadow-sm space-y-4">
                <div class="flex flex-col lg:flex-row items-center gap-4">
                    <div class="flex items-center bg-zinc-50 border border-zinc-300 rounded-2xl sm:rounded-full px-4 py-3 w-full focus-within:border-zinc-900 transition-colors">
                        <i class="fa-solid fa-magnifying-glass text-zinc-400 mr-3 shrink-0"></i>
                        <input type="text" id="catalog-search" oninput="filterCatalog()" 
                               placeholder="Search by title, author, or category..." 
                               class="w-full bg-transparent text-sm text-zinc-900 placeholder-zinc-400 focus:outline-none">
                    </div>
                  <!--  <div class="flex flex-wrap gap-2 w-full lg:w-auto shrink-0 justify-start lg:justify-end">
                        <button onclick="setCategoryFilter('all')" id="filter-btn-all" 
                                class="cat-filter-btn px-4 py-2.5 rounded-full text-xs font-bold uppercase tracking-widest bg-zinc-900 text-white transition-all">All</button>
                        <button onclick="setCategoryFilter('philosophy')" id="filter-btn-philosophy" 
                                class="cat-filter-btn px-4 py-2.5 rounded-full text-xs font-bold uppercase tracking-widest bg-zinc-100 text-zinc-700 hover:bg-zinc-200 transition-all">Philosophy</button>
                        <button onclick="setCategoryFilter('science')" id="filter-btn-science" 
                                class="cat-filter-btn px-4 py-2.5 rounded-full text-xs font-bold uppercase tracking-widest bg-zinc-100 text-zinc-700 hover:bg-zinc-200 transition-all">Science</button>
                        <button onclick="setCategoryFilter('arts')" id="filter-btn-arts" 
                                class="cat-filter-btn px-4 py-2.5 rounded-full text-xs font-bold uppercase tracking-widest bg-zinc-100 text-zinc-700 hover:bg-zinc-200 transition-all">Arts</button>
                    </div>-->
                </div>
            </div>

            <!-- Dynamic Books Grid (from database) -->
            <div id="books-grid" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6 sm:gap-8">

                <c:choose>
                    <c:when test="${not empty bookList}">
                        <c:forEach var="book" items="${bookList}">
                            <div class="book-item bg-white border border-zinc-200 rounded-2xl p-4 sm:p-5 shadow-sm flex flex-col justify-between space-y-4 hover:shadow-md transition-all" 
                                 data-category="${book.category.categoryName != null ? book.category.categoryName.toLowerCase() : 'general'}" 
                                 data-title="${book.title} ${book.author.fullName}">
                                <div>
                                    <div class="relative aspect-[3/4] bg-zinc-100 rounded-xl overflow-hidden border border-zinc-200 mb-4 flex items-center justify-center">
                                        <i class="fa-solid fa-book text-4xl text-zinc-300"></i>
    <c:choose>
        <c:when test="${book.availableQuantity > 0}">
            <span class="absolute top-3 left-3 bg-emerald-100 text-emerald-900 text-[9px] font-bold uppercase tracking-widest px-2.5 py-1 rounded-full shadow-sm">
                Available
            </span>
        </c:when>
        <c:otherwise>
            <span class="absolute top-3 left-3 bg-amber-100 text-amber-900 text-[9px] font-bold uppercase tracking-widest px-2.5 py-1 rounded-full shadow-sm">
                Checked Out
            </span>
        </c:otherwise>
    </c:choose>
                                    </div>
                                    <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400">
                                        ${book.category.categoryName}
                                    </span>
                                    <h3 class="font-editorial text-lg font-medium text-zinc-900 mt-1">${book.title}</h3>
                                    <p class="text-xs text-zinc-600">${book.author.fullName}</p>
                                </div>
                                <div class="border-t border-zinc-100 pt-3 flex items-center justify-between">
                                    <span class="text-[11px] text-zinc-500">
                                        ${book.publisher != null ? book.publisher : 'Vault Shelf'}
                                    </span>
                                    <c:choose>
                                        <c:when test="${book.availableQuantity > 0}">
                                            <button onclick="openBorrowModal(${book.bookId}, '${book.title}', '${book.author.fullName}')" 
                                                    class="px-4 py-2 bg-zinc-900 text-white rounded-full text-[11px] font-bold uppercase tracking-widest hover:bg-zinc-800 transition-all">
                                                Borrow
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button onclick="openReserveQueue('${book.title}')" 
                                                    class="px-4 py-2 border border-zinc-900 text-zinc-900 rounded-full text-[11px] font-bold uppercase tracking-widest hover:bg-zinc-900 hover:text-white transition-all">
                                                Hold Queue
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="col-span-full text-center py-12">
                            <p class="text-zinc-500 text-sm">No books found in the database repository yet.</p>
                        </div>
                    </c:otherwise>
                </c:choose>

            </div>
        </main>

        <!-- Footer -->
        <footer class="bg-zinc-900 text-zinc-400 py-12 border-t border-zinc-800 mt-16">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 flex flex-col md:flex-row items-center justify-between text-xs text-zinc-500 gap-4 text-center md:text-left">
                <p>&copy; 2026 Aurelia Library & Knowledge Sanctuary. Secure JPA Session Active.</p>
                <div class="flex flex-wrap justify-center space-x-6">
                    <a href="${pageContext.request.contextPath}/index.html" class="hover:text-white transition-colors">Home Portal</a>
                    <a href="${pageContext.request.contextPath}/member/member-dashboard.jsp" class="hover:text-white transition-colors">My Member Dashboard</a>
                    <button onclick="toggleAdminPanel()" class="hover:text-white transition-colors underline">Admin Configuration</button>
                </div>
            </div>
        </footer>

        <!-- Notification Modal -->
        <div id="notification-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
            <div class="bg-white rounded-3xl max-w-sm w-full p-6 sm:p-8 text-center shadow-2xl space-y-4">
                <div class="w-12 h-12 rounded-full bg-zinc-100 text-zinc-900 mx-auto flex items-center justify-center text-xl">
                    <i class="fa-solid fa-circle-check"></i>
                </div>
                <h3 id="modal-title" class="font-editorial text-2xl font-medium text-zinc-900">Notice</h3>
                <p id="modal-message" class="text-xs text-zinc-600 leading-relaxed whitespace-pre-line"></p>
                <button onclick="closeModal()" class="w-full py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all">
                    Dismiss
                </button>
            </div>
        </div>

        <script src="${pageContext.request.contextPath}/js/member-bookJs.js"></script>
    </body>
</html>
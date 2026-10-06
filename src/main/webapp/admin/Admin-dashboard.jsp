<%-- 
    Document   : dashboard
    Created on : 22 Sept 2026, 7:31:03 pm
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
    <title>AURELIA | Admin Control Center & Dashboard</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Fonts: Playfair Display for editorial headings & Inter for body -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <!-- FontAwesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script>
        // Context path পাঠানো
        window.APP_CONTEXT = '${pageContext.request.contextPath}';
    </script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/adminNavCss.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dash.css">
</head>
<body class="selection:bg-zinc-900 selection:text-zinc-100 overflow-x-hidden min-h-screen flex flex-col justify-between">

    <!-- Sticky Header Navigation matching Aurelia Theme -->
    <jsp:include page="/include/adminNav.jsp" />

    <!-- Main Content Area -->
    <main class="flex-grow max-w-7xl w-full mx-auto px-4 sm:px-6 py-8 sm:py-12 md:py-16">
        
        <!-- Tab 1: Books Management -->
        <div id="tab-books" class="tab-content active space-y-8">
            
            <!-- Top Section: Header Title + Action Controls -->
            <div class="flex flex-col lg:flex-row lg:items-end justify-between gap-6 border-b border-zinc-200 pb-6">
                <div>
                    <p class="text-xs font-bold tracking-widest uppercase text-zinc-500">Repository Management</p>
                    <h1 class="font-editorial text-2xl sm:text-3xl md:text-4xl font-normal text-zinc-900 uppercase mt-1">Books Inventory</h1>
                </div>

                <!-- Controls Group -->
                <div class="flex flex-row items-center justify-between sm:justify-start gap-2 sm:gap-3 w-full sm:w-auto">
                    <!-- Table / Grid Pill Toggle Controller -->
                    <div class="inline-flex bg-zinc-100 p-1 rounded-full sm:p-1.5 border border-zinc-200 shrink-0">
                        <button onclick="setView('table')" id="view-btn-table" class="px-3 sm:px-4 py-2 rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase bg-white text-zinc-900 shadow-sm transition-all flex items-center gap-1.5 sm:gap-2">
                            <i class="fa-solid fa-table-list"></i> TABLE
                        </button>
                        <button onclick="setView('grid')" id="view-btn-grid" class="px-3 sm:px-4 py-2 rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase text-zinc-500 hover:text-zinc-900 transition-all flex items-center gap-1.5 sm:gap-2">
                            <i class="fa-solid fa-grip-vertical"></i> GRID
                        </button>
                    </div>

                    <!-- Add New Volume Button -->
                    <button onclick="openAddBookModal()" class="px-3 sm:px-6 py-2.5 sm:py-3 bg-zinc-900 text-white rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-sm flex items-center gap-1.5 sm:gap-2 shrink-0">
                        <i class="fa-solid fa-plus"></i> <span class="truncate">Add Volume</span>
                    </button>
                </div>
            </div>

            <!-- KPI Summary Cards (Total Books & Issued Books) - ডিফল্ট '0' দেওয়া হলো যাতে ফাকা না থাকে -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-6">
                <div class="bg-white border border-zinc-200 rounded-2xl p-5 sm:p-6 shadow-sm flex items-center justify-between">
                    <div>
                        <p class="text-[10px] font-bold tracking-widest uppercase text-zinc-500">Total Books</p>
                        <h3 id="stat-total-books" class="font-editorial text-2xl sm:text-3xl font-bold text-zinc-900 mt-1">0</h3>
                    </div>
                    <div class="w-10 h-10 sm:w-12 sm:h-12 rounded-full bg-zinc-100 flex items-center justify-center text-zinc-700 text-base sm:text-lg">
                        <i class="fa-solid fa-book"></i>
                    </div>
                </div>
                <div class="bg-white border border-zinc-200 rounded-2xl p-5 sm:p-6 shadow-sm flex items-center justify-between">
                    <div>
                        <p class="text-[10px] font-bold tracking-widest uppercase text-zinc-500">Issued Books</p>
                        <h3 id="stat-issued-books" class="font-editorial text-2xl sm:text-3xl font-bold text-amber-700 mt-1">0</h3>
                    </div>
                    <div class="w-10 h-10 sm:w-12 sm:h-12 rounded-full bg-amber-50 flex items-center justify-center text-amber-700 text-base sm:text-lg">
                        <i class="fa-solid fa-book-bookmark"></i>
                    </div>
                </div>
            </div>

            <!-- Search Filter Bar -->
            <div class="bg-white border border-zinc-200 rounded-2xl p-4 sm:p-5 shadow-sm flex items-center space-x-3 w-full">
                <i class="fa-solid fa-magnifying-glass text-zinc-400"></i>
                <input type="text" id="admin-book-search" oninput="filterBooks()" placeholder="Filter inventory by title, author, or category..." class="w-full bg-transparent text-xs sm:text-sm text-zinc-900 focus:outline-none">
            </div>

            <!-- Books Table View Container -->
            <div id="view-container-table" class="bg-white border border-zinc-200 rounded-3xl shadow-sm overflow-hidden">
                <div class="overflow-x-auto w-full">
                    <table class="w-full text-left border-collapse min-w-[650px]">
                        <thead>
                            <tr class="bg-zinc-50 border-b border-zinc-200 text-[11px] font-bold uppercase tracking-widest text-zinc-500">
                                <th class="p-4 sm:p-6">Title & Author</th>
                                <th class="p-4 sm:p-6">Category</th>
                                <th class="p-4 sm:p-6">Copies Available</th>
                                <th class="p-4 sm:p-6 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="books-table-body" class="divide-y divide-zinc-100 text-sm">
                            <!-- Populated dynamically via renderBooks() -->
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Books Grid View Container -->
            <div id="view-container-grid" class="hidden grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                <!-- Populated dynamically via renderBooks() -->
            </div>
        </div>

    </main>

    <!-- Add New Book Modal Form -->
    <div id="add-book-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4 overflow-y-auto">
        <div class="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-8 shadow-2xl space-y-6 my-8">
            <div class="flex items-center justify-between border-b border-zinc-100 pb-4">
                <div>
                    <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Repository Entry</span>
                    <h3 class="font-editorial text-2xl font-medium text-zinc-900">Add New Volume</h3>
                </div>
                <button onclick="closeAddBookModal()" class="text-zinc-400 hover:text-zinc-900 p-2">
                    <i class="fa-solid fa-xmark text-lg"></i>
                </button>
            </div>

            <form id="add-book-form" onsubmit="handleBookSubmit(event)" class="space-y-4">
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Book Title *</label>
                    <input type="text" id="book-title" required placeholder="e.g. Critique of Pure Reason" class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                </div>

                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Author *</label>
                    <input type="text" id="book-author" required placeholder="e.g. Immanuel Kant" class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                </div>

                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Category *</label>
                    <select id="book-category" required class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors uppercase">
                        <option value="" disabled selected>Loading categories...</option>
                    </select>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Total Copies *</label>
                        <input type="number" id="book-copies" min="1" value="1" required class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Available Count *</label>
                        <input type="number" id="book-available" min="0" value="1" required class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                    </div>
                </div>

                <div class="pt-4 flex items-center space-x-3">
                    <button type="button" onclick="closeAddBookModal()" class="w-1/2 py-3 bg-zinc-100 text-zinc-700 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200 transition-all">
                        Cancel
                    </button>
                    <button type="submit" class="w-1/2 py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-sm">
                        Save Volume
                    </button>
                </div>
            </form>
        </div>
    </div>
    <!-- Edit Book Modal -->
<div id="edit-book-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4 overflow-y-auto">
    <div class="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-8 shadow-2xl space-y-6 my-8">
        <div class="flex items-center justify-between border-b border-zinc-100 pb-4">
            <div>
                <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Repository Entry</span>
                <h3 class="font-editorial text-2xl font-medium text-zinc-900">Edit Volume</h3>
            </div>
            <button onclick="closeEditBookModal()" class="text-zinc-400 hover:text-zinc-900 p-2">
                <i class="fa-solid fa-xmark text-lg"></i>
            </button>
        </div>

        <form id="edit-book-form" onsubmit="handleBookUpdate(event)" class="space-y-4">
            <input type="hidden" id="edit-book-id">

            <div>
                <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Book Title *</label>
                <input type="text" id="edit-book-title" required 
                       class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
            </div>

            <div>
                <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Author *</label>
                <input type="text" id="edit-book-author" required 
                       class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
            </div>

            <div>
                <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Category *</label>
                <select id="edit-book-category" required 
                        class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors uppercase">
                    <option value="" disabled selected>Loading categories...</option>
                </select>
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Total Copies *</label>
                    <input type="number" id="edit-book-copies" min="1" required 
                           class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900">
                </div>
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Available Count *</label>
                    <input type="number" id="edit-book-available" min="0" required 
                           class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900">
                </div>
            </div>

            <div class="pt-4 flex items-center space-x-3">
                <button type="button" onclick="closeEditBookModal()" 
                        class="w-1/2 py-3 bg-zinc-100 text-zinc-700 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200 transition-all">
                    Cancel
                </button>
                <button type="submit" 
                        class="w-1/2 py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-sm">
                    Update Volume
                </button>
            </div>
        </form>
    </div>
</div>
    <!-- Footer -->
    <footer class="bg-zinc-900 text-zinc-400 py-12 border-t border-zinc-800 mt-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 flex flex-col md:flex-row items-center justify-between text-xs text-zinc-500 gap-4 text-center md:text-left">
            <p>&copy; 2026 Aurelia Library & Knowledge Sanctuary. Secure Admin Session Active.</p>
            <div class="flex flex-wrap justify-center space-x-6">
                <a href="index.html" class="hover:text-white transition-colors">Home Portal</a>
                <a href="profile.jsp" class="hover:text-white transition-colors">Admin Profile</a>
            </div>
        </div>
    </footer>

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
            
            <div id="dual-action-box" class="hidden flex items-center space-x-3 w-full pt-2">
                <button type="button" onclick="closeModal()" class="w-1/2 py-3 bg-zinc-100 text-zinc-700 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200 transition-all">
                    Cancel
                </button>
                <button id="modal-confirm-btn" type="button" class="w-1/2 py-3 bg-rose-600 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-rose-700 transition-all shadow-sm">
                    Confirm
                </button>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/adminNavJs.js"></script>
    <script src="${pageContext.request.contextPath}/js/admindash-js.js"></script>
</body>
</html>
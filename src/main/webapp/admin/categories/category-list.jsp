<%-- 
    Document   : category-list
    Created on : 22 Sept 2026, 7:55:55 pm
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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AURELIA | Categories Management Directory</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/adminNav.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/category-listCss.css">
    <script>
        window.contextPath = '${pageContext.request.contextPath}';
    </script>
</head>
<body class="selection:bg-zinc-900 selection:text-zinc-100 overflow-x-hidden min-h-screen flex flex-col justify-between">

    <jsp:include page="/include/adminNav.jsp" />

    <main class="flex-grow max-w-7xl w-full mx-auto px-4 sm:px-6 py-6 sm:py-12 md:py-16">
        <div id="tab-categories" class="space-y-6 sm:space-y-8">
            <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4 border-b border-zinc-200 pb-6">
                <div>
                    <p class="text-[10px] sm:text-xs font-bold tracking-widest uppercase text-zinc-500">Taxonomy & Classification</p>
                    <h1 class="font-editorial text-2xl sm:text-3xl md:text-4xl font-normal text-zinc-900 uppercase">Categories Management</h1>
                </div>
                <div class="flex flex-wrap items-center gap-3 w-full sm:w-auto justify-between sm:justify-end">
                    <div class="bg-zinc-200/70 p-1 rounded-full flex items-center space-x-1">
                        <button onclick="setCategoryView('table')" id="view-btn-table" class="px-3.5 sm:px-4 py-2 bg-white text-zinc-900 text-[11px] sm:text-xs font-bold uppercase rounded-full shadow-sm transition-all"><i class="fa-solid fa-table-list mr-1"></i> Table</button>
                        <button onclick="setCategoryView('grid')" id="view-btn-grid" class="px-3.5 sm:px-4 py-2 text-zinc-600 hover:text-zinc-900 text-[11px] sm:text-xs font-bold uppercase rounded-full transition-all"><i class="fa-solid fa-grip mr-1"></i> Grid</button>
                    </div>
                    <button onclick="openAddCategoryModal()" class="px-5 sm:px-6 py-2.5 sm:py-3 bg-zinc-900 text-white rounded-full text-[11px] sm:text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-sm whitespace-nowrap">
                        <i class="fa-solid fa-folder-plus mr-1.5"></i> Add Category
                    </button>
                </div>
            </div>

            <!-- Search Filter -->
            <div class="bg-white border border-zinc-200 rounded-2xl p-3 sm:p-5 shadow-sm flex items-center space-x-3">
                <i class="fa-solid fa-magnifying-glass text-zinc-400 pl-1"></i>
                <input type="text" id="admin-category-search" placeholder="Search categories by name or description..." class="w-full bg-transparent text-xs sm:text-sm text-zinc-900 focus:outline-none">
            </div>

            <!-- Table View Container (Empty, dynamically populated) -->
            <div id="categories-table-container" class="bg-white border border-zinc-200 rounded-3xl shadow-sm overflow-hidden w-full">
                <div class="overflow-x-auto w-full">
                    <table class="w-full text-left border-collapse min-w-[600px]">
                        <thead>
                            <tr class="bg-zinc-50 border-b border-zinc-200 text-[11px] font-bold uppercase tracking-widest text-zinc-500">
                                <th class="p-4 sm:p-6 w-1/3">Category Name</th>
                                <th class="p-4 sm:p-6 w-1/2">Description / Scope Notes</th>
                                <th class="p-4 sm:p-6 text-right w-1/6">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="categories-table-body" class="divide-y divide-zinc-100 text-sm">
                            <!-- Dynamic rows will inject here -->
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Grid View Container (Empty, dynamically populated) -->
            <div id="categories-grid-container" class="hidden grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                <!-- Dynamic cards will inject here -->
            </div>
        </div>
    </main>

    <!-- Add New Category Modal -->
    <div id="add-category-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4 overflow-y-auto">
        <div class="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-8 shadow-2xl space-y-6 my-8">
            <div class="flex items-center justify-between border-b border-zinc-100 pb-4">
                <div>
                    <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Taxonomy Repository</span>
                    <h3 class="font-editorial text-2xl font-medium text-zinc-900">Add New Category</h3>
                </div>
                <button onclick="closeAddCategoryModal()" class="text-zinc-400 hover:text-zinc-900 p-2">
                    <i class="fa-solid fa-xmark text-lg"></i>
                </button>
            </div>

            <form id="add-category-form" onsubmit="handleCategorySubmit(event)" class="space-y-4">
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Category Name *</label>
                    <input type="text" id="category-name" name="name" required placeholder="e.g. Political Philosophy & Ethics" class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                </div>
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Description & Scope Notes *</label>
                    <textarea id="category-description" name="description" rows="4" required placeholder="Enter classification details and repository scope..." class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors resize-none"></textarea>
                </div>
                <div class="pt-4 flex flex-col sm:flex-row items-center gap-3">
                    <button type="button" onclick="closeAddCategoryModal()" class="w-full sm:w-1/2 py-3 bg-zinc-100 text-zinc-700 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200 transition-all">
                        Cancel
                    </button>
                    <button type="submit" class="w-full sm:w-1/2 py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-sm">
                        Save Category
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Category Details Modal -->
    <div id="category-details-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-md w-full p-6 sm:p-8 shadow-2xl space-y-6">
            <div class="flex items-center justify-between border-b border-zinc-100 pb-4">
                <div>
                    <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Taxonomy Record</span>
                    <h3 id="details-modal-name" class="font-editorial text-2xl font-medium text-zinc-900">Category Details</h3>
                </div>
                <button onclick="closeCategoryDetailsModal()" class="text-zinc-400 hover:text-zinc-900 p-2">
                    <i class="fa-solid fa-xmark text-lg"></i>
                </button>
            </div>
            <div class="space-y-4 text-sm">
                <div>
                    <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block mb-1">Description & Scope Notes</span>
                    <p id="details-modal-desc" class="text-zinc-600 leading-relaxed bg-zinc-50 p-4 rounded-2xl border border-zinc-100"></p>
                </div>
            </div>
            <button onclick="closeCategoryDetailsModal()" class="w-full py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all">
                Close Details
            </button>
        </div>
    </div>

    <!-- Notification / Action Modal -->
    <div id="delete-confirm-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-sm w-full p-6 sm:p-8 text-center shadow-2xl space-y-4">
            <div class="w-12 h-12 rounded-full bg-rose-50 text-rose-600 mx-auto flex items-center justify-center text-xl">
                <i class="fa-solid fa-triangle-exclamation"></i>
            </div>
            <h3 class="font-editorial text-2xl font-medium text-zinc-900">Confirm Deletion</h3>
            <p class="text-xs text-zinc-600 leading-relaxed">Apni ki nishchit je apni ei category ti delete korte chan? Ei action ti remove korar por ar ferat ana jabe na.</p>
            <div class="grid grid-cols-2 gap-3 pt-2">
                <button type="button" onclick="closeDeleteConfirmModal()" class="py-3 bg-zinc-100 text-zinc-700 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200 transition-all">
                    Cancel
                </button>
                <button type="button" id="confirm-delete-btn" class="py-3 bg-rose-600 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-rose-700 transition-all shadow-sm">
                    Delete
                </button>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/adminNavJs.js"></script>
    <script src="${pageContext.request.contextPath}/js/category-listJs.js"></script>
</body>
</html>
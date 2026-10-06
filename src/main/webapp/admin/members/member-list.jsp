<%-- 
    Document   : member-list
    Created on : 22 Sept 2026, 7:56:56 pm
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
        <title>AURELIA | Members Management Directory</title>
        <!-- Tailwind CSS CDN -->
        <script src="https://cdn.tailwindcss.com"></script>
        <!-- Google Fonts: Playfair Display for editorial headings & Inter for body -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
        <!-- FontAwesome for icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/adminNavCss.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-listCss.css">
        <script>
        window.contextPath = '${pageContext.request.contextPath}';
        </script>
    </head>
    <body class="selection:bg-zinc-900 selection:text-zinc-100 overflow-x-hidden min-h-screen flex flex-col justify-between">

        <!-- Sticky Header Navigation matching Aurelia Theme -->
        <jsp:include page="/include/adminNav.jsp" />

        <!-- Main Content Area: Members Page -->
        <main class="flex-grow max-w-7xl w-full mx-auto px-4 sm:px-6 py-6 sm:py-12 md:py-16">

            <!-- Members Directory Management Section -->
            <div id="tab-members" class="space-y-6 sm:space-y-8">
                <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4 border-b border-zinc-200 pb-6">
                    <div>
                        <p class="text-[10px] sm:text-xs font-bold tracking-widest uppercase text-zinc-500">Sanctuary Access Control</p>
                        <h1 class="font-editorial text-2xl sm:text-3xl md:text-4xl font-normal text-zinc-900 uppercase">Members Management</h1>
                    </div>
                    <!-- Tight side-by-side control grouping matching reference pic layout -->
                    <div class="flex flex-wrap items-center gap-2 sm:gap-3 w-full sm:w-auto justify-between sm:justify-end">
                        <!-- View Toggle Buttons -->
                        <div class="bg-zinc-200/70 p-1 rounded-full flex items-center space-x-1">
                            <button onclick="setMemberView('table')" id="view-btn-table" class="px-3.5 sm:px-4 py-2 bg-white text-zinc-900 text-[11px] sm:text-xs font-bold uppercase rounded-full shadow-sm transition-all"><i class="fa-solid fa-table-list mr-1"></i> Table</button>
                            <button onclick="setMemberView('grid')" id="view-btn-grid" class="px-3.5 sm:px-4 py-2 text-zinc-600 hover:text-zinc-900 text-[11px] sm:text-xs font-bold uppercase rounded-full transition-all"><i class="fa-solid fa-grip mr-1"></i> Grid</button>
                        </div>
                        <!-- Add Members Button -->
                        <button onclick="openAddMemberModal()" class="px-5 sm:px-6 py-2.5 sm:py-3 bg-zinc-900 text-white rounded-full text-[11px] sm:text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-sm whitespace-nowrap">
                            <i class="fa-solid fa-user-plus mr-1.5"></i> Add Members
                        </button>
                    </div>
                </div>

                <!-- Members Search Filter -->
                <div class="bg-white border border-zinc-200 rounded-2xl p-3 sm:p-5 shadow-sm flex items-center space-x-3">
                    <i class="fa-solid fa-magnifying-glass text-zinc-400 pl-1"></i>
                    <input type="text" id="admin-member-search" placeholder="Search members by name, email, or role..." class="w-full bg-transparent text-xs sm:text-sm text-zinc-900 focus:outline-none">
                </div>

                <!-- Members Table View Container -->
                <!-- Members Table View Container -->
                <div id="members-table-container" class="bg-transparent sm:bg-white sm:border sm:border-zinc-200 sm:rounded-3xl sm:shadow-sm overflow-hidden w-full">
                    <div class="w-full">
                        <table class="w-full text-left border-collapse responsive-data-table">
                            <thead>
                                <tr class="bg-zinc-50 border-b border-zinc-200 text-[11px] font-bold uppercase tracking-widest text-zinc-500">
                                    <th class="p-4 sm:p-6">Member Full Name</th>
                                    <th class="p-4 sm:p-6">Email Address</th>
                                    <th class="p-4 sm:p-6">Contact Phone</th>
                                    <th class="p-4 sm:p-6">Assigned Role</th>
                                    <th class="p-4 sm:p-6 text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="members-table-body" class="sm:divide-y sm:divide-zinc-100 text-sm">
                                
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Members Grid View Container (Hidden by Default) -->
                <div id="members-grid-container" class="hidden grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                    <!-- Grid Card 1 -->

                </div>
            </div>

        </main>

        <!-- Add New Member Modal Form -->
        <div id="add-member-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4 overflow-y-auto">
            <div class="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-8 shadow-2xl space-y-6 my-8">
                <div class="flex items-center justify-between border-b border-zinc-100 pb-4">
                    <div>
                        <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Access Directory</span>
                        <h3 class="font-editorial text-2xl font-medium text-zinc-900">Add New Member</h3>
                    </div>
                    <button onclick="closeAddMemberModal()" class="text-zinc-400 hover:text-zinc-900 p-2">
                        <i class="fa-solid fa-xmark text-lg"></i>
                    </button>
                </div>

                <!-- Form configured with POST action and method support -->
                <form id="add-member-form" onsubmit="handleMemberSubmit(event)" action="/api/members" method="POST" class="space-y-4">
                    <input type="hidden" name="_method" value="POST">

                    <!-- Member Full Name -->
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Member Full Name *</label>
                        <input type="text" id="member-name" name="name" required placeholder="e.g. Margaret Cavendish" class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                    </div>

                    <!-- Email Address -->
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Email Address *</label>
                        <input type="email" id="member-email" name="email" required placeholder="e.g. margaret.cavendish@aurelia.org" class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                    </div>

                    <!-- Contact Phone -->
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Contact Phone (Optional)</label>
                        <input type="text" id="member-phone" name="phone" placeholder="e.g. +1 (555) 019-2834 (Leave blank if unavailable)" class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                        <p class="text-[10px] text-zinc-500 mt-1">If the member does not have a phone, leave blank and credentials will be assigned via email.</p>
                    </div>

                    <!-- Admin Assigned Password -->
                    <div>
                        <div class="flex items-center justify-between mb-1">
                            <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700">Admin-Assigned Password *</label>
                            <button type="button" onclick="generateRandomPassword()" class="text-[11px] font-bold uppercase text-zinc-900 hover:underline"><i class="fa-solid fa-wand-magic-sparkles mr-1"></i> Auto-Generate</button>
                        </div>
                        <div class="relative">
                            <input type="text" id="member-password" name="password" required placeholder="Enter or generate secure temporary password..." class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 font-mono focus:outline-none focus:border-zinc-900 transition-colors">
                        </div>
                    </div>

                    <!-- Assigned Role -->
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Sanctuary Role *</label>
                        <select id="member-role" name="role" required class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors cursor-pointer">
                            <option value="Research Fellow" selected>Research Fellow</option>
                            <option value="Senior Scholar">Senior Scholar</option>
                            <option value="Sanctuary Curator">Sanctuary Curator</option>
                            <option value="Archival Guest">Archival Guest</option>
                        </select>
                    </div>

                    <!-- Form Action Buttons -->
                    <div class="pt-4 flex flex-col sm:flex-row items-center gap-3">
                        <button type="button" onclick="closeAddMemberModal()" class="w-full sm:w-1/2 py-3 bg-zinc-100 text-zinc-700 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200 transition-all">
                            Cancel
                        </button>
                        <button type="submit" class="w-full sm:w-1/2 py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-sm">
                            Save Member
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Footer -->
        <footer class="bg-zinc-900 text-zinc-400 py-10 sm:py-12 border-t border-zinc-800 mt-16">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 flex flex-col md:flex-row items-center justify-between text-xs text-zinc-500 gap-4 text-center md:text-left">
                <p>&copy; 2026 Aurelia Library & Knowledge Sanctuary. Members Directory Active.</p>
                <div class="flex flex-wrap justify-center space-x-6">
                    <a href="index.html" class="hover:text-white transition-colors">Home Portal</a>
                    <a href="admin_categories.html" class="hover:text-white transition-colors">Categories</a>
                    <a href="admin_authors.html" class="hover:text-white transition-colors">Authors</a>
                </div>
            </div>
        </footer>
        <!-- Delete Confirmation Modal -->
<div id="delete-confirm-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
    <div class="bg-white rounded-3xl max-w-sm w-full p-6 sm:p-8 text-center shadow-2xl space-y-4">
        <div class="w-12 h-12 rounded-full bg-rose-100 text-rose-600 mx-auto flex items-center justify-center text-xl">
            <i class="fa-solid fa-triangle-exclamation"></i>
        </div>
        <h3 class="font-editorial text-2xl font-medium text-zinc-900">Confirm Deletion</h3>
        <p class="text-xs text-zinc-600 leading-relaxed">Are you sure you want to permanently remove this member?</p>
        <div class="flex items-center gap-3 pt-2">
            <button onclick="closeDeleteModal()" class="w-1/2 py-3 bg-zinc-100 text-zinc-700 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200 transition-all">
                Cancel
            </button>
            <button id="confirm-delete-btn" class="w-1/2 py-3 bg-rose-600 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-rose-700 transition-all shadow-sm">
                Delete
            </button>
        </div>
    </div>
</div>
        <!-- Notification / Action Modal -->
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
        <script src="${pageContext.request.contextPath}/js/adminNavJs.js"></script>
        <script src="${pageContext.request.contextPath}/js/member-listJs.js"></script>
    </body>
</html>
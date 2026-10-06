<%-- 
    Document   : authors-list
    Created on : 22 Sept 2026, 7:55:19 pm
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
    <title>AURELIA | Authors Management Directory</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Fonts: Playfair Display for editorial headings & Inter for body -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <!-- FontAwesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/adminNavCss.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/author-listCss.css">
    <script>
    window.contextPath = '${pageContext.request.contextPath}';
</script>
</head>
<body class="selection:bg-zinc-900 selection:text-zinc-100 overflow-x-hidden min-h-screen flex flex-col justify-between">

    <jsp:include page="/include/adminNav.jsp" />

    <main class="flex-grow max-w-7xl w-full mx-auto px-4 sm:px-6 py-8 sm:py-12 md:py-16">
        
        <!-- Authors Directory Management Section -->
        <div id="tab-authors" class="space-y-8">
            <div class="flex flex-col lg:flex-row lg:items-end justify-between gap-6 border-b border-zinc-200 pb-6">
                <div>
                    <p class="text-xs font-bold tracking-widest uppercase text-zinc-500">Scholarly Directory</p>
                    <h1 class="font-editorial text-2xl sm:text-3xl md:text-4xl font-normal text-zinc-900 uppercase mt-1">Authors Management</h1>
                </div>

                <!-- Controls Group: View Pill Toggle + Add Author Button Side-by-Side on all screens -->
                <div class="flex flex-row items-center justify-between sm:justify-start gap-2 sm:gap-3 w-full sm:w-auto">
                    <!-- View Toggle Buttons -->
                    <div class="inline-flex bg-zinc-100 p-1 rounded-full sm:p-1.5 border border-zinc-200 shrink-0">
                        <button onclick="setAuthorView('table')" id="view-btn-table" class="px-3 sm:px-4 py-2 rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase bg-white text-zinc-900 shadow-sm transition-all flex items-center gap-1.5 sm:gap-2">
                            <i class="fa-solid fa-table-list"></i> TABLE
                        </button>
                        <button onclick="setAuthorView('grid')" id="view-btn-grid" class="px-3 sm:px-4 py-2 rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase text-zinc-500 hover:text-zinc-900 transition-all flex items-center gap-1.5 sm:gap-2">
                            <i class="fa-solid fa-grip-vertical"></i> GRID
                        </button>
                    </div>

                    <!-- Add Author Button -->
                    <button onclick="openAddAuthorModal()" class="px-3 sm:px-6 py-2.5 sm:py-3 bg-zinc-900 text-white rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-sm flex items-center gap-1.5 sm:gap-2 shrink-0">
                        <i class="fa-solid fa-user-plus"></i> <span class="truncate">Add Author</span>
                    </button>
                </div>
            </div>

            <div class="bg-white border border-zinc-200 rounded-2xl p-4 sm:p-5 shadow-sm flex items-center space-x-3 w-full">
                <i class="fa-solid fa-magnifying-glass text-zinc-400"></i>
                <input type="text" id="admin-author-search" placeholder="Search authors by name, nationality, or specialization..." class="w-full bg-transparent text-xs sm:text-sm text-zinc-900 focus:outline-none">
            </div>

            <div id="authors-table-container" class="bg-white border border-zinc-200 rounded-3xl shadow-sm overflow-hidden">
                <div class="overflow-x-auto w-full">
                    <table class="w-full text-left border-collapse min-w-[700px]">
                        <thead>
                            <tr class="bg-zinc-50 border-b border-zinc-200 text-[11px] font-bold uppercase tracking-widest text-zinc-500">
                                <th class="p-4 sm:p-6">Author Full Name</th>
                                <th class="p-4 sm:p-6">Nationality</th>
                                <th class="p-4 sm:p-6">Specialization</th>
                                <th class="p-4 sm:p-6">Biography Summary</th>
                                <th class="p-4 sm:p-6 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="authors-table-body" class="divide-y divide-zinc-100 text-sm">
                            <!--<tr class="hover:bg-zinc-50/50 transition-colors">
                                <td class="p-4 sm:p-6 font-medium text-zinc-900 cursor-pointer hover:underline" onclick="fetchAuthorProfile('Immanuel Kant')">
                                    Immanuel Kant
                                </td>
                                <td class="p-4 sm:p-6 text-zinc-600 text-xs uppercase">German</td>
                                <td class="p-4 sm:p-6 text-zinc-600 text-xs uppercase">Philosophy / Epistemology</td>
                                <td class="p-4 sm:p-6 text-zinc-500 text-xs max-w-xs truncate">Central figure in modern philosophy, arguing that human mind creates structure of experience.</td>
                                <td class="p-4 sm:p-6 text-right space-x-2">
                                    <button onclick="fetchAuthorProfile('Immanuel Kant')" class="text-zinc-600 hover:text-zinc-900 p-2" title="View Profile"><i class="fa-solid fa-id-card"></i></button>
                                    <button onclick="deleteRow(this)" class="text-rose-600 hover:text-rose-800 p-2" title="Remove"><i class="fa-solid fa-trash-can"></i></button>
                                </td>
                            </tr>
                            <tr class="hover:bg-zinc-50/50 transition-colors">
                                <td class="p-4 sm:p-6 font-medium text-zinc-900 cursor-pointer hover:underline" onclick="fetchAuthorProfile('Brian Greene')">
                                    Brian Greene
                                </td>
                                <td class="p-4 sm:p-6 text-zinc-600 text-xs uppercase">American</td>
                                <td class="p-4 sm:p-6 text-zinc-600 text-xs uppercase">Theoretical Physics</td>
                                <td class="p-4 sm:p-6 text-zinc-500 text-xs max-w-xs truncate">Prominent string theorist and science communicator known for popularizing cosmology.</td>
                                <td class="p-4 sm:p-6 text-right space-x-2">
                                    <button onclick="fetchAuthorProfile('Brian Greene')" class="text-zinc-600 hover:text-zinc-900 p-2" title="View Profile"><i class="fa-solid fa-id-card"></i></button>
                                    <button onclick="deleteRow(this)" class="text-rose-600 hover:text-rose-800 p-2" title="Remove"><i class="fa-solid fa-trash-can"></i></button>
                                </td>
                            </tr>
                            <tr class="hover:bg-zinc-50/50 transition-colors">
                                <td class="p-4 sm:p-6 font-medium text-zinc-900 cursor-pointer hover:underline" onclick="fetchAuthorProfile('Kenneth Frampton')">
                                    Kenneth Frampton
                                </td>
                                <td class="p-4 sm:p-6 text-zinc-600 text-xs uppercase">British</td>
                                <td class="p-4 sm:p-6 text-zinc-600 text-xs uppercase">Architectural History</td>
                                <td class="p-4 sm:p-6 text-zinc-500 text-xs max-w-xs truncate">Renowned architect, historian, and critic specializing in modern architecture movements.</td>
                                <td class="p-4 sm:p-6 text-right space-x-2">
                                    <button onclick="fetchAuthorProfile('Kenneth Frampton')" class="text-zinc-600 hover:text-zinc-900 p-2" title="View Profile"><i class="fa-solid fa-id-card"></i></button>
                                    <button onclick="deleteRow(this)" class="text-rose-600 hover:text-rose-800 p-2" title="Remove"><i class="fa-solid fa-trash-can"></i></button>
                                </td>
                            </tr>-->
                        </tbody>
                    </table>
                </div>
            </div>

            <div id="authors-grid-container" class="hidden grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                <!-- Grid Card 1 -->
                <div class="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col justify-between hover:shadow-md transition-all">
                    <div class="space-y-3">
                        <div class="flex items-center justify-between">
                            <span class="px-3 py-1 bg-zinc-100 text-zinc-900 text-[10px] font-bold uppercase rounded-full">German</span>
                            <button onclick="deleteRow(this.closest('.bg-white'))" class="text-rose-500 hover:text-rose-700 text-xs"><i class="fa-solid fa-trash-can"></i></button>
                        </div>
                        <h3 class="font-editorial text-xl font-medium text-zinc-900">Immanuel Kant</h3>
                        <p class="text-xs font-semibold text-zinc-500 uppercase">Philosophy / Epistemology</p>
                        <p class="text-xs text-zinc-600 leading-relaxed">Central figure in modern philosophy, arguing that human mind creates structure of experience.</p>
                    </div>
                    <div class="pt-6 mt-6 border-t border-zinc-100 flex items-center justify-between">
                        <button onclick="fetchAuthorProfile('Immanuel Kant')" class="w-full py-2.5 bg-zinc-900 text-white rounded-full text-xs font-bold uppercase tracking-widest hover:bg-zinc-800 transition-all text-center">
                            View Profile
                        </button>
                    </div>
                </div>
                <!-- Grid Card 2 -->
                <div class="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col justify-between hover:shadow-md transition-all">
                    <div class="space-y-3">
                        <div class="flex items-center justify-between">
                            <span class="px-3 py-1 bg-zinc-100 text-zinc-900 text-[10px] font-bold uppercase rounded-full">American</span>
                            <button onclick="deleteRow(this.closest('.bg-white'))" class="text-rose-500 hover:text-rose-700 text-xs"><i class="fa-solid fa-trash-can"></i></button>
                        </div>
                        <h3 class="font-editorial text-xl font-medium text-zinc-900">Brian Greene</h3>
                        <p class="text-xs font-semibold text-zinc-500 uppercase">Theoretical Physics</p>
                        <p class="text-xs text-zinc-600 leading-relaxed">Prominent string theorist and science communicator known for popularizing cosmology.</p>
                    </div>
                    <div class="pt-6 mt-6 border-t border-zinc-100 flex items-center justify-between">
                        <button onclick="fetchAuthorProfile('Brian Greene')" class="w-full py-2.5 bg-zinc-900 text-white rounded-full text-xs font-bold uppercase tracking-widest hover:bg-zinc-800 transition-all text-center">
                            View Profile
                        </button>
                    </div>
                </div>
                <!-- Grid Card 3 -->
                <div class="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col justify-between hover:shadow-md transition-all">
                    <div class="space-y-3">
                        <div class="flex items-center justify-between">
                            <span class="px-3 py-1 bg-zinc-100 text-zinc-900 text-[10px] font-bold uppercase rounded-full">British</span>
                            <button onclick="deleteRow(this.closest('.bg-white'))" class="text-rose-500 hover:text-rose-700 text-xs"><i class="fa-solid fa-trash-can"></i></button>
                        </div>
                        <h3 class="font-editorial text-xl font-medium text-zinc-900">Kenneth Frampton</h3>
                        <p class="text-xs font-semibold text-zinc-500 uppercase">Architectural History</p>
                        <p class="text-xs text-zinc-600 leading-relaxed">Renowned architect, historian, and critic specializing in modern architecture movements.</p>
                    </div>
                    <div class="pt-6 mt-6 border-t border-zinc-100 flex items-center justify-between">
                        <button onclick="fetchAuthorProfile('Kenneth Frampton')" class="w-full py-2.5 bg-zinc-900 text-white rounded-full text-xs font-bold uppercase tracking-widest hover:bg-zinc-800 transition-all text-center">
                            View Profile
                        </button>
                    </div>
                </div>
            </div>
        </div>

    </main>

    <!-- Add New Author Modal Form -->
    <div id="add-author-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4 overflow-y-auto">
        <div class="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-8 shadow-2xl space-y-6 my-8">
            <div class="flex items-center justify-between border-b border-zinc-100 pb-4">
                <div>
                    <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Scholarly Registry</span>
                    <h3 class="font-editorial text-2xl font-medium text-zinc-900">Add New Author</h3>
                </div>
                <button onclick="closeAddAuthorModal()" class="text-zinc-400 hover:text-zinc-900 p-2">
                    <i class="fa-solid fa-xmark text-lg"></i>
                </button>
            </div>

            <form id="add-author-form" onsubmit="handleAuthorSubmit(event)" class="space-y-4">
    <!-- Author Full Name -->
    <div>
        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Author Full Name *</label>
        <input type="text" id="author-name" name="author-name" required 
               placeholder="e.g. Hannah Arendt" 
               class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
    </div>

    <!-- Nationality -->
    <div>
        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Nationality *</label>
        <input type="text" id="author-nationality" name="author-nationality" required 
               placeholder="e.g. German / American" 
               class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
    </div>

    <!-- Specialization Dropdown -->
    <div>
        <div class="flex items-center justify-between mb-1">
            <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700">Specialization Domain *</label>
            <span id="specialization-loading" class="text-[10px] text-zinc-400 italic">Loading via Servlet...</span>
        </div>
        <div class="relative">
            <select id="author-specialization" name="author-specialization" required 
                    class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors appearance-none cursor-pointer">
                <option value="" disabled selected>Select Scholarly Specialization...</option>
            </select>
            <div class="absolute inset-y-0 right-0 flex items-center px-4 pointer-events-none text-zinc-500">
                <i class="fa-solid fa-chevron-down text-xs"></i>
            </div>
        </div>
    </div>

    <!-- Biography / Summary -->
    <div>
        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Biography / Summary *</label>
        <textarea id="author-bio" name="author-bio" rows="4" required 
                  placeholder="Enter author's scholarly background and notable works..." 
                  class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors resize-none"></textarea>
    </div>

    <!-- Form Action Buttons -->
    <div class="pt-4 flex items-center space-x-3">
        <button type="button" onclick="closeAddAuthorModal()" 
                class="w-1/2 py-3 bg-zinc-100 text-zinc-700 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200 transition-all">
            Cancel
        </button>
        <button type="submit" 
                class="w-1/2 py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-sm">
            Save Author
        </button>
    </div>
</form>
        </div>
    </div>

    <!-- Author Profile Modal -->
    <div id="author-profile-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-md w-full p-6 sm:p-8 shadow-2xl space-y-6">
            <div class="flex items-center justify-between border-b border-zinc-100 pb-4">
                <div>
                    <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Database Record</span>
                    <h3 id="profile-modal-name" class="font-editorial text-2xl font-medium text-zinc-900">Author Profile</h3>
                </div>
                <button onclick="closeAuthorProfileModal()" class="text-zinc-400 hover:text-zinc-900 p-2">
                    <i class="fa-solid fa-xmark text-lg"></i>
                </button>
            </div>
            <div class="space-y-4 text-sm">
                <div>
                    <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block mb-1">Nationality</span>
                    <p id="profile-modal-nationality" class="text-zinc-900 font-medium"></p>
                </div>
                <div>
                    <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block mb-1">Specialization</span>
                    <p id="profile-modal-specialization" class="text-zinc-900 font-medium"></p>
                </div>
                <div>
                    <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 block mb-1">Biography & Scholarly Works</span>
                    <p id="profile-modal-bio" class="text-zinc-600 leading-relaxed bg-zinc-50 p-4 rounded-2xl border border-zinc-100"></p>
                </div>
            </div>
            <button onclick="closeAuthorProfileModal()" class="w-full py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all">
                Close Profile
            </button>
        </div>
    </div>
    <!-- Edit Author Modal -->
<div id="edit-author-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4 overflow-y-auto">
    <div class="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-8 shadow-2xl space-y-6 my-8">
        <div class="flex items-center justify-between border-b border-zinc-100 pb-4">
            <div>
                <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-500">Scholarly Registry</span>
                <h3 class="font-editorial text-2xl font-medium text-zinc-900">Edit Author</h3>
            </div>
            <button onclick="closeEditAuthorModal()" class="text-zinc-400 hover:text-zinc-900 p-2">
                <i class="fa-solid fa-xmark text-lg"></i>
            </button>
        </div>

        <form id="edit-author-form" onsubmit="handleAuthorUpdate(event)" class="space-y-4">
            <input type="hidden" id="edit-author-id">

            <div>
                <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Author Full Name *</label>
                <input type="text" id="edit-author-name" required 
                       class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm focus:outline-none focus:border-zinc-900">
            </div>

            <div>
                <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Nationality *</label>
                <input type="text" id="edit-author-nationality" required 
                       class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm focus:outline-none focus:border-zinc-900">
            </div>

            <div>
                <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Specialization *</label>
                <input type="text" id="edit-author-specialization" required 
                       class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm focus:outline-none focus:border-zinc-900">
            </div>

            <div>
                <label class="block text-xs font-bold uppercase tracking-wider text-zinc-700 mb-1">Biography *</label>
                <textarea id="edit-author-bio" rows="4" required 
                          class="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm focus:outline-none focus:border-zinc-900 resize-none"></textarea>
            </div>

            <div class="pt-4 flex items-center space-x-3">
                <button type="button" onclick="closeEditAuthorModal()" 
                        class="w-1/2 py-3 bg-zinc-100 text-zinc-700 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200">
                    Cancel
                </button>
                <button type="submit" 
                        class="w-1/2 py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800">
                    Update Author
                </button>
            </div>
        </form>
    </div>
</div>
    <!-- Footer -->
    <footer class="bg-zinc-900 text-zinc-400 py-12 border-t border-zinc-800 mt-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 flex flex-col md:flex-row items-center justify-between text-xs text-zinc-500 gap-4 text-center md:text-left">
            <p>&copy; 2026 Aurelia Library & Knowledge Sanctuary. Authors Management Directory Active.</p>
            <div class="flex flex-wrap justify-center space-x-6">
                <a href="index.html" class="hover:text-white transition-colors">Home Portal</a>
                <a href="profile.jsp" class="hover:text-white transition-colors">Admin Profile</a>
            </div>
        </div>
    </footer>

    <!-- Notification / Action Modal -->
<!-- Notification / Action Modal -->
<div id="notification-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
    <div class="bg-white rounded-3xl max-w-sm w-full p-6 sm:p-8 text-center shadow-2xl space-y-4">
        <div id="modal-icon-container" class="w-12 h-12 rounded-full bg-zinc-100 text-zinc-900 mx-auto flex items-center justify-center text-xl">
            <i id="modal-icon" class="fa-solid fa-circle-check"></i>
        </div>
        <h3 id="modal-title" class="font-editorial text-2xl font-medium text-zinc-900">Notice</h3>
        <p id="modal-message" class="text-xs text-zinc-600 leading-relaxed whitespace-pre-line"></p>
        
        <!-- Default Single Button (Dismiss) -->
        <div id="single-action-box">
            <button onclick="closeModal()" class="w-full py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all">
                Dismiss
            </button>
        </div>
        
        <!-- Dual Action Buttons (Cancel / Confirm) -->
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
<script src="${pageContext.request.contextPath}/js/author-listJs.js"></script>
    </body>
</html>

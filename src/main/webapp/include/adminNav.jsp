<%-- 
    Document   : adminNav
    Created on : 22 Sept 2026, 8:00:02 pm
    Author     : Suprakash
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
        <header class="w-full border-b border-zinc-200 bg-[#FBFBFA]/95 backdrop-blur-md sticky top-0 z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 h-20 md:h-24 flex items-center justify-between">
            
            <!-- Brand Logo & Subtitle -->
            <a href="<%= request.getContextPath()%>/admin/Admin-dashboard.jsp" class="font-editorial text-xl sm:text-2xl md:text-3xl lg:text-4xl tracking-wider font-bold text-zinc-900 uppercase truncate pr-2">
                AURELIA 
            </a>

            <!-- Desktop Admin Navigation Links -->
<nav class="hidden lg:flex items-center space-x-6 xl:space-x-8 text-xs font-semibold tracking-widest text-zinc-700 uppercase relative" id="desktop-nav">
    <span id="nav-indicator" class="absolute bottom-0 h-[2px] bg-zinc-900 transition-all duration-300 ease-out pointer-events-none" style="width: 0px; left: 0px;"></span>
    <a href="<%= request.getContextPath()%>/admin/Admin-dashboard.jsp" class="nav-link pb-1 transition-colors relative">Books</a>
    <a href="<%= request.getContextPath()%>/admin/authors/authors-list.jsp" class="nav-link pb-1 transition-colors relative">Authors</a>
    <a href="<%= request.getContextPath()%>/admin/categories/category-list.jsp" class="nav-link pb-1 transition-colors relative">Categories</a>
    <a href="<%= request.getContextPath()%>/admin/members/member-list.jsp" class="nav-link pb-1 transition-colors relative">Members</a>
    
    <!-- Issues Dropdown Menu for Desktop -->
    <div class="relative group py-2">
        <button class="nav-link pb-1 transition-colors relative flex items-center gap-1 uppercase bg-transparent border-none cursor-pointer focus:outline-none">
            Issues <i class="fa-solid fa-chevron-down text-[9px] transition-transform group-hover:rotate-180"></i>
        </button>
        <div class="absolute left-0 top-full pt-1 w-44 hidden group-hover:block z-50">
            <div class="bg-white border border-zinc-200 rounded-2xl shadow-xl py-2 flex flex-col">
                <a href="<%= request.getContextPath()%>/admin/issues/next.jsp" class="px-4 py-2.5 text-xs font-semibold tracking-wider text-zinc-700 hover:bg-zinc-100 hover:text-zinc-900 uppercase transition-colors">Issue Book</a>
                <a href="<%= request.getContextPath()%>/admin/issues/Book-Issue-Approve.jsp" class="px-4 py-2.5 text-xs font-semibold tracking-wider text-zinc-700 hover:bg-zinc-100 hover:text-zinc-900 uppercase transition-colors">Book Request</a>
            </div>
        </div>
    </div>

    <a href="#" class="nav-link pb-1 transition-colors relative">Reports</a>
</nav>

            <!-- Right Actions & Hamburger Button -->
            <div class="flex items-center space-x-2 sm:space-x-4">
                <a href="<%= request.getContextPath()%>/admin/Admin-dashboard.jsp" class="hidden sm:inline-flex items-center justify-center px-4 sm:px-5 py-2.5 border border-zinc-300 text-xs font-bold tracking-widest uppercase rounded-full hover:bg-zinc-900 hover:text-white transition-all whitespace-nowrap">
                    <span>Admin Profile</span>
                </a>
                <!-- Sign Out Button for Desktop -->
                <a href="<%= request.getContextPath()%>/logout" class="hidden sm:inline-flex items-center justify-center px-4 sm:px-5 py-2.5 border border-red-300 text-xs font-bold tracking-widest uppercase rounded-full text-red-600 hover:bg-red-600 hover:text-white transition-all whitespace-nowrap">
                    <span>Sign Out</span>
                </a>
                <button id="mobile-menu-btn" class="lg:hidden text-zinc-900 text-xl focus:outline-none p-2 rounded-xl hover:bg-zinc-100 transition-colors" aria-label="Toggle navigation menu">
    <i id="menu-icon" class="fa-solid fa-bars"></i>
</button>
            </div>
        </div>

<div id="mobile-menu" class="hidden lg:hidden bg-[#FBFBFA] border-b border-zinc-200 px-6 py-6 space-y-2 shadow-xl transition-all">
    <a href="<%= request.getContextPath()%>/admin/Admin-dashboard.jsp" class="mobile-nav-link block w-full text-left text-sm font-semibold tracking-wider text-zinc-700 uppercase py-2.5 px-3 rounded-xl border-l-2 border-transparent transition-all">Books Management</a>
    <a href="<%= request.getContextPath()%>/admin/authors/authors-list.jsp" class="mobile-nav-link block w-full text-left text-sm font-semibold tracking-wider text-zinc-700 uppercase py-2.5 px-3 rounded-xl border-l-2 border-transparent transition-all">Authors Directory</a>
    <a href="<%= request.getContextPath()%>/admin/categories/category-list.jsp" class="mobile-nav-link block w-full text-left text-sm font-semibold tracking-wider text-zinc-700 uppercase py-2.5 px-3 rounded-xl border-l-2 border-transparent transition-all">Categories</a>
    <a href="<%= request.getContextPath()%>/admin/members/member-list.jsp" class="mobile-nav-link block w-full text-left text-sm font-semibold tracking-wider text-zinc-700 uppercase py-2.5 px-3 rounded-xl border-l-2 border-transparent transition-all">Members Registry</a>
    
    <!-- Mobile Sub-links for Issues -->
    <div class="space-y-1 py-1">
        <span class="block w-full text-left text-xs font-bold tracking-wider text-zinc-400 uppercase px-3 pt-1">Circulation Issues</span>
        <a href="<%= request.getContextPath()%>/admin/issues/next.jsp" class="mobile-nav-link block w-full text-left text-sm font-semibold tracking-wider text-zinc-700 uppercase py-2 pl-6 pr-3 rounded-xl border-l-2 border-transparent transition-all">Issue Book</a>
        <a href="<%= request.getContextPath()%>/admin/issues/Book-Issue-Approve.jsp" class="mobile-nav-link block w-full text-left text-sm font-semibold tracking-wider text-zinc-700 uppercase py-2 pl-6 pr-3 rounded-xl border-l-2 border-transparent transition-all">Book Request</a>
    </div>

    <a href="#" class="mobile-nav-link block w-full text-left text-sm font-semibold tracking-wider text-zinc-700 uppercase py-2.5 px-3 rounded-xl border-l-2 border-transparent transition-all">Analytics Reports</a>
    <div class="pt-3 space-y-2">
        <a href="#" class="block w-full py-3 text-center border border-zinc-300 rounded-full text-xs font-bold tracking-widest uppercase bg-zinc-900 text-white shadow-sm">Admin Profile Settings</a>
        <!-- Sign Out Button for Mobile -->
        <a href="<%= request.getContextPath()%>/logout" class="block w-full py-3 text-center border border-red-300 rounded-full text-xs font-bold tracking-widest uppercase bg-red-600 text-white shadow-sm hover:bg-red-700 transition-all">Sign Out</a>
    </div>
</div>
    </header>
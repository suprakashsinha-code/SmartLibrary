<%-- 
    Document   : profile
    Created on : 22 Sept 2026, 7:59:39 pm
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
    <title>AURELIA | Member Profile & Settings</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Fonts: Playfair Display for editorial headings & Inter for body -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <!-- FontAwesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/profileCss.css">
    <script>
    window.contextPath = '${pageContext.request.contextPath}';
</script>   
    
</head>
<body class="selection:bg-zinc-900 selection:text-zinc-100 overflow-x-hidden min-h-screen flex flex-col justify-between">

    <!-- Header Navigation Matching Index & Repository -->
<header class="w-full border-b border-zinc-200 bg-[#FBFBFA]/95 backdrop-blur-md sticky top-0 z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 h-16 md:h-20 flex items-center justify-between gap-4">
            <a href="<%= request.getContextPath()%>/index.jsp" class="font-editorial text-lg sm:text-2xl tracking-wider font-bold text-zinc-900 uppercase flex items-center gap-2 shrink-0">
                <span>AURELIA</span>
                <span class="text-[9px] sm:text-xs font-sans tracking-normal font-normal text-zinc-500 uppercase border border-zinc-300 px-2 py-0.5 rounded-full">Member Portal</span>
            </a>

            <div class="hidden sm:flex items-center space-x-3 md:space-x-5">
                <a href="<%= request.getContextPath()%>/member/member-dashboard.jsp" class="inline-flex items-center justify-center px-4 py-1.5 border border-zinc-900 bg-zinc-900 text-white text-xs font-bold tracking-widest uppercase rounded-full hover:bg-zinc-800 transition-all"><span>Dashboard</span></a>
                <a href="<%= request.getContextPath()%>/member/catalog" class="inline-flex items-center justify-center px-4 py-1.5 border border-zinc-900 bg-zinc-900 text-white text-xs font-bold tracking-widest uppercase rounded-full hover:bg-zinc-800 transition-all"><span>Books</span></a>
                
                <a href="<%= request.getContextPath()%>/member/profile.jsp" class="flex items-center space-x-2.5 border-l border-zinc-200 pl-4 hover:opacity-80 transition-opacity">
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
                <a href="<%= request.getContextPath()%>/logout" class="inline-flex items-center justify-center px-4 py-1.5 border border-zinc-300 text-xs font-bold tracking-widest uppercase rounded-full hover:bg-zinc-900 hover:text-white transition-all"><span>Sign Out</span></a>
            </div>

            <button onclick="toggleMobileNav()" class="sm:hidden p-2 text-zinc-800 focus:outline-none" aria-label="Toggle navigation menu"><i id="mobile-nav-icon" class="fa-solid fa-bars text-lg"></i></button>
        </div>

        <div id="mobile-nav-drawer" class="hidden sm:hidden border-t border-zinc-200 bg-[#FBFBFA] px-4 py-4 space-y-4">
            <a href="<%= request.getContextPath()%>/member/profile.jsp" class="flex items-center space-x-3 pb-3 border-b border-zinc-100">
                <div class="w-9 h-9 rounded-full bg-zinc-900 text-white flex items-center justify-center font-bold text-xs shrink-0"><%= initials %></div>
                <div>
                    <p class="text-xs font-bold text-zinc-900"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Member" %></p>
                    <p class="text-[10px] text-zinc-500 uppercase tracking-widest"><%= "ADMIN".equals(session.getAttribute("userRole")) ? "Administrator" : "Member" %></p>
                </div>
            </a>
            <div class="flex flex-col space-y-2">
                <a href="<%= request.getContextPath()%>/member/member-dashboard.jsp" class="w-full text-center px-4 py-2.5 bg-zinc-900 text-white text-xs font-bold tracking-widest uppercase rounded-full">Dashboard</a>
                <a href="<%= request.getContextPath()%>/member/catalog" class="w-full text-center px-4 py-2.5 bg-zinc-900 text-white text-xs font-bold tracking-widest uppercase rounded-full">Books</a>
                <a href="<%= request.getContextPath()%>/logout" class="w-full text-center px-4 py-2.5 border border-zinc-300 text-xs font-bold tracking-widest uppercase rounded-full hover:bg-zinc-900 hover:text-white transition-all">Sign Out</a>
            </div>
        </div>
    </header>

    <!-- Main Content Area -->
    <main class="flex-grow max-w-5xl w-full mx-auto px-4 sm:px-6 py-8 sm:py-12 md:py-16">
        
        <!-- Header Section -->
        <div class="max-w-3xl mb-10 sm:mb-14 space-y-3">
            <p class="text-xs font-bold tracking-widest uppercase text-zinc-500">Member Account Management</p>
            <h1 class="font-editorial text-3xl sm:text-4xl md:text-5xl font-normal text-zinc-900 uppercase leading-tight">Profile & Credentials</h1>
            <p class="text-zinc-600 text-sm sm:text-base font-light leading-relaxed">
                Update your membership details, upload a profile portrait for your reader card, manage contact information, and secure your account credentials.
            </p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            
            <!-- Left Column: Profile Card & Picture Upload -->
            <div class="lg:col-span-1 space-y-6">
                <div class="bg-white border border-zinc-200 rounded-3xl p-6 sm:p-8 shadow-sm text-center space-y-6">
                    <!-- Avatar Container -->
                    <div class="relative w-32 h-32 mx-auto rounded-full overflow-hidden border-2 border-zinc-200 bg-zinc-100 shadow-inner group">
                        <img id="profile-avatar-preview" src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80" alt="Member Portrait" class="w-full h-full object-cover">
                        <div class="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center cursor-pointer" onclick="document.getElementById('avatar-file-input').click()">
                            <i class="fa-solid fa-camera text-white text-xl"></i>
                        </div>
                    </div>

                    <div>
                        <h2 id="display-member-name" class="font-editorial text-2xl font-bold text-zinc-900">Eleanor Vance</h2>
                        <p class="text-xs text-zinc-500 uppercase tracking-widest mt-1">Fellowship ID: #AUR-84920</p>
                        <span class="inline-block mt-3 px-3 py-1 bg-emerald-100 text-emerald-900 text-[10px] font-bold uppercase tracking-widest rounded-full">Active Subscriber</span>
                    </div>

                    <div class="border-t border-zinc-100 pt-6 text-left space-y-3">
                        <div class="flex items-center justify-between text-xs">
                            <span class="text-zinc-500">Member Since</span>
                            <span class="font-semibold text-zinc-900">September 2024</span>
                        </div>
                        <div class="flex items-center justify-between text-xs">
                            <span class="text-zinc-500">Active Loans</span>
                            <span class="font-semibold text-zinc-900">2 Volumes</span>
                        </div>
                        <div class="flex items-center justify-between text-xs">
                            <span class="text-zinc-500">Reading Room Access</span>
                            <span class="font-semibold text-emerald-700">Unlimited</span>
                        </div>
                    </div>

                    <!-- Hidden file input & trigger button -->
                    <input type="file" id="avatar-file-input" accept="image/*" class="hidden" onchange="handleAvatarUpload(event)">
                    <button onclick="document.getElementById('avatar-file-input').click()" class="w-full py-3 bg-zinc-100 text-zinc-900 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200 transition-all">
                        <i class="fa-solid fa-upload mr-2"></i> Upload New Photo
                    </button>
                </div>
            </div>

            <!-- Right Column: Edit Profile & Password Forms -->
            <div class="lg:col-span-2 space-y-8">
                
                <!-- Personal Information Form -->
                <div class="bg-white border border-zinc-200 rounded-3xl p-6 sm:p-8 shadow-sm space-y-6">
                    <div class="border-b border-zinc-200 pb-4 flex items-center space-x-3">
                        <div class="w-8 h-8 rounded-full bg-zinc-900 text-white flex items-center justify-center text-xs">
                            <i class="fa-solid fa-user"></i>
                        </div>
                        <h3 class="font-editorial text-xl font-bold text-zinc-900">Personal Information</h3>
                    </div>

                    <form id="personal-info-form" onsubmit="handleProfileUpdate(event)" class="space-y-4">
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <div class="space-y-2">
                                <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700">Full Name</label>
                                <input type="text" id="input-name" value="Eleanor Vance" required class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                            </div>
                            <div class="space-y-2">
                                <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700">Email Address</label>
                                <input type="email" id="input-email" value="eleanor.vance@aureliaportal.edu" required class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                            </div>
                        </div>

                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <div class="space-y-2">
                                <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700">Phone Number</label>
                                <input type="tel" id="input-phone" value="+1 (555) 382-9102" class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                            </div>
                            <div class="space-y-2">
                                <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700">Academic / Research Affiliation</label>
                                <input type="text" id="input-affil" value="Department of Comparative Philosophy" class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                            </div>
                        </div>

                        <div class="pt-4 flex justify-end">
                            <button type="submit" class="px-6 py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all">
                                Save Profile Changes
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Password Security Form -->
                <div class="bg-white border border-zinc-200 rounded-3xl p-6 sm:p-8 shadow-sm space-y-6">
                    <div class="border-b border-zinc-200 pb-4 flex items-center space-x-3">
                        <div class="w-8 h-8 rounded-full bg-zinc-900 text-white flex items-center justify-center text-xs">
                            <i class="fa-solid fa-lock"></i>
                        </div>
                        <h3 class="font-editorial text-xl font-bold text-zinc-900">Security & Credentials</h3>
                    </div>

                    <form id="security-form" onsubmit="handlePasswordChange(event)" class="space-y-4">
                        <div class="space-y-2">
                            <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700">Current Password</label>
                            <input type="password" id="current-password" placeholder="••••••••••••" required class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                        </div>

                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <div class="space-y-2">
                                <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700">New Password</label>
                                <input type="password" id="new-password" placeholder="••••••••••••" required class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                            </div>
                            <div class="space-y-2">
                                <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700">Confirm New Password</label>
                                <input type="password" id="confirm-password" placeholder="••••••••••••" required class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900 transition-colors">
                            </div>
                        </div>

                        <div class="pt-4 flex justify-end">
                            <button type="submit" class="px-6 py-3 border border-zinc-900 text-zinc-900 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-900 hover:text-white transition-all">
                                Update Password
                            </button>
                        </div>
                    </form>
                </div>

            </div>

        </div>

    </main>

    <!-- Footer -->
    <footer class="bg-zinc-900 text-zinc-400 py-12 border-t border-zinc-800 mt-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 flex flex-col md:flex-row items-center justify-between text-xs text-zinc-500 gap-4 text-center md:text-left">
            <p>&copy; 2026 Aurelia Library & Knowledge Sanctuary. Secure JPA Session Active.</p>
            <div class="flex flex-wrap justify-center space-x-6">
                <a href="index.html" class="hover:text-white transition-colors">Home Portal</a>
                <a href="books.jsp" class="hover:text-white transition-colors">Books Repository</a>
                <a href="dashboard.jsp" class="hover:text-white transition-colors">Member Dashboard</a>
            </div>
        </div>
    </footer>

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
    <script src="${pageContext.request.contextPath}/js/profileJS.js"></script>
    </body>
</html>

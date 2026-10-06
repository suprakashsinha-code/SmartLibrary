<%-- 
    Document   : index
    Created on : 22 Sept 2026, 7:10:32 pm
    Author     : Suprakash
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Jodi user already logged in thake, tahole take login page aaste dibe na, direct dashboard-e pathiye dibe
    if (session.getAttribute("userName") != null) {
        response.sendRedirect(request.getContextPath() + "/member-dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
    <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AURELIA | Library & Knowledge Sanctuary</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Fonts: Playfair Display for editorial headings & Inter for body -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <!-- FontAwesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/indexcss.css">
    <script>
    window.contextPath = '${pageContext.request.contextPath}';
</script>
</head>
<body class="selection:bg-zinc-900 selection:text-zinc-100">

    <!-- Top Navigation Header -->
    <header class="w-full border-b border-zinc-200 bg-[#FBFBFA]/90 backdrop-blur-md sticky top-0 z-50 transition-all duration-300">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 h-20 md:h-24 flex items-center justify-between">
            <!-- Brand Logo -->
            <a href="#" class="font-editorial text-2xl sm:text-3xl md:text-4xl tracking-wider font-bold text-zinc-900 uppercase">
                AURELIA
            </a>

            <!-- Desktop Menu Links -->
            <nav class="hidden lg:flex items-center space-x-8 text-xs font-semibold tracking-widest text-zinc-700 uppercase">
                <a href="#" class="hover:text-zinc-900 transition-colors">Catalog</a>
                <a href="#" class="hover:text-zinc-900 transition-colors">Rare Archives</a>
                <a href="#membership" class="hover:text-zinc-900 transition-colors">Membership</a>
                <a href="#spaces" class="hover:text-zinc-900 transition-colors">Reading Rooms</a>
                <a href="#journal" class="hover:text-zinc-900 transition-colors">Journal</a>
            </nav>

            <!-- Right Actions & Socials -->
            <div class="flex items-center space-x-4 sm:space-x-6">
                <div class="hidden sm:flex items-center space-x-4 text-zinc-700 text-sm">
                    <a href="#" class="hover:text-zinc-900 transition-colors"><i class="fa-brands fa-instagram"></i></a>
                    <a href="#" class="hover:text-zinc-900 transition-colors"><i class="fa-brands fa-facebook-f"></i></a>
                    <a href="#" class="hover:text-zinc-900 transition-colors"><i class="fa-solid fa-book-bookmark"></i></a>
                </div>
                <a href="#membership" class="relative group inline-flex items-center justify-center px-4 sm:px-6 py-2.5 sm:py-3 border border-zinc-900 text-xs font-bold tracking-widest uppercase overflow-hidden rounded-full transition-all duration-300 hover:bg-zinc-900 hover:text-white">
                    <span class="relative z-10">Member Login</span>
                </a>
                <!-- Mobile Menu Button -->
                <button id="mobile-menu-btn" class="lg:hidden text-zinc-900 text-xl focus:outline-none p-2">
                    <i class="fa-solid fa-bars"></i>
                </button>
            </div>
        </div>

        <!-- Mobile Drawer Menu -->
        <div id="mobile-menu" class="hidden lg:hidden bg-[#FBFBFA] border-b border-zinc-200 px-6 py-6 space-y-4 shadow-xl">
            <a href="#catalog" class="block text-sm font-semibold tracking-wider text-zinc-800 uppercase">Catalog</a>
            <a href="#archives" class="block text-sm font-semibold tracking-wider text-zinc-800 uppercase">Rare Archives</a>
            <a href="#membership" class="block text-sm font-semibold tracking-wider text-zinc-800 uppercase">Membership</a>
            <a href="#spaces" class="block text-sm font-semibold tracking-wider text-zinc-800 uppercase">Reading Rooms</a>
            <a href="#journal" class="block text-sm font-semibold tracking-wider text-zinc-800 uppercase">Journal</a>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="relative min-h-[85vh] flex flex-col items-center justify-center px-4 sm:px-6 pt-12 md:pt-16 pb-20 md:pb-24 overflow-hidden">
        
        <!-- Floating Thumbnail Images -->
        <div class="absolute top-6 md:top-12 left-2 md:left-[8%] lg:left-[12%] w-28 sm:w-36 md:w-40 h-36 sm:h-48 md:h-52 rounded-xl overflow-hidden shadow-2xl transform -rotate-6 transition-transform duration-500 hover:rotate-0 z-0 pointer-events-none opacity-90 md:opacity-100">
            <img src="https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=600&q=80" alt="Archive Volume 1" class="w-full h-full object-cover" onerror="this.src='https://placehold.co/400x520/2C2C2C/E5E5E5?text=Archive'">
        </div>

        <div class="absolute top-10 md:top-20 right-2 md:right-[8%] lg:right-[12%] w-32 sm:w-40 md:w-44 h-40 sm:h-52 md:h-56 rounded-xl overflow-hidden shadow-2xl transform rotate-6 transition-transform duration-500 hover:rotate-0 z-0 pointer-events-none opacity-90 md:opacity-100">
            <img src="https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=600&q=80" alt="Special Edition" class="w-full h-full object-cover" onerror="this.src='https://placehold.co/440x560/3A3A3A/E5E5E5?text=Special'">
        </div>

        <div class="absolute bottom-4 md:bottom-8 left-4 md:left-[15%] lg:left-[18%] hidden sm:block w-32 md:w-36 h-40 md:h-48 rounded-xl overflow-hidden shadow-2xl transform rotate-3 transition-transform duration-500 hover:rotate-0 z-0 pointer-events-none opacity-80 md:opacity-100">
            <img src="https://images.unsplash.com/photo-1457369804613-52c61a468e7d?auto=format&fit=crop&w=600&q=80" alt="Manuscripts" class="w-full h-full object-cover" onerror="this.src='https://placehold.co/360x480/4A4A4A/E5E5E5?text=Manuscripts'">
        </div>

        <div class="absolute bottom-6 md:bottom-12 right-4 md:right-[15%] lg:right-[18%] hidden sm:block w-32 md:w-40 h-40 md:h-48 rounded-xl overflow-hidden shadow-2xl transform -rotate-3 transition-transform duration-500 hover:rotate-0 z-0 pointer-events-none opacity-80 md:opacity-100">
            <img src="https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=600&q=80" alt="Modern Lit" class="w-full h-full object-cover" onerror="this.src='https://placehold.co/400x480/222222/E5E5E5?text=Modern'">
        </div>

        <!-- Central Hero Content -->
        <div class="text-center max-w-4xl mx-auto z-10 space-y-4 sm:space-y-6 px-2">
            <p class="font-editorial italic text-xl sm:text-2xl md:text-3xl text-zinc-600 tracking-wide">
                In the sanctuary of thought
            </p>
            <h1 class="font-editorial text-4xl sm:text-6xl md:text-7xl lg:text-8xl font-normal tracking-tight text-zinc-900 uppercase leading-[1.05]">
                Where knowledge<br>meets culture
            </h1>
            <p class="max-w-xl mx-auto text-zinc-600 text-sm sm:text-base md:text-lg font-light pt-2 sm:pt-4 leading-relaxed">
                Explore over 120,000 curated volumes, rare historic manuscripts, and immersive study environments tailored for scholars and curious minds.
            </p>

            <!-- Interactive Quick Search Bar -->
            <div class="pt-4 sm:pt-6 max-w-2xl mx-auto w-full">
                <div class="flex flex-col sm:flex-row items-center bg-white border border-zinc-300 rounded-3xl sm:rounded-full p-2 shadow-sm focus-within:border-zinc-900 transition-colors">
                    <div class="flex items-center px-4 w-full py-2 sm:py-0">
                        <i class="fa-solid fa-magnifying-glass text-zinc-400 mr-3 shrink-0"></i>
                        <input type="text" id="quick-search" placeholder="Search by title, author, ISBN, or subject..." class="w-full bg-transparent text-sm text-zinc-900 placeholder-zinc-400 focus:outline-none">
                    </div>
                    <button onclick="triggerSearch()" class="w-full sm:w-auto px-8 py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shrink-0 mt-2 sm:mt-0">
                        Find Book
                    </button>
                </div>
            </div>

            <!-- Centered Oval CTA Button -->
            <div class="pt-6 sm:pt-10">
                <a href="#catalog" class="inline-flex items-center justify-center px-8 sm:px-10 py-3.5 sm:py-4 border border-zinc-900 rounded-full text-xs font-bold tracking-widest uppercase text-zinc-900 transition-all duration-300 hover:bg-zinc-900 hover:text-white group">
                    <span>Explore Catalog</span>
                    <i class="fa-solid fa-arrow-right ml-3 transform group-hover:translate-x-1 transition-transform"></i>
                </a>
            </div>
        </div>
    </section>

    <!-- Live Library Statistics Ticker -->
    <section class="border-y border-zinc-200 bg-white py-10 sm:py-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 grid grid-cols-2 md:grid-cols-4 gap-6 sm:gap-8 text-center">
            <div class="space-y-1">
                <p class="font-editorial text-3xl sm:text-4xl md:text-5xl font-bold text-zinc-900">124,500</p>
                <p class="text-[10px] sm:text-xs font-semibold uppercase tracking-widest text-zinc-500">Cataloged Volumes</p>
            </div>
            <div class="space-y-1">
                <p class="font-editorial text-3xl sm:text-4xl md:text-5xl font-bold text-zinc-900">4,820</p>
                <p class="text-[10px] sm:text-xs font-semibold uppercase tracking-widest text-zinc-500">Active Researchers</p>
            </div>
            <div class="space-y-1">
                <p class="font-editorial text-3xl sm:text-4xl md:text-5xl font-bold text-zinc-900">350+</p>
                <p class="text-[10px] sm:text-xs font-semibold uppercase tracking-widest text-zinc-500">Rare Manuscripts</p>
            </div>
            <div class="space-y-1">
                <p class="font-editorial text-3xl sm:text-4xl md:text-5xl font-bold text-zinc-900">12</p>
                <p class="text-[10px] sm:text-xs font-semibold uppercase tracking-widest text-zinc-500">Reading Salons</p>
            </div>
        </div>
    </section>

    <!-- Curated Book Catalog Section -->
    <section id="catalog" class="py-16 sm:py-24 max-w-7xl mx-auto px-4 sm:px-6">
        <div class="flex flex-col md:flex-row md:items-end justify-between mb-12 sm:mb-16">
            <div>
                <p class="text-xs font-bold tracking-widest uppercase text-zinc-500 mb-2">Curated Collections</p>
                <h2 class="font-editorial text-3xl sm:text-4xl md:text-5xl font-normal text-zinc-900">Featured Acquisitions</h2>
            </div>
            <!-- Category Filter Tabs -->
            <div class="flex flex-wrap gap-2 sm:gap-3 mt-6 md:mt-0 text-xs font-semibold tracking-wider uppercase">
                <button onclick="filterBooks('all')" class="catalog-tab px-4 sm:px-5 py-2 sm:py-2.5 rounded-full bg-zinc-900 text-white transition-all shadow-sm">All Books</button>
                <button onclick="filterBooks('philosophy')" class="catalog-tab px-4 sm:px-5 py-2 sm:py-2.5 rounded-full bg-zinc-200 text-zinc-700 hover:bg-zinc-300 transition-all">Philosophy</button>
                <button onclick="filterBooks('science')" class="catalog-tab px-4 sm:px-5 py-2 sm:py-2.5 rounded-full bg-zinc-200 text-zinc-700 hover:bg-zinc-300 transition-all">Science</button>
                <button onclick="filterBooks('arts')" class="catalog-tab px-4 sm:px-5 py-2 sm:py-2.5 rounded-full bg-zinc-200 text-zinc-700 hover:bg-zinc-300 transition-all">Arts & Architecture</button>
            </div>
        </div>

        <!-- Book Grid -->
        <div id="book-grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 sm:gap-8">
            <!-- Book Item 1 -->
            <div class="book-card group cursor-pointer" data-category="philosophy">
                <div class="relative aspect-[3/4] bg-zinc-200 rounded-xl overflow-hidden shadow-md mb-4">
                    <img src="https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=600&q=80" alt="Critique of Pure Reason" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" onerror="this.src='https://placehold.co/600x800/1C1C1C/FBFBFA?text=Book'">
                    <span class="absolute top-3 left-3 bg-white/90 backdrop-blur-sm text-zinc-900 text-[10px] font-bold uppercase tracking-widest px-3 py-1 rounded-full shadow-sm">Available</span>
                </div>
                <p class="text-xs text-zinc-500 uppercase tracking-widest mb-1">Immanuel Kant</p>
                <h3 class="font-editorial text-lg sm:text-xl font-medium text-zinc-900 group-hover:underline">Critique of Pure Reason</h3>
                <p class="text-xs text-zinc-600 mt-1">Philosophy • Call # B2774 .E5 1998</p>
            </div>

            <!-- Book Item 2 -->
            <div class="book-card group cursor-pointer" data-category="science">
                <div class="relative aspect-[3/4] bg-zinc-200 rounded-xl overflow-hidden shadow-md mb-4">
                    <img src="https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&w=600&q=80" alt="The Fabric of Cosmos" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" onerror="this.src='https://placehold.co/600x800/2A2A2A/FBFBFA?text=Book'">
                    <span class="absolute top-3 left-3 bg-amber-100/90 backdrop-blur-sm text-amber-900 text-[10px] font-bold uppercase tracking-widest px-3 py-1 rounded-full shadow-sm">Checked Out</span>
                </div>
                <p class="text-xs text-zinc-500 uppercase tracking-widest mb-1">Brian Greene</p>
                <h3 class="font-editorial text-lg sm:text-xl font-medium text-zinc-900 group-hover:underline">The Fabric of the Cosmos</h3>
                <p class="text-xs text-zinc-600 mt-1">Physics • Call # QC16.2 .G74 2004</p>
            </div>

            <!-- Book Item 3 -->
            <div class="book-card group cursor-pointer" data-category="arts">
                <div class="relative aspect-[3/4] bg-zinc-200 rounded-xl overflow-hidden shadow-md mb-4">
                    <img src="https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&w=600&q=80" alt="Modern Architecture History" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" onerror="this.src='https://placehold.co/600x800/3A3A3A/FBFBFA?text=Book'">
                    <span class="absolute top-3 left-3 bg-white/90 backdrop-blur-sm text-zinc-900 text-[10px] font-bold uppercase tracking-widest px-3 py-1 rounded-full shadow-sm">Available</span>
                </div>
                <p class="text-xs text-zinc-500 uppercase tracking-widest mb-1">Kenneth Frampton</p>
                <h3 class="font-editorial text-lg sm:text-xl font-medium text-zinc-900 group-hover:underline">Modern Architecture: A Critical History</h3>
                <p class="text-xs text-zinc-600 mt-1">Architecture • Call # NA680 .F69 2007</p>
            </div>

            <!-- Book Item 4 -->
            <div class="book-card group cursor-pointer" data-category="philosophy">
                <div class="relative aspect-[3/4] bg-zinc-200 rounded-xl overflow-hidden shadow-md mb-4">
                    <img src="https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?auto=format&fit=crop&w=600&q=80" alt="Beyond Good and Evil" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" onerror="this.src='https://placehold.co/600x800/1F1F1F/FBFBFA?text=Book'">
                    <span class="absolute top-3 left-3 bg-white/90 backdrop-blur-sm text-zinc-900 text-[10px] font-bold uppercase tracking-widest px-3 py-1 rounded-full shadow-sm">Available</span>
                </div>
                <p class="text-xs text-zinc-500 uppercase tracking-widest mb-1">Friedrich Nietzsche</p>
                <h3 class="font-editorial text-lg sm:text-xl font-medium text-zinc-900 group-hover:underline">Beyond Good and Evil</h3>
                <p class="text-xs text-zinc-600 mt-1">Philosophy • Call # B3312 .E5 2002</p>
            </div>
        </div>
    </section>

    <!-- Rare Archives & Special Collections Spotlight -->
    <section id="archives" class="py-16 sm:py-24 bg-zinc-900 text-zinc-100 relative overflow-hidden">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-16 items-center">
            <div class="space-y-6">
                <p class="text-xs font-bold tracking-widest uppercase text-zinc-400">Vault & Special Collections</p>
                <h2 class="font-editorial text-3xl sm:text-4xl md:text-6xl font-normal leading-tight">Preserving Centuries of Written Heritage</h2>
                <p class="text-zinc-400 text-sm sm:text-base font-light leading-relaxed">
                    Our climate-controlled archive houses first-edition folios, illuminated medieval manuscripts, and cartographic treasures dating back to the 15th century. Access is granted to verified scholars and members by appointment.
                </p>
                <div class="pt-2 sm:pt-4 flex flex-wrap gap-4">
                    <a href="#membership" class="px-7 sm:px-8 py-3 sm:py-3.5 bg-white text-zinc-900 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-200 transition-all shadow-md">
                        Request Vault Access
                    </a>
                    <a href="#journal" class="px-7 sm:px-8 py-3 sm:py-3.5 border border-zinc-700 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:border-white transition-all">
                        View Exhibition Archive
                    </a>
                </div>
            </div>
            <div class="grid grid-cols-2 gap-4">
                <div class="space-y-4">
                    <div class="aspect-[4/5] rounded-xl overflow-hidden bg-zinc-800 shadow-xl">
                        <img src="https://images.unsplash.com/photo-1481627834876-b7833e8f5570?auto=format&fit=crop&w=600&q=80" alt="Folio Edition" class="w-full h-full object-cover hover:scale-105 transition-transform duration-500" onerror="this.src='https://placehold.co/400x500/2A2A2A/E5E5E5?text=Archive'">
                    </div>
                </div>
                <div class="space-y-4 pt-6 sm:pt-8">
                    <div class="aspect-[4/5] rounded-xl overflow-hidden bg-zinc-800 shadow-xl">
                        <img src="https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=600&q=80" alt="Cartography" class="w-full h-full object-cover hover:scale-105 transition-transform duration-500" onerror="this.src='https://placehold.co/400x500/3A3A3A/E5E5E5?text=Archive'">
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Reading Rooms & Facilities -->
    <section id="spaces" class="py-16 sm:py-24 max-w-7xl mx-auto px-4 sm:px-6">
        <div class="text-center max-w-2xl mx-auto mb-12 sm:mb-16">
            <p class="text-xs font-bold tracking-widest uppercase text-zinc-500 mb-2">Sanctuary Spaces</p>
            <h2 class="font-editorial text-3xl sm:text-4xl md:text-5xl font-normal text-zinc-900">Quiet Study & Research Salons</h2>
            <p class="text-zinc-600 text-sm mt-3">Designed for absolute focus, our study halls feature natural lighting, ergonomic workspaces, and direct access to reference terminals.</p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 sm:gap-8">
            <!-- Salon 1 -->
            <div class="bg-white border border-zinc-200 rounded-2xl p-6 sm:p-8 shadow-sm hover:shadow-md transition-shadow">
                <div class="text-3xl font-editorial text-zinc-900 mb-4">01</div>
                <h3 class="font-editorial text-xl sm:text-2xl font-medium text-zinc-900 mb-2">The Great Rotunda</h3>
                <p class="text-zinc-600 text-sm mb-6 leading-relaxed">Central silent reading room under our iconic glass dome. Equipped with individual study carrels and power docks.</p>
                <div class="flex items-center justify-between text-xs font-bold tracking-widest uppercase text-zinc-900 border-t border-zinc-100 pt-4">
                    <span>Capacity: 120 seats</span>
                    <span class="text-emerald-600">84 Available</span>
                </div>
            </div>

            <!-- Salon 2 -->
            <div class="bg-white border border-zinc-200 rounded-2xl p-6 sm:p-8 shadow-sm hover:shadow-md transition-shadow">
                <div class="text-3xl font-editorial text-zinc-900 mb-4">02</div>
                <h3 class="font-editorial text-xl sm:text-2xl font-medium text-zinc-900 mb-2">Manuscript Wing</h3>
                <p class="text-zinc-600 text-sm mb-6 leading-relaxed">Specialized lab with magnifying light tables and book cradles for secure handling of delicate historical folios.</p>
                <div class="flex items-center justify-between text-xs font-bold tracking-widest uppercase text-zinc-900 border-t border-zinc-100 pt-4">
                    <span>Capacity: 24 seats</span>
                    <span class="text-amber-600">6 Available</span>
                </div>
            </div>

            <!-- Salon 3 -->
            <div class="bg-white border border-zinc-200 rounded-2xl p-6 sm:p-8 shadow-sm hover:shadow-md transition-shadow">
                <div class="text-3xl font-editorial text-zinc-900 mb-4">03</div>
                <h3 class="font-editorial text-xl sm:text-2xl font-medium text-zinc-900 mb-2">Collaborative Hub</h3>
                <p class="text-zinc-600 text-sm mb-6 leading-relaxed">Acoustically treated seminar rooms for academic discussions, group projects, and research symposiums.</p>
                <div class="flex items-center justify-between text-xs font-bold tracking-widest uppercase text-zinc-900 border-t border-zinc-100 pt-4">
                    <span>Capacity: 8 rooms</span>
                    <span class="text-emerald-600">3 Available</span>
                </div>
            </div>
        </div>
    </section>

    <!-- Membership & Portal Access Section -->
    <section id="membership" class="py-16 sm:py-24 bg-zinc-100 border-t border-zinc-200">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 bg-white border border-zinc-200 rounded-3xl p-6 sm:p-12 md:p-16 shadow-xl">
            <div class="text-center max-w-xl mx-auto mb-10 sm:mb-12">
                <p class="text-xs font-bold tracking-widest uppercase text-zinc-500 mb-2">Library Portal</p>
                <h2 class="font-editorial text-2xl sm:text-3xl md:text-4xl font-normal text-zinc-900">Member Sign-In & Registration</h2>
                <p class="text-zinc-600 text-sm mt-2">Manage your borrowed titles, reserve study carrels, and track your research history.</p>
            </div>

            <!-- Tabs for Login / Register -->
            <div class="flex justify-center mb-8">
                <div class="bg-zinc-100 p-1.5 rounded-full inline-flex space-x-2 text-xs font-bold uppercase tracking-widest">
                    <button onclick="switchAuthTab('login')" id="btn-login-tab" class="px-5 sm:px-6 py-2.5 rounded-full bg-zinc-900 text-white transition-all shadow-sm">Sign In</button>
                    <button onclick="switchAuthTab('register')" id="btn-register-tab" class="px-5 sm:px-6 py-2.5 rounded-full text-zinc-700 hover:text-zinc-900 transition-all">Register Card</button>
                </div>
            </div>

            <!-- Login Form -->
            <form id="form-login" onsubmit="handleLogin(event)" class="space-y-6 max-w-md mx-auto">
                <div>
                    <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700 mb-2">Library Card / Email ID</label>
                    <input type="text" required placeholder="e.g. LIB-892401" class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900">
                </div>
                <div>
                    <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700 mb-2">Access PIN / Password</label>
                    <input type="password" required placeholder="••••••••" class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900">
                </div>
                <button type="submit" class="w-full py-4 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-lg">
                    Access Patron Dashboard
                </button>
            </form>

            <!-- Register Form with Real-Time Password Validation & Strength Indicators -->
            <form id="form-register" onsubmit="handleRegister(event)" class="space-y-5 max-w-md mx-auto hidden">
                <div>
                    <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700 mb-2">Full Legal Name *</label>
                    <input type="text" name="FullName" required placeholder="Dr. Eleanor Vance" class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900">
                </div>
                <div>
                    <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700 mb-2">Academic / Professional Email *</label>
                    <input type="email" required placeholder="eleanor.vance@university.edu" class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900">
                </div>
                <div>
                    <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700 mb-2">Password *</label>
                    <input type="password" id="reg-password" name="password" oninput="validatePasswordStrength()" required placeholder="••••••••" class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900">
                    
                    <!-- Real-time Password Guidelines & Requirements Checklist -->
                    <div class="mt-3 p-3 bg-zinc-50 border border-zinc-200 rounded-xl text-xs space-y-1.5 text-zinc-600">
                        <p class="font-bold text-zinc-700 mb-1">Password Security Requirements:</p>
                        <p id="req-length" class="flex items-center text-zinc-400"><i class="fa-solid fa-circle-xmark mr-2 text-zinc-400"></i> Minimum 8 characters</p>
                        <p id="req-upper" class="flex items-center text-zinc-400"><i class="fa-solid fa-circle-xmark mr-2 text-zinc-400"></i> At least one uppercase letter (A-Z)</p>
                        <p id="req-lower" class="flex items-center text-zinc-400"><i class="fa-solid fa-circle-xmark mr-2 text-zinc-400"></i> At least one lowercase letter (a-z)</p>
                        <p id="req-number" class="flex items-center text-zinc-400"><i class="fa-solid fa-circle-xmark mr-2 text-zinc-400"></i> At least one number (0-9)</p>
                        <p id="req-symbol" class="flex items-center text-zinc-400"><i class="fa-solid fa-circle-xmark mr-2 text-zinc-400"></i> At least one special symbol (!@#$%^&*)</p>
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700 mb-2">Confirm Password *</label>
                    <input type="password" id="reg-confirm-password" name="Confirmpassword" oninput="checkPasswordMatch()" required placeholder="••••••••" class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900">
                    <p id="match-error" class="text-xs text-rose-600 mt-1.5 hidden font-medium flex items-center">
                        <i class="fa-solid fa-triangle-exclamation mr-1.5"></i> Passwords do not match. Please ensure both fields are identical.
                    </p>
                </div>
                <div>
                    <label class="block text-xs font-bold uppercase tracking-widest text-zinc-700 mb-2">Membership Tier *</label>
                    <select name="role" class="w-full bg-zinc-50 border border-zinc-300 rounded-xl px-4 py-3 text-sm text-zinc-900 focus:outline-none focus:border-zinc-900">
                        <option value="MEMBER">Member</option>
        <option value="ADMIN">Admin</option>
                    </select>
                </div>
                <button type="submit" id="submit-reg-btn" class="w-full py-4 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-lg">
                    Request Library Card
                </button>
            </form>
        </div>
    </section>

    <!-- Footer Section -->
    <footer class="bg-zinc-900 text-zinc-400 py-16 border-t border-zinc-800">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 grid grid-cols-1 md:grid-cols-4 gap-10 sm:gap-12 mb-12">
            <div class="space-y-4">
                <span class="font-editorial text-3xl font-bold tracking-wider text-white uppercase">AURELIA</span>
                <p class="text-xs leading-relaxed text-zinc-400">A premier scholarly library and archive dedicated to preserving human knowledge and fostering rigorous intellectual discovery.</p>
            </div>
            <div>
                <h4 class="text-xs font-bold tracking-widest text-white uppercase mb-4">Navigation</h4>
                <ul class="space-y-2 text-xs font-medium">
                    <li><a href="#catalog" class="hover:text-white transition-colors">Catalog & Search</a></li>
                    <li><a href="#archives" class="hover:text-white transition-colors">Rare Archives</a></li>
                    <li><a href="#spaces" class="hover:text-white transition-colors">Reading Rooms</a></li>
                    <li><a href="#membership" class="hover:text-white transition-colors">Patron Membership</a></li>
                </ul>
            </div>
            <div>
                <h4 class="text-xs font-bold tracking-widest text-white uppercase mb-4">Opening Hours</h4>
                <ul class="space-y-2 text-xs font-medium">
                    <li>Monday – Friday: 08:00 – 22:00</li>
                    <li>Saturday: 09:00 – 20:00</li>
                    <li>Sunday: 10:00 – 18:00 (Quiet Study Only)</li>
                </ul>
            </div>
            <div>
                <h4 class="text-xs font-bold tracking-widest text-white uppercase mb-4">Location & Contact</h4>
                <p class="text-xs leading-relaxed">742 Knowledge Avenue, Academic Quarter, City Center</p>
                <p class="text-xs mt-2 text-white font-medium">inquiries@aurelia-library.edu</p>
            </div>
        </div>
        <div class="max-w-7xl mx-auto px-4 sm:px-6 border-t border-zinc-800 pt-8 flex flex-col sm:flex-row items-center justify-between text-xs text-zinc-500">
            <p>&copy; 2026 Aurelia Library & Knowledge Sanctuary. All rights reserved.</p>
            <div class="flex space-x-6 mt-4 sm:mt-0">
                <a href="#" class="hover:text-white transition-colors">Privacy Policy</a>
                <a href="#" class="hover:text-white transition-colors">Terms of Borrowing</a>
                <a href="#" class="hover:text-white transition-colors">Accessibility</a>
            </div>
        </div>
    </footer>

    <!-- Notification Modal Box -->
    <div id="notification-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-sm w-full p-6 text-center shadow-2xl space-y-4">
            <div id="modal-icon" class="w-12 h-12 rounded-full bg-zinc-100 text-zinc-900 mx-auto flex items-center justify-center text-xl">
                <i class="fa-solid fa-circle-check"></i>
            </div>
            <h3 id="modal-title" class="font-editorial text-2xl font-medium text-zinc-900">Notice</h3>
            <p id="modal-message" class="text-xs text-zinc-600 leading-relaxed"></p>
            <button onclick="closeModal()" class="w-full py-3 bg-zinc-900 text-white rounded-full text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all">
                Dismiss
            </button>
        </div>
    </div>
<script src="${pageContext.request.contextPath}/js/indexjs.js"></script>
    </body>
</html>

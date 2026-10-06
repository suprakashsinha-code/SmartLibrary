<%-- 
    Document   : next
    Created on : 4 Oct 2026, 6:41:06 pm
    Author     : Suprakash
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/adminNavCss.css">
    </head>
    <body>
                    <div class="flex flex-col lg:flex-row lg:items-end justify-between gap-6 border-b border-zinc-200 pb-6">
                <div>
                    <p class="text-xs font-bold tracking-widest uppercase text-zinc-500">Feature Will Be added Later</p>
                    <h1 class="font-editorial text-2xl sm:text-3xl md:text-4xl font-normal text-zinc-900 uppercase mt-1">Book Fine</h1>
                </div>

                <!-- Controls Group -->
                <div class="flex flex-row items-center justify-between sm:justify-start gap-2 sm:gap-3 w-full sm:w-auto">
                    <!-- Table / Grid Pill Toggle Controller -->
                    
                    <!-- Add New Volume Button -->
                    <button class="px-3 sm:px-6 py-2.5 sm:py-3 bg-zinc-900 text-white rounded-full text-[10px] sm:text-xs font-bold tracking-widest uppercase hover:bg-zinc-800 transition-all shadow-sm flex items-center gap-1.5 sm:gap-2 shrink-0">
                        <i class="fa-solid fa-plus"></i> <span class="truncate"><a href="<%= request.getContextPath()%>/admin/issues/Book-Issue-Approve.jsp">Add Volume</a></span>
                    </button>
                </div>
            </div>
    </body>
</html>

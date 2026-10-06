/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


        /*function toggleMobileMenu() {
            const mobileMenu = document.getElementById('mobile-menu');
            const menuIcon = document.getElementById('menu-icon');
            
            if (mobileMenu.classList.contains('hidden')) {
                mobileMenu.classList.remove('hidden');
                menuIcon.className = "fa-solid fa-xmark";
            } else {
                mobileMenu.classList.add('hidden');
                menuIcon.className = "fa-solid fa-bars";
            }
        }*/
document.addEventListener('DOMContentLoaded', () => {
    const nav = document.getElementById('desktop-nav');
    const indicator = document.getElementById('nav-indicator');
    const currentPath = window.location.pathname;

    // Desktop handling
    if (nav && indicator) {
        const links = nav.querySelectorAll('.nav-link');
        let activeLink = null;
        links.forEach(link => {
            const href = link.getAttribute('href');
            if (href && href !== '#' && currentPath.includes(href.split('/').pop())) {
                activeLink = link;
            }
        });

        if (activeLink) {
            activeLink.classList.add('text-zinc-900', 'font-bold');
        }

        const getTargetMetrics = (el) => {
            if (!el) return { left: 0, width: 0 };
            const navRect = nav.getBoundingClientRect();
            const linkRect = el.getBoundingClientRect();
            return {
                left: linkRect.left - navRect.left,
                width: linkRect.width
            };
        };

        const applyIndicator = (left, width, animate = true) => {
            indicator.style.transition = animate 
                ? 'left 350ms cubic-bezier(0.16, 1, 0.3, 1), width 350ms cubic-bezier(0.16, 1, 0.3, 1)' 
                : 'none';
            indicator.style.left = `${left}px`;
            indicator.style.width = `${width}px`;
        };

        if (activeLink) {
            const target = getTargetMetrics(activeLink);
            const storedPrev = sessionStorage.getItem('nav_indicator_pos');

            if (storedPrev) {
                const { left: prevLeft, width: prevWidth } = JSON.parse(storedPrev);
                applyIndicator(prevLeft, prevWidth, false);
                indicator.offsetHeight; // Force reflow
                requestAnimationFrame(() => {
                    applyIndicator(target.left, target.width, true);
                });
            } else {
                applyIndicator(target.left, target.width, false);
            }
            sessionStorage.setItem('nav_indicator_pos', JSON.stringify(target));
        } else {
            applyIndicator(0, 0, false);
            sessionStorage.removeItem('nav_indicator_pos');
        }

        window.addEventListener('resize', () => {
            if (activeLink) {
                const target = getTargetMetrics(activeLink);
                applyIndicator(target.left, target.width, false);
            }
        });
    }

    // Mobile menu active state handling
    const mobileLinks = document.querySelectorAll('.mobile-nav-link');
    mobileLinks.forEach(link => {
        const href = link.getAttribute('href');
        if (href && href !== '#' && currentPath.includes(href.split('/').pop())) {
            link.classList.remove('text-zinc-700', 'border-transparent');
            link.classList.add('text-zinc-900', 'font-bold', 'bg-zinc-100/80', 'border-zinc-900');
        }
    });
});
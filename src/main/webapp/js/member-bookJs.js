/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


 // Mobile Menu Toggle
        function toggleMobileNav() {
    const drawer = document.getElementById('mobile-nav-drawer');
    const icon = document.getElementById('mobile-nav-icon');
    if (drawer.classList.contains('hidden')) {
        drawer.classList.remove('hidden');
        icon.className = 'fa-solid fa-xmark text-lg';
    } else {
        drawer.classList.add('hidden');
        icon.className = 'fa-solid fa-bars text-lg';
    }
}

        let currentCategory = 'all';
        let currentLoanDays = 14; // Default loan period set to 14 days

        function setCategoryFilter(category) {
            currentCategory = category;
            const buttons = document.querySelectorAll('.cat-filter-btn');
            buttons.forEach(btn => {
                btn.classList.remove('bg-zinc-900', 'text-white');
                btn.classList.add('bg-zinc-100', 'text-zinc-700');
            });
            const activeBtn = document.getElementById('filter-btn-' + category);
            if (activeBtn) {
                activeBtn.classList.remove('bg-zinc-100', 'text-zinc-700');
                activeBtn.classList.add('bg-zinc-900', 'text-white');
            }

            filterCatalog();
        }

        function filterCatalog() {
            const searchInput = document.getElementById('catalog-search');
            const query = searchInput ? searchInput.value.toLowerCase().trim() : '';
            const items = document.querySelectorAll('.book-item');

            items.forEach(item => {
                const category = item.getAttribute('data-category');
                const titleText = item.getAttribute('data-title').toLowerCase();

                const matchesCategory = (currentCategory === 'all' || category === currentCategory);
                const matchesQuery = (titleText.includes(query) || query === '');

                if (matchesCategory && matchesQuery) {
                    item.style.display = 'flex';
                } else {
                    item.style.display = 'none';
                }
            });
        }

        // Admin Configuration Panel Functions
        function toggleAdminPanel() {
            const panel = document.getElementById('admin-panel');
            if (panel) {
                panel.classList.toggle('hidden');
            }
        }

        function setLoanDays(days) {
            currentLoanDays = days;
            document.getElementById('policy-days-display').innerText = days + (days === 1 ? ' day' : ' days');
            
            // Highlight preset buttons
            const btn7 = document.getElementById('preset-7');
            const btn14 = document.getElementById('preset-14');
            
            if (days === 7) {
                btn7.className = "py-3 px-4 rounded-xl border border-zinc-900 bg-zinc-900 text-white text-xs font-bold uppercase tracking-wider transition-all flex items-center justify-center space-x-2";
                btn14.className = "py-3 px-4 rounded-xl border border-zinc-300 text-xs font-bold uppercase tracking-wider text-zinc-800 hover:border-zinc-900 transition-all flex items-center justify-center space-x-2";
            } else if (days === 14) {
                btn14.className = "py-3 px-4 rounded-xl border border-zinc-900 bg-zinc-900 text-white text-xs font-bold uppercase tracking-wider transition-all flex items-center justify-center space-x-2";
                btn7.className = "py-3 px-4 rounded-xl border border-zinc-300 text-xs font-bold uppercase tracking-wider text-zinc-800 hover:border-zinc-900 transition-all flex items-center justify-center space-x-2";
            } else {
                btn7.className = "py-3 px-4 rounded-xl border border-zinc-300 text-xs font-bold uppercase tracking-wider text-zinc-800 hover:border-zinc-900 transition-all flex items-center justify-center space-x-2";
                btn14.className = "py-3 px-4 rounded-xl border border-zinc-300 text-xs font-bold uppercase tracking-wider text-zinc-800 hover:border-zinc-900 transition-all flex items-center justify-center space-x-2";
            }

            document.getElementById('custom-days-input').value = days;
            showModal("Circulation Policy Updated", `Admin successfully updated the standard return period to ${days} days for all new member checkouts.`);
        }

        function applyCustomDays() {
            const inputVal = parseInt(document.getElementById('custom-days-input').value);
            if (isNaN(inputVal) || inputVal < 1) {
                showModal("Invalid Duration", "Please enter a valid number of days greater than 0.");
                return;
            }
            setLoanDays(inputVal);
        }

function openBorrowModal(bookId, title, author) {
    const bookType = 'PHYSICAL'; 

    // pageContext-এর বদলে এখানে contextPath ব্যবহার করতে হবে
    fetch(`${contextPath}/api/borrow-request`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `bookId=${bookId}&bookType=${bookType}`
    })
    .then(response => response.json())
    .then(data => {
        if(data.status === 'success') {
            showModal("Request Submitted", `Your borrow request for "${title}" by ${author} has been sent to the Admin queue (Pending).`);
        } else {
            showModal("Error", data.message);
        }
    })
    .catch(error => {
        showModal("Error", "Failed to connect to server.");
    });
}
        function openReserveQueue(title) {
            showModal("Added to Hold Queue", `You have been added to the priority hold queue for "${title}". You will receive an email notification when the volume is returned.`);
        }

        function showModal(title, message) {
            document.getElementById('modal-title').innerText = title;
            document.getElementById('modal-message').innerText = message;
            document.getElementById('notification-modal').classList.remove('hidden');
        }

        function closeModal() {
            document.getElementById('notification-modal').classList.add('hidden');
        }
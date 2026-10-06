/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

        const mobileMenuBtn = document.getElementById('mobile-menu-btn');
    const mobileMenu = document.getElementById('mobile-menu');
    const menuIcon = document.getElementById('menu-icon');

    if (mobileMenuBtn && mobileMenu) {
        mobileMenuBtn.addEventListener('click', () => {
            mobileMenu.classList.toggle('hidden');
            if (menuIcon) {
                if (mobileMenu.classList.contains('hidden')) {
                    menuIcon.className = "fa-solid fa-bars";
                } else {
                    menuIcon.className = "fa-solid fa-xmark";
                }
            }
        });
    }
    renderBooks();
 window.addEventListener('DOMContentLoaded', () => {
            const urlParams = new URLSearchParams(window.location.search);
            const issueIdParam = urlParams.get('issueId') || urlParams.get('id');
            if (issueIdParam) {
                document.getElementById('query-issue-id').value = issueIdParam;
                loadIssueRecord(issueIdParam.toUpperCase());
            } else {
                loadIssueRecord('ISS-9012');
            }
        });

        function setDetailView(mode) {
            const tableContainer = document.getElementById('detail-table-container');
            const gridContainer = document.getElementById('detail-grid-container');
            const btnTable = document.getElementById('view-btn-table');
            const btnGrid = document.getElementById('view-btn-grid');

            if (mode === 'table') {
                tableContainer.classList.remove('hidden');
                gridContainer.classList.add('hidden');
                btnTable.className = 'px-3 sm:px-4 py-2 bg-white text-zinc-900 text-[11px] sm:text-xs font-bold uppercase rounded-full shadow-sm transition-all';
                btnGrid.className = 'px-3 sm:px-4 py-2 text-zinc-600 hover:text-zinc-900 text-[11px] sm:text-xs font-bold uppercase rounded-full transition-all';
            } else {
                tableContainer.classList.add('hidden');
                gridContainer.classList.remove('hidden');
                btnGrid.className = 'px-3 sm:px-4 py-2 bg-white text-zinc-900 text-[11px] sm:text-xs font-bold uppercase rounded-full shadow-sm transition-all';
                btnTable.className = 'px-3 sm:px-4 py-2 text-zinc-600 hover:text-zinc-900 text-[11px] sm:text-xs font-bold uppercase rounded-full transition-all';
            }
        }

        function handleQuerySubmit(event) {
            event.preventDefault();
            const id = document.getElementById('query-issue-id').value.trim();
            if (id) {
                loadIssueRecord(id.toUpperCase());
            }
        }

        async function loadIssueRecord(issueId) {
            await new Promise(resolve => setTimeout(resolve, 300));

            const mockDatabase = {
                'ISS-9012': {
                    id: 'ISS-9012',
                    category: 'Philosophy / Epistemology',
                    title: 'Critique of Pure Reason',
                    author: 'Immanuel Kant (ISBN: 978-0141)',
                    memberName: 'Eleanor Vance (MEM-1042)',
                    memberEmail: 'eleanor.vance@scholarly.org',
                    issueDate: 'Oct 12, 2026',
                    dueDate: 'Nov 02, 2026',
                    returnDate: 'Pending Return',
                    status: 'Due in 4 Days',
                    statusClass: 'px-3 py-1 bg-amber-50 text-amber-800 text-[10px] font-bold uppercase rounded-full border border-amber-200',
                    dueClass: 'text-rose-600',
                    fine: '$0.00 (On Schedule)'
                },
                'ISS-9015': {
                    id: 'ISS-9015',
                    category: 'Theoretical Physics',
                    title: 'Structure of Scientific Revolutions',
                    author: 'Thomas Kuhn (ISBN: 978-0226)',
                    memberName: 'Julian Sterling (MEM-2089)',
                    memberEmail: 'julian.sterling@oxford.edu',
                    issueDate: 'Oct 18, 2026',
                    dueDate: 'Nov 18, 2026',
                    returnDate: 'Pending Return',
                    status: 'On Time',
                    statusClass: 'px-3 py-1 bg-emerald-50 text-emerald-800 text-[10px] font-bold uppercase rounded-full border border-emerald-200',
                    dueClass: 'text-zinc-900',
                    fine: '$0.00 (On Schedule)'
                }
            };

            const record = mockDatabase[issueId] || {
                id: issueId,
                category: 'Scholarly Research',
                title: 'Advanced Research Monograph',
                author: 'Verified Author (ISBN: 978-0000)',
                memberName: 'Active Scholar (MEM-9999)',
                memberEmail: 'scholar@sanctuary.org',
                issueDate: 'Sep 01, 2026',
                dueDate: 'Oct 01, 2026',
                returnDate: 'Oct 05, 2026 (Returned Late)',
                status: 'Overdue / Returned',
                statusClass: 'px-3 py-1 bg-rose-50 text-rose-800 text-[10px] font-bold uppercase rounded-full border border-rose-200',
                dueClass: 'text-rose-600',
                fine: '$15.00 (4 Days Overdue)'
            };

            document.getElementById('dossier-header-title').innerText = `Record: ${record.id}`;
            document.getElementById('record-category').innerText = record.category;
            document.getElementById('record-status-badge').className = record.statusClass;
            document.getElementById('record-status-badge').innerText = record.status;
            document.getElementById('record-book-title').innerText = record.title;
            document.getElementById('record-author').innerText = `Author: ${record.author}`;
            document.getElementById('record-member-name').innerText = record.memberName;
            document.getElementById('record-member-email').innerText = record.memberEmail;
            document.getElementById('record-issue-date').innerText = record.issueDate;
            document.getElementById('record-due-date').innerText = record.dueDate;
            document.getElementById('record-due-date').className = record.dueClass;
            document.getElementById('record-return-date').innerText = record.returnDate;
            document.getElementById('record-fine-amount').innerText = record.fine;

            showActionNotice("Record Retrieved (GET)", `Successfully loaded circulation dossier ${record.id} from database repository.`);
        }

        async function calculateFineStatus() {
            await new Promise(resolve => setTimeout(resolve, 250));
            document.getElementById('record-fine-amount').innerText = "$5.00 (Calculated via GET Fine Engine)";
            showActionNotice("Fine Calculation Complete", "Fine calculation endpoint executed successfully. Rate applied: $1.25/day past due.");
        }

        function openReturnModal(issueId = 'ISS-9012') {
            document.getElementById('modal-issue-id').value = issueId;
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('modal-return-date').value = today;
            document.getElementById('return-modal').classList.remove('hidden');
        }

        function closeReturnModal() {
            document.getElementById('return-modal').classList.add('hidden');
        }

        function handleReturnFormSubmit(event) {
            event.preventDefault();
            const id = document.getElementById('modal-issue-id').value;
            const returnDate = document.getElementById('modal-return-date').value;
            
            closeReturnModal();
            document.getElementById('record-return-date').innerText = `${returnDate} (Returned & Settled)`;
            document.getElementById('record-fine-amount').innerText = "$0.00 (Paid in Full)";
            showActionNotice("Return & Fine Settled (POST)", `Circulation record ${id} successfully posted back to database with return date ${returnDate}.`);
        }

        function showActionNotice(title, message) {
            document.getElementById('modal-title').innerText = title;
            document.getElementById('modal-message').innerText = message;
            document.getElementById('notification-modal').classList.remove('hidden');
        }

        function closeModal() {
            document.getElementById('notification-modal').classList.add('hidden');
        }
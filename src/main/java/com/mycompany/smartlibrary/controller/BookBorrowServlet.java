/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.smartlibrary.controller;



import com.google.gson.Gson;
import com.mycompany.smartlibrary.config.HibernateUtil;
import com.mycompany.smartlibrary.model.Book;
import com.mycompany.smartlibrary.model.BookRequest;
import com.mycompany.smartlibrary.model.Member; // Member model import korte hobe
import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.hibernate.Session;
import org.hibernate.Transaction;

@WebServlet("/api/borrow-request")
public class BookBorrowServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write(gson.toJson(Map.of(
                "status", "error", 
                "message", "❌ Unauthorized. Please login first to borrow books."
            )));
            return;
        }

        // Session theke userId ba direct memberId niye asha
        int userId = (int) session.getAttribute("userId");

        String bookIdStr = req.getParameter("bookId");
        String bookTypeStr = req.getParameter("bookType"); // PHYSICAL or ONLINE

        try (Session dbSession = HibernateUtil.getSessionFactory().openSession()) {
            int bookId = Integer.parseInt(bookIdStr);

            // Find member_id corresponding to this user_id from members table
            Member member = dbSession.createQuery("FROM Member m WHERE m.userId = :userId", Member.class)
                    .setParameter("userId", userId)
                    .uniqueResult();

            if (member == null) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write(gson.toJson(Map.of(
                    "status", "error", 
                    "message", "❌ Member profile not found for this account."
                )));
                return;
            }

            int memberId = member.getMemberId();

            // 1. Check if the member already has an active request/loan for this book
            Long activeCount = dbSession.createQuery(
                "SELECT COUNT(r) FROM BookRequest r WHERE r.memberId = :memberId AND r.book.bookId = :bookId AND r.status IN (:statuses)", 
                Long.class)
                .setParameter("memberId", memberId)
                .setParameter("bookId", bookId)
                .setParameter("statuses", List.of(BookRequest.RequestStatus.PENDING, BookRequest.RequestStatus.APPROVED))
                .uniqueResult();

            if (activeCount != null && activeCount > 0) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write(gson.toJson(Map.of(
                    "status", "error", 
                    "message", "❌ Cannot borrow again while active. You already have an active request or loan for this book."
                )));
                return;
            }

            // 2. Proceed to create the borrow request if no active duplication exists
            Transaction tx = dbSession.beginTransaction();
            Book book = dbSession.get(Book.class, bookId);

            if (book != null) {
                BookRequest request = new BookRequest();
                request.setBook(book);
                request.setMemberId(memberId);
                request.setBookType(BookRequest.BookType.valueOf(bookTypeStr != null ? bookTypeStr.toUpperCase() : "PHYSICAL"));
                request.setStatus(BookRequest.RequestStatus.PENDING);

                dbSession.persist(request);
                tx.commit();

                resp.getWriter().write(gson.toJson(Map.of(
                    "status", "success", 
                    "message", "✅ Borrow request submitted successfully!"
                )));
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Book not found")));
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", e.getMessage())));
        }
    }
}
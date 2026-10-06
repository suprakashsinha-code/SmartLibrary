/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.smartlibrary.controller;





import com.google.gson.Gson;
import com.mycompany.smartlibrary.config.HibernateUtil;
import com.mycompany.smartlibrary.model.BookIssue;
import com.mycompany.smartlibrary.model.BookRequest;
import com.mycompany.smartlibrary.model.Member;
import org.hibernate.Session;
import org.hibernate.Transaction;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.Date;
import java.util.Map;

@WebServlet("/api/member/renew")
public class MemberRenewServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession httpSession = req.getSession(false);
        if (httpSession == null || httpSession.getAttribute("userId") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write(gson.toJson(Map.of(
                "status", "error",
                "message", "Please login first."
            )));
            return;
        }

        String issueIdStr = req.getParameter("issueId");
        if (issueIdStr == null || issueIdStr.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Issue ID missing.")));
            return;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = session.beginTransaction();

            // 1. First try to get memberId directly from session (most reliable)
            Integer memberId = null;
            Object midObj = httpSession.getAttribute("memberId");
            if (midObj != null) {
                if (midObj instanceof Integer) {
                    memberId = (Integer) midObj;
                } else if (midObj instanceof String) {
                    try { memberId = Integer.parseInt((String) midObj); } catch (Exception ignored) {}
                }
            }

            // 2. Fallback: find Member using userId
            if (memberId == null) {
                int userId = (int) httpSession.getAttribute("userId");
                Member member = session.createQuery("FROM Member m WHERE m.userId = :uid", Member.class)
                        .setParameter("uid", userId)
                        .uniqueResult();

                if (member != null) {
                    memberId = member.getMemberId();
                    // Optionally set it in session for future use
                    httpSession.setAttribute("memberId", memberId);
                }
            }

            if (memberId == null) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write(gson.toJson(Map.of(
                    "status", "error",
                    "message", "Member profile not found. Please contact admin or re-login."
                )));
                return;
            }

            int issueId = Integer.parseInt(issueIdStr);
            BookIssue issue = session.get(BookIssue.class, issueId);

            if (issue == null || !"ISSUED".equalsIgnoreCase(issue.getStatus())) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write(gson.toJson(Map.of(
                    "status", "error",
                    "message", "This book is not currently issued or already returned."
                )));
                return;
            }

            // Ownership check
            if (issue.getMember() == null || issue.getMember().getMemberId() != memberId) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                resp.getWriter().write(gson.toJson(Map.of(
                    "status", "error",
                    "message", "This loan does not belong to you."
                )));
                return;
            }

            // Check if already a pending request exists for this book
            Long pendingCount = session.createQuery(
                "SELECT COUNT(r) FROM BookRequest r WHERE r.memberId = :mid AND r.book.bookId = :bid AND r.status = 'PENDING'",
                Long.class)
                .setParameter("mid", memberId)
                .setParameter("bid", issue.getBook().getBookId())
                .uniqueResult();

            if (pendingCount != null && pendingCount > 0) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write(gson.toJson(Map.of(
                    "status", "error",
                    "message", "You already have a pending request for this book."
                )));
                return;
            }

            // Create Renewal Request
            BookRequest renewReq = new BookRequest();
            renewReq.setBook(issue.getBook());
            renewReq.setMemberId(memberId);
            renewReq.setBookType(BookRequest.BookType.PHYSICAL);
            renewReq.setStatus(BookRequest.RequestStatus.PENDING);
            renewReq.setRequestDate(new Date());
            renewReq.setAdminRemark("RENEWAL_REQUEST for Issue#" + issueId);

            session.persist(renewReq);
            tx.commit();

            resp.getWriter().write(gson.toJson(Map.of(
                "status", "success",
                "message", "Renewal request submitted successfully! Waiting for admin approval."
            )));

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write(gson.toJson(Map.of(
                "status", "error",
                "message", e.getMessage() != null ? e.getMessage() : "Server error"
            )));
        }
    }
}
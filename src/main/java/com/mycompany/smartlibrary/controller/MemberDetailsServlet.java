/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.smartlibrary.controller;

import com.google.gson.Gson;
import com.mycompany.smartlibrary.config.HibernateUtil;
import com.mycompany.smartlibrary.model.*;

import org.hibernate.Session;
import java.io.IOException;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/api/member-details")
public class MemberDetailsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.getWriter().write("{\"error\": \"Missing member id\"}");
            return;
        }

        int memberId;
        try {
            memberId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"error\": \"Invalid member id format\"}");
            return;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            // 1. Member + User
            String memberQuery = """
                SELECT m, u FROM Member m, User u
                WHERE m.userId = u.id AND m.memberId = :memberId
                """;
            Object[] result = session.createQuery(memberQuery, Object[].class)
                    .setParameter("memberId", memberId)
                    .uniqueResult();

            if (result == null) {
                response.getWriter().write("{\"error\": \"Member not found\"}");
                return;
            }

            Member member = (Member) result[0];
            User user = (User) result[1];

            // 2. Active / Overdue books
            String activeQuery = """
                SELECT bi, b FROM BookIssue bi
                JOIN bi.book b
                WHERE bi.member.memberId = :memberId
                AND bi.status IN ('ISSUED', 'OVERDUE')
                """;
            List<Object[]> activeList = session.createQuery(activeQuery, Object[].class)
                    .setParameter("memberId", memberId)
                    .getResultList();

            List<Map<String, Object>> activeBooks = new ArrayList<>();
            for (Object[] row : activeList) {
                BookIssue bi = (BookIssue) row[0];
                Book b = (Book) row[1];

                Map<String, Object> bMap = new HashMap<>();
                bMap.put("title", b.getTitle());
                bMap.put("author", b.getAuthor() != null ? b.getAuthor().getFullName() : "Unknown");
                bMap.put("isbn", b.getIsbn());
                bMap.put("issueDate", bi.getIssueDate().toString());
                bMap.put("dueDate", bi.getDueDate().toString());
                bMap.put("status", bi.getStatus());
                activeBooks.add(bMap);
            }

            // 3. History (Returned) + Fine
            String historyQuery = """
                SELECT bi, b, f FROM BookIssue bi
                JOIN bi.book b
                LEFT JOIN Fine f ON f.bookIssue.issueId = bi.issueId
                WHERE bi.member.memberId = :memberId
                AND bi.status = 'RETURNED'
                ORDER BY bi.returnDate DESC
                """;
            List<Object[]> historyList = session.createQuery(historyQuery, Object[].class)
                    .setParameter("memberId", memberId)
                    .getResultList();

            List<Map<String, Object>> historyBooks = new ArrayList<>();
            for (Object[] row : historyList) {
                BookIssue bi = (BookIssue) row[0];
                Book b = (Book) row[1];
                Fine f = (Fine) row[2];

                Map<String, Object> hMap = new HashMap<>();
                hMap.put("title", b.getTitle());
                hMap.put("author", b.getAuthor() != null ? b.getAuthor().getFullName() : "Unknown");
                hMap.put("borrowed", bi.getIssueDate().toString());
                hMap.put("returned", bi.getReturnDate() != null ? bi.getReturnDate().toString() : "N/A");

                double fineAmount = (f != null && f.getAmount() != null)
                        ? f.getAmount().doubleValue() : 0.0;

                if (fineAmount > 0) {
                    hMap.put("status", "Late Return ($" + String.format("%.2f", fineAmount) + ")");
                    hMap.put("badgeClass", "bg-amber-50 text-amber-800 border-amber-200");
                } else {
                    hMap.put("status", "Returned ($0.00)");
                    hMap.put("badgeClass", "bg-emerald-50 text-emerald-800 border-emerald-200");
                }
                historyBooks.add(hMap);
            }

            // Response
            Map<String, Object> data = new HashMap<>();
            data.put("memberId", "MEM-" + member.getMemberId());
            data.put("name", user.getName());
            data.put("email", user.getEmail());
            data.put("phone", member.getPhone() != null ? member.getPhone() : "Not Provided");
            data.put("address", member.getAddress() != null ? member.getAddress() : "Not Provided");
            data.put("membershipType", member.getMembershipType());
            data.put("membershipDate", member.getMembershipDate().toString());
            data.put("status", user.getStatus().toString());
            data.put("activeBooks", activeBooks);
            data.put("historyBooks", historyBooks);

            response.getWriter().write(new Gson().toJson(data));

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\": \"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }
}
package com.mycompany.smartlibrary.controller;

import com.mycompany.smartlibrary.config.HibernateUtil;
import com.mycompany.smartlibrary.model.BookIssue;
import org.hibernate.Session;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "MemberHistoryServlet", urlPatterns = {"/api/member/history"})
public class MemberHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Integer memberId = (session != null) ? (Integer) session.getAttribute("memberId") : null;

        if (memberId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("[]");
            return;
        }

        try (Session hibernateSession = HibernateUtil.getSessionFactory().openSession()) {
            // Fetching returned/archived book issues for the specific member
            List<BookIssue> historyLoans = hibernateSession.createQuery(
                "FROM BookIssue bi JOIN FETCH bi.book b JOIN FETCH b.author WHERE bi.member.memberId = :memberId AND bi.status = 'RETURNED'", 
                BookIssue.class)
                .setParameter("memberId", memberId)
                .list();

            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < historyLoans.size(); i++) {
                BookIssue bi = historyLoans.get(i);
                json.append("{");
                json.append("\"issueId\":").append(bi.getIssueId()).append(",");
                json.append("\"title\":\"").append(escape(bi.getBook().getTitle())).append("\",");
                json.append("\"author\":\"").append(escape(bi.getBook().getAuthor() != null ? bi.getBook().getAuthor().getFullName() : "Unknown")).append("\",");
                json.append("\"callNo\":\"").append(escape(bi.getBook().getIsbn())).append("\",");
                json.append("\"issueDate\":\"").append(bi.getIssueDate()).append("\",");
                json.append("\"returnDate\":\"").append(bi.getReturnDate() != null ? bi.getReturnDate().toString() : "N/A").append("\",");
                json.append("\"status\":\"").append(escape(bi.getStatus())).append("\",");
                json.append("\"fineAmount\":0.00,"); // Default fine amount or connect with Fine entity if implemented
                json.append("\"img\":\"https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=300&q=80\"");
                json.append("}");
                if (i < historyLoans.size() - 1) json.append(",");
            }
            json.append("]");

            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(json.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("[]");
        }
    }

    private String escape(String str) {
        return str == null ? "" : str.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
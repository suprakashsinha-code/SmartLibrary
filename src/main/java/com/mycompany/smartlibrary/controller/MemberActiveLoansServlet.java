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

@WebServlet(name = "MemberActiveLoansServlet", urlPatterns = {"/api/member/loans"})
public class MemberActiveLoansServlet extends HttpServlet {

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
            List<BookIssue> activeLoans = hibernateSession.createQuery(
                "FROM BookIssue bi JOIN FETCH bi.book b JOIN FETCH b.author WHERE bi.member.memberId = :memberId AND (bi.status = 'ISSUED' OR bi.status = 'OVERDUE')", 
                BookIssue.class)
                .setParameter("memberId", memberId)
                .list();

            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < activeLoans.size(); i++) {
                BookIssue bi = activeLoans.get(i);
                json.append("{");
                json.append("\"issueId\":").append(bi.getIssueId()).append(",");
                json.append("\"title\":\"").append(escape(bi.getBook().getTitle())).append("\",");
                json.append("\"author\":\"").append(escape(bi.getBook().getAuthor() != null ? bi.getBook().getAuthor().getFullName() : "Unknown")).append("\",");
                json.append("\"callNo\":\"").append(escape(bi.getBook().getIsbn())).append("\",");
                json.append("\"issueDate\":\"").append(bi.getIssueDate()).append("\",");
                json.append("\"dueDate\":\"").append(bi.getDueDate()).append("\",");
                json.append("\"status\":\"").append(bi.getStatus()).append("\",");
                json.append("\"img\":\"https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=300&q=80\"");
                json.append("}");
                if (i < activeLoans.size() - 1) json.append(",");
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
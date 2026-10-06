package com.mycompany.smartlibrary.controller;

import com.mycompany.smartlibrary.dao.BookRequestDAO;
import com.mycompany.smartlibrary.model.BookRequest;
import com.mycompany.smartlibrary.model.BookIssue;
import com.mycompany.smartlibrary.config.HibernateUtil;
import org.hibernate.Session;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "GetCirculationDataServlet", urlPatterns = {"/admin/get-circulation-data"})
public class GetCirculationDataServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            BookRequestDAO dao = new BookRequestDAO();
            
            // Updated here: fetching both PENDING and APPROVED requests
            List<BookRequest> activeRequests = dao.getActiveRequests();
            
            List<BookIssue> issuedBooks = session.createQuery(
                    "FROM BookIssue bi JOIN FETCH bi.book JOIN FETCH bi.member WHERE bi.status = 'ISSUED'", 
                    BookIssue.class).list();
            
            List<BookIssue> overdueBooks = session.createQuery(
                    "FROM BookIssue bi JOIN FETCH bi.book JOIN FETCH bi.member WHERE bi.status = 'OVERDUE' OR (bi.status = 'ISSUED' AND bi.dueDate < CURRENT_DATE)", 
                    BookIssue.class).list();
            
            List<BookIssue> historyBooks = session.createQuery(
                    "FROM BookIssue bi JOIN FETCH bi.book JOIN FETCH bi.member WHERE bi.status = 'RETURNED'", 
                    BookIssue.class).list();

            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"requests\":").append(convertRequestsToJson(activeRequests)).append(",");
            json.append("\"issued\":").append(convertIssuesToJson(issuedBooks)).append(",");
            json.append("\"overdue\":").append(convertIssuesToJson(overdueBooks)).append(",");
            json.append("\"history\":").append(convertIssuesToJson(historyBooks));
            json.append("}");

            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(json.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"status\":\"error\", \"message\":\"" + e.getMessage() + "\"}");
        }
    }

private String convertRequestsToJson(List<BookRequest> list) {
    StringBuilder sb = new StringBuilder("[");
    for (int i = 0; i < list.size(); i++) {
        BookRequest r = list.get(i);
        sb.append("{");
        sb.append("\"id\":\"REQ-").append(r.getRequestId()).append("\",");
        sb.append("\"requestId\":").append(r.getRequestId()).append(",");
        sb.append("\"book\":\"").append(escape(r.getBook() != null ? r.getBook().getTitle() : "Unknown")).append("\",");
        sb.append("\"member\":\"").append("Member-").append(r.getMemberId()).append("\",");  
        sb.append("\"memberId\":\"MEM-").append(r.getMemberId()).append("\",");
        sb.append("\"type\":\"").append(r.getBookType() != null ? r.getBookType().name() : "PHYSICAL").append("\",");
        sb.append("\"requested\":\"").append(r.getRequestDate() != null ? r.getRequestDate().toString() : "").append("\",");
        sb.append("\"status\":\"").append(r.getStatus()).append("\",");
        sb.append("\"isbn\":\"").append(escape(r.getBook() != null ? r.getBook().getIsbn() : "")).append("\"");
        sb.append("}");
        if (i < list.size() - 1) sb.append(",");
    }
    sb.append("]");
    return sb.toString();
}

private String convertIssuesToJson(List<BookIssue> list) {
    StringBuilder sb = new StringBuilder("[");
    for (int i = 0; i < list.size(); i++) {
        BookIssue bi = list.get(i);
        sb.append("{");
        sb.append("\"id\":\"ISS-").append(bi.getIssueId()).append("\",");
        sb.append("\"issueId\":").append(bi.getIssueId()).append(",");
        sb.append("\"book\":\"").append(escape(bi.getBook() != null ? bi.getBook().getTitle() : "Unknown")).append("\",");
        sb.append("\"member\":\"").append(bi.getMember() != null ? "Member-" + bi.getMember().getMemberId() : "Unknown").append("\",");
        sb.append("\"memberId\":\"MEM-").append(bi.getMember() != null ? bi.getMember().getMemberId() : 0).append("\",");
        sb.append("\"type\":\"Physical\",");
        sb.append("\"issueDate\":\"").append(bi.getIssueDate() != null ? bi.getIssueDate().toString() : "").append("\",");
        sb.append("\"dueDate\":\"").append(bi.getDueDate() != null ? bi.getDueDate().toString() : "").append("\",");
        sb.append("\"status\":\"").append(bi.getStatus()).append("\"");
        sb.append("}");
        if (i < list.size() - 1) sb.append(",");
    }
    sb.append("]");
    return sb.toString();
}
    private String escape(String str) {
        return str == null ? "" : str.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
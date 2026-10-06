/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.smartlibrary.controller;




import com.google.gson.Gson;
import com.mycompany.smartlibrary.config.HibernateUtil;
import com.mycompany.smartlibrary.model.BookRequest;
import com.mycompany.smartlibrary.model.Member;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.hibernate.Session;

@WebServlet("/api/member/requests")
public class MemberRequestsServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Unauthorized")));
            return;
        }

        int userId = (int) session.getAttribute("userId");

        try (Session dbSession = HibernateUtil.getSessionFactory().openSession()) {
            Member member = dbSession.createQuery("FROM Member m WHERE m.userId = :userId", Member.class)
                    .setParameter("userId", userId)
                    .uniqueResult();

            if (member == null) {
                resp.getWriter().write(gson.toJson(List.of()));
                return;
            }

            List<BookRequest> requests = dbSession.createQuery(
                "FROM BookRequest r JOIN FETCH r.book b JOIN FETCH b.author WHERE r.memberId = :memberId ORDER BY r.requestId DESC", BookRequest.class)
                .setParameter("memberId", member.getMemberId())
                .getResultList();

            SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");

            List<Map<String, Object>> responseList = requests.stream().map(reqItem -> Map.of(
                "id", (Object) reqItem.getRequestId(),
                "title", reqItem.getBook() != null ? reqItem.getBook().getTitle() : "Unknown Book",
                "author", (reqItem.getBook() != null && reqItem.getBook().getAuthor() != null) ? reqItem.getBook().getAuthor().getFullName() : "Unknown Author",
                "requestedOn", reqItem.getRequestDate() != null ? sdf.format(reqItem.getRequestDate()) : "",
                "status", reqItem.getStatus().name(),
                "img", "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=300&q=80"
            )).collect(Collectors.toList());

            resp.getWriter().write(gson.toJson(responseList));

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", e.getMessage())));
        }
    }
}
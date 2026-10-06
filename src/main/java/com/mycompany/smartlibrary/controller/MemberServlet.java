/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.smartlibrary.controller;




import com.google.gson.Gson;
import com.mycompany.smartlibrary.config.HibernateUtil;
import com.mycompany.smartlibrary.model.Member;
import com.mycompany.smartlibrary.model.User;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.io.IOException;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "MemberServlet", urlPatterns = {"/api/members"})
public class MemberServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            List<Object[]> results = session.createQuery(
                "SELECT m, u FROM Member m, User u WHERE m.userId = u.id ORDER BY m.memberId DESC",
                Object[].class
            ).list();

            List<Map<String, Object>> list = new ArrayList<>();
            for (Object[] row : results) {
                Member m = (Member) row[0];
                User u = (User) row[1];

                Map<String, Object> map = new LinkedHashMap<>();
                map.put("memberId", m.getMemberId());
                map.put("userId", m.getUserId());
                map.put("name", u.getName());
                map.put("email", u.getEmail());
                map.put("phone", m.getPhone() != null ? m.getPhone() : "Not Provided");
                map.put("membershipType", m.getMembershipType());
                map.put("role", u.getRole().name());
                map.put("status", u.getStatus().name());
                map.put("membershipDate", m.getMembershipDate() != null ? m.getMembershipDate().toString() : "");

                list.add(map);
            }

            resp.getWriter().write(gson.toJson(list));
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", e.getMessage())));
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String idParam = req.getParameter("id");          // memberId
        String userIdParam = req.getParameter("userId");  // optional

        if (idParam == null || idParam.isBlank()) {
            resp.setStatus(400);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Member ID required")));
            return;
        }

        Transaction tx = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            tx = session.beginTransaction();

            int memberId = Integer.parseInt(idParam);
            Member member = session.get(Member.class, memberId);

            if (member == null) {
                resp.setStatus(404);
                resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Member not found")));
                return;
            }

            // User মুছে দিলে Member-ও CASCADE হয়ে মুছে যাবে
            User user = session.get(User.class, member.getUserId());
            if (user != null) {
                session.remove(user);
            } else {
                session.remove(member);
            }

            tx.commit();
            resp.getWriter().write(gson.toJson(Map.of(
                    "status", "success",
                    "message", "Member deleted successfully"
            )));
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", e.getMessage())));
        }
    }
}
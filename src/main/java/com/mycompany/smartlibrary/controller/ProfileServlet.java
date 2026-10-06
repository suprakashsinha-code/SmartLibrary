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

@WebServlet(name = "ProfileServlet", urlPatterns = {"/api/profile"})
public class ProfileServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession httpSession = req.getSession(false);
        if (httpSession == null || httpSession.getAttribute("userId") == null) {
            resp.setStatus(401);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Not logged in")));
            return;
        }

        int userId = (int) httpSession.getAttribute("userId");

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            User user = session.get(User.class, userId);
            if (user == null) {
                resp.setStatus(404);
                resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "User not found")));
                return;
            }

            Member member = session.createQuery(
                    "FROM Member m WHERE m.userId = :uid", Member.class)
                    .setParameter("uid", userId)
                    .uniqueResult();

            Map<String, Object> data = new LinkedHashMap<>();
            data.put("userId", user.getId());
            data.put("name", user.getName());
            data.put("email", user.getEmail());
            data.put("role", user.getRole().name());
            data.put("status", user.getStatus().name());
            data.put("phone", member != null ? (member.getPhone() != null ? member.getPhone() : "") : "");
            data.put("address", member != null ? (member.getAddress() != null ? member.getAddress() : "") : "");
            data.put("membershipType", member != null ? member.getMembershipType() : "STANDARD");
            data.put("membershipDate", member != null && member.getMembershipDate() != null
                    ? member.getMembershipDate().toString() : "");

            // পাসওয়ার্ড কখনোই পাঠাবো না
            resp.getWriter().write(gson.toJson(data));
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", e.getMessage())));
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession httpSession = req.getSession(false);
        if (httpSession == null || httpSession.getAttribute("userId") == null) {
            resp.setStatus(401);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Not logged in")));
            return;
        }

        int userId = (int) httpSession.getAttribute("userId");
        String action = req.getParameter("action"); // "updateProfile" or "changePassword"

        try {
            if ("updateProfile".equalsIgnoreCase(action)) {
                handleUpdateProfile(req, resp, userId, httpSession);
            } else if ("changePassword".equalsIgnoreCase(action)) {
                handleChangePassword(req, resp, userId);
            } else {
                resp.setStatus(400);
                resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Invalid action")));
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", e.getMessage())));
        }
    }

    private void handleUpdateProfile(HttpServletRequest req, HttpServletResponse resp,
                                     int userId, HttpSession httpSession) throws IOException {
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String address = req.getParameter("address");

        if (name == null || email == null || name.isBlank() || email.isBlank()) {
            resp.setStatus(400);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Name and Email are required")));
            return;
        }

        Transaction tx = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            tx = session.beginTransaction();

            User user = session.get(User.class, userId);
            if (user == null) {
                resp.setStatus(404);
                resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "User not found")));
                return;
            }

            // Email unique check (নিজের ছাড়া)
            Long count = session.createQuery(
                    "SELECT COUNT(u) FROM User u WHERE u.email = :email AND u.id != :id", Long.class)
                    .setParameter("email", email.trim().toLowerCase())
                    .setParameter("id", userId)
                    .uniqueResult();

            if (count != null && count > 0) {
                resp.setStatus(409);
                resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Email already used by another account")));
                return;
            }

            user.setName(name.trim());
            user.setEmail(email.trim().toLowerCase());
            session.merge(user);

            Member member = session.createQuery(
                    "FROM Member m WHERE m.userId = :uid", Member.class)
                    .setParameter("uid", userId)
                    .uniqueResult();

            if (member != null) {
                member.setPhone(phone != null && !phone.isBlank() ? phone.trim() : null);
                member.setAddress(address != null && !address.isBlank() ? address.trim() : null);
                session.merge(member);
            }

            tx.commit();

            // Session আপডেট
            httpSession.setAttribute("userName", user.getName());
            httpSession.setAttribute("userEmail", user.getEmail());

            resp.getWriter().write(gson.toJson(Map.of(
                    "status", "success",
                    "message", "Profile updated successfully"
            )));
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }

    private void handleChangePassword(HttpServletRequest req, HttpServletResponse resp, int userId) throws IOException {
        String currentPassword = req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword");

        if (currentPassword == null || newPassword == null ||
                currentPassword.isBlank() || newPassword.isBlank()) {
            resp.setStatus(400);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "All password fields are required")));
            return;
        }

        if (newPassword.length() < 8) {
            resp.setStatus(400);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "New password must be at least 8 characters")));
            return;
        }

        Transaction tx = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            tx = session.beginTransaction();

            User user = session.get(User.class, userId);
            if (user == null) {
                resp.setStatus(404);
                resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "User not found")));
                return;
            }

            // Current password verify (এখন plain text, পরে BCrypt করবে)
            if (!user.getPassword().equals(currentPassword)) {
                resp.setStatus(401);
                resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Current password is incorrect")));
                return;
            }

            user.setPassword(newPassword); // পরে BCrypt.hashpw(newPassword, BCrypt.gensalt())
            session.merge(user);

            tx.commit();
            resp.getWriter().write(gson.toJson(Map.of(
                    "status", "success",
                    "message", "Password changed successfully"
            )));
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }
}
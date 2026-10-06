/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.smartlibrary.controller;


import com.google.gson.Gson;
import com.mycompany.smartlibrary.dao.UserDAO;
import com.mycompany.smartlibrary.model.User;

import java.io.IOException;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import org.hibernate.Session;

@WebServlet(name = "AuthServlet", urlPatterns = {"/api/auth"})
public class AuthServlet extends HttpServlet {

    private final Gson gson = new Gson();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action"); // "register" or "login"

        try {
            if ("register".equalsIgnoreCase(action)) {
                handleRegister(req, resp);
            } else if ("login".equalsIgnoreCase(action)) {
                handleLogin(req, resp);
            } else {
                resp.setStatus(400);
                resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Invalid action")));
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            String errorMsg = e.getMessage() != null ? e.getMessage() : e.getClass().getName();
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", errorMsg)));
        }
    }

private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    String name = req.getParameter("name");
    String email = req.getParameter("email");
    String password = req.getParameter("password");
    String roleParam = req.getParameter("role");   // MEMBER or ADMIN

    if (name == null || email == null || password == null || name.isBlank() || email.isBlank() || password.isBlank()) {
        resp.setStatus(400);
        resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "All fields are required")));
        return;
    }

    User user = new User();
    user.setName(name.trim());
    user.setEmail(email.trim().toLowerCase());
    user.setPassword(password);

    // Role set করো
    if ("ADMIN".equalsIgnoreCase(roleParam)) {
        user.setRole(User.Role.ADMIN);
    } else {
        user.setRole(User.Role.MEMBER);
    }

    // Member table-এ শুধু MEMBER হলে রেকর্ড তৈরি হবে
    String membershipType = "STANDARD";
    boolean success = userDAO.register(user, membershipType);

    if (success) {
        resp.getWriter().write(gson.toJson(Map.of(
                "status", "success",
                "message", "Registration successful! You can now login."
        )));
    } else {
        resp.setStatus(409);
        resp.getWriter().write(gson.toJson(Map.of(
                "status", "error",
                "message", "Email already registered"
        )));
    }
}

private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        User user = userDAO.login(email, password);

        if (user != null) {
            // Session তৈরি করো
            HttpSession session = req.getSession(true);
            session.setAttribute("userId", user.getId());
            session.setAttribute("userName", user.getName());
            session.setAttribute("userRole", user.getRole().name());
            session.setAttribute("userEmail", user.getEmail());

            // --- FIX: Member role hole memberId session-e save korte hobe ---
            if (user.getRole() == User.Role.MEMBER) {
                try (Session hibernateSession = com.mycompany.smartlibrary.config.HibernateUtil.getSessionFactory().openSession()) {
                    com.mycompany.smartlibrary.model.Member member = hibernateSession.createQuery(
                        "FROM Member m WHERE m.userId = :userId", com.mycompany.smartlibrary.model.Member.class)
                        .setParameter("userId", user.getId())
                        .uniqueResult();
                    
                    if (member != null) {
                        session.setAttribute("memberId", member.getMemberId());
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            // -------------------------------------------------------------

            String redirectUrl = user.getRole() == User.Role.ADMIN
                    ? "/admin/Admin-dashboard.jsp"
                    : "/member/member-dashboard.jsp";

            resp.getWriter().write(gson.toJson(Map.of(
                    "status", "success",
                    "message", "Login successful",
                    "role", user.getRole().name(),
                    "redirect", redirectUrl
            )));
        } else {
            resp.setStatus(401);
            resp.getWriter().write(gson.toJson(Map.of(
                    "status", "error",
                    "message", "Invalid email or password"
            )));
        }
    }
}

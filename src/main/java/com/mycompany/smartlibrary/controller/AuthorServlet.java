package com.mycompany.smartlibrary.controller;

import com.google.gson.Gson;
import com.mycompany.smartlibrary.dao.AuthorDAO;
import com.mycompany.smartlibrary.model.Author;
import com.mycompany.smartlibrary.config.HibernateUtil;
import com.mycompany.smartlibrary.model.Specialization;
import org.hibernate.Session;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AuthorServlet", urlPatterns = {"/AuthorServlet"})
public class AuthorServlet extends HttpServlet {

    private AuthorDAO authorDAO = new AuthorDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String name = request.getParameter("author-name");
        String nationality = request.getParameter("author-nationality");
        String specializationStr = request.getParameter("author-specialization");
        String bio = request.getParameter("author-bio");

        Author author = new Author();
        author.setFullName(name);
        author.setNationality(nationality);
        author.setBiography(bio);

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Specialization spec = session.createQuery("FROM Specialization WHERE name = :name", Specialization.class)
                    .setParameter("name", specializationStr)
                    .uniqueResult();
            if (spec != null) {
                author.setSpecializationId(spec.getSpecializationId());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        authorDAO.saveAuthor(author);
        response.getWriter().write("{\"status\":\"success\"}");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if ("getAll".equals(action)) {
            List<Author> list = authorDAO.getAllAuthors();
            response.getWriter().write(new Gson().toJson(list));
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            authorDAO.deleteAuthor(id);
            response.getWriter().write("{\"status\":\"deleted\"}");
        } else if ("search".equals(action)) {
            String term = request.getParameter("term");
            List<Author> list = authorDAO.searchAuthors(term);
            response.getWriter().write(new Gson().toJson(list));
        } else if ("getProfile".equals(action)) {
            String profileName = request.getParameter("name");
            try (Session session = HibernateUtil.getSessionFactory().openSession()) {
                List<Author> list = session.createQuery("FROM Author WHERE fullName = :name", Author.class)
                        .setParameter("name", profileName)
                        .list();
                if (!list.isEmpty()) {
                    Author a = list.get(0);
                    Map<String, Object> map = new HashMap<>();
                    map.put("fullName", a.getFullName());
                    map.put("nationality", a.getNationality());
                    map.put("specializationId", a.getSpecializationId());
                    map.put("biography", a.getBiography());
                    response.getWriter().write(new Gson().toJson(map));
                } else {
                    response.getWriter().write("{}");
                }
            }
        }
    }
}

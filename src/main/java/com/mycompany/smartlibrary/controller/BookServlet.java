/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.smartlibrary.controller;

import com.google.gson.Gson;
import com.mycompany.smartlibrary.config.HibernateUtil;
import com.mycompany.smartlibrary.model.Author;
import com.mycompany.smartlibrary.model.Book;
import com.mycompany.smartlibrary.model.Category;
import java.io.IOException;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.hibernate.Session;
import org.hibernate.Transaction;

@WebServlet("/api/books")
public class BookServlet extends HttpServlet {

    private final Gson gson = new Gson();

@Override
protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    resp.setContentType("application/json");
    resp.setCharacterEncoding("UTF-8");

    String action = req.getParameter("action");

    // ========== UPDATE ==========
    if ("update".equalsIgnoreCase(action)) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = session.beginTransaction();

            String idStr = req.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Book ID is missing")));
                return;
            }

            int id = Integer.parseInt(idStr);
            Book book = session.get(Book.class, id);

            if (book == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Book not found")));
                return;
            }

            String title = req.getParameter("title");
            String authorName = req.getParameter("author");
            String categoryName = req.getParameter("category");
            int copies = Integer.parseInt(req.getParameter("copies"));
            int available = Integer.parseInt(req.getParameter("available"));

            book.setTitle(title);
            book.setQuantity(copies);
            book.setAvailableQuantity(available);

            // Author
            Author author = session.createQuery("FROM Author a WHERE a.fullName = :name", Author.class)
                    .setParameter("name", authorName)
                    .uniqueResult();
            if (author == null) {
                author = new Author();
                author.setFullName(authorName);
                author.setNationality("Unknown");
                session.persist(author);
                session.flush();
            }
            book.setAuthor(author);

            // Category
            Category category = session.createQuery("FROM Category c WHERE c.categoryName = :name", Category.class)
                    .setParameter("name", categoryName)
                    .uniqueResult();
            if (category == null) {
                category = new Category();
                category.setCategoryName(categoryName);
                session.persist(category);
                session.flush();
            }
            book.setCategory(category);

            session.merge(book);
            tx.commit();

            resp.getWriter().write(gson.toJson(Map.of("status", "success", "message", "Volume updated successfully")));
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write(gson.toJson(Map.of(
                "status", "error",
                "message", e.getMessage() != null ? e.getMessage() : "Unknown error"
            )));
        }
        return;
    }

    // ========== CREATE ==========
    try (Session session = HibernateUtil.getSessionFactory().openSession()) {
        Transaction tx = session.beginTransaction();

        String title = req.getParameter("title");
        String authorName = req.getParameter("author");
        String categoryName = req.getParameter("category");
        int copies = Integer.parseInt(req.getParameter("copies"));
        int available = Integer.parseInt(req.getParameter("available"));

        // Author
        Author author = session.createQuery(
                "FROM Author a WHERE a.fullName = :name", Author.class)
                .setParameter("name", authorName)
                .uniqueResult();

        if (author == null) {
            author = new Author();
            author.setFullName(authorName);
            author.setNationality("Unknown");
            session.persist(author);
            session.flush();
        }

        // Category
        Category category = session.createQuery(
                "FROM Category c WHERE c.categoryName = :name", Category.class)
                .setParameter("name", categoryName)
                .uniqueResult();

        if (category == null) {
            category = new Category();
            category.setCategoryName(categoryName);
            session.persist(category);
            session.flush();
        }

        // Book
        Book book = new Book();
        book.setTitle(title);
        book.setIsbn("ISBN-" + System.currentTimeMillis());
        book.setAuthor(author);
        book.setCategory(category);
        book.setQuantity(copies);
        book.setAvailableQuantity(available);

        session.persist(book);
        tx.commit();

        resp.getWriter().write(gson.toJson(
                Map.of("status", "success", "message", "Volume registered successfully")
        ));

    } catch (Exception e) {
        e.printStackTrace();
        resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        resp.getWriter().write(gson.toJson(
                Map.of("status", "error", "message", e.getMessage() != null ? e.getMessage() : "Unknown error")
        ));
    }
}
    @Override
protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    resp.setContentType("application/json");
    resp.setCharacterEncoding("UTF-8");

    try (Session session = HibernateUtil.getSessionFactory().openSession()) {
        Transaction tx = session.beginTransaction();

        int id = Integer.parseInt(req.getParameter("id"));
        Book book = session.get(Book.class, id);

        if (book == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Book not found")));
            return;
        }

        String title = req.getParameter("title");
        String authorName = req.getParameter("author");
        String categoryName = req.getParameter("category");
        int copies = Integer.parseInt(req.getParameter("copies"));
        int available = Integer.parseInt(req.getParameter("available"));

        book.setTitle(title);
        book.setQuantity(copies);
        book.setAvailableQuantity(available);

        // Author
        Author author = session.createQuery("FROM Author a WHERE a.fullName = :name", Author.class)
                .setParameter("name", authorName)
                .uniqueResult();
        if (author == null) {
            author = new Author();
            author.setFullName(authorName);
            author.setNationality("Unknown");
            session.persist(author);
            session.flush();
        }
        book.setAuthor(author);

        // Category
        Category category = session.createQuery("FROM Category c WHERE c.categoryName = :name", Category.class)
                .setParameter("name", categoryName)
                .uniqueResult();
        if (category == null) {
            category = new Category();
            category.setCategoryName(categoryName);
            session.persist(category);
            session.flush();
        }
        book.setCategory(category);

        session.merge(book);
        tx.commit();

        resp.getWriter().write(gson.toJson(Map.of("status", "success", "message", "Volume updated successfully")));

    } catch (Exception e) {
        e.printStackTrace();
        resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        resp.getWriter().write(gson.toJson(Map.of("status", "error", "message", e.getMessage() != null ? e.getMessage() : "Unknown error")));
    }
}
    @Override
protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    resp.setContentType("application/json");
    resp.setCharacterEncoding("UTF-8");
    String idParam = req.getParameter("id");
    
    try (Session session = HibernateUtil.getSessionFactory().openSession()) {
        Transaction tx = session.beginTransaction();
        int id = Integer.parseInt(idParam);
        Book book = session.get(Book.class, id);
        if (book != null) {
            session.remove(book);
            tx.commit();
            resp.getWriter().write(gson.toJson(
                Map.of("status", "success", "message", "Volume deleted successfully")
            ));
        } else {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.getWriter().write(gson.toJson(
                Map.of("status", "error", "message", "Book not found")
            ));
        }
    } catch (Exception e) {
        e.printStackTrace();
        resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        resp.getWriter().write(gson.toJson(
            Map.of("status", "error", "message", e.getMessage() != null ? e.getMessage() : "Unknown error")
        ));
    }
}
    @Override
    public String getServletInfo() {
        return "Book Servlet - Add Book via Hibernate";
    }
}
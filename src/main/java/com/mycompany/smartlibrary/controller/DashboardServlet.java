package com.mycompany.smartlibrary.controller;

import com.google.gson.Gson;
import com.mycompany.smartlibrary.dao.BookDAO;
import com.mycompany.smartlibrary.model.Book;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/api/dashboard-books")
public class DashboardServlet extends HttpServlet {
    private BookDAO bookDAO = new BookDAO();
    private Gson gson = new Gson();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html><head><title>Dashboard</title></head>");
            out.println("<body><h1>Servlet DashboardServlet</h1></body></html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        
        List<Book> bookList = bookDAO.getAllBooks();
        long totalBooks = bookDAO.getTotalBooksCount();
        long issuedBooks = bookDAO.getIssuedBooksCount();

        List<Map<String, Object>> formattedBooks = bookList.stream().map(b -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", b.getBookId());
            map.put("title", b.getTitle());
            map.put("author", b.getAuthor() != null ? b.getAuthor().getFullName() : "Unknown");
            map.put("category", b.getCategory() != null ? b.getCategory().getCategoryName() : "General");
            map.put("available", b.getAvailableQuantity());
            return map;
        }).collect(Collectors.toList());

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("totalBooks", totalBooks);
        responseData.put("issuedBooks", issuedBooks);
        responseData.put("books", formattedBooks);

        resp.getWriter().write(gson.toJson(responseData));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Dashboard Servlet";
    }
}
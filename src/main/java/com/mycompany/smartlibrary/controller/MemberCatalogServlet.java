/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.smartlibrary.controller;

import com.mycompany.smartlibrary.dao.BookDAO;
import com.mycompany.smartlibrary.model.Book;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/member/catalog")
public class MemberCatalogServlet extends HttpServlet {
    private BookDAO bookDAO;

    @Override
    public void init() {
        bookDAO = new BookDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String searchQuery = request.getParameter("search");
            String categoryFilter = request.getParameter("category");
            
            List<Book> bookList;
            
            // Backend database search execution
            if ((searchQuery != null && !searchQuery.trim().isEmpty()) || 
                (categoryFilter != null && !categoryFilter.trim().isEmpty() && !categoryFilter.equalsIgnoreCase("all"))) {
                bookList = bookDAO.searchBooks(searchQuery, categoryFilter);
            } else {
                bookList = bookDAO.getAllBooks();
            }
            
            request.setAttribute("bookList", bookList);
            request.setAttribute("searchQuery", searchQuery);
            request.setAttribute("selectedCategory", categoryFilter);
            
            request.getRequestDispatcher("/member/books.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred.");
        }
    }
}
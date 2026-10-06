/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.smartlibrary.controller;

import com.mycompany.smartlibrary.config.HibernateUtil;
import com.mycompany.smartlibrary.model.Category;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.hibernate.Session;
import com.google.gson.Gson;
import com.mycompany.smartlibrary.dao.CategoryDAO;
import javax.servlet.annotation.WebServlet;

@WebServlet("/api/categories")
public class CategoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        Gson gson = new Gson();
        String searchParam = req.getParameter("search");
        
        try {
            CategoryDAO dao = new CategoryDAO();
            List<Category> categories;
            if (searchParam != null && !searchParam.trim().isEmpty()) {
                categories = dao.searchCategories(searchParam.trim());
            } else {
                categories = dao.getAllCategories();
            }
            resp.getWriter().write(gson.toJson(categories));
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        
        try {
            Category category = new Category();
            category.setCategoryName(name);
            category.setDescription(description);
            
            CategoryDAO dao = new CategoryDAO();
            dao.saveCategory(category);
            
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("{\"status\":\"success\", \"message\":\"Category saved successfully\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"status\":\"error\", \"message\":\"" + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        String idParam = req.getParameter("id");
        PrintWriter out = resp.getWriter();
        
        try {
            int id = Integer.parseInt(idParam);
            CategoryDAO dao = new CategoryDAO();
            dao.deleteCategory(id);
            
            resp.setStatus(HttpServletResponse.SC_OK);
            out.write("{\"status\":\"success\", \"message\":\"Category deleted successfully\"}");
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"status\":\"error\", \"message\":\"" + e.getMessage() + "\"}");
        }
    }

    @Override
    public String getServletInfo() {
        return "Category Management Servlet";
    }
}
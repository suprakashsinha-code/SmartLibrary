package com.mycompany.smartlibrary.dao;

import com.mycompany.smartlibrary.model.Book;
import com.mycompany.smartlibrary.config.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.util.List;

public class BookDAO {
    public List<Book> getAllBooks() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM Book b JOIN FETCH b.author JOIN FETCH b.category", Book.class).list();
        }
    }
    
    public long getTotalBooksCount() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("SELECT COUNT(b) FROM Book b", Long.class).getSingleResult();
        }
    }

    public long getIssuedBooksCount() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("SELECT COUNT(bi) FROM BookIssue bi WHERE bi.status = 'ISSUED'", Long.class).getSingleResult();
        }
    }
    public List<Book> searchBooks(String query, String category) {
    try (Session session = HibernateUtil.getSessionFactory().openSession()) {
        StringBuilder hql = new StringBuilder("FROM Book b JOIN FETCH b.author a JOIN FETCH b.category c WHERE 1=1");
        
        if (query != null && !query.trim().isEmpty()) {
            hql.append(" AND (LOWER(b.title) LIKE :query OR LOWER(a.fullName) LIKE :query)");
        }
        if (category != null && !category.equalsIgnoreCase("all") && !category.trim().isEmpty()) {
            hql.append(" AND LOWER(c.categoryName) = :category");
        }
        
        var q = session.createQuery(hql.toString(), Book.class);
        
        if (query != null && !query.trim().isEmpty()) {
            q.setParameter("query", "%" + query.toLowerCase().trim() + "%");
        }
        if (category != null && !category.equalsIgnoreCase("all") && !category.trim().isEmpty()) {
            q.setParameter("category", category.toLowerCase().trim());
        }
        
        return q.list();
    }
}
    public void save(Book book) {
        Transaction tx = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            tx = session.beginTransaction();
            session.persist(book);
            tx.commit();
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw e;
        }
    }
    public void update(Book book) {
    Transaction tx = null;
    try (Session session = HibernateUtil.getSessionFactory().openSession()) {
        tx = session.beginTransaction();
        session.merge(book);
        tx.commit();
    } catch (Exception e) {
        if (tx != null) tx.rollback();
        throw e;
    }
}

public Book getById(int id) {
    try (Session session = HibernateUtil.getSessionFactory().openSession()) {
        return session.get(Book.class, id);
    }
}
}
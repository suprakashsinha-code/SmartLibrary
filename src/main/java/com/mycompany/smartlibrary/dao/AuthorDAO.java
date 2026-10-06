/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.smartlibrary.dao;

import com.mycompany.smartlibrary.model.Author;
import com.mycompany.smartlibrary.config.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.util.List;

public class AuthorDAO {

    public void saveAuthor(Author author) {
        Session session = null;
        Transaction transaction = null;
        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();
            session.persist(author);
            transaction.commit();
        } catch (Exception e) {
            if (transaction != null && transaction.getStatus().canRollback()) {
                transaction.rollback();
            }
            e.printStackTrace();
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }

    public List<Author> getAllAuthors() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM Author", Author.class).list();
        }
    }

    public List<Author> searchAuthors(String term) {
        String queryTerm = "%" + (term == null ? "" : term.trim().toLowerCase()) + "%";
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "SELECT a FROM Author a LEFT JOIN Specialization s ON a.specializationId = s.specializationId "
                    + "WHERE LOWER(a.fullName) LIKE :term OR LOWER(a.nationality) LIKE :term OR LOWER(s.name) LIKE :term";
            return session.createQuery(hql, Author.class)
                    .setParameter("term", queryTerm)
                    .list();
        } catch (Exception e) {
            e.printStackTrace();
            return getAllAuthors();
        }
    }

    public Author getAuthorById(int id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.get(Author.class, id);
        }
    }

    public void deleteAuthor(int id) {
        Session session = null;
        Transaction transaction = null;
        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();
            Author author = session.get(Author.class, id);
            if (author != null) {
                session.remove(author);
            }
            transaction.commit();
        } catch (Exception e) {
            if (transaction != null && transaction.getStatus().canRollback()) {
                transaction.rollback();
            }
            e.printStackTrace();
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }
}

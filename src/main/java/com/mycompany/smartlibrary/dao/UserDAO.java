/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.smartlibrary.dao;

/**
 *
 * @author Suprakash
 */


import com.mycompany.smartlibrary.config.HibernateUtil;
import com.mycompany.smartlibrary.model.User;
import com.mycompany.smartlibrary.model.Member;
import org.hibernate.Session;
import org.hibernate.Transaction;

public class UserDAO {

public boolean register(User user, String membershipType) {
    Transaction tx = null;
    try (Session session = HibernateUtil.getSessionFactory().openSession()) {
        tx = session.beginTransaction();

        Long count = session.createQuery(
                "SELECT COUNT(u) FROM User u WHERE u.email = :email", Long.class)
                .setParameter("email", user.getEmail())
                .uniqueResult();

        if (count != null && count > 0) {
            return false;
        }

        session.persist(user);
        session.flush();

        // শুধু Member হলে members টেবিলে রেকর্ড তৈরি করো
        if (user.getRole() == User.Role.MEMBER) {
            Member member = new Member();
            member.setUserId(user.getId());
            member.setMembershipType(membershipType != null ? membershipType : "STANDARD");
            session.persist(member);
        }

        tx.commit();
        return true;
    } catch (Exception e) {
        if (tx != null) tx.rollback();
        e.printStackTrace();
        return false;
    }
}

    public User login(String email, String password) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                    "FROM User u WHERE u.email = :email AND u.password = :password AND u.status = 'ACTIVE'",
                    User.class)
                    .setParameter("email", email)
                    .setParameter("password", password)
                    .uniqueResult();
        }
    }
}
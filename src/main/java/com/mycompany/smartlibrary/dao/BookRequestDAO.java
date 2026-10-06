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
import com.mycompany.smartlibrary.model.Book;
import com.mycompany.smartlibrary.model.BookIssue;
import com.mycompany.smartlibrary.model.BookRequest;
import com.mycompany.smartlibrary.model.Member;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.time.LocalDate;
import java.util.Date;
import java.util.List;

public class BookRequestDAO {

    public List<BookRequest> getRequestsByStatus(BookRequest.RequestStatus status) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                "FROM BookRequest r JOIN FETCH r.book b JOIN FETCH b.author JOIN FETCH b.category WHERE r.status = :status", 
                BookRequest.class)
                .setParameter("status", status)
                .list();
        }
    }

    public List<BookRequest> getActiveRequests() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                "FROM BookRequest r JOIN FETCH r.book b JOIN FETCH b.author JOIN FETCH b.category WHERE r.status IN (:statuses)", 
                BookRequest.class)
                .setParameter("statuses", List.of(BookRequest.RequestStatus.PENDING, BookRequest.RequestStatus.APPROVED))
                .list();
        }
    }

    public BookRequest getRequestById(int requestId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.get(BookRequest.class, requestId);
        }
    }

public boolean processRequest(int requestId, String adminRemark, String action) {
        Transaction tx = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            tx = session.beginTransaction();

            BookRequest request = session.get(BookRequest.class, requestId);
            if (request == null) {
                return false;
            }

            // 1. Cancel / Reject
            if ("CANCELLED".equalsIgnoreCase(action) || "REJECTED".equalsIgnoreCase(action)) {
                session.remove(request);
                tx.commit();
                return true;
            }

            // 2. Approve Only
            if ("APPROVE_ONLY".equalsIgnoreCase(action)) {
                request.setStatus(BookRequest.RequestStatus.APPROVED);
                request.setProcessedAt(new Date());
                request.setAdminRemark(adminRemark);
                session.merge(request);
                tx.commit();
                return true;
            }

            // 3. Issue / Accept Action
            Book book = request.getBook();
            int memberId = request.getMemberId();

            // AUTOMATIC RENEWAL CHECK: Check if an active issue already exists for this member and book
            BookIssue existingIssue = session.createQuery(
                "FROM BookIssue bi WHERE bi.member.memberId = :memberId AND bi.book.bookId = :bookId AND bi.status = 'ISSUED'",
                BookIssue.class)
                .setParameter("memberId", memberId)
                .setParameter("bookId", book.getBookId())
                .uniqueResult();

            boolean isRenewal = (existingIssue != null) || 
                                (request.getAdminRemark() != null && request.getAdminRemark().toUpperCase().contains("RENEWAL"));

            if (isRenewal) {
                if (existingIssue == null) {
                    // Fallback to extract Issue ID from remark if explicitly provided
                    String remark = request.getAdminRemark();
                    String numberOnly = remark != null ? remark.replaceAll("[^0-9]", "") : "";
                    if (!numberOnly.isEmpty()) {
                        int originalIssueId = Integer.parseInt(numberOnly);
                        existingIssue = session.get(BookIssue.class, originalIssueId);
                    }
                }

                if (existingIssue == null || !"ISSUED".equalsIgnoreCase(existingIssue.getStatus())) {
                    throw new RuntimeException("Original active issue not found or already returned for renewal.");
                }

                // Due date extend by 30 days from TODAY
                existingIssue.setDueDate(LocalDate.now().plusDays(30));
                existingIssue.setStatus("ISSUED");
                session.merge(existingIssue);

                // Remove the renewal request from requests table
                session.remove(request);
                tx.commit();
                return true;
            }

            // ===== NORMAL NEW ISSUE FLOW =====
            if (request.getBookType() == BookRequest.BookType.PHYSICAL) {
                if (book.getAvailableQuantity() <= 0) {
                    throw new RuntimeException("No available copies remaining.");
                }
                book.setAvailableQuantity(book.getAvailableQuantity() - 1);
                session.merge(book);
            }

            Member member = session.get(Member.class, memberId);
            if (member == null) {
                throw new RuntimeException("Associated member not found.");
            }

            BookIssue issue = new BookIssue();
            issue.setBook(book);
            issue.setMember(member);
            issue.setIssueDate(LocalDate.now());
            issue.setDueDate(LocalDate.now().plusDays(30));
            issue.setStatus("ISSUED");

            session.persist(issue);
            session.remove(request);

            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
            return false;
        }
    }

    public boolean returnBook(int issueId) {
        Transaction tx = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            tx = session.beginTransaction();

            BookIssue issue = session.get(BookIssue.class, issueId);
            if (issue == null || "RETURNED".equalsIgnoreCase(issue.getStatus())) {
                return false;
            }

            issue.setStatus("RETURNED");
            issue.setReturnDate(LocalDate.now());
            session.merge(issue);

            Book book = issue.getBook();
            if (book != null) {
                book.setAvailableQuantity(book.getAvailableQuantity() + 1);
                session.merge(book);
            }

            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
            return false;
        }
    }
}
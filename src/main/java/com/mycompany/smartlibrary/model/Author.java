/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.smartlibrary.model;

/**
 *
 * @author Suprakash
 */


import jakarta.persistence.*;

import jakarta.persistence.*;

@Entity
@Table(name = "authors")
public class Author {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "author_id")
    private int authorId;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    private String nationality;

    @Column(name = "specialization_id")
    private Integer specializationId;

    private String biography;

    // Getters and Setters
    public int getAuthorId() { return authorId; }
    public void setAuthorId(int authorId) { this.authorId = authorId; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getNationality() { return nationality; }
    public void setNationality(String nationality) { this.nationality = nationality; }
    public Integer getSpecializationId() { return specializationId; }
    public void setSpecializationId(Integer specializationId) { this.specializationId = specializationId; }
    public String getBiography() { return biography; }
    public void setBiography(String biography) { this.biography = biography; }
}
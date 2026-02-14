package com.brewco.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "govt_proof")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GovernmentProof {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String proofType;

    @Column(nullable = false)
    private String proofNumber;
}

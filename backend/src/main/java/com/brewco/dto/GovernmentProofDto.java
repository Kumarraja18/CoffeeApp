package com.brewco.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GovernmentProofDto {
    private Long id;
    private String proofType;
    private String proofNumber;
}

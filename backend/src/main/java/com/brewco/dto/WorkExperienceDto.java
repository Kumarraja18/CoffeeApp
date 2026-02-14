package com.brewco.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WorkExperienceDto {
    private Long id;
    private String companyName;
    private String position;
    private Integer years;
}

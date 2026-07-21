# Diabetes Patient Readmission Risk Analysis

## Overview
Analyzed 100K+ diabetic patient encounters from 130 US hospitals to find patterns behind 30-day hospital readmissions. Worked across SQL, Python and Power BI to clean the data, run KPI analysis and build an interactive dashboard.

---

## Dataset
- **Source:** Kaggle — Diabetes 130-US Hospitals (1999–2008)
- **Link:** https://www.kaggle.com/datasets/brandao/diabetes
- **Raw size:** 101,766 hospital encounters across 10 years

Columns used in analysis: `patient_nbr`, `age`, `admission_type_id`, `discharge_disposition_id`, `time_in_hospital`, `medical_specialty`, `number_diagnoses`, `change`, `readmitted`

---

## What I did
- Cleaned the dataset — replaced `?` values, kept only the first encounter per patient, excluded expired/hospice patients (`discharge_disposition_id` codes 11, 13, 14, 19, 20, 21) before computing readmission rates
- Used SQL to calculate readmission KPIs, age group analysis, specialty-level breakdown and risk stratification
- Used Python (Pandas, Matplotlib) for EDA and visualizations
- Built a Power BI dashboard with filters for age, gender and medical specialty

---

## Readmission Definition
Readmission rate is reported using the **strict 30-day definition** (`readmitted == '<30'`) as the headline metric everywhere — README, SQL, and Python all use this same definition. A broader "any readmission" metric (`readmitted <> 'NO'`, includes >30-day readmits) is also available in the SQL file, labeled separately so it isn't confused with the 30-day figure.

---

## Dashboard KPIs
| Metric                            | Value     |
| ---------------------------------- | --------- |
| Raw Encounters                     | 101,766   |
| Unique Patients (after dedup)      | 71,518    |
| Encounters After Cleaning*         | 69,973    |
| Average Length of Stay             | 4.27 days |
| Readmitted Encounters (30-day)     | 6,277     |
| Readmission Rate (30-day)          | 8.97%     |
| Readmission Rate (any, broad def)  | 40.73%    |

*After deduplication (first encounter per patient) and exclusion of expired/hospice discharges.

---

## Key Findings
- Age group and admission-type patterns in readmission rate (see `readmission_by_age.png`, `readmission_by_admission.png`)
- Length of stay alone was not a strong predictor — discharge planning plays a bigger role
- A rule-based high-risk flag (elderly + emergency admission + long stay ≥7 days) identifies a high-risk subgroup; this is descriptive risk stratification, not a predictive ML model

---

## Files
```
├── diabetes.sql            — SQL queries (readmission KPIs, age/specialty breakdowns, window functions)
├── diabetic_analysis.py    — Python EDA script (cleaning, KPI calc, visualizations)
├── diabetes.bi.pbix        — Power BI dashboard
├── readmission_by_age.png  — Readmission rate by age group chart
├── readmission_by_admission.png — Readmission rate by admission type chart
```

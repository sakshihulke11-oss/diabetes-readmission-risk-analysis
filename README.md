# Diabetes Patient Readmission Risk Analysis

## Overview

Analyzed 102,000+ diabetic patient encounters from 130 US hospitals to find patterns behind 30-day hospital readmissions. Worked across SQL, Python and Power BI to clean the data, run KPI analysis and build an interactive dashboard.

---

## Dataset

- **Source:** Kaggle — Diabetes 130-US Hospitals (1999–2008)
- **Link:** https://www.kaggle.com/datasets/brandao/diabetes
- **Size:** 102,000+ hospital encounters across 10 years

Columns used in analysis: `patient_nbr`, `age`, `admission_type_id`, `discharge_disposition_id`, `time_in_hospital`, `medical_specialty`, `number_diagnoses`, `change`, `readmitted`

---

## What I did

- Cleaned the dataset — replaced `?` values, removed duplicate encounters, excluded expired/hospice patients
- Used SQL to calculate readmission KPIs, age group analysis, specialty level breakdown and risk stratification
- Used Python (Pandas, Matplotlib) for EDA and visualizations
- Built a Power BI dashboard with filters for age, gender and medical specialty

---

## Dashboard KPIs

| Metric | Value |
|---|---|
| Total Encounters | 102K |
| Avg Length of Stay | 4.40 days |
| Readmitted Encounters | 11K |
| Readmission Rate | 11.16% |

---

## Key Findings

- Overall 30-day readmission rate was **11.16%**
- Age group **[20-30]** had the highest readmission rate
- **[80-90]** and **[70-80]** also showed high risk
- Specialties like Hematology/Oncology had highest readmission concentration
- Length of stay alone was not a strong predictor — discharge planning plays a bigger role

---

├── diabetes.sql                   — SQL queries
├── diabetic_analysis.py           — Python EDA script
├── diabetes.bi.pbix               — Power BI dashboard
├── readmission_by_age.png         — Readmission rate by age group chart
├── readmission_by_admission.png   — Readmission rate by admission type chart
├── IMG_20260213_232330.jpg        — Power BI dashboard screenshot


# Diabetic Patient Readmission: Risk & Utilization Analysis

**Data-driven exploratory analysis of 30-day hospital readmission patterns in diabetic patients across 130 US hospitals (1999–2008).**

---

## Overview

This project analyzes **102,000+ clinical encounters** to identify demographic, clinical, and operational risk factors associated with unplanned readmission within 30 days of discharge. The analysis surfaces actionable patterns—by age, medical specialty, and length of stay—that care coordination teams can use to prioritize interventions.

**Key Finding:** Overall 30-day readmission rate is **11.16%** (11K of 102K encounters); rate varies significantly by age group (20–30 age bracket peaks at ~14%) and medical specialty (Hematology/Oncology, Nephrology, and Physical Medicine exceed 14%).

---

## Data & Methodology

### Dataset
- **Source:** UCI Machine Learning Repository – Diabetes 130-US Hospitals Dataset
- **Period:** 1999–2008 (10 years)
- **Scope:** 102K+ encounters across 130 US hospitals; 50+ clinical, demographic, and medication features
- **Target Variable:** `readmitted` (values: `<30` = 30-day readmission, `>30`, `NO`)

### Data Cleaning & Preprocessing
The analysis removes encounters that do not represent actionable readmission risk:

- **Dropped columns** with >80% missing data: `weight` (97%), `payer_code`, `medical_specialty`
- **Replaced** `?` (missing indicator) with `pd.NA`
- **Removed** death and hospice discharges (`discharge_disposition_id` ∈ {11, 13, 14, 19, 20, 21})
- **Kept first record per patient** to avoid duplicate encounters from multi-admit sequences
- **Final dataset:** 101,766 unique patient encounters

### Definitions
- **30-Day Readmission Rate (Primary Metric):** Percentage of patients readmitted within 30 days of discharge
- **Any-Day Readmission Rate (Secondary Metric):** Percentage readmitted at any time post-discharge (>30 days included)
  - SQL queries distinguish both metrics to prevent conflation

---

## Key Findings

### 1. **Age & Readmission**
Readmission risk rises with age, then stabilizes:
- **20–30 age bracket:** Peak at ~14% readmission rate
- **40–90 age range:** Gradual decline, stabilizing around 10–11%
- **90–100 age range:** Slight dip (possible survivorship bias in data)

### 2. **Medical Specialty Variation**
High-acuity specialties carry elevated readmission risk:
- **Hematology/Oncology:** ~14.5% readmission rate
- **Nephrology:** ~13.8%
- **Physical Medicine & Rehabilitation:** ~13.6%
- **Surgery-Vascular:** ~12.8%
- **Cardiology:** ~11.2%

### 3. **Length of Stay vs. Readmission**
Average length of stay is **4.40 days**. Extended hospitalizations correlate with modestly higher readmission rates, suggesting either disease severity or inadequate discharge planning.

---

## Technical Implementation

### SQL Analysis (`diabetes.sql`)
- **Data Exploration:** Total encounters, patient counts, encounter deduplication
- **Readmission Calculations:** 30-day vs. any-day readmission rates with `CASE` aggregation
- **Stratified Analysis:** Readmission by age group, medical specialty, and length of stay
- **Window Functions:** 
  - `RANK()` to identify longest hospital stays within each age group
  - Running totals of 30-day readmissions across age groups using `SUM() OVER (ORDER BY age)`
- **Filtering:** `HAVING count(*) > 100` excludes rare specialties from bias

### Python Analysis (`diabetic_analysis.py`)
- **Libraries:** Pandas, Matplotlib
- **Workflow:**
  1. Load CSV; inspect dimensions and head rows
  2. Clean missing values and drop high-missingness columns
  3. Deduplicate by patient ID (keep first encounter)
  4. Filter out hospice/death discharges
  5. Engineer binary target: `readmitted_30days` (1 if `readmitted == '<30'`, else 0)
  6. Group-by analysis: readmission rate by age, length of stay, admission type
  7. Visualize distributions with bar charts

### Power BI Dashboards
Interactive visualizations with dynamic filters:
- **Time in Hospital Chart:** Bivariate plot showing length of stay vs. readmission rate
- **Medical Specialty Chart:** Horizontal bar chart ranking specialties by readmission rate
- **Age Group Chart:** Bar chart of readmission rate by age bracket
- **Detailed Table:** Row-level age/encounter/readmission breakdown with scrollable filters for gender, age range, and specialty

---

## Repository Structure

```
diabetes-readmission-risk-analysis/
├── README.md                          # This file
├── diabetes.sql                       # SQL exploratory and analytical queries
├── diabetic_analysis.py               # Python data cleaning and analysis
├── diabetic_dashboard.pbix            # Power BI interactive dashboard (if included)
├── IMG_20260213_232330.jpg            # Power BI screenshot
└── diabetic_data.csv                  # Raw dataset (if available in repo)
```

---

## Key Metrics & Query Examples

### 30-Day Readmission Rate (Overall)
```sql
SELECT 
  COUNT(*) AS total_encounters,
  ROUND(COUNT(CASE WHEN readmitted = '<30' THEN 1 END) * 100.0 / COUNT(*), 2) AS readmission_rate_pct
FROM diabetes_hospital_data;
```
**Result:** 11,392 / 101,766 = **11.16%**

### Readmission by Medical Specialty (30-Day Definition)
```sql
SELECT 
  medical_specialty,
  ROUND(COUNT(CASE WHEN readmitted = '<30' THEN 1 END) * 100.0 / COUNT(*), 2) AS readmission_rate_pct
FROM diabetes_hospital_data
GROUP BY medical_specialty
HAVING COUNT(*) > 100
ORDER BY readmission_rate_pct DESC;
```

### Window Function: Highest-Acuity Patients by Age
```sql
SELECT 
  age, 
  patient_nbr, 
  time_in_hospital,
  readmitted,
  RANK() OVER (PARTITION BY age ORDER BY time_in_hospital DESC) AS stay_rank
FROM diabetes_hospital_data
WHERE readmitted = '<30'
ORDER BY age, stay_rank;
```

---

## Usage

### Prerequisites
- Python 3.7+
- Pandas, Matplotlib
- SQL database (PostgreSQL, MySQL, or SQLite) with loaded dataset
- Power BI Desktop (optional, for interactive visualization)

### Run the Analysis

**Python:**
```bash
python diabetic_analysis.py
```
Outputs summary statistics and matplotlib bar charts for age, length of stay, and admission type.

**SQL:**
Load `diabetes.sql` into your database and execute queries incrementally. Queries are commented to distinguish 30-day vs. any-day readmission metrics.

### Load Data into SQL
```bash
# PostgreSQL example
psql -U username -d diabetes_db -c "\COPY diabetes_hospital_data FROM 'diabetic_data.csv' WITH (FORMAT csv, HEADER true);"
```

---

## Limitations & Caveats

1. **No Predictive Model:** This is exploratory analysis, not a classifier. Findings describe associations, not causal drivers of readmission.

2. **Historical Data:** Dataset spans 1999–2008; modern readmission risk factors (telehealth, newer medications, post-COVID patterns) may differ.

3. **Survivorship Bias:** Patients discharged to hospice or deceased on index admission are excluded, potentially inflating readmission rates for surviving cohorts.

4. **Unmeasured Confounding:** Social determinants (income, housing stability, transportation) are not in this dataset and likely explain some readmission variance.

5. **Specialty Bias:** Specialties with <100 encounters are excluded to avoid noise; rare conditions may be underrepresented.

---

## Next Steps

To extend this analysis:

- **Predictive Modeling:** Engineer interaction terms and apply classification algorithms (Logistic Regression, Random Forest, Gradient Boosting) with hyperparameter tuning and cross-validation
- **Medication Impact:** Analyze diabetes medication changes (`metformin`, `insulin`, etc.) as pre/post-discharge risk factors
- **Network Analysis:** Map readmission pathways—which discharge destinations predict return to which departments?
- **Temporal Trends:** Stratify 1999–2008 data by year to detect shifts in readmission risk over time
- **Clinical Segmentation:** Cluster patients by diagnosis codes and length of stay; build specialty-specific risk profiles

---

## Contact & Attribution

**Author:** Sakshi Hulke  
**Email:** sakshihulke11@gmail.com  
**GitHub:** [github.com/sakshihulke11-oss](https://github.com/sakshihulke11-oss)

**Dataset Citation:**  
Strack, B., DeShazo, J.P., Gennings, C., Olmo, J.L., Ventura, S., Cios, K.J., & Clore, J.N. (2014). "Impact of HbA1c Measurement on Hospital Readmission Rates: Analysis of 70,000 Clinical Database Patient Records." *BioMed Research International*, 2014.  
Available: UCI Machine Learning Repository – [Diabetes 130-US Hospitals Dataset](https://archive.ics.uci.edu/dataset/296/diabetes+130-us+hospitals+for+years+1999-2008)

---

## License

This project is provided for educational and portfolio purposes.

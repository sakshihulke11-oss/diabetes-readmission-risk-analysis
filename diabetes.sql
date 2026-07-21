DROP TABLE IF EXISTS diabetes_hospital_data;

CREATE TABLE diabetes_hospital_data (
encounter_id BIGINT,
patient_nbr BIGINT,
race VARCHAR(50),
gender VARCHAR(20),
age VARCHAR(20),
weight VARCHAR(20),
admission_type_id INT,
discharge_disposition_id INT,
admission_source_id INT,
time_in_hospital INT,
payer_code VARCHAR(20),
medical_specialty VARCHAR(100),
num_lab_procedures INT,
num_procedures INT,
num_medications INT,
number_outpatient INT,
number_emergency INT,
number_inpatient INT,
diag_1 VARCHAR(20),
diag_2 VARCHAR(20),
diag_3 VARCHAR(20),
number_diagnoses INT,
max_glu_serum VARCHAR(20),
a1cresult VARCHAR(20),
metformin VARCHAR(20),
repaglinide VARCHAR(20),
nateglinide VARCHAR(20),
chlorpropamide VARCHAR(20),
glimepiride VARCHAR(20),
acetohexamide VARCHAR(20),
glipizide VARCHAR(20),
glyburide VARCHAR(20),
tolbutamide VARCHAR(20),
pioglitazone VARCHAR(20),
rosiglitazone VARCHAR(20),
acarbose VARCHAR(20),
miglitol VARCHAR(20),
troglitazone VARCHAR(20),
tolazamide VARCHAR(20),
examide VARCHAR(20),
citoglipton VARCHAR(20),
insulin VARCHAR(20),
glyburide_metformin VARCHAR(20),
glipizide_metformin VARCHAR(20),
glimepiride_pioglitazone VARCHAR(20),
metformin_rosiglitazone VARCHAR(20),
metformin_pioglitazone VARCHAR(20),
change VARCHAR(10),
diabetesmed VARCHAR(10),
readmitted VARCHAR(20)
);

select * from diabetes_hospital_data;

--total encounters and patients
select count(*) as total_encounters,
count(distinct patient_nbr) as total_patients
from diabetes_hospital_data;

-- FIX: the original query here used readmitted <> 'NO', which counts BOTH
-- <30-day and >30-day readmissions as "readmitted." That's a different,
-- broader metric than the 11.16% headline number in the README, which only
-- counts <30-day readmissions. Both numbers are now shown side by side and
-- clearly labeled so they can't be confused with each other.
select
count(*) as total_encounters,
round(count(case when readmitted = '<30' then 1 end)*100.0/count(*), 2) as readmission_rate_30day_pct,
round(count(case when readmitted <> 'NO' then 1 end)*100.0/count(*), 2) as readmission_rate_any_pct
from diabetes_hospital_data;

--Readmission by age group (30-day definition, matches README/Python)
select age,
round(count(case when readmitted = '<30' then 1 end)*100.0/count(*), 2) as readmission_rate_30day_pct
from diabetes_hospital_data
group by age
order by readmission_rate_30day_pct desc;

--departments wise Readmission rate (30-day definition, matches README/Python)
select medical_specialty,
round(count(case when readmitted = '<30' then 1 end)*100.0/count(*), 2) as readmission_rate_30day_pct
from diabetes_hospital_data
group by medical_specialty
having count(*) > 100
order by readmission_rate_30day_pct desc;

--Average length of stay & readmission rate
select medical_specialty,
avg(time_in_hospital) as avg_stay,
round(count(case when readmitted = '<30' then 1 end)*100.0/count(*), 2) as readmission_rate_30day_pct
from diabetes_hospital_data
group by medical_specialty;

-- ranking patients by stay duration within each age group
SELECT
age,
patient_nbr,
time_in_hospital,
readmitted,
RANK() OVER (PARTITION BY age ORDER BY time_in_hospital DESC) AS stay_rank_in_age_group
FROM diabetes_hospital_data
WHERE readmitted = '<30'
ORDER BY age, stay_rank_in_age_group;

-- running total of readmissions across age groups
SELECT
age,
COUNT(*) AS total_patients,
SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmitted_30days,
SUM(SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END)) OVER (ORDER BY age) AS running_total
FROM diabetes_hospital_data
GROUP BY age
ORDER BY age;

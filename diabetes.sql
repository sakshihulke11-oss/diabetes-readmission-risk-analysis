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

total encounters and patients 
select count(*) as total_encounters,
count(distinct patient_nbr) as total_patients 
from diabetes_hospital_data;

Overall readmission rate
select 
count(case when readmitted <> 'NO' then 1 end)*100.0/count(*) as readmission_rate
from diabetes_hospital_data;

Readmission by age group
select age,
count(case when readmitted <> 'NO' then 1 end) * 100.0/count(*) as readmission_rate
from diabetes_hospital_data
group by age
order by readmission_rate desc;

departments wise Readmission rate
select medical_specialty,
count(case when readmitted <> 'NO' then 1 end)* 100/count(*) as readmission_rate
from diabetes_hospital_data
group by medical_specialty
having count(*) > 100
order by readmission_rate desc;

Average length of stay & readmission rate
select medical_specialty,
avg(time_in_hospital) as avg_stay,
count(case when readmitted <> 'NO' then 1 end)*100.0/count(*) as readmission_rate
from diabetes_hospital_data
group by medical_specialty;











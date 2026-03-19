import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

df = pd.read_csv("diabetic_data.csv")
print(df.shape)
print(df.head())

# dataset uses ? for missing values
df.replace('?', np.nan, inplace=True)

# these columns had too many missing values, not useful
df.drop(columns=['weight', 'payer_code', 'medical_specialty'], inplace=True)

# keeping only first encounter per patient
df = df.drop_duplicates(subset='patient_nbr', keep='first')

# patients who expired or went to hospital can't be readmitted so removing them
df = df[df['discharge_disposition_id'].isin([11, 13, 14, 19, 20, 21])]

print("after cleaning:", df.shape)

# readmission target - 1 means readmitted within 30 days
df['readmitted_30days'] = df['readmitted'].apply(lambda x: 1 if x == '<30' else 0)

total = len(df)
readmitted = df['readmitted_30days'].sum()
rate = round(readmitted / total * 100, 2)

print(f"Total Encounters : {total}")
print(f"Readmitted 30days: {readmitted}")
print(f"Readmission Rate : {rate}%")

# -----------------------------------------------
# Age Group Analysis
# -----------------------------------------------

age_map = {
    '[0-10)' : 'Child',
    '[10-20)': 'Teen',
    '[20-30)': 'Young Adult',
    '[30-40)': 'Adult',
    '[40-50)': 'Adult',
    '[50-60)': 'Middle Age',
    '[60-70)': 'Senior',
    '[70-80)': 'Senior',
    '[80-90)': 'Elderly',
    '[90-100)': 'Elderly'
}
df['age_group'] = df['age'].map(age_map)

age_summary = df.groupby('age_group')['readmitted_30days'].agg(
    total='count',
    readmitted='sum'
)
age_summary['readmission_rate_%'] = round(
    age_summary['readmitted'] / age_summary['total'] * 100, 2
)
print("\nReadmission by Age Group:")
print(age_summary.sort_values('readmission_rate_%', ascending=False))

# -----------------------------------------------
# Length of Stay
# -----------------------------------------------

avg_los = round(df['time_in_hospital'].mean(), 2)
print(f"\nAverage Length of Stay: {avg_los} days")

los_summary = df.groupby('time_in_hospital')['readmitted_30days'].agg(
    total='count',
    readmitted='sum'
)
los_summary['readmission_rate_%'] = round(
    los_summary['readmitted'] / los_summary['total'] * 100, 2
)
print("\nReadmission by Length of Stay:")
print(los_summary)

# -----------------------------------------------
# Admission Type Analysis
# -----------------------------------------------

admission_map = {
    1: 'Emergency',
    2: 'Urgent',
    3: 'Elective',
    4: 'Newborn',
    7: 'Trauma Center'
}
df['admission_type'] = df['admission_type_id'].map(admission_map).fillna('Other')

adm_summary = df.groupby('admission_type')['readmitted_30days'].agg(
    total='count',
    readmitted='sum'
)
adm_summary['readmission_rate_%'] = round(
    adm_summary['readmitted'] / adm_summary['total'] * 100, 2
)
print("\nReadmission by Admission Type:")
print(adm_summary.sort_values('readmission_rate_%', ascending=False))

# -----------------------------------------------
# High Risk Patient Identification
# elderly + emergency + long stay
# -----------------------------------------------

df['high_risk'] = (
    (df['age'].isin(['[70-80)', '[80-90)', '[90-100)'])) &
    (df['admission_type_id'] == 1) &
    (df['time_in_hospital'] >= 7)
).astype(int)

hr_count = df['high_risk'].sum()
hr_rate = round(df[df['high_risk'] == 1]['readmitted_30days'].mean() * 100, 2)
print(f"\nHigh Risk Patients   : {hr_count}")
print(f"Their Readmission Rate: {hr_rate}%")

# -----------------------------------------------
# Visualizations
# -----------------------------------------------

# readmission rate by age group
plt.figure(figsize=(10, 5))
plot_data = age_summary.sort_values('readmission_rate_%')
plt.barh(plot_data.index, plot_data['readmission_rate_%'], color='steelblue')
plt.xlabel('Readmission Rate (%)')
plt.title('30-Day Readmission Rate by Age Group')
plt.tight_layout()
plt.savefig('readmission_by_age.png')
plt.show()


# readmission rate by admission type
plt.figure(figsize=(9, 5))
plt.bar(adm_summary.index, adm_summary['readmission_rate_%'], color='coral')
plt.xticks(rotation=25)
plt.ylabel('Readmission Rate (%)')
plt.title('Readmission Rate by Admission Type')
plt.tight_layout()
plt.savefig('readmission_by_admission.png')
plt.show()

print("\ndone")
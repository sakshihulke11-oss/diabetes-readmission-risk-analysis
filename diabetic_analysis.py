import pandas as pd
import matplotlib.pyplot as plt

# Load data
df = pd.read_csv("diabetic_data.csv")

print(df.shape)
print(df.head())

# Replace missing values
df.replace("?", pd.NA, inplace=True)

# Remove columns with too many missing values
df.drop(columns=["weight", "payer_code", "medical_specialty"], inplace=True)

# Keep first record of each patient
df.drop_duplicates("patient_nbr", inplace=True)

# Remove death and hospice cases
df = df[~df["discharge_disposition_id"].isin([11, 13, 14, 19, 20, 21])]

print("Cleaned data:", df.shape)


# Create 30-day readmission
df["readmitted_30days"] = 0
df.loc[df["readmitted"] == "<30", "readmitted_30days"] = 1


# Finding 1: Overall readmission
print("\n30-Day Readmission:")
print(df["readmitted_30days"].value_counts())

print(
    "Readmission Rate:",
    round(df["readmitted_30days"].mean() * 100, 2),
    "%"
)


# Finding 2: Readmission by Age
age_result = df.groupby("age")["readmitted_30days"].mean() * 100

print("\nReadmission by Age:")
print(age_result.round(2).sort_values(ascending=False))


# Finding 3: Readmission by Length of Stay
stay_result = df.groupby("time_in_hospital")["readmitted_30days"].mean() * 100

print("\nReadmission by Length of Stay:")
print(stay_result.round(2))


# Finding 4: Readmission by Admission Type
admission_result = df.groupby("admission_type_id")["readmitted_30days"].mean() * 100

print("\nReadmission by Admission Type:")
print(admission_result.round(2))


# Chart 1: Age
age_result.plot(kind="bar", figsize=(10, 5))

plt.title("30-Day Readmission by Age")
plt.ylabel("Readmission Rate (%)")
plt.xlabel("Age Group")
plt.tight_layout()
plt.show()


# Chart 2: Length of Stay
stay_result.plot(kind="bar", figsize=(10, 5))

plt.title("30-Day Readmission by Length of Stay")
plt.ylabel("Readmission Rate (%)")
plt.xlabel("Days in Hospital")
plt.tight_layout()
plt.show()

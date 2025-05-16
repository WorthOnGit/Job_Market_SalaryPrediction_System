import pandas as pd

df = pd.read_pickle("data/cleaned_salary_data.pkl")

X = df.drop(['salary_year_avg', 'job_id', 'company_id'], axis=1)
y = df['salary_year_avg']

print(X.shape)
print(y.shape)

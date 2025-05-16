from sqlalchemy import create_engine
import pandas as pd

# Replace with your credentials
username = 'postgres'
password = 'pass123'
host = 'localhost'
port = '5432'
database = 'postgres'

engine = create_engine(f'postgresql+psycopg2://{username}:{password}@{host}:{port}/{database}')

query = "SELECT * FROM model_features;"
df = pd.read_sql(query, engine)

print(df.shape)

# -------
# DATA CLEANING

skill_cols = [col for col in df.columns if col.startswith('has_')]
df[skill_cols] = df[skill_cols].fillna(0).astype(int)
df['skill_count'] = df['skill_count'].fillna(0).astype(int)

df['job_schedule_type'] = df['job_schedule_type'].fillna('Unknown')
df = df.dropna(subset=['job_country'])


df['job_work_from_home'] = df['job_work_from_home'].astype(int)

# -------

df.to_pickle("data/cleaned_salary_data.pkl")




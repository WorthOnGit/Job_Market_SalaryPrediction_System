

CREATE VIEW base_job_features AS
SELECT 
    job_id,
    job_title_short,
    job_country,
    job_work_from_home,
    job_schedule_type,
    company_id,
    CASE
        WHEN job_no_degree_mention IS TRUE THEN 0
        ELSE 1
    END AS job_degree_required
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL AND salary_year_avg BETWEEN 25000 AND 400000;


------

CREATE VIEW job_skill_counts AS
SELECT
  job_id,
  COUNT(*) AS skill_count
FROM skills_job_dim
GROUP BY job_id;


CREATE VIEW job_skill_flags AS
SELECT
  job_id,
  MAX(CASE WHEN LOWER(sd.skills) = 'python' THEN 1 ELSE 0 END) AS has_python,
  MAX(CASE WHEN LOWER(sd.skills) = 'sql' THEN 1 ELSE 0 END) AS has_sql,
  MAX(CASE WHEN LOWER(sd.skills) = 'aws' THEN 1 ELSE 0 END) AS has_aws,
  MAX(CASE WHEN LOWER(sd.skills) = 'r' THEN 1 ELSE 0 END) AS has_r,
  MAX(CASE WHEN LOWER(sd.skills) = 'excel' THEN 1 ELSE 0 END) AS has_excel,
  MAX(CASE WHEN LOWER(sd.skills) = 'tableau' THEN 1 ELSE 0 END) AS has_tableau,
  MAX(CASE WHEN LOWER(sd.skills) = 'spark' THEN 1 ELSE 0 END) AS has_spark,
  MAX(CASE WHEN LOWER(sd.skills) = 'azure' THEN 1 ELSE 0 END) AS has_azure,
  MAX(CASE WHEN LOWER(sd.skills) = 'power bi' THEN 1 ELSE 0 END) AS has_power_bi,
  MAX(CASE WHEN LOWER(sd.skills) = 'hadoop' THEN 1 ELSE 0 END) AS has_hadoop
FROM skills_job_dim sjd
JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
GROUP BY job_id;

CREATE VIEW job_skill_features AS
SELECT 
  sc.job_id,
  sc.skill_count,
  sf.has_python,
  sf.has_sql,
  sf.has_aws,
  sf.has_r,
  sf.has_excel,
  sf.has_tableau,
  sf.has_spark,
  sf.has_azure,
  sf.has_power_bi,
  sf.has_hadoop
FROM job_skill_counts sc
LEFT JOIN job_skill_flags sf ON sc.job_id = sf.job_id


------

CREATE VIEW company_aggregates AS
SELECT
  company_id,
  COUNT(*) AS company_job_count,
  ROUND(AVG(salary_year_avg)) AS company_avg_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
  AND salary_year_avg BETWEEN 25000 AND 400000
GROUP BY company_id;

------

CREATE VIEW model_features AS
SELECT 
  b.job_id,
  b.job_title_short,
  b.job_country,
  b.job_work_from_home,
  b.job_schedule_type,
  b.job_degree_required,
  b.company_id,

  s.skill_count,
  s.has_python,
  s.has_sql,
  s.has_aws,
  s.has_r,
  s.has_excel,
  s.has_tableau,
  s.has_spark,
  s.has_azure,
  s.has_power_bi,
  s.has_hadoop,

  c.company_job_count,
  c.company_avg_salary,

  jpf.salary_year_avg 
FROM base_job_features b
LEFT JOIN job_skill_features s ON b.job_id = s.job_id
LEFT JOIN company_aggregates c ON b.company_id = c.company_id
JOIN job_postings_fact jpf ON b.job_id = jpf.job_id;



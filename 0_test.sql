-- 787,686 jobs
SELECT COUNT(*) AS tjob_postings
FROM job_postings_fact

-- 259 skills
SELECT COUNT(*) AS tskills
FROM skills_dim

-- 3,669,604 mappings
SELECT COUNT(*) AS tskill_mapping
FROM skills_job_dim

-- 140,033 companies
SELECT COUNT(*) AS tcompanies
FROM company_dim

--------------------------------

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'job_postings_fact';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'skills_dim';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'skills_job_dim';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'company_dim';

--------------------------------

SELECT
  COUNT(*) FILTER (WHERE salary_year_avg IS NOT NULL) * 100.0 / COUNT(*) AS percent_filled_year,
  COUNT(*) FILTER (WHERE salary_hour_avg IS NOT NULL) * 100.0 / COUNT(*) AS percent_filled_hour
FROM job_postings_fact;


SELECT
  MIN(salary_year_avg) AS min_ysalary,
  MAX(salary_year_avg) AS max_ysalary,
  AVG(salary_year_avg) AS avg_ysalary,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_year_avg) AS median_ysalary,
  STDDEV(salary_year_avg) AS std_ysalary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL;

SELECT
  MIN(salary_hour_avg) AS min_hsalary,
  MAX(salary_hour_avg) AS max_hsalary,
  AVG(salary_hour_avg) AS avg_hsalary,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_hour_avg) AS median_hsalary,
  STDDEV(salary_hour_avg) AS std_hsalary
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL;


SELECT job_title_short,
       COUNT(*) AS postings,
       ROUND(AVG(salary_year_avg)) AS avg_salary,
       ROUND(MIN(salary_year_avg)) AS min_salary,
       ROUND(MAX(salary_year_avg)) AS max_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short
ORDER BY avg_salary DESC
LIMIT 20;

SELECT job_title_short,
       COUNT(*) AS postings,
       ROUND(AVG(salary_hour_avg)) AS avg_salary,
       ROUND(MIN(salary_hour_avg)) AS min_salary,
       ROUND(MAX(salary_hour_avg)) AS max_salary
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
GROUP BY job_title_short
ORDER BY avg_salary DESC
LIMIT 20;

-- 21 outliers
SELECT COUNT(*) AS outlier_count_year
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
  AND (salary_year_avg < 25000 OR salary_year_avg > 400000);

-- 129 outliers
SELECT COUNT(*) AS outlier_count_hour
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
  AND (salary_hour_avg < 15 OR salary_hour_avg > 150);


-- 22,013 jobs reported (target variable)
SELECT COUNT(*) AS count_ysalary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
  AND NOT (salary_year_avg < 25000 OR salary_year_avg > 400000)

-- 10,536 jobs reported
SELECT COUNT(*) AS count_hsalary
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
  AND NOT (salary_hour_avg < 15 OR salary_hour_avg > 150)


ALTER TABLE job_postings_fact
DROP COLUMN salary_hour_avg;

--------------------

SELECT *
FROM job_postings_fact
WHERE (salary_year_avg BETWEEN 25000 AND 400000)

-------------------

SELECT
  COUNT(DISTINCT sjd.job_id) AS jobs_with_skills,
  COUNT(DISTINCT jpf.job_id) AS total_jobs,
  ROUND(COUNT(DISTINCT sjd.job_id) * 100.0 / COUNT(DISTINCT jpf.job_id), 2) AS percent_with_skills
FROM job_postings_fact jpf
LEFT JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id;


SELECT
  sd.skills,
  COUNT(*) AS times_used
FROM skills_job_dim sjd
JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
GROUP BY sd.skills
ORDER BY times_used DESC
LIMIT 25;


SELECT
  COUNT(*) AS num_jobs,
  ROUND(AVG(skill_count), 2) AS avg_skills_per_job,
  MIN(skill_count) AS min_skills,
  MAX(skill_count) AS max_skills
FROM (
  SELECT job_id, COUNT(*) AS skill_count
  FROM skills_job_dim
  GROUP BY job_id
) sub;








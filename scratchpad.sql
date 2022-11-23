CREATE TABLE job (
    JOB_ID SERIAL NOT NULL,
    JOB_TITLE VARCHAR(100) NOT NULL
);
ALTER TABLE
    job ADD PRIMARY KEY(JOB_ID);
CREATE TABLE department(
    DEPARTMENT_ID SERIAL NOT NULL,
    DEPARTMENT_NM VARCHAR(50) NOT NULL,
    MANAGER VARCHAR(50) NOT NULL
);
ALTER TABLE
    department ADD PRIMARY KEY(DEPARTMENT_ID);
CREATE TABLE education(
    EDUCATION_ID SERIAL NOT NULL,
    EDUCATION_LEVEL VARCHAR(50) NOT NULL
);
ALTER TABLE
    education ADD PRIMARY KEY(EDUCATION_ID);
CREATE TABLE location(
    LOCATION_ID SERIAL NOT NULL,
    LOCATION_NM VARCHAR(50) NOT NULL,
    ADDRESS VARCHAR(100) NOT NULL,
    CITY VARCHAR(50) NOT NULL,
    STATE VARCHAR(2) NOT NULL
);
CREATE TABLE employee(
    EMP_ID VARCHAR(8) NOT NULL,
    EMP_NM VARCHAR(50) NOT NULL,
    EMAIL VARCHAR(100) NOT NULL,
    HIRE_DT DATE NOT NULL,
    SALARY INT NOT NULL,
    START_DT DATE NOT NULL,
    END_DT DATE,
    JOB_ID INT NOT NULL,
    DEPARTMENT_ID INT NOT NULL,
    LOCATION_ID INT NOT NULL,
    EDUCATION_ID INT NOT NULL
);
ALTER TABLE
    employee ADD PRIMARY KEY(EMP_ID);
ALTER TABLE
    employee ADD CONSTRAINT employee_job_id_unique UNIQUE(JOB_ID);
ALTER TABLE
    employee ADD CONSTRAINT employee_department_id_unique UNIQUE(DEPARTMENT_ID);
ALTER TABLE
    employee ADD CONSTRAINT employee_location_id_unique UNIQUE(LOCATION_ID);
ALTER TABLE
    employee ADD CONSTRAINT employee_education_id_unique UNIQUE(EDUCATION_ID);
ALTER TABLE
    location ADD PRIMARY KEY(LOCATION_ID);
ALTER TABLE
    employee ADD CONSTRAINT employee_job_id_foreign FOREIGN KEY(JOB_ID) REFERENCES job(JOB_ID);
ALTER TABLE
    employee ADD CONSTRAINT employee_department_id_foreign FOREIGN KEY(DEPARTMENT_ID) REFERENCES department(DEPARTMENT_ID);
ALTER TABLE
    employee ADD CONSTRAINT employee_education_id_foreign FOREIGN KEY(EDUCATION_ID) REFERENCES education(EDUCATION_ID);
ALTER TABLE
    employee ADD CONSTRAINT employee_location_id_foreign FOREIGN KEY(LOCATION_ID) REFERENCES location(LOCATION_ID);

INSERT INTO job (JOB_TITLE)
SELECT job_title from proj_stg;

INSERT INTO department (DEPARTMENT_NM, MANAGER)
SELECT department_nm, manager from proj_stg;

INSERT INTO education (EDUCATION_LEVEL)
SELECT education_lvl from proj_stg;

INSERT INTO location (LOCATION_NM, ADDRESS, CITY, STATE)
SELECT location, address, city, state from proj_stg;

INSERT INTO employee (EMP_ID, EMP_NM, EMAIL, HIRE_DT, SALARY, START_DT, END_DT, JOB_ID, DEPARTMENT_ID, LOCATION_ID, EDUCATION_ID)
SELECT CAST(Emp_ID as VARCHAR(8)), CAST(Emp_NM as VARCHAR(50)), CAST(email as VARCHAR(100)), CAST(hire_dt as DATE), CAST(salary as INT), CAST(start_dt as DATE), CAST(end_dt as DATE), JOB_ID, DEPARTMENT_ID, LOCATION_ID, EDUCATION_ID  
FROM proj_stg
JOIN job on job.JOB_TITLE = proj_stg.job_title
JOIN department on department.DEPARTMENT_NM = proj_stg.department_nm
JOIN location on location.LOCATION_NM = proj_stg.location
JOIN education on education.EDUCATION_LEVEL = proj_stg.education_lvl;

select * from proj_stg limit 10;


-- CRUD
-- Question 1: Return a list of employees with Job Titles and Department Names
select emp_nm, job_title, department_nm
from employee_job
join employee on employee.emp_id = employee_job.emp_id
join job on job.job_id = employee_job.job_id
join department on department.department_id = employee_job.department_id;

-- Question 2: Insert Web Programmer as a new job title
insert into job(JOB_TITLE) values ('Web Programmer');
select * from job;

-- Question 3: Correct the job title from web programmer to web developer
update job
set JOB_TITLE = 'Web Developer'
where JOB_TITLE = 'Web Programmer';

-- Question 4: Delete the job title Web Developer from the database
delete from job
where JOB_TITLE = 'Web Developer';

-- Question 5: How many employees are in each department?
select department_nm, count(EMP_ID) as employee_number 
from employee_job
join department on department.DEPARTMENT_ID = employee_job.DEPARTMENT_ID
group by department_nm;

-- Question 6: Write a query that returns current and past jobs (include employee name, job title, department, manager name, start and end date for position) for employee Toni Lembeck.
select EMP_NM, JOB_TITLE, DEPARTMENT_NM, MANAGER, START_DT, END_DT
from employee_job
join employee on employee.EMP_ID =  employee_job.EMP_ID
join job on job.JOB_ID = employee_job.JOB_ID
join department on department.DEPARTMENT_ID = employee_job.DEPARTMENT_ID
where EMP_NM = 'Toni Lembeck';


-- STANDOUT SUGGESTION 
-- Create a view that returns all employee attributes; results should resemble initial Excel file
create view full_table as
select emp_nm, email, job_title, department_nm, manager, salary, education_level, location_nm, address, city, state
from employee_job
join employee on employee.emp_id = employee_job.emp_id
join job on job.job_id = employee_job.job_id
join department on department.department_id = employee_job.department_id
join education on education.EDUCATION_ID = employee_job.EDUCATION_ID
join location on location.LOCATION_ID = employee_job.LOCATION_ID;

select * from full_table limit 10;

-- Create a stored procedure with parameters that returns current and past jobs (include employee name, job title, department, manager name, start and end date for position) when given an employee name.
create or replace function employee_jobs(employee_nm varchar(50))
returns table(
    EMP_NM varchar(50), 
    JOB_TITLE varchar(100), 
    DEPARTMENT_NM varchar(50), 
    MANAGER varchar(50), 
    START_DT date, 
    END_DT date
)
language plpgsql
as $$
begin
return query select employee.EMP_NM, job.JOB_TITLE, department.DEPARTMENT_NM, department.MANAGER, employee_job.START_DT, employee_job.END_DT
from employee_job
join employee on employee.EMP_ID =  employee_job.EMP_ID
join job on job.JOB_ID = employee_job.JOB_ID
join department on department.DEPARTMENT_ID = employee_job.DEPARTMENT_ID
where employee.EMP_NM = employee_nm;
end;
$$;

-- Implement user security on the restricted salary attribute.
create user NotManager password '1234';
grant connect on database postgres to NotManager
grant select on department, education, employee, employee_job, job, location to NotManager;
revoke all on NotManager from salary;
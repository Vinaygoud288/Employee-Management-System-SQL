-----------              Employee Management System using SQL          --------

/* 
PROJECT OBJECTIVE : To design and develop an Employee Management System using SQL to efficiently store, manage, and analyze employee, 
                        department, salary, and leave data in a structured database.                                
                                                                                              */
                        
/* 
 DATA DESCIPTION: 

Table name	       Description
JobDepartment :   Stores job roles, departments, and related salary ranges
SalaryBonus	  :   Contains salary, bonus, and annual pay linked to specific job roles.
Employee	  :   Maintains personal, contact, and login details of all employees.
Qualification :   Records qualifications and required skills for employee job positions.
Leaves	      :   Tracks employee leave records with reasons and dates.
Payroll	      :   Combines employee, job, salary, and leave data to calculate net payments.      */

-- CREATING DATABASE

CREATE DATABASE PROJECTDB;

-- USING THE DATABASE

USE PROJECTDB;

-- CREATING JOB DEPARTMENT TABLE

CREATE TABLE JOBDEPARTMENT (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);

-- CREATING TABLE SALARYBONUS

CREATE TABLE SALARYBONUS (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
 
 -- CREATING TABLE EMPLOYEE
 
 CREATE TABLE EMPLOYEE (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
	REFERENCES JobDepartment(Job_ID)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);

-- CREATING TABLE QUALIFICATION

CREATE TABLE QUALIFICATION (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- CREATING TABLE LEAVES

CREATE TABLE LEAVES (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- CREATING TABLE PAYROLL

CREATE TABLE PAYROLL(
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- 1. EMPLOYEE INSIGHTS

-- HOW MANY UNIQUE EMPLOYEES ARE CURRENTLY IN THE SYSTEM?

SELECT COUNT(distinct emp_ID) AS TOTAL_UNIQUE_EMPLOYEES
FROM employee;

-- WHICH DEPARTMENT HAVE THE HIGHEST NUMBER OF EMPLOYEES?

SELECT jd.jobdept,COUNT(e.emp_ID) AS TotalEmployees
FROM employee e 
JOIN jobdepartment jd
ON e.Job_ID = jd.Job_ID
GROUP BY jobdept
LIMIT 1;

-- WHAT IS THE AVERAGE SALARY PER DEPARTMENT?

SELECT jd.jobdept,AVG(s.annual+s.bonus) AS Average_salary
FROM salarybonus s 
JOIN jobdepartment jd
ON s.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;

-- WHO ARE THE TOP 5 HIGHEST-PAID EMPLOYEES?

SELECT e.emp_ID,e.firstname,s.annual+s.bonus AS Totalsalary
FROM employee e
JOIN salarybonus s
ON e.Job_ID = s.Job_ID
ORDER BY Totalsalary DESC
LIMIT 5;
 
-- WHAT IS THE TOTAL SALARY EXPENDITURE ACROSS A COMPANY?

SELECT SUM(annual+bonus) AS Total_Expenditure 
FROM salarybonus;

-- 2.JOB ROLE AND DEPARTMENT ANALYSIS

-- HOW MANY DIFFERENT JOB ROLES EXIST IN EACH DEPARTMENT?

-- RENAMING NAME COLUMN TO ROLE IN JOBDEPARTMENT TABLE

ALTER TABLE JOBDEPARTMENT
RENAME COLUMN name TO role;

SELECT JOBDEPT,COUNT(DISTINCT role)  AS Number_roles
FROM JOBDEPARTMENT
GROUP BY JOBDEPT;

-- WHAT IS THE AVERAGE SALARY RANGE PER DEPARTMENT?

SELECT jd.jobdept,CONCAT(MIN(s.annual + s.bonus),"-",MAX(s.annual + s.bonus)) AS Salary_range
FROM salarybonus s
JOIN jobdepartment jd
ON s.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;

-- WHICH JOB ROLES OFFER THE HIGHEST SALARY?
 
SELECT jd.role,(s.annual+s.bonus) AS TotalSalary
FROM jobdepartment jd
JOIN salarybonus s
ON jd.Job_ID = s.Job_ID
ORDER BY TotalSalary DESC
LIMIT 1;
 
 -- WHICH DEPARTMENTS HAVE HIGHEST TOTAL SALARY ALLOCATION?
 
 SELECT jd.jobdept,sum(s.annual+s.bonus) as Total_Salary_Allocation
 FROM jobdepartment jd
 JOIN salarybonus s
 ON jd.Job_ID = s.Job_Id
 GROUP BY jd.jobdept
 ORDER BY Total_Salary_Allocation DESC;
 
 -- 3.QUALIFICATION AND SKILL ANALYSIS
 
 -- HOW MANY EMPLOYEES HAVE ATLEAST ONE QUALIFICATION LISTED?
 
 SELECT COUNT(DISTINCT q.EMP_ID) AS Total_employees_with_qualification
 FROM qualification q
 JOIN employee e 
 ON e.emp_ID = q.EMP_ID;
 
 -- WHICH POSITIONs REQUIRE the MOST QUALIFICATIONS?
 
  SELECT jd.role,count(DISTINCT q.Emp_ID) AS Total_Number_Qualifications
  FROM jobdepartment jd
  JOIN employee e
  ON jd.Job_ID = e.Job_ID
  JOIN qualification q
  ON e.emp_ID = q.Emp_ID
  GROUP BY jd.role
  ORDER BY Total_Number_Qualifications DESC;
  
  -- WHICH EMPLOYEES HAVE THE HIGHEST NUMBER OF QUALIFICATION?
  
  SELECT e.emp_Id,e.firstname,COUNT(q.Requirements) AS Total_Number_Qualifications
  FROM employee e
  JOIN qualification q
  ON e.emp_ID = q.Emp_Id
  GROUP BY e.emp_Id,e.firstname
  ORDER BY Total_Number_Qualifications DESC;
  
  -- 4.LEAVE AND ABSENCE PATTERNS
  
  -- WHICH YEAR HAD THE MOST EMPLOYEES TAKING LEAVES
  
  SELECT YEAR(DATE) AS Year_Most_leaves,
  COUNT(DISTINCT emp_ID) AS Total_Number_Employees
  FROM leaves
  GROUP BY YEAR(DATE)
  ORDER BY Total_Number_Employees DESC
  LIMIT 1;
  
  -- WHAT IS THE AVERAGE NUMBER OF LEAVE DAYS TAKEN BY ITS EMPLOYEES PER DEPARTMENT
  
  SELECT jobdept,AVG(leave_count) AS average_leaves_count
  FROM(
  SELECT e.emp_ID,jd.jobdept,count(l.emp_id) AS leave_count
  FROM leaves l
  JOIN employee e 
  ON l.emp_ID = e.emp_ID
  JOIN jobdepartment jd
  ON e.Job_ID = jd.Job_ID
  GROUP BY e.emp_ID,jd.jobdept ) AS dept_leaves
  GROUP BY jobdept;
  
  -- WHICH EMPLOYEES HAVE TAKEN THE MOST LEAVES?
  
  SELECT e.emp_ID,e.firstname,COUNT(l.emp_ID) AS leave_count
  FROM leaves l 
  JOIN employee e
  ON l.emp_ID = e.emp_ID
  GROUP BY e.emp_ID,e.firstname
  ORDER BY leave_count DESC; 
  
  -- WHAT IS THE TOTAL NUMBER OF LEAVE DAYS TAKEN COMPANY-WIDE?
  
  SELECT COUNT(emp_ID) AS Total_Number_Leaves
  FROM leaves;
  
  -- HOW DO LEAVE DAYS CORRELATE WITH PAYROLL AMOUNTS?

SELECT e.emp_ID,e.firstname,
    COUNT(l.emp_ID) AS total_leaves,
    (s.annual + s.bonus) AS payroll_amount
FROM employee e
JOIN leaves l
    ON e.emp_ID = l.emp_ID
JOIN salarybonus s
    ON e.Job_ID = s.Job_ID
GROUP BY e.emp_ID, e.firstname
ORDER BY total_leaves DESC;
 
 -- 5. PAYROLL AND COMPENSATION ANALYSIS
 
 -- WHAT IS THE TOTAL MONTHLY PAYROLL PROCESSED?
 
 SELECT SUM(total_amount) AS total_monthly_payroll
 FROM payroll;
 
 -- WHAT IS THE AVERAGE BONUS GIVEN PER DEPARTMENT?
 
 SELECT jd.jobdept,AVG(s.bonus) AS Average_Department_Bonus
 FROM salarybonus s 
 JOIN jobdepartment jd 
 ON s.Job_ID = jd.Job_ID
 GROUP BY jd.jobdept;
 
 -- WHICH DEPARTMENT RECEIVES THE HIGHEST TOTAL BONUSES?
 
 SELECT jd.jobdept,SUM(s.bonus) AS Total_dept_bonus
 FROM salarybonus s
 JOIN jobdepartment jd
 ON s.Job_ID = jd.Job_ID
 GROUP BY jd.jobdept
 ORDER BY Total_dept_bonus DESC
 LIMIT 1;
 
 -- WHAT IS THE AVERAGE VALUE OF TOTAL_AMOUNT AFTER CONSIDERING LEAVE DEDUCTIONS?
 
 SELECT AVG(total_amount) as avg_total_amount
 FROM payroll;
 
 
 -- Challenges

-- Defining correct table relationships and ensuring accurate use of foreign keys.
-- Maintaining data consistency with cascading updates and deletes.
-- Writing complex joins for reports involving employee roles, leaves, and payroll.
-- Ensuring all date fields follow the YYYY-MM-DD format for reliable time-based analysis.
-- Preventing duplicate entries using unique constraints, especially on email fields

 

 
 




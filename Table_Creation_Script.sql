-- Create database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'medicalrocket')
    CREATE DATABASE medicalrocket;
GO

USE medicalrocket;
GO

--------------------------------------------------------------
-- DROP existing objects safely
--------------------------------------------------------------
-- Tables with constraints removed in correct order
DECLARE @sql NVARCHAR(MAX);

-- Drop tables in order to avoid FK conflicts
SET @sql = N'
IF OBJECT_ID(''billing'', ''U'') IS NOT NULL DROP TABLE billing;
IF OBJECT_ID(''med_prescription'', ''U'') IS NOT NULL DROP TABLE med_prescription;
IF OBJECT_ID(''med_sales'', ''U'') IS NOT NULL DROP TABLE med_sales;
IF OBJECT_ID(''med_inventory'', ''U'') IS NOT NULL DROP TABLE med_inventory;
IF OBJECT_ID(''medicine_master'', ''U'') IS NOT NULL DROP TABLE medicine_master;
IF OBJECT_ID(''lab_report_results'', ''U'') IS NOT NULL DROP TABLE lab_report_results;
IF OBJECT_ID(''test'', ''U'') IS NOT NULL DROP TABLE test;
IF OBJECT_ID(''room'', ''U'') IS NOT NULL DROP TABLE room;
IF OBJECT_ID(''employee_paychecks'', ''U'') IS NOT NULL DROP TABLE employee_paychecks;
IF OBJECT_ID(''employee_speciality'', ''U'') IS NOT NULL DROP TABLE employee_speciality;
IF OBJECT_ID(''speciality'', ''U'') IS NOT NULL DROP TABLE speciality;
IF OBJECT_ID(''employee_master'', ''U'') IS NOT NULL DROP TABLE employee_master;
IF OBJECT_ID(''departments'', ''U'') IS NOT NULL DROP TABLE departments;
IF OBJECT_ID(''patient_insurance'', ''U'') IS NOT NULL DROP TABLE patient_insurance;
IF OBJECT_ID(''patient_emergency_contact'', ''U'') IS NOT NULL DROP TABLE patient_emergency_contact;
IF OBJECT_ID(''patient_master'', ''U'') IS NOT NULL DROP TABLE patient_master;
';

EXEC sp_executesql @sql;
GO

--------------------------------------------------------------
-- CREATE Tables
--------------------------------------------------------------
-- Patient Master
CREATE TABLE patient_master (
    patient_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_firstname VARCHAR(50) NOT NULL,
    patient_lastname VARCHAR(50) NOT NULL,
    patient_dateofbirth DATE NOT NULL,
    patient_phone VARCHAR(10) NOT NULL,
    patient_emailaddress VARCHAR(50) NOT NULL UNIQUE,
    patient_addressline1 VARCHAR(100) NOT NULL,
    patient_addressline2 VARCHAR(100),
    patient_city VARCHAR(50) NOT NULL,
    patient_state VARCHAR(50) NOT NULL,
    patient_zip CHAR(10) NOT NULL,
    patient_login_password VARCHAR(50) NOT NULL
);
GO

-- Patient Emergency Contact
CREATE TABLE patient_emergency_contact (
    patient_ec_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_ec_patient_id INT NOT NULL,
    patient_ec_name VARCHAR(50) NOT NULL,
    patient_ec_phone VARCHAR(10) NOT NULL,
    patient_ec_email_address VARCHAR(50) NOT NULL,
    CONSTRAINT fk_patient_ec_patient_id FOREIGN KEY (patient_ec_patient_id) REFERENCES patient_master(patient_id)
);
GO

-- Patient Insurance
CREATE TABLE patient_insurance (
    patient_in_line_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_in_patient_id INT NOT NULL,
    patient_in_policy_no VARCHAR(100) NOT NULL UNIQUE,
    patient_in_startdate DATE NOT NULL,
    patient_in_expiration_date DATE NOT NULL,
    patient_in_company_name VARCHAR(100) NOT NULL,
    patient_in_copay INT NOT NULL,
    patient_in_med_coverage INT NOT NULL,
    CONSTRAINT fk_patient_insurance_pid FOREIGN KEY (patient_in_patient_id) REFERENCES patient_master(patient_id)
);
GO

-- Departments
CREATE TABLE departments (
    department_code VARCHAR(20) PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL
);
GO

-- Employee Master
CREATE TABLE employee_master (
    employee_id INT IDENTITY(1,1) PRIMARY KEY,
    employee_designation VARCHAR(50) NOT NULL,
    employee_name VARCHAR(50) NOT NULL,
    employee_dateofbirth DATE NOT NULL,
    employee_phone VARCHAR(10) NOT NULL,
    employee_emailaddress VARCHAR(50) NOT NULL UNIQUE,
    employee_hiredate DATE NOT NULL,
    employee_enddate DATE,
    employee_password VARCHAR(50) NOT NULL,
    employee_department VARCHAR(20) NOT NULL,
    CONSTRAINT fk_employee_dept_id FOREIGN KEY (employee_department) REFERENCES departments(department_code)
);
GO

-- Speciality
CREATE TABLE speciality (
    speciality_code VARCHAR(10) PRIMARY KEY,
    speciality_name VARCHAR(50) NOT NULL
);
GO

-- Employee Speciality Mapping
CREATE TABLE employee_speciality (
    speciality_mapping_id INT IDENTITY(1,1) PRIMARY KEY,
    speciality_code VARCHAR(10) NOT NULL,
    employee_id INT NOT NULL,
    CONSTRAINT fk_emp_spec_id FOREIGN KEY (speciality_code) REFERENCES speciality(speciality_code),
    CONSTRAINT fk_emp_spec_emp_id FOREIGN KEY (employee_id) REFERENCES employee_master(employee_id)
);
GO

-- Employee Paychecks
CREATE TABLE employee_paychecks (
    emp_paycheck_id INT IDENTITY(1,1) PRIMARY KEY,
    emp_paycheck_empid INT NOT NULL,
    paycheck_hourly_rate MONEY NOT NULL,
    paycheck_hours_worked FLOAT NOT NULL,
    paycheck_total_compensation MONEY NOT NULL,
    CONSTRAINT fk_emp_paycheck_emp_master FOREIGN KEY (emp_paycheck_empid) REFERENCES employee_master(employee_id)
);
GO

-- Room
CREATE TABLE room (
    room_no INT PRIMARY KEY,
    room_type VARCHAR(20) NOT NULL,
    room_status VARCHAR(20) NOT NULL,
    room_rate MONEY NOT NULL,
    room_occupation_start_date DATE,
    room_occupation_end_date DATE,
    room_occupation_number_of_days INT,
    room_patient_id INT,
    CONSTRAINT fk_room_patient_id FOREIGN KEY (room_patient_id) REFERENCES patient_master(patient_id)
);
GO

-- Test
CREATE TABLE test (
    test_code VARCHAR(20) PRIMARY KEY,
    test_name VARCHAR(50) NOT NULL,
    test_type VARCHAR(50) NOT NULL,
    test_cost MONEY NOT NULL
);
GO

-- Lab Report Results
CREATE TABLE lab_report_results (
    lab_report_id INT IDENTITY(1,1) PRIMARY KEY,
    lab_report_res_test_code VARCHAR(20) NOT NULL,
    lab_report_results_date DATE NOT NULL,
    result_status VARCHAR(50) NOT NULL,
    lab_report_result_description VARCHAR(2000),
    lab_report_rs_patient_id INT NOT NULL,
    lab_report_rs_prescribed_by INT NOT NULL,
    lab_report_rs_generated_by INT,
    CONSTRAINT fk_lab_report_result_patient FOREIGN KEY (lab_report_rs_patient_id) REFERENCES patient_master(patient_id),
    CONSTRAINT fk_lab_report_result_prescribed_by FOREIGN KEY (lab_report_rs_prescribed_by) REFERENCES employee_master(employee_id),
    CONSTRAINT fk_lab_report_result_generated_by FOREIGN KEY (lab_report_rs_generated_by) REFERENCES employee_master(employee_id),
    CONSTRAINT fk_lab_report_result_test_code FOREIGN KEY (lab_report_res_test_code) REFERENCES test(test_code)
);
GO

-- Medicine Master
CREATE TABLE medicine_master (
    medicine_SKU INT IDENTITY(1,1) PRIMARY KEY,
    medicine_name VARCHAR(50) NOT NULL UNIQUE,
    medicine_type VARCHAR(50) NOT NULL,
    medicine_description VARCHAR(100),
    medicine_manufacturer VARCHAR(50) NOT NULL
);
GO

-- Medicine Inventory
CREATE TABLE med_inventory (
    med_inv_line_id INT IDENTITY(1,1) PRIMARY KEY,
    med_inv_batch_no VARCHAR(10) NOT NULL,
    med_inv_medicine_SKU INT NOT NULL,
    med_inv_quantity_open INT NOT NULL DEFAULT 0,
    med_inv_onhand_quantity INT NOT NULL DEFAULT 0,
    med_inv_mfg_date DATE,
    med_inv_exp_date DATE,
    med_inv_price MONEY NOT NULL DEFAULT 0,
    CONSTRAINT fk_med_inv_medicine_SKU FOREIGN KEY (med_inv_medicine_SKU) REFERENCES medicine_master(medicine_SKU)
);
GO

-- Med Sales
CREATE TABLE med_sales (
    med_sales_trac_no INT IDENTITY(1,1) PRIMARY KEY,
    med_sales_patient_id INT NOT NULL,
    med_sales_medicine_SKU INT NOT NULL,
    med_sales_inv_line_id INT NOT NULL,
    med_sales_quantity INT NOT NULL,
    med_sales_price MONEY NOT NULL,
    med_sales_total_cost AS (med_sales_quantity * med_sales_price) PERSISTED,
    CONSTRAINT fk_med_sales_patient_id FOREIGN KEY (med_sales_patient_id) REFERENCES patient_master(patient_id),
    CONSTRAINT fk_med_sales_med_SKU FOREIGN KEY (med_sales_medicine_SKU) REFERENCES medicine_master(medicine_SKU),
    CONSTRAINT fk_med_sales_line_id FOREIGN KEY (med_sales_inv_line_id) REFERENCES med_inventory(med_inv_line_id)
);
GO

-- Med Prescription
CREATE TABLE med_prescription (
    med_prescription_id INT IDENTITY(1,1) PRIMARY KEY,
    med_patient_id INT NOT NULL,
    med_prescribed_by_emp_id INT NOT NULL,
    med_medicine_SKU INT,
    med_prescription_morning_dosage FLOAT,
    med_prescription_afternoon_dosage FLOAT,
    med_prescription_evening_dosage FLOAT,
    CONSTRAINT fk_med_patient_id FOREIGN KEY (med_patient_id) REFERENCES patient_master(patient_id),
    CONSTRAINT fk_med_prec_emp_id FOREIGN KEY (med_prescribed_by_emp_id) REFERENCES employee_master(employee_id),
    CONSTRAINT fk_med_prec_medSKU FOREIGN KEY (med_medicine_SKU) REFERENCES med_inventory(med_inv_line_id)
);
GO

-- Billing
CREATE TABLE billing (
    bill_no INT IDENTITY(1,1) PRIMARY KEY,
    bill_patient_id INT NOT NULL,
    bill_total_amount MONEY NOT NULL,
    CONSTRAINT fk_bill_patient_id FOREIGN KEY (bill_patient_id) REFERENCES patient_master(patient_id)
);
GO

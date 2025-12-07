USE medicalrocket;
GO

-- Insert Patients
INSERT INTO patient_master 
(
    patient_firstname,
    patient_lastname,
    patient_dateofbirth,
    patient_phone,
    patient_emailaddress,
    patient_addressline1,
    patient_addressline2,
    patient_city,
    patient_state,
    patient_zip,
    patient_login_password
)
VALUES
(
    'Arnav',
    'Patil',
    '2000-05-01',
    '3157664881',
    'apatil07@syr.edu',
    'Syracuse',
    'Near Westcott Community Center',
    'Syracuse',
    'New York',
    '13210',
    'dbmsgroup26'
);
GO

-- Insert Emergency Contact
INSERT INTO patient_emergency_contact
(
    patient_ec_patient_id,
    patient_ec_name,
    patient_ec_phone,
    patient_ec_email_address
)
VALUES
(
    1,
    'Vipul',
    '1234567890',
    'hadoshi@syr.edu'
);
GO

-- Insert Insurance
INSERT INTO patient_insurance
(
    patient_in_patient_id,
    patient_in_policy_no,
    patient_in_startdate,
    patient_in_expiration_date,
    patient_in_company_name,
    patient_in_copay,
    patient_in_med_coverage
)
VALUES
(
    1,
    '1234567',
    '1995-05-06',
    '1999-06-01',
    'MED AND CO',
    2000,
    10000
);
GO

-- Insert Departments
INSERT INTO departments (department_code, department_name)
VALUES 
('CARD', 'Cardiology'),
('LAB', 'Lab Technician');
GO

-- Insert Employees
INSERT INTO employee_master
(
    employee_designation,
    employee_name,
    employee_dateofbirth,
    employee_phone,
    employee_emailaddress,
    employee_hiredate,
    employee_password,
    employee_department
)
VALUES
('Doctor', 'Harmish', '1995-05-06', '1234567892', 'hadoshi@syr.edu', '2000-06-19', 'abc123', 'CARD'),
('Lab Technician', 'Ritesh', '2000-06-20', '1234567892', 'rghorpad@syr.edu', '2000-06-19', 'abc123', 'LAB');
GO

-- Insert Speciality and Employee Speciality
INSERT INTO speciality(speciality_code, speciality_name) VALUES ('HS', 'Heart Surgeons');
INSERT INTO employee_speciality(speciality_code, employee_id) VALUES ('HS', 1);
GO

-- Insert Room
INSERT INTO room(room_no, room_type, room_status, room_rate, room_occupation_start_date, room_patient_id)
VALUES (1, 'Basic', 'Occupied', 25.50, '2022-12-01', 1);
GO

-- Insert Tests
INSERT INTO test(test_code, test_name, test_type, test_cost)
VALUES 
('COVID-19-instant', 'SARS-CoV-2', 'instant', 25),
('COVID-19-rtpcr', 'SARS-CoV-2', 'RTPCR', 25);
GO

-- Insert Lab Report Results
INSERT INTO lab_report_results
(
    lab_report_res_test_code,
    lab_report_results_date,
    result_status,
    lab_report_result_description,
    lab_report_rs_patient_id,
    lab_report_rs_prescribed_by,
    lab_report_rs_generated_by
)
VALUES
(
    'COVID-19-instant',
    '2019-06-19',
    'generated',
    'Covid Positive. Detected. Please be in quarantine for next 7 days.',
    1,
    1,
    1
);
GO

-- Insert Medicine
INSERT INTO medicine_master(medicine_name, medicine_type, medicine_description, medicine_manufacturer)
VALUES('Paracetamol', 'tablet', 'Generic Medicine', 'ABMCJ Pvt Ltd');
GO

-- Insert Inventory
INSERT INTO med_inventory(med_inv_batch_no, med_inv_medicine_SKU, med_inv_quantity_open, med_inv_onhand_quantity, med_inv_mfg_date, med_inv_exp_date, med_inv_price)
VALUES('ABC123', 1, 100, 50, '2022-05-06', '2024-05-06', 5);
GO

-- Insert Sales
INSERT INTO med_sales(med_sales_patient_id, med_sales_medicine_SKU, med_sales_inv_line_id, med_sales_price, med_sales_quantity)
VALUES(1, 1, 1, 5, 10);
GO

-- Insert Prescription
INSERT INTO med_prescription(med_patient_id, med_prescribed_by_emp_id, med_medicine_SKU, med_prescription_morning_dosage, med_prescription_afternoon_dosage, med_prescription_evening_dosage)
VALUES(1, 1, 1, 0.5, 1, 0.5);
GO

-- Insert Billing
INSERT INTO billing(bill_patient_id, bill_total_amount)
VALUES(1, 500);
GO

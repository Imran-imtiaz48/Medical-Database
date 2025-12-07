USE medicalrocket
GO

-- DOWN: drop existing objects
IF OBJECT_ID('proc_patient_report_results', 'P') IS NOT NULL DROP PROCEDURE proc_patient_report_results
GO
IF OBJECT_ID('proc_lab_prescription', 'P') IS NOT NULL DROP PROCEDURE proc_lab_prescription
GO
IF OBJECT_ID('v_patient_lab_test_records', 'V') IS NOT NULL DROP VIEW v_patient_lab_test_records
GO
IF OBJECT_ID('v_patient_details', 'V') IS NOT NULL DROP VIEW v_patient_details
GO


-- UP: create views and procedures
--------------------------------------------------------------
-- View: v_patient_details
--------------------------------------------------------------
CREATE VIEW v_patient_details AS
SELECT 
    p.patient_id,
    p.patient_firstname + ' ' + p.patient_lastname AS Patient_Name,
    p.patient_dateofbirth AS Date_of_Birth,
    r.room_no AS Room_Number,
    r.room_occupation_start_date AS Admission_Date
FROM patient_master p
LEFT JOIN room r ON p.patient_id = r.room_patient_id
GO


--------------------------------------------------------------
-- View: v_patient_lab_test_records
--------------------------------------------------------------
CREATE VIEW v_patient_lab_test_records AS
SELECT 
    l.lab_report_id,
    l.lab_report_rs_patient_id,
    p.patient_firstname + ' ' + p.patient_lastname AS Patient_Name,
    p.patient_emailaddress,
    t.test_name,
    t.test_type,
    t.test_cost,
    l.lab_report_results_date,
    l.result_status,
    l.lab_report_result_description,
    e.employee_name
FROM lab_report_results l
INNER JOIN test t ON t.test_code = l.lab_report_res_test_code
LEFT JOIN employee_master e ON e.employee_id = l.lab_report_rs_generated_by
INNER JOIN patient_master p ON p.patient_id = l.lab_report_rs_patient_id
GO


--------------------------------------------------------------
-- Procedure: proc_lab_prescription
--------------------------------------------------------------
CREATE PROCEDURE proc_lab_prescription
(
    @in_test_code VARCHAR(20),
    @in_patient_id INT,
    @in_employee_emailaddress VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @in_employee_id INT

    BEGIN TRY
        BEGIN TRANSACTION

        IF @in_test_code IS NULL OR @in_patient_id IS NULL OR @in_employee_emailaddress IS NULL
        BEGIN
            RAISERROR('Input parameters cannot be null', 16, 1)
            ROLLBACK
            RETURN
        END

        SELECT @in_employee_id = employee_id
        FROM employee_master
        WHERE employee_emailaddress = @in_employee_emailaddress

        IF @in_employee_id IS NULL
        BEGIN
            RAISERROR('Employee not found', 16, 1)
            ROLLBACK
            RETURN
        END

        INSERT INTO lab_report_results
        (
            lab_report_res_test_code,
            lab_report_results_date,
            result_status,
            lab_report_rs_patient_id,
            lab_report_rs_prescribed_by
        )
        VALUES
        (
            @in_test_code,
            CONVERT(date, GETDATE()),
            'prescribed',
            @in_patient_id,
            @in_employee_id
        )

        COMMIT
    END TRY
    BEGIN CATCH
        ROLLBACK
        RAISERROR('Error occurred while prescribing lab test', 16, 1)
    END CATCH
END
GO


--------------------------------------------------------------
-- Procedure: proc_patient_report_results
--------------------------------------------------------------
CREATE PROCEDURE proc_patient_report_results
(
    @in_lab_report_id INT,
    @in_patient_id INT,
    @in_employee_emailaddress VARCHAR(100),
    @in_test_result VARCHAR(2000)
)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @in_employee_id INT

    BEGIN TRY
        BEGIN TRANSACTION

        IF @in_lab_report_id IS NULL OR @in_patient_id IS NULL OR @in_employee_emailaddress IS NULL OR @in_test_result IS NULL
        BEGIN
            RAISERROR('Input parameters cannot be null', 16, 1)
            ROLLBACK
            RETURN
        END

        SELECT @in_employee_id = employee_id
        FROM employee_master
        WHERE employee_emailaddress = @in_employee_emailaddress

        IF @in_employee_id IS NULL
        BEGIN
            RAISERROR('Employee not found', 16, 1)
            ROLLBACK
            RETURN
        END

        UPDATE lab_report_results
        SET 
            lab_report_results_date = CONVERT(date, GETDATE()),
            result_status = 'generated',
            lab_report_result_description = @in_test_result,
            lab_report_rs_generated_by = @in_employee_id
        WHERE lab_report_id = @in_lab_report_id
        AND lab_report_rs_patient_id = @in_patient_id

        COMMIT
    END TRY
    BEGIN CATCH
        ROLLBACK
        RAISERROR('Error occurred while updating lab report results', 16, 1)
    END CATCH
END
GO

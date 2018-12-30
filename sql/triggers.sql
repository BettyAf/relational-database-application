DELIMITER $$

CREATE TRIGGER supervises_insert_check
BEFORE INSERT ON Supervises
FOR EACH ROW
BEGIN
	IF 
	(
		NEW.suborID NOT IN
		(
			/* gets IDs of all employees in supervisor's department */
			SELECT empID
			FROM Employee
			WHERE depID IN
				(
					/* gets supervisor's department */
					SELECT depID
					FROM Employee
					WHERE empID = NEW.superID
				)
		)
	)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Supervisor & subordinate must be in same department';
	END IF;
	IF (NEW.superID = NEW.suborID)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Supervisor & subordinate must be two different people';
	END IF;
	IF (NEW.suborID IN (SELECT superID FROM Supervises WHERE superID=NEW.suborID AND suborID=NEW.superID))
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Employees cannot be supervisors for their own supervisors.';
	END IF;
	IF (NEW.suborID IN (SELECT depManagerID FROM Department))
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Employees cannot be the supervisors for their own department manager.';
	END IF;
END$$

CREATE TRIGGER supervises_update_check
BEFORE UPDATE ON Supervises
FOR EACH ROW
BEGIN
	IF 
	(
		NEW.suborID NOT IN
		(
			/* gets IDs of all employees in supervisor's department */
			SELECT empID
			FROM Employee
			WHERE depID IN
				(
					/* gets supervisor's department */
					SELECT depID
					FROM Employee
					WHERE empID = NEW.superID
				)
		)
	)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Supervisor & subordinate must be in same department';
	END IF;
	IF (NEW.superID = NEW.suborID)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Supervisor & subordinate must be two different people';
	END IF;
	IF (NEW.suborID IN (SELECT depManagerID FROM Department))
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Employees cannot be the supervisors for their own department manager.';
	END IF;
	IF (NEW.suborID IN (SELECT superID FROM Supervises WHERE superID=NEW.suborID AND suborID=NEW.superID))
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Employees cannot be supervisors for their own supervisors.';
	END IF;
END$$


CREATE TRIGGER department_insert_check
BEFORE INSERT ON Department
FOR EACH ROW
BEGIN
	IF
	(
		(NEW.depManagerID IS NOT NULL)
		AND
		(NEW.depManagerID NOT IN
			(
				SELECT Employee.empID
				FROM Employee
				WHERE Employee.depID = NEW.depID
			)
		)
	)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Manager must be in department';
	END IF;
	IF ((NEW.depManagerID IS NULL) AND (NEW.depManagerStartDate IS NOT NULL))
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Cannot set a manager start date without the employee ID of the manager in question';
	END IF;
END$$

CREATE TRIGGER department_update_check
BEFORE UPDATE ON Department
FOR EACH ROW
BEGIN
	IF
	(
		(NEW.depManagerID IS NOT NULL)
		AND
		(NEW.depManagerID NOT IN
			(
				SELECT Employee.empID
				FROM Employee
				WHERE Employee.depID = NEW.depID
			)
		)
	)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Manager must be in department';
	END IF;
	IF (NEW.depManagerStartDate < (SELECT dob FROM Person,Employee WHERE Person.SIN=Employee.SIN AND Employee.empID=NEW.depManagerID))
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Employees cannot start managing companies before their date of birth.';
	END IF;
	IF ((NEW.depManagerID IS NULL) AND (NEW.depManagerStartDate IS NOT NULL))
	THEN
		SET NEW.depManagerStartDate=NULL;
	END IF;
END$$

CREATE TRIGGER hasdependent_insert_check
BEFORE INSERT ON HasDependent
FOR EACH ROW
BEGIN
	IF (NEW.benefactorID IN (SELECT Employee.empID FROM Employee WHERE Employee.SIN=NEW.dependentSIN))
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Benefactor & dependent cannot be the same person';
	END IF;
END$$

CREATE TRIGGER hasdependent_update_check
BEFORE UPDATE ON HasDependent
FOR EACH ROW
BEGIN
	IF (NEW.benefactorID IN (SELECT Employee.empID FROM Employee WHERE Employee.SIN=NEW.dependentSIN))
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Benefactor & dependent cannot be the same person';
	END IF;
END$$

-- tested & seems ok
-- NOTE: must disable safe update mode for this to work, so gotta verify if this is allowed at school computers...
-- if safe update mode isn't allowed, will get this: "Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect."
CREATE TRIGGER employee_update_check
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
	IF ((NEW.depID <> OLD.depID) OR ((NEW.depID IS NULL) AND (OLD.depID IS NOT NULL)))
	THEN
		UPDATE Department
		SET depManagerID=NULL
		WHERE depManagerID=OLD.empID;
		
		DELETE FROM ProjectLeader
		WHERE projLeaderID=OLD.empID;
		
		DELETE FROM Supervises
		WHERE superID=OLD.empID OR suborID=OLD.empID;
	END IF;
END$$

CREATE TRIGGER project_update_check
AFTER UPDATE ON Project
FOR EACH ROW
BEGIN
	IF ((OLD.projDepID <> NEW.projDepID) OR ((OLD.projDepID IS NOT NULL) AND (NEW.projDepID IS NULL)))
	THEN
		DELETE FROM ProjectLeader
		WHERE ProjectLeader.projID = OLD.projID;
	END IF;
END$$

CREATE TRIGGER hours_worked_insert_check
BEFORE INSERT ON HoursWorkedOnProject
FOR EACH ROW
BEGIN
	IF
		(
			/* new amt of hours on same day now exceeds 24 */
			(((SELECT SUM(hours)
			FROM HoursWorkedOnProject
			WHERE HoursWorkedOnProject.empID=NEW.empID AND HoursWorkedOnProject.day=NEW.day) + NEW.hours) > 24)
			OR
			(NEW.hours < 1)
		)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: For each employee, total hours worked in a day can only be between 1 and 24 (inclusive)';
	END IF;
	IF (NEW.day < (SELECT dob FROM Person,Employee WHERE Person.SIN=Employee.SIN AND Employee.empID=NEW.empID))
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Employees cannot start working before their date of birth.';
	END IF;
END$$


CREATE TRIGGER sin_nine_digits_insert_check
BEFORE INSERT ON Person
FOR EACH ROW
BEGIN
	IF (NEW.SIN < 100000000)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: SIN must be between 100000000 and 999999999 (inclusive)';
	END IF;
END$$

CREATE TRIGGER sin_nine_digits_update_check
BEFORE UPDATE ON Person
FOR EACH ROW
BEGIN
	IF (NEW.SIN < 100000000)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: SIN must be between 100000000 and 999999999 (inclusive)';
	END IF;
END$$

CREATE TRIGGER salary_min_wage_insert_check
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
	IF (NEW.salary < 11.25)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Employee hourly salary must at least meet the Quebec minimum wage ($11.25)';
	END IF;
END$$

CREATE TRIGGER salary_min_wage_update_check
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
	IF (NEW.salary < 11.25)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Employee hourly salary must at least meet the Quebec minimum wage ($11.25)';
	END IF;
END$$

CREATE TRIGGER proj_leader_insert
BEFORE INSERT ON ProjectLeader
FOR EACH ROW
BEGIN
	IF
	(
		NEW.projLeaderID NOT IN 
		(
			SELECT empID FROM Employee WHERE depID IN
			(
				SELECT projDepID FROM Project WHERE Project.projID=NEW.projID
			)
		)
	)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Project leader must be part of department.';
	END IF;
END$$

CREATE TRIGGER proj_leader_update
BEFORE UPDATE ON ProjectLeader
FOR EACH ROW
BEGIN
	IF
	(
		NEW.projLeaderID NOT IN 
		(
			SELECT empID FROM Employee WHERE depID IN
			(
				SELECT projDepID FROM Project WHERE Project.projID=NEW.projID
			)
		)
	)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Project leader must be part of department.';
	END IF;
END$$

CREATE TRIGGER cant_start_working_before_you_were_born_update
BEFORE UPDATE ON HoursWorkedOnProject
FOR EACH ROW
BEGIN
	IF (NEW.day < (SELECT dob FROM Person,Employee WHERE Person.SIN=Employee.SIN AND Employee.empID=NEW.empID))
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Employees cannot start working before their date of birth.';
	END IF;
	IF
		(	
			/* new amt of hours on same day now exceeds 24 */
			(((SELECT SUM(hours)
			FROM HoursWorkedOnProject
			WHERE HoursWorkedOnProject.empID=NEW.empID AND HoursWorkedOnProject.day=NEW.day) + (NEW.hours - OLD.hours)) > 24)
			OR
			(NEW.hours < 1)
		)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: For each employee, total hours worked in a day can only be between 1 and 24 (inclusive)';
	END IF;
END$$

DELIMITER ;
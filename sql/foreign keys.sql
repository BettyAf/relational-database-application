ALTER TABLE Department
ADD FOREIGN KEY fk_dep_manager(depManagerID)
REFERENCES Employee(empID)
ON DELETE SET NULL
ON UPDATE CASCADE;

ALTER TABLE Project
ADD FOREIGN KEY fk_proj_depid(projDepID) 
REFERENCES Department(depID)
ON DELETE SET NULL
ON UPDATE CASCADE;

ALTER TABLE ProjectLeader
ADD FOREIGN KEY fk_projleader_id(projLeaderID)
REFERENCES Employee(empID)
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE ProjectLeader
ADD FOREIGN KEY fk_projleader_projid(projID)
REFERENCES Project(projID)
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE Employee
ADD FOREIGN KEY fk_emp_sin(SIN)
REFERENCES Person(SIN)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Employee
ADD FOREIGN KEY fk_emp_depid(depID)
REFERENCES Department(depID)
ON DELETE SET NULL
ON UPDATE CASCADE;

ALTER TABLE HoursWorkedOnProject
ADD FOREIGN KEY fk_empid_worked_on_proj(empID)
REFERENCES Employee(empID)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE HoursWorkedOnProject
ADD FOREIGN KEY fk_projid_hours_on_proj (projID)
REFERENCES Project(projID)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE HasDependent
ADD FOREIGN KEY fk_benefactor(benefactorID)
REFERENCES Employee(empID)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE HasDependent
ADD FOREIGN KEY fk_dependent(dependentSIN)
REFERENCES Person(SIN)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Supervises
ADD FOREIGN KEY fk_supervisor(superID)
REFERENCES Employee(empID)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Supervises
ADD FOREIGN KEY fk_subordinate(suborID)
REFERENCES Employee(empID)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE DepartmentLocation
ADD FOREIGN KEY fk_deploc_depid(depID)
REFERENCES Department(depID)
ON DELETE CASCADE
ON UPDATE CASCADE;

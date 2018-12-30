CREATE TABLE Department(
	depID					INT(4) UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	depName					CHAR(30) UNIQUE NOT NULL,
	depManagerID			INT(8) UNSIGNED,
	depManagerStartDate		DATE
)ENGINE=InnoDB;

-- null is allowed on project leader ID by design, in case a project might be at any point where it is in between leaders
CREATE TABLE Project(
	projDepID		INT(4) UNSIGNED,
	projID			INT(8) UNSIGNED AUTO_INCREMENT,
	projName		CHAR(30) UNIQUE NOT NULL,
	projLocation	CHAR(100),
	projStage		ENUM('Preliminary', 'Intermediate', 'Advanced', 'Complete'),
	PRIMARY KEY(projID)
)ENGINE=InnoDB;

CREATE TABLE ProjectLeader(
	projID			INT(8) UNSIGNED PRIMARY KEY,
	projLeaderID	INT(8) UNSIGNED NOT NULL
)ENGINE=InnoDB;

-- could be an employe or a dependent
CREATE TABLE Person(
	SIN			INT(9) UNSIGNED PRIMARY KEY,
	name		CHAR(100) NOT NULL,
	dob			DATE NOT NULL,
	gender		ENUM('M', 'F')
)ENGINE=InnoDB;

-- salary is hourly
CREATE TABLE Employee(
	SIN			INT(9) UNSIGNED PRIMARY KEY,
	empID		INT(8) UNSIGNED UNIQUE NOT NULL AUTO_INCREMENT,
	depID		INT(4) UNSIGNED,
	cellNum		BIGINT(15) UNSIGNED,
	homeNum		BIGINT(15) UNSIGNED,
	address		CHAR(100),
	salary		DECIMAL(9,2) UNSIGNED
)ENGINE=InnoDB;

-- so that regular employees will have 8-digit IDs. IDs with less digits may still be allowed if manually entered
ALTER TABLE Employee AUTO_INCREMENT = 10000000;

-- keeps track of the amount of hours every employee has worked on a project on a specific day
-- this table can also be used to keep track on which project the employee is working or has worked on
CREATE TABLE HoursWorkedOnProject (
	projID		INT(8) UNSIGNED,
	empID		INT(8) UNSIGNED,
	day			DATE,
	hours		INT(2) UNSIGNED NOT NULL,
	PRIMARY KEY(projID, empID, day)
)ENGINE=InnoDB;

-- Can a dependent be someone employed in the company?
-- https://www.1040.com/tax-guide/taxes-for-families/who-can-you-claim/
CREATE TABLE HasDependent(
	benefactorID	INT(8) UNSIGNED,
	dependentSIN	INT(9) UNSIGNED,
	PRIMARY KEY(benefactorID, dependentSIN)
)ENGINE=InnoDB;

CREATE TABLE Supervises(
	superID		INT(8) UNSIGNED NOT NULL,
	suborID		INT(8) UNSIGNED,
	PRIMARY KEY (suborID)
)ENGINE=InnoDB;

-- a department may have multiple locations
CREATE TABLE DepartmentLocation(
	depID		INT(4) UNSIGNED,
	address		CHAR(100),
	PRIMARY KEY (depID, address)
)ENGINE=InnoDB;
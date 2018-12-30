-- calculate the stipend of employees based on the
-- hours she/he worked on different projects
SELECT w.empID, (sum( w.hours))* e.salary AS employeeStpend
FROM HoursWorkedOnProject w
JOIN (SELECT empID, salary
		FROM Employee ) AS e
ON w.empID = e.empID
GROUP BY empID
ORDER BY empID ASC;

-- who works under which employee
SELECT p.projID, p.projLeaderID, w.empID
FROM ProjectLeader p
JOIN (SELECT projID, empID
		FROM HoursWorkedOnProject) AS w
ON p.projID = w.projID;


-- How much each employee gets (per project)
SELECT w.empID, w.projID, (SUM(hours)*e.salary) AS salaryPerProject 
FROM HoursWorkedOnProject w
JOIN (SELECT empID, salary
		FROM Employee ) AS e 
ON w.empID = e.empID
GROUP BY w.projID, w.empID
ORDER BY empID ASC;

-- In what stage a project 
SELECT projID, projName, projStage
FROM Project; 

-- Who works on which project
SELECT empID, projID
FROM HoursWorkedOnProject
ORDER BY empID ASC;

-- List the project managed by each department
SELECT depID, projID
FROM Project
ORDER BY depID ASC;

-- Each employee is involved in most and least number projects?
SELECT x.empID,  MAX(x.num)AS maxProject
  FROM (SELECT empID, COUNT(DISTINCT projID) AS num
          FROM HoursWorkedOnProject) x;

SELECT x.empID,  MIN(x.num)AS minProject
  FROM (SELECT empID, COUNT(DISTINCT projID) AS num
          FROM HoursWorkedOnProject) x;

-- 4. What is the total pay for each project? 
SELECT w.projID, SUM(w.hours*e.salary)AS payToProject
FROM HoursWorkedOnProject w
JOIN (SELECT empID, salary
		FROM Employee ) AS e 
GROUP BY w.projID;

--For each department?
SELECT p.projDepID, SUM(q.payToProject) AS departmentRevenue
FROM Project p
JOIN (SELECT w.projID, SUM(w.hours*e.salary)AS payToProject
		FROM HoursWorkedOnProject w
		JOIN (SELECT empID, salary
				FROM Employee ) AS e 
		GROUP BY w.projID) AS q
ON q.projID = p.projID
GROUP BY p.projDepID;

-- For the company in a certain period?
SELECT SUM(w.hours * e.salary) As companyExpenditures
FROM HoursWorkedOnProject w
JOIN (SELECT empID, salary
		FROM Employee ) AS e 
WHERE w.day> '2018-04-01' AND w.day < '2018-04-05';

-- 5. Which department manager is also the manager of some projects?
SELECT depManagerID
FROM Department d
WHERE d.depManagerID IN (SELECT projLeaderID
							FROM Project);

-- 6. etc...
-- return the number of hours spent in total on a given project
SELECT p.projName, w.projID, (SUM(hours)) AS totalHours 
FROM HoursWorkedOnProject w
JOIN (SELECT projID, projName
        FROM Project ) AS p 
ON w.projID = p.projID
GROUP BY w.projID;

-- Average salary per department, along with both the names, employee IDs, and salaries of the highest & lowest-earning employees of each department respectively, in one table

SELECT m.depID, m.depName, m.averageSalary,
	n.highestEarnerName, n.highestEarnerID, n.highestSalary,
	n.lowestEarnerName, n.lowestEarnerID, n.lowestSalary
FROM
	(
		SELECT Employee.depID, depName, AVG(salary) AS averageSalary
		FROM Employee, Department
		WHERE Employee.depID=Department.depID
		GROUP BY Employee.depID
	) AS m
	INNER JOIN
	(
		SELECT a.depID, a.highestEarnerName, a.highestEarnerID, a.highestSalary, b.lowestEarnerName, b.lowestEarnerID, b.lowestSalary
		FROM
		(
			SELECT depID, name AS highestEarnerName, empID AS highestEarnerID, salary as highestSalary
			FROM Employee AS e1, Person AS p1
			WHERE p1.SIN=e1.SIN AND e1.empID NOT IN
			(
				SELECT a.empID
				FROM Employee AS a CROSS JOIN Employee AS b
				WHERE a.empID <> b.empID AND a.depID=b.depID AND a.salary < b.salary
			)
		) AS a
		INNER JOIN
		(
			SELECT depID, name AS lowestEarnerName, empID AS lowestEarnerID, salary as lowestSalary
			FROM Employee AS e2, Person AS p2
			WHERE p2.SIN=e2.SIN AND e2.empID NOT IN
			(
				SELECT a.empID
				FROM Employee AS a CROSS JOIN Employee AS b
				WHERE a.empID <> b.empID AND a.depID=b.depID AND a.salary > b.salary
			)
		) AS b
		WHERE a.depID=b.depID
	) AS n
WHERE m.depID=n.depID
ORDER BY depID;

-- List of employees (containing all of their attributes from People and Employee) who live in Montreal

SELECT depID, empID, name, dob, gender, address, salary, Employee.SIN
FROM Employee
INNER JOIN Person ON Employee.SIN=Person.SIN
WHERE address LIKE '%Montreal%'
ORDER BY depID, empID;
This project concerns the implementation of a database for a company that consists of several unique departments, each of which may have several locations, as well as the employees who work in various roles in that company and their dependents. The database is actively managed, using a series of triggers to monitor and address various changes to state.

## E/R Diagram

![1](https://user-images.githubusercontent.com/31786043/50550697-25523f00-0c43-11e9-840c-c61970e2a922.png)

This is a digital representation of the ER diagram that was used to determine how to design the schema, the original being hand-drawn. 

Employee is the primary entity, acting as an inheritor of Person’s attributes. Employee relates to Person through HasDependent (many:many; employees can have many dependants and share them in the case of spouses), determining dependants of employees, and to itself through Supervises (1:many, as a supervisor may have many subordinates, but a subordinate has one supervisor), which determines which employees supervise others. 

Employee then relates to Department through Manages to indicate which employee is in charge of a department (1:1; an employee may not lead more than 1 department, and a department may only have 1 head manager). Employee relates to Project to determine which project is led by which employee through LedBy (many: many; an employee may coordinate many projects alone or work in a team on one to several), and to HoursWorkedOnProject to determine which employee contributed hours during a day to a given project. 

WorkedBy, WorkedOn, and HoursWorkedOnProject are all weak, as the day alone does not constitute an identifying key: it must use the foreign keys from Employee and Project to create a unique identifier.

Departments may have many locations and share addresses between departments, allowing for the many:many relation between Location and Department.

## Design Decisions

Implementation of the ER diagram saw the creation of the following tables in the database:

●	Department

    ○	Identifies department and manager
●	DepartmentLocation

    ○	Identifies addresses of each department
●	Employee

    ○	Contains comprehensive identification for company employees
●	HasDependent

    ○	Identifies employee dependents, if any
●	HoursWorkedOnProject

     ○	Records how long employees work on projects each day
●	Person

    ○	Contains basic identifying information
●	Project

    ○	Records department, leader, name, stage, and location of project developments
●	Supervises

    ○	Identifies supervisors and subordinates
●	ProjectLeader

    ○	Identifies the employee leading a project

-- Stored procedure 1
/*
This stored procedure takes a row limit number, it takes in a total_salary variable in modifies it with new row limited value,
how many names start with the letter j variable (which gets changed in the body of the stored proc and returned with the new value.

How to use:  1st parameter: pass in a number for row_limiter parameter
			 2nd parameter: pass in a variable @emp_first_name_j
			 3rd parameter: pass in a variable @total_salary_row_limited
For example, call the stored procedure as so:
											call employees.stored_proc1(100, @emp_first_name_j, @total_salary_row_limited);
*/
delimiter //
create procedure employees.stored_proc1(in row_limiter int, out how_many_names_start_with_j int, inout total_salary decimal(25, 2))
begin
	-- sum row limited salary 
	select sum(salary)
    into total_salary
    from
	(	
		select salary
		from employees.salaries
        limit row_limiter
    ) as row_limited;
	
	-- Count total employees whose first name starts with 'j'
	select count(emp_no)
    into how_many_names_start_with_j
	from employees.employees
	where first_name like 'j%';
end//
delimiter ;

-- Stored procedure 2
/*
Stored procedure creates a table, then inserts to the table which employees make more than 90000.
It gets the total number of rows of that table. Then does a loop through the number and inserts into the who_made_90000_plus a detailed description
of if an employee makes more than or equal to 90000 or more than or equal to 100000 dollars in salary. 

How to use: simply call the stored procedure without parameter,

For example, call the stored procedure as so:
											call employees.stored_proc2();

*/
delimiter //
create procedure employees.stored_proc2()
begin
	-- These variables store important info used by statements
    declare salarygrp char(200);
    declare sal decimal(20, 2);
    declare cnt int(11);

	create table if not exists employees.who_made_90000_plus (
		id int(11) not null auto_increment primary key,
		emp_no int(11) not null references employees(emp_no),
		full_name char(200) not null,
		salary decimal(20, 2) not null,
        salary_group char(200)
	);
  
	-- insert into the table who_made_90000_plus who makes 90000 or more
	insert into employees.who_made_90000_plus (emp_no, full_name, salary)
			select emp_no
			,full_name
            ,salary
            from
			(
				select 	 e.emp_no
						,concat(first_name, ' ', last_name) as full_name
						,max(salary) as salary
				from employees.employees as e
				inner join employees.salaries as s
					on s.emp_no = e.emp_no
				group by e.emp_no
				having max(salary) >= 90000
		) as limited
		limit 100;
    
	-- Get count of employees for while loop
    select max(id)
    into cnt
    from employees.who_made_90000_plus;
    
	-- Determine who make 90000 or more or if they make 100000 or more
    while cnt > 0 do
		select salary
        into sal
        from employees.who_made_90000_plus
        where id = cnt;
        if sal >= 90000 and sal < 100000  then
			 set salarygrp = '90000 dollars or more';
		elseif sal >= 100000 then
			set salarygrp = '100000 dollars or more';
		end if;
        
		-- Update salary group in table
        update employees.who_made_90000_plus
			set salary_group = salarygrp
		where id = cnt;
	
        set cnt = cnt - 1;
	end while;
	
	-- Show results of previous statements
	select *
	from employees.who_made_90000_plus;
end//
delimiter ;

-- Stored procedure 3
/*
This stored procedure is takes in a employee number, birth date, first name, last name, gender letter, and hire date.
It uses that info and inserts it into the employees table. Then shows the inserted data to the user.

How to use:  1st parameter: pass in any number less than 10000 to ensure it is not taken.
			 2nd parameter: pass in a date in this format YYYY-MM-DD
			 3rd parameter: pass in a string first name
			 4th parameter: pass in a string last name
			 5th parameter: pass in a enum char (M, F)
			 6th parameter: pass in a date in this format YYYY-MM-DD
For example, call the stored procedure as so:
											call employees.stored_proc3(1, '2002-01-01', 'Billy', 'Bob', 'M', date(now()));

*/
delimiter //
create procedure employees.stored_proc3(in empno int(11), in birthdate date, in firstname char(14), in lastname char(16), in gen enum('M', 'F'), in hiredate date)
	begin 
		insert into employees.employees (emp_no, birth_date, first_name, last_name, gender, hire_date) 
        values (empno, birthdate, firstname, lastname, gen, hiredate);
		
		select *
		from employees.employees
		where emp_no = empno;
	end//
delimiter ;

-- Stored procedure 4
/*
Stored procedure takes a manager_no and then compares manager's salary to all of their employees
and sees who makes the most. It then tells the user who makes the most with a select statement.

How to use: pass in a emp_no of any manager from the dept_manager table. 

For example, call the stored procedure as so:
											call employees.stored_proc4(111692);

*/
delimiter //
create procedure employees.stored_proc4(in manager_no int(11))
	begin
		declare does_someone_make_more_than_then_manager int(1);
		
		-- Finds the salary of a manager and their employee and compares who makes the most
		select case when max(ms.salary) > max(emp_sal.salary) then 0
						 else 1 end
		into does_someone_make_more_than_then_manager
        from employees.salaries as ms
		inner join employees.dept_manager as manager
			on ms.emp_no = manager.emp_no
		inner join employees.dept_emp as de
			on manager.dept_no = de.dept_no
            and manager.emp_no != de.emp_no
		inner join employees.salaries as emp_sal
			on emp_sal.emp_no = de.emp_no
		where manager.emp_no = manager_no;
        
		-- 	This if statement blocks determines if manager makes more than their employees 
		--	or visa versa and conditional outputs to the screen based off that. 
        if does_someone_make_more_than_then_manager = 1 then
			select "Someone in a matter of fact make mores than the manager" as who_makes_more;
		else
			select "The manager makes more than every one else" as who_makes_more;
        end if;
	end//
delimiter ;

-- Stored Procedure 5
-- Reference: https://www.programiz.com/c-programming/examples/fibonacci-series
/*
This stored procedure takes in number of terms that the series will have and then will create the series and will finally list it to the user.

How to use: pass in a number that represents how many terms you want in the series. Keep in mind that the store procedure can only output up to 254 chars, 
so please use a reasonable number.

For example, call the stored procedure as so:
											call employees.stored_proc5(10);

*/
delimiter //
create procedure employees.stored_proc5(in num int(11))
    begin
		-- Declare variable needed by loop: first and second term of the sequence (0, 1), number that will hold the sum of the last two terms,
		-- and a char variable to give a char representation of the series.
		declare fib_sq char(254);
        declare number1 int(11);
        declare number2 int(11);
        declare number3 int(11);
        declare i int(11);
        set i = 1;
		set number1 = 0;
        set number2 = 1;
        set fib_sq = '';
        
		-- Loop through until all elements are created
		while i <= num do
			if i = 1 then
				set fib_sq = concat(fib_sq, number1);
			else
				set fib_sq = concat(fib_sq, ', ', number1);
			end if;
			set number3 = number1 + number2;
            set number1 = number2;
            set number2 = number3;
            set i = i + 1;
		end while;
		
		-- Show the series to the user
        select fib_sq;
	end//
delimiter ;
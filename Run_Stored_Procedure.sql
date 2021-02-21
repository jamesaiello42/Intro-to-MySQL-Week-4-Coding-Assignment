/*
Please read the Create_Stored_Procedures.sql or Week 4 Assignment 4.docx files for detail description of what each does and how to use.
*/

-- Note that running all of these could take up to 30 seconds

-- Use two numeric variables for the stored procedure parameters 2 and 3. The first parameter is numeric, but does not require a variable to be passed in 
call employees.stored_proc1(100, @emp_first_name_j, @total_salary_row_limited);
select	@emp_first_name_j,
		@total_salary_row_limited;

-- Stored Procedure takes 4 seconds, but is limited to 100 rows. This one has no parameters.
call employees.stored_proc2();

-- Pass in data to this procedure any id less than 10000 is a safe one to use.
call employees.stored_proc3(1, '2002-01-01', 'Billy', 'Bob', 'M', date(now()));

-- Pass in any emp_no from the dept_manager table
call employees.stored_proc4(111692);

-- Pass in a reasonable number to get a list of fibonacci numbers
call employees.stored_proc5(10); 
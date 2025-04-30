
--1.-- create a table with the name 'Hr_attrition'

Create table Hr_attrition
(Age varchar(max),	Attrition varchar(max),	BusinessTravel varchar(max),	DailyRate varchar(max),
Department varchar(max),	DistanceFromHome varchar(max),	Education varchar(max),	EducationField varchar(max),
EmployeeCount varchar(max),EmployeeNumber varchar(max),	EnvironmentSatisfaction varchar(max),	Gender varchar(max),
HourlyRate varchar(max),JobInvolvement varchar(max),JobLevel varchar(max),	JobRole	varchar(max),JobSatisfaction varchar(max),	
MaritalStatus varchar(max),MonthlyIncome varchar(max),	MonthlyRate varchar(max),	NumCompaniesWorked varchar(max),
Over18 varchar(max),OverTime varchar(max),	PercentSalaryHike varchar(max),	PerformanceRating varchar(max),	RelationshipSatisfaction varchar(max),
StandardHours varchar(max),	StockOptionLevel varchar(max),	TotalWorkingYears varchar(max),	TrainingTimesLastYear varchar(max),
WorkLifeBalance	 varchar(max),YearsAtCompany varchar(max),	YearsInCurrentRole varchar(max),YearsSinceLastPromotion varchar(max),
YearsWithCurrManager varchar(max))

--2-- with the information_schema

select Column_name, Data_type 
from INFORMATION_SCHEMA.columns
where Table_name='Hr_attrition'

--3--To import data from a CSV file into the Hr_attrition table in bulk

bulk insert Hr_attrition
from 'C:\Users\admin\Downloads\hr_attrition.csv'
with ( fieldterminator=',', Rowterminator='\n' , firstrow=2)

--4--To know the distinct attrition

Select distinct Attrition from Hr_attrition

--5--To know count of employees 

Select Attrition , count(attrition) as 'Cntof_emp' from hr_attrition
group by Attrition

--6--To know the overall attriton rate

select * from Hr_attrition

select (sum(case when Attrition ='Yes' then 1 else 0 End) * 100.00/Count(*)) as 'Overall_Attr_rate' from Hr_attrition

--7--To know the distinct age from attrition

select count(Distinct age) from Hr_attrition

--8--To know the min age and max age from attrition

select min(age) , max(age) from hr_attrition

--9--To create age band as well as attrition rate for all age groups

with Age_grp as (Select Age,Attrition, Case when Age between 18 And 25 then '18-25'
				When Age between 26 And 35 then '26-35'
				When Age between 36 and 45 then '36-45'
				When Age between 46 and 55 then '46-55'
				Else '55+' end as 'Age_band' from Hr_attrition)

Select age, Age_band, (sum(case when Attrition ='Yes' then 1 else 0 End) * 100.00/Count(*))  from Age_grp
group by age, age_band

--10--To create attrition rate for each age band

Select  Case when Age between 18 And 25 then '18-25'
				When Age between 26 And 35 then '26-35'
				When Age between 36 and 45 then '36-45'
				When Age between 46 and 55 then '46-55'
				Else '55+' end as 'Age_band',
(sum(case when Attrition ='Yes' then 1 else 0 End) * 100.00/Count(*)) as 'Age_band_Attr_rate'

from Hr_attrition
group by 
Case when Age between 18 And 25 then '18-25'
				When Age between 26 And 35 then '26-35'
				When Age between 36 and 45 then '36-45'
				When Age between 46 and 55 then '46-55'
				Else '55+' end
Order by Age_band_Attr_rate desc


--11--To know distinct monthly income

select distinct monthlyincome from hr_attrition

--12--to know min,avg and ,max monthlyincome

select Min(monthlyincome) , avg(monthlyincome), max(monthlyincome) from hr_attrition

--13--Calculate attrition rates across income quartiles using a JOIN on MonthlyIncome

with Inc_quartiles as (Select Monthlyincome, Ntile(4) over ( order by monthlyincome) as Income_group
from hr_attrition)

Select Income_group ,(sum(case when Attrition ='Yes' then 1 else 0 End) * 100.00/Count(*)) as 'Attr_rate' from hr_attrition h
join inc_quartiles IQ 
on h.monthlyincome=IQ.monthlyincome
group by income_group
order by Attr_rate desc

--14--To know if the employees who haven't been promoted for many years may have a higher attrition rate.

Select YearsSinceLastPromotion ,(sum(case when Attrition ='Yes' then 1 else 0 End) * 100.00/Count(*)) as 'Attr_rate' from hr_attrition 
group by YearsSinceLastPromotion
order by 'Attr_rate' desc

--15--To know the distinct distance from home 

Select Distinct distancefromhome from hr_attrition

--16--To know the min, max, avg and standard deviation of distance from home 

select min(distancefromhome) , avg(distancefromhome), STDEV(distancefromhome),  max(distancefromhome) from hr_attrition

--17--To know how the employess distance from home affects the attrition rate

select case when distancefromhome between 1 and 5 then 'near'
							  when distancefromhome between 6 and 12 then 'bit_far'
							  Else 'Far_from_office' end as 'Travel_km',
sum(case when Attrition='yes' then 1 else 0 end) *100.0/count(*)					
from hr_attrition
group by case when distancefromhome between 1 and 5 then 'near'
							  when distancefromhome between 6 and 12 then 'bit_far'
							  Else 'Far_from_office' end

---18-To know the distinct job role 

select Distinct jobrole from Hr_attrition

--19--To know employess distinct years at company

select distinct yearsatcompany from Hr_attrition


--20--To analyzing attrition rates for specific job roles (Sales Representative and Research Director) based on employee experience levels (YearsAtCompany).

Select Jobrole, case when yearsatcompany <2 then 'new_hires'
				when yearsatcompany between 3 and 8 then '3-5yrs'
				when yearsatcompany between 9 and 20 then '9-20yrs'
				when yearsatcompany between 21 and 35 then '21-35yrs'
				Else '>35yrs' end as 'exp_group',
				avg(monthlyincome) as 'avg_monthlyinc',
		Avg(yearssincelastpromotion) as 'avg_pro_yrs',
		count(case when attrition='yes' then 1 else 0 end) as 'totalcnt'
		, sum(case when attrition='yes' then 1 else 0 end) *100.0/count(*) as 'tot_attr_rate'
		from Hr_attrition
		where jobrole in ('sales representative', 'Research Director')
Group by jobrole,case when yearsatcompany <2 then 'new_hires'
				when yearsatcompany between 3 and 8 then '3-5yrs'
				when yearsatcompany between 9 and 20 then '9-20yrs'
				when yearsatcompany between 21 and 35 then '21-35yrs'
				Else '>35yrs' end
order by tot_attr_rate desc	

--21-To to analyze employee attrition based on job role, experience level, and job satisfaction and also understand which experience groups and job roles 
--have high attrition rates, while also considering job satisfaction levels.

with JSandJR_matrix as (select jobsatisfaction,Jobrole,case when yearsatcompany <2 then 'new_hires'
				when yearsatcompany between 3 and 8 then '3-5yrs'
				when yearsatcompany between 9 and 20 then '9-20yrs'
				when yearsatcompany between 21 and 35 then '21-35yrs'
				Else '>35yrs' end as 'expr_group', sum(case when attrition='yes' then 1 else 0 end) *100.0/count(*) as 'tot_attr_rate'
from Hr_attrition

group by jobsatisfaction, jobrole,case when yearsatcompany <2 then 'new_hires'
				when yearsatcompany between 3 and 8 then '3-5yrs'
				when yearsatcompany between 9 and 20 then '9-20yrs'
				when yearsatcompany between 21 and 35 then '21-35yrs'
				Else '>35yrs' end)

select expr_group, jobrole, avg(jobsatisfaction) as 'avg_rating', tot_attr_rate from JSandJR_matrix
group by expr_group, jobrole,tot_attr_rate
having avg(jobsatisfaction)>2
order by tot_attr_rate desc

--22--To analyze employee attrition rates based on their tenure at a company.

With Tenure_grp as ( select Employeenumber,case when yearsatcompany <2 then 'new_hires'
				when yearsatcompany between 3 and 8 then '3-5yrs'
				when yearsatcompany between 9 and 20 then '9-20yrs'
				when yearsatcompany between 21 and 35 then '21-35yrs'
				Else 'Long_tenure' end as 'Tenu_incomp',
				attrition from hr_attrition)
				-- this above query create group of exp in company
, attrition_bytenure as ( Select Tenu_incomp, count(*) as  Cnt_emp,
						sum(case when attrition='yes' then 1 else 0 end) as 'tot_attr_cnt',
						sum(case when attrition='yes' then 1 else 0 end) *100.0/count(*) as 'tot_attr_rate'
						from tenure_grp
						group by tenu_incomp )
						-- this subquery is using first CTE and creating group for attrcnt and attrrate for exp group
Select tenu_incomp, cnt_emp, tot_attr_cnt,tot_attr_rate
from attrition_bytenure
order by tot_attr_rate desc


--23--To analyzes employee attrition based on travel distance from home to office, grouped by gender. It provides insights into whether commuting distance 
--affects employee turnover.

Select gender,case when distancefromhome between 1 and 5 then 'near'
							  when distancefromhome between 6 and 12 then 'bit_far'
							  Else 'Far_from_office' end as 'Travel_km',
							  count(*) as  Cnt_emp,
						sum(case when attrition='yes' then 1 else 0 end) as 'tot_attr_cnt',
						sum(case when attrition='yes' then 1 else 0 end) *100.0/count(*) as 'tot_attr_rate'
						from Hr_attrition
						group by gender, case when distancefromhome between 1 and 5 then 'near'
							  when distancefromhome between 6 and 12 then 'bit_far'
							  Else 'Far_from_office' end

--24-- To know attrition gender wise with income grp

Select gender,case when distancefromhome between 1 and 5 then 'near'
							  when distancefromhome between 6 and 12 then 'bit_far'
							  Else 'Far_from_office' end as 'Travel_km',
							  avg(monthlyincome) as 'avg_M_inc',
							  count(*) as  Cnt_emp,
						sum(case when attrition='yes' then 1 else 0 end) as 'tot_attr_cnt',
						sum(case when attrition='yes' then 1 else 0 end) *100.0/count(*) as 'tot_attr_rate'
						from Hr_attrition
						group by gender, case when distancefromhome between 1 and 5 then 'near'
							  when distancefromhome between 6 and 12 then 'bit_far'
							  Else 'Far_from_office' end


--25--To analyzes employee attrition rates based on gender and business travel frequency, while also considering average monthly income.

Select gender,Businesstravel,
							  avg(monthlyincome) as 'avg_M_inc',
							  count(*) as  Cnt_emp,
						sum(case when attrition='yes' then 1 else 0 end) as 'tot_attr_cnt',
						sum(case when attrition='yes' then 1 else 0 end) *100.0/count(*) as 'tot_attr_rate'
						from Hr_attrition
						group by gender, BusinessTravel
						order by tot_attr_rate desc

--26--To analyzes employee attrition based on workload factors such as, Overtime,Business Travel and Job Level, also to identify the workload 
--conditions with the highest attrition rate for each job level.

with workload_matrix as ( Select Employeenumber, Overtime, Businesstravel, Joblevel, Attrition from Hr_attrition)

, attrition_by_wload as ( Select Joblevel, overtime, businesstravel, 
							count(*) as 'cn_emp',
							Sum(case when attrition='yes' then 1 else 0 end) as 'attr_cnt',
							Sum(case when attrition='yes' then 1 else 0 end)*100.0/count(*) as 'attr_rate'
							from workload_matrix
							group by Joblevel, overtime, businesstravel)

,attr_ord_job_level as (Select joblevel, overtime, businesstravel, cn_emp, attr_cnt,attr_rate,
row_number() over (partition by joblevel order by attr_rate desc) as 'row_ord'
from attrition_by_wload)

select * from attr_ord_job_level
where row_ord=1
order by joblevel desc, attr_rate desc

--27--Creating a table attrition log
create table Attrition_log
(logid int identity(1,1) primary key
, log_message varchar(max)
, log_date datetime default getdate())


--28--To create a trigger , which will generate a query into a log file table, that if the attrition rate goes higher than the threshold that is 17% then 
--create a message in the log report

create trigger trg_attritionmonitoring
on Hr_attrition
After Insert,Update,Delete
As
Begin
		Declare @T_cnt as int, @Attrcnt as int, @attrrate as decimal(4,2)

		
		Select @T_cnt=Count(*) from hr_attrition
		
		Select @attrcnt=Count(*) from hr_attrition where Attrition='yes'
		
		Select @attrrate= (100.0 * @attrcnt)/@T_cnt

		
		If @attrrate>16.99
		Begin
			insert into Attrition_log(log_message)
			values('alert: Attrition rate has exceeded from 16.99 and now ' + cast(@attrrate as varchar(40)) + '%')
		End
End



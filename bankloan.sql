create database bank;
use bank;
show tables;
desc financial_loan;
select * from financial_loan;
alter table financial_loan add constraint primary key(id);

-- KPI Queries

-- total loan applications
select count(id) as total_loan_applications from financial_loan;

-- MTD loan applications
set sql_safe_updates=0;
update financial_loan set issue_date = case
	when issue_date like '%/%' then date_format(str_to_date(issue_date,'%d/%m/%Y'),'%Y-%m-%d')
	when issue_date like '%-%' then date_format(str_to_date(issue_date,'%d-%m-%Y'),'%Y-%m-%d')
    else null
end;
alter table financial_loan modify column issue_date date;
select count(id) as MTD_Total_loan_applications from financial_loan where month(issue_date) = 12 and year(issue_date) = (select max(year(issue_date)) from financial_loan);

-- MOM loan applications = (MTD - PMTD)/PMTD
select count(id) as PMTD_Total_loan_applications from financial_loan where month(issue_date) = 11 and year(issue_date) = (select max(year(issue_date)) from financial_loan);


-- Total funded amount
select sum(loan_amount) as Total_funded_amount from financial_loan;

-- MTD Total funded amount
select sum(loan_amount) as MTD_Total_funded_amount from financial_loan where month(issue_date) = 12 and year(issue_date) = (select max(year(issue_date)) from financial_loan);

-- PMTD Total funded amount
select sum(loan_amount) as PMTD_Total_funded_amount from financial_loan where month(issue_date) = 11 and year(issue_date) = (select max(year(issue_date)) from financial_loan);

-- Total amount Recieved
select sum(total_payment) as Total_amount_received from financial_loan;

-- MTD Total amount Recieved
select sum(total_payment) as MTD_Total_amount_received from financial_loan where month(issue_date) = 12 and year(issue_date) = (select max(year(issue_date)) from financial_loan);

-- PMTD Total amount Recieved
select sum(total_payment) as PMTD_Total_amount_received from financial_loan where month(issue_date) = 11 and year(issue_date) = (select max(year(issue_date)) from financial_loan);

-- Average interest rate
select truncate(avg(int_rate),4)*100 as Average_interest_rate from financial_loan;

-- MTD Average interest rate
select truncate(avg(int_rate),4)*100 as MTD_Average_interest_rate from financial_loan where month(issue_date) = 12 and year(issue_date) = (select max(year(issue_date)) from financial_loan);

-- PMTD Average interest rate
select convert(avg(int_rate),decimal(5,2))*100 as PMTD_Average_interest_rate from financial_loan where month(issue_date) = 11 and year(issue_date) = (select max(year(issue_date)) from financial_loan);

-- Average Debt-to_income Ratio(DTI)
select convert(avg(dti),decimal(5,2))*100 as Avg_DTI from financial_loan;

-- MTD Average Debt-to_income Ratio(DTI)
select convert(avg(dti),decimal(5,2))*100 as Avg_DTI_MTD from financial_loan where month(issue_date) = 12 and year(issue_date) = (select max(year(issue_date)) from financial_loan);

-- PMTD Average Debt-to_income Ratio(DTI)
select convert(avg(dti),decimal(5,2))*100 as Avg_DTI_PMTD from financial_loan where month(issue_date) = 11 and year(issue_date) = (select max(year(issue_date)) from financial_loan);

-- Good loan vs Bad loan KPI's

-- Good loan vs Bad loan Application's
select case when loan_status ='Fully Paid' or loan_status ='Current' then 'Good Loan'
            else 'Bad Loan'
end as loan_type, count(*) as count from financial_loan group by loan_type;

-- Percentage of good loans
select (count(case when loan_status ='Fully Paid' or loan_status ='Current' then id end) / 
 count(id))*100 as good_loan_percentage from financial_loan;
 
 -- Percentage of bad loans
select (count(case when loan_status ='Charged Off' then id end) / 
 count(id))*100 as bad_loan_percentage from financial_loan;
 
 -- Good loan vs Bad loan Funded Amount
select case when loan_status ='Fully Paid' or loan_status ='Current' then 'Good Loan Funded Amount'
            else 'Bad Loan Funded Amount'
end as loan_type, sum(loan_amount) as count from financial_loan group by loan_type;

-- Good loan vs Bad loan Received Amount
select case when loan_status ='Fully Paid' or loan_status ='Current' then 'Good Loan Received Amount'
            else 'Bad Loan Received Amount'
end as loan_type, sum(total_payment) as count from financial_loan group by loan_type;

-- grid view to compare different KPI's that we calculated earlier
select
	loan_status,
    count(id) as total_loan_applications,
    sum(total_payment) as total_amount_received,
    sum(loan_amount) as total_funded_amount,
    avg(int_rate * 100) as interst_rate,
    avg(dti * 100) as DTI
from
	financial_loan
group by
loan_status;

-- grid view to compare different KPI's by MTD that we calculated earlier
select
	loan_status,
    sum(total_payment) as total_amount_received,
    sum(loan_amount) as total_funded_amount
from
	financial_loan
where month(issue_date) = 12 
group by
loan_status;

-- metrics to be shown in charts: total loan applications, total funded amount and total amount received

-- monthly trends by issue date(line chart)
select    		month(issue_date) as month_no,
				monthname(issue_date) as month_name,
				count(id) as total_loan_applications,
				sum(loan_amount) as total_funded_amount,
				sum(total_payment) as total_amount_received
 from financial_loan group by month_name,month_no order by month_no;


-- trends by address_state(bar chart)
select address_state,
				count(id) as total_loan_applications,
				sum(loan_amount) as total_funded_amount,
				sum(total_payment) as total_amount_received
 from financial_loan group by address_state order by total_loan_applications desc;
 
 
 -- trends by term duration(pie chart)
select term,
				count(id) as total_loan_applications,
				sum(loan_amount) as total_funded_amount,
				sum(total_payment) as total_amount_received
 from financial_loan group by term order by total_loan_applications desc;
 
 
  -- trends by work experience of our customer(bar chart)
select emp_length,
				count(id) as total_loan_applications,
				sum(loan_amount) as total_funded_amount,
				sum(total_payment) as total_amount_received
 from financial_loan group by emp_length order by total_loan_applications desc;
 

 -- trends by loan purpose(bar chart)
select purpose,
				count(id) as total_loan_applications,
				sum(loan_amount) as total_funded_amount,
				sum(total_payment) as total_amount_received
 from financial_loan group by purpose order by total_loan_applications desc;


 -- trends by home ownership(bar chart)
select home_ownership,
				count(id) as total_loan_applications,
				sum(loan_amount) as total_funded_amount,
				sum(total_payment) as total_amount_received
 from financial_loan group by home_ownership order by total_loan_applications desc;
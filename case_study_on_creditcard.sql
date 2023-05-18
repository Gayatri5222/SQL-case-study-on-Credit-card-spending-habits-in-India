CREATE DATABASE IF NOT EXISTS creditcard;
USE creditcard;
select * from creditcard.cc;

-- 1.What is the total transaction amount for each city?
select city, sum(amount) from creditcard.cc group by city order by sum(amount) desc;

-- 2.How many transactions were made for each card type? 
select Card_Type, count(*) as ' count' from creditcard.cc group by Card_Type;

-- 3.What is the average transaction amount by expense type?
select Exp_Type, avg(amount) as 'average transaction' from creditcard.cc group by Exp_Type;

-- 4.What is the total transaction amount by gender?
select gender, sum(amount) as 'total transaction' from creditcard.cc group by gender;

-- 5.Which city has the highest total transaction amount?
select city, sum(amount) from creditcard.cc group by city order by sum(amount) desc limit 1;

-- 6.What is the average transaction amount for each card type and expense type combination? 
select Card_Type , Exp_Type, avg(Amount) as 'average transaction'  from creditcard.cc group by Card_Type, Exp_Type;

-- 7.write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 
with table1 as (select city, sum(Amount) as 'total_amt_spend'  
from creditcard.cc group by city order by 'total_amt_spend' desc limit 5),
table2 as (select sum(amount) as 'total_amt' from creditcard.cc) 
select table1.city, table1.total_amt_spend, round((table1.total_amt_spend/table2.total_amt)*100,2) as 'precentage_contribution' 
from table1 inner join table2 on 1=1 order by table1.total_amt_spend desc;

-- 8. write a query to print 3 columns: city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
with table1 as (select city, Exp_Type, (sum(amount)) as 'total_amt' from creditcard.cc group by city, Exp_Type ),
table2 as (select city, max(total_amt) as highest_amt_spend, min(total_amt) as lowest_amt_spend from table1 group by city)
select table1.city ,
max(case when total_amt=highest_amt_spend then exp_type end) as highest_exp_type,
min(case when total_amt=lowest_amt_spend then exp_type end) as lowest_exp_type
from table1 inner join table2 on table1.city=table2.city
group by table1.city order by table1.city;

-- 9.write a query to find city which had lowest percentage spend for gold card type
with table1 as (select city, sum(amount) as 'total_gold_amt' from creditcard.cc where Card_Type='Gold' group by city),
table2 as (select city, sum(amount) as 'total_amt_spend' from creditcard.cc group by city),
table3 as (select table1.city, table1.total_gold_amt, table2.total_amt_spend, (table1.total_gold_amt/table2.total_amt_spend )*100 as 'precent_contribution' from table1 inner join table2 on table1.city=table2.city)
select * from table3 order by table3.precent_contribution;


-- 10.write a query to print the transaction details(all columns from the table) for each card type when 
-- it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
with table1 as (select *, sum(Amount) over(partition by Card_Type order by Date) as 'cumulative_sum' from creditcard.cc),
table2 as (select *, dense_rank() over(partition by Card_Type order by table1.cumulative_sum) as 'd_rank' from table1 where table1.cumulative_sum >= 1000000) 
select * from table2 where table2.d_rank=1 ;

-- 11. write a query to find percentage contribution of spends by females for each expense type
with table1 as (select Exp_Type, sum(amount) as 'total_amt_spend_byfemale' from creditcard.cc where Gender='F' group by Exp_Type),
table2 as (select Exp_Type, sum(amount) as 'total_amt_spend' from creditcard.cc group by Exp_Type)
select table1.Exp_Type, table1.total_amt_spend_byfemale, table2.total_amt_spend , (table1.total_amt_spend_byfemale/table2.total_amt_spend)*100 as 'percent_contri' from table1 
inner join table2 on table1.Exp_Type=table2.Exp_Type order by 'percent_contri';



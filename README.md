# Introduction
This file documents my approach and process through out this task split into sections of the questions , steps. I have written this in markdown such that when you preview it you can follow it like a coherent  report document and yes i do speak like this on a day to day.


## General Approach 
My general approach towards all these tasks places emphasis on **readability** for other data analysts so the code can be easily understood hence my excessive usage of CTE (Common Table Expressions) to keep the code modular and maintainable. 

## Preparatory Queries 
My preparation involved investigating all the tables for all the information i need to come up with solutions for the tasks and cut down on some of my thinking time as well as making navigating this schema  much easier. This is the query i ran:

`
SELECT 
    
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    COLUMN_KEY,
    EXTRA

FROM 

    INFORMATION_SCHEMA.COLUMNS
WHERE 

    TABLE_SCHEMA = 'adashi_staging' AND 
    TABLE_NAME = 'withdrawals_withdrawal'; #replace with all the other table names to fetch similar data 
    `

## General Issue 
working with mysql, admitedly i should be database agnostic but i spend so much time in postgres and the psql shell commandline qw well as writing scripts to automate things of this nature that setting up/ installing mysql and importing  the db in mysql was a bit frustrating and my queries were failing for syntax compatibility but once i got the hang of it the rest was history 

## High-Value Customers with Multiple Products
Scenario: The business wants to identify customers who have both a savings and an investment plan (cross-selling opportunity).
Task: Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.

Tables:
users_customuser
savings_savingsaccount
plans_plan

## Approach 
- My Query tries to fetch cross-selling opportunities for customers that have with emphasis both savings and investment plans

So based off the task my output columns are :

- `owner_id`: The unique identifier for the user

- `name`: Concatenation of first and last names for readability
- `savings_count`: Total number of distinct funded savings accounts per user
- `investment_count`: Total number of distinct funded investment plans per user
- `total_deposits`: Sum of net balance from savings and investments, sorted in descending order
I made use of an Inner join to link savings accounts to their respective owners but this is an approach i am constantly using day to day there are others 
- Then another Inner join inorder to  link investment plans to their respective owners
- Now I need to Ensure only funded savings accounts are considered in this query
- Ensure only funded investment plans are considered
- We only want users with at least one funded savings and one funded investment

### Problems encountered:
-  my initial query referenced 'deduction_amounts' in 'savings_savingsaccount', which does not exist.
   This was corrected by using 'deduction_amount' instead, based on the table schema provided.
-  There was confusion on the calculation of net balance for savings, which was clarified as 'confirmed_amount - deduction_amount'.
- The expected output format was clarified to include counts and total deposits, which required adjustments to aggregation and grouping logic.




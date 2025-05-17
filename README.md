# Introduction
This file documents the approach and process I followed through out writing the **sql scripts**  for this task split into sections of the questions , approach, issues encountered etc. I have written this in markdown such that when you preview you can follow it like a coherent  report document and yes i do speak like this on a day to day Its a bit long and not without error so please read with care.


## General Approach 
My general approach towards all these tasks places emphasis on **readability** for other data analysts so the code can be easily understood hence my excessive usage of CTE (Common Table Expressions) to keep the code modular and maintainable( Ha maintainable like I am gonna get the Job). 

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

## High-Value Customers with Multiple Products file: Assessment_Q1.sql
Scenario: The business wants to identify customers who have both a savings and an investment plan (cross-selling opportunity).
Task: Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.

**Tables**
`users_customuser`
`savings_savingsaccount`
`plans_plan`

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

## Transaction Frequency Analysis file: Assessment_Q2.sql
Scenario: The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).
Task: Calculate the average number of transactions per customer per month and categorize them:
`"High Frequency" (≥10 transactions/month)`
`"Medium Frequency" (3-9 transactions/month)`
`"Low Frequency" (≤2 transactions/month)`

**Tables**
`users_customuser`
`savings_savingsaccount`

## Aproach
I follow a three step process using as mentioned earlier on Common Table Expressions (CTEs)

**Transaction Aggregation/ CustomerTransactions (brining the transactions together)**
- I collect transaction data for each customer
- then i calculated the total number of transactions
- I then determinf the customer's active period in months(relevant when thinking about the output value)

**Freqeuncy Categorization**
- Calculates the average transactions per month for each customer
- Here I categorize customers into three distinct frequency segments based on the task namely the:
    - High Frequency: having >10 transactions per month
    - Medium Frequency: having between 3-9 transactions a month but not lower or higher than said range
    - Low Frequency: having <3 transactions a month.
**Results Aggregation (corresponds to the last query in the script)**
- customers  are grouped by their frequency categories 
- the count of customers in each segment are calculated 
- then i check for the average transaction rate within each segment 
- Results are presented in this order (High -> Medium -> Low)

 
## Account Inactivity Alert Assessment_Q3.sql
Scenario: The ops team wants to flag accounts with no inflow transactions for over one year.
Task: Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) .

**Tables**
`plans_plan`
`savings_savingsaccount`

## Approach
in similar fashion with my approach here can be broken into three steps ***identifying inactive savings account**, ***identifying inactive investment plans***, ***combining and presenting results***

**Inactive Savings Account**
- Create a Common Table Expression named InactiveSavings
- Group savings accounts by plan_id and owner_id
- Calculate the most recent transaction date for each account
- Determine how many days have passed since the last transaction
- Filter for accounts with no transactions in the last 365 Days

**Inactive Investment Plans**
- Create a CTE named InactiveInvestments
- It looks at the plans_plan table
- Then I Apply filters to exclude deleted (is_deleted = 0) and archived (is_archived = 0) plans
- I then  Group by id and owner_id
- Here I use last_charge_date as the indicator of account activity
- I apply Filters for plans with no charges in the last 365 days

**Results Compilation (Final Query)**
- Combines  both CTEs using UNION ALL (preserving all rows from both queries)
For each account I am returning:

- plan_id: The identifier for the savings account or investment plan
- owner_id: The user who owns the account
type: Identifies whether the account is "Savings" or "Investment"
- last_transaction_date: The date of the last activity
- inactivity_days: The number of days with no activity
- Orders results by inactivity_days in descending order (most inactive accounts first)

## Customer Lifetime Value (CLV) Estimation Assessment_Q4.sql
Scenario: Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).
Task: For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
Account tenure (months since signup)
Total transactions
Estimated CLV `(Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)`
Order by estimated CLV from highest to lowest

**Tables**
`users_customuser`
`savings_savingsaccount`

## Approach
So my approach gathers customer information and transaction history, then it estimates the lifetime  value based on customer behaviour patterns , finally the results are sorted and displayed

**CustomerData CTE (Data Collection)**
- I extract customer identification and personal information
- Then i calculate the `customer tenure` in months
- I aggregate transaction counts and total profit per customer 
- Then I link user data with transactions on their savings account using a LEFT JOIN

**CLVEstimation CTE (CLV Calculation)**
- Using the aggregated customer data I calculate the average monthly transaction rate
- Then Estimate annual transaction volume, followed by a Calculation for the  average  profit per trThere three factors are combined to estimate the life time value 
## Issues
- Handline edge cases where new customers with zero tenures were included 

**Result/Output**
- Select relevant customer and CLV information
- Round the CLV values to 2 decimal places for readability
- Sort results by estimated CLV in desending order,highlighting the customers with a higher value first 

**Explanation of the formulas used as stipulated by the task**
**Transaction Rate**: `total_transactions/ tenure_months` to calculate the average number of transactions each month
**Annual Projection**: `total_profit/ total_transactions` determines the average profit per transaction
**CLV Estimation**: Multiplying the above gives an estimated annual customer value (Incredibly Over simplified )

## Issues
Just general confusion about the formulas, and how to begin writing the query, I solved this by stepping away from the computer and heading to https://www.leetcode.com because i believed I had stumbled on a similar problem beforehand


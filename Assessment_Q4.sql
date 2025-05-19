-- Please visit my README.md for more verbose explanations of what the script is doing 
-- This Query attempts  to estimate Customer Lifetime Value (CLV) for each user
-- Step 1: Calculate the account tenure in months, total transactions, and total profit
-- off bat you can see i am using lots of aliases for readabilty of code
-- I am not using tons of in code comments because i am worried it might prevent the code from running correctly
USE `adashi_staging`;
WITH CustomerData AS (
    SELECT 
        user.id AS customer_id,
        CONCAT(user.first_name, ' ', user.last_name) AS name,
        TIMESTAMPDIFF(MONTH, user.date_joined, NOW()) AS tenure_months,
        COUNT(savings.id) AS total_transactions,
        SUM(savings.confirmed_amount) * 0.001 AS total_profit
    FROM 
        users_customuser user
    LEFT JOIN 
        savings_savingsaccount savings ON user.id = savings.owner_id
    GROUP BY 
        user.id
),

-- Step 2: Estimate CLV

CLVEstimation AS (
    SELECT 
        customer_id,
        name,
        tenure_months,
        total_transactions,
        CASE 
            WHEN tenure_months > 0 THEN (total_transactions / tenure_months) * 12 * (total_profit / total_transactions)
            ELSE 0
        END AS estimated_clv
    FROM 
        CustomerData
)

-- Step 3: Display results sorted by estimated CLV
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    ROUND(estimated_clv, 2) AS estimated_clv
FROM 
    CLVEstimation
ORDER BY 
    estimated_clv DESC;

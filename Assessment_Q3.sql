-- Please visit the README.md for more verbose explanations
-- This Query tries to find active accounts (savings or investments) with no transactions in the last year

-- Step 1: Fetch savings accounts with no transactions in the last 365 days
USE `adashi_staging`;
WITH InactiveSavings AS (
    SELECT 
        savings.plan_id,
        savings.owner_id,
        'Savings' AS type,
        MAX(savings.transaction_date) AS last_transaction_date,
        DATEDIFF(NOW(), MAX(savings.transaction_date)) AS inactivity_days
    FROM 
        savings_savingsaccount savings
    GROUP BY 
        savings.plan_id, savings.owner_id
    HAVING 
        MAX(savings.transaction_date) < NOW() - INTERVAL 365 DAY
),

-- Step 2: Check for investment plans with no transactions in the last 365 days

InactiveInvestments AS (
    SELECT 
        plans.id AS plan_id,
        plans.owner_id,
        'Investment' AS type,
        MAX(plans.last_charge_date) AS last_transaction_date,
        DATEDIFF(NOW(), MAX(plans.last_charge_date)) AS inactivity_days
    FROM 
        plans_plan plans
    WHERE 
        plans.is_deleted = 0 
        AND plans.is_archived = 0
    GROUP BY 
        plans.id, plans.owner_id
    HAVING 
        MAX(plans.last_charge_date) < NOW() - INTERVAL 365 DAY
)

-- Step 3: Then go ahead and Combine the two kinds of inactive accounts

SELECT 
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    inactivity_days
FROM 
    InactiveSavings

UNION ALL

SELECT 
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    inactivity_days
FROM 
    InactiveInvestments
ORDER BY 
    inactivity_days DESC;

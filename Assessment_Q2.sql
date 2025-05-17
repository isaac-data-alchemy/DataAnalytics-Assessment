-- This Query analyzes customer transactions frequencys and categorizes them accordingly

-- Step 1: Calculate the number of months a user has been transacting and their total transaction count
USE `adashi_staging`;
WITH CustomerTransactions AS (
    SELECT 
        savings.owner_id,
        COUNT(savings.id) AS transaction_count,
        TIMESTAMPDIFF(MONTH, MIN(savings.transaction_date), MAX(savings.transaction_date)) + 1 AS active_months
    FROM 
        savings_savingsaccount savings
    GROUP BY 
        savings.owner_id
),

-- Step 2: Calculate average transactions per month and categorize frequency
FrequencyCategorization AS (
    SELECT 
        owner_id,
        transaction_count,
        active_months,
        (transaction_count / active_months) AS avg_transactions_per_month,
        CASE 
            WHEN (transaction_count / active_months) >= 10 THEN 'High Frequency'
            WHEN (transaction_count / active_months) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM 
        CustomerTransactions
)

-- Step 3: Finally Aggregate the results by category
SELECT 
    frequency_category,
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM 
    FrequencyCategorization
GROUP BY 
    frequency_category
ORDER BY 
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');

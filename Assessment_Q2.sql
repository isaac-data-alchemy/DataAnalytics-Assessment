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

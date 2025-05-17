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

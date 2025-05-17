USE `adashi_staging`;
WITH InactiveSavings AS (
    SELECT 
        s.plan_id,
        s.owner_id,
        'Savings' AS type,
        MAX(s.transaction_date) AS last_transaction_date,
        DATEDIFF(NOW(), MAX(s.transaction_date)) AS inactivity_days
    FROM 
        savings_savingsaccount s
    GROUP BY 
        s.plan_id, s.owner_id
    HAVING 
        MAX(s.transaction_date) < NOW() - INTERVAL 365 DAY
),

InactiveInvestments AS (
    SELECT 
        p.id AS plan_id,
        p.owner_id,
        'Investment' AS type,
        MAX(p.last_charge_date) AS last_transaction_date,
        DATEDIFF(NOW(), MAX(p.last_charge_date)) AS inactivity_days
    FROM 
        plans_plan p
    WHERE 
        p.is_deleted = 0 
        AND p.is_archived = 0
    GROUP BY 
        p.id, p.owner_id
    HAVING 
        MAX(p.last_charge_date) < NOW() - INTERVAL 365 DAY
)


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

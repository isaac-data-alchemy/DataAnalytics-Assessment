USE `adashi_staging`;
SELECT 
    user.id AS owner_id,
    CONCAT(user.first_name, ' ', user.last_name) AS name,
    COUNT(DISTINCT savings.id) AS savings_count,
    COUNT(DISTINCT plans.id) AS investment_count,
    COALESCE(SUM(savings.confirmed_amount - savings.deduction_amount) + SUM(plans.amount), 0) AS total_deposits
FROM
    users_customuser user

INNER JOIN
    savings_savingsaccount savings ON user.id = savings.owner_id

INNER JOIN
    plans_plan plans ON user.id = plans.owner_id
WHERE
    (savings.confirmed_amount - savings.deduction_amount) > 0
    AND plans.is_a_fund = 1
    AND (plans.amount > 0)
GROUP BY
    user.id, name
HAVING
    savings_count > 0 AND investment_count > 0
ORDER BY
    total_deposits DESC;


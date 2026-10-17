-- 1. Verify total rows
SELECT COUNT(*) AS total_rows
FROM online_retail;

-- 2. Validate transaction categories
SELECT
    transaction_category,
    COUNT(*) AS row_count,
    ROUND(SUM(line_value), 2) AS total_line_value
FROM online_retail
GROUP BY transaction_category;

-- 3. Compare missing and identified customers
SELECT
    CASE
        WHEN customer_id IS NULL THEN 'Missing customer ID'
        ELSE 'Customer ID present'
    END AS customer_status,
    COUNT(*) AS row_count,
    ROUND(SUM(line_value), 2) AS total_line_value
FROM online_retail
GROUP BY customer_status;

-- 4. Measure extra duplicate occurrences
SELECT
    COUNT(*) AS extra_duplicate_rows,
    ROUND(SUM(line_value), 2) AS signed_line_value,
    ROUND(SUM(ABS(line_value)), 2) AS absolute_line_value
FROM online_retail
WHERE is_duplicate_extra = 1;

-- 5. Calculate yearly line value
SELECT
    SUBSTR(invoice_date, 1, 4) AS sales_year,
    COUNT(*) AS row_count,
    ROUND(SUM(line_value), 2) AS total_line_value
FROM online_retail
GROUP BY SUBSTR(invoice_date, 1, 4)
ORDER BY sales_year;
-- Monthly ordinary line value and cancellation-style line value

Check date coverage
First, verify the full date range and monthly record distribution.
pd.read_sql_query("""
SELECT
    MIN(invoice_date) AS first_transaction,
    MAX(invoice_date) AS last_transaction,
    COUNT(DISTINCT SUBSTR(invoice_date, 1, 7)) AS months_covered
FROM online_retail;
""", conn)

Then run:
pd.read_sql_query("""
SELECT
    SUBSTR(invoice_date, 1, 7) AS year_month,
    COUNT(*) AS row_count
FROM online_retail
GROUP BY SUBSTR(invoice_date, 1, 7)
ORDER BY year_month;
""", conn)

Analyse monthly sales and cancellation-style line value
pd.read_sql_query("""
SELECT
    SUBSTR(invoice_date, 1, 7) AS year_month,
    COUNT(*) AS all_rows,
    ROUND(SUM(CASE
        WHEN transaction_category = 'other_or_ordinary'
        THEN line_value ELSE 0
    END), 2) AS ordinary_line_value,
    ROUND(SUM(CASE
        WHEN transaction_category = 'cancellation_style_invoice'
        THEN line_value ELSE 0
    END), 2) AS cancellation_line_value,
    ROUND(SUM(line_value), 2) AS all_category_line_value
FROM online_retail
GROUP BY SUBSTR(invoice_date, 1, 7)
ORDER BY year_month;
""", conn)

-- Top products by ordinary line value
pd.read_sql_query("""
SELECT
    stock_code,
    MAX(description) AS product_description,
    SUM(quantity) AS total_units,
    COUNT(*) AS transaction_rows,
    ROUND(SUM(line_value), 2) AS ordinary_line_value
FROM online_retail
WHERE transaction_category = 'other_or_ordinary'
GROUP BY stock_code
ORDER BY ordinary_line_value DESC
LIMIT 10;
""", conn)

-- Top products by units
pd.read_sql_query("""
SELECT
    stock_code,
    MAX(description) AS product_description,
    SUM(quantity) AS total_units,
    ROUND(SUM(line_value), 2) AS ordinary_line_value
FROM online_retail
WHERE transaction_category = 'other_or_ordinary'
GROUP BY stock_code
ORDER BY total_units DESC
LIMIT 10;
""", conn)

-- Highest-value identified customers
pd.read_sql_query("""
SELECT
    customer_id,
    COUNT(DISTINCT invoice) AS distinct_invoices,
    COUNT(*) AS transaction_rows,
    SUM(quantity) AS total_units,
    ROUND(SUM(line_value), 2) AS ordinary_line_value
FROM online_retail
WHERE customer_id IS NOT NULL
  AND transaction_category = 'other_or_ordinary'
GROUP BY customer_id
ORDER BY ordinary_line_value DESC
LIMIT 10;
""", conn)

-- Customer purchase frequency
pd.read_sql_query("""
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice) AS invoice_count
    FROM online_retail
    WHERE customer_id IS NOT NULL
      AND transaction_category = 'other_or_ordinary'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN invoice_count = 1 THEN '1 invoice'
        WHEN invoice_count BETWEEN 2 AND 5 THEN '2-5 invoices'
        ELSE '6+ invoices'
    END AS purchase_frequency_group,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY purchase_frequency_group
ORDER BY
    CASE purchase_frequency_group
        WHEN '1 invoice' THEN 1
        WHEN '2-5 invoices' THEN 2
        ELSE 3
    END;
""", conn)

-- Country performance
pd.read_sql_query("""
SELECT
    country,
    COUNT(DISTINCT invoice) AS distinct_invoices,
    COUNT(DISTINCT customer_id) AS identified_customers,
    SUM(quantity) AS total_units,
    ROUND(SUM(line_value), 2) AS ordinary_line_value
FROM online_retail
WHERE transaction_category = 'other_or_ordinary'
GROUP BY country
ORDER BY ordinary_line_value DESC
LIMIT 15;
""", conn)

-- Customer value bands
pd.read_sql_query("""
WITH customer_value AS (
    SELECT
        customer_id,
        SUM(line_value) AS customer_line_value
    FROM online_retail
    WHERE customer_id IS NOT NULL
      AND transaction_category = 'other_or_ordinary'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN customer_line_value < 100 THEN 'Below 100'
        WHEN customer_line_value < 500 THEN '100-499.99'
        WHEN customer_line_value < 1000 THEN '500-999.99'
        ELSE '1000 and above'
    END AS value_band,
    COUNT(*) AS customer_count,
    ROUND(SUM(customer_line_value), 2) AS combined_line_value
FROM customer_value
GROUP BY value_band
ORDER BY
    CASE value_band
        WHEN 'Below 100' THEN 1
        WHEN '100-499.99' THEN 2
        WHEN '500-999.99' THEN 3
        ELSE 4
    END;
""", conn)

-- Cancellation-style invoice frequency
pd.read_sql_query("""
SELECT
    SUBSTR(invoice_date, 1, 4) AS calendar_year,
    COUNT(DISTINCT CASE
        WHEN transaction_category = 'cancellation_style_invoice'
        THEN invoice
    END) AS cancellation_invoices,
    COUNT(DISTINCT invoice) AS all_distinct_invoices,
    ROUND(SUM(CASE
        WHEN transaction_category = 'cancellation_style_invoice'
        THEN line_value ELSE 0
    END), 2) AS cancellation_line_value
FROM online_retail
GROUP BY SUBSTR(invoice_date, 1, 4)
ORDER BY calendar_year;
""", conn)


## SQL Analysis Progress

- Audit non-product stock codes: These codes should be excluded from a retail product ranking if the output confirms they represent manual entries or postage services. Keep them in overall transaction analysis unless a separate, evidence-based rule says otherwise.
pd.read_sql_query("""
SELECT
    stock_code,
    MAX(description) AS description,
    COUNT(*) AS row_count,
    SUM(quantity) AS total_units,
    ROUND(SUM(line_value), 2) AS line_value
FROM online_retail
WHERE stock_code IN ('M', 'DOT', 'POST')
GROUP BY stock_code
ORDER BY line_value DESC;
""", conn)

- Inspect the top 20 stock codes by line value: Goal: Identify products or service codes that may distort a retail-product ranking. Don't exclude a code merely because its description looks unusual. Record the evidence.
pd.read_sql_query("""
SELECT
    stock_code,
    MAX(description) AS description,
    COUNT(*) AS row_count,
    COUNT(DISTINCT invoice) AS invoice_count,
    SUM(quantity) AS total_units,
    ROUND(SUM(line_value), 2) AS line_value
FROM online_retail
WHERE transaction_category = 'other_or_ordinary'
GROUP BY stock_code
ORDER BY line_value DESC
LIMIT 20;
""", conn)

- Check price anomalies by transaction category: This helps show whether unusual prices and quantities are concentrated in particular categories. The counts can overlap within a category, so don't add them together as if they represented separate rows.
pd.read_sql_query("""
SELECT
    transaction_category,
    SUM(CASE WHEN price = 0 THEN 1 ELSE 0 END) AS zero_price_rows,
    SUM(CASE WHEN price < 0 THEN 1 ELSE 0 END) AS negative_price_rows,
    SUM(CASE WHEN quantity < 0 THEN 1 ELSE 0 END) AS negative_quantity_rows,
    COUNT(*) AS total_rows
FROM online_retail
GROUP BY transaction_category
ORDER BY transaction_category;
""", conn)

- Find the largest invoices by line value: These are invoice totals under the current working classification. They are not necessarily final billed amounts, because cancellation, adjustment, and duplicate treatment has not been finalized.
pd.read_sql_query("""
SELECT
    invoice,
    COUNT(*) AS line_count,
    COUNT(DISTINCT stock_code) AS distinct_stock_codes,
    SUM(quantity) AS total_units,
    ROUND(SUM(line_value), 2) AS invoice_line_value
FROM online_retail
WHERE transaction_category = 'other_or_ordinary'
GROUP BY invoice
ORDER BY invoice_line_value DESC
LIMIT 10;
""", conn)

- Compare monthly invoice counts with line value: Compare invoice volume with ordinary line value. A month with more invoices does not necessarily have a higher average invoice value.
pd.read_sql_query("""
SELECT
    SUBSTR(invoice_date, 1, 7) AS year_month,
    COUNT(DISTINCT invoice) AS distinct_invoices,
    SUM(CASE
        WHEN transaction_category = 'other_or_ordinary'
        THEN 1 ELSE 0
    END) AS ordinary_rows,
    ROUND(SUM(CASE
        WHEN transaction_category = 'other_or_ordinary'
        THEN line_value ELSE 0
    END), 2) AS ordinary_line_value
FROM online_retail
GROUP BY SUBSTR(invoice_date, 1, 7)
ORDER BY year_month;
""", conn)

- Calculate average ordinary invoice value by month: This gives you a preliminary average invoice value, calculated from invoices represented in the ordinary category. Label it accordingly in your notes.
pd.read_sql_query("""
WITH invoice_totals AS (
    SELECT
        SUBSTR(invoice_date, 1, 7) AS year_month,
        invoice,
        SUM(line_value) AS invoice_value
    FROM online_retail
    WHERE transaction_category = 'other_or_ordinary'
    GROUP BY SUBSTR(invoice_date, 1, 7), invoice
)
SELECT
    year_month,
    COUNT(*) AS invoice_count,
    ROUND(SUM(invoice_value), 2) AS total_line_value,
    ROUND(AVG(invoice_value), 2) AS average_invoice_value
FROM invoice_totals
GROUP BY year_month
ORDER BY year_month;
""", conn)

- Create a cleaner retail-product ranking: Compare this list with Task 33. Record which entries disappear and whether the rankings change.
Important: This removes only the three identified codes. Other unusual codes may still require investigation.
pd.read_sql_query("""
SELECT
    stock_code,
    MAX(description) AS product_description,
    COUNT(DISTINCT invoice) AS invoice_count,
    SUM(quantity) AS total_units,
    ROUND(SUM(line_value), 2) AS product_line_value
FROM online_retail
WHERE transaction_category = 'other_or_ordinary'
  AND stock_code NOT IN ('M', 'DOT', 'POST')
GROUP BY stock_code
ORDER BY product_line_value DESC
LIMIT 15;
""", conn)

- Reconcile customer counts across the analysis: This is a reconciliation exercise. The counts can differ because customers may appear only in particular transaction categories, or in more than one category.
pd.read_sql_query("""
SELECT
    COUNT(DISTINCT customer_id) AS all_identified_customers,
    COUNT(DISTINCT CASE
        WHEN transaction_category = 'other_or_ordinary'
        THEN customer_id
    END) AS customers_in_ordinary_category,
    COUNT(DISTINCT CASE
        WHEN transaction_category = 'cancellation_style_invoice'
        THEN customer_id
    END) AS customers_in_cancellation_category
FROM online_retail;
""", conn)

- Examine international performance without the UK: This makes international markets easier to compare without the UK's much larger total dominating the table.
pd.read_sql_query("""
SELECT
    country,
    COUNT(DISTINCT invoice) AS invoice_count,
    COUNT(DISTINCT customer_id) AS identified_customers,
    ROUND(SUM(line_value), 2) AS ordinary_line_value
FROM online_retail
WHERE transaction_category = 'other_or_ordinary'
  AND country <> 'United Kingdom'
GROUP BY country
ORDER BY ordinary_line_value DESC
LIMIT 10;
""", conn)

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_acct_num BIGINT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    customer_address VARCHAR(255),
    customer_city VARCHAR(100),
    customer_state_province VARCHAR(100),
    customer_postal_code VARCHAR(30),
    customer_country VARCHAR(100),
    birthdate DATE,
    marital_status VARCHAR(20),
    yearly_income VARCHAR(50),
    gender VARCHAR(20),
    total_children INT,
    num_children_at_home INT,
    education VARCHAR(100),
    acct_open_date DATE,
    member_card VARCHAR(50),
    occupation VARCHAR(100),
    homeowner VARCHAR(10)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_brand VARCHAR(100),
    product_name VARCHAR(255),
    product_sku BIGINT,
    product_retail_price NUMERIC(10,2),
    product_cost NUMERIC(10,2),
    product_weight NUMERIC(10,2),
    recyclable INT,
    low_fat INT
);

CREATE TABLE regions (
    region_id INT PRIMARY KEY,
    sales_district VARCHAR(100),
    sales_region VARCHAR(100)
);

CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    region_id INT,
    store_type VARCHAR(100),
    store_name VARCHAR(150),
    store_street_address VARCHAR(255),
    store_city VARCHAR(100),
    store_state VARCHAR(100),
    store_country VARCHAR(100),
    store_phone VARCHAR(50),
    first_opened_date DATE,
    last_remodel_date DATE,
    total_sqft INT,
    grocery_sqft INT
);

CREATE TABLE transactions (
    transaction_date DATE,
    stock_date DATE,
    product_id INT,
    customer_id INT,
    store_id INT,
    quantity INT
);

CREATE TABLE returns (
    return_date DATE,
    product_id INT,
    store_id INT,
    quantity INT
);

CREATE TABLE calendar (
    date DATE PRIMARY KEY
);



SELECT COUNT(*) AS customers_count FROM customers;
SELECT COUNT(*) AS products_count FROM products;
SELECT COUNT(*) AS stores_count FROM stores;
SELECT COUNT(*) AS regions_count FROM regions;
SELECT COUNT(*) AS transactions_count FROM transactions;
SELECT COUNT(*) AS returns_count FROM returns;
SELECT COUNT(*) AS calendar_count FROM calendar;

SELECT * FROM customers LIMIT 5;
SELECT * FROM products LIMIT 5;
SELECT * FROM stores LIMIT 5;
SELECT * FROM regions LIMIT 5;
SELECT * FROM transactions LIMIT 5;
SELECT * FROM returns LIMIT 5;


SELECT COUNT(*) AS unmatched_customers
FROM transactions t
LEFT JOIN customers c
    ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS unmatched_products
FROM transactions t
LEFT JOIN products p
    ON t.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*) AS unmatched_regions
FROM stores s
LEFT JOIN regions r
    ON s.region_id = r.region_id
WHERE r.region_id IS NULL;

SELECT
    transaction_date,
    stock_date,
    product_id,
    customer_id,
    store_id,
    quantity,
    COUNT(*) AS duplicate_count
FROM transactions
GROUP BY
    transaction_date,
    stock_date,
    product_id,
    customer_id,
    store_id,
    quantity
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

SELECT
    MIN(transaction_date) AS first_transaction_date,
    MAX(transaction_date) AS last_transaction_date
FROM transactions;


SELECT
    MIN(return_date) AS first_return_date,
    MAX(return_date) AS last_return_date
FROM returns;



-- ==========================================
-- Retail Business SQL Analytics
-- Section 1: Core Business Analysis
-- ==========================================

--1. Total Sales Revenue
SELECT
    ROUND(SUM(t.quantity * p.product_retail_price), 2) AS total_revenue
FROM transactions t
JOIN products p
    ON t.product_id = p.product_id;
	
-- Interpretation:
-- The retail business generated approximately 1.76M in total revenue
-- across all recorded transactions.

--2. Total Cost
SELECT
    ROUND(SUM(t.quantity * p.product_cost), 2) AS total_cost
FROM transactions t
JOIN products p
    ON t.product_id = p.product_id;

-- Interpretation:
-- The estimated total product cost was approximately 711.7K,
-- providing the cost base required for profitability analysis.

--3. Total Profit
SELECT
    ROUND(
        SUM(
            t.quantity *
            (p.product_retail_price - p.product_cost)
        ),
        2
    ) AS total_profit
FROM transactions t
JOIN products p
    ON t.product_id = p.product_id;
	
-- Interpretation:
-- The business generated approximately 1.05M in gross profit,
-- indicating strong profitability across the transaction period.

--4. Profit Margin %
SELECT
    ROUND(
        (
            SUM(
                t.quantity *
                (p.product_retail_price - p.product_cost)
            )
            /
            SUM(t.quantity * p.product_retail_price)
        ) * 100,
        2
    ) AS profit_margin_pct
FROM transactions t
JOIN products p
    ON t.product_id = p.product_id;

-- Interpretation:
-- The overall gross profit margin was approximately 59.67%,
-- showing a relatively strong margin between retail price and product cost.

--5. Total Quantity Sold
SELECT
    SUM(quantity) AS total_units_sold
FROM transactions;

--6. Unique Customers

SELECT
    COUNT(DISTINCT customer_id) AS total_customers
FROM transactions;
-- Interpretation:
-- The business served 8,842 unique customers during the analysis period,
-- reflecting a broad customer base.

--7. Active Stores
SELECT
    COUNT(DISTINCT store_id) AS active_stores
FROM transactions;

-- Interpretation:
-- Sales transactions were recorded across 24 active stores,
-- providing a geographically distributed retail footprint.

--8. Products Sold
SELECT
    COUNT(DISTINCT product_id) AS products_sold
FROM transactions;

--9. Top 10 Products by Revenue
SELECT
    p.product_id,
    p.product_name,
    p.product_brand,
    ROUND(
        SUM(t.quantity * p.product_retail_price),
        2
    ) AS revenue
FROM transactions t
JOIN products p
    ON t.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.product_brand
ORDER BY revenue DESC
LIMIT 10;

-- Interpretation:
-- Hermanos Green Pepper generated the highest product revenue,
-- followed closely by Hilltop Mint Mouthwash and Carlson Head Cheese.
-- Revenue among the top products is relatively close, suggesting that
-- no single product overwhelmingly dominates sales.

--10. Top 10 Products by Quantity
SELECT
    p.product_id,
    p.product_name,
    SUM(t.quantity) AS units_sold
FROM transactions t
JOIN products p
    ON t.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY units_sold DESC
LIMIT 10;

-- Interpretation:
-- This ranking highlights the products with the strongest unit demand.
-- Comparing quantity rankings with revenue rankings helps identify
-- high-volume products that may not necessarily be the highest revenue generators.


--11. Top 10 Customers by Revenue
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(
        SUM(t.quantity * p.product_retail_price),
        2
    ) AS customer_revenue
FROM transactions t
JOIN customers c
    ON t.customer_id = c.customer_id
JOIN products p
    ON t.product_id = p.product_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY customer_revenue DESC
LIMIT 10;

-- Interpretation:
-- Ida Rodriguez was the highest-revenue customer, followed by James Horvat
-- and Dawn Laner. Customer revenue is relatively dispersed,
-- suggesting limited dependency on any single customer.

--12. Top Stores by Revenue
SELECT
    s.store_id,
    s.store_name,
    s.store_city,
    ROUND(
        SUM(t.quantity * p.product_retail_price),
        2
    ) AS revenue
FROM transactions t
JOIN stores s
    ON t.store_id = s.store_id
JOIN products p
    ON t.product_id = p.product_id
GROUP BY
    s.store_id,
    s.store_name,
    s.store_city
ORDER BY revenue DESC
limit 5;

-- Interpretation:
-- Store 13 in Salem generated the highest revenue, followed by Store 17 in Tacoma.
-- The large variation across stores suggests meaningful differences
-- in location-level sales performance.

--13. Revenue by Region
SELECT
    r.sales_region,
    ROUND(
        SUM(t.quantity * p.product_retail_price),
        2
    ) AS revenue
FROM transactions t
JOIN stores s
    ON t.store_id = s.store_id
JOIN regions r
    ON s.region_id = r.region_id
JOIN products p
    ON t.product_id = p.product_id
GROUP BY
    r.sales_region
ORDER BY revenue DESC
limit 5;

-- Interpretation:
-- The North West region generated the highest revenue by a wide margin,
-- indicating strong geographic concentration in that region.
-- Regional performance should be examined further at the store level.

--14. Monthly Revenue Trend
SELECT
    DATE_TRUNC(
        'month',
        t.transaction_date
    )::DATE AS month,
    
    ROUND(
        SUM(t.quantity * p.product_retail_price),
        2
    ) AS revenue

FROM transactions t
JOIN products p
    ON t.product_id = p.product_id

GROUP BY
    DATE_TRUNC('month', t.transaction_date)

ORDER BY month;

-- Interpretation:
-- Monthly revenue remained relatively stable during much of 1997
-- and increased sharply at the beginning of 1998,
-- indicating significant year-over-year growth in sales activity.

--15. Monthly Profit Trend
SELECT
    DATE_TRUNC(
        'month',
        t.transaction_date
    )::DATE AS month,

    ROUND(
        SUM(
            t.quantity *
            (p.product_retail_price - p.product_cost)
        ),
        2
    ) AS profit

FROM transactions t
JOIN products p
    ON t.product_id = p.product_id

GROUP BY
    DATE_TRUNC('month', t.transaction_date)

ORDER BY month;

-- Interpretation:
-- Monthly profit generally follows the revenue trend,
-- suggesting that profitability scales closely with sales performance.
-- Stronger revenue months also tend to generate higher gross profit.


-- ==========================================
-- Section 2: Intermediate Business Analysis
-- Customer, Product & Store Analysis
-- ==========================================


SELECT
    customer_id,
    COUNT(*) AS transaction_count,
    SUM(quantity) AS total_units
FROM transactions
GROUP BY customer_id
ORDER BY transaction_count DESC;

-- ==========================================
-- Section 2: Intermediate Business Analysis
-- Customer, Product & Store Analysis
-- ==========================================


-- ==========================================
-- 1. Customer Purchase Frequency
-- ==========================================

SELECT
    customer_id,
    COUNT(*) AS transaction_count,
    SUM(quantity) AS total_units
FROM transactions
GROUP BY customer_id
ORDER BY transaction_count DESC;


-- ==========================================
-- 2. Repeat vs One-Time Customers
-- ==========================================

WITH customer_activity AS (
    SELECT
        customer_id,
        COUNT(*) AS transaction_count
    FROM transactions
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN transaction_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM customer_activity
GROUP BY customer_type;


-- ==========================================
-- 3. Customer Revenue Segmentation
-- ==========================================

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN customers c
        ON t.customer_id = c.customer_id
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)
SELECT
    customer_id,
    first_name,
    last_name,
    ROUND(revenue, 2) AS revenue,
    CASE
        WHEN revenue >= 1500 THEN 'High Value'
        WHEN revenue >= 750 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_revenue
ORDER BY revenue DESC;


-- ==========================================
-- 4. Customers Above Average Revenue
-- ==========================================

WITH customer_revenue AS (
    SELECT
        t.customer_id,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY t.customer_id
)
SELECT
    customer_id,
    ROUND(revenue, 2) AS revenue
FROM customer_revenue
WHERE revenue > (
    SELECT AVG(revenue)
    FROM customer_revenue
)
ORDER BY revenue DESC;


-- ==========================================
-- 5. Brand Performance
-- ==========================================

SELECT
    p.product_brand,
    ROUND(
        SUM(t.quantity * p.product_retail_price),
        2
    ) AS revenue,
    SUM(t.quantity) AS units_sold
FROM transactions t
JOIN products p
    ON t.product_id = p.product_id
GROUP BY p.product_brand
ORDER BY revenue DESC
limit 5;


-- ==========================================
-- 6. Brand Profitability
-- ==========================================

SELECT
    p.product_brand,
    ROUND(
        SUM(
            t.quantity *
            (p.product_retail_price - p.product_cost)
        ),
        2
    ) AS profit
FROM transactions t
JOIN products p
    ON t.product_id = p.product_id
GROUP BY p.product_brand
ORDER BY profit DESC
limit 5;


-- ==========================================
-- 7. Most Profitable Products
-- ==========================================

SELECT
    p.product_id,
    p.product_name,
    p.product_brand,
    ROUND(
        SUM(
            t.quantity *
            (p.product_retail_price - p.product_cost)
        ),
        2
    ) AS profit
FROM transactions t
JOIN products p
    ON t.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.product_brand
ORDER BY profit DESC
LIMIT 10;


-- ==========================================
-- 8. High-Margin Products
-- ==========================================

SELECT
    p.product_id,
    p.product_name,
    p.product_brand,
    ROUND(
        (
            (p.product_retail_price - p.product_cost)
            / p.product_retail_price
        ) * 100,
        2
    ) AS margin_pct
FROM products p
WHERE p.product_retail_price > 0
ORDER BY margin_pct DESC
LIMIT 10;


-- ==========================================
-- 9. Stores Above Average Revenue
-- ==========================================

WITH store_revenue AS (
    SELECT
        s.store_id,
        s.store_name,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN stores s
        ON t.store_id = s.store_id
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY
        s.store_id,
        s.store_name
)
SELECT
    store_id,
    store_name,
    ROUND(revenue, 2) AS revenue
FROM store_revenue
WHERE revenue > (
    SELECT AVG(revenue)
    FROM store_revenue
)
ORDER BY revenue DESC;


-- ==========================================
-- 10. Store Performance Category
-- ==========================================

WITH store_revenue AS (
    SELECT
        s.store_id,
        s.store_name,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN stores s
        ON t.store_id = s.store_id
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY
        s.store_id,
        s.store_name
)
SELECT
    store_id,
    store_name,
    ROUND(revenue, 2) AS revenue,
    CASE
        WHEN revenue >= 120000 THEN 'High Performing'
        WHEN revenue >= 70000 THEN 'Medium Performing'
        ELSE 'Low Performing'
    END AS performance_category
FROM store_revenue
ORDER BY revenue DESC;


-- ==========================================
-- 11. Region Revenue Contribution %
-- ==========================================

WITH regional_revenue AS (
    SELECT
        r.sales_region,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN stores s
        ON t.store_id = s.store_id
    JOIN regions r
        ON s.region_id = r.region_id
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY r.sales_region
)
SELECT
    sales_region,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue * 100.0 /
        SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct
FROM regional_revenue
ORDER BY revenue DESC;


-- ==========================================
-- 12. High-Volume Products Using HAVING
-- ==========================================

SELECT
    p.product_id,
    p.product_name,
    SUM(t.quantity) AS units_sold
FROM transactions t
JOIN products p
    ON t.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
HAVING SUM(t.quantity) > 500
ORDER BY units_sold DESC;


-- ==========================================
-- 13. High-Revenue Customers Using HAVING
-- ==========================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(
        SUM(t.quantity * p.product_retail_price),
        2
    ) AS revenue
FROM transactions t
JOIN customers c
    ON t.customer_id = c.customer_id
JOIN products p
    ON t.product_id = p.product_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING SUM(t.quantity * p.product_retail_price) > 1000
ORDER BY revenue DESC;


-- ==========================================
-- 14. Revenue by Customer Country
-- ==========================================

SELECT
    c.customer_country,
    ROUND(
        SUM(t.quantity * p.product_retail_price),
        2
    ) AS revenue
FROM transactions t
JOIN customers c
    ON t.customer_id = c.customer_id
JOIN products p
    ON t.product_id = p.product_id
GROUP BY c.customer_country
ORDER BY revenue DESC;



-- ==========================================
-- Section 3: CTE & Subquery Analysis
-- ==========================================

-- ==========================================
-- 1. Customers Above Average Revenue
-- ==========================================

WITH customer_revenue AS (
    SELECT
        t.customer_id,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY t.customer_id
)
SELECT
    customer_id,
    ROUND(revenue, 2) AS revenue
FROM customer_revenue
WHERE revenue > (
    SELECT AVG(revenue)
    FROM customer_revenue
)
ORDER BY revenue DESC;


-- ==========================================
-- 2. Products Above Average Revenue
-- ==========================================

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_id,
    product_name,
    ROUND(revenue, 2) AS revenue
FROM product_revenue
WHERE revenue > (
    SELECT AVG(revenue)
    FROM product_revenue
)
ORDER BY revenue DESC;


-- ==========================================
-- 3. Stores Above Average Profit
-- ==========================================

WITH store_profit AS (
    SELECT
        s.store_id,
        s.store_name,
        SUM(
            t.quantity *
            (p.product_retail_price - p.product_cost)
        ) AS profit
    FROM transactions t
    JOIN stores s
        ON t.store_id = s.store_id
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY
        s.store_id,
        s.store_name
)
SELECT
    store_id,
    store_name,
    ROUND(profit, 2) AS profit
FROM store_profit
WHERE profit > (
    SELECT AVG(profit)
    FROM store_profit
)
ORDER BY profit DESC;


-- ==========================================
-- 4. Top 10% Customers by Revenue
-- ==========================================

WITH customer_revenue AS (
    SELECT
        t.customer_id,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY t.customer_id
),
threshold AS (
    SELECT
        PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY revenue) AS p90
    FROM customer_revenue
)
SELECT
    cr.customer_id,
    ROUND(cr.revenue, 2) AS revenue
FROM customer_revenue cr
CROSS JOIN threshold th
WHERE cr.revenue >= th.p90
ORDER BY cr.revenue DESC;


-- ==========================================
-- 5. Customers Contributing More Than 0.1%
--    of Total Customer Revenue
-- ==========================================

WITH customer_revenue AS (
    SELECT
        t.customer_id,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY t.customer_id
),
total_revenue AS (
    SELECT
        SUM(revenue) AS grand_total
    FROM customer_revenue
)
SELECT
    cr.customer_id,
    ROUND(cr.revenue, 2) AS revenue,
    ROUND(
        cr.revenue * 100.0 / tr.grand_total,
        3
    ) AS revenue_share_pct
FROM customer_revenue cr
CROSS JOIN total_revenue tr
WHERE cr.revenue / tr.grand_total > 0.001
ORDER BY cr.revenue DESC;


-- ==========================================
-- 6. Products with Profit Above Average
-- ==========================================

WITH product_profit AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(
            t.quantity *
            (p.product_retail_price - p.product_cost)
        ) AS profit
    FROM transactions t
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_id,
    product_name,
    ROUND(profit, 2) AS profit
FROM product_profit
WHERE profit > (
    SELECT AVG(profit)
    FROM product_profit
)
ORDER BY profit DESC;


-- ==========================================
-- 7. Best Store in Each Region
-- ==========================================

WITH store_revenue AS (
    SELECT
        r.sales_region,
        s.store_id,
        s.store_name,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN stores s
        ON t.store_id = s.store_id
    JOIN regions r
        ON s.region_id = r.region_id
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY
        r.sales_region,
        s.store_id,
        s.store_name
),
region_max AS (
    SELECT
        sales_region,
        MAX(revenue) AS max_revenue
    FROM store_revenue
    GROUP BY sales_region
)
SELECT
    sr.sales_region,
    sr.store_id,
    sr.store_name,
    ROUND(sr.revenue, 2) AS revenue
FROM store_revenue sr
JOIN region_max rm
    ON sr.sales_region = rm.sales_region
    AND sr.revenue = rm.max_revenue
ORDER BY sr.revenue DESC;


-- ==========================================
-- 8. Products Sold in More Stores Than Average
-- ==========================================

WITH product_store_count AS (
    SELECT
        product_id,
        COUNT(DISTINCT store_id) AS store_count
    FROM transactions
    GROUP BY product_id
)
SELECT
    product_id,
    store_count
FROM product_store_count
WHERE store_count > (
    SELECT AVG(store_count)
    FROM product_store_count
)
ORDER BY store_count DESC;


-- ==========================================
-- 9. Customers with Purchase Frequency
--    Above Average
-- ==========================================

WITH customer_frequency AS (
    SELECT
        customer_id,
        COUNT(*) AS transaction_count
    FROM transactions
    GROUP BY customer_id
)
SELECT
    customer_id,
    transaction_count
FROM customer_frequency
WHERE transaction_count > (
    SELECT AVG(transaction_count)
    FROM customer_frequency
)
ORDER BY transaction_count DESC;


-- ==========================================
-- 10. Regions Contributing Above Average Revenue
-- ==========================================

WITH regional_revenue AS (
    SELECT
        r.sales_region,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN stores s
        ON t.store_id = s.store_id
    JOIN regions r
        ON s.region_id = r.region_id
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY r.sales_region
)
SELECT
    sales_region,
    ROUND(revenue, 2) AS revenue
FROM regional_revenue
WHERE revenue > (
    SELECT AVG(revenue)
    FROM regional_revenue
)
ORDER BY revenue DESC;



-- ==========================================
-- Section 4: Advanced SQL / Window Functions
-- ==========================================


-- ==========================================
-- 1. Rank Customers by Revenue
-- ==========================================

WITH customer_revenue AS (
    SELECT
        t.customer_id,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY t.customer_id
)
SELECT
    customer_id,
    ROUND(revenue, 2) AS revenue,
    RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank
FROM customer_revenue
ORDER BY revenue_rank;


-- ==========================================
-- 2. Rank Products by Revenue
-- ==========================================

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_id,
    product_name,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS product_rank
FROM product_revenue
ORDER BY product_rank;


-- ==========================================
-- 3. Rank Stores Within Each Region
-- ==========================================

WITH store_revenue AS (
    SELECT
        r.sales_region,
        s.store_id,
        s.store_name,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN stores s
        ON t.store_id = s.store_id
    JOIN regions r
        ON s.region_id = r.region_id
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY
        r.sales_region,
        s.store_id,
        s.store_name
)
SELECT
    sales_region,
    store_id,
    store_name,
    ROUND(revenue, 2) AS revenue,
    RANK() OVER (
        PARTITION BY sales_region
        ORDER BY revenue DESC
    ) AS region_store_rank
FROM store_revenue
ORDER BY sales_region, region_store_rank;


-- ==========================================
-- 4. Top 3 Products Within Each Brand
-- ==========================================

WITH product_revenue AS (
    SELECT
        p.product_brand,
        p.product_id,
        p.product_name,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY
        p.product_brand,
        p.product_id,
        p.product_name
),
ranked_products AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY product_brand
            ORDER BY revenue DESC
        ) AS rn
    FROM product_revenue
)
SELECT
    product_brand,
    product_id,
    product_name,
    ROUND(revenue, 2) AS revenue,
    rn
FROM ranked_products
WHERE rn <= 3
ORDER BY product_brand, rn;


-- ==========================================
-- 5. Monthly Revenue with Previous Month Revenue
-- ==========================================

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC(
            'month',
            t.transaction_date
        )::DATE AS month,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY
        DATE_TRUNC('month', t.transaction_date)
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        LAG(revenue) OVER (
            ORDER BY month
        ),
        2
    ) AS previous_month_revenue
FROM monthly_revenue
ORDER BY month;


-- ==========================================
-- 6. Month-over-Month Revenue Growth %
-- ==========================================

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC(
            'month',
            t.transaction_date
        )::DATE AS month,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY
        DATE_TRUNC('month', t.transaction_date)
),
monthly_with_previous AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY month
        ) AS previous_revenue
    FROM monthly_revenue
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(
        (
            (revenue - previous_revenue)
            / NULLIF(previous_revenue, 0)
        ) * 100,
        2
    ) AS mom_growth_pct
FROM monthly_with_previous
ORDER BY month;


-- ==========================================
-- 7. Running Total Revenue
-- ==========================================

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC(
            'month',
            t.transaction_date
        )::DATE AS month,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY
        DATE_TRUNC('month', t.transaction_date)
)
SELECT
    month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(
        SUM(revenue) OVER (
            ORDER BY month
        ),
        2
    ) AS running_revenue
FROM monthly_revenue
ORDER BY month;


-- ==========================================
-- 8. Customer Revenue Contribution %
-- ==========================================

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY customer_id
)
SELECT
    customer_id,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue * 100.0 /
        SUM(revenue) OVER (),
        3
    ) AS revenue_share_pct
FROM customer_revenue
ORDER BY revenue DESC;


-- ==========================================
-- 9. Store Revenue vs Regional Average
-- ==========================================

WITH store_revenue AS (
    SELECT
        r.sales_region,
        s.store_id,
        s.store_name,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN stores s
        ON t.store_id = s.store_id
    JOIN regions r
        ON s.region_id = r.region_id
    JOIN products p
        ON t.product_id = p.product_id
    GROUP BY
        r.sales_region,
        s.store_id,
        s.store_name
)
SELECT
    sales_region,
    store_id,
    store_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        AVG(revenue) OVER (
            PARTITION BY sales_region
        ),
        2
    ) AS regional_avg_revenue,
    ROUND(
        revenue -
        AVG(revenue) OVER (
            PARTITION BY sales_region
        ),
        2
    ) AS difference_from_region_avg
FROM store_revenue
ORDER BY sales_region, revenue DESC;


-- ==========================================
-- 10. Customer Purchase Sequence
-- ==========================================

WITH customer_daily_purchase AS (
    SELECT
        customer_id,
        transaction_date,
        SUM(quantity) AS daily_units
    FROM transactions
    GROUP BY
        customer_id,
        transaction_date
)
SELECT
    customer_id,
    transaction_date,
    daily_units,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY transaction_date
    ) AS purchase_sequence,
    LAG(transaction_date) OVER (
        PARTITION BY customer_id
        ORDER BY transaction_date
    ) AS previous_purchase_date
FROM customer_daily_purchase
ORDER BY customer_id, transaction_date;

--Highest MoM Growth Month

WITH m AS (
    SELECT
        DATE_TRUNC('month', t.transaction_date)::date AS month,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p USING (product_id)
    GROUP BY 1
),
g AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS prev_revenue
    FROM m
)
SELECT
    month,
    ROUND(((revenue - prev_revenue) / prev_revenue) * 100, 2) AS mom_growth_pct
FROM g
WHERE prev_revenue IS NOT NULL
ORDER BY mom_growth_pct DESC
LIMIT 1;

--Lowest MoM Growth Month
WITH m AS (
    SELECT
        DATE_TRUNC('month', t.transaction_date)::date AS month,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p USING (product_id)
    GROUP BY 1
),
g AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS prev_revenue
    FROM m
)
SELECT
    month,
    ROUND(((revenue - prev_revenue) / prev_revenue) * 100, 2) AS mom_growth_pct
FROM g
WHERE prev_revenue IS NOT NULL
ORDER BY mom_growth_pct ASC
LIMIT 1;

--Final Running Revenue

WITH m AS (
    SELECT
        DATE_TRUNC('month', t.transaction_date)::date AS month,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p USING (product_id)
    GROUP BY 1
)
SELECT
    ROUND(SUM(revenue), 2) AS final_running_revenue
FROM m;


--Top Store in Each Region


WITH s AS (
    SELECT
        r.sales_region,
        st.store_id,
        st.store_name,
        SUM(t.quantity * p.product_retail_price) AS revenue,
        RANK() OVER (
            PARTITION BY r.sales_region
            ORDER BY SUM(t.quantity * p.product_retail_price) DESC
        ) AS rn
    FROM transactions t
    JOIN products p USING (product_id)
    JOIN stores st USING (store_id)
    JOIN regions r USING (region_id)
    GROUP BY
        r.sales_region,
        st.store_id,
        st.store_name
)
SELECT
    sales_region,
    store_id,
    store_name,
    ROUND(revenue, 2) AS revenue
FROM s
WHERE rn = 1
ORDER BY revenue DESC;


-- Customer segment counts

WITH customer_revenue AS (
    SELECT
        t.customer_id,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p USING (product_id)
    GROUP BY t.customer_id
)
SELECT
    CASE
        WHEN revenue >= 1500 THEN 'High Value'
        WHEN revenue >= 750 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,
    COUNT(*) AS customer_count
FROM customer_revenue
GROUP BY customer_segment;

-- Above-average revenue customer count
WITH customer_revenue AS (
    SELECT
        t.customer_id,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN products p USING (product_id)
    GROUP BY t.customer_id
)
SELECT COUNT(*) AS above_average_customer_count
FROM customer_revenue
WHERE revenue > (
    SELECT AVG(revenue)
    FROM customer_revenue
);


-- ==========================================
-- Section 5: Returns & Business Performance
-- ==========================================

-- ==========================================
-- 1. Total Returned Quantity
-- ==========================================

SELECT
    SUM(quantity) AS total_returned_quantity
FROM returns;


-- ==========================================
-- 2. Total Return Records
-- ==========================================

SELECT
    COUNT(*) AS total_return_records
FROM returns;


-- ==========================================
-- 3. Most Returned Products
-- ==========================================

SELECT
    p.product_id,
    p.product_name,
    p.product_brand,
    SUM(r.quantity) AS returned_units
FROM returns r
JOIN products p
    ON r.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.product_brand
ORDER BY returned_units DESC
LIMIT 5;


-- ==========================================
-- 4. Stores with Highest Returned Quantity
-- ==========================================

SELECT
    s.store_id,
    s.store_name,
    s.store_city,
    SUM(r.quantity) AS returned_units
FROM returns r
JOIN stores s
    ON r.store_id = s.store_id
GROUP BY
    s.store_id,
    s.store_name,
    s.store_city
ORDER BY returned_units DESC;


-- ==========================================
-- 5. Returns by Region
-- ==========================================

SELECT
    rg.sales_region,
    SUM(r.quantity) AS returned_units
FROM returns r
JOIN stores s
    ON r.store_id = s.store_id
JOIN regions rg
    ON s.region_id = rg.region_id
GROUP BY rg.sales_region
ORDER BY returned_units DESC;


-- ==========================================
-- 6. Monthly Return Trend
-- ==========================================

SELECT
    DATE_TRUNC(
        'month',
        return_date
    )::DATE AS month,
    SUM(quantity) AS returned_units
FROM returns
GROUP BY
    DATE_TRUNC('month', return_date)
ORDER BY month;


-- ==========================================
-- 7. Product Return Rate %
--    Returned Units / Sold Units
-- ==========================================

WITH sold_units AS (
    SELECT
        product_id,
        SUM(quantity) AS units_sold
    FROM transactions
    GROUP BY product_id
),
returned_units AS (
    SELECT
        product_id,
        SUM(quantity) AS units_returned
    FROM returns
    GROUP BY product_id
)
SELECT
    p.product_id,
    p.product_name,
    su.units_sold,
    COALESCE(ru.units_returned, 0) AS units_returned,
    ROUND(
        COALESCE(ru.units_returned, 0) * 100.0
        / NULLIF(su.units_sold, 0),
        2
    ) AS return_rate_pct
FROM sold_units su
JOIN products p
    ON su.product_id = p.product_id
LEFT JOIN returned_units ru
    ON su.product_id = ru.product_id
ORDER BY return_rate_pct DESC
LIMIT 20;


-- ==========================================
-- 8. Store Return Rate %
-- ==========================================

WITH store_sales AS (
    SELECT
        store_id,
        SUM(quantity) AS units_sold
    FROM transactions
    GROUP BY store_id
),
store_returns AS (
    SELECT
        store_id,
        SUM(quantity) AS units_returned
    FROM returns
    GROUP BY store_id
)
SELECT
    s.store_id,
    s.store_name,
    ss.units_sold,
    COALESCE(sr.units_returned, 0) AS units_returned,
    ROUND(
        COALESCE(sr.units_returned, 0) * 100.0
        / NULLIF(ss.units_sold, 0),
        2
    ) AS return_rate_pct
FROM store_sales ss
JOIN stores s
    ON ss.store_id = s.store_id
LEFT JOIN store_returns sr
    ON ss.store_id = sr.store_id
ORDER BY return_rate_pct DESC
limit 5;


-- ==========================================
-- 9. Products with High Sales and High Returns
-- ==========================================

WITH product_sales AS (
    SELECT
        product_id,
        SUM(quantity) AS units_sold
    FROM transactions
    GROUP BY product_id
),
product_returns AS (
    SELECT
        product_id,
        SUM(quantity) AS units_returned
    FROM returns
    GROUP BY product_id
)
SELECT
    p.product_id,
    p.product_name,
    ps.units_sold,
    COALESCE(pr.units_returned, 0) AS units_returned,
    ROUND(
        COALESCE(pr.units_returned, 0) * 100.0
        / NULLIF(ps.units_sold, 0),
        2
    ) AS return_rate_pct
FROM product_sales ps
JOIN products p
    ON ps.product_id = p.product_id
LEFT JOIN product_returns pr
    ON ps.product_id = pr.product_id
WHERE ps.units_sold > 500
ORDER BY return_rate_pct DESC, units_sold DESC;


-- ==========================================
-- 10. Estimated Revenue Impact of Returns
-- ==========================================

SELECT
    ROUND(
        SUM(r.quantity * p.product_retail_price),
        2
    ) AS estimated_return_value
FROM returns r
JOIN products p
    ON r.product_id = p.product_id;







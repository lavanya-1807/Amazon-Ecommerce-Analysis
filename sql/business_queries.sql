CREATE SCHEMA ecommerce_analysis;

USE ecommerce_analysis;

SELECT * FROM amazon_sale_report
LIMIT 100;

SELECT COUNT(*) FROM amazon_sale_report ;

SELECT STR_TO_DATE(Date, '%m-%d-%y') AS proper_date
FROM amazon_sale_report
LIMIT 5;

ALTER TABLE amazon_sale_report
ADD COLUMN proper_date DATE;

UPDATE amazon_sale_report 
SET proper_date = STR_TO_DATE(Date, '%m-%d-%y');

SET SQL_SAFE_UPDATES = 0;

UPDATE amazon_sale_report
SET proper_date = CASE
    WHEN Date LIKE '%-%-%' AND LENGTH(Date) = 10 
    THEN STR_TO_DATE(Date, '%m-%d-%Y')
    WHEN Date LIKE '%-%-%' AND LENGTH(Date) = 8 
    THEN STR_TO_DATE(Date, '%m-%d-%y')
    ELSE NULL
END;

SET SQL_SAFE_UPDATES = 1;

SELECT MONTHNAME(proper_date) , SUM(Amount) AS total_salary
FROM amazon_sale_report
GROUP BY MONTHNAME(proper_date)
ORDER BY total_salary DESC
LIMIT 1;


SELECT Category, COUNT(*) as top_category
FROM amazon_sale_report
GROUP BY Category
ORDER BY  top_category DESC
LIMIT 3;

SELECT Category, SUM(Amount) as top_category
FROM amazon_sale_report
GROUP BY Category
ORDER BY  top_category DESC
LIMIT 3;

SELECT MONTHNAME(proper_date) , Category ,SUM(Amount) AS total_amount
FROM amazon_sale_report
GROUP BY MONTHNAME(proper_date) , Category
ORDER BY total_amount DESC 
LIMIT 3;

SELECT `ship-city`, COUNT(*) AS total_orders
FROM amazon_sale_report
GROUP BY `ship-city`
ORDER BY total_orders DESC
LIMIT 5;

SELECT 
    CASE 
        WHEN Status IN ('Shipped - Delivered to Buyer', 
                        'Shipped - Out for Delivery',
                        'Shipped - Picked Up')
                        THEN 'Completed'
        WHEN Status IN ('Cancelled',
                        'Shipped - Damaged',
                        'Shipped - Lost in Transit',
                        'Shipped - Rejected by Buyer',
                        'Shipped - Returned to Seller',
                        'Shipped - Returning to Seller')
                        THEN 'Failed'
        ELSE 'In Progress'
END AS order_status, COUNT(*) AS total_orders
FROM amazon_sale_report
GROUP BY order_status
ORDER BY total_orders DESC;

SELECT 
    Category,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate
FROM amazon_sale_report
GROUP BY Category
ORDER BY cancellation_rate DESC
LIMIT 5;

SELECT 
    B2B,
    AVG(Amount) AS avg_order_value,
    COUNT(*) AS total_orders
FROM amazon_sale_report
GROUP BY B2B
ORDER BY total_orders DESC;

SELECT `ship-state`, ROUND(SUM(Amount),2) AS total_amount,
ROUND(SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate
FROM amazon_sale_report
GROUP BY `ship-state` 
ORDER BY  total_amount DESC , cancellation_rate DESC
LIMIT 3;

SELECT MONTHNAME(proper_date), Category, SUM(Amount) AS total_amount
FROM amazon_sale_report
GROUP BY MONTHNAME(proper_date), Category
ORDER BY total_amount DESC;

SELECT 
    Fulfilment,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Status IN (
        'Shipped - Delivered to Buyer',
        'Shipped - Out for Delivery',
        'Shipped - Picked Up',
        'Shipped') 
    THEN 1 ELSE 0 END) AS successful_orders,
    ROUND(SUM(CASE WHEN Status IN (
        'Shipped - Delivered to Buyer',
        'Shipped - Picked Up',
        'Shipped - Out for Delivery',
        'Shipped') 
    THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate
FROM amazon_sale_report
GROUP BY Fulfilment
ORDER BY success_rate DESC;


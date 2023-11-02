/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/

## Answer 1.
USE orders;

SELECT 
    CUSTOMER_ID,
    CASE 
        WHEN CUSTOMER_GENDER = 'M' THEN CONCAT('Mr. ', UPPER(CUSTOMER_FNAME), ' ', UPPER(CUSTOMER_LNAME))
        ELSE CONCAT('Ms. ', UPPER(CUSTOMER_FNAME), ' ', UPPER(CUSTOMER_LNAME))
    END AS CUSTOMER_FULL_NAME,
    CUSTOMER_EMAIL,
    YEAR(CUSTOMER_CREATION_DATE) AS CUSTOMER_CREATION_YEAR,
    CASE 
        WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN 'A'
        WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE) < 2011 THEN 'B'
        ELSE 'C'
    END AS CUSTOMER_CATEGORY
FROM 
    ONLINE_CUSTOMER;



/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/
## Answer 2.
SELECT 
    P.PRODUCT_ID,
    P.PRODUCT_DESC,
    P.PRODUCT_QUANTITY_AVAIL,
    P.PRODUCT_PRICE,
    P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE AS INVENTORY_VALUE,
    CASE 
        WHEN P.PRODUCT_PRICE > 20000 THEN P.PRODUCT_PRICE * 0.80
        WHEN P.PRODUCT_PRICE > 10000 THEN P.PRODUCT_PRICE * 0.85
        ELSE P.PRODUCT_PRICE * 0.90
    END AS NEW_PRICE
FROM 
    PRODUCT P
LEFT JOIN 
    ORDER_ITEMS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
WHERE 
    OI.PRODUCT_ID IS NULL
ORDER BY 
    INVENTORY_VALUE DESC;



/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

## Answer 3.
SELECT 
    PC.PRODUCT_CLASS_CODE,
    PC.PRODUCT_CLASS_DESC,
    COUNT(P.PRODUCT_ID) AS PRODUCT_COUNT,
    SUM(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE
FROM 
    PRODUCT P
JOIN 
    PRODUCT_CLASS PC ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
GROUP BY 
    PC.PRODUCT_CLASS_CODE, PC.PRODUCT_CLASS_DESC
HAVING 
    SUM(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) > 100000
ORDER BY 
    INVENTORY_VALUE DESC;



/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/
 
## Answer 4.
SELECT 
    OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS FULL_NAME,
    OC.CUSTOMER_EMAIL,
    OC.CUSTOMER_PHONE,
    A.COUNTRY
FROM 
    ONLINE_CUSTOMER OC
JOIN 
    ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE 
    OC.CUSTOMER_ID IN (
        SELECT OH.CUSTOMER_ID 
        FROM ORDER_HEADER OH 
        WHERE OH.ORDER_STATUS = 'cancelled'
        GROUP BY OH.CUSTOMER_ID
    )
AND 
    OC.CUSTOMER_ID NOT IN (
        SELECT DISTINCT OH.CUSTOMER_ID 
        FROM ORDER_HEADER OH 
        WHERE OH.ORDER_STATUS <> 'cancelled'
    );




/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */

## Answer 5.  
SELECT 
    S.SHIPPER_NAME,
    A.CITY,
    COUNT(DISTINCT OH.CUSTOMER_ID) AS NUM_OF_CUSTOMERS,
    COUNT(DISTINCT OH.ORDER_ID) AS NUM_OF_CONSIGNMENTS
FROM 
    SHIPPER S
JOIN 
    ORDER_HEADER OH ON S.SHIPPER_ID = OH.SHIPPER_ID
JOIN 
    ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
JOIN 
    ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE 
    S.SHIPPER_NAME = 'DHL'
GROUP BY 
    S.SHIPPER_NAME, A.CITY
ORDER BY 
    A.CITY;



/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

## Answer 6.
SELECT 
    P.PRODUCT_ID,
    P.PRODUCT_DESC,
    P.PRODUCT_QUANTITY_AVAIL,
    COALESCE(SUM(OI.PRODUCT_QUANTITY), 0) AS QUANTITY_SOLD,
    CASE 
        WHEN PC.PRODUCT_CLASS_DESC IN ('Electronics', 'Computer') THEN
            CASE 
                WHEN COALESCE(SUM(OI.PRODUCT_QUANTITY), 0) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.10 * COALESCE(SUM(OI.PRODUCT_QUANTITY), 0) THEN 'Low inventory, need to add inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.50 * COALESCE(SUM(OI.PRODUCT_QUANTITY), 0) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        WHEN PC.PRODUCT_CLASS_DESC IN ('Mobiles', 'Watches') THEN
            CASE 
                WHEN COALESCE(SUM(OI.PRODUCT_QUANTITY), 0) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.20 * COALESCE(SUM(OI.PRODUCT_QUANTITY), 0) THEN 'Low inventory, need to add inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.60 * COALESCE(SUM(OI.PRODUCT_QUANTITY), 0) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        ELSE
            CASE 
                WHEN COALESCE(SUM(OI.PRODUCT_QUANTITY), 0) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.30 * COALESCE(SUM(OI.PRODUCT_QUANTITY), 0) THEN 'Low inventory, need to add inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.70 * COALESCE(SUM(OI.PRODUCT_QUANTITY), 0) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
    END AS INVENTORY_STATUS
FROM 
    PRODUCT P
LEFT JOIN 
    ORDER_ITEMS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
JOIN 
    PRODUCT_CLASS PC ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
GROUP BY 
    P.PRODUCT_ID, P.PRODUCT_DESC, P.PRODUCT_QUANTITY_AVAIL, PC.PRODUCT_CLASS_DESC;



/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */

## Answer 7.
SET @CartonVolume = (SELECT LEN * WIDTH * HEIGHT FROM CARTON WHERE CARTON_ID = 10);

SELECT 
    OI.ORDER_ID,
    SUM(P.LEN * P.WIDTH * P.HEIGHT) AS ORDER_VOLUME
FROM 
    ORDER_ITEMS OI
JOIN 
    PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
GROUP BY 
    OI.ORDER_ID
HAVING 
    ORDER_VOLUME <= @CartonVolume
ORDER BY 
    ORDER_VOLUME DESC
LIMIT 1;




/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

## Answer 8.
SELECT 
    OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS FULL_NAME,
    SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY,
    SUM(OI.PRODUCT_QUANTITY * P.PRODUCT_PRICE) AS TOTAL_VALUE
FROM 
    ONLINE_CUSTOMER OC
JOIN 
    ORDER_HEADER OH ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
JOIN 
    ORDER_ITEMS OI ON OH.ORDER_ID = OI.ORDER_ID
JOIN 
    PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
WHERE 
    OH.PAYMENT_MODE = 'Cash' 
    AND OC.CUSTOMER_LNAME LIKE 'G%'
GROUP BY 
    OC.CUSTOMER_ID, OC.CUSTOMER_FNAME, OC.CUSTOMER_LNAME;



/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */

## Answer 9.
SELECT 
    P.PRODUCT_ID,
    P.PRODUCT_DESC,
    SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM 
    ORDER_ITEMS OI
JOIN 
    PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
JOIN 
    ORDER_HEADER OH ON OI.ORDER_ID = OH.ORDER_ID
JOIN 
    ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
JOIN 
    ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE 
    -- Ensure the product is in an order that contains product id 201
    OI.ORDER_ID IN (
        SELECT DISTINCT ORDER_ID 
        FROM ORDER_ITEMS 
        WHERE PRODUCT_ID = 201
    )
    AND OI.PRODUCT_ID <> 201  -- Exclude product id 201 itself
    AND A.CITY NOT IN ('Bangalore', 'New Delhi')  -- Exclude these cities
GROUP BY 
    P.PRODUCT_ID, P.PRODUCT_DESC
ORDER BY 
    TOTAL_QUANTITY DESC;



/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */

## Answer 10.
SELECT 
    OH.ORDER_ID,
    OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS FULL_NAME,
    SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM 
    ORDER_HEADER OH
JOIN 
    ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
JOIN 
    ORDER_ITEMS OI ON OH.ORDER_ID = OI.ORDER_ID
JOIN 
    ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE 
    OH.ORDER_ID MOD 2 = 0  -- Ensure the order_id is even
    AND A.PINCODE NOT LIKE '5%'  -- Ensure pincode doesn't start with '5'
GROUP BY 
    OH.ORDER_ID, OC.CUSTOMER_ID, OC.CUSTOMER_FNAME, OC.CUSTOMER_LNAME
ORDER BY 
    TOTAL_QUANTITY DESC
LIMIT 15;




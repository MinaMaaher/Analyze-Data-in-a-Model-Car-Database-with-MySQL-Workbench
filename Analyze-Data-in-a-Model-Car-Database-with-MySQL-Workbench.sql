--  Total number of customers at each country
select count(customerName) as count_customers_per_country ,  country
from customers
group by  country 
order by count_customers_per_country desc 
;
-- we see that USA has most of the customers and then come germany and france .

-- -------------------------
-- -------------------------

-- customers that cancelled their order, their reasons and the quantity of products ordered
select o.customernumber , o.orderNumber , o.status , sum(oo.quantityordered) as tot_quantity_ordered , o.comments 
from orders o join orderdetails oo on o.orderNumber = oo.orderNumber
where o.status = 'cancelled'
group by  o.orderNumber , o.customernumber, o.comments 
order by tot_quantity_ordered desc 
  ;
  
-- we see that customer (141) cancelled the order because he had better offer from another competitor 

-- -------------------------
-- -------------------------

-- all the products that customer (141) has found better offers at
select o.customernumber , o.status , sum(oo.quantityordered) as tot_quantity_ordered ,p.productname,oo.priceEach , o.comments 
from orders o join orderdetails oo on o.orderNumber = oo.orderNumber
join products p on p.productCode = oo.productCode
where o.status = 'cancelled' and o.customerNumber = 141
group by  o.orderNumber ,p.productname, o.customernumber, o.comments , oo.priceEach
order by tot_quantity_ordered desc , o.customerNumber desc 
  ;
  
-- -------------------------
-- -------------------------
  
-- customers that cancelled or have a disputed  , on hold , in process orders
SELECT * FROM orders 
WHERE status="Cancelled" 
OR status="On Hold" 
OR status="Disputed" 
OR status="In Process"
;

-- -------------------------
-- -------------------------
-- profit percent earned from the products that were ordered the least

select p.productname , p.buyprice  , o.priceeach , p.msrp  
, ( o.priceeach - p.buyprice ) as profits , (( o.priceeach - p.buyprice )/ p.buyprice)*100 as profit_percentage
from products p join orderdetails o on   p.productcode = o.productcode 
group by p.productName , p.buyprice , o.priceeach , p.msrp
order by SUM(o.quantityOrdered)asc limit 10  ;

-- profit percent earned from the products that were ordered the most

select p.productname , p.buyprice  , o.priceeach , p.msrp  
, ( o.priceeach - p.buyprice ) as profits , (( o.priceeach - p.buyprice )/ p.buyprice)*100 as profit_percentage
from products p join orderdetails o on   p.productcode = o.productcode 
group by p.productName , p.buyprice , o.priceeach , p.msrp
order by SUM(o.quantityOrdered) desc limit 10  ;

-- ------------------------------------------------

-- a major client seemed to have cancelled their order as they recieved a better offer depending on the offer given by our competitor
-- we could bring down the pricing of each of the products by 5%
 
-- cancelled products with their prices
select o.customernumber ,p.productCode , o.status , sum(oo.quantityordered) as tot_quantity_ordered ,p.productname,oo.priceEach 
from orders o join orderdetails oo on o.orderNumber = oo.orderNumber
join products p on p.productCode = oo.productCode
where o.status = 'cancelled' and o.customerNumber = 141
group by p.productCode , p.productname, o.customernumber , oo.priceEach
order by tot_quantity_ordered desc , o.customerNumber desc 
  ;
    
-- products names based on product codes that were cancelled and price difference between selling price and buy price  

select  p.productCode ,p.productname ,oo.priceEach
 , (oo.priceEach - p.buyPrice) AS price_difference, 
(oo.priceEach*0.95) AS Price_reduction 
from orders o join orderdetails oo on o.orderNumber = oo.orderNumber
join products p on p.productCode = oo.productCode
where o.status = 'cancelled' and o.customerNumber = 141
group by p.productCode , p.productname, o.customernumber , oo.priceEach
 
  ;
  
-- ------------------------------------------------
-- total profits (payments)
select sum(amount) from payments 
 ;
 
-- Least profits earned in which countries
 
 select  c.country , sum(p.amount) as total
 from payments p right join customers c
 on p.customerNumber = c.customerNumber
 group by c.country order by total asc
 ;
 -- poland , russia , israel , south africa , netherlands , portugal have no profits .

-- most profits earned in which countries
 
 select  c.country , sum(p.amount) as total
 from payments p right join customers c
 on p.customerNumber = c.customerNumber
 group by c.country order by total desc
 ;
-- ------------------------------------------------------------

-- stocks with optimal values 
select  p.productname , p.quantityinstock ,sum(o.quantityordered) as total_ordered 
from products p left join orderdetails o on p.productCode = o.productCode
group by  p.productname , p.quantityinstock 
having ( p.quantityinstock - total_ordered ) <3000
and (  p.quantityinstock - total_ordered ) >500
order by  total_ordered desc
;

-- -------------------------------------------------

-- these products needs to be restocked beacause it's running out .
select  p.productname ,p.productVendor, p.quantityinstock ,sum(o.quantityordered) as total_ordered 
, (p.quantityinstock - sum(o.quantityordered)) as remainings
from products p left join orderdetails o on p.productCode = o.productCode
group by  p.productname , p.quantityinstock , p.productVendor
having ( p.quantityinstock - total_ordered ) <500
and (  p.quantityinstock - total_ordered ) >0
order by  total_ordered 
;

-- ------------------------------------------------------------
-- these products needs to be urgent restock beacause warehouses dosen't have any more of it .
select  p.productname ,p.productVendor, p.quantityinstock ,sum(o.quantityordered) as total_ordered 
, (p.quantityinstock - sum(o.quantityordered)) as remainings
from products p left join orderdetails o on p.productCode = o.productCode
group by  p.productname , p.quantityinstock , p.productVendor
having ( p.quantityinstock - total_ordered ) < 0
order by  total_ordered desc
;
 
-- -------------------------------------------------

-- these products needs to be reduced from the stock beacause it has huge amount .
-- we can reduce 50% o these products and still have the optimal basis . 
-- we can reduce it by 20% - 30% but we still have many unbuyed products .

select p.productcode , p.productname , p.warehouseCode ,p.quantityinstock ,sum(o.quantityordered) as total_ordered 
, (p.quantityinstock - sum(o.quantityordered)) as remainings 
, (p.quantityInStock * 0.5) AS reduction_stock -- as 50 % of reduction .
, (p.quantityInStock * 0.5 - sum(o.quantityordered) ) AS remaining_after_reduction 
from products p left join orderdetails o on p.productCode = o.productCode
group by  p.productcode , p.productname , p.quantityinstock 
having ( p.quantityinstock - total_ordered ) >3000
order by  total_ordered asc
;
 -- ----------------------------------------------------------
 
select warehousecode from products 
having productcode = p.productcode in (
select p.productcode 
from products p left join orderdetails o on p.productCode = o.productCode 
having ( p.quantityinstock - total_ordered ) >3000
);

-- we here can see which warehouse will has more reduce in products 

select p.productcode , p.productname , p.warehouseCode ,p.quantityinstock ,sum(o.quantityordered) as total_ordered 
, (p.quantityinstock - sum(o.quantityordered)) as remainings 
, (p.quantityInStock * 0.5) AS reduction_stock 
, (p.quantityInStock * 0.5 - sum(o.quantityordered) ) AS remaining_after_reduction 
from products p left join orderdetails o on p.productCode = o.productCode
group by  p.productcode , p.productname , p.quantityinstock 
having ( p.quantityinstock - total_ordered ) >3000
order by p.warehouseCode asc , reduction_stock desc
;

-- -----------------------------------------------

-- details on warehouses
SELECT * FROM warehouses;

-- quantity of stock in each warehouse
SELECT  p.warehouseCode,w.warehousename, SUM(p.quantityInStock) AS stock 
FROM products p join warehouses w 
on p.warehouseCode = w.warehouseCode
GROUP BY warehouseCode;

-- A,B warehouses are the primary ones used 

-- quantity shipped from each warehouse
SELECT p.warehouseCode, SUM(o.quantityOrdered) 
FROM products p LEFT JOIN orderdetails o ON o.productCode= p.productCode
GROUP BY p.warehouseCode;


-- --------------------------------------------------------------------------

-- quantity of total sales each year , significant decline in the last year
SELECT YEAR(o.orderDate) AS Year, SUM(oo.quantityOrdered) AS Total_quantity_sales
FROM orders o  JOIN orderdetails oo 
ON o.orderNumber= oo.orderNumber 
GROUP BY YEAR(o.orderDate);

-- 2004 was the best selling year then 2005 was the worst .

-- ----------------------------------------------------------
-- ---------------------------------------------------------
-- ----------------------------------------------------------

-- As conclusion : 
-- after we reduce the products stock we knew above , we will gain extra stroage at warehouses A and B the most 
-- so we can move products from warehouse D to C then to A or B so we can close the warehouse easily .









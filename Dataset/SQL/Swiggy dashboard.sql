create database Swiggy_db
use Swiggy_db
create table dim_location(location_id int,state varchar(100),city varchar(100),location varchar(200));
desc dim_location;
alter table dim_location
add primary key(location_id);
create table dim_restaurant(restaurant_id int,restaurant_name varchar(100));
desc dim_restaurant;
alter table dim_restaurant add primary key(restaurant_id);
CREATE TABLE fact_orders(order_id INT,date_id INT,location_id INT,restaurant_id INT,food_id INT,price DECIMAL(10,2),rating DECIMAL(3,1),rating_count INT);
desc fact_orders;



select f.date_id from fact_orders f left join dim_date d on f.date_id=d.date_id where d.date_id is null; 
select f.location_id from fact_orders f left join dim_location l on f.location_id=l.location_id where l.location_id is null;
select f.restaurant_id from fact_orders f left join dim_restaurant r on f.restaurant_id=r.restaurant_id where r.restaurant_id is null;
select f.food_id from fact_orders f left join dim_dish d on f.food_id=d.dish_id where d.dish_id is null;


ALTER TABLE fact_orders
ADD CONSTRAINT fk_date
FOREIGN KEY(date_id)
REFERENCES dim_date(date_id);

ALTER TABLE fact_orders
ADD CONSTRAINT fk_location
FOREIGN KEY(location_id)
REFERENCES dim_location(location_id);

ALTER TABLE fact_orders
ADD CONSTRAINT fk_restaurant
FOREIGN KEY(restaurant_id)
REFERENCES dim_restaurant(restaurant_id);

ALTER TABLE fact_orders
ADD CONSTRAINT fk_dish
FOREIGN KEY(food_id)
REFERENCES dim_dish(dish_id);

SELECT *
FROM fact_orders f
JOIN dim_date d
ON f.date_id = d.date_id
LIMIT 5;

select * from fact_orders f join dim_location l on f.location_id=l.location_id limit 5;
CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    order_date DATE
);
CREATE TABLE dim_dish (
    dish_id INT PRIMARY KEY,category VARCHAR(100),dish_name VARCHAR(255));
select * from dim_dish;
select * from dim_date;

SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:/Users/Sudulaguntla.Yamini/Downloads/dim_location.csv'
INTO TABLE dim_location
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(location_id,state,city,location);
select * from dim_location;
select * from dim_restaurant;
select * from fact_orders;


### Data Cleaning Queries
###Check Null Values
select * from fact_orders where order_id IS NULL or date_id 
IS NULL or location_id IS NULL 
or restaurant_id IS NULL or food_id IS NULL;

select * from dim_restaurant where restaurant_id IS NULL;
select * from dim_location where location_id IS NULL;
select * from dim_dish where dish_id IS NULL;
SELECT *
FROM dim_dish
WHERE dish_id IS NULL
   OR category IS NULL
   OR dish_name IS NULL;
   
### COUNT THE VALUES
select count(*) as total_rows,
count(order_id) as total_orders,
count(date_id) as total_days,
count(location_id) as total_locations,
count(restaurant_id) as total_restaurants from fact_orders;

select order_id, count(order_id) as  total_orders from fact_orders group by order_id having count(order_id)>1;

SELECT o.* FROM fact_orders o LEFT JOIN dim_restaurant r 
ON o.restaurant_id = r.restaurant_id WHERE r.restaurant_id IS NULL;


select * from dim_dish where category =' 'or dish_name=' ';
select * from dim_location  where state =' ' or city=' ' or location=' ';
select * from dim_restaurant;
select * from dim_restaurant where restaurant_name=' ';
###########To find duplicates
SELECT dish_id, category, dish_name, COUNT(*) AS cnt
FROM dim_dish
GROUP BY dish_id, category, dish_name
HAVING COUNT(*) > 1;

SELECT location_id, state, city, location, COUNT(*) AS cnt
FROM dim_location
GROUP BY location_id, state, city, location
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) AS cnt
FROM fact_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

alter table dim_date 
add column day_num int;
add  column Year int,
add column Month int,
add column Month_name varchar(10),
add column Quater int,
add column week_num int;
SET SQL_SAFE_UPDATES = 0;
update dim_date
set day_num=day(order_date),
month=month(order_date),
month_name=monthname(order_date),
Year=Year(order_date),
Quater=Quarter(order_date),
week_num=week(order_date);
set sql_safe_updates=1
select * from dim_date;

select * from fact_orders f join dim_date d on f.date_id=d.date_id
 join dim_dish di on f.food_id=di.dish_id join dim_location l on l.location_id=f.location_id
 join dim_restaurant r on f.restaurant_id=r.restaurant_id;
 
 ####KPI"S:
 # Total Orders
 select count(*) as total_orders from fact_orders;
 
 ## Total_sales
 SELECT CONCAT(
         FORMAT(SUM(price)/1000000, 2),
         ' INR Millions'
       ) AS total_sales
FROM fact_orders;
select min(location_id) ,max(location_id) from fact_orders;

## Average Sales
select concat(format(avg(price),2), 'INR') as Average_value from fact_orders;
##Average Rating
select round(avg(rating),1) from fact_orders;
#### MONTHLY ORDERS
select * from dim_date;
select d.month,d.month_name,count(f.order_id) as total_orders from fact_orders f join dim_date d on d.date_id=f.date_id
group by d.month,d.month_name order by total_orders desc;

### MONTHLY REVENUE
select d.month,d.month_name,concat(sum(f.price),'  INR MILLIONS') as total_revenue from fact_orders f join
dim_date d on d.date_id=f.date_id group by d.month,d.month_name order by total_revenue desc;

### QUATERLY TREND

select * from dim_date;
select d.Quater,count(f.order_id) as total_orders from fact_orders f join dim_date d on d.date_id=f.date_id
group by d.Quater order by total_orders desc;

### YEARLY TREND
select d.Year,count(*) as total_orders from fact_orders f join dim_date d on d.date_id=f.date_id group by d.Year order by total_orders desc;

### yearly Sales
select d.year,sum(f.price) as total_sales from fact_orders f join dim_date d on f.date_id=d.date_id group by d.year order by 
total_sales desc


### top 10 cities orders
select l.city,count(f.order_id) as total_orders from fact_orders f join dim_location l on f.location_id=l.location_id group by 
l.city order by total_orders desc;
select * from fact_orders;
select l.state,sum(f.price) as revenue from fact_orders f join dim_location l on f.location_id=l.location_id
group by l.state order by revenue desc;


SELECT DISTINCT f.location_id, l.city
FROM fact_orders f
JOIN dim_location l
ON f.location_id = l.location_id;

SELECT DISTINCT city
FROM dim_location
ORDER BY city;

SELECT DISTINCT location_id
FROM fact_orders
ORDER BY location_id;

SELECT
    f.location_id,
    l.city,
    COUNT(*) AS orders
FROM fact_orders f
JOIN dim_location l
ON f.location_id = l.location_id
GROUP BY f.location_id, l.city
ORDER BY f.location_id;

SELECT *
FROM dim_location
WHERE city <> 'Bengaluru'
LIMIT 20;
SELECT
    MIN(location_id),
    MAX(location_id),
    COUNT(DISTINCT location_id)
FROM fact_orders;

SELECT DISTINCT location_id
FROM fact_orders
ORDER BY location_id;
select * from dim_location;

SELECT DISTINCT city
FROM dim_location
ORDER BY city;
select count(distinct city) from dim_location order by city

SELECT DISTINCT l.city
FROM fact_orders f
JOIN dim_location l
ON f.location_id = l.location_id
ORDER BY l.city;

SELECT
    city,
    MIN(location_id) AS min_id,
    MAX(location_id) AS max_id,
    COUNT(*) AS total_locations
FROM dim_location
GROUP BY city
ORDER BY min_id;


SELECT DISTINCT location_id
FROM fact_orders
ORDER BY location_id;

SELECT
    location_id,
    city
FROM dim_location
WHERE location_id BETWEEN 1 AND 74
ORDER BY location_id;
SELECT location_id, COUNT(*)
FROM dim_location
GROUP BY location_id
HAVING COUNT(*) > 1;

SELECT
   *
FROM fact_orders
WHERE location_id > 74;

SELECT
    MIN(location_id),
    MAX(location_id)
FROM fact_orders;
SELECT *
FROM fact_orders
ORDER BY location_id DESC
LIMIT 10;

SHOW CREATE TABLE fact_orders;

TRUNCATE TABLE fact_orders;
show tables;
desc fact_orders;
select * from fact_orders;
SET GLOBAL local_infile = 1;


LOAD DATA LOCAL INFILE 'C:/Users/Sudulaguntla.Yamini/Downloads/fact_orders.csv'
INTO TABLE fact_orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id,
 date_id,
 location_id,
 restaurant_id,
 food_id,
 price,
 rating,
 rating_count);
 SHOW GLOBAL VARIABLES LIKE 'local_infile';
 
 ALTER TABLE fact_orders DROP FOREIGN KEY fk_dish;
ALTER TABLE fact_orders DROP FOREIGN KEY fk_date;
ALTER TABLE fact_orders DROP FOREIGN KEY fk_location;
ALTER TABLE fact_orders DROP FOREIGN KEY fk_restaurant;
select database();
SHOW CREATE TABLE swiggy_db.fact_orders;
SELECT
    CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'swiggy_db'
AND TABLE_NAME = 'fact_orders'
AND REFERENCED_TABLE_NAME IS NOT NULL;
use swiggy_db;
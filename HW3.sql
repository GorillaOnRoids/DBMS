USE HW3;

alter table merchants
add primary key (mid);

alter table products
add primary key (pid);

alter table sell
add foreign key (mid) references merchants(mid);
alter table sell
add foreign key (pid) references products(pid);

alter table orders
add primary key (oid);

alter table contain
add foreign key (oid) references orders(oid);
alter table contain
add foreign key (pid) references products(pid);

alter table customers
add primary key (cid);

alter table place
add foreign key (cid) references customers(cid);
alter table place
add foreign key (oid) references orders(oid);
#Primary and Foreign Keys

alter table products
add constraint check_product_name check (name in ('Printer', 'Ethernet Adapter', 'Desktop', 'Hard Drive',
            'Laptop', 'Router', 'Network Card', 'Super Drive', 'Monitor'));

alter table products
add constraint check_category check (category IN ('Peripheral', 'Networking', 'Computer'));

alter table sell
add constraint check_sell_price check (price between 0 and 100000);

alter table sell
add constraint check_quantity_available check (quantity_available between 0 and 1000);

alter table orders
add constraint check_shipping_method check (shipping_method in ('UPS','FedEx','USPS'));

alter table orders 
add constraint check_shipping_cost check (shipping_cost between 0 and 500);

alter table place
add constraint check_order_date check (order_date between '2004-11-01' and '2099-01-01'); #This is my birthday. This is the date the company opened
#Adding Constraints

select products.name,
merchants.name,
sell.quantity_available
from products
join sell on sell.pid=products.pid
join merchants on merchants.mid=sell.mid 
where(quantity_available=0);
#Q1 

select products.name,
products.description,
sell.quantity_available
from products
join sell on sell.pid=products.pid 
where(quantity_available!=0);
#Q2

select count(oid),
products.name
from contain
join products on products.pid=contain.pid
where (products.name != 'Router' and products.name in ('Hard Drive','Super Drive'))
group by products.name;
#Q3

select sell.price,
round((sell.price*0.8),2) as sale_price,
products.name,
products.category,
merchants.name
from sell
join products on sell.pid=products.pid
join merchants on sell.mid=merchants.mid
where (merchants.name = 'HP' and products.category = 'Networking');
#Q4

select orders.oid, 
products.name,
sell.price,
customers.fullname,
merchants.name,
place.order_date
FROM customers 
JOIN place ON customers.cid = place.cid
JOIN orders ON place.oid = orders.oid
JOIN contain ON orders.oid = contain.oid
JOIN products ON contain.pid = products.pid
JOIN sell ON sell.pid = products.pid
JOIN merchants ON sell.mid = merchants.mid
where (customers.fullname = 'Uriel Whitney'and merchants.name = 'Acer')
order by order_date desc;
#Q5

select merchants.name,
year(place.order_date),
round(SUM(sell.price),2) as total_sales
FROM merchants 
JOIN sell ON merchants.mid = sell.mid
JOIN products ON sell.pid = products.pid
JOIN contain ON products.pid = contain.pid
JOIN orders ON contain.oid = orders.oid
join place on place.oid = orders.oid
GROUP BY merchants.name, YEAR(place.order_date);
#Q6

select merchants.name,
year(place.order_date),
round(SUM(sell.price),2) as total_sales
FROM merchants 
JOIN sell ON merchants.mid = sell.mid
JOIN products ON sell.pid = products.pid
JOIN contain ON products.pid = contain.pid
JOIN orders ON contain.oid = orders.oid
join place on place.oid = orders.oid
GROUP BY merchants.name, YEAR(place.order_date)
order by total_sales desc
limit 1;
#Q7

select orders.shipping_method,
	round(avg(orders.shipping_cost),2) as avg_cost
    from orders
    group by shipping_method
    order by avg_cost asc
    limit 1;
#Q8

select merchants.name as seller,
products.category,
round(sum(sell.price),2) as total_sales
from merchants
join sell on merchants.mid = sell.mid
join products on sell.pid = products.pid
join contain on products.pid = contain.pid
join orders on contain.oid = orders.oid
group by seller,
products.category
order by seller, 
total_sales desc;
#Q9

WITH spenders AS (
    SELECT 
        merchants.name AS seller,
        customers.fullname,
        SUM(sell.price) AS total_spent
    FROM customers
    JOIN place ON customers.cid = place.cid
    JOIN contain ON place.oid = contain.oid
    JOIN sell ON contain.pid = sell.pid
    JOIN merchants ON sell.mid = merchants.mid
    GROUP BY seller, customers.fullname
),
ranked AS (
    SELECT 
        seller,
        fullname,
        total_spent,
        ROW_NUMBER() OVER (PARTITION BY seller ORDER BY total_spent DESC) AS max_rank,
        ROW_NUMBER() OVER (PARTITION BY seller ORDER BY total_spent ASC) AS min_rank
    FROM spenders
)
SELECT 
    seller,
    fullname,
    total_spent,
    CASE
        WHEN max_rank = 1 THEN 'Most Spent'
        WHEN min_rank = 1 THEN 'Least Spent'
    END AS spend_status
FROM ranked
WHERE max_rank = 1 OR min_rank = 1
ORDER BY seller, total_spent DESC;
#Q10







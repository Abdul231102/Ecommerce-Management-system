create database ecommerce;
use ecommerce;
show tables;
-- customers 
alter table customers_det modify account_created date;
alter table customers_det modify last_login date;

desc customers_det;
select * from customers_det;
drop table customers_det;

-- orders
alter table orders modify order_date date;

desc orders;
select * from orders;

-- payments
select * from payments;

-- products
select * from products;

-- shipping

select * from shipping;

-- Task 1 - Update loyalty points for customers based on age.

update  customers_det set loyalty_points =  case
when age < 25 then loyalty_points + 10 
when age between 25 and 40 then loyalty_points  + 20
else loyalty_points + 5  end ; 

select * from customers_det;

-- Task 2 - Get total order value per country and classify sales category.

select distinct c.country,round(sum(o.order_value)) as total_ordervalue ,
case when round(sum(o.order_value)) > 10000 then 'high'
	when  round(sum(o.order_value)) between 5000 and 10000  then 'medium' else 'low' end as sales_reach
from customers_det c left join orders o on c.customer_id = o.customer_id group by c.country;



    
-- Task 3 -  Pivot total order quantity per payment method.
select * from orders;
select  payment_method, 
sum(case when payment_method = "credit card" then quantity else 0 end) as Credit_card_qty, 
sum(case when payment_method = "Bank Transfer" then quantity else 0 end) as BankTransfer_qty,
sum(case when payment_method = "paypal" then quantity else 0 end) as paypal_qty
 from orders group by  payment_method;
 
 
 
-- Task 4 -  Find top 3 customers by total order value and Customer_id (using Rank).
select * from customers_det;

select c.customer_id, c.customer_name ,t.totalorder_value,t.rnk from customers_det c
inner join
(select customer_id, round(sum(order_value)) as totalorder_value, 
dense_rank()over(order by round(sum(order_value)) desc) as rnk from orders
group by customer_id) as t on c.customer_id = t.customer_id
 where t.rnk <=3 order by t.rnk;
 

 
 
 
 

-- task 5 Find products that have been ordered more than the average quantity.


select * from orders;
select * from products;

select  round(avg(quantity)) from orders ;

  select distinct  p.product_name,sum(o.quantity)as total_quantiy
  from products p
  left join 
  orders o on p.product_id = o.product_id group by p.product_name 
  having sum(o.quantity) > (select avg(o.quantity) from orders o);
  
  


  

  
  
-- task 6 - Get all orders for a specific customer using customer_id

delimiter //
create procedure order_count(in cust_id int)
begin
select c.customer_name, o.* from customers_det c 
left join orders o on c.customer_id = o.customer_id 
where o.customer_id = cust_id;
end // delimiter ;

call order_count(27);


-- Project Task7: Return the total spending of a customer.
delimiter //
create procedure total_spending(in cust_id int, out spending int)
begin
select sum(order_value) into spending from orders where customer_id = cust_id;
end
//delimiter ;
call total_spending(27,@spending);
select @spending as total_spend;




-- Project Task8: Automatically set loyalty points to 0 if NULL on insert.

delimiter //
create trigger loyaltypoint_check before insert on customers_det for each row
begin
if new.loyalty_points is null then set new.loyalty_points= 0;
 end if; end
// delimiter ; 
drop trigger loyaltypoint_check;

insert  into customers_det 
(customer_id, customer_name, email, gender, age , country,city, 
account_created,last_login, loyalty_points)  values
(5002,'abdul', 'abdulrahman.ms2311@gmail.com', 'male', 22, "india", 
"chennai", '2025-06-13', '2025-06-13', null);

select * from customers_det order by customer_id desc;

-- Project Task9: After a new order is inserted, deduct quantity from product stock.
-- •	Hint1 : apply triggers using after insert(Insert event)
-- •	Hint2: In the concept of triggers, when an event is inserted using an AFTER INSERT trigger, the corresponding data should be updated in the secondary table.
select * from products;
select * from orders;
create table updated_stock
(product_id int, product_name varchar(100), category varchar(100),
 brand varchar(100), unit_price int,  stock_quantity int, warehouse_id int);
insert into updated_stock select * from products;
select * from updated_stock;

delimiter //
create trigger updated_stock_count after insert on orders for each  row
begin
update updated_stock
set stock_quantity = stock_quantity - new.quantity  where product_id = new.product_id;
end // 
delimiter ;
select * from orders;

insert into orders values
(5001,2141,7,'2025-06-13','pending',5,'10%', 15.37,'paypal',131.25);
insert into orders values
(5002,2141,1,'2025-06-13','pending',10,'10%', 15.37,'paypal',131.25);

select * from orders order by order_id desc;
select *from updated_stock;















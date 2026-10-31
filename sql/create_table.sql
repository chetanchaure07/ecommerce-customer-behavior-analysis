CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    gender VARCHAR(10),
    age INTEGER,
    city VARCHAR(100),
    signup_date DATE,
    acquisition_channel VARCHAR(50),
    is_prime_member VARCHAR(3),
    state VARCHAR(100)
);


CREATE TABLE orders (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    order_date DATE,
    product_category VARCHAR(50),
    unit_price NUMERIC(10,2),
    quantity FLOAT,
    discount_pct NUMERIC(5,2),
    shipping_fee NUMERIC(10,2),
    order_total NUMERIC(12,2),
    payment_method VARCHAR(50),
    order_status VARCHAR(30),
    customer_rating NUMERIC(2,1),
    delivery_days NUMERIC(3, 0),
);
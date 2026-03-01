ALTER TABLE product
ADD COLUMN price double precision;
ALTER TABLE orders
ADD COLUMN date_created date;

ALTER TABLE product
ADD CONSTRAINT product_pkey PRIMARY KEY (id);
ALTER TABLE orders
ADD CONSTRAINT orders_pkey PRIMARY KEY (id);

ALTER TABLE order_product 
ADD CONSTRAINT fk_order_product_product 
FOREIGN KEY (product_id) REFERENCES product(id);
ALTER TABLE order_product 
ADD CONSTRAINT fk_order_product_orders 
FOREIGN KEY (order_id) REFERENCES orders(id);

DROP TABLE product_info;
DROP TABLE orders_date;

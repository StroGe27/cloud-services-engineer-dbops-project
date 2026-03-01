CREATE INDEX order_product_order_id_idx ON order_product(order_id, quantity);
CREATE INDEX orders_status_date_created_idx ON orders(status, date_created);

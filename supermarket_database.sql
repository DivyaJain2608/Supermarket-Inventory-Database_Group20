CREATE DATABASE IF NOT EXISTS supermarket_pro;
USE supermarket_pro;

CREATE TABLE category (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(60) NOT NULL,
  description VARCHAR(255),
  created_at DATETIME DEFAULT NOW()
);

CREATE TABLE brand (
  brand_id INT AUTO_INCREMENT PRIMARY KEY,
  brand_name VARCHAR(80) NOT NULL,
  country VARCHAR(40),
  created_at DATETIME DEFAULT NOW()
);

CREATE TABLE product (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(30) UNIQUE NOT NULL,
  upc VARCHAR(30),
  name VARCHAR(120) NOT NULL,
  category_id INT NOT NULL,
  brand_id INT,
  unit_of_measure VARCHAR(20),
  default_unit_price DECIMAL(10,2) NOT NULL,
  reorder_level INT DEFAULT 10,
  status ENUM('active','inactive','discontinued') DEFAULT 'active',
  hsn_code VARCHAR(20),
  created_at DATETIME DEFAULT NOW(),
  FOREIGN KEY (category_id) REFERENCES category(category_id),
  FOREIGN KEY (brand_id) REFERENCES brand(brand_id)
);

CREATE TABLE product_tax (
  product_id INT PRIMARY KEY,
  gst_rate DECIMAL(5,2) NOT NULL,
  cess DECIMAL(6,2) DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES product(product_id)
);

CREATE TABLE supplier (
  supplier_id INT AUTO_INCREMENT PRIMARY KEY,
  supplier_code VARCHAR(40) UNIQUE,
  name VARCHAR(120) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(100),
  address VARCHAR(255),
  credit_days INT DEFAULT 0,
  created_at DATETIME DEFAULT NOW()
);

CREATE TABLE supplier_product (
  id INT AUTO_INCREMENT PRIMARY KEY,
  supplier_id INT NOT NULL,
  product_id INT NOT NULL,
  supplier_sku VARCHAR(60),
  lead_time_days INT DEFAULT 7,
  min_order_qty INT DEFAULT 0,
  cost_price DECIMAL(10,2),
  UNIQUE (supplier_id, product_id),
  FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id),
  FOREIGN KEY (product_id) REFERENCES product(product_id)
);

CREATE TABLE product_batch (
  batch_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  batch_no VARCHAR(60),
  mfg_date DATE,
  expiry_date DATE,
  cost_price DECIMAL(10,2),
  created_at DATETIME DEFAULT NOW(),
  FOREIGN KEY (product_id) REFERENCES product(product_id)
);

CREATE TABLE store_location (
  store_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  address VARCHAR(255),
  city VARCHAR(60),
  pincode VARCHAR(12),
  manager_emp_id INT,
  created_at DATETIME DEFAULT NOW()
);

CREATE TABLE stock (
  product_id INT NOT NULL,
  store_id INT NOT NULL,
  batch_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  last_updated DATETIME DEFAULT NOW(),
  PRIMARY KEY (product_id, store_id, batch_id),
  FOREIGN KEY (product_id) REFERENCES product(product_id),
  FOREIGN KEY (store_id) REFERENCES store_location(store_id),
  FOREIGN KEY (batch_id) REFERENCES product_batch(batch_id)
);

CREATE TABLE stock_ledger (
  ledger_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  store_id INT NOT NULL,
  batch_id INT,
  change_qty INT NOT NULL,
  txn_type VARCHAR(40) NOT NULL,
  ref_no VARCHAR(60),
  created_by INT,
  created_at DATETIME DEFAULT NOW(),
  FOREIGN KEY (product_id) REFERENCES product(product_id),
  FOREIGN KEY (store_id) REFERENCES store_location(store_id),
  FOREIGN KEY (batch_id) REFERENCES product_batch(batch_id)
);

CREATE TABLE customer (
  cust_id INT AUTO_INCREMENT PRIMARY KEY,
  cust_code VARCHAR(40) UNIQUE,
  name VARCHAR(120) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(120),
  addr VARCHAR(255),
  created_at DATETIME DEFAULT NOW()
);

CREATE TABLE customer_loyalty (
  cust_id INT PRIMARY KEY,
  points INT DEFAULT 0,
  tier ENUM('Bronze','Silver','Gold','Platinum') DEFAULT 'Bronze',
  last_update DATETIME DEFAULT NOW(),
  FOREIGN KEY (cust_id) REFERENCES customer(cust_id)
);

CREATE TABLE role (
  role_id INT AUTO_INCREMENT PRIMARY KEY,
  role_name VARCHAR(40) NOT NULL
);

CREATE TABLE department (
  dept_id INT AUTO_INCREMENT PRIMARY KEY,
  dept_name VARCHAR(60) NOT NULL
);

CREATE TABLE employee (
  emp_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  role_id INT,
  dept_id INT,
  store_id INT,
  phone VARCHAR(20),
  email VARCHAR(120),
  created_at DATETIME DEFAULT NOW(),
  FOREIGN KEY (role_id) REFERENCES role(role_id),
  FOREIGN KEY (dept_id) REFERENCES department(dept_id),
  FOREIGN KEY (store_id) REFERENCES store_location(store_id)
);

CREATE TABLE attendance (
  attendance_id INT AUTO_INCREMENT PRIMARY KEY,
  emp_id INT NOT NULL,
  date DATE NOT NULL,
  check_in TIME,
  check_out TIME,
  FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE employee_shift (
  shift_id INT AUTO_INCREMENT PRIMARY KEY,
  emp_id INT NOT NULL,
  shift_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE sales_invoice (
  invoice_id INT AUTO_INCREMENT PRIMARY KEY,
  invoice_no VARCHAR(40) UNIQUE NOT NULL,
  cust_id INT,
  store_id INT NOT NULL,
  emp_id INT,
  invoice_date DATETIME DEFAULT NOW(),
  subtotal DECIMAL(12,2) NOT NULL,
  discount_amount DECIMAL(12,2) DEFAULT 0,
  tax_amount DECIMAL(12,2) DEFAULT 0,
  total_amount DECIMAL(12,2) NOT NULL,
  status ENUM('open','paid','cancelled','returned') DEFAULT 'open',
  created_at DATETIME DEFAULT NOW(),
  FOREIGN KEY (cust_id) REFERENCES customer(cust_id),
  FOREIGN KEY (store_id) REFERENCES store_location(store_id),
  FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE sales_invoice_item (
  invoice_id INT NOT NULL,
  product_id INT NOT NULL,
  batch_id INT NOT NULL,
  qty INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  discount DECIMAL(10,2) DEFAULT 0,
  tax DECIMAL(10,2) DEFAULT 0,
  line_total DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (invoice_id, product_id, batch_id),
  FOREIGN KEY (invoice_id) REFERENCES sales_invoice(invoice_id),
  FOREIGN KEY (product_id) REFERENCES product(product_id),
  FOREIGN KEY (batch_id) REFERENCES product_batch(batch_id)
);

CREATE TABLE payment_method (
  method_id INT AUTO_INCREMENT PRIMARY KEY,
  method_name VARCHAR(40) NOT NULL
);

CREATE TABLE payment (
  payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  invoice_id INT NOT NULL,
  method_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  paid_at DATETIME DEFAULT NOW(),
  reference VARCHAR(120),
  FOREIGN KEY (invoice_id) REFERENCES sales_invoice(invoice_id),
  FOREIGN KEY (method_id) REFERENCES payment_method(method_id)
);

CREATE TABLE return_invoice (
  return_id INT AUTO_INCREMENT PRIMARY KEY,
  original_invoice_id INT,
  store_id INT,
  emp_id INT,
  return_date DATETIME DEFAULT NOW(),
  total_amount DECIMAL(12,2) NOT NULL,
  reason VARCHAR(255),
  FOREIGN KEY (original_invoice_id) REFERENCES sales_invoice(invoice_id),
  FOREIGN KEY (store_id) REFERENCES store_location(store_id),
  FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE coupon (
  coupon_id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(40) UNIQUE NOT NULL,
  discount_percent INT NOT NULL,
  valid_from DATE,
  valid_to DATE
);

CREATE TABLE coupon_redemption (
  id INT AUTO_INCREMENT PRIMARY KEY,
  coupon_id INT NOT NULL,
  invoice_id INT NOT NULL,
  redeemed_at DATETIME DEFAULT NOW(),
  FOREIGN KEY (coupon_id) REFERENCES coupon(coupon_id),
  FOREIGN KEY (invoice_id) REFERENCES sales_invoice(invoice_id)
);

CREATE TABLE purchase_order (
  po_id INT AUTO_INCREMENT PRIMARY KEY,
  po_no VARCHAR(40) UNIQUE NOT NULL,
  supplier_id INT NOT NULL,
  order_date DATE,
  expected_delivery DATE,
  total_amount DECIMAL(12,2),
  FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
);

CREATE TABLE purchase_order_item (
  po_id INT NOT NULL,
  product_id INT NOT NULL,
  qty INT NOT NULL,
  cost_price DECIMAL(10,2),
  PRIMARY KEY (po_id, product_id),
  FOREIGN KEY (po_id) REFERENCES purchase_order(po_id),
  FOREIGN KEY (product_id) REFERENCES product(product_id)
);

CREATE TABLE grn (
  grn_id INT AUTO_INCREMENT PRIMARY KEY,
  po_id INT,
  received_date DATE,
  store_id INT,
  emp_id INT,
  total_amount DECIMAL(12,2),
  FOREIGN KEY (po_id) REFERENCES purchase_order(po_id),
  FOREIGN KEY (store_id) REFERENCES store_location(store_id),
  FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE grn_item (
  grn_id INT NOT NULL,
  product_id INT NOT NULL,
  batch_id INT NOT NULL,
  qty INT NOT NULL,
  cost_price DECIMAL(10,2),
  PRIMARY KEY (grn_id, product_id, batch_id),
  FOREIGN KEY (grn_id) REFERENCES grn(grn_id),
  FOREIGN KEY (product_id) REFERENCES product(product_id),
  FOREIGN KEY (batch_id) REFERENCES product_batch(batch_id)
);

CREATE TABLE supplier_rating (
  rating_id INT AUTO_INCREMENT PRIMARY KEY,
  supplier_id INT NOT NULL,
  rating INT NOT NULL,
  comments VARCHAR(255),
  rated_on DATE,
  FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
);

CREATE TABLE store_transfer (
  transfer_id INT AUTO_INCREMENT PRIMARY KEY,
  from_store INT NOT NULL,
  to_store INT NOT NULL,
  transfer_date DATE,
  emp_id INT,
  FOREIGN KEY (from_store) REFERENCES store_location(store_id),
  FOREIGN KEY (to_store) REFERENCES store_location(store_id),
  FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE store_transfer_item (
  transfer_id INT NOT NULL,
  product_id INT NOT NULL,
  batch_id INT NOT NULL,
  qty INT NOT NULL,
  PRIMARY KEY (transfer_id, product_id, batch_id),
  FOREIGN KEY (transfer_id) REFERENCES store_transfer(transfer_id),
  FOREIGN KEY (product_id) REFERENCES product(product_id),
  FOREIGN KEY (batch_id) REFERENCES product_batch(batch_id)
);

CREATE TABLE price_history (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  old_price DECIMAL(10,2),
  new_price DECIMAL(10,2),
  changed_at DATETIME DEFAULT NOW(),
  FOREIGN KEY (product_id) REFERENCES product(product_id)
);

INSERT INTO category (category_id, name, description, created_at) VALUES
(1,'Dairy','Milk, butter, cheese','2025-01-01 08:00:00'),
(2,'Snacks','Chips, biscuits, namkeen','2025-01-01 08:00:00'),
(3,'Beverages','Juices, cold drinks, tea, coffee','2025-01-01 08:00:00'),
(4,'Bakery','Bread, cakes, pastries','2025-01-01 08:00:00'),
(5,'Personal Care','Toiletries and personal care','2025-01-01 08:00:00'),
(6,'Household','Detergents, cleaning','2025-01-01 08:00:00');

INSERT INTO brand (brand_id, brand_name, country, created_at) VALUES
(1,'Amul','India','2025-01-01 08:00:00'),
(2,'Parle','India','2025-01-01 08:00:00'),
(3,'PepsiCo','USA','2025-01-01 08:00:00'),
(4,'Nestle','Switzerland','2025-01-01 08:00:00'),
(5,'Haldiram','India','2025-01-01 08:00:00'),
(6,'SurfExcel','India','2025-01-01 08:00:00'),
(7,'Britannia','India','2025-01-01 08:00:00'),
(8,'Dabur','India','2025-01-01 08:00:00');

INSERT INTO product (product_id, sku, upc, name, category_id, brand_id, unit_of_measure, default_unit_price, reorder_level, status, hsn_code, created_at) VALUES
(1,'AMUL-MILK-1L','890600000001','Amul Toned Milk 1L',1,1,'litre',64.00,20,'active','0401','2025-01-01 08:00:00'),
(2,'PARLE-G-200G','890106300002','Parle G Biscuits 200g',2,2,'piece',20.00,50,'active','1905','2025-01-01 08:00:00'),
(3,'LAYS-50G','890106300003','Lays Classic Salted 50g',2,3,'piece',20.00,40,'active','1905','2025-01-01 08:00:00'),
(4,'NESCAFE-100G','890106300004','Nestle Nescafe 100g',3,4,'gm',320.00,10,'active','2101','2025-01-01 08:00:00'),
(5,'TROPIC-1L','890106300005','Tropicana Orange Juice 1L',3,4,'litre',180.00,15,'active','2009','2025-01-01 08:00:00'),
(6,'HALDIM-200G','890106300006','Haldiram Bhujia 200g',2,5,'piece',95.00,30,'active','1905','2025-01-01 08:00:00'),
(7,'BRIT-BREAD-400G','890106300007','Britannia Bread 400g',4,7,'piece',35.00,25,'active','1905','2025-01-01 08:00:00'),
(8,'SURF-1KG','890106300008','Surf Excel Detergent 1kg',6,6,'kg',220.00,10,'active','3402','2025-01-01 08:00:00'),
(9,'DABUR-HONEY-250G','890106300009','Dabur Honey 250g',5,8,'gm',150.00,10,'active','1702','2025-01-01 08:00:00'),
(10,'AMUL-BUTTER-100G','890106300010','Amul Butter 100g',1,1,'gm',60.00,15,'active','0405','2025-01-01 08:00:00'),
(11,'PARLE-20G','890106300011','Parle Smile 20g',2,2,'piece',5.00,100,'active','1905','2025-01-01 08:00:00'),
(12,'COCA-330ML','890106300012','Coca-Cola 330ml',3,3,'ml',45.00,50,'active','2202','2025-01-01 08:00:00'),
(13,'MAGGI-2MIN-70G','890106300013','Maggi Masala 70g',2,4,'piece',12.00,80,'active','1902','2025-01-01 08:00:00'),
(14,'AMUL-CURD-400G','890106300014','Amul Curd 400g',1,1,'gm',40.00,25,'active','0403','2025-01-01 08:00:00'),
(15,'NIVEA-200ML','890106300015','Nivea Body Lotion 200ml',5,NULL,'ml',299.00,5,'active','3304','2025-01-01 08:00:00'),
(16,'TIDE-1KG','890106300016','Tide Detergent 1kg',6,3,'kg',240.00,10,'active','3402','2025-01-01 08:00:00'),
(17,'PEPSI-500ML','890106300017','Pepsi 500ml',3,3,'ml',50.00,40,'active','2202','2025-01-01 08:00:00'),
(18,'COOKIE-150G','890106300018','Butter Cookies 150g',2,7,'piece',45.00,30,'active','1905','2025-01-01 08:00:00'),
(19,'PEN-1PC','890106300019','Ball Pen Pack',5,NULL,'piece',10.00,100,'active','9608','2025-01-01 08:00:00'),
(20,'CHOC-100G','890106300020','Dairy Milk Chocolate 100g',2,4,'gm',120.00,25,'active','1806','2025-01-01 08:00:00'),
(21,'AMUL-CHED-200G','890106300021','Amul Cheese 200g',1,1,'gm',140.00,10,'active','0406','2025-01-01 08:00:00'),
(22,'PARLE-RUSK-200G','890106300022','Parle Rusk 200g',2,2,'piece',30.00,40,'active','1905','2025-01-01 08:00:00'),
(23,'MILK-500ML','890106300023','Amul Toned Milk 500ml',1,1,'ml',35.00,30,'active','0401','2025-01-01 08:00:00'),
(24,'TOOTHPASTE-200G','890106300024','Colgate Toothpaste 200g',5,NULL,'gm',85.00,20,'active','3306','2025-01-01 08:00:00'),
(25,'ENERGY-DRINK-250ML','890106300025','EnergyUp 250ml',3,NULL,'ml',90.00,20,'active','2202','2025-01-01 08:00:00'),
(26,'BISCUIT-150G','890106300026','Marie Gold 150g',2,7,'piece',25.00,50,'active','1905','2025-01-01 08:00:00'),
(27,'OLIVE-OIL-500ML','890106300027','Olive Oil 500ml',5,NULL,'ml',420.00,5,'active','1509','2025-01-01 08:00:00'),
(28,'SALT-1KG','890106300028','Table Salt 1kg',5,NULL,'kg',25.00,40,'active','2501','2025-01-01 08:00:00'),
(29,'SUGAR-1KG','890106300029','Sugar 1kg',5,NULL,'kg',45.00,40,'active','1701','2025-01-01 08:00:00'),
(30,'RICE-5KG','890106300030','Basmati Rice 5kg',5,NULL,'kg',420.00,8,'active','1006','2025-01-01 08:00:00'),
(31,'TOFU-200G','890106300031','Tofu 200g',1,NULL,'gm',80.00,10,'active','0402','2025-01-01 08:00:00'),
(32,'SAMOSA-1PC','890106300032','Fresh Samosa 1pc',4,NULL,'piece',15.00,50,'active','2106','2025-01-01 08:00:00'),
(33,'WATER-1.5L','890106300033','Mineral Water 1.5L',3,NULL,'litre',25.00,100,'active','2201','2025-01-01 08:00:00'),
(34,'ICE-CREAM-500ML','890106300034','Vanilla Ice Cream 500ml',4,1,'ml',240.00,10,'active','2105','2025-01-01 08:00:00'),
(35,'FLOUR-1KG','890106300035','Wheat Flour 1kg',5,NULL,'kg',60.00,30,'active','1101','2025-01-01 08:00:00'),
(36,'CORN-FLAKES-250G','890106300036','Corn Flakes 250g',2,7,'piece',150.00,15,'active','1904','2025-01-01 08:00:00'),
(37,'SWEETS-250G','890106300037','Mithai Pack 250g',4,NULL,'piece',180.00,20,'active','2106','2025-01-01 08:00:00'),
(38,'GREEN-TEA-25T','890106300038','Green Tea 25 Tea Bags',3,NULL,'piece',180.00,10,'active','2101','2025-01-01 08:00:00'),
(39,'YOGURT-200G','890106300039','Greek Yogurt 200g',1,1,'gm',90.00,15,'active','0403','2025-01-01 08:00:00'),
(40,'BISCUIT-200G','890106300040','Chocolate Chip Cookies 200g',2,NULL,'piece',80.00,30,'active','1905','2025-01-01 08:00:00');

INSERT INTO product_tax (product_id, gst_rate, cess) VALUES
(1,5.00,0.00),(2,12.00,0.00),(3,12.00,0.00),(4,18.00,0.00),(5,12.00,0.00),
(6,12.00,0.00),(7,12.00,0.00),(8,18.00,0.00),(9,5.00,0.00),(10,5.00,0.00),
(11,12.00,0.00),(12,28.00,0.00),(13,12.00,0.00),(14,5.00,0.00),(15,18.00,0.00),
(16,18.00,0.00),(17,28.00,0.00),(18,12.00,0.00),(19,18.00,0.00),(20,18.00,0.00),
(21,5.00,0.00),(22,12.00,0.00),(23,5.00,0.00),(24,18.00,0.00),(25,28.00,0.00),
(26,12.00,0.00),(27,18.00,0.00),(28,5.00,0.00),(29,5.00,0.00),(30,5.00,0.00),
(31,5.00,0.00),(32,5.00,0.00),(33,12.00,0.00),(34,18.00,0.00),(35,5.00,0.00),
(36,12.00,0.00),(37,5.00,0.00),(38,12.00,0.00),(39,5.00,0.00),(40,12.00,0.00);

INSERT INTO supplier (supplier_id, supplier_code, name, phone, email, address, credit_days, created_at) VALUES
(1,'AMUL-DL','Amul Distributors Delhi','9876543210','amul.delhi@example.com','Okhla Industrial Area, New Delhi',30,'2025-01-02 09:00:00'),
(2,'PARLE-NO','Parle Distributors','9988776655','parle.supply@example.com','Noida Sector 62',30,'2025-01-02 09:00:00'),
(3,'PEPSI-WH','PepsiCo Wholesale','9090909090','pepsico@example.com','Gurugram',45,'2025-01-02 09:00:00'),
(4,'NESTLE-NR','Nestle India','9012345678','nestle@example.com','Faridabad',30,'2025-01-02 09:00:00'),
(5,'GEN-BEV','Generic Beverages','9023456789','bev@example.com','Gurugram',15,'2025-01-02 09:00:00'),
(6,'GEN-HH','Household Supplies','9034567890','household@example.com','Ghaziabad',15,'2025-01-02 09:00:00');

INSERT INTO supplier_product 
(id, supplier_id, product_id, supplier_sku, lead_time_days, min_order_qty, cost_price)
VALUES
(1, 1, 1, 'AMUL-1L', 5, 25, 55.00),
(2, 1, 10, 'AMUL-BUTTER-100', 5, 20, 50.00),
(3, 1, 14, 'AMUL-CURD-400', 5, 15, 32.00),
(4, 1, 21, 'AMUL-CHEESE-200', 6, 10, 110.00),
(5, 1, 23, 'AMUL-MILK-500', 4, 30, 28.00),

(6, 2, 2, 'PARLE-G-200', 7, 40, 16.00),
(7, 2, 11, 'PARLE-20G', 6, 100, 4.00),
(8, 2, 18, 'COOKIES-150', 6, 50, 32.00),
(9, 2, 22, 'PARLE-RUSK-200', 7, 30, 25.00),
(10, 2, 26, 'MARIE-GOLD-150', 7, 40, 20.00),

(11, 3, 12, 'COCA-330ML', 4, 50, 32.00),
(12, 3, 17, 'PEPSI-500ML', 4, 60, 35.00),
(13, 3, 25, 'ENERGY-DRINK-250', 5, 40, 65.00),
(14, 3, 33, 'WATER-1.5L', 3, 100, 15.00),
(15, 3, 38, 'GREEN-TEA-25T', 7, 20, 140.00),

(16, 4, 4, 'NESCAFE-100G', 6, 20, 260.00),
(17, 4, 5, 'TROPIC-1L', 5, 20, 140.00),
(18, 4, 13, 'MAGGI-70G', 6, 100, 9.00),
(19, 4, 20, 'DAIRY-MILK-100', 7, 25, 95.00),
(20, 4, 34, 'ICECREAM-500', 6, 12, 180.00),

(21, 5, 9, 'DABUR-HONEY-250', 7, 15, 120.00),
(22, 5, 15, 'NIVEA-200ML', 10, 10, 240.00),
(23, 5, 24, 'COLGATE-200G', 7, 20, 70.00),
(24, 5, 27, 'OLIVE-OIL-500', 10, 12, 350.00),
(25, 5, 31, 'TOFU-200G', 10, 10, 65.00),

(26, 6, 8, 'SURF-EXCEL-1KG', 7, 10, 180.00),
(27, 6, 16, 'TIDE-1KG', 7, 15, 190.00),
(28, 6, 28, 'SALT-1KG', 5, 30, 15.00),
(29, 6, 29, 'SUGAR-1KG', 5, 30, 30.00),
(30, 6, 35, 'FLOUR-1KG', 5, 25, 40.00);

INSERT INTO product_batch (batch_id, product_id, batch_no, mfg_date, expiry_date, cost_price, created_at) VALUES
(1,1,'B2025001','2025-01-01','2025-06-30',50.00,'2025-01-01 09:00:00'),
(2,10,'B2025002','2025-01-05','2025-07-05',45.00,'2025-01-05 09:00:00'),
(3,14,'B2025003','2025-01-03','2025-03-03',30.00,'2025-01-03 09:00:00'),
(4,21,'B2025004','2025-01-02','2025-12-31',110.00,'2025-01-02 09:00:00'),
(5,2,'B2025005','2025-01-01','2026-01-01',12.00,'2025-01-01 09:00:00'),
(6,3,'B2025006','2025-01-04','2026-01-04',12.00,'2025-01-04 09:00:00'),
(7,12,'B2025007','2024-12-15','2026-12-15',30.00,'2024-12-15 09:00:00'),
(8,4,'B2025008','2024-11-01','2026-11-01',240.00,'2024-11-01 09:00:00'),
(9,5,'B2025009','2024-12-20','2026-06-20',140.00,'2024-12-20 09:00:00'),
(10,6,'B2025010','2025-01-06','2026-01-06',70.00,'2025-01-06 09:00:00'),
(11,7,'B2025011','2025-01-07','2025-02-07',25.00,'2025-01-07 09:00:00'),
(12,8,'B2025012','2024-10-01','2026-10-01',160.00,'2024-10-01 09:00:00'),
(13,9,'B2025013','2024-12-01','2026-12-01',110.00,'2024-12-01 09:00:00'),
(14,11,'B2025014','2025-01-10','2026-01-10',3.00,'2025-01-10 09:00:00'),
(15,13,'B2025015','2024-12-20','2026-12-20',8.00,'2024-12-20 09:00:00'),
(16,15,'B2025016','2024-11-15','2026-11-15',220.00,'2024-11-15 09:00:00'),
(17,16,'B2025017','2024-10-30','2026-10-30',170.00,'2024-10-30 09:00:00'),
(18,17,'B2025018','2024-12-01','2026-12-01',35.00,'2024-12-01 09:00:00'),
(19,18,'B2025019','2025-01-12','2026-01-12',15.00,'2025-01-12 09:00:00'),
(20,20,'B2025020','2024-12-05','2026-12-05',85.00,'2024-12-05 09:00:00'),
(21,23,'B2025021','2025-01-01','2025-08-01',28.00,'2025-01-01 09:00:00'),
(22,24,'B2025022','2025-01-15','2027-01-15',60.00,'2025-01-15 09:00:00'),
(23,25,'B2025023','2025-01-05','2026-06-05',65.00,'2025-01-05 09:00:00'),
(24,26,'B2025024','2025-01-02','2026-01-02',15.00,'2025-01-02 09:00:00'),
(25,27,'B2025025','2024-10-01','2027-10-01',320.00,'2024-10-01 09:00:00'),
(26,28,'B2025026','2025-01-01','2027-01-01',20.00,'2025-01-01 09:00:00'),
(27,29,'B2025027','2025-01-01','2027-01-01',35.00,'2025-01-01 09:00:00'),
(28,30,'B2025028','2024-09-01','2027-09-01',350.00,'2024-09-01 09:00:00'),
(29,33,'B2025029','2025-01-03','2026-01-03',10.00,'2025-01-03 09:00:00'),
(30,36,'B2025030','2024-12-10','2026-12-10',110.00,'2024-12-10 09:00:00');

INSERT INTO store_location (store_id, name, address, city, pincode, manager_emp_id, created_at) VALUES
(1,'Central Store','Connaught Place, New Delhi','New Delhi','110001',NULL,'2025-01-01 09:00:00'),
(2,'Mall Outlet','DLF Cyber City, Gurugram','Gurugram','122002',NULL,'2025-01-01 09:00:00'),
(3,'Residential Store','Sector 62, Noida','Noida','201301',NULL,'2025-01-01 09:00:00');

INSERT INTO role (role_id, role_name) VALUES
(1,'Manager'),(2,'Cashier'),(3,'Inventory Executive'),(4,'Supervisor');

INSERT INTO department (dept_id, dept_name) VALUES
(1,'Sales'),(2,'Inventory'),(3,'HR'),(4,'Accounts');

INSERT INTO employee (emp_id, name, role_id, dept_id, store_id, phone, email, created_at) VALUES
(1,'Anil Kumar',1,1,1,'9871112222','anil.kumar@example.com','2025-01-02 09:00:00'),
(2,'Sujata Verma',2,1,1,'9873214444','sujata.verma@example.com','2025-01-02 09:00:00'),
(3,'Rahul Singh',3,2,2,'9875556666','rahul.singh@example.com','2025-01-02 09:00:00'),
(4,'Priya Nair',2,1,3,'9877778888','priya.nair@example.com','2025-01-02 09:00:00'),
(5,'Rahul Mehta',4,1,2,'9881112222','rahul.mehta@example.com','2025-01-02 09:00:00'),
(6,'Sunita Rao',3,2,1,'9883334444','sunita.rao@example.com','2025-01-02 09:00:00'),
(7,'Vikram Patel',2,1,2,'9885556666','vikram.patel@example.com','2025-01-02 09:00:00'),
(8,'Neha Gupta',2,1,3,'9887778888','neha.gupta@example.com','2025-01-02 09:00:00'),
(9,'Asha Menon',3,2,1,'9889990000','asha.menon@example.com','2025-01-02 09:00:00'),
(10,'Karan Joshi',2,1,1,'9891112223','karan.joshi@example.com','2025-01-02 09:00:00'),
(11,'Meera Iyer',4,4,3,'9893334445','meera.iyer@example.com','2025-01-02 09:00:00'),
(12,'Sandeep Rao',3,2,2,'9895556667','sandeep.rao@example.com','2025-01-02 09:00:00');

INSERT INTO customer (cust_id, cust_code, name, phone, email, addr, created_at) VALUES
(1,'CUST001','Aman Sharma','9876500011','aman@example.com','Delhi','2025-01-03 10:00:00'),
(2,'CUST002','Riya Gupta','9987700022','riya@example.com','Gurugram','2025-01-03 10:15:00'),
(3,'CUST003','Karan Mehta','9090909091','karan@example.com','Noida','2025-01-03 10:30:00'),
(4,'CUST004','Pooja Singh','9012340004','pooja@example.com','Delhi','2025-01-03 11:00:00'),
(5,'CUST005','Rajat Verma','9023450005','rajat@example.com','Gurugram','2025-01-03 11:30:00'),
(6,'CUST006','Simran Kaur','9034560006','simran@example.com','Noida','2025-01-03 12:00:00'),
(7,'CUST007','Aditya Rao','9045670007','aditya@example.com','Delhi','2025-01-03 12:30:00'),
(8,'CUST008','Neetu Malik','9056780008','neetu@example.com','Gurugram','2025-01-03 13:00:00'),
(9,'CUST009','Vivek Sharma','9067890009','vivek@example.com','Noida','2025-01-03 13:30:00'),
(10,'CUST010','Shweta Jain','9078900010','shweta@example.com','Delhi','2025-01-03 14:00:00'),
(11,'CUST011','Manish Desai','9089010011','manish@example.com','Gurugram','2025-01-03 14:30:00'),
(12,'CUST012','Tina Thomas','9090120012','tina@example.com','Noida','2025-01-03 15:00:00'),
(13,'CUST013','Rohit Sharma','9101230013','rohit@example.com','Delhi','2025-01-03 15:30:00'),
(14,'CUST014','Alka Verma','9112340014','alka@example.com','Gurugram','2025-01-03 16:00:00'),
(15,'CUST015','Gaurav Patel','9123450015','gaurav@example.com','Noida','2025-01-03 16:30:00'),
(16,'CUST016','Sonia Kapoor','9134560016','sonia@example.com','Delhi','2025-01-03 17:00:00'),
(17,'CUST017','Mohan Lal','9145670017','mohan@example.com','Gurugram','2025-01-03 17:30:00'),
(18,'CUST018','Ritu Bala','9156780018','ritu@example.com','Noida','2025-01-03 18:00:00'),
(19,'CUST019','Deepak Nair','9167890019','deepak@example.com','Delhi','2025-01-03 18:30:00'),
(20,'CUST020','Kavita Joshi','9178900020','kavita@example.com','Gurugram','2025-01-03 19:00:00');

INSERT INTO customer_loyalty (cust_id, points, tier, last_update) VALUES
(1,120,'Silver','2025-02-01 10:00:00'),
(2,50,'Bronze','2025-02-01 10:00:00'),
(3,300,'Gold','2025-02-01 10:00:00'),
(4,10,'Bronze','2025-02-01 10:00:00'),
(5,80,'Bronze','2025-02-01 10:00:00'),
(6,0,'Bronze','2025-02-01 10:00:00'),
(7,200,'Gold','2025-02-01 10:00:00'),
(8,30,'Bronze','2025-02-01 10:00:00'),
(9,60,'Bronze','2025-02-01 10:00:00'),
(10,90,'Silver','2025-02-01 10:00:00'),
(11,15,'Bronze','2025-02-01 10:00:00'),
(12,45,'Bronze','2025-02-01 10:00:00'),
(13,250,'Gold','2025-02-01 10:00:00'),
(14,5,'Bronze','2025-02-01 10:00:00'),
(15,70,'Bronze','2025-02-01 10:00:00');

INSERT INTO stock (product_id, store_id, batch_id, quantity, last_updated) VALUES
(1,1,1,150,'2025-02-01 09:00:00'),
(1,2,1,90,'2025-02-01 09:00:00'),
(1,3,1,120,'2025-02-01 09:00:00'),
(2,1,5,400,'2025-02-02 09:00:00'),
(2,2,5,250,'2025-02-02 09:00:00'),
(2,3,5,300,'2025-02-02 09:00:00'),
(3,1,6,350,'2025-02-02 09:00:00'),
(3,2,6,180,'2025-02-02 09:00:00'),
(3,3,6,200,'2025-02-02 09:00:00'),
(4,1,8,60,'2025-02-03 09:00:00'),
(4,2,8,40,'2025-02-03 09:00:00'),
(4,3,8,55,'2025-02-03 09:00:00'),
(5,1,9,80,'2025-02-03 09:00:00'),
(5,2,9,60,'2025-02-03 09:00:00'),
(6,1,10,180,'2025-02-04 09:00:00'),
(6,2,10,120,'2025-02-04 09:00:00'),
(7,1,11,90,'2025-02-04 09:00:00'),
(8,1,12,50,'2025-02-04 09:00:00'),
(9,1,13,40,'2025-02-04 09:00:00'),
(10,1,2,60,'2025-02-05 09:00:00'),
(11,1,14,800,'2025-02-05 09:00:00'),
(12,1,7,300,'2025-02-05 09:00:00'),
(13,1,15,220,'2025-02-05 09:00:00'),
(14,1,3,150,'2025-02-05 09:00:00'),
(15,3,16,40,'2025-02-06 09:00:00'),
(16,2,17,60,'2025-02-06 09:00:00'),
(17,2,18,200,'2025-02-06 09:00:00'),
(18,1,19,120,'2025-02-06 09:00:00'),
(20,1,20,70,'2025-02-06 09:00:00'),
(21,1,4,50,'2025-02-06 09:00:00'),
(22,1,24,200,'2025-02-07 09:00:00'),
(23,2,21,180,'2025-02-07 09:00:00'),
(24,1,22,90,'2025-02-07 09:00:00'),
(25,1,23,60,'2025-02-07 09:00:00'),
(26,1,24,120,'2025-02-07 09:00:00'),
(27,1,25,30,'2025-02-08 09:00:00'),
(28,1,26,200,'2025-02-08 09:00:00'),
(29,1,27,250,'2025-02-08 09:00:00'),
(30,2,30,80,'2025-02-08 09:00:00');

INSERT INTO stock_ledger (ledger_id, product_id, store_id, batch_id, change_qty, txn_type, ref_no, created_by, created_at) VALUES
(1,1,1,1,150,'initial_stock','INIT1',3,'2025-01-05 09:00:00'),
(2,1,2,1,90,'initial_stock','INIT2',3,'2025-01-05 09:00:00'),
(3,1,3,1,120,'initial_stock','INIT3',3,'2025-01-05 09:00:00'),
(4,2,1,5,400,'initial_stock','INIT4',3,'2025-01-06 09:00:00'),
(5,3,1,6,350,'initial_stock','INIT5',3,'2025-01-06 09:00:00'),
(6,4,1,8,60,'initial_stock','INIT6',3,'2025-01-07 09:00:00'),
(7,12,1,7,300,'initial_stock','INIT7',3,'2025-01-08 09:00:00'),
(8,10,1,2,60,'initial_stock','INIT8',3,'2025-01-08 09:00:00'),
(9,11,1,14,800,'initial_stock','INIT9',3,'2025-01-08 09:00:00'),
(10,21,1,4,50,'initial_stock','INIT10',3,'2025-01-09 09:00:00'),
(11,24,1,22,90,'initial_stock','INIT11',3,'2025-01-09 09:00:00'),
(12,30,2,30,80,'initial_stock','INIT12',3,'2025-01-09 09:00:00'),
(13,3,2,6,180,'initial_stock','INIT13',3,'2025-01-09 09:00:00'),
(14,6,1,10,180,'initial_stock','INIT14',3,'2025-01-09 09:00:00'),
(15,8,1,12,50,'initial_stock','INIT15',3,'2025-01-10 09:00:00'),
(16,9,1,13,40,'initial_stock','INIT16',3,'2025-01-10 09:00:00'),
(17,2,3,5,300,'purchase','PO1001',1,'2025-01-12 09:00:00'),
(18,2,1,5,-100,'sale','INV1001',2,'2025-01-12 10:00:00'),
(19,3,1,6,-2,'sale','INV1002',2,'2025-01-12 10:05:00'),
(20,4,1,8,-1,'sale','INV1003',2,'2025-01-12 10:10:00');

INSERT INTO purchase_order (po_id, po_no, supplier_id, order_date, expected_delivery, total_amount) VALUES
(1001,'PO1001',2,'2025-01-10','2025-01-15',7200.00),
(1002,'PO1002',1,'2025-01-11','2025-01-16',6000.00),
(1003,'PO1003',3,'2025-01-12','2025-01-17',4500.00),
(1004,'PO1004',4,'2025-01-15','2025-01-20',9600.00),
(1005,'PO1005',5,'2025-01-18','2025-01-23',4200.00),
(1006,'PO1006',6,'2025-01-20','2025-01-25',3200.00),
(1007,'PO1007',2,'2025-01-22','2025-01-27',5400.00),
(1008,'PO1008',1,'2025-01-24','2025-01-29',2800.00),
(1009,'PO1009',3,'2025-01-25','2025-01-30',6300.00),
(1010,'PO1010',4,'2025-01-26','2025-02-01',1500.00);

INSERT INTO purchase_order_item (po_id, product_id, qty, cost_price) VALUES
(1001,2,300,12.00),
(1001,3,150,12.00),
(1002,1,200,50.00),
(1002,21,100,110.00),
(1003,12,200,30.00),
(1004,4,40,240.00),
(1005,5,100,140.00),
(1006,8,20,160.00),
(1007,11,500,3.00),
(1008,10,100,45.00),
(1009,17,200,35.00),
(1010,13,150,8.00),
(1004,20,20,85.00),
(1001,22,100,18.00),
(1005,25,60,65.00),
(1003,36,50,110.00),
(1007,26,200,15.00),
(1002,23,150,28.00),
(1008,14,120,30.00),
(1009,33,300,10.00),
(1001,6,200,70.00),
(1006,16,40,170.00),
(1005,27,10,320.00),
(1009,12,100,30.00),
(1010,15,5,220.00);

INSERT INTO grn (grn_id, po_id, received_date, store_id, emp_id, total_amount) VALUES
(2001,1001,'2025-01-15',1,3,7200.00),
(2002,1002,'2025-01-16',1,6,6000.00),
(2003,1003,'2025-01-17',2,3,4500.00),
(2004,1004,'2025-01-20',1,3,9600.00),
(2005,1005,'2025-01-23',2,3,4200.00),
(2006,1006,'2025-01-25',1,6,3200.00),
(2007,1007,'2025-01-27',3,9,5400.00),
(2008,1008,'2025-01-29',1,6,2800.00);

INSERT INTO grn_item (grn_id, product_id, batch_id, qty, cost_price) VALUES
(2001,2,5,300,12.00),
(2001,3,6,150,12.00),
(2002,1,1,200,50.00),
(2002,21,4,100,110.00),
(2003,12,7,200,30.00),
(2004,4,8,40,240.00),
(2005,5,9,100,140.00),
(2006,8,12,20,160.00),
(2007,11,14,500,3.00),
(2008,10,2,100,45.00),
(2004,20,20,20,85.00),
(2005,25,23,60,65.00),
(2003,36,30,50,110.00),
(2001,22,24,100,18.00),
(2006,16,17,40,170.00),
(2002,23,21,150,28.00),
(2008,14,3,120,30.00),
(2007,26,24,200,15.00);

INSERT INTO supplier_rating (rating_id, supplier_id, rating, comments, rated_on) VALUES
(1,1,5,'Prompt delivery','2025-02-01'),
(2,2,4,'Good rates','2025-02-02'),
(3,3,4,'Occasional delay','2025-02-03'),
(4,4,5,'Consistent quality','2025-02-04'),
(5,5,3,'Packaging issues','2025-02-05'),
(6,6,4,'Competitive pricing','2025-02-06'),
(7,1,5,'Excellent support','2025-02-07'),
(8,2,4,'Reliable','2025-02-08');

INSERT INTO sales_invoice (invoice_id, invoice_no, cust_id, store_id, emp_id, invoice_date, subtotal, discount_amount, tax_amount, total_amount, status, created_at) VALUES
(10001,'INV10001',1,1,2,'2025-02-10 10:00:00',84.00,0.00,0.00,84.00,'paid','2025-02-10 10:05:00'),
(10002,'INV10002',2,2,7,'2025-02-10 10:15:00',40.00,0.00,0.00,40.00,'paid','2025-02-10 10:20:00'),
(10003,'INV10003',3,3,4,'2025-02-10 10:30:00',340.00,0.00,0.00,340.00,'paid','2025-02-10 10:35:00'),
(10004,'INV10004',4,1,2,'2025-02-11 11:00:00',150.00,10.00,6.30,146.30,'paid','2025-02-11 11:10:00'),
(10005,'INV10005',5,2,7,'2025-02-11 11:30:00',220.00,0.00,39.60,259.60,'paid','2025-02-11 11:40:00'),
(10006,'INV10006',6,1,2,'2025-02-12 12:00:00',55.00,0.00,6.60,61.60,'paid','2025-02-12 12:05:00'),
(10007,'INV10007',7,1,1,'2025-02-12 12:30:00',420.00,20.00,71.00,471.00,'paid','2025-02-12 12:45:00'),
(10008,'INV10008',8,2,7,'2025-02-13 13:00:00',35.00,0.00,4.20,39.20,'paid','2025-02-13 13:10:00'),
(10009,'INV10009',9,3,4,'2025-02-13 13:30:00',120.00,0.00,21.60,141.60,'paid','2025-02-13 13:40:00'),
(10010,'INV10010',10,1,2,'2025-02-14 14:00:00',180.00,0.00,21.60,201.60,'paid','2025-02-14 14:10:00'),
(10011,'INV10011',11,2,7,'2025-02-14 14:30:00',50.00,0.00,9.00,59.00,'paid','2025-02-14 14:35:00'),
(10012,'INV10012',12,3,4,'2025-02-15 15:00:00',310.00,15.00,52.50,347.50,'paid','2025-02-15 15:10:00'),
(10013,'INV10013',13,1,1,'2025-02-15 15:30:00',95.00,0.00,17.10,112.10,'paid','2025-02-15 15:40:00'),
(10014,'INV10014',14,2,7,'2025-02-16 16:00:00',65.00,0.00,11.70,76.70,'paid','2025-02-16 16:10:00'),
(10015,'INV10015',15,1,2,'2025-02-16 16:30:00',299.00,0.00,53.82,352.82,'paid','2025-02-16 16:40:00'),
(10016,'INV10016',16,2,7,'2025-02-17 17:00:00',240.00,0.00,43.20,283.20,'paid','2025-02-17 17:10:00'),
(10017,'INV10017',17,1,1,'2025-02-17 17:30:00',90.00,0.00,25.20,115.20,'paid','2025-02-17 17:40:00'),
(10018,'INV10018',18,3,4,'2025-02-18 18:00:00',180.00,0.00,21.60,201.60,'paid','2025-02-18 18:10:00'),
(10019,'INV10019',19,1,2,'2025-02-19 19:00:00',45.00,0.00,2.25,47.25,'paid','2025-02-19 19:05:00'),
(10020,'INV10020',20,2,7,'2025-02-20 20:00:00',120.00,0.00,21.60,141.60,'paid','2025-02-20 20:10:00'),
(10021,'INV10021',1,1,2,'2025-02-21 10:00:00',150.00,0.00,7.50,157.50,'paid','2025-02-21 10:10:00'),
(10022,'INV10022',4,1,2,'2025-02-21 11:00:00',60.00,0.00,3.00,63.00,'paid','2025-02-21 11:10:00'),
(10023,'INV10023',7,2,7,'2025-02-22 12:00:00',90.00,0.00,4.50,94.50,'paid','2025-02-22 12:10:00'),
(10024,'INV10024',10,1,2,'2025-02-22 13:00:00',200.00,0.00,10.00,210.00,'paid','2025-02-22 13:10:00'),
(10025,'INV10025',12,3,4,'2025-02-23 14:00:00',75.00,0.00,13.50,88.50,'paid','2025-02-23 14:10:00'),
(10026,'INV10026',14,2,7,'2025-02-23 15:00:00',45.00,0.00,2.25,47.25,'paid','2025-02-23 15:10:00'),
(10027,'INV10027',3,1,2,'2025-02-24 16:00:00',220.00,0.00,39.60,259.60,'paid','2025-02-24 16:10:00'),
(10028,'INV10028',5,2,7,'2025-02-25 17:00:00',110.00,0.00,19.80,129.80,'paid','2025-02-25 17:10:00'),
(10029,'INV10029',6,1,1,'2025-02-25 18:00:00',360.00,50.00,58.80,368.80,'paid','2025-02-25 18:10:00'),
(10030,'INV10030',8,1,3,'2025-02-26 19:00:00',220.00,0.00,39.60,259.60,'paid','2025-02-26 19:10:00');

INSERT INTO sales_invoice_item (invoice_id, product_id, batch_id, qty, unit_price, discount, tax, line_total) VALUES
(10001,1,1,1,64.00,0.00,3.20,67.20),
(10001,2,5,1,20.00,0.00,2.40,22.40),
(10002,3,6,2,20.00,0.00,4.80,44.80),
(10003,4,8,1,320.00,0.00,57.60,377.60),
(10004,20,20,1,120.00,10.00,18.00,128.00),
(10004,11,14,2,5.00,0.00,1.20,11.20),
(10005,8,12,1,220.00,0.00,39.60,259.60),
(10006,2,5,1,20.00,0.00,2.40,22.40),
(10007,30,28,1,420.00,20.00,72.00,472.00),
(10008,7,11,1,35.00,0.00,6.30,41.30),
(10009,20,20,1,120.00,0.00,21.60,141.60),
(10010,5,9,1,180.00,0.00,21.60,201.60),
(10011,11,14,5,5.00,0.00,4.50,29.50),
(10012,4,8,1,320.00,15.00,46.05,351.05),
(10012,13,15,2,12.00,0.00,4.80,28.80),
(10013,26,24,2,25.00,0.00,6.00,56.00),
(10014,23,21,1,35.00,0.00,6.30,41.30),
(10015,15,16,1,299.00,0.00,53.82,352.82),
(10016,16,17,1,240.00,0.00,43.20,283.20),
(10017,25,23,1,90.00,0.00,25.20,115.20),
(10018,37,30,1,180.00,0.00,9.00,189.00),
(10019,11,14,1,5.00,0.00,0.60,5.60),
(10020,20,20,1,120.00,0.00,21.60,141.60),
(10021,1,1,2,64.00,0.00,6.40,134.40),
(10022,10,2,1,60.00,0.00,3.00,63.00),
(10023,7,11,3,35.00,0.00,5.25,110.25),
(10024,21,4,1,140.00,0.00,7.00,147.00),
(10025,12,7,1,45.00,0.00,8.10,53.10),
(10026,14,3,1,40.00,0.00,2.00,42.00),
(10027,3,6,4,20.00,0.00,9.60,89.60),
(10028,5,9,1,180.00,0.00,19.80,199.80),
(10029,8,12,2,220.00,25.00,39.60,437.60),
(10030,36,30,1,150.00,0.00,27.00,177.00);

INSERT INTO payment_method (method_id, method_name) VALUES
(1,'Cash'),(2,'Card'),(3,'UPI'),(4,'Wallet');

INSERT INTO payment (payment_id, invoice_id, method_id, amount, paid_at, reference) VALUES
(50001,10001,1,84.00,'2025-02-10 10:06:00','CASH1001'),
(50002,10002,3,40.00,'2025-02-10 10:21:00','UPI2001'),
(50003,10003,2,340.00,'2025-02-10 10:36:00','CARD3001'),
(50004,10004,3,146.30,'2025-02-11 11:11:00','UPI4001'),
(50005,10005,2,259.60,'2025-02-11 11:41:00','CARD5001'),
(50006,10006,1,61.60,'2025-02-12 12:06:00','CASH6001'),
(50007,10007,2,471.00,'2025-02-12 12:46:00','CARD7001'),
(50008,10008,1,39.20,'2025-02-13 13:11:00','CASH8001'),
(50009,10009,4,141.60,'2025-02-13 13:41:00','WALLET9001'),
(50010,10010,3,201.60,'2025-02-14 14:11:00','UPI10010'),
(50011,10011,1,59.00,'2025-02-14 14:36:00','CASH11011'),
(50012,10012,2,347.50,'2025-02-15 15:11:00','CARD12012'),
(50013,10013,1,112.10,'2025-02-15 15:41:00','CASH13013'),
(50014,10014,3,76.70,'2025-02-16 16:11:00','UPI14014'),
(50015,10015,2,352.82,'2025-02-16 16:41:00','CARD15015'),
(50016,10016,4,283.20,'2025-02-17 17:11:00','WALLET16016'),
(50017,10017,1,115.20,'2025-02-17 17:41:00','CASH17017'),
(50018,10018,2,201.60,'2025-02-18 18:11:00','CARD18018'),
(50019,10019,3,47.25,'2025-02-19 19:06:00','UPI19019'),
(50020,10020,1,141.60,'2025-02-20 20:11:00','CASH20020'),
(50021,10021,2,157.50,'2025-02-21 10:11:00','CARD21021'),
(50022,10022,1,63.00,'2025-02-21 11:11:00','CASH22022'),
(50023,10023,3,94.50,'2025-02-22 12:11:00','UPI23023'),
(50024,10024,2,210.00,'2025-02-22 13:11:00','CARD24024'),
(50025,10025,4,88.50,'2025-02-23 14:11:00','WALLET25025'),
(50026,10026,1,47.25,'2025-02-23 15:11:00','CASH26026'),
(50027,10027,2,259.60,'2025-02-24 16:11:00','CARD27027'),
(50028,10028,3,129.80,'2025-02-25 17:11:00','UPI28028'),
(50029,10029,2,368.80,'2025-02-25 18:11:00','CARD29029'),
(50030,10030,1,259.60,'2025-02-26 19:11:00','CASH30030');

INSERT INTO coupon (coupon_id, code, discount_percent, valid_from, valid_to) VALUES
(1,'WELCOME10',10,'2025-01-01','2025-12-31'),
(2,'SNACKS5',5,'2025-02-01','2025-03-31'),
(3,'FESTIVE20',20,'2025-10-01','2025-11-15'),
(4,'LOYALTY15',15,'2025-01-01','2025-12-31'),
(5,'WINTER8',8,'2025-12-01','2026-01-31');

INSERT INTO coupon_redemption (id, coupon_id, invoice_id, redeemed_at) VALUES
(1,1,10001,'2025-02-10 10:04:00'),
(2,2,10008,'2025-02-13 13:05:00'),
(3,4,10021,'2025-02-21 10:05:00'),
(4,1,10005,'2025-02-11 11:35:00'),
(5,5,10029,'2025-02-25 18:05:00'),
(6,2,10012,'2025-02-15 15:05:00');

INSERT INTO return_invoice (return_id, original_invoice_id, store_id, emp_id, return_date, total_amount, reason) VALUES
(3001,10003,3,4,'2025-02-20 10:00:00',320.00,'Damaged product'),
(3002,10012,3,4,'2025-02-21 11:00:00',15.00,'Customer changed mind'),
(3003,10029,1,1,'2025-02-26 12:00:00',50.00,'Expired on receipt'),
(3004,10007,1,1,'2025-02-27 13:00:00',20.00,'Packaging issue');

INSERT INTO store_transfer (transfer_id, from_store, to_store, transfer_date, emp_id) VALUES
(4001,1,2,'2025-02-05',3),
(4002,2,3,'2025-02-06',9),
(4003,1,3,'2025-02-07',6),
(4004,3,1,'2025-02-08',11);

INSERT INTO store_transfer_item (transfer_id, product_id, batch_id, qty) VALUES
(4001,2,5,50),
(4001,3,6,30),
(4002,12,7,100),
(4003,1,1,40),
(4003,21,4,10),
(4004,26,24,50),
(4004,11,14,200),
(4002,36,30,20),
(4001,22,24,30),
(4003,10,2,20);

INSERT INTO price_history (id, product_id, old_price, new_price, changed_at) VALUES
(1,1,58.00,64.00,'2025-01-01 08:00:00'),
(2,4,280.00,320.00,'2025-01-01 08:00:00'),
(3,8,180.00,220.00,'2025-01-01 08:00:00'),
(4,12,40.00,45.00,'2025-01-01 08:00:00'),
(5,16,200.00,240.00,'2025-01-01 08:00:00'),
(6,20,100.00,120.00,'2025-01-01 08:00:00'),
(7,30,380.00,420.00,'2025-01-01 08:00:00'),
(8,36,120.00,150.00,'2025-01-01 08:00:00'),
(9,5,150.00,180.00,'2025-01-01 08:00:00'),
(10,21,120.00,140.00,'2025-01-01 08:00:00');

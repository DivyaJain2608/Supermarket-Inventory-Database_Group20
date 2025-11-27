# Retail Supermarket Inventory System (DBMS Project)

This repository contains the SQL schema and ER diagram for a Retail Supermarket Inventory System created as part of the DBMS course.

---

## Files Included
- **supermarket_database.sql** – Complete database schema with full table definitions and sample data.
- **supermarket_ER_diagram.pdf** – ER diagram showing all entities and their relationships.

---

## Project Description
This project represents the database design for a retail supermarket.  
It covers major operations such as product management, procurement, inventory control, sales billing, customer loyalty, employee management, and store-level operations.

The schema is fully normalized and enforces primary–foreign key constraints to maintain data integrity.

---

## Entities Included (All Tables)

### **1. Product & Pricing**
- category  
- brand  
- product  
- product_tax  
- price_history  

### **2. Suppliers & Procurement**
- supplier  
- supplier_product  
- purchase_order  
- purchase_order_item  
- grn  
- grn_item  
- supplier_rating  

### **3. Inventory & Stock**
- product_batch  
- stock  
- stock_ledger  
- store_transfer  
- store_transfer_item  

### **4. Store & Employees**
- store_location  
- employee  
- department  
- role  
- attendance  
- employee_shift  

### **5. Sales & Customers**
- customer  
- customer_loyalty  
- sales_invoice  
- sales_invoice_item  
- payment_method  
- payment  
- coupon  
- coupon_redemption  
- return_invoice  

---

## Highlights
- 32 fully connected tables  
- Batch-level inventory tracking  
- Complete procurement → stock → sales workflow  
- Multi-store inventory structure  
- Customer loyalty and coupon system  
- Supplier mapping and GRN-based stock updates  
- Clear foreign key relationships ensuring referential integrity  

---

## Group Details
**Project:** Retail Supermarket Inventory System  
**Group 20**<br>
**Members:** <br>
Divya Jain (341138) <br>
Kashish Jain (341143) <br>
Mandira Roy (341151)<br>
**PGDM 34(C)** <br>
**Course:** DBMS  
**Submitted To:** Prof. Ashok K. Harnal


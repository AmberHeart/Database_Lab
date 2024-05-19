DROP DATABASE IF EXISTS lab2;
CREATE DATABASE lab2
    DEFAULT CHARACTER SET = 'utf8mb4';
USE lab2;

DROP TABLE IF EXISTS bank;
DROP TABLE IF EXISTS account;
DROP TABLE IF EXISTS loan;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS department;

-- 创建银行表
CREATE TABLE bank (
    bank_name VARCHAR(50) NOT NULL,
    bank_address VARCHAR(100) NOT NULL,
    bank_contact VARCHAR(50) NOT NULL,
    PRIMARY KEY (bank_name)
);

-- 创建客户表
CREATE TABLE customer (
    customer_id INT NOT NULL AUTO_INCREMENT,
    customer_username VARCHAR(50) NOT NULL UNIQUE,
    customer_password VARCHAR(50) NOT NULL DEFAULT '123456',
    customer_name VARCHAR(50) NOT NULL,
    id_card VARCHAR(50) NOT NULL UNIQUE,
    customer_phone VARCHAR(50) NOT NULL,
    PRIMARY KEY (customer_id)
);

-- 创建账户表
CREATE TABLE account (
    account_id INT NOT NULL AUTO_INCREMENT,
    account_type VARCHAR(50) NOT NULL,
    account_balance DECIMAL(15, 2) DEFAULT 0.00, 
    customer_id INT NOT NULL,
    PRIMARY KEY (account_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- 创建贷款表
CREATE TABLE loan (
    loan_id INT NOT NULL AUTO_INCREMENT,
    customer_id INT NOT NULL,
    loan_amount DECIMAL(15, 2) NOT NULL,
    loan_date DATE NOT NULL,
    loan_term INT NOT NULL,
    loan_status VARCHAR(50) NOT NULL,
    PRIMARY KEY (loan_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- 创建部门表
CREATE TABLE department (
    department_id INT NOT NULL AUTO_INCREMENT,
    department_name VARCHAR(50) NOT NULL,
    department_phone VARCHAR(50) NOT NULL,
    PRIMARY KEY (department_id)
);

-- 创建员工表
CREATE TABLE employee (
    employee_id INT NOT NULL AUTO_INCREMENT,
    employee_username VARCHAR(50) NOT NULL UNIQUE,
    employee_password VARCHAR(50) NOT NULL DEFAULT 'admin',
    employee_name VARCHAR(50) NOT NULL,
    employee_phone VARCHAR(50) NOT NULL,
    department_id INT NOT NULL,
    PRIMARY KEY (employee_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);

-- 插入测试数据
INSERT INTO bank VALUES ('中国银行', '北京市东城区东长安街1号', '95566');

INSERT INTO customer (customer_username, customer_password, customer_name, id_card, customer_phone) VALUES ('zhangsan', '123456', '张三', '110101199001011234', '13800138000');
INSERT INTO customer (customer_username, customer_password, customer_name, id_card, customer_phone) VALUES ('lisi', '123456', '李四', '110101199001011235', '13800138001');
INSERT INTO customer (customer_username, customer_password, customer_name, id_card, customer_phone) VALUES ('wangwu', '123456', '王五', '110101199001011236', '13800138002');

INSERT INTO account (account_type, account_balance, customer_id) VALUES ('储蓄账户', 10000.00, 1);
INSERT INTO account (account_type, account_balance, customer_id) VALUES ('定期存款账户', 20000.00, 1);
INSERT INTO account (account_type, account_balance, customer_id) VALUES ('定期存款账户', 20000.00, 2);
INSERT INTO account (account_type, account_balance, customer_id) VALUES ('储蓄账户', 30000.00, 3);

INSERT INTO loan (customer_id, loan_amount, loan_date, loan_term, loan_status) VALUES (1, 10000.00, '2020-01-01', 12, '待审批');
INSERT INTO loan (customer_id, loan_amount, loan_date, loan_term, loan_status) VALUES (2, 20000.00, '2020-01-01', 12, '待审批');
INSERT INTO loan (customer_id, loan_amount, loan_date, loan_term, loan_status) VALUES (3, 30000.00, '2020-01-01', 12, '待审批');

INSERT INTO department (department_name, department_phone) VALUES ('财务部', '010-12345678');
INSERT INTO department (department_name, department_phone) VALUES ('人事部', '010-12345679');
INSERT INTO department (department_name, department_phone) VALUES ('市场部', '010-12345680');

INSERT INTO employee (employee_username, employee_password, employee_name, employee_phone, department_id) VALUES ('admin', 'admin', '管理员', '010-12345677', 1);
INSERT INTO employee (employee_username, employee_password, employee_name, employee_phone, department_id) VALUES ('Employee1', '123456', '员工1', '010-12345678', 2);
INSERT INTO employee (employee_username, employee_password, employee_name, employee_phone, department_id) VALUES ('Employee2', '123456', '员工2', '010-12345679', 3);

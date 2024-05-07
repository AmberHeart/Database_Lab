-- Active: 1713010429592@@127.0.0.1@3306@lab1
CREATE DATABASE lab1;
USE lab1;
-- 删除表格
DROP TABLE IF EXISTS book, Reader, Borrow, Reserve;
-- 创建图书表
CREATE TABLE Book (
    bid CHAR(8) PRIMARY KEY,
    bname VARCHAR(100) NOT NULL,
    author VARCHAR(50),
    price FLOAT,
    bstatus INT DEFAULT 0,
    borrow_Times INT DEFAULT 0,
    reserve_Times INT DEFAULT 0
);

-- 创建读者表
CREATE TABLE Reader (
    rid CHAR(8) PRIMARY KEY,
    rname VARCHAR(20),
    age INT,
    address VARCHAR(100)
);

-- 创建借阅表
CREATE TABLE Borrow (
    book_ID CHAR(8),
    reader_ID CHAR(8),
    borrow_Date DATE,
    return_Date DATE,
    PRIMARY KEY (book_ID, reader_ID, borrow_Date),
    FOREIGN KEY (book_ID) REFERENCES Book(bid),
    FOREIGN KEY (reader_ID) REFERENCES Reader(rid)
);

-- 创建预约表
CREATE TABLE Reserve (
    book_ID CHAR(8),
    reader_ID CHAR(8),
    reserve_Date DATE DEFAULT (CURDATE()),
    take_Date DATE,
    PRIMARY KEY (book_ID, reader_ID, reserve_Date),
    FOREIGN KEY (book_ID) REFERENCES Book(bid),
    FOREIGN KEY (reader_ID) REFERENCES Reader(rid),
    CHECK (take_Date > reserve_Date)
);

-- 插入图书数据
INSERT INTO book (bid, bname, author, price, borrow_times, reserve_times, bstatus) 
VALUES 
('B001', 'The Hobbit', 'J.R.R. Tolkien', 18.99, 4, 1, 2),
('B002', 'Harry Potter and the Chamber of Secrets', 'J.K. Rowling', 25.50, 3, 0, 1),
('B003', 'Harry Potter and the Philosopher\'s Stone', 'J.K. Rowling', 14.7, 2, 0, 1),
('B004', 'To Kill a Mockingbird', 'Harper Lee', 12.99, 0, 0, 0),
('B005', '1984', 'George Orwell', 10.50, 0, 1, 2),
('B006', 'Learning MySQL: Get a Handle on Your Data', 'Seyed M.M. (Saied) Tahaghoghi, Hugh E. Williams', 29.99, 1, 0, 1),
('B007', 'Pride and Prejudice', 'Jane Austen', 14.25, 1, 0, 1),
('B008', 'The Catcher in the Rye', 'J.D. Salinger', 11.20, 0, 2, 2),
('B009', 'Brave New World', 'Aldous Huxley', 13.80, 1, 0, 1),
('B010', 'Animal Farm', 'George Orwell', 8.99, 1, 1, 1) ,
('B011', 'MySQL Cookbook: Solutions for Database Developers and Administrators', 'Paul DuBois', 35.50, 1, 0, 0),
('B012', 'Test your trigger here', 'TA', 10.4, 0, 0, 0)
;


-- 插入读者数据
INSERT INTO reader (rid, rname, age, address)
VALUES
('R001', 'John', 35, '456 Oak St, Othertown'),
('R002', 'Rose', 35, '123 Main St, Anytown'),
('R003', 'Emma', 30, '123 Elm St, Anytown'),
('R004', 'Sophia', 28, '789 Maple St, Somewhere'),
('R005', 'Emily', 28, '456 Elm St, Othertown'),
('R006', 'Michael', 40, '789 Oak St, Somewhere');

-- 插入借阅数据
INSERT INTO borrow (book_id, reader_id, borrow_date, return_date)
VALUES
('B001', 'R002', '2024-03-01', '2024-03-15'),
('B003', 'R001', '2024-03-05', '2024-03-20'),
('B002', 'R001', '2024-03-10', NULL),
('B001', 'R004', '2024-03-15', '2024-03-16'),
('B006', 'R005', '2024-03-03', NULL),
('B003', 'R001', '2024-03-21', NULL),
('B001', 'R005', '2024-03-17', '2024-03-18'),
('B001', 'R006', '2024-03-19', '2024-03-20'),
('B002', 'R001', '2024-03-08', '2024-03-09'),
('B002', 'R005', '2024-03-09', '2024-03-10'),
('B011', 'R005', '2024-03-11', '2024-03-25'),
('B010', 'R002', '2024-03-12', NULL),
('B007', 'R005', '2024-03-03', NULL),
('B009', 'R005', '2024-03-03', NULL);

-- 插入预约数据
INSERT INTO reserve (book_id, reader_id, take_date)		-- ver1将预约数据中4月改为6月
VALUES
('B001', 'R001', '2024-06-08'),
('B005', 'R004', '2024-06-08'),
('B008', 'R005', '2024-06-10'),
('B008', 'R002', '2024-06-10'),
('B010', 'R006', '2024-06-15');

-- 2.1 查询读者 Rose 借过的书（包括已还和未还）的图书号、书名和借期；
SELECT book.bid, book.bname, borrow.borrow_Date
FROM book, borrow, reader
WHERE
    book.bid = borrow.book_ID
    AND borrow.reader_ID = reader.rid
    AND reader.rname = 'Rose';

-- 2.2 查询从没有借过图书也从没有预约过图书的读者号和读者姓名；
SELECT reader.rid, reader.rname
FROM reader
WHERE reader.rid NOT IN (
    SELECT reader_ID
    FROM borrow
    UNION
    SELECT reader_ID
    FROM reserve
);

-- 2.3 查询被借阅次数最多的作者（注意一个作者可能写了多本书）；
# 使用借阅表 borrow 中的借书记录
SELECT book.author
FROM book, borrow
WHERE book.bid = borrow.book_ID
GROUP BY book.author
ORDER BY COUNT(*) DESC
LIMIT 1;

# 使用图书表 book 中的borrow_times
SELECT book.author
FROM book
GROUP BY book.author
ORDER BY SUM(book.borrow_times) DESC
LIMIT 1;

# 思考：使用 borrow 表的方法更好，因为 borrow 表中的记录是实际借阅的记录，而 book 表中的 borrow_times 是统计的借阅次数，可能存在重复统计的情况。 

-- 2.4 查询目前借阅未还的书名中包含“MySQL”的图书号和书名；
SELECT book.bid, book.bname
FROM book, borrow
WHERE
    book.bid = borrow.book_ID
    AND book.bname LIKE '%MySQL%'
    AND borrow.return_Date IS NULL;

-- 2.5 查询借阅图书数目（多次借同一本书需重复计入）超过3本的读者姓名；
SELECT reader.rname
FROM reader, borrow
WHERE reader.rid = borrow.reader_ID
GROUP BY reader.rname
HAVING COUNT(*) > 3;

-- 2.6 查询没有借阅过任何一本 J.K. Rowling 所著的图书的读者号和姓名；
SELECT reader.rid, reader.rname
FROM reader
WHERE reader.rid NOT IN (
    SELECT DISTINCT
        borrow.reader_ID
    FROM borrow, book
    WHERE
        borrow.book_ID = book.bid
        AND book.author = 'J.K. Rowling'
);

-- 2.7 查询 2024 年借阅图书数目排名前 3 名的读者号、姓名以及借阅图书数；
SELECT reader.rid, reader.rname, COUNT(*) AS borrow_cout
FROM reader, borrow
WHERE
    reader.rid = borrow.reader_ID
    AND borrow.borrow_Date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY reader.rid
ORDER BY borrow_cout DESC
LIMIT 3;

-- 2.8 创建一个读者借书信息的视图，该视图包含读者号、姓名、所借图书号、图书名和借期（对于没有借过图书的读者，是否包含在该视图中均可）；
-- 并使用该视图查询2024年所有读者的读者号以及所借阅的不同图书数
DROP VIEW IF EXISTS reader_borrow_info;
CREATE VIEW reader_borrow_info AS
SELECT reader.rid, reader.rname, borrow.book_ID, book.bname, borrow.borrow_Date
FROM reader, borrow, book
WHERE
    reader.rid = borrow.reader_ID
    AND borrow.book_ID = book.bid;

SELECT rid, COUNT(DISTINCT book_ID) AS borrow_count
FROM reader_borrow_info
WHERE borrow_Date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY rid;

-- 3、 设计一个存储过程 updateReaderID,实现对读者表的 ID 的修改
/* （本题要求不得使用外键定义时的 on update cascade 选项,因为该选项不是所有 DBMS 都支持）。
使用该存储过程：将读者ID中‘R006’改为‘R999’。
（3-6题中，select对应表展示变化，另外可以select “error”，会显示字符串error在结果中，实现打印错误信息） */
DROP PROCEDURE IF EXISTS updateReaderID;
DELIMITER //
CREATE PROCEDURE updateReaderID(IN oldID CHAR(8), IN newID CHAR(8))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'error';
    END;
    START TRANSACTION;
    SET FOREIGN_KEY_CHECKS = 0;
    UPDATE Reader SET rid = newID WHERE rid = oldID;
    UPDATE Borrow SET reader_ID = newID WHERE reader_ID = oldID;
    UPDATE Reserve SET reader_ID = newID WHERE reader_ID = oldID;
    SET FOREIGN_KEY_CHECKS = 1;
    COMMIT;
END 
//
DELIMITER ;

# 测试存储过程
CALL updateReaderID('R006', 'R999');
SELECT * FROM reader;

-- 设计一个存储过程 borrowBook, 当读者借书时调用该存储过程完成借书处理。要求：
/* 
A. 一个读者最多只能借阅 3 本图书，意味着如果读者已经借阅了 3 本图书并且未归还则不允许再借书；
B. 同一天不允许同一个读者重复借阅同一本读书；
C. 如果该图书存在预约记录，而当前借阅者没有预约，则不许借阅；
（思考：在实现时，处理借书请求的效率是否和 A、B、C 的实现顺序有关系？）
D. 如果借阅者已经预约了该图书，则允许借阅，但要求借阅完成后删除借阅者对该图书的预约记录；
E. 借阅成功后图书表中的 times 加 1，修改 bstatus，并在borrow表中插入相应借阅信息。 
*/
DROP PROCEDURE IF EXISTS borrowBook;
DELIMITER //
CREATE PROCEDURE borrowBook(IN input_reader_id CHAR(8), IN input_book_id CHAR(8))
BEGIN
    DECLARE borrowed_count INT;
    DECLARE is_borrowed_today BOOL;
    DECLARE has_reservation BOOL;
    DECLARE reservation_exists BOOL;
    DECLARE cannot_borrow BOOL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'error' AS error_msg;
        ROLLBACK;
    END;

    START TRANSACTION;

    -- 初始化变量
    SET borrowed_count = 0;
    SET has_reservation = FALSE;
    SET reservation_exists = FALSE;
    SET cannot_borrow = FALSE;

    -- 检查读者已借阅数量是否超过 3 本
    SELECT COUNT(*) INTO borrowed_count
    FROM borrow
    WHERE reader_ID = input_reader_id AND borrow_date IS NOT NULL AND return_date IS NULL;

    IF borrowed_count >= 3 THEN
        SELECT CONCAT('Reader ', input_reader_id, ' has already borrowed 3 books.') AS error_msg;
        SET cannot_borrow = TRUE;
    END IF;

    -- 检查是否重复借阅同一本书
    SELECT EXISTS (
        SELECT 1
        FROM borrow
        WHERE book_ID = input_book_id AND reader_ID = input_reader_id AND borrow_date = '2024-05-9'
    ) INTO is_borrowed_today;

    IF is_borrowed_today THEN
        SELECT CONCAT('Reader ', input_reader_id, ' has borrowed book ', input_book_id, ' today.') AS error_msg;
        SET cannot_borrow = TRUE;
    END IF;

    -- 检查是否存在预约记录
    SELECT EXISTS (
        SELECT 1
        FROM reserve
        WHERE book_ID = input_book_id
    ) INTO reservation_exists;

    -- 检查读者是否已预约该书
    SELECT EXISTS (
        SELECT 1
        FROM reserve
        WHERE book_ID = input_book_id AND reader_ID = input_reader_id
    ) INTO has_reservation;

    IF reservation_exists AND NOT has_reservation THEN
        SELECT CONCAT('Book ', input_book_id, ' is reserved by others.') AS error_msg;
        SET cannot_borrow = TRUE;
    END IF;

    -- 借阅成功,更新相关表
    IF cannot_borrow = FALSE THEN
        UPDATE book
        SET bstatus = 1, borrow_times = borrow_times + 1
        WHERE bid = input_book_id;

        INSERT INTO borrow (book_ID, reader_ID, borrow_Date, return_Date)
        VALUES (input_book_id, input_reader_id, '2024-05-9', NULL);

        IF has_reservation THEN
            DELETE FROM reserve
            WHERE book_ID = input_book_id AND reader_ID = input_reader_id;
        END IF;

        SELECT CONCAT('Reader ', input_reader_id, ' borrowed book ', input_book_id, ' successfully.') AS success_msg;
    END IF;

    COMMIT;
END //
DELIMITER ;

# 测试存储过程
CALL borrowBook('R001', 'B008');
CALL borrowBook('R001', 'B001');
CALL borrowBook('R001', 'B001');
CALL borrowBook('R005', 'B008');

-- 参考 4，设计一个存储过程 returnBook，当读者还书时调用该存储过程完成还书处理。
/* 要求：
A. 还书后补上借阅表 borrow 中对应记录的 return_date;
B. 还书后将图书表 book 中对应记录的 bstatus 修改为 0（没有其他预约）或 2（有其他预约） 。 
*/
DROP PROCEDURE IF EXISTS returnBook;
DELIMITER //
CREATE PROCEDURE returnBook(IN input_reader_id CHAR(8), IN input_book_id CHAR(8))
BEGIN
    DECLARE has_borrowed BOOL;
    DECLARE has_reservation BOOL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred during return book process.' AS error_msg;
        ROLLBACK;
    END;

    START TRANSACTION;

    -- 初始化变量
    SET has_borrowed = TRUE;
    SET has_reservation = FALSE;

    -- 检查读者是否已借阅该书
    IF NOT EXISTS (
        SELECT 1
        FROM borrow
        WHERE reader_ID = input_reader_id AND book_ID = input_book_id AND return_date IS NULL
    ) THEN
        SELECT CONCAT('Reader ', input_reader_id, ' has not borrowed book ', input_book_id, '.') AS error_msg;
        SET has_borrowed = FALSE;
    END IF;

    -- 检查是否有其他读者预约该书
    SELECT EXISTS (
        SELECT 1
        FROM reserve
        WHERE book_ID = input_book_id AND reader_ID <> input_reader_id
    ) INTO has_reservation;

    IF has_borrowed THEN
        -- 更新借阅记录的归还日期
        UPDATE borrow
        SET return_date = '2024-05-10'
        WHERE reader_ID = input_reader_id AND book_ID = input_book_id AND return_date IS NULL;

        -- 更新图书状态
        IF has_reservation THEN
            UPDATE book
            SET bstatus = 2  -- 有其他预约
            WHERE bid = input_book_id;
        ELSE
            UPDATE book
            SET bstatus = 0  -- 无预约
            WHERE bid = input_book_id;
        END IF;

        SELECT CONCAT('Reader ', input_reader_id, ' returned book ', input_book_id, ' successfully.') AS success_msg;
    END IF;

    COMMIT;
END //
DELIMITER ;

-- 测试存储过程
CALL returnBook('R001', 'B008');
# 展示book表中的bstatus以及borrow表中的return_date变化
SELECT * FROM book WHERE bid = 'B001';
SELECT * FROM borrow WHERE book_ID = 'B001' AND reader_ID = 'R001';
CALL returnBook('R001', 'B001');
SELECT * FROM book WHERE bid = 'B001';
SELECT * FROM borrow WHERE book_ID = 'B001' AND reader_ID = 'R001';


-- 设计触发器，实现：
DELIMITER //
# A. 当一本书被预约时, 自动将图书表 book 中相应图书的 bstatus修改为 2，并增加 reserve_Times；
CREATE TRIGGER trigger_reserve_book
AFTER INSERT ON reserve
FOR EACH ROW
BEGIN
    UPDATE book
    SET bstatus = 2, reserve_times = reserve_times + 1
    WHERE bid = NEW.book_id;
END;
//

CREATE TRIGGER reserve_cancelled
AFTER DELETE ON reserve
FOR EACH ROW
BEGIN
    # B. 当某本预约的书被借出时或者读者取消预约时，自动减少 reserve_Times
    UPDATE book
    SET reserve_Times = reserve_Times - 1
    WHERE bid = OLD.book_ID;
    
    # C. 当某本书的最后一位预约者取消预约且该书未被借出（修改前 bstatus 为 2）时，将 bstatus 改为 0
    IF NOT EXISTS (
        SELECT 1 FROM reserve WHERE book_ID = OLD.book_ID
    ) THEN
        UPDATE book
        SET bstatus = 0
        WHERE bid = OLD.book_ID AND bstatus = 2;
    END IF;
END;
//
DELIMITER ;

-- 测试触发器
SELECT * FROM book WHERE bid = 'B012';
INSERT INTO reserve (book_id, reader_id, reserve_Date, take_date) VALUES ('B012', 'R001', '2024-06-08', NULL); # 预约书籍
SELECT * FROM book WHERE bid = 'B012';
DELETE FROM reserve WHERE book_id = 'B012'; # 取消预约
SELECT * FROM book WHERE bid = 'B012';
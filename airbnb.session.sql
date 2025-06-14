DROP TABLE IF EXISTS users, bookings, rooms, cars, Sales, Insurances, Rentals, Drivers, Payments, RoomPrices, CarPrices, Reviews, MaintenanceLogs, Promotions, UserPromotions, LoyaltyPrograms, Equipment, IncidentReports, Notifications, GiftCards;
-- @block
CREATE TABLE Users(
    id INT AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    bio TEXT,
    country VARCHAR(2),
    PRIMARY KEY (id)
);
--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv'
INTO TABLE Users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(email, bio, country);

--@block
SELECT * FROM Users;

-- @block
CREATE TABLE Rooms (
    id INT AUTO_INCREMENT,
    street VARCHAR (255),
    owner_id INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (owner_id) REFERENCES Users(id)
);

-- @block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/rooms.csv'
INTO TABLE Rooms
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(street, owner_id);


-- @block
CREATE TABLE Bookings(
    id INT AUTO_INCREMENT,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in DATETIME,
    PRIMARY KEY (id),
    FOREIGN KEY (guest_id) REFERENCES Users (id),
    FOREIGN KEY (room_id) REFERENCES Rooms (id)
);
-- @block
SELECT * FROM Users
INNER JOIN Rooms ON Rooms.owner_id = Users.id;
-- @block Rooms a user has booked
SELECT
guest_id,
street,
check_in
FROM bookings
INNER JOIN Rooms ON Rooms.owner_id = guest_id
WHERE guest_id = 1
-- @block Drop old tables if needed
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Rooms;
DROP TABLE IF EXISTS Users;

-- @block Users table with email as primary key
CREATE TABLE Users (
    email VARCHAR(255) PRIMARY KEY,
    bio TEXT,
    country VARCHAR(2)
);

-- @block Rooms table, owner_email instead of owner_id
CREATE TABLE Rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    street VARCHAR(255),
    owner_email VARCHAR(255) NOT NULL,
    FOREIGN KEY (owner_email) REFERENCES Users(email)
);

-- @block Bookings table
CREATE TABLE Bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guest_email VARCHAR(255) NOT NULL,
    room_id INT NOT NULL,
    check_in DATETIME,
    FOREIGN KEY (guest_email) REFERENCES Users(email),
    FOREIGN KEY (room_id) REFERENCES Rooms(id)
);
-- @block BCNF
INSERT INTO Users (email, bio, country)
VALUES
('yle@route.com', 'fishing expert', 'MA'),
('olf@cyberspace.com', 'ethical hacker', 'SB');

INSERT INTO Rooms (owner_email, street)
VALUES
('yle@route.com', '341 Fed St'),
('olf@cyberspace.com', '9112 Sane St');

INSERT INTO Bookings (guest_email, room_id, check_in)
VALUES
('yle@route.com', 1, '2025-03-23 14:00:00'),
('olf@cyberspace.com', 2, '2025-03-24 10:00:00');
--@block
CREATE TABLE Cars (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    brand VARCHAR(255) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INT NOT NULL,
    FOREIGN KEY (email) REFERENCES Users(email)
);

-- @block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/cars.csv'
INTO TABLE Cars
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(email, brand, model, year);


--@block
CREATE TABLE Sales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    CarID INT,
    SaleDate DATE NOT NULL,
    SalePrice DECIMAL(10, 2) NOT NULL,
    CustomerID INT,
    FOREIGN KEY (CarID) REFERENCES Cars(id)
);

-- @block
INSERT INTO Sales (CarID, SaleDate, SalePrice, CustomerID)
SELECT 
    c.id AS CarID,
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365 * 3) DAY) AS SaleDate, 
    ROUND(5000 + RAND() * 45000, 2) AS SalePrice,  
    u.id AS CustomerID
FROM Cars c
JOIN Users u ON u.id != c.id  
ORDER BY RAND()
LIMIT 1000;

--@block
SELECT 
    u.email, u.country,
    c.id AS car_id, c.brand, c.model, c.year,
    s.id AS sale_id, s.SaleDate, s.SalePrice, s.CustomerID
FROM 
    Users u
INNER JOIN Cars c ON u.email = c.email
INNER JOIN Sales s ON c.id = s.CarID;

--@block
CREATE TABLE Insurances (
    id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT NOT NULL,
    insurance_provider VARCHAR(255) NOT NULL,
    policy_number VARCHAR(100) NOT NULL,
    coverage_start DATE NOT NULL,
    coverage_end DATE NOT NULL,
    FOREIGN KEY (car_id) REFERENCES Cars(id)
);

--@block
CREATE TABLE Rentals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT NOT NULL,
    renter_id INT NOT NULL,
    rental_start DATETIME NOT NULL,
    rental_end DATETIME,
    FOREIGN KEY (car_id) REFERENCES Cars(id),
    FOREIGN KEY (renter_id) REFERENCES Users(id)
);
-- @block
INSERT INTO Insurances (car_id, insurance_provider, policy_number, coverage_start, coverage_end)
SELECT 
    id AS car_id,
    ELT(FLOOR(1 + RAND() * 6), 
        'Allianz', 'GEICO', 'State Farm', 'Progressive', 'Liberty Mutual', 'AXA') AS insurance_provider,
    CONCAT('POL', id, LPAD(FLOOR(RAND() * 1000000), 6, '0')) AS policy_number,
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365 * 3) DAY) AS coverage_start,
    DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 365 * 2) DAY) AS coverage_end
FROM Cars;

-- @block
INSERT INTO Rentals (car_id, renter_id, rental_start, rental_end)
SELECT 
    c.id AS car_id,
    u.id AS renter_id,
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY) AS rental_start,
    CASE 
        WHEN RAND() < 0.8 
        THEN DATE_ADD(NOW(), INTERVAL FLOOR(RAND() * 30) DAY)
        ELSE NULL  
    END AS rental_end
FROM Cars c
JOIN Users u ON u.id != c.id
ORDER BY RAND()
LIMIT 1000;


--@block
SELECT 
    u.email, u.country,
    r.id AS rental_id, r.rental_start, r.rental_end,
    i.id AS insurance_id, i.insurance_provider, i.policy_number, i.coverage_start, i.coverage_end,
    c.id AS car_id, c.brand, c.model, c.year
FROM 
    Users u
INNER JOIN Rentals r ON u.id = r.renter_id
INNER JOIN Cars c ON r.car_id = c.id
INNER JOIN Insurances i ON c.id = i.car_id;

--@block
CREATE TABLE Drivers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    license_country VARCHAR(2),
    license_expiry DATE,
    verified BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/drivers.csv'
INTO TABLE Drivers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(user_id, license_number, license_country, license_expiry, verified);

--@block
SELECT * FROM Drivers WHERE verified=true;

--@block
CREATE TABLE Payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('card', 'paypal', 'bank_transfer', 'cash') NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'completed', 'failed') DEFAULT 'completed',
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

--@block
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/payments.csv'
INTO TABLE Payments
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(user_id, amount, payment_method, payment_date, @status)
SET status = CASE 
    WHEN LOWER(TRIM(@status)) = 'pending' THEN 'pending'
    WHEN LOWER(TRIM(@status)) = 'completed' THEN 'completed'
    WHEN LOWER(TRIM(@status)) = 'failed' THEN 'failed'
    ELSE 'completed' 
END; 

--@block
SELECT 
    p.id AS payment_id,
    u.email,
    p.amount,
    p.payment_method,
    p.payment_date,
    p.status
FROM Payments p
JOIN Users u ON p.user_id = u.id
ORDER BY p.payment_date DESC;

--@block
CREATE TABLE RoomPrices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (room_id) REFERENCES Rooms(id)
);
-- @block
INSERT INTO RoomPrices (room_id, price, start_date, end_date)
SELECT 
    r.id,
    ROUND(50 + RAND() * 250, 2) AS price, 
    DATE_ADD(CURDATE(), INTERVAL -FLOOR(RAND() * 365) DAY) AS start_date, 
    DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 90) DAY) AS end_date      
FROM Rooms r
ORDER BY RAND()
LIMIT 750;

--@block
SELECT * FROM RoomPrices;
--@block
CREATE TABLE CarPrices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT NOT NULL,
    daily_rate DECIMAL(10, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (car_id) REFERENCES Cars(id)
);
--@block
INSERT INTO CarPrices (car_id, daily_rate, start_date, end_date)
SELECT 
    c.id,
    ROUND(20 + (RAND() * 130), 2) AS daily_rate,  
    DATE_ADD(CURDATE(), INTERVAL -FLOOR(RAND() * 365) DAY) AS start_date, 
    DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 60) DAY) AS end_date       
FROM Cars c
ORDER BY RAND()
LIMIT 1000;
--@block
SELECT * FROM CarPrices;

--@block
CREATE TABLE Reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    room_id INT,
    car_id INT,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (room_id) REFERENCES Rooms(id),
    FOREIGN KEY (car_id) REFERENCES Cars(id),
    CHECK (room_id IS NOT NULL OR car_id IS NOT NULL)
);
--@block
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/reviews.csv'
INTO TABLE Reviews
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(user_id, room_id, car_id, rating, comment, review_date);


-- @block
SELECT 
    r.id,
    u.email AS user_email,
    r.room_id,
    r.car_id,
    r.rating,
    r.comment,
    r.review_date
FROM Reviews r
JOIN Users u ON r.user_id = u.id
ORDER BY r.review_date DESC;

--@block
CREATE TABLE MaintenanceLogs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_type ENUM('room', 'car') NOT NULL,
    item_id INT NOT NULL, 
    maintenance_type VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATETIME NOT NULL,
    end_date DATETIME,
    cost DECIMAL(10, 2),
    technician VARCHAR(100),
    status ENUM('scheduled', 'in progress', 'completed', 'cancelled') NOT NULL DEFAULT 'scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--@block
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/maintenance_logs.csv'
INTO TABLE MaintenanceLogs
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(item_type, item_id, maintenance_type, description, start_date, @end_date, cost, technician, @status)
SET
    end_date = NULLIF(@end_date, ''),
    status = CASE 
        WHEN TRIM(@status) = 'in progress' THEN 'in progress'
        WHEN TRIM(@status) = 'completed' THEN 'completed'
        WHEN TRIM(@status) = 'cancelled' THEN 'cancelled'
        WHEN TRIM(@status) = 'scheduled' THEN 'scheduled'
        ELSE 'scheduled' 
    END;
--@block
SELECT id, item_type, item_id, maintenance_type, description, start_date, end_date, cost, technician, status
FROM MaintenanceLogs
LIMIT 100;

-- @block
CREATE TABLE Promotions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    promo_type ENUM('seasonal', 'flash_sale', 'loyalty', 'referral') NOT NULL,
    discount_id INT, 
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    target_audience VARCHAR(100),
    channel ENUM('email', 'sms', 'app', 'web') NOT NULL
);

--@block
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/promotions.csv'
INTO TABLE Promotions
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(name, description, promo_type, @discount_id, start_date, end_date, target_audience, @channel)
SET 
    discount_id = NULLIF(@discount_id, ''),
    channel = CASE 
        WHEN LOWER(TRIM(@channel)) IN ('email', 'sms', 'app', 'web') THEN LOWER(TRIM(@channel))
        ELSE 'email' 
    END;
--@block
CREATE TABLE UserPromotions (
    user_id INT NOT NULL,
    promotion_id INT NOT NULL,
    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, promotion_id),
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (promotion_id) REFERENCES Promotions(id)
);
--@block
INSERT INTO UserPromotions (user_id, promotion_id)
SELECT 
    u.id AS user_id,
    (
        SELECT id FROM Promotions ORDER BY RAND() LIMIT 1
    ) AS promotion_id
FROM Users AS u;
--@block
SELECT 
    up.user_id,
    u.email AS user_name,
    up.promotion_id,
    p.name AS promotion_name,
    up.assigned_at
FROM UserPromotions up
JOIN Users u ON up.user_id = u.id
JOIN Promotions p ON up.promotion_id = p.id
ORDER BY RAND()
LIMIT 500;

--@block
CREATE TABLE LoyaltyPrograms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    points_balance INT DEFAULT 0,
    current_tier ENUM('Bronze', 'Silver', 'Gold', 'Platinum') DEFAULT 'Bronze',
    join_date DATE NOT NULL,
    last_activity_date DATE
    -- FOREIGN KEY (user_id) REFERENCES Users(id)  
);

-- @block
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/loyalty_programs.csv'
INTO TABLE LoyaltyPrograms
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(user_id, points_balance, current_tier, join_date, last_activity_date);


--@block
SELECT 
    u.id AS user_id,
    u.email,
    lp.points_balance,
    lp.current_tier,
    lp.join_date,
    lp.last_activity_date
FROM LoyaltyPrograms lp
JOIN Users u ON lp.user_id = u.id;

--@block
CREATE TABLE Equipment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    daily_rate DECIMAL(10, 2) NOT NULL,
    current_stock INT NOT NULL,
    reorder_threshold INT DEFAULT 3
);
-- @block
INSERT INTO Equipment (name, description, daily_rate, current_stock, reorder_threshold)
VALUES 
('GPS Navigator', 'Portable GPS unit for vehicles', 5.99, 15, 3),
('Child Seat', 'Child safety car seat', 7.50, 8, 2),
('Bike Rack', 'Roof-mounted bike carrier', 4.25, 5, 2),
('Snow Chains', 'Snow chains for winter driving', 6.00, 10, 3),
('WiFi Hotspot', 'Portable WiFi for travelers', 8.75, 20, 5);
--@block
SELECT * 
FROM Equipment
ORDER BY daily_rate DESC;

--@block
CREATE TABLE IncidentReports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    rental_id INT,
    reporter_id INT NOT NULL,
    incident_type ENUM('Damage', 'Accident', 'Theft', 'Complaint', 'Other') NOT NULL,
    description TEXT NOT NULL,
    incident_date DATETIME NOT NULL,
    resolution_status ENUM('Open', 'In Progress', 'Resolved', 'Claim Filed') DEFAULT 'Open',
    resolution_notes TEXT,
    FOREIGN KEY (booking_id) REFERENCES Bookings(id),
    FOREIGN KEY (rental_id) REFERENCES Rentals(id),
    FOREIGN KEY (reporter_id) REFERENCES Users(id)
);

--@block
INSERT INTO IncidentReports (
    rental_id,
    reporter_id,
    incident_type,
    description,
    incident_date,
    resolution_status,
    resolution_notes
)
SELECT 
    r.id AS rental_id,
    u.id AS reporter_id,
    ELT(FLOOR(1 + RAND() * 5), 'Damage', 'Accident', 'Theft', 'Complaint', 'Other') AS incident_type,
    CONCAT('Reported issue involving ', ELT(FLOOR(1 + RAND() * 5), 'a delay', 'a breakdown', 'lost items', 'a rude driver', 'property damage')) AS description,
    DATE_SUB(CURRENT_DATE(), INTERVAL FLOOR(RAND() * 180) DAY) AS incident_date,
    ELT(FLOOR(1 + RAND() * 4), 'Open', 'In Progress', 'Resolved', 'Claim Filed') AS resolution_status,
    CONCAT('Initial follow-up performed. Status: ', ELT(FLOOR(1 + RAND() * 4), 'pending investigation', 'resolved', 'insurance filed', 'awaiting client response')) AS resolution_notes
FROM Users u
LEFT JOIN Rentals r ON r.renter_id = u.id
WHERE r.id IS NOT NULL
ORDER BY RAND()
LIMIT 200;

--@block
SELECT 
    ir.*,
    u.email 
FROM IncidentReports ir
JOIN Users u ON ir.reporter_id = u.id;

--@block
CREATE TABLE Notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    notification_type ENUM('Booking', 'Payment', 'Incident', 'Promotion', 'System') NOT NULL,
    message TEXT NOT NULL,
    status ENUM('Unread', 'Read', 'Archived') DEFAULT 'Unread',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);
--@block
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/notifications.csv'
INTO TABLE Notifications
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(user_id, notification_type, message, status, created_at);

--@block
SELECT * FROM Notifications 

--@block
CREATE TABLE GiftCards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    balance DECIMAL(10, 2) NOT NULL DEFAULT 0,
    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATE,
    status ENUM('Active', 'Used', 'Expired') DEFAULT 'Active',
    FOREIGN KEY (user_id) REFERENCES Users(id)
);
--@block
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/giftcards.csv'
INTO TABLE GiftCards
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(code, user_id, balance, issue_date, expiry_date, @status)
SET status = CASE 
    WHEN TRIM(@status) IN ('Active', 'Used', 'Expired') THEN TRIM(@status)
    ELSE 'Active'  
END;

--@block
SELECT * FROM GiftCards
WHERE expiry_date BETWEEN CURDATE() AND (CURDATE() + INTERVAL 30 DAY);



























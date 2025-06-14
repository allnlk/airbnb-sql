--@block
DROP TABLE IF EXISTS users, bookings, rooms, cars, Sales, Insurances, Rentals, Drivers, Payments, RoomPrices, CarPrices, Reviews, MaintenanceLogs, Promotions, UserPromotions, LoyaltyPrograms, Equipment, IncidentReports, Notifications, GiftCards;
--@block
CREATE TABLE Users(
    id SERIAL,
    email VARCHAR(255) NOT NULL UNIQUE,
    bio TEXT,
    country VARCHAR(2),
    PRIMARY KEY (id)
);
--@block
COPY Users(email, bio, country)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv'
DELIMITER ','
CSV HEADER;

--@block
SELECT * FROM Users;

--@block
CREATE TABLE Rooms (
    id SERIAL,
    street VARCHAR (255),
    owner_id INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (owner_id) REFERENCES Users(id)
);

--@block
COPY Rooms (street, owner_id)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/rooms.csv'
WITH (
    FORMAT csv,
    HEADER,
    DELIMITER ',',
    QUOTE '"'
);


-- @block
CREATE TABLE Bookings(
    id SERIAL,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (guest_id) REFERENCES Users (id),
    FOREIGN KEY (room_id) REFERENCES Rooms (id)
);
-- @block
SELECT * FROM Users
INNER JOIN Rooms ON Rooms.owner_id = Users.id;

--@block
CREATE TABLE Cars (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    brand VARCHAR(255) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INT NOT NULL,
    FOREIGN KEY (email) REFERENCES Users(email)
);

--@block
COPY Cars (email, brand, model, year)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/cars.csv'
WITH (
    FORMAT csv,
    HEADER,
    DELIMITER ',',
    QUOTE '"'
);


--@block
CREATE TABLE Sales (
    id SERIAL PRIMARY KEY,
    CarID INT,
    SaleDate DATE NOT NULL,
    SalePrice DECIMAL(10, 2) NOT NULL,
    CustomerID INT,
    FOREIGN KEY (CarID) REFERENCES Cars(id)
);

--@block
INSERT INTO Sales (CarID, SaleDate, SalePrice, CustomerID)
WITH random_assignments AS (
    SELECT 
        c.id AS car_id,
        u.id AS customer_id
    FROM Cars c
    CROSS JOIN LATERAL (
        SELECT id 
        FROM Users 
        WHERE id != c.id  
        ORDER BY RANDOM() 
        LIMIT 1
    ) u
    ORDER BY RANDOM()
    LIMIT 1000
)
SELECT 
    ra.car_id AS CarID,
    (CURRENT_DATE - (FLOOR(RANDOM() * 365 * 3) || ' days')::interval) AS SaleDate,
    ROUND((5000 + RANDOM() * 45000)::numeric, 2) AS SalePrice,
    ra.customer_id AS CustomerID
FROM random_assignments ra;

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
    id SERIAL PRIMARY KEY,
    car_id INT NOT NULL,
    insurance_provider VARCHAR(255) NOT NULL,
    policy_number VARCHAR(100) NOT NULL,
    coverage_start DATE NOT NULL,
    coverage_end DATE NOT NULL,
    FOREIGN KEY (car_id) REFERENCES Cars(id)
);

--@block
CREATE TABLE Rentals (
    id SERIAL PRIMARY KEY,
    car_id INT NOT NULL,
    renter_id INT NOT NULL,
    rental_start TIMESTAMP NOT NULL,
    rental_end TIMESTAMP,
    FOREIGN KEY (car_id) REFERENCES Cars(id),
    FOREIGN KEY (renter_id) REFERENCES Users(id)
);
-- @block
INSERT INTO Insurances (car_id, insurance_provider, policy_number, coverage_start, coverage_end)
SELECT 
    id AS car_id,
    (ARRAY['Allianz', 'GEICO', 'State Farm', 'Progressive', 'Liberty Mutual', 'AXA'])[1 + FLOOR(RANDOM() * 6)] AS insurance_provider,
    'POL' || id || LPAD(FLOOR(RANDOM() * 1000000)::text, 6, '0') AS policy_number,
    (CURRENT_DATE - (FLOOR(RANDOM() * 365 * 3) || ' days')::interval)::date AS coverage_start,
    (CURRENT_DATE + (FLOOR(RANDOM() * 365 * 2) || ' days')::interval)::date AS coverage_end
FROM Cars;
--@block
INSERT INTO Rentals (car_id, renter_id, rental_start, rental_end)
SELECT 
    c.id,
    u.id,
    (NOW() - (FLOOR(RANDOM() * 365) || ' days')::interval),
    CASE 
        WHEN RANDOM() < 0.8 THEN (NOW() + (FLOOR(RANDOM() * 30) || ' days')::interval)
        ELSE NULL
    END
FROM (
    SELECT id FROM Cars ORDER BY RANDOM() LIMIT 1000
) c
CROSS JOIN LATERAL (
    SELECT id FROM Users ORDER BY RANDOM() LIMIT 1
) u;

--@block
SELECT 
    r.car_id,
    r.renter_id,
    r.rental_start
FROM Rentals r
WHERE r.rental_end IS NULL
ORDER BY r.rental_start DESC;


--@block
CREATE TABLE Drivers (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    license_country CHAR(2),
    license_expiry DATE,
    verified BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);


--@block
COPY Drivers (user_id, license_number, license_country, license_expiry, verified)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/drivers.csv'
WITH (
    FORMAT csv,
    HEADER,
    DELIMITER ',',
    QUOTE '"'
);

--@block
SELECT * FROM Drivers WHERE verified = TRUE;

--@block
CREATE TYPE payment_method_enum AS ENUM ('card', 'paypal', 'bank_transfer', 'cash');
CREATE TYPE payment_status_enum AS ENUM ('pending', 'completed', 'failed');
--@block
CREATE TABLE Payments (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method payment_method_enum NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status payment_status_enum DEFAULT 'completed',
    FOREIGN KEY (user_id) REFERENCES Users(id)
);
--@block
COPY Payments(user_id, amount, payment_method, payment_date, status)
FROM 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/payments.csv'
WITH (
    FORMAT csv,
    DELIMITER E'\t',
    NULL '',
    HEADER
);

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
    id SERIAL PRIMARY KEY,
    room_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (room_id) REFERENCES Rooms(id)
);

--@block
INSERT INTO RoomPrices (room_id, price, start_date, end_date)
SELECT 
    r.id,
    ROUND((50 + random() * 250)::numeric, 2) AS price,
    CURRENT_DATE - (floor(random() * 365) || ' days')::INTERVAL AS start_date,
    (CURRENT_DATE - (floor(random() * 365) || ' days')::INTERVAL) + (floor(random() * 90 + 1) || ' days')::INTERVAL AS end_date
FROM Rooms r
ORDER BY random()
LIMIT 750;

--@block
SELECT * FROM RoomPrices;

--@block
CREATE TABLE CarPrices (
    id SERIAL PRIMARY KEY,
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
    ROUND((20 + random() * 130)::numeric, 2) AS daily_rate,
    (CURRENT_DATE - (floor(random() * 365) || ' days')::INTERVAL) AS start_date,
    (CURRENT_DATE - (floor(random() * 365) || ' days')::INTERVAL) + (floor(random() * 60 + 1) || ' days')::INTERVAL AS end_date
FROM Cars c
ORDER BY random()
LIMIT 1000;

--@block
SELECT * FROM CarPrices;

--@block
CREATE TABLE Reviews (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    room_id INT,
    car_id INT,
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (room_id) REFERENCES Rooms(id),
    CHECK (room_id IS NOT NULL OR car_id IS NOT NULL)
);

--@block
COPY Reviews(user_id, room_id, car_id, rating, comment, review_date)
FROM 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/reviews.csv'
WITH (
    FORMAT csv,
    DELIMITER E'\t',
    NULL '\N',
    HEADER
);


--@block
SELECT DISTINCT
    r.id,
    CONCAT(u.email, '_rev_', FLOOR(RANDOM() * 1000000)::TEXT) AS user_email,  -- додаємо великий випадковий суфікс до емайлу
    COALESCE(rm.street, c.model) AS item, 
    r.rating,
    'Review: ' || 
    (ARRAY['Excellent stay!', 'Very good service.', 'Okay experience, could improve.', 'Not bad, but expected more.', 'Totally dissatisfied.'])[FLOOR(RANDOM() * 5 + 1)] AS comment,  -- випадковий коментар
    r.review_date
FROM Reviews r
JOIN Users u ON r.user_id = u.id
LEFT JOIN Rooms rm ON r.room_id = rm.id
LEFT JOIN Cars c ON r.car_id = c.id
ORDER BY r.review_date DESC;


--@block
CREATE TYPE item_type_enum AS ENUM ('room', 'car');
CREATE TYPE maintenance_status_enum AS ENUM ('scheduled', 'in_progress', 'completed', 'cancelled');
--@block
CREATE TABLE MaintenanceLogs (
    id SERIAL PRIMARY KEY,
    item_type item_type_enum NOT NULL,
    item_id INT NOT NULL, 
    maintenance_type VARCHAR(100) NOT NULL,
    description TEXT,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    cost DECIMAL(10, 2),
    technician VARCHAR(100),
    status maintenance_status_enum DEFAULT 'scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--@block
CREATE TEMP TABLE tmp_logs (
    item_type TEXT,
    item_id TEXT,
    maintenance_type TEXT,
    description TEXT,
    start_date TEXT,
    end_date TEXT,
    cost TEXT,
    technician TEXT,
    status TEXT
);
--@block
COPY tmp_logs FROM 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/maintenance_logs.csv'
WITH (
    FORMAT csv,
    DELIMITER E'\t',
    HEADER
);
--@block
INSERT INTO MaintenanceLogs(item_type, item_id, maintenance_type, description, start_date, end_date, cost, technician, status)
SELECT 
    item_type::item_type_enum,
    item_id::INT,
    maintenance_type,
    description,
    NULLIF(start_date, '')::TIMESTAMP,
    NULLIF(end_date, '')::TIMESTAMP,
    NULLIF(cost, '')::DECIMAL,
    NULLIF(technician, ''),
    CASE 
        WHEN TRIM(LOWER(status)) = 'in progress' THEN 'in_progress'
        WHEN TRIM(LOWER(status)) = 'completed' THEN 'completed'
        WHEN TRIM(LOWER(status)) = 'cancelled' THEN 'cancelled'
        ELSE 'scheduled'
    END::maintenance_status_enum
FROM tmp_logs;
--@block
SELECT 
    m.id,
    m.item_type,
    CASE 
        WHEN m.item_type = 'room' THEN r.street
        WHEN m.item_type = 'car' THEN CONCAT(c.brand, ' ', c.model)
        ELSE 'Unknown Item'
    END AS item_name,
    m.maintenance_type,
    m.status,
    m.start_date,
    m.end_date,
    m.cost
FROM MaintenanceLogs m
LEFT JOIN Rooms r ON m.item_type = 'room' AND m.item_id = r.id
LEFT JOIN Cars c ON m.item_type = 'car' AND m.item_id = c.id
WHERE m.status != 'completed'
ORDER BY m.start_date DESC;



--@block
CREATE TYPE promo_type_enum AS ENUM ('seasonal', 'flash_sale', 'loyalty', 'referral');
CREATE TYPE channel_enum AS ENUM ('email', 'sms', 'app', 'web');

--@block
CREATE TABLE Promotions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    promo_type promo_type_enum NOT NULL,
    discount_id INT,  
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    target_audience VARCHAR(100),
    channel channel_enum NOT NULL
);


--@block
CREATE TEMP TABLE tmp_promotions (
    name TEXT,
    description TEXT,
    promo_type TEXT,
    discount_id TEXT,
    start_date TEXT,
    end_date TEXT,
    target_audience TEXT,
    channel TEXT
);
--@block
COPY tmp_promotions
FROM 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/promotions.csv'
WITH (
    FORMAT csv,
    DELIMITER E'\t',
    HEADER
);
--@block
INSERT INTO Promotions (name, description, promo_type, discount_id, start_date, end_date, target_audience, channel)
SELECT
    name,
    description,
    promo_type::promo_type_enum,
    NULLIF(discount_id, '')::INT,
    NULLIF(start_date, '')::TIMESTAMP,
    NULLIF(end_date, '')::TIMESTAMP,
    target_audience,
    CASE 
        WHEN LOWER(TRIM(channel)) IN ('email', 'sms', 'app', 'web') THEN LOWER(TRIM(channel))
        ELSE 'email'
    END::channel_enum
FROM tmp_promotions;

--@block
SELECT name, start_date, end_date 
FROM Promotions ;
--@block
CREATE TABLE UserPromotions (
    user_id INT NOT NULL,
    promotion_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, promotion_id),
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (promotion_id) REFERENCES Promotions(id)
);
--@block
WITH promo_assignments AS (
    SELECT 
        u.id AS user_id,
        p.id AS promotion_id
    FROM Users u
    JOIN Promotions p ON p.id IS NOT NULL
    ORDER BY RANDOM()
)
INSERT INTO UserPromotions (user_id, promotion_id)
SELECT user_id, promotion_id
FROM promo_assignments
WHERE NOT EXISTS (
    SELECT 1
    FROM UserPromotions up
    WHERE up.user_id = promo_assignments.user_id
      AND up.promotion_id = promo_assignments.promotion_id
);

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
ORDER BY RANDOM()
LIMIT 500;

--@block
CREATE TYPE tier_enum AS ENUM ('Bronze', 'Silver', 'Gold', 'Platinum');

-- @block
CREATE TABLE LoyaltyPrograms (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    points_balance INT DEFAULT 0,
    current_tier tier_enum DEFAULT 'Bronze',
    join_date DATE NOT NULL,
    last_activity_date DATE,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

--@block
COPY LoyaltyPrograms(user_id, points_balance, current_tier, join_date, last_activity_date)
FROM 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/loyalty_programs.csv'
WITH (
    FORMAT csv,
    DELIMITER E'\t',
    NULL '\N',
    HEADER
);

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
    id SERIAL PRIMARY KEY,
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
CREATE TYPE incident_type_enum AS ENUM ('Damage', 'Accident', 'Theft', 'Complaint', 'Other');
CREATE TYPE resolution_status_enum AS ENUM ('Open', 'In Progress', 'Resolved', 'Claim Filed');

--@block
CREATE TABLE IncidentReports (
    report_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    incident_date TIMESTAMP NOT NULL,
    incident_type VARCHAR(100) NOT NULL,
    description TEXT,
    severity_level VARCHAR(20) CHECK (severity_level IN ('Low', 'Medium', 'High', 'Critical')),
    status VARCHAR(20) DEFAULT 'Open' CHECK (status IN ('Open', 'In Progress', 'Resolved', 'Closed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);
--@block
INSERT INTO IncidentReports (user_id, incident_date, incident_type, description, severity_level, status, resolved_at)
SELECT 
    floor(random() * 1000) + 1 as user_id,
    CURRENT_TIMESTAMP - (random() * 365 * 3 || ' days')::interval as incident_date,
    CASE floor(random() * 6)
        WHEN 0 THEN 'Login Issue'
        WHEN 1 THEN 'Payment Problem'
        WHEN 2 THEN 'Service Outage'
        WHEN 3 THEN 'Data Error'
        WHEN 4 THEN 'Security Alert'
        ELSE 'Other'
    END as incident_type,
    CASE 
        WHEN random() < 0.3 THEN 'User reported issue with ' || 
            CASE floor(random() * 4)
                WHEN 0 THEN 'authentication'
                WHEN 1 THEN 'payment processing'
                WHEN 2 THEN 'data display'
                ELSE 'system performance'
            END
        WHEN random() < 0.6 THEN 'Automated system detected ' ||
            CASE floor(random() * 3)
                WHEN 0 THEN 'unusual activity'
                WHEN 1 THEN 'failed transactions'
                ELSE 'connection errors'
            END
        ELSE 'Manual report submitted by user'
    END as description,
    CASE floor(random() * 4)
        WHEN 0 THEN 'Low'
        WHEN 1 THEN 'Medium'
        WHEN 2 THEN 'High'
        ELSE 'Critical'
    END as severity_level,
    CASE floor(random() * 4)
        WHEN 0 THEN 'Open'
        WHEN 1 THEN 'In Progress'
        ELSE 'Resolved'
    END as status,
    CASE 
        WHEN random() < 0.7 THEN CURRENT_TIMESTAMP - (random() * 30 || ' days')::interval
        ELSE NULL
    END as resolved_at
FROM generate_series(1, 5000);
 --@block
SELECT 
    incident_type,
    severity_level,
    COUNT(*) as count
FROM IncidentReports
GROUP BY incident_type, severity_level
ORDER BY incident_type, 
    CASE severity_level
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        ELSE 4
    END;


--@block
CREATE TYPE notification_type_enum AS ENUM ('Booking', 'Payment', 'Incident', 'Promotion', 'System');
CREATE TYPE status_enum AS ENUM ('Unread', 'Read', 'Archived');
--@block
CREATE TABLE Notifications (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    notification_type notification_type_enum NOT NULL,
    message TEXT NOT NULL,
    status status_enum DEFAULT 'Unread',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

--@block
CREATE TYPE notification_status_enum AS ENUM (
    'Unread', 'Read', 'Archived'
);

--@block
COPY Notifications (user_id, notification_type, message, status, created_at)
FROM 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/notifications.csv'
WITH (
    FORMAT csv,
    DELIMITER E'\t',
    HEADER true,
    NULL ''
);


--@block
SELECT * FROM Notifications 

--@block
CREATE TYPE new_status_enum AS ENUM ('Active', 'Used', 'Expired');
--@block
CREATE TABLE GiftCards (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    balance DECIMAL(10, 2) NOT NULL DEFAULT 0,
    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATE,
    status new_status_enum DEFAULT 'Active',
    FOREIGN KEY (user_id) REFERENCES Users(id)
);
--@block
COPY GiftCards(code, user_id, balance, issue_date, expiry_date, status)
FROM 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/giftcards.csv'
DELIMITER E'\t'
CSV HEADER;

--@block
SELECT * 
FROM GiftCards 
WHERE expiry_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days';





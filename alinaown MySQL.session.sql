--@block
DROP TABLE IF EXISTS users, Achievements, NutritionLog, SportEvents, Sports, TrainingSessions, UserSports, HydrationLog, MealPlans, MealPlanRecipes, UserGoals, WorkoutPlans, Coaches, UserCoaches, WorkoutExercises, ProgressTracking, UserChallenges, BodyMeasurements, UserInjuries, UserDevices, Payments, Bonuses, Payroll;
--@block
CREATE TABLE Users(
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    bio TEXT,
    country VARCHAR(2)
);

--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/sportsmen.csv'
INTO TABLE Users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(email, bio, country);

--@block
SELECT * FROM Users;
--@block
CREATE TABLE Sports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    category VARCHAR(50)
);
 --@block
 INSERT INTO Sports (name, category)
VALUES
('Tennis', 'Racket Sports'),
('Football', 'Team Sports'),
('Basketball', 'Team Sports'),
('Swimming', 'Aquatics'),
('Volleyball', 'Team Sports'),
('Athletics', 'Track and Field'),
('Boxing', 'Combat Sports'),
('Cycling', 'Endurance Sports'),
('Gymnastics', 'Artistic Sports'),
('Hockey', 'Team Sports'),
('Badminton', 'Racket Sports'),
('Table Tennis', 'Racket Sports'),
('Rugby', 'Team Sports'),
('Baseball', 'Team Sports'),
('Cricket', 'Team Sports'),
('Diving', 'Aquatics'),
('Water Polo', 'Aquatics'),
('Sprinting', 'Track and Field'),
('Archery', 'Target Sports'),
('Fencing', 'Combat Sports'),
('Weightlifting', 'Strength Sports'),
('Wrestling', 'Combat Sports'),
('Skiing', 'Winter Sports'),
('Snowboarding', 'Winter Sports'),
('Surfing', 'Water Sports'),
('Canoeing', 'Water Sports'),
('Rowing', 'Water Sports'),
('Triathlon', 'Multisport'),
('Karate', 'Martial Arts'),
('Judo', 'Martial Arts'),
('Taekwondo', 'Martial Arts'),
('Golf', 'Precision Sports'),
('Handball', 'Team Sports'),
('Squash', 'Racket Sports'),
('Polo', 'Equestrian Sports'),
('Horse Racing', 'Equestrian Sports'),
('Figure Skating', 'Winter Sports'),
('Ice Hockey', 'Team Sports'),
('Curling', 'Winter Sports'),
('Bowling', 'Target Sports'),
('Darts', 'Target Sports');

--@block
CREATE TABLE UserSports (
    user_id INT,
    sport_id INT,
    skill_level ENUM('Beginner', 'Intermediate', 'Advanced', 'Professional', 'Amateur'),
    PRIMARY KEY (user_id, sport_id),
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (sport_id) REFERENCES Sports(id)
); 

--@block
INSERT INTO UserSports (user_id, sport_id, skill_level)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 1000
)
SELECT 
    n AS user_id,
    FLOOR(1 + RAND() * 20) AS sport_id,
    ELT(FLOOR(1 + RAND() * 5),
        'Beginner',
        'Intermediate',
        'Advanced',
        'Professional',
        'Amateur'
    ) AS skill_level
FROM numbers
ON DUPLICATE KEY UPDATE 
    sport_id = VALUES(sport_id),
    skill_level = VALUES(skill_level); 


-- @block
SELECT u.id, u.email, s.name AS sport, us.skill_level
FROM UserSports us
JOIN Users u ON us.user_id = u.id
JOIN Sports s ON us.sport_id = s.id;

--@block
CREATE TABLE Achievements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    date_achieved DATE,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/achievements.csv'
INTO TABLE Achievements
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(user_id, title, description, date_achieved);


--@block
SELECT u.email, a.title, a.date_achieved
FROM Achievements a 
JOIN Users u ON a.user_id = u.id;

--@block
CREATE TABLE TrainingSessions (
    id INT PRIMARY KEY AUTO_INCREMENT, 
    user_id INT, 
    sport_id INT,
    duration_minutes INT NOT NULL,
    calories_burned INT,
    session_date DATETIME NOT NULL, 
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES Users (id),
    FOREIGN KEY (sport_id) REFERENCES Sports (id)
);

--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/trainingsessions.csv'
INTO TABLE TrainingSessions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(user_id, sport_id, duration_minutes, calories_burned, session_date);


--@block
SELECT
ts. id,
ts.user_id,
s.name AS 'Kind of sport',
ts.duration_minutes AS 'Duration',
ts.calories_burned AS 'Calories'
FROM TrainingSessions ts
JOIN Sports s ON ts.sport_id = s.id
LIMIT 1000;

--@block
CREATE TABLE SportEvents (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(100) NOT NULL,
    sport_id INT NOT NULL,
    event_date DATE NOT NULL,
    location VARCHAR(100),
    description TEXT,
    organizer_id INT,
    FOREIGN KEY (sport_id) REFERENCES Sports(id),
    FOREIGN KEY (organizer_id) REFERENCES Users(id)
);

--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/sportevents.csv'
INTO TABLE SportEvents
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(name, sport_id, event_date, location, organizer_id);

-- @block
SELECT
e.name AS 'Name',
s.name AS 'KIND',
e.location AS 'Location',
u. email AS 'Organisator'
FROM SportEvents e
JOIN Sports s ON e.sport_id = s.id
JOIN
Users u ON e.organizer_id = u.id
ORDER BY e.event_date DESC
LIMIT 1000;

--@block
CREATE TABLE NutritionLog (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    log_date DATE NOT NULL,
    meal_type ENUM('Breakfast', 'Lunch', 'Dinner', 'Snack', 'Pre-Workout', 'Post-Workout') NOT NULL,
    calories INT NOT NULL,
    protein_g INT,
    carbs_g INT,
    fat_g INT,
    water_ml INT,
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/nutritionlog.csv'
INTO TABLE NutritionLog
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(user_id, log_date, meal_type, calories, protein_g, carbs_g, fat_g, water_ml, notes);

-- @block
SELECT u.email, nl.log_date, nl.meal_type, nl.calories
FROM NutritionLog nl
JOIN Users u ON nl.user_id = u.id
ORDER BY nl.log_date DESC;

--@block
CREATE TABLE MealPlans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    calories_per_day INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/mealplans.csv'
INTO TABLE MealPlans
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(user_id, name, description, calories_per_day);

--@block
CREATE TABLE MealPlanRecipes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    meal_plan_id INT,
    recipe_name VARCHAR(100) NOT NULL,
    meal_type ENUM('Breakfast', 'Lunch', 'Dinner', 'Snack'),
    ingredients TEXT,
    instructions TEXT,
    calories INT,
    FOREIGN KEY (meal_plan_id) REFERENCES MealPlans(id)
);
--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/mealplanrecipes.csv'
INTO TABLE MealPlanRecipes
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(meal_plan_id, recipe_name, meal_type, ingredients, instructions, calories);

--@block
SELECT 
    mp.id AS meal_plan_id,
    mp.name AS meal_plan_name,
    mp.calories_per_day,
    mpr.recipe_name,
    mpr.meal_type,
    mpr.calories AS recipe_calories
FROM MealPlans mp
LEFT JOIN MealPlanRecipes mpr ON mp.id = mpr.meal_plan_id
ORDER BY mp.id, FIELD(mpr.meal_type, 'Breakfast', 'Lunch', 'Dinner', 'Snack');
--@block
CREATE TABLE HydrationLog (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    date DATE,
    water_liters DECIMAL(4,2),
    FOREIGN KEY (user_id) REFERENCES Users(id)
);
--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/hydrationlog.csv'
INTO TABLE HydrationLog
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(user_id, date, water_liters);

--@block
SELECT user_id, date, water_liters
FROM (
    SELECT 
        user_id,
        date,
        water_liters,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY date DESC) AS rn
    FROM HydrationLog
) t
WHERE rn = 1;

--@block
CREATE TABLE UserGoals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    goal_text TEXT NOT NULL,
    target_date DATE,
    status ENUM('active', 'achieved', 'abandoned'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);
--@block
INSERT INTO UserGoals (user_id, goal_text, target_date, status)
SELECT 
    u.id,
    g.goal_text,
    DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 90) DAY) AS target_date,
    s.status
FROM Users u
JOIN (
    SELECT 'Lose 5 kg' AS goal_text UNION ALL
    SELECT 'Run a half marathon' UNION ALL
    SELECT 'Increase bench press to 100kg' UNION ALL
    SELECT 'Swim 1km without stopping' UNION ALL
    SELECT 'Train consistently for 30 days' UNION ALL
    SELECT 'Improve flexibility with daily stretching' UNION ALL
    SELECT 'Cycle 500km in one month' UNION ALL
    SELECT 'Eat balanced meals for 4 weeks' UNION ALL
    SELECT 'Get 8 hours of sleep daily for a month' UNION ALL
    SELECT 'Join a local competition'
) g
JOIN (
    SELECT 'active' AS status UNION ALL
    SELECT 'achieved' UNION ALL
    SELECT 'abandoned'
) s
ORDER BY RAND()
LIMIT 1000;
--@block
CREATE TABLE WorkoutPlans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    plan_name VARCHAR(100),
    plan_type ENUM('strength', 'cardio', 'flexibility', 'balance'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);
--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/workoutplans.csv'
INTO TABLE WorkoutPlans
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(user_id, plan_name, plan_type, created_at);

--@block
SELECT 
    u.id AS user_id,
    u.email,
    ug.goal_text,
    ug.status AS goal_status,
    wp.plan_name,
    wp.plan_type
FROM Users u
JOIN UserGoals ug ON u.id = ug.user_id
JOIN WorkoutPlans wp ON u.id = wp.user_id
WHERE ug.status = 'active'
ORDER BY u.id
LIMIT 800;
--@block
CREATE TABLE WorkoutExercises (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    muscle_group VARCHAR(50),
    equipment_required VARCHAR(100),
    difficulty_level VARCHAR(20)
);
--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/workoutexercises.csv'
INTO TABLE WorkoutExercises
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(name, description, muscle_group, equipment_required, difficulty_level);

--@block
SELECT 
    difficulty_level,
    COUNT(*) AS exercise_count
FROM WorkoutExercises
GROUP BY difficulty_level
ORDER BY exercise_count DESC;
--@block
CREATE TABLE Coaches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    specialization TEXT,
    email VARCHAR(255) UNIQUE
);
--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/coaches.csv' 
INTO TABLE Coaches
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES 
(name, specialization, email);

--@block
CREATE TABLE UserCoaches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    coach_id INT NOT NULL,
    assigned_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (coach_id) REFERENCES Coaches(id)
);

--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/user_coaches.csv' 
INTO TABLE UserCoaches
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES 
(user_id, coach_id, assigned_date);

--@block
SELECT 
    c.id AS coach_id,
    c.name AS coach_name,
    COUNT(uc.user_id) AS assigned_users
FROM Coaches c
LEFT JOIN UserCoaches uc ON c.id = uc.coach_id
GROUP BY c.id, c.name
ORDER BY assigned_users DESC
LIMIT 1000;

--@block
CREATE TABLE ProgressTracking (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    tracking_date DATE NOT NULL,
    weight_kg DECIMAL(5,2),
    body_fat_percentage DECIMAL(4,2),
    muscle_mass_kg DECIMAL(5,2),
    resting_heart_rate INT,
    daily_steps INT,
    calories_burned INT,
    workout_minutes INT,
    sleep_hours DECIMAL(3,1),
    mood_rating INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

--@block
INSERT INTO ProgressTracking (
    user_id, tracking_date, weight_kg, body_fat_percentage, muscle_mass_kg,
    resting_heart_rate, daily_steps, calories_burned, workout_minutes,
    sleep_hours, mood_rating, notes
)
SELECT
    MOD(i, 1000) + 1 AS user_id,
    DATE_SUB(CURDATE(), INTERVAL MOD(i, 365) DAY) AS tracking_date,
    ROUND(70 + (RAND() * 30) - (RAND() * 5 * MOD(i, 30)/30), 2) AS weight_kg,
    ROUND(15 + (RAND() * 15) - (RAND() * 3 * MOD(i, 30)/30), 2) AS body_fat_percentage,
    ROUND(30 + (RAND() * 20) + (RAND() * 2 * MOD(i, 30)/30), 2) AS muscle_mass_kg,
    50 + MOD(i, 30) AS resting_heart_rate,
    FLOOR(3000 + (RAND() * 12000)) AS daily_steps,
    FLOOR(1800 + (RAND() * 1500)) AS calories_burned,
    FLOOR(20 + (RAND() * 120)) AS workout_minutes,
    ROUND(5.5 + (RAND() * 4), 1) AS sleep_hours,
    MOD(i, 5) + 1 AS mood_rating,
    CASE MOD(i, 5)
        WHEN 0 THEN 'Felt great during workout'
        WHEN 1 THEN 'Recovery day, took it easy'
        WHEN 2 THEN 'Increased weights today'
        WHEN 3 THEN 'Struggled with energy levels'
        ELSE 'Consistent performance'
    END AS notes
FROM (
    SELECT @rownum := @rownum + 1 AS i FROM 
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t1,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t2,
    (SELECT @rownum := 0) r
    LIMIT 1000
) numbers;

--@block
SELECT user_id, tracking_date, weight_kg, body_fat_percentage, muscle_mass_kg,
       resting_heart_rate, daily_steps, calories_burned, workout_minutes,
       sleep_hours, mood_rating, notes, created_at
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY tracking_date DESC) AS rn
    FROM ProgressTracking
) t
WHERE rn = 1;

--@block
CREATE TABLE UserChallenges (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    challenge_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    status ENUM('In Progress', 'Completed', 'Failed'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);
--@block
INSERT INTO UserChallenges (user_id, challenge_name, start_date, status)
SELECT 
    MOD(i, 1000) + 1 AS user_id,
    c.challenge_name,
    DATE_SUB(CURDATE(), INTERVAL MOD(i, 365) DAY) AS start_date,
    s.status
FROM (
    SELECT @rownum := @rownum + 1 AS i FROM 
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t1,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t2,
    (SELECT @rownum := 0) r
    LIMIT 1000
) numbers
JOIN (
    SELECT '30 Day Fitness Challenge' AS challenge_name UNION ALL
    SELECT '10k Steps a Day' UNION ALL
    SELECT 'No Sugar Challenge' UNION ALL
    SELECT 'Strength Training Program' UNION ALL
    SELECT 'Yoga Flexibility Challenge'
) c ON 1=1
JOIN (
    SELECT 'In Progress' AS status UNION ALL
    SELECT 'Completed' UNION ALL
    SELECT 'Failed'
) s ON 1=1
ORDER BY RAND()
LIMIT 1000;

--@block
SELECT 
    uc.id AS challenge_id,
    uc.user_id,
    u.email,
    uc.challenge_name,
    uc.start_date,
    uc.status,
    uc.created_at
FROM UserChallenges uc
JOIN Users u ON uc.user_id = u.id
WHERE uc.status = 'In Progress'
ORDER BY uc.start_date DESC
LIMIT 30;

--@block
CREATE TABLE BodyMeasurements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    measurement_date DATE NOT NULL,
    weight_kg DECIMAL(5,2),
    height_cm DECIMAL(5,2),
    waist_cm DECIMAL(5,2),
    body_fat_percent DECIMAL(4,2),
    UNIQUE KEY unique_user_measurement (user_id, measurement_date),
    FOREIGN KEY (user_id) REFERENCES Users(id)
);
--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/body_measurements.csv'
INTO TABLE BodyMeasurements
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(user_id, measurement_date, weight_kg, height_cm, waist_cm, body_fat_percent);

--@block
SELECT user_id, measurement_date, weight_kg, height_cm, waist_cm, body_fat_percent
FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY measurement_date DESC) AS rn
    FROM BodyMeasurements
) t
WHERE rn = 1;
--@block
CREATE TABLE UserInjuries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    injury_type VARCHAR(100),
    injury_description TEXT,
    date_injured DATE,
    recovery_status ENUM('In Progress', 'Recovered', 'Not Started'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);
--@block
INSERT INTO UserInjuries (user_id, injury_type, injury_description, date_injured, recovery_status)
SELECT
    MOD(i, 1000) + 1 AS user_id,
    it.injury_type,
    idesc.injury_description,
    DATE_SUB(CURDATE(), INTERVAL MOD(i, 365) DAY) AS date_injured,
    rs.recovery_status
FROM (
    SELECT @rownum := @rownum + 1 AS i FROM 
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t1,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t2,
    (SELECT @rownum := 0) r
    LIMIT 1000
) numbers
JOIN (
    SELECT 'Knee' AS injury_type UNION ALL
    SELECT 'Ankle' UNION ALL
    SELECT 'Back' UNION ALL
    SELECT 'Shoulder' UNION ALL
    SELECT 'Wrist' UNION ALL
    SELECT 'Elbow'
) it ON 1=1
JOIN (
    SELECT 'Sprain' AS injury_description UNION ALL
    SELECT 'Fracture' UNION ALL
    SELECT 'Tendinitis' UNION ALL
    SELECT 'Strain' UNION ALL
    SELECT 'Dislocation'
) idesc ON 1=1
JOIN (
    SELECT 'In Progress' AS recovery_status UNION ALL
    SELECT 'Recovered' UNION ALL
    SELECT 'Not Started'
) rs ON 1=1
ORDER BY RAND()
LIMIT 1000; 


--@block
SELECT 
    ui.id AS injury_id,
    ui.user_id,
    u.email,
    ui.injury_type,
    ui.injury_description,
    ui.date_injured,
    ui.recovery_status,
    ui.created_at
FROM UserInjuries ui
JOIN Users u ON ui.user_id = u.id
ORDER BY ui.date_injured DESC
LIMIT 30;
--@block
CREATE TABLE UserDevices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    device_name VARCHAR(100) NOT NULL,
    device_type VARCHAR(50),
    registered_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);
--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/user_devices.csv'
INTO TABLE UserDevices
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(user_id, device_name, device_type, registered_on, is_active);

--@block
SELECT 
    ud.id,
    ud.user_id,
    u.email,
    ud.device_name,
    ud.device_type,
    ud.registered_on,
    ud.is_active
FROM UserDevices ud
JOIN Users u ON ud.user_id = u.id
ORDER BY ud.registered_on DESC
LIMIT 30;

--@block
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    payment_type ENUM('salary', 'bonus', 'reimbursement', 'other') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method ENUM('bank transfer', 'check', 'cash', 'digital wallet') NOT NULL,
    description VARCHAR(255),
    status ENUM('pending', 'completed', 'failed', 'cancelled') DEFAULT 'pending',
    transaction_reference VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_by INT,
    FOREIGN KEY (user_id) REFERENCES Users(id),  -- Changed to reference 'id'
    FOREIGN KEY (processed_by) REFERENCES Users(id)  -- Changed to reference 'id'
);
--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/payments_data.csv'
INTO TABLE Payments
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    payment_id, 
    user_id, 
    payment_type, 
    amount, 
    payment_date,
    payment_method, 
    description, 
    status, 
    @transaction_ref,
    created_at, 
    @processed_by
)
SET 
    transaction_reference = NULLIF(@transaction_ref, ''),
    processed_by = NULLIF(@processed_by, '');
--@block
SELECT 
    p.payment_id,
    p.user_id,
    u1.email AS user_name,
    p.amount,
    p.payment_type,
    p.status,
    p.payment_date,
    u2.email AS processed_by_name
FROM Payments p
JOIN users u1 ON p.user_id = u1.id
LEFT JOIN users u2 ON p.processed_by = u2.id;

--@block
CREATE TABLE Bonuses (
    bonus_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    bonus_type ENUM('performance', 'referral', 'holiday', 'retention', 'other') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    awarded_date DATE NOT NULL,
    payment_status ENUM('pending', 'paid', 'cancelled') DEFAULT 'pending',
    approved_by INT, 
    processed_by INT, 
    payment_id INT, 
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id),
    FOREIGN KEY (processed_by) REFERENCES users(id),
    FOREIGN KEY (payment_id) REFERENCES Payments(payment_id)
);

--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/bonuses_data.csv'
INTO TABLE Bonuses
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    bonus_id,
    user_id,
    bonus_type,
    amount,
    reason,
    awarded_date,
    payment_status,
    @approved_by,
    @processed_by,
    @payment_id
)
SET
    approved_by = NULLIF(@approved_by, ''),
    processed_by = NULLIF(@processed_by, ''),
    payment_id = NULLIF(@payment_id, '');
--@block
SELECT 
    b.bonus_id,
    u.email AS employee_name,
    b.bonus_type,
    b.amount,
    b.reason,
    b.awarded_date,
    a.email AS approved_by,
    pr.email AS processed_by,
    pay.amount AS payment_amount
FROM Bonuses b
JOIN users u ON b.user_id = u.id
LEFT JOIN users a ON b.approved_by = a.id
LEFT JOIN users pr ON b.processed_by = pr.id
LEFT JOIN Payments pay ON b.payment_id = pay.payment_id;

--@block
CREATE TABLE Payroll (
    payroll_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    pay_period_start DATE NOT NULL,
    pay_period_end DATE NOT NULL,
    base_salary DECIMAL(10,2) NOT NULL,
    hours_worked DECIMAL(5,2),
    overtime_hours DECIMAL(5,2),
    overtime_pay DECIMAL(10,2),
    bonus_total DECIMAL(10,2) DEFAULT 0.00,
    deductions DECIMAL(10,2) DEFAULT 0.00,
    tax_amount DECIMAL(10,2),
    net_pay DECIMAL(10,2) NOT NULL,
    payment_id INT, 
    status ENUM('draft', 'processed', 'paid', 'cancelled') DEFAULT 'draft',
    processed_at TIMESTAMP,
    processed_by INT, 
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (payment_id) REFERENCES Payments(payment_id),
    FOREIGN KEY (processed_by) REFERENCES users(id)
);
--@block
LOAD DATA INFILE '/ProgramData/MySQL/MySQL Server 8.0/Uploads/payroll_data.csv'
INTO TABLE Payroll
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    payroll_id,
    user_id,
    pay_period_start,
    pay_period_end,
    base_salary,
    hours_worked,
    overtime_hours,
    overtime_pay,
    bonus_total,
    deductions,
    tax_amount,
    net_pay,
    @payment_id,
    status,
    @processed_at,
    @processed_by,
    notes
)
SET
    payment_id = NULLIF(@payment_id, ''),
    processed_at = NULLIF(@processed_at, ''),
    processed_by = NULLIF(@processed_by, '');
--@block
SELECT 
    pr.payroll_id,
    u.email AS employee_name,
    pr.pay_period_start,
    pr.pay_period_end,
    pr.base_salary,
    pr.overtime_pay,
    pr.bonus_total,
    pr.deductions,
    pr.tax_amount,
    pr.net_pay,
    pay.amount AS payment_amount,
    proc.email AS processed_by_name
FROM Payroll pr
JOIN users u ON pr.user_id = u.id
LEFT JOIN Payments pay ON pr.payment_id = pay.payment_id
LEFT JOIN users proc ON pr.processed_by = proc.id;

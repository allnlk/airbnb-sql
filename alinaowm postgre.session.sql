--@block
DROP TABLE IF EXISTS users, Achievements, NutritionLog, SportEvents, Sports, TrainingSessions, UserSports, HydrationLog, MealPlans, MealPlanRecipes, UserGoals, WorkoutPlans, Coaches, UserCoaches, WorkoutExercises, ProgressTracking, UserChallenges, BodyMeasurements, UserInjuries, UserDevices, Payments, Bonuses, Payroll;
--@block
CREATE TABLE Users(
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    bio TEXT,
    country VARCHAR(2)
);

--@block
COPY Users (email, bio, country)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/sportsmen.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);

--@block
SELECT * FROM Users;

--@block
CREATE TABLE Sports (
    id SERIAL PRIMARY KEY,
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
    skill_level VARCHAR(20) CHECK (skill_level IN ('Beginner', 'Intermediate', 'Advanced', 'Professional', 'Amateur')),
    PRIMARY KEY (user_id, sport_id),
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (sport_id) REFERENCES Sports(id)
);
--@block
INSERT INTO UserSports (user_id, sport_id, skill_level)
SELECT 
    n AS user_id,
    1 + FLOOR(RANDOM() * 20) AS sport_id,
    (ARRAY['Beginner', 'Intermediate', 'Advanced', 'Professional', 'Amateur'])[1 + FLOOR(RANDOM() * 5)] AS skill_level
FROM 
    GENERATE_SERIES(1, 1000) AS n
ON CONFLICT (user_id, sport_id) 
DO UPDATE SET
    sport_id = EXCLUDED.sport_id,
    skill_level = EXCLUDED.skill_level;
--@block
SELECT u.id, u.email, s.name AS sport, us.skill_level
FROM UserSports us
JOIN Users u ON us.user_id = u.id
JOIN Sports s ON us.sport_id = s.id;

--@block
CREATE TABLE Achievements (
    id SERIAL PRIMARY KEY ,
    user_id INT,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    date_achieved DATE,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);
--@block
COPY Achievements (user_id, title, description, date_achieved)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/achievements.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);

--@block
SELECT u.email, a.title, a.date_achieved
FROM Achievements a 
JOIN Users u ON a.user_id = u.id;

--@block
CREATE TABLE TrainingSessions (
    id SERIAL PRIMARY KEY, 
    user_id INT, 
    sport_id INT,
    duration_minutes INT NOT NULL,
    calories_burned INT,
    session_date TIMESTAMP NOT NULL, 
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES Users (id),
    FOREIGN KEY (sport_id) REFERENCES Sports (id)
);
--@block
COPY TrainingSessions (user_id, sport_id, duration_minutes, calories_burned, session_date)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/trainingsessions.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);


--@block
SELECT
    ts.id,
    ts.user_id,
    s.name AS "Kind of sport",
    ts.duration_minutes AS "Duration",
    ts.calories_burned AS "Calories"
FROM TrainingSessions ts
JOIN Sports s ON ts.sport_id = s.id
LIMIT 1000;
--@block
CREATE TABLE SportEvents (
id SERIAL PRIMARY KEY,
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
COPY SportEvents (name, sport_id, event_date, location, organizer_id)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/sportevents.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);

--@block
SELECT
    e.name AS "Name",
    s.name AS "KIND",
    e.location AS "Location",
    u.email AS "Organisator"
FROM SportEvents e
JOIN Sports s ON e.sport_id = s.id
JOIN Users u ON e.organizer_id = u.id
ORDER BY e.event_date DESC
LIMIT 1000;

--@block
CREATE TABLE NutritionLog (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    log_date DATE NOT NULL,
    meal_type VARCHAR(20) NOT NULL CHECK (meal_type IN (
        'Breakfast', 
        'Lunch', 
        'Dinner', 
        'Snack', 
        'Pre-Workout', 
        'Post-Workout'
    )),
    calories INT NOT NULL,
    protein_g INT,
    carbs_g INT,
    fat_g INT,
    water_ml INT,
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);
--@block
COPY NutritionLog (user_id, log_date, meal_type, calories, protein_g, carbs_g, fat_g, water_ml, notes)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/nutritionlog.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);

--@block
SELECT u.email, nl.log_date, nl.meal_type, nl.calories
FROM NutritionLog nl
JOIN Users u ON nl.user_id = u.id
ORDER BY nl.log_date DESC;

--@block
CREATE TABLE MealPlans (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    calories_per_day INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--@block
COPY MealPlans (user_id, name, description, calories_per_day)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/mealplans.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);


--@block
CREATE TABLE MealPlanRecipes (
    id SERIAL PRIMARY KEY,
    meal_plan_id INT REFERENCES MealPlans(id),
    recipe_name VARCHAR(100) NOT NULL,
    meal_type VARCHAR(20) CHECK (meal_type IN ('Breakfast', 'Lunch', 'Dinner', 'Snack')),
    ingredients TEXT,
    instructions TEXT,
    calories INT
);

--@block
COPY MealPlanRecipes (meal_plan_id, recipe_name, meal_type, ingredients, instructions, calories)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/mealplanrecipes.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);

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
ORDER BY mp.id, mpr.meal_type;


--@block
CREATE TABLE HydrationLog (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(id),
    date DATE,
    water_liters REAL
);

--@block
COPY HydrationLog (user_id, date, water_liters)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/hydrationlog.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);


--@block
SELECT DISTINCT ON (user_id)
    user_id,
    date,
    water_liters
FROM HydrationLog
ORDER BY user_id, date DESC;


--@block
CREATE TABLE UserGoals (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(id),
    goal_text TEXT NOT NULL,
    target_date DATE,
    status VARCHAR(20) CHECK (status IN ('active', 'achieved', 'abandoned')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--@block
INSERT INTO UserGoals (user_id, goal_text, target_date, status)
SELECT 
    u.id,
    (ARRAY[
        'Lose 5 kg',
        'Run a half marathon',
        'Increase bench press to 100kg',
        'Swim 1km without stopping',
        'Train consistently for 30 days',
        'Improve flexibility with daily stretching',
        'Cycle 500km in one month',
        'Eat balanced meals for 4 weeks',
        'Get 8 hours of sleep daily for a month',
        'Join a local competition'
    ])[1 + FLOOR(RANDOM() * 10)],
    CURRENT_DATE + (FLOOR(RANDOM() * 90) || ' days')::interval,
    (ARRAY['active', 'achieved', 'abandoned'])[1 + FLOOR(RANDOM() * 3)]
FROM Users u
ORDER BY RANDOM()
LIMIT 1000;

--@block
CREATE TABLE WorkoutPlans (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(id),
    plan_name VARCHAR(100),
    plan_type VARCHAR(50) CHECK (plan_type IN ('strength', 'cardio', 'flexibility', 'balance')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--@block
COPY WorkoutPlans (user_id, plan_name, plan_type, created_at)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/workoutplans.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);

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
LIMIT 30;

--@block
CREATE TABLE WorkoutExercises (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    muscle_group VARCHAR(50),
    equipment_required VARCHAR(100),
    difficulty_level VARCHAR(20)
);

--@block
COPY WorkoutExercises (name, description, muscle_group, equipment_required, difficulty_level)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/workoutexercises.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);


--@block
SELECT 
    difficulty_level,
    COUNT(*) AS exercise_count
FROM WorkoutExercises
GROUP BY difficulty_level
ORDER BY exercise_count DESC;

--@block
CREATE TABLE Coaches (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    specialization TEXT,
    email VARCHAR(255) UNIQUE
);
--@block
COPY Coaches (name, specialization, email)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/coaches.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);


--@block
CREATE TABLE UserCoaches (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(id),
    coach_id INT REFERENCES Coaches(id),
    assigned_date DATE DEFAULT CURRENT_DATE
);
--@block
COPY UserCoaches (user_id, coach_id, assigned_date)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/user_coaches.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);

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
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(id),
    tracking_date DATE DEFAULT CURRENT_DATE,
    weight_kg DECIMAL(5,2),
    body_fat_percentage DECIMAL(4,2),
    muscle_mass_kg DECIMAL(5,2),
    resting_heart_rate INT,
    daily_steps INT,
    calories_burned INT,
    workout_minutes INT,
    sleep_hours DECIMAL(3,1),
    mood_rating INT CHECK (mood_rating BETWEEN 1 AND 5),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--@block
INSERT INTO ProgressTracking (
    user_id, 
    tracking_date, 
    weight_kg, 
    body_fat_percentage, 
    muscle_mass_kg, 
    resting_heart_rate, 
    daily_steps, 
    calories_burned, 
    workout_minutes, 
    sleep_hours, 
    mood_rating, 
    notes
)
SELECT
    (i % 1000) + 1 AS user_id,
    CURRENT_DATE - (i % 365) AS tracking_date,
    ROUND((70 + (RANDOM() * 30) - (RANDOM() * 5 * (i % 30)/30))::numeric, 2) AS weight_kg,
    ROUND((15 + (RANDOM() * 15) - (RANDOM() * 3 * (i % 30)/30))::numeric, 2) AS body_fat_percentage,
    ROUND((30 + (RANDOM() * 20) + (RANDOM() * 2 * (i % 30)/30))::numeric, 2) AS muscle_mass_kg,
    (50 + (i % 30))::INT AS resting_heart_rate,
    (3000 + (RANDOM() * 12000))::INT AS daily_steps,
    (1800 + (RANDOM() * 1500))::INT AS calories_burned,
    (20 + (RANDOM() * 120))::INT AS workout_minutes,
    ROUND((5.5 + (RANDOM() * 4))::numeric, 1) AS sleep_hours,
    (1 + (i % 5))::INT AS mood_rating,
    CASE 
        WHEN i % 5 = 0 THEN 'Felt great during workout'
        WHEN i % 5 = 1 THEN 'Recovery day, took it easy'
        WHEN i % 5 = 2 THEN 'Increased weights today'
        WHEN i % 5 = 3 THEN 'Struggled with energy levels'
        ELSE 'Consistent performance'
    END AS notes
FROM generate_series(1, 1000) AS i;
--@block
SELECT DISTINCT ON (user_id)
    user_id,
    tracking_date,
    weight_kg,
    body_fat_percentage,
    muscle_mass_kg,
    resting_heart_rate,
    daily_steps,
    calories_burned,
    workout_minutes,
    sleep_hours,
    mood_rating,
    notes,
    created_at
FROM ProgressTracking
ORDER BY user_id, tracking_date DESC;



--@block
CREATE TABLE UserChallenges (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(id),
    challenge_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    status VARCHAR(50) CHECK (status IN ('In Progress', 'Completed', 'Failed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--@block
INSERT INTO UserChallenges (user_id, challenge_name, start_date, end_date, status, created_at)
SELECT 
    (i % 1000) + 1 AS user_id,  
    (ARRAY['30 Day Fitness Challenge', '10k Steps a Day', 'No Sugar Challenge', 'Strength Training Program', 'Yoga Flexibility Challenge'])[1 + FLOOR(RANDOM() * 5)] AS challenge_name,
    CURRENT_DATE - (i % 365) AS start_date,  
    CURRENT_DATE - (i % 365) + INTERVAL '30 days' AS end_date, -- setting end_date 30 days after the start_date
    (ARRAY['In Progress', 'Completed', 'Failed'])[1 + FLOOR(RANDOM() * 3)] AS status,
    CURRENT_TIMESTAMP AS created_at
FROM generate_series(1, 1000) AS i;
 
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
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(id),
    measurement_date DATE NOT NULL,
    weight_kg NUMERIC(5,2),
    height_cm NUMERIC(5,2),
    waist_cm NUMERIC(5,2),
    body_fat_percent NUMERIC(4,2),
    UNIQUE(user_id, measurement_date)
);

--@block
COPY BodyMeasurements(user_id, measurement_date, weight_kg, height_cm, waist_cm, body_fat_percent)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/body_measurements.csv'
DELIMITER ','
CSV HEADER;

--@block
SELECT DISTINCT ON (user_id)
    user_id,
    measurement_date,
    weight_kg,
    height_cm,
    waist_cm,
    body_fat_percent
FROM BodyMeasurements
ORDER BY user_id, measurement_date DESC;

--@block
CREATE TABLE UserInjuries (
id SERIAL PRIMARY KEY,
user_id INT REFERENCES Users(id),
injury_type VARCHAR(100),
injury_description TEXT,
date_injured DATE,
recovery_status VARCHAR(50) CHECK (recovery_status IN ('In Progress', 'Recovered', 'Not Started')),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--@block
INSERT INTO UserInjuries (user_id, injury_type, injury_description, date_injured, recovery_status)
SELECT
(i % 1000) + 1 AS user_id,
(ARRAY['Knee', 'Ankle', 'Back', 'Shoulder', 'Wrist', 'Elbow'])[1 + FLOOR(RANDOM() * 6)] AS injury_type,
(ARRAY['Sprain', 'Fracture', 'Tendinitis', 'Strain', 'Dislocation'])[1 + FLOOR(RANDOM() * 5)] AS injury_description,
CURRENT_DATE - (i % 365) AS date_injured,
(ARRAY['In Progress', 'Recovered', 'Not Started'])[1 + FLOOR(RANDOM() * 3)] AS recovery_status
FROM generate_series(1, 1000) AS i;
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
id SERIAL PRIMARY KEY,
user_id INT REFERENCES Users(id),
device_name VARCHAR(100) NOT NULL,
device_type VARCHAR(50),
registered_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
is_active BOOLEAN DEFAULT TRUE
); 
--@block
COPY UserDevices(user_id, device_name, device_type, registered_on, is_active)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/user_devices.csv'
DELIMITER ','
CSV HEADER;

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
    payment_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    payment_type TEXT CHECK (payment_type IN ('salary', 'bonus', 'reimbursement', 'other')) NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method TEXT CHECK (payment_method IN ('bank transfer', 'check', 'cash', 'digital wallet')) NOT NULL,
    description VARCHAR(255),
    status TEXT CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')) DEFAULT 'pending',
    transaction_reference VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_by INT,
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (processed_by) REFERENCES Users(id)
);
--@block
COPY Payments(user_id, payment_type, amount, payment_date, payment_method, description, status, transaction_reference, created_at, processed_by)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/payments_1000.csv'
DELIMITER ','
CSV HEADER;

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
    bonus_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    bonus_type TEXT CHECK (bonus_type IN ('performance', 'referral', 'holiday', 'retention', 'other')) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    awarded_date DATE NOT NULL,
    payment_status TEXT CHECK (payment_status IN ('pending', 'paid', 'cancelled')) DEFAULT 'pending',
    approved_by INT,
    processed_by INT,
    payment_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (approved_by) REFERENCES Users(id),
    FOREIGN KEY (processed_by) REFERENCES Users(id),
    FOREIGN KEY (payment_id) REFERENCES Payments(payment_id)
);
--@block
COPY Bonuses(user_id, bonus_type, amount, reason, awarded_date, payment_status, approved_by, processed_by, payment_id)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/bonuses_1000.csv'
DELIMITER ','
CSV HEADER;

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
    payroll_id SERIAL PRIMARY KEY,
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
    status TEXT CHECK (status IN ('draft', 'processed', 'paid', 'cancelled')) DEFAULT 'draft',
    processed_at TIMESTAMP,
    processed_by INT,
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (payment_id) REFERENCES Payments(payment_id),
    FOREIGN KEY (processed_by) REFERENCES Users(id)
);

--@block
COPY Payroll(user_id, pay_period_start, pay_period_end, base_salary, hours_worked, overtime_hours, overtime_pay, bonus_total, deductions, tax_amount, net_pay, payment_id, status, processed_at, processed_by, notes)
FROM '/ProgramData/MySQL/MySQL Server 8.0/Uploads/payroll_1000.csv'
DELIMITER ','
CSV HEADER;

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











    





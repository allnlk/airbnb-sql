--@block
DROP TABLE IF EXISTS users, Achievements, NutritionLog, SportEvents, Sports, TrainingSessions, UserSports, Achievements, TrainingSessions,
-- @block
CREATE TABLE Users(
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    bio TEXT,
    country VARCHAR(2)
);

-- @block
INSERT INTO Users (email, bio, country)
SELECT 
    CONCAT(
        LOWER(
            CONCAT(
                ELT(FLOOR(1 + RAND() * 20), 
                    'john', 'mike', 'david', 'alex', 'chris', 
                    'emma', 'sarah', 'lisa', 'anna', 'olga',
                    'ivan', 'petro', 'andrii', 'serhii', 'vitalii',
                    'maria', 'natalia', 'oksana', 'tetiana', 'yulia'
                ),
                ELT(FLOOR(1 + RAND() * 10), '', '.', '_', '-', '.', '_', '-', '.', '_', '-'),
                ELT(FLOOR(1 + RAND() * 20), 
                    'smith', 'johnson', 'williams', 'brown', 'jones',
                    'miller', 'davis', 'wilson', 'anderson', 'thomas',
                    'kovalenko', 'petrenko', 'sydorenko', 'bondarenko', 'kravchenko',
                    'melnyk', 'shevchenko', 'boyko', 'tkachenko', 'kovalchuk'
                ),
                FLOOR(RAND() * 1000),  
                UNIX_TIMESTAMP()       
            )
        ),
        '@',
        ELT(FLOOR(1 + RAND() * 10), 
            'gmail.com', 'yahoo.com', 'outlook.com', 'icloud.com', 'protonmail.com',
            'ukr.net', 'i.ua', 'meta.ua', 'mail.com', 'hotmail.com'
        )
    ) AS email,
    
    CONCAT(
        ELT(FLOOR(1 + RAND() * 5), 'Professional', 'Amateur', 'Former', 'Olympic', 'National'),
        ' ',
        ELT(FLOOR(1 + RAND() * 20), 
            'football', 'basketball', 'tennis', 'swimming', 'volleyball',
            'athletics', 'boxing', 'cycling', 'gymnastics', 'hockey',
            'skiing', 'snowboarding', 'figure skating', 'biathlon', 'weightlifting',
            'judo', 'karate', 'wrestling', 'archery', 'fencing'
        ),
        ' ',
        ELT(FLOOR(1 + RAND() * 5), 'player', 'athlete', 'competitor', 'champion', 'coach'),
        ' from ',
        ELT(FLOOR(1 + RAND() * 10), 
            'US', 'Ukraine', 'Canada', 'UK', 'Germany',
            'France', 'Japan', 'India', 'Brazil', 'Australia'
        ),
        '. ',
        CASE 
            WHEN RAND() < 0.3 THEN CONCAT('Specializes in ', ELT(FLOOR(1 + RAND() * 10), 
                'tactics', 'endurance training', 'speed development', 'team strategies', 
                'technical skills', 'mental preparation', 'nutrition planning', 
                'recovery techniques', 'injury prevention', 'competition analysis'))
            WHEN RAND() < 0.6 THEN CONCAT('Currently training for ', ELT(FLOOR(1 + RAND() * 5), 
                'Olympics', 'World Championship', 'National Cup', 'Regional Tournament', 'Charity Event'))
            ELSE CONCAT('Former member of ', ELT(FLOOR(1 + RAND() * 10), 
                'national team', 'professional league', 'university team', 
                'youth academy', 'military sports club', 'private training center',
                'elite sports program', 'international federation', 
                'regional association', 'local sports community'))
        END
    ) AS bio,
    
    ELT(FLOOR(1 + RAND() * 10), 'US', 'UA', 'CA', 'GB', 'DE', 'FR', 'JP', 'IN', 'BR', 'AU') AS country
FROM 
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION 
     SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) AS t1,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION 
     SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) AS t2,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION 
     SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) AS t3
LIMIT 1000; 
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

-- @block
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

-- @block
INSERT INTO Achievements (user_id, title, description, date_achieved)
SELECT 
    u.id,
    CASE 
        WHEN RAND() < 0.3 THEN CONCAT(ELT(FLOOR(1 + RAND() * 5), 'Gold', 'Silver', 'Bronze', 'Regional', 'National'), ' Champion')
        WHEN RAND() < 0.6 THEN CONCAT('Best ', ELT(FLOOR(1 + RAND() * 5), 'Player', 'Scorer', 'Defender', 'All-rounder', 'Rookie'))
        ELSE CONCAT(ELT(FLOOR(1 + RAND() * 5), 'Tournament', 'League', 'Cup', 'Championship', 'Competition'), ' Winner')
    END,
    CONCAT('Achieved in ', ELT(FLOOR(1 + RAND() * 10), 'US', 'Ukraine', 'Canada', 'UK', 'Germany', 'France', 'Japan', 'India', 'Brazil', 'Australia')),
    DATE_SUB(CURRENT_DATE, INTERVAL FLOOR(RAND() * 3650) DAY)
FROM Users u
ORDER BY RAND()
LIMIT 1000; 

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

-- @block
INSERT INTO TrainingSessions (user_id, sport_id, duration_minutes, calories_burned, session_date)
SELECT
    id,
    FLOOR(1 + RAND() * 20),  
    FLOOR(30 + RAND() * 150),  
    FLOOR(200 + RAND() * 800),  
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 180) DAY) 
FROM Users
WHERE id <= 1000;

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
INSERT INTO SportEvents (name, sport_id, event_date, location, organizer_id)
SELECT
CONCAT (
    COALESCE (ELT (FLOOR(1 + RAND() * 4),
    'Championship', 'Cup', 'Competition ','Festival '), 'Event '),
    COALESCE (ELT (FLOOR(1 + RAND() * 10),
    'football', 'tennis', 'swimming', 'basketball', 'volleyball',
    'boxing', 'athletics' , 'gymnastics', 'hockey', 'baseball'), 'sport')
) AS name,
FLOOR (1 + RAND() * 20) AS sport_id,
DATE_ADD (CURRENT_DATE, INTERVAL FLOOR (30 + RAND() * 330) DAY) AS event_date,
CONCAT (
    ELT (FLOOR(1 + RAND() * 10),
    'New York', 'Kyiv', 'Shanghai', 'Beijing', 'Tokyo',
    'London', 'Dubai', 'Paris', 'Berlin', 'Rome'),
ELT (FLOOR (1 + RAND() * 5),
'Stadium "Dynamo"', 'Sport Complex', 'Aqua Base', 'Pro Field', 'Arena')
) AS location,
FLOOR (1 + RAND() * 1000) AS organizer_id
FROM
(SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) AS t1,
(SELECT 1
UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION
SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) AS t2, (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION
SELECT 6
UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) AS t3
LIMIT 1000;
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

-- @block
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

-- @block
INSERT INTO NutritionLog (user_id, log_date, meal_type, calories, protein_g, carbs_g, fat_g, water_ml, notes)
SELECT 
    u.id,
    DATE_SUB(CURRENT_DATE, INTERVAL FLOOR(RAND() * 30) DAY),
    ELT(FLOOR(1 + RAND() * 6), 'Breakfast', 'Lunch', 'Dinner', 'Snack', 'Pre-Workout', 'Post-Workout'),
    FLOOR(200 + RAND() * 800),
    FLOOR(10 + RAND() * 50),
    FLOOR(20 + RAND() * 100),
    FLOOR(5 + RAND() * 40),
    FLOOR(200 + RAND() * 500),
    CASE 
        WHEN RAND() < 0.5 THEN CONCAT('Meal focused on ', 
               ELT(FLOOR(1 + RAND() * 4), 'recovery', 'energy', 'muscle growth', 'hydration'))
        ELSE NULL
    END
FROM Users u
ORDER BY RAND()
LIMIT 3000;
-- @block
SELECT u.email, nl.log_date, nl.meal_type, nl.calories
FROM NutritionLog nl
JOIN Users u ON nl.user_id = u.id
ORDER BY nl.log_date DESC;
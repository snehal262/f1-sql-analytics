-- ============================================
-- F1 WORLD CHAMPIONSHIP ANALYTICS
-- Dataset: Formula 1 World Championship (1950-2024)
-- Tools: PostgreSQL, pgAdmin
-- ============================================


-- ============================================
-- SECTION 1: DATABASE SETUP
-- ============================================

-- QUERY 1: Create drivers table
-- ============================================
CREATE TABLE drivers (
    driverId INT PRIMARY KEY,
    driverRef VARCHAR(50),
    number VARCHAR(10),
    code VARCHAR(5),
    forename VARCHAR(50),
    surname VARCHAR(50),
    dob DATE,
    nationality VARCHAR(50),
    url VARCHAR(200)
);

-- QUERY 2: Create races table
-- ============================================
CREATE TABLE races (
    raceId INT PRIMARY KEY,
    year INT,
    round INT,
    circuitId INT,
    name VARCHAR(100),
    date DATE,
    time VARCHAR(10),
    url VARCHAR(200),
    fp1_date VARCHAR(20),
    fp1_time VARCHAR(20),
    fp2_date VARCHAR(20),
    fp2_time VARCHAR(20),
    fp3_date VARCHAR(20),
    fp3_time VARCHAR(20),
    quali_date VARCHAR(20),
    quali_time VARCHAR(20),
    sprint_date VARCHAR(20),
    sprint_time VARCHAR(20)
);

-- QUERY 3: Create constructors table
-- ============================================
CREATE TABLE constructors (
    constructorId INT PRIMARY KEY,
    constructorRef VARCHAR(50),
    name VARCHAR(100),
    nationality VARCHAR(50),
    url VARCHAR(200)
);

-- QUERY 4: Create results table
-- ============================================
CREATE TABLE results (
    resultId INT PRIMARY KEY,
    raceId INT,
    driverId INT,
    constructorId INT,
    number VARCHAR(10),
    grid INT,
    position VARCHAR(10),
    positionText VARCHAR(10),
    positionOrder INT,
    points FLOAT,
    laps INT,
    time VARCHAR(20),
    milliseconds VARCHAR(20),
    fastestLap VARCHAR(10),
    rank VARCHAR(10),
    fastestLapTime VARCHAR(20),
    fastestLapSpeed VARCHAR(20),
    statusId INT
);


-- ============================================
-- SECTION 2: BASIC EXPLORATION
-- ============================================

-- QUERY 5: Total number of races and results in the dataset
-- ============================================
SELECT COUNT(*) AS total_races FROM races;
SELECT COUNT(*) AS total_results FROM results;

-- QUERY 6: Preview Lewis Hamilton's driver record
-- ============================================
SELECT * FROM drivers
WHERE surname = 'Hamilton'
AND forename = 'Lewis';


-- ============================================
-- SECTION 3: DRIVER ANALYSIS
-- ============================================

-- QUERY 7: Drivers with the most race entries (all time)
-- ============================================
SELECT
    d.forename,
    d.surname,
    COUNT(r.raceId) AS total_races
FROM drivers AS d
JOIN results AS r ON d.driverId = r.driverId
GROUP BY d.forename, d.surname
HAVING COUNT(r.raceId) > 100
ORDER BY total_races DESC;

-- QUERY 8: All time top points scorers
-- ============================================
SELECT
    d.forename,
    d.surname,
    SUM(r.points) AS total_points
FROM drivers AS d
JOIN results AS r ON d.driverId = r.driverId
GROUP BY d.forename, d.surname
ORDER BY total_points DESC
LIMIT 10;

-- QUERY 9: All time race wins by driver
-- ============================================
SELECT
    d.forename,
    d.surname,
    COUNT(CASE WHEN r.positionOrder = 1 THEN 1 END) AS wins
FROM drivers AS d
JOIN results AS r ON d.driverId = r.driverId
GROUP BY d.forename, d.surname
ORDER BY wins DESC
LIMIT 10;

-- QUERY 10: All time win rate by driver (minimum 10 races entered)
-- Insight: Shows who was most dominant relative to races entered
-- ============================================
WITH race_wins AS (
    SELECT
        d.forename,
        d.surname,
        COUNT(CASE WHEN r.positionOrder = 1 THEN 1 END) AS wins,
        COUNT(r.raceId) AS total_races_entered
    FROM drivers AS d
    JOIN results AS r ON d.driverId = r.driverId
    GROUP BY d.forename, d.surname, d.driverId
),
win_rate AS (
    SELECT
        forename,
        surname,
        wins,
        total_races_entered,
        ROUND((wins * 100.0 / total_races_entered), 1) AS win_percentage
    FROM race_wins
    WHERE total_races_entered >= 10
)
SELECT * FROM win_rate
ORDER BY win_percentage DESC
LIMIT 10;


-- ============================================
-- SECTION 4: SEASON ANALYSIS
-- ============================================

-- QUERY 11: Championship standings by season using RANK
-- Shows every driver ranked by points within their season
-- ============================================
SELECT
    d.forename,
    d.surname,
    ra.year,
    SUM(r.points) AS total_points,
    RANK() OVER (PARTITION BY ra.year ORDER BY SUM(r.points) DESC) AS season_rank
FROM drivers AS d
JOIN results AS r ON d.driverId = r.driverId
JOIN races AS ra ON r.raceId = ra.raceId
GROUP BY d.forename, d.surname, d.driverId, ra.year
ORDER BY ra.year DESC, season_rank;

-- QUERY 12: Championship standings using DENSE_RANK with previous season comparison (LAG)
-- Uses CTE to avoid nesting aggregate inside window function
-- ============================================
WITH season_totals AS (
    SELECT
        d.driverId,
        d.forename,
        d.surname,
        ra.year,
        SUM(r.points) AS total_points
    FROM drivers AS d
    JOIN results AS r ON d.driverId = r.driverId
    JOIN races AS ra ON r.raceId = ra.raceId
    GROUP BY d.driverId, d.forename, d.surname, ra.year
)
SELECT
    forename,
    surname,
    year,
    total_points,
    DENSE_RANK() OVER (PARTITION BY year ORDER BY total_points DESC) AS season_rank,
    LAG(total_points) OVER (PARTITION BY driverId ORDER BY year) AS prev_season_points
FROM season_totals
ORDER BY year DESC, season_rank;

-- QUERY 13: Lewis Hamilton season by season points and ranking
-- Insight: Tracks Hamilton's career progression across all seasons
-- ============================================
WITH hamilton_seasons AS (
    SELECT
        ra.year,
        SUM(r.points) AS season_points
    FROM races AS ra
    JOIN results AS r ON ra.raceId = r.raceId
    JOIN drivers AS d ON d.driverId = r.driverId
    WHERE d.surname = 'Hamilton'
    AND d.forename = 'Lewis'
    GROUP BY ra.year
),
hamilton_ranked AS (
    SELECT
        year,
        season_points,
        RANK() OVER (ORDER BY season_points DESC) AS points_rank
    FROM hamilton_seasons
)
SELECT * FROM hamilton_ranked
ORDER BY year ASC;


-- ============================================
-- SECTION 5: CONSTRUCTOR ANALYSIS
-- ============================================

-- QUERY 14: All time wins by constructor
-- ============================================
SELECT
    c.name AS constructor,
    COUNT(CASE WHEN r.positionOrder = 1 THEN 1 END) AS wins
FROM constructors AS c
JOIN results AS r ON c.constructorId = r.constructorId
GROUP BY c.name
ORDER BY wins DESC
LIMIT 10;

-- QUERY 15: Constructor dominance by era
-- Insight: Shows which team dominated each regulation era
-- ============================================
WITH era_wins AS (
    SELECT
        c.name AS constructor,
        CASE
            WHEN ra.year BETWEEN 1950 AND 1979 THEN 'Early Era (1950-1979)'
            WHEN ra.year BETWEEN 1980 AND 1999 THEN 'Turbo Era (1980-1999)'
            WHEN ra.year BETWEEN 2000 AND 2013 THEN 'V8 Era (2000-2013)'
            WHEN ra.year BETWEEN 2014 AND 2024 THEN 'Hybrid Era (2014-2024)'
        END AS era,
        COUNT(CASE WHEN r.positionOrder = 1 THEN 1 END) AS wins
    FROM constructors AS c
    JOIN results AS r ON c.constructorId = r.constructorId
    JOIN races AS ra ON r.raceId = ra.raceId
    GROUP BY c.name, era
),
era_ranked AS (
    SELECT
        constructor,
        era,
        wins,
        RANK() OVER (PARTITION BY era ORDER BY wins DESC) AS era_rank
    FROM era_wins
    WHERE era IS NOT NULL
)
SELECT * FROM era_ranked
WHERE era_rank <= 3
ORDER BY era, era_rank;


-- ============================================
-- SECTION 6: HEAD TO HEAD COMPARISON
-- ============================================

-- QUERY 16: Hamilton vs Verstappen all time head to head stats
-- Insight: Comprehensive comparison of the two greatest modern drivers
-- ============================================
WITH driver_stats AS (
    SELECT
        d.forename,
        d.surname,
        COUNT(CASE WHEN r.positionOrder = 1 THEN 1 END) AS race_wins,
        COUNT(CASE WHEN r.positionOrder <= 3 THEN 1 END) AS podiums,
        COUNT(CASE WHEN r.grid = 1 THEN 1 END) AS pole_positions,
        COUNT(r.raceId) AS races_entered,
        ROUND(AVG(r.positionOrder), 1) AS avg_finish_position
    FROM drivers AS d
    JOIN results AS r ON d.driverId = r.driverId
    WHERE d.forename IN ('Lewis', 'Max')
    AND d.surname IN ('Hamilton', 'Verstappen')
    GROUP BY d.forename, d.surname
),
win_rate AS (
    SELECT
        forename,
        surname,
        race_wins,
        podiums,
        pole_positions,
        races_entered,
        avg_finish_position,
        ROUND((race_wins * 100.0 / races_entered), 1) AS win_percentage
    FROM driver_stats
)
SELECT * FROM win_rate
ORDER BY race_wins DESC;

-- ============================================
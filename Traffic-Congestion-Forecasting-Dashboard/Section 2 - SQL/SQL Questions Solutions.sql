USE traffic_capstone;

-- Question 1: Design relational tables for sensor data (traffic volume, vehicle type, location).

-- Step 1 — Create Sensor Table
CREATE TABLE sensors (
    sensor_id VARCHAR(20) PRIMARY KEY,
    location VARCHAR(50),
    road_segment VARCHAR(100),
    segment_type VARCHAR(30)
);

-- Step 2 — Insert Unique Sensor Data
INSERT INTO sensors (sensor_id, location, road_segment, segment_type)
SELECT DISTINCT
    Sensor_ID,
    Location,
    Road_Segment,
    Segment_Type
FROM traffic_data;

-- Step 3 — Create Vehicle Table
CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_type VARCHAR(20)
);

-- Step 4 — Insert Vehicle Types
INSERT INTO vehicles (vehicle_type)
SELECT DISTINCT Vehicle_Type
FROM traffic_data;

-- Step 5 — Create Traffic Volume Table
CREATE TABLE traffic_volume (
    traffic_id INT AUTO_INCREMENT PRIMARY KEY,
    sensor_id VARCHAR(20),
    vehicle_type VARCHAR(20),
    traffic_volume INT,
    avg_speed DOUBLE,
    congestion_ratio DOUBLE,
    congestion_level VARCHAR(20),
    timestamp DATETIME,
    FOREIGN KEY (sensor_id)
        REFERENCES sensors (sensor_id)
);

-- Step 6 — Insert Data into Traffic Volume Table
INSERT INTO traffic_volume (
    sensor_id,
    vehicle_type,
    traffic_volume,
    avg_speed,
    congestion_ratio,
    congestion_level,
    timestamp
)
SELECT
    Sensor_ID,
    Vehicle_Type,
    Traffic_Volume,
    Avg_Speed_kmph,
    Congestion_Ratio,
    Congestion_Level,
    Timestamp
FROM traffic_data;

-- Step 7 — Verify Tables
SELECT * FROM sensors LIMIT 5;

SELECT * FROM vehicles LIMIT 5;

SELECT * FROM traffic_volume LIMIT 5;

-- Question 2: Aggregate traffic counts by location and time

-- Query 1 — Total Traffic by Location
SELECT 
    Location, SUM(Traffic_Volume) AS Total_Traffic
FROM
    traffic_data
GROUP BY Location
ORDER BY Total_Traffic DESC;

-- Query 2 — Hourly Traffic Trend
SELECT 
    Hour, SUM(Traffic_Volume) AS Total_Traffic
FROM
    traffic_data
GROUP BY Hour
ORDER BY Hour;

-- Query 3 — Traffic by Location and Hour
SELECT 
    Location, Hour, SUM(Traffic_Volume) AS Total_Traffic
FROM
    traffic_data
GROUP BY Location , Hour
ORDER BY Location , Hour;

-- Question 3: Use window functions (ROW_NUMBER, LAG) to calculate congestion trends

-- Query 1 — ROW_NUMBER()
SELECT 
    Location,
    Hour,
    Traffic_Volume,

    ROW_NUMBER() OVER(
        PARTITION BY Location
        ORDER BY Traffic_Volume DESC
    ) AS Traffic_Rank

FROM traffic_data;

-- Query 2 — LAG()
SELECT 
    Location,
    Hour,
    Traffic_Volume,

    LAG(Traffic_Volume, 1)
    OVER(
        PARTITION BY Location
        ORDER BY Hour
    ) AS Previous_Hour_Traffic

FROM traffic_data;

-- Query 3 — Traffic Difference Trend
SELECT 
    Location,
    Hour,
    Traffic_Volume,

    LAG(Traffic_Volume, 1)
    OVER(
        PARTITION BY Location
        ORDER BY Hour
    ) AS Previous_Traffic,

    Traffic_Volume -
    LAG(Traffic_Volume, 1)
    OVER(
        PARTITION BY Location
        ORDER BY Hour
    ) AS Traffic_Change

FROM traffic_data;

-- Question 4: Create stored procedures to automate daily traffic summaries

-- Step 1 — Create Stored Procedure
DELIMITER $$

CREATE PROCEDURE daily_traffic_summary()

BEGIN

    SELECT
        Date,
        Location,
        SUM(Traffic_Volume) AS Total_Traffic,
        ROUND(AVG(Avg_Speed_kmph), 2) AS Average_Speed

    FROM traffic_data

    GROUP BY Date, Location

    ORDER BY Date, Total_Traffic DESC;

END $$

DELIMITER ;

-- Step 2 — Run the Procedure
CALL daily_traffic_summary();

-- Step 3 — Check Stored Procedure
SHOW PROCEDURE STATUS
WHERE Db = 'traffic_capstone';

-- Question 5: Write complex joins to combine sensor data with weather conditions

-- Query 1 — Join Sensors with Traffic Data
SELECT 
    s.sensor_id,
    s.location,
    s.road_segment,
    t.vehicle_type,
    t.traffic_volume,
    td.Weather,
    td.Weather_Severity
FROM
    sensors s
        JOIN
    traffic_volume t ON s.sensor_id = t.sensor_id
        JOIN
    traffic_data td ON t.timestamp = td.Timestamp
        AND t.sensor_id = td.Sensor_ID
LIMIT 20;

-- Query 2 — Analyze Traffic During Different Weather Conditions
SELECT 
    td.Weather,
    td.Location,
    SUM(td.Traffic_Volume) AS Total_Traffic,
    ROUND(AVG(td.Congestion_Ratio), 2) AS Avg_Congestion
FROM
    traffic_data td
GROUP BY td.Weather , td.Location
ORDER BY Avg_Congestion DESC;

-- Query 3 — Weather Impact on Average Speed
SELECT 
    Weather, ROUND(AVG(Avg_Speed_kmph), 2) AS Average_Speed
FROM
    traffic_data
GROUP BY Weather
ORDER BY Average_Speed;

-- Question 6: Use CASE statements for congestion classification

-- Query 1 — Congestion Classification using Congestion Ratio
SELECT 
    Location,
    Traffic_Volume,
    Congestion_Ratio,
    CASE
        WHEN Congestion_Ratio < 3 THEN 'Low Congestion'
        WHEN Congestion_Ratio BETWEEN 3 AND 6 THEN 'Medium Congestion'
        ELSE 'High Congestion'
    END AS Congestion_Status
FROM
    traffic_data;
    
-- Query 2 — Traffic Density Classification
SELECT 
    Location,
    Traffic_Volume,
    CASE
        WHEN Traffic_Volume < 100 THEN 'Low Traffic'
        WHEN Traffic_Volume BETWEEN 100 AND 250 THEN 'Moderate Traffic'
        ELSE 'Heavy Traffic'
    END AS Traffic_Category
FROM
    traffic_data;
    
-- Query 3 — Peak vs Off-Peak Classification
SELECT 
    Hour,
    Traffic_Volume,
    CASE
        WHEN
            Hour BETWEEN 7 AND 10
                OR Hour BETWEEN 17 AND 20
        THEN
            'Peak Hour'
        ELSE 'Off-Peak Hour'
    END AS Time_Category
FROM
    traffic_data;
    
-- Question 7: Optimize query performance using indexes

-- Query 1 — Create Index on Location
CREATE INDEX idx_location
ON traffic_data(Location);

-- Query 2 — Create Index on Timestamp
CREATE INDEX idx_timestamp
ON traffic_data(Timestamp);

-- Query 3 — Create Composite Index
CREATE INDEX idx_location_hour
ON traffic_data(Location, Hour);

-- Query 4 — Check Indexes
SHOW INDEX FROM traffic_data;

-- Question 8: Use GROUP BY and HAVING clauses for hourly congestion reports

-- Query 1 — Average Congestion by Hour
SELECT 
    Hour, ROUND(AVG(Congestion_Ratio), 2) AS Avg_Congestion
FROM
    traffic_data
GROUP BY Hour
ORDER BY Hour;

-- Query 2 — High Congestion Hours using HAVING
SELECT 
    Hour, ROUND(AVG(Congestion_Ratio), 2) AS Avg_Congestion
FROM
    traffic_data
GROUP BY Hour
HAVING AVG(Congestion_Ratio) > 5
ORDER BY Avg_Congestion DESC;

-- Query 3 — Congestion Report by Location and Hour
SELECT 
    Location,
    Hour,
    ROUND(AVG(Congestion_Ratio), 2) AS Avg_Congestion,
    SUM(Traffic_Volume) AS Total_Traffic
FROM
    traffic_data
GROUP BY Location , Hour
HAVING AVG(Congestion_Ratio) > 4
ORDER BY Location , Avg_Congestion DESC;

-- Question 9: Create SQL views for reusable traffic density analysis

-- Query 1 — Create Traffic Density View
CREATE VIEW traffic_density_view AS
    SELECT 
        Location,
        Road_Segment,
        ROUND(AVG(Traffic_Volume), 2) AS Avg_Traffic,
        ROUND(AVG(Congestion_Ratio), 2) AS Avg_Congestion
    FROM
        traffic_data
    GROUP BY Location , Road_Segment;
    
-- Query 2 — Use the View
SELECT 
    *
FROM
    traffic_density_view
ORDER BY Avg_Congestion DESC;

-- Query 3 — Create Peak Hour Analysis View
CREATE VIEW peak_hour_view AS
    SELECT 
        Location,
        Hour,
        SUM(Traffic_Volume) AS Total_Traffic,
        ROUND(AVG(Congestion_Ratio), 2) AS Avg_Congestion
    FROM
        traffic_data
    GROUP BY Location , Hour;
    
-- Query 4 — Use Peak Hour View
SELECT 
    *
FROM
    peak_hour_view
WHERE
    Avg_Congestion > 5
ORDER BY Total_Traffic DESC;

-- Query 5 — Check Views
SHOW FULL TABLES
WHERE TABLE_TYPE = 'VIEW';

-- Question 10: Export SQL query results into CSV format for Python analysis
SELECT 
    *
FROM
    traffic_data;
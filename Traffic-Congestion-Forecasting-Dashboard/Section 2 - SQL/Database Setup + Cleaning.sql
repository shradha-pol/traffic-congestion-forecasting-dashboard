CREATE DATABASE traffic_capstone; 
USE traffic_capstone;

-- Check whether import worked
SELECT 
    *
FROM
    traffic_data
LIMIT 10;

-- Check columns
DESCRIBE traffic_data;

-- Fix Date column
UPDATE traffic_data
SET Date = STR_TO_DATE(Date, '%m/%d/%Y');

-- Change datatype
ALTER TABLE traffic_data
MODIFY Date DATE;

-- Fix Timestamp
UPDATE traffic_data
SET Timestamp = STR_TO_DATE(Timestamp, '%m/%d/%Y %H:%i');

-- Change datatype
ALTER TABLE traffic_data
MODIFY Timestamp DATETIME;

SELECT Date, Timestamp
FROM traffic_data
LIMIT 5;

ALTER TABLE traffic_data
MODIFY Sensor_ID VARCHAR(20),
MODIFY Day_Name VARCHAR(15),
MODIFY Month VARCHAR(10),
MODIFY Peak_Period VARCHAR(20),
MODIFY Location VARCHAR(50),
MODIFY Road_Segment VARCHAR(100),
MODIFY Segment_Type VARCHAR(30),
MODIFY Vehicle_Type VARCHAR(20),
MODIFY Weather VARCHAR(20),
MODIFY Congestion_Level VARCHAR(20),
MODIFY Hour_Label VARCHAR(20),
MODIFY Is_Weekend VARCHAR(5);

-- Fixed Hour Time

ALTER TABLE traffic_data
MODIFY Hour_Time TIME;

-- PrimaryKey added

ALTER TABLE traffic_data
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

DESCRIBE traffic_data;



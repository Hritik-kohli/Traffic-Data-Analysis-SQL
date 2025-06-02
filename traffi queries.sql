create database trfc;
use trfc;
select * from traffic_incidents;
select * from locations;
select * from vehicle_info;

ALTER TABLE locations ADD PRIMARY KEY (Location_ID);

ALTER TABLE vehicle_info ADD PRIMARY KEY (Vehicle_ID);

ALTER TABLE traffic_incidents ADD PRIMARY KEY (Incident_ID);

ALTER TABLE traffic_incidents
ADD CONSTRAINT fk_location FOREIGN KEY (Location_ID) REFERENCES locations(Location_ID);

ALTER TABLE traffic_incidents
ADD CONSTRAINT fk_vehicle FOREIGN KEY (Vehicle_ID) REFERENCES vehicle_info(Vehicle_ID);

-- Total Fine Collected by Violation Type 
SELECT Violation_Type, SUM(Fine_Amount) AS Total_Fines
FROM traffic_incidents
GROUP BY Violation_Type
ORDER BY Total_Fines DESC;
-- Count of Incidents per Vehicle Type
SELECT v.Vehicle_Type, COUNT(*) AS Incident_Count
FROM traffic_incidents t
JOIN vehicle_info v ON t.Vehicle_ID = v.Vehicle_ID
GROUP BY v.Vehicle_Type;
-- List Top 3 Streets with Most Incidents 
SELECT l.Street_Name, COUNT(*) AS Incident_Count
FROM traffic_incidents t
JOIN locations l ON t.Location_ID = l.Location_ID
GROUP BY l.Street_Name
ORDER BY Incident_Count DESC
LIMIT 3;
-- Average Fine Amount for Each Neighborhood 
SELECT l.Neighborhood, AVG(t.Fine_Amount) AS Avg_Fine
FROM traffic_incidents t
JOIN locations l ON t.Location_ID = l.Location_ID
GROUP BY l.Neighborhood;
-- All DUI Cases with Vehicle and Street Details
SELECT t.Date, v.Vehicle_Type, l.Street_Name, t.Fine_Amount
FROM traffic_incidents t
JOIN vehicle_info v ON t.Vehicle_ID = v.Vehicle_ID
JOIN locations l ON t.Location_ID = l.Location_ID
WHERE t.Violation_Type = 'DUI';
-- Find Vehicles Involved in Multiple Violations
SELECT Vehicle_ID, COUNT(*) AS Violation_Count
FROM traffic_incidents
GROUP BY Vehicle_ID
HAVING COUNT(*) > 1;
-- Rank Streets by Average Fine (Using Window Function)
SELECT Street_Name, AVG(Fine_Amount) AS Avg_Fine,
       RANK() OVER (ORDER BY AVG(Fine_Amount) DESC) AS Fine_Rank
FROM traffic_incidents t
JOIN locations l ON t.Location_ID = l.Location_ID
GROUP BY Street_Name;
-- Monthly Trend of Total Fines
SELECT DATE_TRUNC('month', Date) AS Month, SUM(Fine_Amount) AS Total_Fines
FROM traffic_incidents
GROUP BY DATE_TRUNC('month', Date)
ORDER BY Month;
-- Neighborhoods with More Than One Type of Violation
SELECT Neighborhood, COUNT(DISTINCT Violation_Type) AS Violation_Types
FROM traffic_incidents t
JOIN locations l ON t.Location_ID = l.Location_ID
GROUP BY Neighborhood
HAVING COUNT(DISTINCT Violation_Type) > 1;
-- Most Common Violation Per Street (Using Subquery)
SELECT Street_Name, Violation_Type, CountPerStreet
FROM (
    SELECT l.Street_Name, t.Violation_Type,
           COUNT(*) AS CountPerStreet,
           ROW_NUMBER() OVER (PARTITION BY l.Street_Name ORDER BY COUNT(*) DESC) AS rn
    FROM traffic_incidents t
    JOIN locations l ON t.Location_ID = l.Location_ID
    GROUP BY l.Street_Name, t.Violation_Type
) ranked
WHERE rn = 1;
   


 

USE flights;
ALTER TABLE flights MODIFY COLUMN Date_of_Journey DATETIME;

-- Q. Month with most number of flights

SELECT MONTHNAME(date_of_journey),COUNT(*) FROM flights
GROUP BY MONTHNAME(date_of_journey) ORDER BY COUNT(*) DESC LIMIT 1;

-- Q. weekday with most costly flights

SELECT DAYNAME(date_of_journey),AVG(price) FROM flights 
GROUP BY DAYNAME(date_of_journey) ORDER BY AVG(price) DESC;

-- Q Number of indigo flights per month

SELECT monthname(date_of_journey),COUNT(*) FROM finals.flights WHERE Airline= 'Indigo'
GROUP BY monthname(date_of_journey) ;

-- Q.list of flights that depart between 10AM and 2PM from banglore to new delhi 

SELECT * FROM finals.flights 
WHERE Source= 'Banglore' and Destination='New Delhi' and HOUR(Dep_Time) BETWEEN 10 AND 13;

-- Q number of flights departing on weekends from bangalore

SELECT *, DAYNAME(date_of_journey) FROM flights WHERE source='banglore'AND DAYOFWEEK(date_of_journey) IN (7,1);

-- Q calc the arrival time for all flights by adding duration to departure time

ALTER TABLE flights ADD COLUMN departure DATETIME;

UPDATE flights SET departure=
(STR_TO_DATE(CONCAT(date_of_journey,' ',dep_time),'%Y-%m-%d %H:%i'));

ALTER TABLE flights ADD COLUMN duration_mins INTEGER, ADD COLUMN arrival DATETIME;



UPDATE flights
SET duration_mins = REPLACE(SUBSTRING_INDEX(duration,' ',1),'h','')*60 + 
CASE
	WHEN SUBSTRING_INDEX(duration,' ',-1) = SUBSTRING_INDEX(duration,' ',1) THEN 0
    ELSE REPLACE(SUBSTRING_INDEX(duration,' ',-1),'m','')
END;

SELECT * FROM flights;

UPDATE flights
SET arrival = DATE_ADD(departure,INTERVAL duration_mins MINUTE);

SELECT * FROM flights;

SELECT TIME(arrival) FROM flights;

-- Number of flights which travell on multiple days

SELECT * FROM flights WHERE DAY(departure)!= DAY(arrival);

-- Avg DUration of flights bw all city pairs

SELECT Source,Destination,TIME_FORMAT(sec_to_time(AVG(duration_mins)*60),'%kh %im') AS avg_duration FROM flights
GROUP BY Source,Destination  ORDER BY AVG(duration_mins) DESC;

-- quarterwsie number of flights for eac airline

SELECT Airline, QUARTER(departure),COUNT(*)FROM flights
GROUP BY Airline,QUARTER(departure) ORDER BY Airline ;

-- longest flight distance (between cities in terms of time)

SELECT Source,Destination, MAX(duration_mins) FROM flights 
GROUP BY Source,Destination ORDER BY MAX(duration_mins) DESC;

-- avg time duration of flights that have 1 stop vs 1+ stops

WITH temp_df AS (SELECT *,
CASE
   WHEN total_stops= 'non-stop' THEN 'non-stop'
   ELSE 'with stop'
END AS 'temp'
FROM flights  )
SELECT temp,TIME_FORMAT(sec_to_time(AVG(duration_mins)*60),'%kh %im') AS avg_duration, AVG(price)
FROM temp_df
GROUP BY temp;

-- air india flights from Delhi in a give data range

SELECT * FROM flights WHERE Airline='Air India' AND Source='Delhi'
 AND departure BETWEEN '2019-03-27' AND '2019-05-09';
 
 -- longest flight of each airline
 
 SELECT Airline,TIME_FORMAT(sec_to_time(MAX(duration_mins)*60),'%kh %im') AS avg_duration 
 FROM flights GROUP BY Airline ORDER BY MAX(duration_mins) DESC;
 
 -- pairs of cities having average time duration> 3 hours
 
SELECT source,destination,TIME_FORMAT(sec_to_time(AVG(duration_mins)*60),'%kh %im') AS avg_duration  FROM flights
GROUP BY Source,Destination HAVING AVG(duration_mins)>180 ORDER BY AVG(duration_mins);

-- weekday vs time grid showing freq of flights from Banglore to Delhi 

SELECT DAYNAME(departure),
SUM(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN 1 ELSE 0 END) AS '12AM to 6AM',
SUM(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN 1 ELSE 0 END) AS '6AM to 12AM',
SUM(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN 1 ELSE 0 END) AS '12PM to 6PM',
SUM(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN 1 ELSE 0 END) AS '6PM to 12PM' FROM flights
WHERE source='Banglore' AND destination= 'Delhi'
GROUP BY DAYNAME(departure) ORDER BY DAYOFWEEK(departure);

-- weekday vs time grid showing price of flights from Banglore to Delhi

SELECT DAYNAME(departure),
AVG(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN price ELSE NULL END) AS '12AM to 6AM',
avg(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN price ELSE NULL END) AS '6AM to 12AM',
AVG(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN price ELSE NULL END) AS '12PM to 6PM',
AVG(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN price ELSE NULL END) AS '6PM to 12PM' FROM flights
WHERE source='Banglore' AND destination= 'Delhi'
GROUP BY DAYNAME(departure) ORDER BY DAYOFWEEK(departure)
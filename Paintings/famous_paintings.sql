-- Identify the museums which are open on both Sunday and Monday. Display museum name, city
SELECT * FROM product_size

SELECT m.name, m.city
FROM museum AS m
JOIN museum_hours AS m_h
ON m.museum_id = m_h.museum_id
WHERE m_h.day IN ('Monday', 'Sunday')
GROUP BY m.museum_id, m.name, m.city
HAVING COUNT(DISTINCT m_h.day) = 2;


 -- Which museum is open for the longest during a day. Display museum name, state and hours open and which day?
 SELECT m.name, m.state, mh.day, open, close,
 		 to_timestamp(close, 'HH:MI PM') - to_timestamp(open, 'HH:MI AM') as duration
 FROM museum_hours as mh
 LEFT JOIN museum as m
 ON mh.museum_id = m.museum_id
 ORDER BY 
    duration DESC
LIMIT 1;

-- Fetch all the paintings which are not displayed on any museums?
SELECT w.name
FROM work AS w
LEFT JOIN museum AS m
ON w.museum_id = m.museum_id
WHERE m.museum_id IS NULL;

-- Are there museums without any paintings?
SELECT m.museum_id, m.name
FROM museum AS m
LEFT JOIN work AS w
ON m.museum_id = w.museum_id
WHERE w.work_id IS NULL;

-- How many paintings have an asking price of more than their regular price?
SELECT COUNT(*)
FROM product_size
WHERE sale_price > regular_price

-- Identify the paintings whose asking price is less than 50% of its regular price
SELECT COUNT(*)
FROM product_size
WHERE sale_price < (regular_price/2)

-- Which canva size costs the most?
SELECT c.label , p.regular_price
FROM  product_size AS p
LEFT JOIN canvas_size AS c
ON c.size_id::bigint = c.size_id
ORDER BY p.regular_price DESC
LIMIT 1; 

-- Remove the duplicates from the work table
WITH duplicates AS (
  SELECT MIN(work_id) AS work_id
  FROM work
  GROUP BY name -- Replace with the relevant columns
  HAVING COUNT(*) > 1
)
DELETE FROM work
WHERE work_id NOT IN (SELECT work_id FROM duplicates);


--  Identify the museums with invalid city information in the given dataset
SELECT name
FROM museum
WHERE city ~ '^[0-9]+$';

-- Museum_Hours table has 1 invalid entry. Identify it and remove it.
WITH invalid AS (
  SELECT museum_id
  FROM museum_hours
  WHERE to_timestamp(close, 'HH:MI PM') < to_timestamp(open, 'HH:MI AM')
)
DELETE FROM museum_hours
WHERE museum_id IN (SELECT museum_id FROM invalid);

-- Fetch the top 10 most famous painting subject
WITH subset (subject, popularity) AS (
    SELECT subject, COUNT(*) AS popularity
    FROM subject
    GROUP BY subject
)
SELECT TOP 10 * FROM subset
ORDER BY popularity DESC;


-- How many museums are open every single day?
SELECT COUNT(*) 
FROM(
SELECT museum_id
FROM museum_hours
GROUP BY museum_id
HAVING(COUNT(day)=7))

-- Display the 3 least popular canva sizes
SELECT c.size_id, c.label
FROM product_size AS p
LEFT JOIN canvas_size AS c
ON p.size_id::text = c.size_id::text
GROUP BY c.size_id, c.label
ORDER BY COUNT(*) ASC
LIMIT 3;

-- Which are the top 5 most popular museum? (based on most no of paintings in a museum)
SELECT m.name
FROM museum AS m
LEFT JOIN work AS w
ON m.museum_id = w.museum_id
GROUP BY m.museum_id, m.name
ORDER BY COUNT (w.work_id) DESC
LIMIT 5;

-- Who are the top 5 most popular artist? 
SELECT a.full_name
FROM artist AS a
LEFT JOIN work AS w
ON a.artist_id = w.artist_id 
GROUP BY a.artist_id , a.full_name
ORDER BY COUNT (w.work_id) DESC
LIMIT 5;


-- Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country.
--If there are multiple value, seperate them with comma.

WITH cte_country AS 
	(SELECT country,
	rank() over(ORDER BY COUNT(*) DESC) AS rnk
	FROM museum 
	GROUP BY country),
cte_city AS 
	(SELECT city,
	rank() over(ORDER BY COUNT(*) DESC) AS rnk
	FROM museum 
	GROUP BY city)

SELECT string_agg(DISTINCT(country), ', ') AS country,
	   string_agg(city, ', ') AS city
FROM cte_country
CROSS JOIN cte_city
WHERE cte_country.rnk = 1 AND cte_city.rnk =1







select * from artist
select * from canvas_size
select * from image_link
select * from museum
select * from museum_hours
select * from product_size
select * from subject
select * from work


--Fetch all the paintings which are not displayed on any museums?
select *
from work
where museum_id is null
--Are there museuems without any paintings?
select * from museum m
	where not exists (select * from work w
					 where w.museum_id=m.museum_id);
--How many paintings have an asking price of more than their regular price? 
select COUNT(*) as  number
from product_size
where  regular_price > sale_price

--Identify the paintings whose asking price is less than 50% of its regular price
SELECT *
FROM product_size
WHERE sale_price < (regular_price * 0.5);
 --Which canva size costs the most?
SELECT TOP 1 C.size_id, C.label
FROM product_size AS P
JOIN canvas_size AS C ON CAST(P.size_id AS INT) = CAST(C.size_id AS INT)
ORDER BY P.sale_price DESC;

-- Museum_Hours table has 1 invalid entry. Identify it and remove it.


 ---Fetch the top 10 most famous painting subject
select count (*) as number, subject
from subject
group by subject
order by number desc;
--Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
select count (W.work_id) as number, W.artist_id,A.full_name 
from work as W inner join artist as A   on W.artist_id= A.artist_id
group by  W.artist_id, A.full_name 
order by number  desc ;
--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
--Display the 3 least popular canva sizes
SELECT  count(CAST(C.size_id AS INT)) AS number ,    CAST(C.size_id AS INT), C.label
FROM product_size AS P
JOIN canvas_size AS C ON CAST(P.size_id AS INT) = CAST(C.size_id AS INT)
GROUP BY CAST(C.size_id AS INT), C.label
ORDER BY number ASC;
-- Display the 3 least popular canva sizes
SELECT C.label, P.size_id, count(P.size_id) as number
FROM product_size as P inner join canvas_size  as C on CAST(P.size_id AS INT) = CAST(C.size_id AS INT)
group by C.label, P.size_id
ORDER BY number ASC;
--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
--- Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.
SELECT A.artist_id, A. full_name, M.country, W.museum_id
FROM artist AS A
INNER JOIN work AS W ON A.artist_id = W.artist_id
INNER JOIN museum AS M ON W.museum_id = M.museum_id
WHERE M.country != 'USA' AND A.style = 'Portraitist';

--- Which are the 3 most popular and 3 least popular painting styles? with cte 
with cte as 
( select  top 3 style , count (style) as number
from artist
group by style
order by number desc)

select style , number
from cte;
--Which country has the 5th highest no of paintings? with cte as
 select  M.country , count(W.work_id) AS number
from museum  AS M inner join work as W ON M.museum_id= W.museum_id
group by M.country
order by number desc;
-- second solution
WITH cte AS (
    SELECT M.country, 
           COUNT(W.work_id) AS number, 
           RANK() OVER (ORDER BY COUNT(W.work_id) DESC) AS rnk
    FROM museum AS M 
    INNER JOIN work AS W 
    ON M.museum_id = W.museum_id
    GROUP BY M.country
)
SELECT country, number
FROM cte
WHERE rnk = 2;
-- Display the country and the city with most no of museums. Output 2 seperate columns

WITH cte_country AS (
    SELECT M.country, COUNT(W.work_id) AS number_country,
           RANK() OVER (ORDER BY COUNT(W.work_id) DESC) AS rnk_country
    FROM museum AS M
    INNER JOIN work AS W ON M.museum_id = W.museum_id
    GROUP BY M.country
),
cte_city AS (
    SELECT M.city, COUNT(W.work_id) AS number_city,
           RANK() OVER (ORDER BY COUNT(W.work_id) DESC) AS rnk_city
    FROM museum AS M
    INNER JOIN work AS W ON M.museum_id = W.museum_id
    GROUP BY M.city
)
SELECT 
    (SELECT country FROM cte_country WHERE rnk_country = 1) AS country,
    (SELECT city FROM cte_city WHERE rnk_city = 1) AS city;

---Identify the artist and the museum where the most expensive and least expensive painting is placed.  Display the artist name, sale_price, painting name, museum name, museum city and canvas label
--Display the artist name, sale_price, painting name, museum name, museum city and canvas label

WITH cte AS (
    SELECT 
        P.*,
        RANK() OVER (PARTITION BY P.work_id ORDER BY P.sale_price DESC) AS rnk,
        RANK() OVER (PARTITION BY P.work_id ORDER BY P.sale_price ASC) AS rnk_asc
    FROM product_size AS P
)

SELECT 
    A.full_name AS artist_name,
    W.name AS painting_name,
    M.name AS museum_name,
    M.city AS museum_city,
	cte.rnk, cte.rnk_asc
FROM cte
INNER JOIN work AS W ON cte.work_id = W.work_id
INNER JOIN artist AS A ON W.artist_id = A.artist_id
INNER JOIN museum AS M ON W.museum_id = M.museum_id
WHERE cte.rnk = 1 OR cte.rnk_asc = 1;

--Identify the artists whose paintings are displayed in multiple countries

select M.museum_id, M.country, A.artist_id, A.full_name
from artist as A inner join work AS W on A.artist_id=W.artist_id
INNER JOIN museum AS M ON W.museum_id = M.museum_id
where M.country != 'USA';
--Which museum has the most no of most popular painting style?
-- Step 1: Identify the most popular painting style
WITH popular_style AS (
    SELECT TOP 1 style
    FROM work
    GROUP BY style
    ORDER BY COUNT(*) DESC
)

-- Step 2: Find the museum with the most works in that style
SELECT TOP 1 M.museum_id, M.name AS museum_name, style
FROM work AS W
INNER JOIN museum AS M ON W.museum_id = M.museum_id
WHERE W.style IN (SELECT style FROM popular_style)
GROUP BY M.museum_id, M.name, style
ORDER BY COUNT(*) DESC;

   











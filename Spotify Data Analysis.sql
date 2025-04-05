-- Advanced SQL Project -- Spotify Analysis

-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

SELECT * FROM public.spotify
LIMIT 100;

-- EDA

SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;

SELECT * FROM spotify 
WHERE duration_min = 0;

DELETE FROM spotify 
WHERE duration_min = 0;
SELECT * FROM spotify 
WHERE duration_min = 0;

SELECT DISTINCT channel FROM spotify;

SELECT DISTINCT most_played_on FROM spotify;

--------------------------------
-- EASY LEVEL BUSINESS PROBLEMS:
--------------------------------
-- 1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM spotify
WHERE stream > 1000000000;

-- 2. List all albums along with their respective artists.

SELECT 
	DISTINCT album, artist
FROM spotify
ORDER BY 1;

SELECT 
	DISTINCT album
FROM spotify
ORDER BY 1;

-- 3. Get the total number of comments for tracks where licensed = TRUE.

SELECT 
	SUM(comments) AS total_comments 
FROM spotify
WHERE licensed = 'true';

-- 4. Find all tracks that belong to the album type single.

SELECT * FROM spotify
WHERE album_type = 'single';

-- 5. Count the total number of tracks by each artist.

SELECT 
	artist,
	COUNT(*) AS total_no_songs
FROM spotify
GROUP BY artist
ORDER BY 2;

---------------------------------
-- MEDIUM LEVEL BUSINESS PROBLEMS:
---------------------------------

-- 1. Calculate the average danceability of tracks in each album.

SELECT 
	album,
	AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;

-- 2. Find the top 5 tracks with the highest energy values.

SELECT 
	track,
	MAX(energy) AS max_energy
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 3. List all tracks along with their views and likes where official_video = TRUE.

SELECT 
	track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'true' 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 4. For each album, calculate the total views of all associated tracks.

SELECT
	album,
	track,
	SUM(views)
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5;

-- 5. Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT * FROM 
(SELECT
	track,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as streamed_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) AS streamed_on_spotify
FROM spotify
GROUP BY 1
) AS t1
WHERE 
	streamed_on_spotify > streamed_on_youtube
	AND 
	streamed_on_youtube <> 0;

-- ADVANCED LEVEL BUSINESS PROBLEMS:
-- 1. Find the top 3 most-viewed tracks for each artist using window functions.

--each artists and total view for each track
--track with highest view for each artist (we need top)
--dense rank
--cte and filder rank <=3

WITH ranking_artist
AS
(SELECT
	artist,
	track,
	SUM(views)  AS total_view,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) as rank
FROM spotify
GROUP BY 1, 2
ORDER BY 1, 3 DESC
)
SELECT * FROM ranking_artist
WHERE rank <= 3;

-- 2. Write a query to find tracks where the liveness score is above the average.

SELECT
	track,
	artist,
	liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

-- 3. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

WITH cte
AS
(SELECT
	album,
	MAX(energy) AS highest_energy,
	MIN(energy) AS lowest_energy
FROM spotify
GROUP BY 1
)
SELECT
album,
highest_energy - lowest_energy AS energy_diffrent
FROM cte
ORDER BY 2 DESC;

-- 4. Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT 
    artist,
    track,
    album,
    energy,
    liveness,
    (energy / NULLIF(liveness, 0)) AS energy_liveness_ratio
FROM 
    spotify
WHERE 
    (energy / NULLIF(liveness, 0)) > 1.2
ORDER BY 
    energy_liveness_ratio DESC;

-- 5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT 
    artist,
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views DESC) AS cumulative_likes
FROM 
    spotify
ORDER BY 
    Views DESC;

-- Query Analysis 
EXPLAIN ANALYZE -- et 7.97 ms pt 0.112ms
SELECT
	artist,
	track,
	views
FROM spotify
WHERE artist = 'Gorillaz'
	AND
	most_played_on = 'Youtube'
ORDER BY stream DESC LIMIT 25;

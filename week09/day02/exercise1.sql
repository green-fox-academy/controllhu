--https://lagunita.stanford.edu/courses/DB/SQL/SelfPaced/courseware/ch-sql/seq-exercise-sql_movie_query_core/

/* Create the schema for our tables */
create table Movie(mID int, title text, year int, director text);
create table Reviewer(rID int, name text);
create table Rating(rID int, mID int, stars int, ratingDate date);

/* Populate the tables with our data */
insert into Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into Movie values(102, 'Star Wars', 1977, 'George Lucas');
insert into Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into Movie values(105, 'Titanic', 1997, 'James Cameron');
insert into Movie values(106, 'Snow White', 1937, null);
insert into Movie values(107, 'Avatar', 2009, 'James Cameron');
insert into Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

insert into Reviewer values(201, 'Sarah Martinez');
insert into Reviewer values(202, 'Daniel Lewis');
insert into Reviewer values(203, 'Brittany Harris');
insert into Reviewer values(204, 'Mike Anderson');
insert into Reviewer values(205, 'Chris Jackson');
insert into Reviewer values(206, 'Elizabeth Thomas');
insert into Reviewer values(207, 'James Cameron');
insert into Reviewer values(208, 'Ashley White');

insert into Rating values(201, 101, 2, '2011-01-22');
insert into Rating values(201, 101, 4, '2011-01-27');
insert into Rating values(202, 106, 4, null);
insert into Rating values(203, 103, 2, '2011-01-20');
insert into Rating values(203, 108, 4, '2011-01-12');
insert into Rating values(203, 108, 2, '2011-01-30');
insert into Rating values(204, 101, 3, '2011-01-09');
insert into Rating values(205, 103, 3, '2011-01-27');
insert into Rating values(205, 104, 2, '2011-01-22');
insert into Rating values(205, 108, 4, null);
insert into Rating values(206, 107, 3, '2011-01-15');
insert into Rating values(206, 106, 5, '2011-01-19');
insert into Rating values(207, 107, 5, '2011-01-20');
insert into Rating values(208, 104, 3, '2011-01-02');

-- 1. Find the titles of all movies directed by Steven Spielberg.

SELECT title
FROM Movie
WHERE director = 'Steven Spielberg';


-- 2. Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.

SELECT DISTINCT year
FROM Movie, Rating
WHERE Movie.mId = Rating.mId AND stars IN (4, 5)
ORDER BY year;

-- VAGY

SELECT DISTINCT year
FROM Movie
INNER JOIN Rating ON Movie.mId = Rating.mId
WHERE stars IN (4, 5)
ORDER BY year;

-- VAGY

SELECT DISTINCT year
FROM Movie
INNER JOIN Rating USING(mId)
WHERE stars IN (4, 5)
ORDER BY year;

-- VAGY

SELECT DISTINCT year
FROM Movie NATURAL JOIN Rating
WHERE stars IN (4, 5)
ORDER BY year;


-- 3. Find the titles of all movies that have no ratings. 

SELECT title
FROM Movie
WHERE mId NOT IN (SELECT mID FROM Rating);


-- 4. Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. 

SELECT name
FROM Reviewer
INNER JOIN Rating USING(rId)
WHERE ratingDate IS NULL;


-- 5. Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 

SELECT name, title, stars, ratingDate
FROM Movie, Rating, Reviewer
WHERE Movie.mId = Rating.mId AND Reviewer.rId = Rating.rId
ORDER BY name, title, stars;

-- VAGY

SELECT name, title, stars, ratingDate
FROM Movie
INNER JOIN Rating ON Movie.mId = Rating.mId
INNER JOIN Reviewer ON Reviewer.rId = Rating.rId
ORDER BY name, title, stars;

-- VAGY

SELECT name, title, stars, ratingDate
FROM Movie
INNER JOIN Rating USING(mId)
INNER JOIN Reviewer USING(rId)
ORDER BY name, title, stars;

-- VAGY

SELECT name, title, stars, ratingDate
FROM Movie NATURAL JOIN Rating NATURAL JOIN Reviewer
ORDER BY name, title, stars;


-- 6. For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. 

SELECT name, title
FROM Movie
INNER JOIN Rating R1 USING(mId)
INNER JOIN Rating R2 USING(rId)
INNER JOIN Reviewer USING(rId)
WHERE R1.mId = R2.mId AND R1.ratingDate < R2.ratingDate AND R1.stars < R2.stars;

SELECT name, title
FROM Movie
INNER JOIN Rating R1 USING(mId)
INNER JOIN Rating R2 USING(rId, mId)
INNER JOIN Reviewer USING(rId)
WHERE R1.ratingDate < R2.ratingDate AND R1.stars < R2.stars;


-- 7. For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 

SELECT title, MAX(stars)
FROM Movie
INNER JOIN Rating USING(mId)
GROUP BY mId
ORDER BY title;


-- 8. For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 

SELECT title, (MAX(stars) - MIN(stars)) AS rating_spread
FROM Movie
INNER JOIN Rating USING(mId)
GROUP BY mId
ORDER BY rating_spread DESC, title;


-- 9. Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.) 

SELECT AVG(Before1980.avg) - AVG(After1980.avg)
FROM (
  SELECT AVG(stars) AS avg
  FROM Movie
  INNER JOIN Rating USING(mId)
  WHERE year < 1980
  GROUP BY mId
) AS Before1980, (
  SELECT AVG(stars) AS avg
  FROM Movie
  INNER JOIN Rating USING(mId)
  WHERE year > 1980
  GROUP BY mId
) AS After1980;
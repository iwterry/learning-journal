/*###########################################################################################
	Questions 6 through 12 (skipped #11) for Stanford's online DB course
	See https://lagunita.stanford.edu/courses/DB/SQL/SelfPaced/courseware/ch-sql/seq-exercise-sql_movie_query_extra/ for more info.
############################################################################################## */

/* Question 6: For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name,
movie title, and number of stars. */

SELECT title, name, stars
FROM movie INNER JOIN (
	SELECT mID, rID, stars
	FROM rating
	WHERE stars = ( SELECT MIN(stars) FROM rating )
) AS t1 USING (mID) INNER JOIN reviewer USING (rID);

/* Question 7: List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same
average rating, list them in alphabetical order. */

SELECT title, AVG(stars) AS avg_stars
FROM rating INNER JOIN movie USING (mID)
GROUP BY title
ORDER BY avg_stars DESC, title ASC;

/* Question 8: Find the names of all reviewers who have contributed three or more ratings. */

SELECT name
FROM (
	SELECT rID
	FROM rating
	GROUP BY rID
	HAVING COUNT(*) >= 3
) AS t1 INNER JOIN reviewer USING (rID);

/* Question 9: Some directors directed more than one movie. For all such directors, return the titles of all movies
directed by them, along with the director name. Sort by director name, then movie title. */

SELECT title, director
FROM movie INNER JOIN (
	SELECT director
	FROM movie
	GROUP BY director
	HAVING COUNT(*) > 1
) AS t1 USING (director)
ORDER BY director ASC, title ASC;

/* Question 10: Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. */

SELECT title, avg_stars1, max_avg_stars
FROM (
	(
		SELECT mID, AVG(stars) AS avg_stars1
		FROM rating
		GROUP BY mID
	) AS t1 INNER JOIN movie USING (mID)
), (
	SELECT MAX(avg_stars2) AS max_avg_stars
	FROM (
		SELECT mID, AVG(stars) AS avg_stars2
		FROM rating
		GROUP BY mID
	) AS t2
) AS t3
WHERE avg_stars1 = max_avg_stars;

/* Question 12: For each director, return the director's name together with the title(s) of the movie(s) they directed
that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL. */

SELECT DISTINCT director, title, stars
FROM movie AS m1 INNER JOIN rating AS r1 USING(mID)
WHERE director IS NOT NULL AND NOT EXISTS (
	SELECT *
	FROM movie INNER JOIN rating USING (mID)
	WHERE director = m1.director AND stars > r1.stars	
);
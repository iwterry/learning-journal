/*##############################################################################################################
	Questions 7 through 9 for Stanford's online DB course.
	See https://lagunita.stanford.edu/courses/DB/SQL/SelfPaced/courseware/ch-sql/seq-exercise-sql_social_query_core/ for more info.
################################################################################################################*/

/* Question 7: For each student A who likes a student B where the two are not friends, find if they have a
friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C. */

SELECT h1.name, h1.grade, h2.name, h2.grade, h3.name, h3.grade
FROM highschooler AS h1, (	
	SELECT id_1, id_2, id_3
	FROM likes, (
		SELECT f1.ID1 AS id_1, f2.ID1 AS id_2, f1.ID2 AS id_3
		FROM friend AS f1, friend AS f2
		WHERE f1.ID2 = f2.ID2 AND f1.ID1 <> f2.ID1
	) AS t1
	WHERE likes.ID1 = t1.id_1 AND likes.ID2 = t1.id_2 AND NOT EXISTS (
		SELECT *
		FROM friend
		WHERE likes.ID1 = friend.ID1 AND likes.ID2 = friend.ID2
	)
)AS t2, highschooler AS h2, highschooler AS h3
WHERE h1.ID = t2.id_1 AND h2.ID = t2.id_2 AND h3.ID = t2.id_3;

/* Question 8: Find the difference between the number of students in the school and the number of different first names. */

SELECT COUNT(*) - COUNT(DISTINCT name)
FROM highschooler;

/* Question 9: Find the name and grade of all students who are liked by more than one other student. */

SELECT name, grade
FROM highschooler INNER JOIN (
	SELECT DISTINCT ID2 AS ID
	FROM likes AS l1 INNER JOIN likes AS l2 USING(ID2)
	WHERE l1.ID1 <> l2.ID1
) AS t1 USING (ID);

/*##################################################################################################################### 
	Questions 1 through 5 for Stanford's online DB course.
	See https://lagunita.stanford.edu/courses/DB/SQL/SelfPaced/courseware/ch-sql/seq-exercise-sql_social_query_extra/ for more info.
#####################################################################################################################*/

/* Question 1: For every situation where student A likes student B, but student B likes a different student C,
return the names and grades of A, B, and C. */

SELECT h1.name, h1.grade, h2.name, h2.grade, h3.name, h3.grade
FROM highschooler AS h1, highschooler AS h2, highschooler AS h3, (
	SELECT l1.ID1 AS id_1, l1.ID2 AS id_2, l2.ID2 AS id_3
	FROM likes AS l1, likes AS l2
	WHERE l1.ID1 <> l2.ID2 AND l1.ID2 = l2.ID1
) AS t1
WHERE h1.ID = t1.id_1 AND h2.ID = t1.id_2 AND h3.ID = t1.id_3;

/* Question 2: Find those students for whom all of their friends are in different grades from themselves.
Return the students' names and grades. */

SELECT name, grade
FROM highschooler AS h1
WHERE EXISTS (
	SELECT *
	FROM friend
	WHERE h1.ID = friend.ID1
) AND NOT EXISTS (
	SELECT *
	FROM highschooler AS h2
	WHERE EXISTS (
		SELECT *
		FROM friend
		WHERE h1.ID = friend.ID1 AND h2.ID = friend.ID2 AND h1.grade = h2.grade
	)
);
	
/* Question 3: What is the average number of friends per student? (Your result should be just one number.) */

SELECT AVG(num_friends) 
FROM (
	SELECT (
		SELECT COUNT(*)
		FROM friend
		WHERE highschooler.ID = friend.ID1
	) AS num_friends
	FROM highschooler
) AS t1;

/* Question 4: Find the number of students who are either friends with Cassandra or are friends of friends
of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend. */

SELECT COUNT(*) 
FROM (

	SELECT ID1 AS cassandra_id,ID2 AS other_id
	FROM friend, (
		SELECT ID
		FROM highschooler
		WHERE name = 'Cassandra'
	) AS t1 
	WHERE t1.ID = friend.ID1

UNION

	SELECT f1.ID1 AS cassandra_id, f2.ID2 AS other_id
	FROM friend AS f1, friend AS f2, (
		SELECT ID
		FROM highschooler
		WHERE name = 'Cassandra'
	) AS t2 
	WHERE f1.ID1 = t2.ID AND f1.ID2 = f2.ID1 AND t2.ID <> f2.ID2

) AS t3;

/* Question 5: Find the name and grade of the student(s) with the greatest number of friends. */

SELECT name, grade
FROM (
	highschooler AS h INNER JOIN (
		SELECT ID1 AS ID, COUNT(*) AS num_friends
		FROM friend
		GROUP BY ID1
	) AS t1 USING (ID)
), (
	SELECT MAX(t2.num_friends) AS max_num_friends
	FROM (
		SELECT COUNT(*) AS num_friends
		FROM friend
		GROUP BY ID1
	) AS t2
) AS t4
WHERE num_friends = max_num_friends;

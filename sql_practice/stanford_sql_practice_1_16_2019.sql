/* Questions 1 - 6 for https://lagunita.stanford.edu/courses/DB/SQL/SelfPaced/courseware/ch-sql/seq-exercise-sql_social_query_core/ */


/* Q1: Find the names of all students who are friends with someone named Gabriel. */

SELECT name
FROM (
	friend INNER JOIN (
		SELECT ID AS ID1
		FROM highschooler 
		WHERE name = 'Gabriel'
	) AS t1 USING (ID1)
), highschooler
WHERE ID = ID2;


/* Q2: For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like. */

SELECT h1.name, h1.grade, h2.name, h2.grade
FROM highschooler AS h1, likes, highschooler AS h2
WHERE h1.ID = likes.ID1 AND h2.ID = likes.ID2 AND (h1.grade - h2.grade) >= 2;


/* Q3: For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order. */

SELECT DISTINCT h1.name, h1.grade, h2.name, h2.grade
FROM highschooler AS h1, (
	SELECT l1.ID1 AS id_1, l1.ID2 AS id_2
	FROM likes AS l1, likes AS l2
	WHERE l1.ID2 = l2.ID1 AND l1.ID1 = l2.ID2
) AS t1, highschooler AS h2
WHERE h1.id = t1.id_1 AND h2.id = t1.id_2 AND h1.name <= h2.name
ORDER BY h1.name ASC;

/* Q4: Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade. */

SELECT name, grade
FROM highschooler
WHERE NOT EXISTS (
	SELECT *
	FROM likes
	WHERE ID = ID1 OR ID = ID2
)
ORDER BY grade ASC, name ASC;

/* Q5: For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. */

SELECT h1.name, h1.grade, h2.name, h2.grade
FROM highschooler AS h1, (
	SELECT l1.ID1 AS id_1, l1.ID2 AS id_2
	FROM likes AS l1 LEFT OUTER JOIN likes AS l2 ON (l1.ID2 = l2.ID1)
	WHERE l2.ID1 IS NULL
) AS t1, highschooler AS h2 
WHERE h1.ID = id_1 AND h2.ID = id_2;

/* Q6: Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade. */

SELECT *
FROM highschooler AS h1 
WHERE EXISTS (
	SELECT *
	FROM friend
	WHERE h1.ID = ID1
) AND NOT EXISTS (
	SELECT *
	FROM friend
	WHERE h1.ID = ID1 AND EXISTS (
		SELECT *
		FROM highschooler AS h2
		WHERE ID2 = h2.ID AND h1.grade <> h2.grade
	)
);
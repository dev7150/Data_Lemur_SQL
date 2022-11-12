-- Given a table of candidates and their skills, you're tasked with finding the candidates best suited for an open Data Science job. You want to find candidates who are proficient in Python, Tableau, and PostgreSQL.
SELECT candidate_id FROM candidates
where skill in ( 'Python','Tableau','PostgreSQL')
group by 1
having COUNT(*) > 2

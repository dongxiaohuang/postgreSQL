-- Q1

SELECT name,
       father,
       mother
FROM person AS child_table
WHERE dod < ALL
    ( SELECT dod
     FROM person
     WHERE (name = child_table.father
            OR name = child_table.mother) )
  AND child_table.father IS NOT NULL
  AND child_table.mother IS NOT NULL
  AND dod IS NOT NULL
ORDER BY name;

-- Q2

SELECT name
FROM monarch
WHERE house IS NOT NULL
UNION
SELECT name
FROM prime_minister
ORDER BY name;

-- Q3

SELECT name
FROM monarch AS main
NATURAL JOIN person
WHERE house IS NOT NULL
  AND
    (SELECT MIN(accession)
     FROM monarch AS sub
     WHERE sub.accession > main.accession) < dod
ORDER BY name;

-- Q4

SELECT house,
       name,
       accession
FROM monarch AS com_mon
WHERE house IS NOT NULL
  AND accession <= ALL
    (SELECT accession
     FROM monarch
     WHERE house = com_mon.house )
ORDER BY accession;

-- Q5

SELECT first_name,
       COUNT (*) AS popularity
FROM
  ( SELECT SPLIT_PART(name, ' ', 1) AS first_name
   FROM person) AS name_table
GROUP BY first_name
HAVING COUNT(*) > 1
ORDER BY popularity DESC,
         first_name;

-- Q6

SELECT DISTINCT house,
                COUNT(CASE
                          WHEN accession >= '1600-01-01'
                               AND accession < '1700-01-01' THEN name
                      END) OVER (PARTITION BY house) AS seventeenth,
                COUNT(CASE
                          WHEN accession >= '1700-01-01'
                               AND accession < '1800-01-01' THEN name
                      END) OVER (PARTITION BY house) AS eighteenth,
                COUNT(CASE
                          WHEN accession >= '1800-01-01'
                               AND accession < '1900-01-01' THEN name
                      END) OVER (PARTITION BY house) AS nineteenth,
                COUNT(CASE
                          WHEN accession >= '1900-01-01'
                               AND accession < '2000-01-01' THEN name
                      END) OVER (PARTITION BY house) AS twentieth
FROM monarch
WHERE house IS NOT NULL
ORDER BY house;

-- Q7

SELECT person.name AS father,
       child_person.name AS child,
       CASE
           WHEN child_person.name IS NULL THEN NULL
           ELSE RANK() OVER (PARTITION BY person.name
                             ORDER BY child_person.dob)
       END AS born
FROM person
LEFT JOIN person AS child_person ON (person.name = child_person.father)
WHERE person.gender = 'M'
ORDER BY father,
         born;

-- Q8

SELECT DISTINCT main.name AS monarch,
                mainp.name AS prime_minister
FROM monarch AS main,
     prime_minister AS mainp
WHERE house IS NOT NULL
  AND (
         (SELECT MIN(entry)
          FROM prime_minister
          WHERE entry > mainp.entry)>= accession AND(
                                                       (SELECT MIN(entry)
                                                        FROM prime_minister
                                                        WHERE entry > mainp.entry)>
                                                       (SELECT MIN(accession)
                                                        FROM monarch AS sub
                                                        WHERE sub.accession > main.accession)) IS NOT TRUE)
  OR (entry>= accession
      AND (entry >
             (SELECT MIN(accession)
              FROM monarch
              WHERE accession > main.accession)) IS NOT TRUE)
  OR (entry <= accession
      AND (
             (SELECT MIN(entry)
              FROM prime_minister
              WHERE entry > mainp.entry)>=
             (SELECT MIN(accession)
              FROM monarch AS sub
              WHERE sub.accession > main.accession)))
ORDER BY monarch,
         prime_minister;

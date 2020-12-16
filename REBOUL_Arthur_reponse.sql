A.
1/
CREATE TABLE Departement
(
DID VARCHAR(2) PRIMARY KEY NOT NULL,
Libelle VARCHAR(20)
);

CREATE TABLE Employe
(
EID INT PRIMARY KEY NOT NULL,
Nom VARCHAR(20),
Dept VARCHAR(2),
CONSTRAINT fk_dept
  FOREIGN KEY (Dept)
  REFERENCES Departement(DID)
);

2/
INSERT INTO Departement
VALUES (01, 'Yo');

SELECT * FROM Departement;

ROLLBACK; -> Aucune transaction en cours.

3/
begin transaction;

INSERT INTO Departement
VALUES (02, 'aaa');

SELECT * FROM Departement;

ROLLBACK;

SELECT * FROM Departement; -> La table est revenue au même état que avant la transac.

4/
begin transaction;

INSERT INTO Departement
VALUES (02, 'aaa');

SELECT * FROM Departement;

COMMIT; -> Fin de la transac.

SELECT * FROM Departement; -> La table n a pas changée

5/
begin transaction;

INSERT INTO Departement
VALUES (03, 'bbb');

SELECT * FROM Departement;

COMMIT; -> Fin de la transac.

SELECT * FROM Departement; -> La table n a pas changée

ROLLBACK; -> Aucune transaction en cours.

SELECT * FROM Departement; -> La table n a pas changée

6/
begin transaction;

INSERT INTO Departement
VALUES (04, 'ccc');

\q

SELECT * FROM Departement; -> Nouvel élément absent, transac non validée.

7/
INSERT INTO Departement
VALUES (04, 'ccc');

\q

SELECT * FROM Departement; -> Nouvel élément présent, transac validée.

8/
begin transaction;

TRUNCATE TABLE Departement CASCADE;

SELECT * FROM Departement; -> Table vidée

ROLLBACK;

SELECT * FROM Departement; -> Table rétablie.

9/
begin transaction;

TRUNCATE TABLE Departement CASCADE;

SELECT * FROM Departement; -> Table vidée

COMMIT;

SELECT * FROM Departement; -> Table vidée.

10/
INSERT INTO Departement
VALUES ('C1', 'Info');

INSERT INTO Employe
VALUES (01, 'Quentin', 'C1');

11/
INSERT INTO Departement
VALUES ('C1', 'Informatique'); -> Erreur il y a déja une clé C1

12/
INSERT INTO Employe
VALUES (02, 'Quentin', 'C2'); -> Erreur, pas de correspondance dans Departement pour la fkey

13/
DELETE FROM Departement
WHERE DID = 'C1';
-> Erreur, C1 est utilisé en fk dans Emplye

14/
ALTER TABLE Employe
DROP CONSTRAINT fk_dept;

DELETE FROM Departement
WHERE DID = 'C1';
-> Ligne C1 supprimée, elle n est plus attachée a Employe

15/
TRUNCATE TABLE Departement CASCADE;
TRUNCATE TABLE Employe CASCADE;

16/
ALTER TABLE Employe
ADD CONSTRAINT fk_dept
  FOREIGN KEY (Dept)
  REFERENCES Departement(DID)
  ON DELETE CASCADE;

INSERT INTO Departement
VALUES ('C1', 'Info');

INSERT INTO Employe
VALUES (01, 'Quentin', 'C1');

17/
DELETE FROM Departement
WHERE DID = 'C1';
-> C1 et l employé rataché a C1 ont été supprimés

18/
INSERT INTO Departement
VALUES ('C1', 'Info');

INSERT INTO Employe
VALUES (01, 'Quentin', 'C1');

19/
ALTER TABLE Employe
DROP CONSTRAINT fk_dept;

ALTER TABLE Employe
ADD CONSTRAINT fk_dept
  FOREIGN KEY (Dept)
  REFERENCES Departement(DID)
  DEFERRABLE;

20/
begin transaction;

SET CONSTRAINTS fk_dept DEFERRED;

21/
DELETE FROM Departement
WHERE DID = 'C1';

COMMIT;
-> Rollback, C1 est utilisé en fk par Employe

B.
2/
a.
INSERT INTO Departement
VALUES ('C1', 'Info');

b.
INSERT INTO Departement
VALUES ('C2', 'Info');

-> les deux dpt apparaissent sur les deux sessions

3/
a.
begin transaction;

INSERT INTO Departement
VALUES ('d1', '1111');

b.
begin transaction;

INSERT INTO Departement
VALUES ('d2', '2222');

COMMIT;

a.
SELECT * FROM Departement -> Il y a d1 et d2

b.
SELECT * FROM Departement -> Il ny a que d2

a.
COMMIT;

b.
SELECT * FROM Departement -> Il y a d1 et d2

4/
a.
begin transaction;

INSERT INTO Departement
VALUES ('d3', '1111');

b.
begin transaction;

INSERT INTO Departement
VALUES ('d3', '2222');
-> la session est "en attente"

a.
COMMIT;

b.
-> Erreur, d3 existe deja

5/
a.
begin transaction;

INSERT INTO Departement
VALUES ('d4', '1111');

b.
begin transaction;

INSERT INTO Departement
VALUES ('d4', '2222');
-> la session est "en attente"

a.
ROLLBACK;

b.
-> d4 est créé.
COMMIT;

6/
TRUNCATE TABLE Departement CASCADE;

7/
begin transaction;

INSERT INTO Departement
VALUES ('C1', '1111');

COMMIT;

SELECT * FROM Departement; -> C1 créé

8/
b.
begin transaction;

UPDATE Departement
SET Libelle = 'Informatique'
WHERE DID = 'C1';

COMMIT;

9/
a.
SELECT * FROM Departement; -> Info est bien devenu Informatique

10/
a.
begin transaction;

UPDATE Departement
SET Libelle = 'Info'
WHERE DID = 'C1';

b.
begin transaction;

UPDATE Departement
SET Libelle = 'Biologie'
WHERE DID = 'C1';
-> Session 2 wait

11/
a.
ROLLBACK;

SELECT * FROM Departement; -> Retour a Informatique

b.
-> Fin du wait
SELECT * FROM Departement; -> Biologie

12/
a.
begin transaction;

UPDATE Departement
SET Libelle = 'Info'
WHERE DID = 'C1';

COMMIT;

SELECT * FROM Departement; -> Info

b.
SELECT * FROM Departement; -> Info

13/
TRUNCATE TABLE Departement CASCADE;

14/
a.
begin transaction;

INSERT INTO Departement
VALUES ('C1', 'Info');

b.
begin transaction;

INSERT INTO Employe
VALUES ('01', 'Henri', 'C1');
-> Ne fonctionne pas, la transac 1 n est pas commit donc pas encore de C1
-> Si commit dans la session 1 avant de le faire dans sess 2 -> ok

15/Insertion annulée

16/
a.
begin transaction;

INSERT INTO Departement
VALUES ('C1', 'Info');

COMMIT;

b.
begin transaction;

INSERT INTO Employe
VALUES ('01', 'Henri', 'C1');

COMMIT;

17/
DELETE FROM Departement
WHERE DID = 'C1';
-> Imposible, utilisé par employé

18/
begin transaction;

INSERT INTO Employe
VALUES ('02', 'Gregoire', 'C1');

COMMIT;

19/
a.
begin transaction;

UPDATE Employe
SET Nom = 'Coleen'
WHERE EID = '01';

SELECT * FROM Employe;

b.
begin transaction;

UPDATE Employe
SET Nom = 'Camille'
WHERE EID = '02';

SELECT * FROM Employe;

-> Il n'y a pas les modifs de l'autre session

20/
a.
COMMIT;
SELECT * FROM Employe;
->Modif effectuée, celle de sess 2 pas appliquée

b.
COMMIT;
SELECT * FROM Employe;
-> toutes les modif apparaissent.

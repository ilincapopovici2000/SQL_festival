--CREATE DATABASE Festival

USE Festival

--drop all
DROP TABLE Bilete;
DROP TABLE SceneOrganizatori;
DROP TABLE Organizatori;
DROP TABLE SceneSpectatori;
DROP TABLE Spectatori;
DROP TABLE ArtistiScene;
DROP TABLE Artisti;
DROP TABLE Scene;

--relatie many to many intre artisti si scene
CREATE TABLE Artisti
(cod_artist INT PRIMARY KEY,
 nume VARCHAR(30));

 CREATE TABLE Scene
(cod_scena INT PRIMARY KEY,
nume VARCHAR(30),
tip VARCHAR(30));

CREATE TABLE ArtistiScene
(cod_artist INT FOREIGN KEY REFERENCES Artisti(cod_artist),
cod_scena INT FOREIGN KEY REFERENCES Scene(cod_scena),
data_ DATE,-- este atribut al relatiei many to many, si poate sa difere la fiecare combinatie (artist, scena)
ora INT,-- este atribut al relatiei many to many, si poate sa difere la fiecare combinatie (artist, scena)
CHECK (0<=ora AND ora<=24),
CONSTRAINT pk_ArtistiScene PRIMARY KEY (cod_artist, cod_scena),
);


--relatie one to many intre bilete si spectatori
CREATE TABLE Spectatori
(cod_spectator INT PRIMARY KEY,
nume VARCHAR(30),
prenume VARCHAR(100),
varsta INT,
email VARCHAR(100))

CREATE TABLE Bilete
(cod_bilet INT PRIMARY KEY,
tip VARCHAR(30),
pret INT,
cod_spectator INT FOREIGN KEY REFERENCES Spectatori(cod_spectator))

--relatie many to many intre organizatori si scene
CREATE TABLE Organizatori
(cod_organizator INT PRIMARY KEY,
nume VARCHAR(30),
prenume VARCHAR(100))

CREATE TABLE SceneOrganizatori(
cod_organizator INT FOREIGN KEY REFERENCES Organizatori(cod_organizator),
cod_scena INT FOREIGN KEY REFERENCES Scene(cod_scena),
CONSTRAINT pk_SceneOrganizatori PRIMARY KEY (cod_organizator, cod_scena),
);

--relatie many to many intre spectatori si scene
CREATE TABLE SceneSpectatori(
cod_spectator INT FOREIGN KEY REFERENCES Spectatori(cod_spectator),
cod_scena INT FOREIGN KEY REFERENCES Scene(cod_scena),
CONSTRAINT pk_SceneSpectatori PRIMARY KEY (cod_spectator, cod_scena),
);

--inserare in tabel

INSERT INTO Artisti VALUES (1, 'Martin Garrix');
INSERT INTO Artisti VALUES (2, 'David Guetta');
INSERT INTO Artisti VALUES (3, 'Tiesto');

INSERT INTO Scene VALUES (18, 'Main Stage','mare');
INSERT INTO Scene VALUES (19, 'Alchemy Stage','medie');
INSERT INTO Scene VALUES (20, 'Galaxy Stage','medie');

INSERT INTO ArtistiScene VALUES (1, 18, '2021/08/20', 22);
INSERT INTO ArtistiScene VALUES (2, 18, '2021/08/20', 23);
INSERT INTO ArtistiScene VALUES (3, 19, '2021/08/21', 20);

INSERT INTO Spectatori VALUES (345, 'Pop', 'Mirela', 19, 'pop_mirela@yahoo.com');
INSERT INTO Spectatori VALUES (567, 'Oltean', 'Sorin', 23, 'sorinoltean@yahoo.com');
INSERT INTO Spectatori VALUES (123, 'Pop', 'Simona',17,  'simonapop23@yahoo.com');
INSERT INTO Spectatori VALUES (120, 'Ise', 'Andrei',20, 'andrei-ise30@yahoo.com');

INSERT INTO SceneSpectatori VALUES (123, 18);
INSERT INTO SceneSpectatori VALUES (345, 18);
INSERT INTO SceneSpectatori VALUES (567, 19);

INSERT INTO Organizatori VALUES (22, 'Bob','Vlad');
INSERT INTO Organizatori VALUES (33, 'Ispas','Andreea');
INSERT INTO Organizatori VALUES (44, 'Pojar','Andrada');

INSERT INTO SceneOrganizatori VALUES (22, 18);
INSERT INTO SceneOrganizatori VALUES (33, 18);
INSERT INTO SceneOrganizatori VALUES (44, 19);

INSERT INTO Bilete VALUES (367,'abonament', 679,345);
INSERT INTO Bilete VALUES (832,'abonament VIP',1050,567);
INSERT INTO Bilete VALUES (432,'abonament VIP',1000,567);
INSERT INTO Bilete VALUES (512,'abonament',679,123);
INSERT INTO Bilete VALUES (112,'abonament',800,123);
/*
--stergere de date

DELETE FROM Bilete;
DELETE FROM SceneOrganizatori;
DELETE FROM Organizatori;
DELETE FROM SceneSpectatori;
DELETE FROM Spectatori;
DELETE FROM ArtistiScene;
DELETE FROM Artisti;
DELETE FROM Scene;
*/
--modificare de date

UPDATE Spectatori
SET email='popmirela@yahoo.com'
WHERE nume='Pop' AND prenume='Mirela';

UPDATE Spectatori
SET email=NULL
WHERE nume='Ise';

UPDATE Bilete
SET tip='bilet de o zi'
WHERE cod_spectator<400;

--stergere de date

DELETE FROM Spectatori
WHERE email IS NULL;

--afisare

SELECT * 
FROM Spectatori

SELECT * 
FROM Artisti

SELECT * 
FROM ArtistiScene

SELECT * 
FROM SceneSpectatori

--UNION

SELECT nume, prenume FROM Spectatori
UNION 
SELECT nume, prenume FROM Organizatori;


--GROUP BY

SELECT s.nume, s.cod_spectator, SUM(pret) AS Valoarea_totala, COUNT(cod_bilet) AS TotalBilete
FROM Bilete b, Spectatori s
WHERE s.cod_spectator = b.cod_spectator
GROUP BY s.cod_spectator, s.nume
HAVING SUM(pret) > 1000;

SELECT s.nume, s.cod_spectator, MAX(pret) AS pret_maxim
FROM Bilete b, Spectatori s
WHERE s.cod_spectator = b.cod_spectator
GROUP BY s.cod_spectator, s.nume
ORDER BY pret_maxim desc;

SELECT DISTINCT s.cod_spectator, s.nume, s.varsta, COUNT(b.cod_bilet) AS total
FROM Bilete b, Spectatori s
WHERE b.cod_spectator = s.cod_spectator
AND s.varsta<=20
GROUP BY s.cod_spectator, s.nume, s.varsta

SELECT DISTINCT s.nume, s.cod_spectator
FROM Bilete b, Spectatori s
WHERE s.cod_spectator = b.cod_spectator

SELECT s.nume, s.cod_spectator, COUNT(cod_bilet) AS TotalBilete
FROM Bilete b, Spectatori s
WHERE s.cod_spectator = b.cod_spectator
GROUP BY s.cod_spectator, s.nume;

--INNER JOIN & RIGHT JOIN

SELECT O.nume, O.prenume, S.nume, S.tip
FROM Organizatori O
INNER JOIN SceneOrganizatori SO ON O.cod_organizator=SO.cod_organizator
INNER JOIN Scene S ON SO.cod_scena=S.cod_scena

SELECT* FROM Organizatori
SELECT * FROM SceneOrganizatori
SELECT * FROM Scene

SELECT A.nume, S.nume
FROM Artisti A
RIGHT JOIN ArtistiScene A_S ON A.cod_artist=A_S.cod_artist
RIGHT JOIN Scene S ON A_S.cod_scena=S.cod_scena

SELECT COUNT(O.nume) AS Nr, S.nume, S.tip
FROM Organizatori O
INNER JOIN SceneOrganizatori SO ON O.cod_organizator=SO.cod_organizator
INNER JOIN Scene S ON SO.cod_scena=S.cod_scena
GROUP BY S.nume, S.tip

--functii user-defined

/*
GO
CREATE FUNCTION NumarBilete(@tip VARCHAR(20))
RETURNS INT AS
BEGIN
DECLARE @nr_bilete INT = 0;
SELECT @nr_bilete = COUNT(*) FROM Bilete WHERE tip= @tip
RETURN @nr_bilete
END
GO
*/
SELECT*FROM BILETE
PRINT dbo.NumarBilete('abonament VIP')
/*
GO
CREATE FUNCTION Pret(@pret INT, @tip VARCHAR(20))
RETURNS TABLE AS
RETURN SELECT * FROM Bilete WHERE pret > @pret AND tip=@tip
GO*/
SELECT * FROM dbo.Pret(700, 'abonament')
/*
GO
CREATE FUNCTION Program_artist(@cod_artist INT)
RETURNS TABLE AS
RETURN SELECT * FROM ArtistiScene WHERE cod_artist=@cod_artist
GO
*/
SELECT * FROM dbo.Program_artist(1)

--proceduri stocate & functii de validare
/*
DROP PROCEDURE AdaugaSpectator
DROP PROCEDURE AdaugaScena
DROP PROCEDURE AdaugaSceneSpectatori

DROP FUNCTION Validare_varsta_adult
DROP FUNCTION Validare_tip
DROP FUNCTION Validare_cod_spectator
*/
/*
GO
CREATE FUNCTION Validare_varsta_adult(@varsta INT)
RETURNS INT AS
BEGIN
DECLARE @valid INT = 0;
IF (@varsta>=18) SELECT @valid = 1 ELSE SELECT @valid = 0
RETURN @valid
END
GO

GO
CREATE PROCEDURE AdaugaSpectator @nume VARCHAR(30), @prenume VARCHAR(100), @varsta INT, @email VARCHAR(100)
AS
BEGIN 
IF(dbo.Validare_varsta_adult(@varsta) = 1) 
BEGIN
	DECLARE @cod_spectator INT = 1 + (SELECT MAX(cod_spectator) FROM Spectatori); 
	INSERT INTO Spectatori VALUES (@cod_spectator, @nume, @prenume, @varsta, @email);
END
END

GO 
EXEC AdaugaSpectator 'Dragan', 'Paula', 20, 'paula_stragan288@yahoo.com'
EXEC AdaugaSpectator 'Popescu', 'Diana', 17, 'popescudiana@yahoo.com'
SELECT * FROM Spectatori

CREATE FUNCTION Validare_tip(@tip VARCHAR(20))
RETURNS INT AS
BEGIN
DECLARE @valid INT = 0;
IF (@tip = 'mare' OR @tip = 'medie' OR @tip = 'mica') SELECT @valid = 1 ELSE SELECT @valid = 0
RETURN @valid
END
*/
PRINT dbo.Validare_tip('mica')
/*
GO
CREATE PROCEDURE AdaugaScena @nume VARCHAR(20), @tip VARCHAR(20)
AS
BEGIN 
IF(dbo.Validare_tip(@tip) = 1) 
BEGIN
	DECLARE @cod_scena INT = 1+ (SELECT MAX(cod_scena) FROM Scene)
	INSERT INTO Scene VALUES (@cod_scena, @nume, @tip);
END
END

GO 
EXEC AdaugaScena 'TimeStage', 'medie'
EXEC AdaugaScena 'ForestStage', 'mare'

SELECT*FROM Scene

CREATE FUNCTION Validare_cod_spectator(@cod_spectator INT)
RETURNS INT AS
BEGIN
DECLARE @cod INT = (SELECT cod_spectator FROM Spectatori WHERE cod_spectator = @cod_spectator)
DECLARE @valid INT=0
IF (@cod IS NOT NULL) SELECT @valid = 1 ELSE SELECT @valid = 0
RETURN @valid
END


GO
CREATE PROCEDURE AdaugaSceneSpectatori @cod_spectator INT, @nume_scena VARCHAR(20)
AS
BEGIN 
DECLARE @cod_scena INT = (SELECT cod_scena FROM Scene WHERE nume = @nume_scena);
IF ((@cod_scena IS NOT NULL) AND (dbo.Validare_cod_spectator(@cod_spectator) =1))
INSERT INTO SceneSpectatori(cod_scena, cod_spectator) VALUES (@cod_scena, @cod_spectator);
END

GO 
EXEC AdaugaSceneSpectatori 123,'ForestStage'
EXEC AdaugaSceneSpectatori 120,'TimeStage'
EXEC AdaugaSceneSpectatori 123,'TimeStage'

SELECT*FROM SceneSpectatori
SELECT*FROM Scene

--View Bilete

DROP VIEW vw_Bilete

GO
CREATE VIEW vw_Bilete AS
SELECT S.nume, S.prenume, B.tip, B.pret
FROM Bilete AS B
INNER JOIN Spectatori AS S
ON B.cod_spectator=S.cod_spectator;
*/
SELECT * FROM vw_Bilete

--Triggere
--DROP TRIGGER dbo.TriggerAdaugaSpectator

GO
CREATE TRIGGER dbo.TriggerAdaugaSpectator
ON dbo.Spectatori
FOR INSERT
AS
BEGIN
SET NOCOUNT ON;
PRINT 'Insert, Spectatori, ' + CAST(GETDATE() AS VARCHAR(40));
END;

--INSERT INTO Spectatori VALUES (316, 'Pop', 'Mirela', 19, 'pop_mirela@yahoo.com');
SELECT * FROM Spectatori
/*
GO
CREATE TRIGGER dbo.TriggerStergeSpectator
ON dbo.Spectatori
FOR DELETE
AS
BEGIN
SET NOCOUNT ON;
PRINT 'Delete, Spectatori, ' + CAST(GETDATE() AS VARCHAR(40));
END;

DELETE FROM Spectatori
WHERE nume='Popa';

SELECT * FROM Spectatori
*/
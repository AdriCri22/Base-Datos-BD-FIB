-- Pregunta 1 enunciat
/*Doneu una sentència SQL per obtenir el número i el nom dels departaments que
no tenen cap empleat que visqui a MADRID.

Pel joc de proves que trobareu al fitxer adjunt, la sortida seria:

NUM_DPT		NOM_DPT
3		MARKETING*/

-- Sent�ncies de preparaci� de la base de dades:
CREATE TABLE DEPARTAMENTS
         (	NUM_DPT INTEGER,
	NOM_DPT CHAR(20),
	PLANTA INTEGER,
	EDIFICI CHAR(30),
	CIUTAT_DPT CHAR(20),
	PRIMARY KEY (NUM_DPT));

CREATE TABLE PROJECTES
         (	NUM_PROJ INTEGER,
	NOM_PROJ CHAR(10),
	PRODUCTE CHAR(20),
	PRESSUPOST INTEGER,
	PRIMARY KEY (NUM_PROJ));

CREATE TABLE EMPLEATS
         (	NUM_EMPL INTEGER,
	NOM_EMPL CHAR(30),
	SOU INTEGER,
	CIUTAT_EMPL CHAR(20),
	NUM_DPT INTEGER,
	NUM_PROJ INTEGER,
	PRIMARY KEY (NUM_EMPL),
	FOREIGN KEY (NUM_DPT) REFERENCES DEPARTAMENTS (NUM_DPT),
	FOREIGN KEY (NUM_PROJ) REFERENCES PROJECTES (NUM_PROJ));

-- Sent�ncies d'esborrat de la base de dades:
DROP TABLE empleats;
DROP TABLE departaments;
DROP TABLE projectes;

--------------------------
-- Joc de proves Public
--------------------------

-- Sent�ncies d'inicialitzaci�:
INSERT INTO  DEPARTAMENTS VALUES (3,'MARKETING',3,'RIOS ROSAS','MADRID');

INSERT INTO  PROJECTES VALUES (1,'IBDTEL','TELEVISIO',1000000);

-- Sent�ncies de neteja de les taules:
DELETE FROM empleats;
DELETE FROM departaments;
DELETE FROM projectes;

-- Pregunta 1 solució
SELECT  d.num_dpt, d.nom_dpt
FROM departaments d
WHERE NOT EXISTS (SELECT * FROM empleats e
                  WHERE e.num_dpt = d.num_dpt AND e.ciutat_empl = 'MADRID');


-- Pregunta 2 enunciat
/*Doneu una sentència SQL per obtenir les ciutats on hi viuen empleats però no
hi ha cap departament.

Pel joc de proves que trobareu al fitxer adjunt, la sortida seria:

CIUTAT_EMPL
GIRONA*/

-- Sentències de preparació de la base de dades:
CREATE TABLE DEPARTAMENTS
         (	NUM_DPT INTEGER,
	NOM_DPT CHAR(20),
	PLANTA INTEGER,
	EDIFICI CHAR(30),
	CIUTAT_DPT CHAR(20),
	PRIMARY KEY (NUM_DPT));

CREATE TABLE PROJECTES
         (	NUM_PROJ INTEGER,
	NOM_PROJ CHAR(10),
	PRODUCTE CHAR(20),
	PRESSUPOST INTEGER,
	PRIMARY KEY (NUM_PROJ));

CREATE TABLE EMPLEATS
         (	NUM_EMPL INTEGER,
	NOM_EMPL CHAR(30),
	SOU INTEGER,
	CIUTAT_EMPL CHAR(20),
	NUM_DPT INTEGER,
	NUM_PROJ INTEGER,
	PRIMARY KEY (NUM_EMPL),
	FOREIGN KEY (NUM_DPT) REFERENCES DEPARTAMENTS (NUM_DPT),
	FOREIGN KEY (NUM_PROJ) REFERENCES PROJECTES (NUM_PROJ));

-- Sentències d'esborrat de la base de dades:
DROP TABLE empleats;
DROP TABLE projectes;
DROP TABLE departaments;

--------------------------
-- Joc de proves Public
--------------------------

-- Sentències d'inicialització:
INSERT INTO  DEPARTAMENTS VALUES (
5,'VENDES',3,'CASTELLANA','MADRID');

INSERT INTO  EMPLEATS VALUES (1,'MANEL',250000,'MADRID',5,null);

INSERT INTO  EMPLEATS VALUES (3,'JOAN',25000,'GIRONA',5,null);

-- Sentències de neteja de les taules:
DELETE FROM empleats;
DELETE FROM Projectes;
DELETE FROM departaments;

-- Pregunta 2 solució
SELECT DISTINCT e.ciutat_empl
FROM empleats e
WHERE NOT EXISTS (SELECT * FROM departaments d
                  WHERE d.ciutat_dpt = e.ciutat_empl);


-- Pregunta 3 enunciat
/*Doneu una sentència SQL per obtenir el número i nom dels departaments que
tenen dos o més empleats que viuen a ciutats diferents.

Pel joc de proves que trobareu al fitxer adjunt, la sortida seria:

NUM_DPT		NOM_DPT
3		MARKETING*/

-- Sentències de preparació de la base de dades:
CREATE TABLE DEPARTAMENTS
         (	NUM_DPT INTEGER,
	NOM_DPT CHAR(20),
	PLANTA INTEGER,
	EDIFICI CHAR(30),
	CIUTAT_DPT CHAR(20),
	PRIMARY KEY (NUM_DPT));

CREATE TABLE PROJECTES
         (	NUM_PROJ INTEGER,
	NOM_PROJ CHAR(10),
	PRODUCTE CHAR(20),
	PRESSUPOST INTEGER,
	PRIMARY KEY (NUM_PROJ));

CREATE TABLE EMPLEATS
         (	NUM_EMPL INTEGER,
	NOM_EMPL CHAR(30),
	SOU INTEGER,
	CIUTAT_EMPL CHAR(20),
	NUM_DPT INTEGER,
	NUM_PROJ INTEGER,
	PRIMARY KEY (NUM_EMPL),
	FOREIGN KEY (NUM_DPT) REFERENCES DEPARTAMENTS (NUM_DPT),
	FOREIGN KEY (NUM_PROJ) REFERENCES PROJECTES (NUM_PROJ));

-- Sentències d'esborrat de la base de dades:
DROP TABLE empleats;
DROP TABLE departaments;
DROP TABLE projectes;

--------------------------
-- Joc de proves Public
--------------------------

-- Sentències d'inicialització:
INSERT INTO DEPARTAMENTS VALUES(3,'MARKETING',1,'EDIFICI1','SABADELL');

INSERT INTO  EMPLEATS VALUES (4,'JOAN',30000,'BARCELONA',3,null);

INSERT INTO  EMPLEATS VALUES (5,'PERE',25000,'MATARO',3,null);

-- Sentències de neteja de les taules:
DELETE FROM empleats;
DELETE FROM departaments;
DELETE FROM projectes;

-- Pregunta 3 solució
SELECT d.num_dpt, d.nom_dpt
FROM departaments d, empleats e
WHERE e.num_dpt = d.num_dpt
GROUP BY d.num_dpt
HAVING 1 < COUNT(DISTINCT e.ciutat_empl);


-- Pregunta 4 enunciat
/*Tenint en compte l'esquema de la BD que s'adjunta, proposeu una sentència de
creació de les taules següents:
VENDES(NUM_VENDA, NUM_EMPL, CLIENT)
PRODUCTES_VENUTS(NUM_VENDA, PRODUCTE, QUANTITAT, IMPORT)

Cada fila de la taula vendes representa una venda que ha fet un empleat a un
client. Cada fila de la taula productes_venuts representa una quantitat de
producte venut en una venda, amb un cert import.

En la creació de les taules cal que tingueu en compte que:
- No hi poden haver dues vendes amb un mateix número de venda.
- Un empleat només li pot fer una única venda a un mateix client.
- Una venda l'ha de fer un empleat que existeixi a la base de dades
- No hi pot haver dues vegades un mateix producte en una mateixa venda.
- La venda d'un producte venut ha d'existir a la base de dades.
- La quantitat de producte venut no pot ser nul, i té com a valor per defecte 1.
- Els atributs num_venda, quantitat, import són enters.
- Els atributs client, producte són char(30), i char(20) respectivament.

Respecteu els noms i l'ordre en què apareixen les columnes (fins i tot dins la
clau o claus que calgui definir). Tots els noms s'han de posar en majúscues com
surt a l'enunciat.*/

-- Sentències de preparació de la base de dades:
CREATE TABLE DEPARTAMENTS
         (	NUM_DPT INTEGER,
	NOM_DPT CHAR(20),
	PLANTA INTEGER,
	EDIFICI CHAR(30),
	CIUTAT_DPT CHAR(20),
	PRIMARY KEY (NUM_DPT));

CREATE TABLE PROJECTES
         (	NUM_PROJ INTEGER,
	NOM_PROJ CHAR(10),
	PRODUCTE CHAR(20),
	PRESSUPOST INTEGER,
	PRIMARY KEY (NUM_PROJ));

CREATE TABLE EMPLEATS
         (	NUM_EMPL INTEGER,
	NOM_EMPL CHAR(30),
	SOU INTEGER,
	CIUTAT_EMPL CHAR(20),
	NUM_DPT INTEGER,
	NUM_PROJ INTEGER,
	PRIMARY KEY (NUM_EMPL),
	FOREIGN KEY (NUM_DPT) REFERENCES DEPARTAMENTS (NUM_DPT),
	FOREIGN KEY (NUM_PROJ) REFERENCES PROJECTES (NUM_PROJ));

-- Pregunta 4 solució
CREATE TABLE VENDES (
        NUM_VENDA INTEGER,
        NUM_EMPL INTEGER NOT NULL,
        CLIENT CHAR(30),
        PRIMARY KEY (NUM_VENDA),
        FOREIGN KEY (NUM_EMPL) REFERENCES EMPLEATS (NUM_EMPL),
        UNIQUE (num_empl, client));

CREATE TABLE PRODUCTES_VENUTS (
        NUM_VENDA INTEGER,
        PRODUCTE CHAR(20),
        QUANTITAT INTEGER NOT NULL DEFAULT 1,
        IMPORT INTEGER,
        PRIMARY KEY (NUM_VENDA, PRODUCTE),
        FOREIGN KEY (NUM_VENDA) REFERENCES VENDES (NUM_VENDA));

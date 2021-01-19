-- Pregunta 1 enunciat
/*Donar una sentència SQL per obtenir per cada mòdul on hi hagi despatxos, la durada mitjana de les assignacions finalitzades (instantFi diferent de null) a despatxos del mòdul. El resultat ha d'estar ordenat ascendentment pel nom del mòdul.

Pel joc de proves que trobareu al fitxer adjunt, la sortida ha de ser:

MODUL		MITJANA_DURADA
Omega		235.00*/

-- Sentències de preparació de la base de dades:
create table professors
(dni char(50),
nomProf char(50) unique,
telefon char(15),
sou integer not null check(sou>0),
primary key (dni));

create table despatxos
(modul char(5),
numero char(5),
superficie integer not null check(superficie>12),
primary key (modul,numero));

create table assignacions
(dni char(50),
modul char(5),
numero char(5),
instantInici integer,
instantFi integer,
primary key (dni, modul, numero, instantInici),
foreign key (dni) references professors,
foreign key (modul,numero) references despatxos);
-- instantFi te valor null quan una assignacio es encara vigent.

-- Sentències d'esborrat de la base de dades:
DROP TABLE assignacions;
DROP TABLE despatxos;
DROP TABLE professors;

--------------------------
-- Joc de proves Public
--------------------------

-- Sentències d'inicialització:
insert into professors values('111','toni','3111',100);
insert into professors values('222','pere','4111',200);

insert into despatxos values('omega','118',16);

insert into assignacions values('111','omega','118',109,344);
insert into assignacions values('222','omega','118',345,null);

-- Sentències de neteja de les taules:
DELETE FROM assignacions;
DELETE FROM despatxos;
DELETE FROM professors;

-- Pregunta 1 solució
select a.MODUL, AVG(a.instantfi- a.instantinici) AS MITJANA_DURADA
from assignacions a
where a.instantfi is not null
group by a.modul
order by a.modul ASC;


-- Pregunta 2 enunciat
/*Doneu una sentència SQL per obtenir els departaments tals que tots els empleats del departament estan assignats a un mateix projecte.
No es vol que surtin a la consulta els departaments que no tenen cap empleat.
Es vol el número, nom i ciutat de cada departament. El resultat ha d'estar ordenat ascendentment per cadascun dels atributs anteriors.

Cal resoldre l'exercici sense fer servir funcions d'agregació.

Pel joc de proves que trobareu al fitxer adjunt, la sortida seria:

Num_dpt		Nom_dpt		Ciutat_dpt
1		DIRECCIO		BARCELONA*/

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
	NUM_DPT INTEGER NOT NULL,
	NUM_PROJ INTEGER NOT NULL,
	PRIMARY KEY (NUM_EMPL),
	FOREIGN KEY (NUM_DPT) REFERENCES DEPARTAMENTS (NUM_DPT),
	FOREIGN KEY (NUM_PROJ) REFERENCES PROJECTES (NUM_PROJ));


INSERT INTO  DEPARTAMENTS VALUES (1,'DIRECCIO',10,'PAU CLARIS','BARCELONA');
INSERT INTO  DEPARTAMENTS VALUES (2,'DIRECCIO',8,'RIOS ROSAS','MADRID');
INSERT INTO  DEPARTAMENTS VALUES (4,'MARKETING',3,'RIOS ROSAS','MADRID');

INSERT INTO  PROJECTES VALUES (1,'IBDTEL','TELEVISIO',1000000);
INSERT INTO  PROJECTES VALUES (2,'IBDVID','VIDEO',500000);
INSERT INTO  PROJECTES VALUES (3,'IBDTEF','TELEFON',200000);
INSERT INTO  PROJECTES VALUES (4,'IBDCOM','COMPACT DISC',2000000);

INSERT INTO  EMPLEATS VALUES (1,'CARME',400000,'MATARO',1,1);

-- Pregunta 2 solució
select DISTINCT d.num_dpt, d.nom_dpt, d.ciutat_dpt
from departaments d, empleats e
where e.num_dpt = d.num_dpt AND NOT EXISTS(select *
                           from empleats e2
                           where e.num_dpt = e2.num_dpt AND e.num_proj <> e2.num_proj)
order by d.num_dpt ASC;


-- Pregunta 3 enunciat
/*Tenint en compte l'esquema de la BD que s'adjunta, proposeu una sentència de creació de la taula següent:
presentacioTFG(idEstudiant, titolTFG, dniDirector, dniPresident, dniVocal, instantPresentacio, nota)

Hi ha una fila de la taula per cada treball final de grau (TFG) que estigui pendent de ser presentat o que ja s'hagi presentat.

En la creació de la taula cal que tingueu en compte que:
- L'identificador de l'estudiant i el títol del TFG són chars de 100 caràcters.
- Un estudiant només pot presentar un TFG.
- No hi pot haver dos TFG amb el mateix títol.
- Tot TFG ha de tenir un títol.
- El director, el president i el vocal han de ser professors que existeixin a la base de dades.
- El director del TFG no pot estar en el tribunal del TFG (no pot ser ni president, ni vocal).
- El president i el vocal no poden ser el mateix professor.
- L'instant de presentació ha de ser un enter diferent de nul.
- La nota ha de ser un enter entre 0 i 10.
- La nota té valor nul fins que s'ha fet la presentació del TFG.

Respecteu els noms i l'ordre en què apareixen les columnes (fins i tot dins la clau o claus que calgui definir). Tots els noms s'han de posar en majúscues/minúscules com surt a l'enunciat.*/

----------------
-- Neteja
----------------



------------------------
-- Inicialitzacio
------------------------

create table professors
(dni char(50),
nomProf char(50) unique,
telefon char(15),
sou integer not null check(sou>0),
primary key (dni));

create table despatxos
(modul char(5),
numero char(5),
superficie integer not null check(superficie>12),
primary key (modul,numero));

create table assignacions
(dni char(50),
modul char(5),
numero char(5),
instantInici integer,
instantFi integer,
primary key (dni, modul, numero, instantInici),
foreign key (dni) references professors,
foreign key (modul,numero) references despatxos);
-- instantFi te valor null quan una assignacio es encara vigent.

-- Pregunta 3 solució
create table presentacioTFG(
idEstudiant char(100),
titolTFG char(100) unique not null,
dniDirector char(50) check(dniDirector<>dniPresident and dniDirector<> dniVocal) not null,
dniPresident char(50) check(dniPresident <> dniVocal) not null,
dniVocal char(50) not null,
instantPresentacio integer not null,
nota integer check(nota>=0 and nota <=10) default null,
foreign key (dniDirector) references professors(dni) ,
foreign key (dniPresident) references professors(dni),
foreign key (dniVocal) references professors(dni),
primary key (idEstudiant));


-- Pregunta 4 enunciat
/*Doneu una seqüència d'operacions en àlgebra relacional per obtenir el nom dels professors que o bé tenen un sou superior a 2500, o bé que cobren menys de 2500 i no tenen cap assignació a un despatx amb superfície inferior a 20..

Pel joc de proves que trobareu al fitxer adjunt, la sortida seria:

NomProf
toni*/

-- Sentències de preparació de la base de dades:
create table professors
(dni char(50),
nomProf char(50) unique,
telefon char(15),
sou integer not null check(sou>0),
primary key (dni));

create table despatxos
(modul char(5),
numero char(5),
superficie integer not null check(superficie>12),
primary key (modul,numero));

create table assignacions
(dni char(50),
modul char(5),
numero char(5),
instantInici integer,
instantFi integer,
primary key (dni, modul, numero, instantInici),
foreign key (dni) references professors,
foreign key (modul,numero) references despatxos);
-- instantFi te valor null quan una assignacio es encara vigent.

-- Sentències d'esborrat de la base de dades:
DROP TABLE assignacions;
DROP TABLE despatxos;
DROP TABLE professors;

--------------------------
-- Joc de proves Public
--------------------------

-- Sentències d'inicialització:
insert into professors values('111','toni','3111',3500);

insert into despatxos values('omega','120',20);

insert into assignacions values('111','omega','120',345,null);

-- Sentències de neteja de les taules:
DELETE FROM assignacions;
DELETE FROM despatxos;
DELETE FROM professors;

-- Pregunta 4 solució
A = PROFESSORS(sou > 2500)
B = PROFESSORS * DESPATXOS
C = B * ASSIGNACIONS
D = C(superficie < 20)
X = D[nomProf]
T= C[nomProf]
M = T - X
J = professors[nomProf]
H = J - X
Q = A[nomProf]
K = M _u_ H
R = Q _u_ K


-- Pregunta 5 enunciat
/*Doneu una sentència d'inserció de files a la taula cost_ciutat que l'ompli a partir del contingut de la resta de taules de la base de dades. Tingueu en compte el següent:

Cal inserir una fila a la taula cost_ciutat per cada ciutat on hi ha un o més departaments, però no hi ha cap departament que tingui empleats.

Per tant, només s'han d'inserir les ciutats on cap dels departaments situats a la ciutat tinguin empleats.

El valor de l'atribut cost ha de ser 0.

Pel joc de proves públic del fitxer adjunt, un cop executada la sentència d'inserció, a la taula cost_ciutat hi haurà les tuples següents:

CIUTAT_DPT		COST
BARCELONA		0*/

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

CREATE TABLE COST_CIUTAT
        (CIUTAT_DPT CHAR(20),
        COST INTEGER,
        PRIMARY KEY (CIUTAT_DPT));

-- Sentències d'esborrat de la base de dades:
DROP TABLE cost_ciutat;
DROP TABLE empleats;
DROP TABLE departaments;
DROP TABLE projectes;

--------------------------
-- Joc de proves Public
--------------------------

-- Sentències d'inicialització:
INSERT INTO  PROJECTES VALUES (3,'PR1123','TELEVISIO',600000);

INSERT INTO  DEPARTAMENTS VALUES (4,'MARKETING',3,'RIOS ROSAS','BARCELONA');

-- Sentències de neteja de les taules:
delete from cost_ciutat;
delete from empleats;
delete from departaments;
delete from projectes;

-- Pregunta 5 solució
INSERT INTO cost_ciutat (SELECT DISTINCT d.ciutat_dpt, 0
                          FROM departaments d
                          WHERE d.ciutat_dpt NOT IN (SELECT d2.ciutat_dpt
                                                      FROM empleats e1, departaments d2
                                                      WHERE e1.num_dpt = d2.num_dpt));

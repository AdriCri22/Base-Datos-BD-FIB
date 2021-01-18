-- Pregunta 1 enunciat
/* Implementar mitjançant disparadors la restricció d'integritat següent:
No es pot esborrar l'empleat 123 ni modificar el seu número d'empleat.

Cal informar dels errors a través d'excepcions tenint en compte les situacions
tipificades a la taula missatgesExcepcions, que podeu trobar definida (amb els
inserts corresponents) al fitxer adjunt. Concretament en el vostre procediment
heu d'incloure, quan calgui, les sentències:
SELECT texte INTO missatge FROM missatgesExcepcions WHERE num=__; (el número que sigui, depenent de l'error)
RAISE EXCEPTION '%',missatge;
La variable missatge ha de ser una variable definida al vostre procediment, i
del mateix tipus que l'atribut corresponent de l'esquema de la base de dades.

Pel joc de proves que trobareu al fitxer adjunt i la instrucció:
DELETE FROM empleats WHERE nempl=123;
La sortida ha de ser:

No es pot esborrar l'empleat 123 ni modificar el seu número d'empleat */

-- Sentències de preparació de la base de dades:
create table empleats(
                 nempl integer primary key,
                 salari integer);

create table missatgesExcepcions(
	num integer,
	texte varchar(100));

insert into missatgesExcepcions values(1,'No es pot esborrar l''empleat 123 ni modificar el seu número d''empleat');

-- Sentències d'esborrat de la base de dades:
drop table empleats;
drop table missatgesExcepcions;

--------------------------
-- Joc de proves Public
--------------------------

-- Sentències d'inicialització:
insert into empleats values(1,1000);
insert into empleats values(2,2000);
insert into empleats values(123,3000);

-- Dades d'entrada o sentències d'execució:
delete from empleats where nempl=123;

--Pregunta 1 solució
CREATE FUNCTION delete_cond() RETURNS trigger AS $$
  DECLARE
    missatge missatgesExcepcions.texte%type;
  BEGIN
    IF (old.nempl = 123) THEN
      SELECT texte INTO missatge FROM missatgesExcepcions WHERE num = 1;
      RAISE EXCEPTION '%', missatge;
    ELSE RETURN OLD;
    END IF;

  EXCEPTION
    WHEN raise_exception THEN RAISE EXCEPTION '%', SQLERRM;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_trigger BEFORE delete ON empleats FOR EACH ROW
EXECUTE PROCEDURE delete_cond();


CREATE FUNCTION update_cond() RETURNS trigger AS $$
  DECLARE
    missatge missatgesExcepcions.texte%type;
  BEGIN
    IF (old.nempl = 123) THEN
      SELECT texte INTO missatge FROM missatgesExcepcions WHERE num = 1;
      RAISE EXCEPTION '%', missatge;
    ELSE RETURN NEW;
    END IF;

  EXCEPTION
    WHEN raise_exception THEN RAISE EXCEPTION '%', SQLERRM;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_trigger BEFORE UPDATE OF nempl ON empleats FOR EACH ROW
EXECUTE PROCEDURE update_cond();


-- Pregunta 2 enunciat
/* Implementar mitjançant disparadors la restricció d'integritat següent:
No es poden esborrar empleats el dijous
Tigueu en compte que:
- Les restriccions d'integritat definides a la BD (primary key, foreign key,...)
es violen amb menys freqüència que la restricció comprovada per aquests disparadors.
- El dia de la setmana serà el que indiqui la única fila que hi ha d'haver sempre
insertada a la taula "dia". Com podreu veure en el joc de proves que trobareu al
fitxer adjunt, el dia de la setmana és el 'dijous'. Per fer altres proves podeu
modificar la fila de la taula amb el nom d'un altre dia de la setmana.
IMPORTANT: Tant en el programa com en la base de dades poseu el nom del dia de
la setmana en MINÚSCULES.

Cal informar dels errors a través d'excepcions tenint en compte les situacions
tipificades a la taula missatgesExcepcions, que podeu trobar definida (amb els
inserts corresponents) al fitxer adjunt. Concretament en el vostre procediment
heu d'incloure, quan calgui, les sentències:
SELECT texte INTO missatge FROM missatgesExcepcions WHERE num=__;(el número que sigui, depenent de l'error)
RAISE EXCEPTION '%',missatge;
La variable missatge ha de ser una variable definida al vostre procediment, i
del mateix tipus que l'atribut corresponent de l'esquema de la base de dades.

Pel joc de proves que trobareu al fitxer adjunt i la instrucció:
DELETE FROM empleats WHERE salari<=1000
la sortida ha de ser:

No es poden esborrar empleats el dijous */

CREATE TABLE empleats(
  nempl integer primary key,
  salari integer);

insert into empleats values(1,1000);

insert into empleats values(2,2000);

insert into empleats values(123,3000);

CREATE TABLE dia(
dia char(10));

insert into dia values('dijous');

create table missatgesExcepcions(
	num integer,
	texte varchar(50)
	);
insert into missatgesExcepcions values(1,'No es poden esborrar empleats el dijous');

-- Pregunta 2 solució
CREATE FUNCTION delete_cond() RETURNS trigger AS $$
  DECLARE
    d dia.dia%type;
    missatge missatgesExcepcions.texte%type;

  BEGIN
    SELECT dia INTO d FROM dia;
    IF (d = 'dijous') THEN
      SELECT texte INTO missatge FROM missatgesExcepcions WHERE num = 1;
      RAISE EXCEPTION '%', missatge;
    ELSE RETURN OLD;
    END IF;

  EXCEPTION
    WHEN raise_exception THEN RAISE EXCEPTION '%', SQLERRM;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger BEFORE DELETE ON empleats FOR EACH STATEMENT
EXECUTE PROCEDURE delete_cond();

-- Pregunta 3 enunciat
/* En aquest exercici es tracta de simular una asserció a base de definir
disparadors. En concret, es demana definir els disparadors necessaris sobre
empleats1 (veure definició de la base de dades al fitxer adjunt) per comprovar
la restricció següent:
Els valors de l'atribut ciutat1 de la taula empleats1 han d'estar inclosos en
els valors de ciutat2 de la taula empleats2
La idea és llançar una excepció en cas que s'intenti executar una sentència
sobre EMPLEATS1 que pugui violar aquesta restricció.

Cal informar dels errors a través d'excepcions tenint en compte les situacions
tipificades a la taula missatgesExcepcions, que podeu trobar definida i amb els
inserts corresponents al fitxer adjunt. Concretament en el vostre procediment
heu d'incloure, quan calgui, les sentències:
SELECT texte INTO missatge FROM missatgesExcepcions WHERE num=__ (segons l'error 1,2,...);
RAISE EXCEPTION '%',missatge;
La variable missatge ha de ser una variable definida al vostre procediment.

Pel joc de proves que trobareu al fitxer adjunt i la sentència:
INSERT INTO empleats1 VALUES (1,'joan','mad');
La sortida ha de ser:

Els valors de l'atribut ciutat1 d'empleats1 han d''estar inclosos en els valors de ciutat2 */

create table empleats1 (nemp1 integer primary key, nom1 char(25), ciutat1 char(10) not null);

create table empleats2 (nemp2 integer primary key, nom2 char(25), ciutat2 char(10) not null);

create table missatgesExcepcions(
	num integer,
	texte varchar(100)
	);


insert into missatgesExcepcions values(1,' Els valors de l''atribut ciutat1 d''empleats1  han d''estar inclosos en els valors de ciutat2');

insert into empleats2 values(1,'joan','bcn');

-- Pregunta 3 solució
CREATE FUNCTION ciutats_cond() RETURNS trigger AS $$
  DECLARE
    c2 empleats2.ciutat2%TYPE;
    missatge missatgesExcepcions.texte%TYPE;

  BEGIN
    SELECT * INTO c2 FROM empleats2 WHERE ciutat2 = NEW.ciutat1;
    IF FOUND THEN RETURN NEW;
    ELSE
      SELECT texte INTO missatge FROM missatgesExcepcions WHERE num = 1;
      RAISE EXCEPTION '%', missatge;
      RETURN NULL;
    END IF;

  EXCEPTION
    WHEN raise_exception THEN RAISE EXCEPTION '%', SQLERRM;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_insert BEFORE INSERT ON empleats1 FOR EACH ROW
EXECUTE PROCEDURE ciutats_cond();

CREATE TRIGGER trigger_update BEFORE UPDATE OF ciutat1 ON empleats1 FOR EACH ROW
EXECUTE PROCEDURE ciutats_cond();

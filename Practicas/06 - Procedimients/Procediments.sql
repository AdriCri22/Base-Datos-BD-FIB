
-- Sentències de preparació de la base de dades:
create table cotxes(
	matricula char(10) primary key,
	marca char(20) not null,
	model char(20) not null,
	categoria integer not null,
	color char(10),
	any_fab integer
	);
create table treballadors(
	dni char(8) primary key,
	nom char(30) not null,
	sou_base real not null,
	plus real not null
	);
create table lloguers_actius(
	matricula char(10) primary key    references cotxes,
	dni char(8) not null constraint fk_treb  references treballadors,
	num_dies integer not null,
	preu_total real not null
	);

create table missatgesExcepcions(
	num integer,
	texte varchar(50)
	);
insert into missatgesExcepcions values(1,'No hi ha cap tupla dins del interval demanat');
insert into missatgesExcepcions values(2, 'Error intern');

--------------------------
-- Joc de proves Public
--------------------------

-- Sentències de neteja de les taules:
delete from lloguers_actius;
delete from treballadors;
delete from cotxes;

-- Sentències d'inicialització:
insert into cotxes values ('1111111111','Audi','A4',1,'Vermell',1998);
insert into cotxes values ('2222222222','Audi','A3',2,'Blanc',1998);
insert into cotxes values ('3333333333','Volskwagen','Golf',2,'Blau',1990);
insert into cotxes values ('4444444444','Toyota','Corola',3,'groc',1999);
insert into cotxes values ('5555555555','Honda','Civic',3,'Vermell',2000);
insert into cotxes values ('6666666666','BMW','Mini',2,'Vermell',2000);

insert into treballadors values ('22222222','Joan',1700,150);

insert into lloguers_actius values ('1111111111','22222222',7,750);
insert into lloguers_actius values ('2222222222','22222222',5,550);
insert into lloguers_actius values ('3333333333','22222222',4,450);
insert into lloguers_actius values ('4444444444','22222222',8,850);
insert into lloguers_actius values ('5555555555','22222222',2,250);



--Pregunta 1
CREATE TYPE dades AS (
  dni char(8),
  nom char(30),
  sou real,
  plus real,
  matricula char(10));

CREATE FUNCTION llistat_treb(dniIni treballadors.dni%type, dniFi treballadors.dni%type)
RETURNS SETOF dades AS $$
DECLARE
  dades dades;
  missatge varchar(50);

BEGIN
  FOR dades IN SELECT t.dni, t.nom, t.sou_base, t.plus
               FROM treballadors t
               WHERE dniIni <= t.dni AND t.dni <= dniFi
  LOOP
    IF (5 <= (SELECT COUNT(*)
              FROM lloguers_actius a
              WHERE dades.dni = a.dni)) THEN FOR dades.matricula IN (SELECT a2.matricula
                                                                 FROM lloguers_actius a2
                                                                 WHERE dades.dni = a2.dni)
                                             LOOP RETURN NEXT dades;
                                             END LOOP;
    ELSE RETURN NEXT dades;
    END IF;
  END LOOP;
  IF not found THEN
    SELECT texte INTO missatge FROM missatgesExcepcions WHERE num = 1;
    RAISE EXCEPTION '%', missatge;
  END IF;

  EXCEPTION
    WHEN raise_exception THEN RAISE EXCEPTION '%', SQLERRM;
    WHEN OTHERS THEN
      SELECT texte INTO missatge FROM missatgesExcepcions WHERE num = 2;
      RAISE EXCEPTION '%', missatge;
END;
$$LANGUAGE plpgsql;

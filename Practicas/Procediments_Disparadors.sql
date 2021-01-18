-- Pregunta 1 enunciat
/* En aquest exercici es tracta de mantenir de manera automàtica, mitjançant triggers, l'atribut derivat import de la taula comandes.

En concret, l'import d'una comanda és igual a la suma dels resultats de multiplicar per cada línia de comanda, la quantitat del producte de la línia pel preu del producte .

Només heu de considerar les operacions de tipus INSERT sobre la taula línies de comandes.

Pel joc de proves que trobareu al fitxer adjunt, i la sentència: INSERT INTO liniesComandes VALUES (110, 'p111', 2);
La sentència s'executarà sense cap problema, i l'estat de la taula de comandes després de la seva execució ha de ser:

numcomanda		instantfeta		instantservida		numtelf		import
110		1091		1101		null		30 */

-- Sentències de preparació de la base de dades:
create table productes
(idProducte char(9),
nom char(20),
mida char(20),
preu integer check(preu>0),
primary key (idProducte),
unique (nom,mida));

create table domicilis
(numTelf char(9),
nomCarrer char(20),
numCarrer integer check(numCarrer>0),
pis char(2),
porta char(2),
primary key (numTelf));

create table comandes
(numComanda integer check(numComanda>0),
instantFeta integer not null check(instantFeta>0),
instantServida integer check(instantServida>0),
numTelf char(9),
import integer ,
primary key (numComanda),
foreign key (numTelf) references domicilis,
check (instantServida>instantFeta));
-- numTelf es el numero de telefon del domicili des don sha
-- fet la comanda. Pot tenir valor nul en cas que la comanda
-- sigui de les de recollir a la botiga.

create table liniesComandes
(numComanda integer,
idProducte char(9),
quantitat integer check(quantitat>0),
primary key(numComanda,idProducte),
foreign key (idProducte) references productes,
foreign key (numComanda) references comandes
);
-- quantitat es el numero d'unitats del producte que sha demanat
-- a la comanda

insert into productes values ('p111', '4 formatges', 'gran', 10);

insert into productes values ('p222', 'margarita', 'gran', 5);

insert into comandes(numComanda,instantfeta,instantservida,numtelf, import) values (110, 1091, 1101, null, 10);

insert into liniesComandes values (110, 'p222', 2);

-- Pregunta 1 solució
CREATE FUNCTION cond() RETURNS trigger AS $$
  DECLARE
    import_antic comandes.import%TYPE;

  BEGIN
    import_antic := (SELECT import FROM comandes WHERE numComanda = NEW.numComanda);

    UPDATE comandes
    SET import = import_antic +  NEW.quantitat * (SELECT preu FROM productes WHERE idProducte = NEW.idProducte)
    WHERE numComanda = NEW.numComanda;

  RETURN NULL;
END;
$$LANGUAGE plpgsql;

CREATE TRIGGER insert_linia_comandes AFTER INSERT ON liniesComandes FOR EACH ROW
EXECUTE PROCEDURE cond();

INSERT INTO liniesComandes VALUES (110, 'p111', 2);


-- Pregunta 2 enunciat
/* Disposem de la base de dades del fitxer adjunt que gestiona clubs esportius i
socis d'aquests clubs. Cal implementar un procediment emmagatzemat
"assignar_individual(nomSoci,nomClub)".

El procediment ha de:
- Enregistrar l'assignació del soci nomSoci al club nomClub, inserint la fila
corresponent a la taula Socisclubs.
- Si el club nomClub passa a tenir més de 5 socis, inserir el club a la taula
  Clubs_amb_mes_de_5_socis.
- El procediment no retorna cap resultat.

Les situacions d'error que cal identificar són les tipificades a la taula missatgesExcepcions.
Quan s'identifiqui una d'aquestes situacions cal generar una excepció:
SELECT texte INTO missatge FROM missatgesExcepcions WHERE num=___; ( 1 .. 5, depenent de l'error)
RAISE EXCEPTION '%',missatge; (missatge ha de ser una variable definida al vostre procediment)

Suposem el joc de proves que trobareu al fitxer adjunt i la sentència
select * from assignar_individual('anna','escacs');
La sentència s'executarà sense cap problema, i l'estat de la base de dades
just després ha de ser:

Taula Socisclubs
anna	escacs
joanna	petanca
josefa	petanca
pere	petanca
Taula clubs_amb_mes_de_5_soci
sense cap fila */

-- Sentències de preparació de la base de dades:
create table socis ( nsoci char(10) primary key, sexe char(1) not null);

create table clubs ( nclub char(10) primary key);

create table socisclubs (nsoci char(10) not null references socis,
  nclub char(10) not null references clubs,
  primary key(nsoci, nclub));

create table clubs_amb_mes_de_5_socis (nclub char(10) primary key references clubs);

create table missatgesExcepcions(
	num integer,
	texte varchar(50)
	);


insert into missatgesExcepcions values(1, 'Club amb mes de 10 socis');
insert into missatgesExcepcions values(2, 'Club amb mes homes que dones');
insert into missatgesExcepcions values(3, 'Soci ja assignat a aquest club');
insert into missatgesExcepcions values(4, 'O el soci o el club no existeixen');
insert into missatgesExcepcions values(5, 'Error intern');

insert into clubs values ('escacs');
insert into clubs values ('petanca');

insert into socis values ('anna','F');

insert into socis values ('joanna','F');
insert into socis values ('josefa','F');
insert into socis values ('pere','M');

insert into socisclubs values('joanna','petanca');
insert into socisclubs values('josefa','petanca');
insert into socisclubs values('pere','petanca');

-- Pregunta 2 solució
CREATE FUNCTION assignar_individual(nomSoci socisclubs.nsoci%TYPE,
          nomClub socisclubs.nclub%TYPE) RETURNS void AS $$
  DECLARE
    numSocis integer;
    missatge missatgesExcepcions.texte%TYPE;

  BEGIN
    INSERT INTO socisclubs VALUES(nomSoci, nomClub);
    numSocis := (SELECT COUNT(*) FROM socisclubs WHERE nclub = nomClub);

    IF (numSocis = 6)
        THEN
          INSERT INTO clubs_amb_mes_de_5_socis VALUES (nomClub);
    END IF;

    IF (numSocis > 10)
        THEN
          SELECT texte INTO missatge FROM missatgesExcepcions WHERE num = 1;
          RAISE EXCEPTION '%', missatge;
    END IF;

    IF ((SELECT COUNT(*) FROM socisclubs sc NATURAL INNER JOIN socis s
          WHERE sc.nclub = nomClub AND s.sexe = 'M') > (numSocis / 2))
        THEN
          SELECT texte INTO missatge FROM missatgesExcepcions WHERE num = 2;
          RAISE EXCEPTION '%', missatge;
    END IF;

    EXCEPTION
      WHEN raise_exception THEN RAISE EXCEPTION '%', SQLERRM;
      WHEN unique_violation THEN
        SELECT texte INTO missatge FROM missatgesExcepcions WHERE num = 3;
        RAISE EXCEPTION '%', missatge;
      WHEN foreign_key_violation THEN
        SELECT texte INTO missatge FROM missatgesExcepcions WHERE num = 4;
        RAISE EXCEPTION '%', missatge;
      WHEN OTHERS THEN
        SELECT texte INTO missatge FROM missatgesExcepcions WHERE num = 5;
        RAISE EXCEPTION '%', missatge;
END;
$$LANGUAGE plpgsql;

select * from assignar_individual('anna','escacs');

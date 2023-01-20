/* Pap Alexandre */
/* Pruvost Alban */
/* BUT2 TD1 TPA */
/* SAE Coupe Du Monde De Tennis Groupe 7 */

/* Tables et Tuples */

/* Création des tables */

CREATE TABLE nationalite 
(
    id_nationalite INTEGER PRIMARY KEY, 
    libelle_nationalite VARCHAR(250)
);

CREATE TABLE joueur
(
    id_joueur INTEGER PRIMARY KEY,
    id_nationalite INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    nom VARCHAR(250),
    prenom VARCHAR(250),
    datenai VARCHAR(250)
);

CREATE TABLE stade
(
    id_stade INTEGER PRIMARY KEY,
    nom_stade VARCHAR(250),
    capacite_stade INTEGER,
    pays_stade VARCHAR(250)
);

CREATE TABLE classement_un_seize
(
    id_joueur INTEGER NOT NULL REFERENCES joueur(id_joueur),
    id_nationalite INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    nom VARCHAR(250),
    prenom VARCHAR(250),
    datenai VARCHAR(250),
    statut VARCHAR(250),
    score_joueur INTEGER
);

CREATE TABLE match_un_seize
(
    id_match INTEGER PRIMARY KEY,
    date_match DATE,
    type_match VARCHAR(250),
    poule VARCHAR(250),
    id_stade INTEGER NOT NULL REFERENCES stade(id_stade),
    nb_spectateurs INTEGER,
    id_joueur_a INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    id_joueur_b INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    score_joueur_a INTEGER,
    score_joueur_b INTEGER
);

CREATE TABLE classement_un_huit
(
    id_joueur INTEGER NOT NULL REFERENCES joueur(id_joueur),
    id_nationalite INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    nom VARCHAR(250),
    prenom VARCHAR(250),
    datenai VARCHAR(250),
    statut VARCHAR(250),
    score_joueur INTEGER
);

CREATE TABLE match_un_huit
(
    id_match INTEGER PRIMARY KEY,
    date_match DATE,
    type_match VARCHAR(250),
    id_stade INTEGER NOT NULL REFERENCES stade(id_stade),
    nb_spectateurs INTEGER,
    id_joueur_a INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    id_joueur_b INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    score_joueur_a INTEGER,
    score_joueur_b INTEGER
);

CREATE TABLE classement_quart
(
    id_joueur INTEGER NOT NULL REFERENCES joueur(id_joueur),
    id_nationalite INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    nom VARCHAR(250),
    prenom VARCHAR(250),
    datenai VARCHAR(250),
    statut VARCHAR(250),
    score_joueur INTEGER
);

CREATE TABLE match_quart
(
    id_match INTEGER PRIMARY KEY,
    date_match DATE,
    type_match VARCHAR(250),
    id_stade INTEGER NOT NULL REFERENCES stade(id_stade),
    nb_spectateurs INTEGER,
    id_joueur_a INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    id_joueur_b INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    score_joueur_a INTEGER,
    score_joueur_b INTEGER
);

CREATE TABLE classement_demie
(
    id_joueur INTEGER NOT NULL REFERENCES joueur(id_joueur),
    id_nationalite INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    nom VARCHAR(250),
    prenom VARCHAR(250),
    datenai VARCHAR(250),
    statut VARCHAR(250),
    score_joueur INTEGER
);

CREATE TABLE match_demie
(
    id_match INTEGER PRIMARY KEY,
    date_match DATE,
    type_match VARCHAR(250),
    id_stade INTEGER NOT NULL REFERENCES stade(id_stade),
    nb_spectateurs INTEGER,
    id_joueur_a INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    id_joueur_b INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    score_joueur_a INTEGER,
    score_joueur_b INTEGER
);

CREATE TABLE classement_finale
(
    id_joueur INTEGER NOT NULL REFERENCES joueur(id_joueur),
    id_nationalite INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    nom VARCHAR(250),
    prenom VARCHAR(250),
    datenai VARCHAR(250),
    score_joueur INTEGER
);

CREATE TABLE match_finale
(
    id_match INTEGER PRIMARY KEY,
    date_match DATE,
    type_match VARCHAR(250),
    id_stade INTEGER NOT NULL REFERENCES stade(id_stade),
    nb_spectateurs INTEGER,
    id_joueur_a INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    id_joueur_b INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    score_joueur_a INTEGER,
    score_joueur_b INTEGER
);

CREATE TABLE classement_general
(
    id_joueur INTEGER NOT NULL REFERENCES joueur(id_joueur),
    id_nationalite INTEGER NOT NULL REFERENCES nationalite(id_nationalite),
    nom VARCHAR(250),
    prenom VARCHAR(250),
    datenai VARCHAR(250),
    score_joueur INTEGER
);

/* Insertion des tuples */

INSERT INTO NATIONALITE VALUES (1, 'FRANCE');
INSERT INTO NATIONALITE VALUES (2, 'EQUATEUR');
INSERT INTO NATIONALITE VALUES (3, 'ESPAGNE');
INSERT INTO NATIONALITE VALUES (4, 'ROUMANIE');
INSERT INTO NATIONALITE VALUES (5, 'ETATS-UNIS');
INSERT INTO NATIONALITE VALUES (6, 'COLOMBIE');
INSERT INTO NATIONALITE VALUES (7, 'PAYS-BAS');
INSERT INTO NATIONALITE VALUES (8, 'CANADA');
INSERT INTO NATIONALITE VALUES (9, 'BRESIL');
INSERT INTO NATIONALITE VALUES (10, 'ALLEMAGNE');
INSERT INTO NATIONALITE VALUES (11, 'SLOVAQUIE');
INSERT INTO NATIONALITE VALUES (12, 'ITALIE');
INSERT INTO NATIONALITE VALUES (13, 'AUSTRALIE');
INSERT INTO NATIONALITE VALUES (14, 'HONGRIE');
INSERT INTO NATIONALITE VALUES (15, 'NORVEGE');
INSERT INTO NATIONALITE VALUES (16, 'KAZAKHSTAN');
INSERT INTO NATIONALITE VALUES (17, 'SUEDE');
INSERT INTO NATIONALITE VALUES (18, 'JAPON');
INSERT INTO NATIONALITE VALUES (19, 'ARGENTINE');
INSERT INTO NATIONALITE VALUES (20, 'REP-TCHEQUE');
INSERT INTO NATIONALITE VALUES (21, 'COREE-DU-SUD');
INSERT INTO NATIONALITE VALUES (22, 'AUTRICHE');
INSERT INTO NATIONALITE VALUES (23, 'FINLANDE');
INSERT INTO NATIONALITE VALUES (24, 'BELGIQUE');
INSERT INTO NATIONALITE VALUES (25, 'FRANCE');
INSERT INTO NATIONALITE VALUES (26, 'FRANCE');
INSERT INTO NATIONALITE VALUES (27, 'FRANCE');
INSERT INTO NATIONALITE VALUES (28, 'FRANCE');
INSERT INTO NATIONALITE VALUES (29, 'FRANCE');
INSERT INTO NATIONALITE VALUES (30, 'FRANCE');
INSERT INTO NATIONALITE VALUES (31, 'FRANCE');
INSERT INTO NATIONALITE VALUES (32, 'FRANCE');

INSERT INTO STADE VALUES (1, 'Arthur Ashe Stadium', 23771, 'ETATS-UNIS');
INSERT INTO STADE VALUES (2, 'O2 Arena', 20000, 'ROYAUME-UNI');
INSERT INTO STADE VALUES (3, 'Indian Wells Tennis Garden', 16000, 'ETATS-UNIS');
INSERT INTO STADE VALUES (4, 'Bercy Arena', 20300, 'FRANCE');

insert into JOUEUR values (1, 1, 'MONFILS', 'GAEL', '1986');
insert into JOUEUR values (2, 2, 'GOMEZ', 'EMILIO', '1991');
insert into JOUEUR values (3, 3, 'ALCARAZ', 'CARLOS', '2003');
insert into JOUEUR values (4, 4, 'COPIL', 'MARCUS', '1990');
insert into JOUEUR values (5, 5, 'CORDA', 'SEBASTIAN', '2000');
insert into JOUEUR values (6, 6, 'MEJIA', 'NICOLAS', '2000');
insert into JOUEUR values (7, 7, 'GRIEKSPOOR', 'TALLON', '1996');
insert into JOUEUR values (8, 8, 'DIEZ', 'STEVEN', '1991');
insert into JOUEUR values (9, 9, 'MONTEIRO', 'THIAGO', '1994');
insert into JOUEUR values (10, 10, 'ZVEREV', 'ALEXANDER', '1997');
insert into JOUEUR values (11, 11, 'GOMBOS', 'NORBERT', '1990');
insert into JOUEUR values (12, 12, 'SINNER', 'JANNIK', '2001');
insert into JOUEUR values (13, 13, 'KOKINNAKIS', 'THANASI', '1999');
insert into JOUEUR values (14, 14, 'PIROS', 'ZSOMBOR', '1986');
insert into JOUEUR values (15, 15, 'RUUD', 'CASPER', '1998');
insert into JOUEUR values (16, 16, 'BUBLIK', 'ALEXANDER', '1997');
insert into JOUEUR values (17, 17, 'YMER', 'ELIAS', '1997');
insert into JOUEUR values (18, 18, 'DIANEL', 'TARO', '1993');
insert into JOUEUR values (19, 19, 'BAEZ', 'SEBASTIAN', '2000');
insert into JOUEUR values (20, 20, 'MACHAC', 'TOMAS', '2000');
insert into JOUEUR values (21, 21, 'NOVAK', 'DENNIS', '1993');
insert into JOUEUR values (22, 22, 'NAM', 'JISUNG', '1993');
insert into JOUEUR values (23, 23, 'VIRTANNEN', 'OTTO', '2001');
insert into JOUEUR values (24, 24, 'GOFFIN', 'DAVID', '1990');
insert into JOUEUR values (25, 25, 'LAURENT', 'SYLVAIN', '1992');
insert into JOUEUR values (26, 26, 'YOURI', 'ALBERT', '1993');
insert into JOUEUR values (27, 27, 'PAUL', 'ROGER', '1994');
insert into JOUEUR values (28, 28, 'RAFAEL', 'MARTIN', '1995');
insert into JOUEUR values (29, 29, 'GAUTHIER', 'ERWANN', '1995');
insert into JOUEUR values (30, 30, 'MATHIEU', 'LUCAS', '1996');
insert into JOUEUR values (31, 31, 'AURELIAN', 'MAXIME', '1997');
insert into JOUEUR values (32, 32, 'THOMAS', 'CAMILLE', '1998');
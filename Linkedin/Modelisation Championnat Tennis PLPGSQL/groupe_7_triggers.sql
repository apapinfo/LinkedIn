/* Pap Alexandre */
/* Pruvost Alban */
/* BUT2 TD1 TPA */
/* SAE Coupe Du Monde De Tennis Groupe 7 */

/* Fonctions et Triggers */

CREATE OR REPLACE FUNCTION championnat()
RETURNS VOID AS $$
BEGIN
    /* Si des joueurs existent déjà dans le classement des 1/16e de finale */
    IF EXISTS (SELECT * FROM classement_un_seize) THEN
        RAISE NOTICE 'Un nouveau championnat va commencer';
        /* On réactualise toutes les tables pour commencer un nouveau championnat */
        TRUNCATE TABLE classement_un_seize;
        TRUNCATE TABLE match_un_seize;
        TRUNCATE TABLE classement_un_huit;
        TRUNCATE TABLE match_un_huit;
        TRUNCATE TABLE classement_quart;
        TRUNCATE TABLE match_quart;
        TRUNCATE TABLE classement_demie;
        TRUNCATE TABLE match_demie;
        TRUNCATE TABLE classement_finale;
        TRUNCATE TABLE match_finale;
        TRUNCATE TABLE classement_general;
    END IF;
    /* On insère 32 joueurs mélangés de façon aléatoire dans le classement des 1/16e de finale */
    INSERT INTO classement_un_seize (id_joueur, id_nationalite, nom, prenom, datenai) SELECT * FROM joueur ORDER BY RANDOM();
    RAISE NOTICE 'Le Championnat commence';
END;
$$LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION match_un_seize()
RETURNS TRIGGER AS $$
DECLARE
    vmax_idstade STADE.id_stade%TYPE;
    vmin_idstade STADE.id_stade%TYPE;
    vid_stade STADE.id_stade%TYPE;
    vmax_nb_spectateurs STADE.capacite_stade%TYPE;
    vnumero_poule INTEGER;
    vnb INTEGER;
    vindice_ligne_joueur_a INTEGER;
    vindice_ligne_joueur_b INTEGER;
    vnb_spectateurs STADE.capacite_stade%TYPE;
    vid_joueur_a match_un_seize.id_joueur_a%TYPE;
    vid_joueur_b match_un_seize.id_joueur_b%TYPE;
    vscore_joueur_a match_un_seize.score_joueur_a%TYPE;
    vscore_joueur_b match_un_seize.score_joueur_b%TYPE;
BEGIN
    /* On sélectionne l'indice maximal de id_stade dans la table stade */
    SELECT MAX(stade.id_stade) FROM stade INTO vmax_idstade;
    /* On sélectionne l'indice minimal de id_stade dans la table stade */
    SELECT MIN(stade.id_stade) FROM stade INTO vmin_idstade;
    /* On sélectionne un indice de stade aléatoire (stade qui accueillera tous les matchs de 1/16e de finale) */
    SELECT FLOOR(RANDOM() * ( vmax_idstade - vmin_idstade + 1) + vmin_idstade) INTO vid_stade;
    /* On sélectionne la capacité du stade où se déroulent les matchs de 1/16e de finale */
    SELECT stade.capacite_stade FROM stade WHERE stade.id_stade = vid_stade INTO vmax_nb_spectateurs;

    /* On attribue à chaque match de 1/16e de finale un numéro de poule (de 1 à 8 car 8 poules) qu'on initialise à 0 */
    vnumero_poule := 0;
    /* On introduit une variable qui représentera l'id d'un match de 1/16e de finale ainsi que la date du match de 1/16e de finale qu'on initialise à 0 */
    vnb := 0;
    /* On introduit un premier indice de ligne où se trouvera l'indice du joueur d'un match de 1/16e de finale dans la table poule qu'on initialise à 1 */
    vindice_ligne_joueur_a := 1;

    /* Pour chaque combinaison de matchs de 1/16e de finale (de 1 à 8 car 8 combinaisons possibles de 4 joueurs dans les 8 poules) */
    FOR combinaison IN 1..8
    LOOP
        /* On attribue à chaque match de 1/16e de finale de chaque combinaison un numéro de poule */
        vnumero_poule := vnumero_poule + 1;

        /* Pour chaque numéro de joueur de la poule (sauf le dernier car celui-ci affrontera l'avant-dernier) */
        FOR num_joueur IN 1..3
        LOOP

            /* On introduit une variable qui représentera le deuxième indice de ligne (car 2 parmi 4 pour chacune des 8 combinaisons possibles) où se trouvera l'indice du joueur adverse du même match de 1/16e de finale dans la table classement_un_seize */
            vindice_ligne_joueur_b := (num_joueur - 2);

            /* Pour chaque nombre de permutations possibles suivant les joueurs de la combinaison */
            FOR nb_permutations IN 1..-num_joueur+4
            LOOP

                /* Le deuxième indice de ligne augmente de 1 pour compléter la combinaison */
                vindice_ligne_joueur_b := vindice_ligne_joueur_b + 1;

                /* A chaque match de 1/16e de finale opposant deux joueurs, on associe un id de match ainsi qu'une date de match */
                vnb := vnb + 1;

                /* On sélectionne un nombre aléatoire de spectateurs pour chaque match de 1/16e de finale */
                SELECT FLOOR(RANDOM() * ( vmax_nb_spectateurs - 1 + 1) + 1) INTO vnb_spectateurs;

                /* On sélectionne le premier joueur suivant le premier indice de ligne pour un match de 1/16e de finale sur les 6 matchs possibles pour chaque poule dans la table classement_un_seize */
                SELECT id_joueur FROM classement_un_seize LIMIT 1 OFFSET vindice_ligne_joueur_a - 1 + (num_joueur - 1) INTO vid_joueur_a;
                /* On sélectionne le deuxième joueur (joueur adverse) suivant le deuxième indice de ligne pour le même match de 1/16e de finale dans la table classement_un_seize */
                SELECT id_joueur FROM classement_un_seize LIMIT 1 OFFSET vindice_ligne_joueur_a + vindice_ligne_joueur_b INTO vid_joueur_b;

                /* On attribue à chacun des deux joueurs un score */
                SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_a;
                SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_b;

                /* Si les deux joueurs ont le même score */
                IF vscore_joueur_a = vscore_joueur_b THEN
                    /* Tant qu'il y a égalité de score */
                    WHILE vscore_joueur_a = vscore_joueur_b
                    LOOP
                        /* On attribue un nouveau score en cas d'égalité au joueur a */
                        SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_a;
                    END LOOP;
                END IF;

                /* Insertion du match de 1/16e de finale dans la table match_un_seize */
                INSERT INTO match_un_seize VALUES (vnb, current_date + vnb, '1/16e de finale', 'Poule' || vnumero_poule, vid_stade, vnb_spectateurs, vid_joueur_a, vid_joueur_b, vscore_joueur_a, vscore_joueur_b);

            END LOOP;

        END LOOP;

        /* Pour la combinaison suivante de 2 joueurs parmi 4, l'indice de ligne du premier joueur change car 1 poule est composée de 4 joueurs uniques */
        vindice_ligne_joueur_a := 4 * combinaison + 1;

    END LOOP;
    
    /* Déclencheur du trigger */
    INSERT INTO match_un_seize VALUES (1000, NULL, NULL, NULL, 1, NULL, 1, 1, NULL, NULL);
    DELETE FROM match_un_seize WHERE id_match = 1000;

    RETURN OLD;

END;
$$LANGUAGE 'plpgsql';


CREATE TRIGGER match_un_seize
AFTER INSERT ON classement_un_seize
EXECUTE PROCEDURE match_un_seize();


CREATE OR REPLACE FUNCTION classement_un_seize()
RETURNS TRIGGER AS $$
BEGIN
    FOR i IN 1..8
    LOOP
        /* Mise à jour des qualifiés dans la table classement_un_seize suivant les premiers vainqueurs de chacune des 8 poules des matchs de 1/16e de finale */
        UPDATE classement_un_seize SET statut = 'Qualifié' WHERE id_joueur = (SELECT subquery2.id_des_joueurs FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poules, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total = (SELECT MAX(subquery2.score_total) FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2) LIMIT 1);
        /* Mise à jour des scores des qualifiés dans la table classement_un_seize les premiers vainqueurs de chacune des 8 poules des matchs de 1/16e de finale */
        UPDATE classement_un_seize SET score_joueur = (SELECT subquery2.score_total FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poules, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total = (SELECT MAX(subquery2.score_total) FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2) LIMIT 1) WHERE id_joueur = (SELECT subquery2.id_des_joueurs FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poules, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total = (SELECT MAX(subquery2.score_total) FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2) LIMIT 1);

        /* Mise à jour des qualifiés dans la table classement_un_seize suivant les deuxièmes vainqueurs de chacune des 8 poules des matchs de 1/16e de finale */
        UPDATE classement_un_seize SET statut = 'Qualifié' WHERE id_joueur = (SELECT subquery3.id_des_joueurs FROM (SELECT subquery2.id_des_joueurs, subquery2.poules AS poule, subquery2.score_total FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poules, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total NOT IN (SELECT subquery2.score_total FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total = (SELECT MAX(subquery2.score_total) FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2))) as subquery3 WHERE subquery3.score_total = (SELECT MAX(subquery3.score_total) FROM (SELECT subquery2.id_des_joueurs, subquery2.poules AS poule, subquery2.score_total FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poules, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total NOT IN (SELECT subquery2.score_total FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total = (SELECT MAX(subquery2.score_total) FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2))) as subquery3) LIMIT 1);
        /* Mise à jour des scores des qualifiés dans la table classement_un_seize les deuxièmes vainqueurs de chacune des 8 poules des matchs de 1/16e de finale */
        UPDATE classement_un_seize SET score_joueur = (SELECT subquery3.score_total FROM (SELECT subquery2.id_des_joueurs, subquery2.poules AS poule, subquery2.score_total FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poules, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total NOT IN (SELECT subquery2.score_total FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total = (SELECT MAX(subquery2.score_total) FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2))) as subquery3 WHERE subquery3.score_total = (SELECT MAX(subquery3.score_total) FROM (SELECT subquery2.id_des_joueurs, subquery2.poules AS poule, subquery2.score_total FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poules, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total NOT IN (SELECT subquery2.score_total FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total = (SELECT MAX(subquery2.score_total) FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2))) as subquery3) LIMIT 1) WHERE id_joueur = (SELECT subquery3.id_des_joueurs FROM (SELECT subquery2.id_des_joueurs, subquery2.poules AS poule, subquery2.score_total FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poules, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total NOT IN (SELECT subquery2.score_total FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total = (SELECT MAX(subquery2.score_total) FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2))) as subquery3 WHERE subquery3.score_total = (SELECT MAX(subquery3.score_total) FROM (SELECT subquery2.id_des_joueurs, subquery2.poules AS poule, subquery2.score_total FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poules, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total NOT IN (SELECT subquery2.score_total FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2 WHERE subquery2.score_total = (SELECT MAX(subquery2.score_total) FROM (SELECT subquery1.id_joueurs AS id_des_joueurs, subquery1.poule AS poule, SUM(subquery1.score) as score_total FROM (SELECT id_joueur_a as id_joueurs, poule, SUM(score_joueur_a) AS score FROM match_un_seize GROUP BY id_joueur_a, poule UNION (SELECT id_joueur_b, poule, SUM(score_joueur_b) AS score FROM match_un_seize GROUP BY id_joueur_b, poule)) as subquery1 WHERE subquery1.poule = 'Poule' || i GROUP BY id_des_joueurs, poule ORDER BY poule) as subquery2))) as subquery3) LIMIT 1);
    END LOOP;

    /* Insertion et mélange de façon aléatoire des joueurs qualifiés qui joueront les matchs de 1/8e de finale */
    INSERT INTO classement_un_huit (id_joueur, id_nationalite, nom, prenom, datenai) SELECT classement_un_seize.id_joueur, classement_un_seize.id_nationalite, classement_un_seize.nom, classement_un_seize.prenom, classement_un_seize.datenai FROM classement_un_seize WHERE statut='Qualifié' ORDER BY RANDOM();

    RETURN OLD;
END;
$$LANGUAGE 'plpgsql';


CREATE TRIGGER classement_un_seize
AFTER DELETE ON match_un_seize
EXECUTE PROCEDURE classement_un_seize();


CREATE OR REPLACE FUNCTION match_un_huit()
RETURNS TRIGGER AS $$
DECLARE
    vmax_idstade STADE.id_stade%TYPE;
    vmin_idstade STADE.id_stade%TYPE;
    vid_stade STADE.id_stade%TYPE;
    vmax_nb_spectateurs STADE.capacite_stade%TYPE;
    vnb INTEGER;
    vid_match match_un_huit.id_match%TYPE;
    vindice_ligne_joueur INTEGER;
    vnb_spectateurs STADE.capacite_stade%TYPE;
    vid_joueur_a match_un_huit.id_joueur_a%TYPE;
    vid_joueur_b match_un_huit.id_joueur_b%TYPE;
    vscore_joueur_a match_un_huit.score_joueur_a%TYPE;
    vscore_joueur_b match_un_huit.score_joueur_b%TYPE;
BEGIN
    /* On sélectionne l'indice maximal dans la table stade */
    SELECT MAX(stade.id_stade) FROM stade INTO vmax_idstade;
    /* On sélectionne l'indice minimal dans la table stade */
    SELECT MIN(stade.id_stade) FROM stade INTO vmin_idstade;
    /* On sélectionne un indice de stade aléatoire (stade qui accueillera tous les matchs de 1/8e de finale) */
    SELECT FLOOR(RANDOM() * ( vmax_idstade - vmin_idstade + 1) + vmin_idstade) INTO vid_stade;
    /* On sélectionne la capacité du stade où se déroulent les matchs de 1/8e de finale */
    SELECT stade.capacite_stade FROM stade WHERE stade.id_stade = vid_stade INTO vmax_nb_spectateurs;

    /* On introduit une variable qui représentera la date du match de 1/8e de finale qu'on initialise à 48 (car 48ème jour du championnat) */
    vnb := 48;

    /* On introduit une variable qui représentera l'indice du match de 1/8e de finale qu'on initialise à 0 */
    vid_match := 0;

    /* On introduit un indice de ligne où se trouvera l'indice du joueur d'un match de 1/8e de finale dans la table classement_un_huit */
    vindice_ligne_joueur := 0;

    /* Tant que les 16 joueurs n'ont pas été assignés à des matchs de 1/8e de finale */
    WHILE vindice_ligne_joueur != 16
    LOOP
        /* Pour chacun des 2 joueurs d'un match de 1/8e de finale sur les 16 joueurs au total */
        FOR i IN vindice_ligne_joueur..vindice_ligne_joueur + 1
        LOOP
            /* Si le joueur est le joueur a */
            IF i = vindice_ligne_joueur THEN
                /* On sélectionne l'indice du joueur a dans la table classement_un_huit */
                SELECT id_joueur FROM classement_un_huit LIMIT 1 OFFSET i INTO vid_joueur_a;
            /* Si le joueur est le joueur b */
            ELSIF i = vindice_ligne_joueur + 1 THEN
                /* On sélectionne l'indice du joueur b dans la table classement_un_huit */
                SELECT id_joueur FROM classement_un_huit LIMIT 1 OFFSET i INTO vid_joueur_b;
                vid_match := vid_match + 1;
                /* A chaque match de 1/8e de finale opposant deux joueurs, on associe une date */
                vnb := vnb + 1;
                /* On sélectionne un nombre aléatoire de spectateurs pour chaque match de 1/8e de finale */
                SELECT FLOOR(RANDOM() * ( vmax_nb_spectateurs - 1 + 1) + 1) INTO vnb_spectateurs;

                /* On attribue à chacun des deux joueurs un score */
                SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_a;
                SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_b;

                /* Si les deux joueurs ont le même score */
                IF vscore_joueur_a = vscore_joueur_b THEN
                    /* Tant qu'il y a égalité de score */
                    WHILE vscore_joueur_a = vscore_joueur_b
                    LOOP
                        /* On attribue un nouveau score en cas d'égalité au joueur a */
                        SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_a;
                    END LOOP;
                END IF;

                /* Insertion du match de 1/8e de finale dans la table match_un_huit */
                INSERT INTO match_un_huit VALUES (vid_match, current_date + vnb, '1/8e de finale', vid_stade, vnb_spectateurs, vid_joueur_a, vid_joueur_b, vscore_joueur_a, vscore_joueur_b);

                /* Deux joueurs sont assignés pour chaque match de 1/8e de finale */
                vindice_ligne_joueur := vindice_ligne_joueur + 1 + 1;

            END IF;

        END LOOP;

    END LOOP;

    /* Déclencheur du trigger */
    INSERT INTO match_un_huit VALUES (1000, NULL, NULL, 1, NULL, 1, 1, NULL, NULL);
    DELETE FROM match_un_huit WHERE id_match = 1000;

    RETURN OLD;

END;
$$LANGUAGE 'plpgsql';


CREATE TRIGGER match_un_huit
AFTER INSERT ON classement_un_huit
EXECUTE PROCEDURE match_un_huit();


CREATE OR REPLACE FUNCTION classement_un_huit()
RETURNS TRIGGER AS $$
BEGIN
    FOR i IN 1..8
    LOOP
        /* Mise à jour des qualifiés dans la table classement_un_huit suivant les vainqueurs de chacun des matchs de 1/8e de finale */
        UPDATE classement_un_huit SET statut='Qualifié' WHERE id_joueur=(SELECT classement_un_huit.id_joueur FROM classement_un_huit INNER JOIN match_un_huit ON match_un_huit.id_joueur_a=classement_un_huit.id_joueur WHERE score_joueur_a > score_joueur_b AND id_match = i);
        UPDATE classement_un_huit SET statut='Qualifié' WHERE id_joueur=(SELECT classement_un_huit.id_joueur FROM classement_un_huit INNER JOIN match_un_huit ON match_un_huit.id_joueur_b=classement_un_huit.id_joueur WHERE score_joueur_b > score_joueur_a AND id_match = i);

        /* Mise à jour des scores des qualifiés dans la table classement_un_huit suivant les vainqueurs de chacun des matchs de 1/8e de finale */
        UPDATE classement_un_huit SET score_joueur=(SELECT match_un_huit.score_joueur_a FROM match_un_huit WHERE score_joueur_a > score_joueur_b AND id_match = i) WHERE id_joueur=(SELECT classement_un_huit.id_joueur FROM classement_un_huit INNER JOIN match_un_huit ON match_un_huit.id_joueur_a=classement_un_huit.id_joueur WHERE score_joueur_a > score_joueur_b AND id_match = i);
        UPDATE classement_un_huit SET score_joueur=(SELECT match_un_huit.score_joueur_b FROM match_un_huit WHERE score_joueur_b > score_joueur_a AND id_match = i) WHERE id_joueur=(SELECT classement_un_huit.id_joueur FROM classement_un_huit INNER JOIN match_un_huit ON match_un_huit.id_joueur_b=classement_un_huit.id_joueur WHERE score_joueur_b > score_joueur_a AND id_match = i);    
    END LOOP;

    /* Insertion et mélange de façon aléatoire des joueurs qualifiés qui joueront les matchs de quart de finale */
    INSERT INTO classement_quart (id_joueur, id_nationalite, nom, prenom, datenai) SELECT classement_un_huit.id_joueur, classement_un_huit.id_nationalite, classement_un_huit.nom, classement_un_huit.prenom, classement_un_huit.datenai FROM classement_un_huit WHERE statut='Qualifié' ORDER BY RANDOM();

    RETURN OLD;
END;
$$LANGUAGE 'plpgsql';


CREATE TRIGGER classement_un_huit
AFTER DELETE ON match_un_huit
EXECUTE PROCEDURE classement_un_huit();


CREATE OR REPLACE FUNCTION match_quart()
RETURNS TRIGGER AS $$
DECLARE
    vmax_idstade STADE.id_stade%TYPE;
    vmin_idstade STADE.id_stade%TYPE;
    vid_stade STADE.id_stade%TYPE;
    vmax_nb_spectateurs STADE.capacite_stade%TYPE;
    vnb INTEGER;
    vid_match match_quart.id_match%TYPE;
    vindice_ligne_joueur INTEGER;
    vnb_spectateurs STADE.capacite_stade%TYPE;
    vid_joueur_a match_quart.id_joueur_a%TYPE;
    vid_joueur_b match_quart.id_joueur_b%TYPE;
    vscore_joueur_a match_quart.score_joueur_a%TYPE;
    vscore_joueur_b match_quart.score_joueur_b%TYPE;
BEGIN
    /* On sélectionne l'indice maximal dans la table stade */
    SELECT MAX(stade.id_stade) FROM stade INTO vmax_idstade;
    /* On sélectionne l'indice minimal dans la table stade */
    SELECT MIN(stade.id_stade) FROM stade INTO vmin_idstade;
    /* On sélectionne un indice de stade aléatoire (stade qui accueillera tous les matchs de quart de finale) */
    SELECT FLOOR(RANDOM() * ( vmax_idstade - vmin_idstade + 1) + vmin_idstade) INTO vid_stade;
    /* On sélectionne la capacité du stade où se déroulent les matchs de quart de finale */
    SELECT stade.capacite_stade FROM stade WHERE stade.id_stade = vid_stade INTO vmax_nb_spectateurs;

    /* On introduit une variable qui représentera la date du match de quart de finale qu'on initialise à 56 (car 56ème jour du championnat) */
    vnb := 56;

    /* On introduit une variable qui représentera l'indice du match de quart de finale qu'on initialise à 0 */
    vid_match := 0;

    /* On introduit un indice de ligne où se trouvera l'indice du joueur d'un match de quart de finale dans la table classement_un_quart */
    vindice_ligne_joueur := 0;

    /* Tant que les 8 joueurs n'ont pas été assignés à des matchs de quart de finale */
    WHILE vindice_ligne_joueur != 8
    LOOP
        /* Pour chacun des 2 joueurs d'un match de quart de finale sur les 8 joueurs au total */
        FOR i IN vindice_ligne_joueur..vindice_ligne_joueur + 1
        LOOP
            /* Si le joueur est le joueur a */
            IF i = vindice_ligne_joueur THEN
                /* On sélectionne l'indice du joueur a dans la table classement_quart */
                SELECT id_joueur FROM classement_quart LIMIT 1 OFFSET i INTO vid_joueur_a;
            /* Si le joueur est le joueur b */
            ELSIF i = vindice_ligne_joueur + 1 THEN
                /* On sélectionne l'indice du joueur b dans la table classement_quart */
                SELECT id_joueur FROM classement_quart LIMIT 1 OFFSET i INTO vid_joueur_b;
                vid_match := vid_match + 1;
                /* A chaque match de quart de finale opposant deux joueurs, on associe une date */
                vnb := vnb + 1;
                /* On sélectionne un nombre aléatoire de spectateurs pour chaque match de quart de finale */
                SELECT FLOOR(RANDOM() * ( vmax_nb_spectateurs - 1 + 1) + 1) INTO vnb_spectateurs;

                /* On attribue à chacun des deux joueurs un score */
                SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_a;
                SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_b;

                /* Si les deux joueurs ont le même score */
                IF vscore_joueur_a = vscore_joueur_b THEN
                    /* Tant qu'il y a égalité de score */
                    WHILE vscore_joueur_a = vscore_joueur_b
                    LOOP
                        /* On attribue un nouveau score en cas d'égalité au joueur a */
                        SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_a;
                    END LOOP;
                END IF;

                /* Insertion du match de 1/8e de finale dans la table match_quart */
                INSERT INTO match_quart VALUES (vid_match, current_date + vnb, 'quart de finale', vid_stade, vnb_spectateurs, vid_joueur_a, vid_joueur_b, vscore_joueur_a, vscore_joueur_b);

                /* Deux joueurs sont assignés pour chaque match de quart de finale */
                vindice_ligne_joueur := vindice_ligne_joueur + 1 + 1;

            END IF;

        END LOOP;

    END LOOP;

    /* Déclencheur du trigger */
    INSERT INTO match_quart VALUES (1000, NULL, NULL, 1, NULL, 1, 1, NULL, NULL);
    DELETE FROM match_quart WHERE id_match = 1000;

    RETURN OLD;

END;
$$LANGUAGE 'plpgsql';


CREATE TRIGGER match_quart
AFTER INSERT ON classement_quart
EXECUTE PROCEDURE match_quart();


CREATE OR REPLACE FUNCTION classement_quart()
RETURNS TRIGGER AS $$
BEGIN
    FOR i IN 1..4
    LOOP
        /* Mise à jour des qualifiés dans la table classement_quart suivant les vainqueurs de chacun des matchs de quart de finale */
        UPDATE classement_quart SET statut='Qualifié' WHERE id_joueur=(SELECT classement_quart.id_joueur FROM classement_quart INNER JOIN match_un_huit ON match_un_huit.id_joueur_a=classement_quart.id_joueur WHERE score_joueur_a > score_joueur_b AND id_match = i);
        UPDATE classement_quart SET statut='Qualifié' WHERE id_joueur=(SELECT classement_quart.id_joueur FROM classement_quart INNER JOIN match_un_huit ON match_un_huit.id_joueur_b=classement_quart.id_joueur WHERE score_joueur_b > score_joueur_a AND id_match = i);

        /* Mise à jour des scores des qualifiés dans la table classement_quart suivant les vainqueurs de chacun des matchs de quart de finale */
        UPDATE classement_quart SET score_joueur=(SELECT match_quart.score_joueur_a FROM match_quart WHERE score_joueur_a > score_joueur_b AND id_match = i) WHERE id_joueur=(SELECT classement_quart.id_joueur FROM classement_quart INNER JOIN match_quart ON match_quart.id_joueur_a=classement_quart.id_joueur WHERE score_joueur_a > score_joueur_b AND id_match = i);
        UPDATE classement_quart SET score_joueur=(SELECT match_quart.score_joueur_b FROM match_quart WHERE score_joueur_b > score_joueur_a AND id_match = i) WHERE id_joueur=(SELECT classement_quart.id_joueur FROM classement_quart INNER JOIN match_quart ON match_quart.id_joueur_b=classement_quart.id_joueur WHERE score_joueur_b > score_joueur_a AND id_match = i);    
    END LOOP;

    /* Insertion et mélange de façon aléatoire des joueurs qualifiés qui joueront les matchs de demie finale */
    INSERT INTO classement_demie (id_joueur, id_nationalite, nom, prenom, datenai) SELECT classement_quart.id_joueur, classement_quart.id_nationalite, classement_quart.nom, classement_quart.prenom, classement_quart.datenai FROM classement_quart WHERE statut='Qualifié' ORDER BY RANDOM();

    RETURN OLD;
END;
$$LANGUAGE 'plpgsql';


CREATE TRIGGER classement_quart
AFTER DELETE ON match_quart
EXECUTE PROCEDURE classement_quart();


CREATE OR REPLACE FUNCTION match_demie()
RETURNS TRIGGER AS $$
DECLARE
    vmax_idstade STADE.id_stade%TYPE;
    vmin_idstade STADE.id_stade%TYPE;
    vid_stade STADE.id_stade%TYPE;
    vmax_nb_spectateurs STADE.capacite_stade%TYPE;
    vnb INTEGER;
    vid_match match_demie.id_match%TYPE;
    vindice_ligne_joueur INTEGER;
    vnb_spectateurs STADE.capacite_stade%TYPE;
    vid_joueur_a match_demie.id_joueur_a%TYPE;
    vid_joueur_b match_demie.id_joueur_b%TYPE;
    vscore_joueur_a match_demie.score_joueur_a%TYPE;
    vscore_joueur_b match_demie.score_joueur_b%TYPE;
BEGIN
    /* On sélectionne l'indice maximal dans la table stade */
    SELECT MAX(stade.id_stade) FROM stade INTO vmax_idstade;
    /* On sélectionne l'indice minimal dans la table stade */
    SELECT MIN(stade.id_stade) FROM stade INTO vmin_idstade;
    /* On sélectionne un indice de stade aléatoire (stade qui accueillera tous les matchs de demie finale) */
    SELECT FLOOR(RANDOM() * ( vmax_idstade - vmin_idstade + 1) + vmin_idstade) INTO vid_stade;
    /* On sélectionne la capacité du stade où se déroulent les matchs de demie finale */
    SELECT stade.capacite_stade FROM stade WHERE stade.id_stade = vid_stade INTO vmax_nb_spectateurs;

    /* On introduit une variable qui représentera la date du match de demie finale qu'on initialise à 60 (car 60ème jour du championnat) */
    vnb := 60;

    /* On introduit une variable qui représentera l'indice du match de demie finale qu'on initialise à 0 */
    vid_match := 0;

    /* On introduit un indice de ligne où se trouvera l'indice du joueur d'un match de demie dans la table classement_demie */
    vindice_ligne_joueur := 0;

    /* Tant que les 4 joueurs n'ont pas été assignés à des matchs de demie finale */
    WHILE vindice_ligne_joueur != 4
    LOOP
        /* Pour chacun des 2 joueurs d'un match de demie finale sur les 4 joueurs au total */
        FOR i IN vindice_ligne_joueur..vindice_ligne_joueur + 1
        LOOP
            /* Si le joueur est le joueur a */
            IF i = vindice_ligne_joueur THEN
                /* On sélectionne l'indice du joueur a dans la table classement_demie */
                SELECT id_joueur FROM classement_demie LIMIT 1 OFFSET i INTO vid_joueur_a;
            /* Si le joueur est le joueur b */
            ELSIF i = vindice_ligne_joueur + 1 THEN
                /* On sélectionne l'indice du joueur b dans la table classement_demie */
                SELECT id_joueur FROM classement_demie LIMIT 1 OFFSET i INTO vid_joueur_b;
                vid_match := vid_match + 1;
                /* A chaque match de demie finale opposant deux joueurs, on associe une date */
                vnb := vnb + 1;
                /* On sélectionne un nombre aléatoire de spectateurs pour chaque match de demie finale */
                SELECT FLOOR(RANDOM() * ( vmax_nb_spectateurs - 1 + 1) + 1) INTO vnb_spectateurs;

                /* On attribue à chacun des deux joueurs un score */
                SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_a;
                SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_b;

                /* Si les deux joueurs ont le même score */
                IF vscore_joueur_a = vscore_joueur_b THEN
                    /* Tant qu'il y a égalité de score */
                    WHILE vscore_joueur_a = vscore_joueur_b
                    LOOP
                        /* On attribue un nouveau score en cas d'égalité au joueur a */
                        SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_a;
                    END LOOP;
                END IF;

                /* Insertion du match de 1/8e de finale dans la table match_demie */
                INSERT INTO match_demie VALUES (vid_match, current_date + vnb, 'demie finale', vid_stade, vnb_spectateurs, vid_joueur_a, vid_joueur_b, vscore_joueur_a, vscore_joueur_b);

                /* Deux joueurs sont assignés pour chaque match de demie finale */
                vindice_ligne_joueur := vindice_ligne_joueur + 1 + 1;

            END IF;

        END LOOP;

    END LOOP;

    /* Déclencheur du trigger */
    INSERT INTO match_demie VALUES (1000, NULL, NULL, 1, NULL, 1, 1, NULL, NULL);
    DELETE FROM match_demie WHERE id_match = 1000;

    RETURN OLD;

END;
$$LANGUAGE 'plpgsql';


CREATE TRIGGER match_demie
AFTER INSERT ON classement_demie
EXECUTE PROCEDURE match_demie();


CREATE OR REPLACE FUNCTION classement_demie()
RETURNS TRIGGER AS $$
BEGIN
    FOR i IN 1..2
    LOOP
        /* Mise à jour des qualifiés dans la table classement_demie suivant les vainqueurs de chacun des matchs de demie finale */
        UPDATE classement_demie SET statut='Qualifié' WHERE id_joueur=(SELECT classement_demie.id_joueur FROM classement_demie INNER JOIN match_demie ON match_demie.id_joueur_a=classement_demie.id_joueur WHERE score_joueur_a > score_joueur_b AND id_match = i);
        UPDATE classement_demie SET statut='Qualifié' WHERE id_joueur=(SELECT classement_demie.id_joueur FROM classement_demie INNER JOIN match_demie ON match_demie.id_joueur_b=classement_demie.id_joueur WHERE score_joueur_b > score_joueur_a AND id_match = i);

        /* Mise à jour des scores des qualifiés dans la table classement_demie suivant les vainqueurs de chacun des matchs de demie finale */
        UPDATE classement_demie SET score_joueur=(SELECT match_demie.score_joueur_a FROM match_demie WHERE score_joueur_a > score_joueur_b AND id_match = i) WHERE id_joueur=(SELECT classement_demie.id_joueur FROM classement_demie INNER JOIN match_demie ON match_demie.id_joueur_a=classement_demie.id_joueur WHERE score_joueur_a > score_joueur_b AND id_match = i);
        UPDATE classement_demie SET score_joueur=(SELECT match_demie.score_joueur_b FROM match_demie WHERE score_joueur_b > score_joueur_a AND id_match = i) WHERE id_joueur=(SELECT classement_demie.id_joueur FROM classement_demie INNER JOIN match_demie ON match_demie.id_joueur_b=classement_demie.id_joueur WHERE score_joueur_b > score_joueur_a AND id_match = i);    
    END LOOP;

    /* Insertion et mélange de façon aléatoire des joueurs qualifiés qui joueront en finale */
    INSERT INTO classement_finale (id_joueur, id_nationalite, nom, prenom, datenai) SELECT classement_demie.id_joueur, classement_demie.id_nationalite, classement_demie.nom, classement_demie.prenom, classement_demie.datenai FROM classement_demie WHERE statut='Qualifié' ORDER BY RANDOM();

    RETURN OLD;
END;
$$LANGUAGE 'plpgsql';


CREATE TRIGGER classement_demie
AFTER DELETE ON match_demie
EXECUTE PROCEDURE classement_demie();


CREATE OR REPLACE FUNCTION match_finale()
RETURNS TRIGGER AS $$
DECLARE
    vmax_idstade STADE.id_stade%TYPE;
    vmin_idstade STADE.id_stade%TYPE;
    vid_stade STADE.id_stade%TYPE;
    vmax_nb_spectateurs STADE.capacite_stade%TYPE;
    vnb INTEGER;
    vnb_spectateurs STADE.capacite_stade%TYPE;
    vid_joueur_a match_finale.id_joueur_a%TYPE;
    vid_joueur_b match_finale.id_joueur_b%TYPE;
    vscore_joueur_a match_finale.score_joueur_a%TYPE;
    vscore_joueur_b match_finale.score_joueur_b%TYPE;
BEGIN
    /* On sélectionne l'indice maximal dans la table stade */
    SELECT MAX(stade.id_stade) FROM stade INTO vmax_idstade;
    /* On sélectionne l'indice minimal dans la table stade */
    SELECT MIN(stade.id_stade) FROM stade INTO vmin_idstade;
    /* On sélectionne un indice de stade aléatoire (stade qui accueillera la finale) */
    SELECT FLOOR(RANDOM() * ( vmax_idstade - vmin_idstade + 1) + vmin_idstade) INTO vid_stade;
    /* On sélectionne la capacité du stade où se déroule la finale */
    SELECT stade.capacite_stade FROM stade WHERE stade.id_stade = vid_stade INTO vmax_nb_spectateurs;

    /* On introduit une variable qui représentera la date de la finale (63ème jour du championnat) */
    vnb := 63;

    /* On sélectionne l'indice du joueur a dans la table classement_finale */
    SELECT id_joueur FROM classement_finale LIMIT 1 OFFSET 0 INTO vid_joueur_a;

    /* On sélectionne l'indice du joueur b dans la table classement_finale */
    SELECT id_joueur FROM classement_finale LIMIT 1 OFFSET 1 INTO vid_joueur_b;

    /* On sélectionne un nombre aléatoire de spectateurs pour la finale */
    SELECT FLOOR(RANDOM() * ( vmax_nb_spectateurs - 1 + 1) + 1) INTO vnb_spectateurs;

    /* On attribue à chacun des deux joueurs un score */
    SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_a;
    SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_b;

    /* Si les deux joueurs ont le même score */
    IF vscore_joueur_a = vscore_joueur_b THEN
        /* Tant qu'il y a égalité de score */
        WHILE vscore_joueur_a = vscore_joueur_b
        LOOP
            /* On attribue un nouveau score en cas d'égalité au joueur a */
            SELECT FLOOR(RANDOM() * ( 7 - 0 + 1) + 0) INTO vscore_joueur_a;
        END LOOP;
    END IF;

    /* Insertion de la finale dans la table match_finale */
    INSERT INTO match_finale VALUES (1, current_date + vnb, 'finale', vid_stade, vnb_spectateurs, vid_joueur_a, vid_joueur_b, vscore_joueur_a, vscore_joueur_b);

    /* Déclencheur du trigger */
    INSERT INTO match_finale VALUES (1000, NULL, NULL, 1, NULL, 1, 1, NULL, NULL);
    DELETE FROM match_finale WHERE id_match = 1000;

    RETURN OLD;

END;
$$LANGUAGE 'plpgsql';


CREATE TRIGGER match_finale
AFTER INSERT ON classement_finale
EXECUTE PROCEDURE match_finale();


CREATE OR REPLACE FUNCTION classement_finale()
RETURNS TRIGGER AS $$
BEGIN
    FOR i IN 1..2
    LOOP
        /* Mise à jour des scores des qualifiés dans la table classement_finale */
        UPDATE classement_finale SET score_joueur=(SELECT match_finale.score_joueur_a FROM match_finale WHERE score_joueur_a > score_joueur_b AND id_match = i) WHERE id_joueur=(SELECT classement_finale.id_joueur FROM classement_finale INNER JOIN match_finale ON match_finale.id_joueur_a=classement_finale.id_joueur WHERE score_joueur_a > score_joueur_b AND id_match = i);
        UPDATE classement_finale SET score_joueur=(SELECT match_finale.score_joueur_b FROM match_finale WHERE score_joueur_b > score_joueur_a AND id_match = i) WHERE id_joueur=(SELECT classement_finale.id_joueur FROM classement_finale INNER JOIN match_finale ON match_finale.id_joueur_b=classement_finale.id_joueur WHERE score_joueur_b > score_joueur_a AND id_match = i);    
    END LOOP;

    /* Insertion de tous les joueurs du championnat et de leurs scores dans le classement général */
    INSERT INTO classement_general (id_joueur, id_nationalite, nom, prenom, datenai, score_joueur) SELECT classement_un_seize.id_joueur, classement_un_seize.id_nationalite, classement_un_seize.nom, classement_un_seize.prenom, classement_un_seize.datenai, subquery1.score_total FROM (SELECT classement_un_seize.id_joueur, classement_un_seize.score_joueur+classement_un_huit.score_joueur+classement_quart.score_joueur+classement_demie.score_joueur+classement_finale.score_joueur AS score_total FROM classement_un_seize INNER JOIN classement_un_huit ON classement_un_huit.id_joueur=classement_un_seize.id_joueur INNER JOIN classement_quart ON classement_quart.id_joueur=classement_un_seize.id_joueur INNER JOIN classement_demie ON classement_demie.id_joueur=classement_un_seize.id_joueur INNER JOIN classement_finale ON classement_finale.id_joueur=classement_un_seize.id_joueur UNION SELECT classement_un_seize.id_joueur AS id_joueur, classement_un_seize.score_joueur+classement_un_huit.score_joueur+classement_quart.score_joueur+classement_demie.score_joueur AS score_total FROM classement_un_seize INNER JOIN classement_un_huit ON classement_un_huit.id_joueur=classement_un_seize.id_joueur INNER JOIN classement_quart ON classement_quart.id_joueur=classement_un_seize.id_joueur INNER JOIN classement_demie ON classement_demie.id_joueur=classement_un_seize.id_joueur UNION SELECT classement_un_seize.id_joueur AS id_joueur, classement_un_seize.score_joueur+classement_un_huit.score_joueur+classement_quart.score_joueur AS score_total FROM classement_un_seize INNER JOIN classement_un_huit ON classement_un_huit.id_joueur=classement_un_seize.id_joueur INNER JOIN classement_quart ON classement_quart.id_joueur=classement_un_seize.id_joueur UNION SELECT classement_un_seize.id_joueur AS id_joueur, classement_un_seize.score_joueur+classement_un_huit.score_joueur AS score_total FROM classement_un_seize INNER JOIN classement_un_huit ON classement_un_huit.id_joueur=classement_un_seize.id_joueur UNION SELECT classement_un_seize.id_joueur AS id_joueur, classement_un_seize.score_joueur AS score_total FROM classement_un_seize ORDER BY score_total DESC) AS subquery1 INNER JOIN classement_un_seize ON classement_un_seize.id_joueur=subquery1.id_joueur WHERE subquery1.score_total IS NOT NULL;

    RETURN OLD;
END;
$$LANGUAGE 'plpgsql';


CREATE TRIGGER classement_finale
AFTER DELETE ON match_finale
EXECUTE PROCEDURE classement_finale();


CREATE OR REPLACE FUNCTION resultats()
RETURNS TRIGGER AS $$
DECLARE
    curseur_un_seize CURSOR FOR SELECT prenom, nom FROM classement_un_seize WHERE statut='Qualifié';
    vprenom_curseur_un_seize classement_un_seize.prenom%TYPE;
    vnom_curseur_un_seize classement_un_seize.nom%TYPE;
    curseur_un_huit CURSOR FOR SELECT prenom, nom FROM classement_un_huit WHERE statut='Qualifié';
    vprenom_curseur_un_huit classement_un_huit.prenom%TYPE;
    vnom_curseur_un_huit classement_un_huit.nom%TYPE;
    curseur_quart CURSOR FOR SELECT prenom, nom FROM classement_quart WHERE statut='Qualifié';
    vprenom_curseur_quart classement_quart.prenom%TYPE;
    vnom_curseur_quart classement_quart.nom%TYPE;
    curseur_demie CURSOR FOR SELECT prenom, nom FROM classement_demie WHERE statut='Qualifié';
    vprenom_curseur_demie classement_demie.prenom%TYPE;
    vnom_curseur_demie classement_demie.nom%TYPE;
    curseur_vainqueur CURSOR FOR SELECT prenom, nom, score_joueur FROM classement_general WHERE score_joueur=(SELECT MAX(score_joueur) FROM classement_general);
    vprenom_curseur_vainqueur classement_general.prenom%TYPE;
    vnom_curseur_vainqueur classement_general.nom%TYPE;
    vscore_joueur_curseur_vainqueur classement_general.score_joueur%TYPE;
BEGIN
    OPEN curseur_un_seize;
    LOOP
        FETCH curseur_un_seize INTO vprenom_curseur_un_seize, vnom_curseur_un_seize;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '% % est qualifié pour les 1/8e de finale !', vprenom_curseur_un_seize, vnom_curseur_un_seize;
    END LOOP;
    CLOSE curseur_un_seize;
    OPEN curseur_un_huit;
    LOOP
        FETCH curseur_un_huit INTO vprenom_curseur_un_huit, vnom_curseur_un_huit;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '% % est qualifié pour les quarts de finale !', vprenom_curseur_un_huit, vnom_curseur_un_huit;
    END LOOP;
    CLOSE curseur_un_huit;
    OPEN curseur_quart;
    LOOP
        FETCH curseur_quart INTO vprenom_curseur_quart, vnom_curseur_quart;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '% % est qualifié pour la demie finale !', vprenom_curseur_quart, vnom_curseur_quart;
    END LOOP;
    CLOSE curseur_quart;
    OPEN curseur_demie;
    LOOP
        FETCH curseur_demie INTO vprenom_curseur_demie, vnom_curseur_demie;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '% % est qualifié pour la finale !', vprenom_curseur_demie, vnom_curseur_demie;
    END LOOP;
    CLOSE curseur_demie;
    OPEN curseur_vainqueur;
    LOOP
        FETCH curseur_vainqueur INTO vprenom_curseur_vainqueur, vnom_curseur_vainqueur, vscore_joueur_curseur_vainqueur;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Le Vainqueur du Championnat est % % avec un score de % points ! Bravo !', vprenom_curseur_vainqueur, vnom_curseur_vainqueur, vscore_joueur_curseur_vainqueur;
    END LOOP;
    CLOSE curseur_vainqueur;
    RETURN OLD;
END;
$$LANGUAGE 'plpgsql';


CREATE TRIGGER resultats
AFTER INSERT ON classement_general
EXECUTE PROCEDURE resultats();


SELECT * FROM championnat();
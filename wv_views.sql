-- 3. Créer la vue ALL_PLAYERS_ELAPSED_TOUR qui affiche le temps
-- moyen de chaque prise décision,
-- Les colonnes attendues pour cette vue sont dans l’ordre :
-- • nom du joueur
-- • nom de la partie
-- • n° du tour
-- • date et heure du début du tour
-- • date et heure de la prise de décision du joueur dans le
-- tour
-- • nb de secondes passées dans le tour pour le joueur
USE tp_loup;
GO

CREATE VIEW ALL_PLAYERS_ELAPSED_TOUR AS
SELECT p.pseudo, pt.title_party, t.id_turn, t.start_time AS turn_start_time, pp.start_time AS decision_start_time, 
    (pp.start_time - t.start_time) AS elapsed_time
FROM players p
INNER JOIN players_play pp ON p.id_player = pp.id_player
INNER JOIN turns t ON pp.id_turn = t.id_turn
INNER JOIN parties pt ON t.id_party = pt.id_party;
GROUP BY p.pseudo, pt.title_party, t.id_turn, t.start_time, pp.start_time;


-- 4. Créer la vue ALL_PLAYERS_STATS qui affiche le temps moyen de
-- prise de décision à chaque tour.
-- Les colonnes attendues pour cette vue sont dans l’ordre :
-- • nom du joueur
-- • role parmi loup et villageois
-- • nom de la partie
-- • nb de tours joués par le joueur
-- • nb total de tours de la partie
-- • vainqueur dépendant du rôle du joueur
-- • temps moyen de prise de décision du joueur

CREATE VIEW ALL_PLAYERS_STATS AS
SELECT p.pseudo, r.description_role, pt.title_party, COUNT(DISTINCT t.id_turn) AS nb_turns_played,
    (SELECT COUNT(DISTINCT t.id_turn) FROM turns t WHERE t.id_party = pt.id_party) AS nb_total_turns,
    CASE
        WHEN r.description_role = 'loup' THEN 'loup'
        ELSE 'villageois'
    END AS winner,
    AVG(pp.end_time - pp.start_time) AS avg_decision_time
FROM players p
INNER JOIN players_in_parties pip ON p.id_player = pip.id_player
INNER JOIN roles r ON pip.id_role = r.id_role
INNER JOIN parties pt ON pip.id_party = pt.id_party
INNER JOIN players_play pp ON p.id_player = pp.id_player
INNER JOIN turns t ON pp.id_turn = t.id_turn
GROUP BY p.pseudo, r.description_role, pt.title_party, r.description_role;
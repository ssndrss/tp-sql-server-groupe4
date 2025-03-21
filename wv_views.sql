-- Modification des colonnes de type TEXT en VARCHAR

DROP VIEW ALL_PLAYERS_ELAPSED_GAME

CREATE VIEW ALL_PLAYERS_ELAPSED_GAME AS
SELECT 
    p.pseudo AS 'nom du joueur',
    pt.title_party AS 'nom de la partie',
    (SELECT COUNT(DISTINCT id_player) FROM players_in_parties WHERE id_party = pip.id_party) AS 'nombre de participants',
    (SELECT MIN(pp.start_time) 
     FROM players_play pp 
     JOIN turns t ON pp.id_turn = t.id_turn 
     WHERE t.id_party = pip.id_party 
     AND pp.id_player = pip.id_player) AS 'date et heure de la première action du joueur dans la partie',
    (SELECT MAX(pp.end_time) 
     FROM players_play pp 
     JOIN turns t ON pp.id_turn = t.id_turn 
     WHERE t.id_party = pip.id_party 
     AND pp.id_player = pip.id_player) AS 'date et heure de la dernière action du joueur dans la partie',
    DATEDIFF(
        SECOND, 
        (SELECT MIN(pp.start_time) 
         FROM players_play pp 
         JOIN turns t ON pp.id_turn = t.id_turn 
         WHERE t.id_party = pip.id_party 
         AND pp.id_player = pip.id_player),
        (SELECT MAX(pp.end_time) 
         FROM players_play pp 
         JOIN turns t ON pp.id_turn = t.id_turn 
         WHERE t.id_party = pip.id_party 
         AND pp.id_player = pip.id_player)
    ) AS 'nb de secondes passées dans la partie pour le joueur'
FROM 
    players_in_parties pip
JOIN 
    players p ON pip.id_player = p.id_player
JOIN 
    parties pt ON pip.id_party = pt.id_party
GROUP BY 
    p.pseudo, pt.title_party, pip.id_party, pip.id_player;
CREATE VIEW ALL_PLAYERS AS
SELECT
    players.pseudo AS nom_du_joueur,
    COUNT(DISTINCT parties.id_party) AS nombre_de_parties_jouees,
    COUNT(DISTINCT turns.id_turn) AS nombre_de_tours_joues,
    MIN(turns.start_time) AS date_et_heure_de_la_premiere_participation,
    MAX(players_play.end_time) AS date_et_heure_de_la_derniere_action
FROM players
JOIN players_in_parties ON players.id_player = players_in_parties.id_player
JOIN parties ON players_in_parties.id_party = parties.id_party
JOIN turns ON parties.id_party = turns.id_party
JOIN players_play ON players.id_player = players_play.id_player
GROUP BY players.pseudo;


CREATE VIEW RAND AS
SELECT RAND() as VALUE;


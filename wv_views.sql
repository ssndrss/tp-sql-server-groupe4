-- Modification des colonnes de type TEXT en VARCHAR
ALTER TABLE parties ALTER COLUMN title_party VARCHAR(255);
ALTER TABLE roles ALTER COLUMN description_role VARCHAR(255);
ALTER TABLE players ALTER COLUMN pseudo VARCHAR(255);
ALTER TABLE players_in_parties ALTER COLUMN is_alive VARCHAR(50);
ALTER TABLE players_play ALTER COLUMN origin_position_col VARCHAR(50);
ALTER TABLE players_play ALTER COLUMN origin_position_row VARCHAR(50);
ALTER TABLE players_play ALTER COLUMN target_position_col VARCHAR(50);
ALTER TABLE players_play ALTER COLUMN target_position_row VARCHAR(50);

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
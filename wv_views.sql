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

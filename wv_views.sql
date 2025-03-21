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
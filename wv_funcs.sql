CREATE FUNCTION dbo.random_position(
    @id_party INT
)
RETURNS @result TABLE (
    row INT,
    col INT
)
AS
BEGIN
    DECLARE @row INT, @col INT;
    DECLARE @random_row FLOAT, @random_col FLOAT;
    DECLARE @max_rows INT, @max_cols INT;

    SELECT @max_rows = row, @max_cols = col
    FROM parties
    WHERE id_party = @id_party;

    IF @max_rows IS NULL OR @max_cols IS NULL
        RETURN;

    WHILE 1 = 1
    BEGIN
        SELECT TOP 1 @random_row = value FROM RAND;
        SELECT TOP 1 @random_col = value FROM RAND;

        SET @row = CAST(ROUND(@random_row * (@max_rows - 1), 0) AS INT);
        SET @col = CAST(ROUND(@random_col * (@max_cols - 1), 0) AS INT);

        IF NOT EXISTS (
            SELECT 1 FROM players_play pp
            JOIN turns t ON pp.id_turn = t.id_turn
            WHERE t.id_party = @id_party
            AND ((pp.origin_position_row = @row AND pp.origin_position_col = @col)
              OR (pp.target_position_row = @row AND pp.target_position_col = @col))
        )
        BEGIN
            INSERT INTO @result VALUES (@row, @col);
            RETURN;
        END;
    END;

    RETURN;
END; 

-- Créer une fonction random_role() qui renvoie le prochain rôle à
-- affecter au joueur en cours d’inscription en respectant les quotas
-- de loups et de villageois

CREATE FUNCTION random_role()
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @nb_loups INT = 0;
    DECLARE @nb_villageois INT = 0;
    DECLARE @role VARCHAR(50);
    
    SELECT @nb_loups = COUNT(*) 
    FROM players_in_parties pp
    INNER JOIN roles r ON r.id_role = pp.id_role
    WHERE r.description_role = 'loup';

    SELECT @nb_villageois = COUNT(*) 
    FROM players_in_parties pp
    INNER JOIN roles r ON r.id_role = pp.id_role
    WHERE r.description_role = 'villageois';
    
    IF @nb_loups < 3 
        SET @role = 'loup';
    ELSE 
        SET @role = 'villageois';
    
    RETURN @role;
END;


-- Créer une fonction get_the_winner(@partyid INT) qui renvoie
-- toutes les informations sur le vainqueur de la partie passée en
-- paramètre. Les informations renvoyées doivent être :
-- • nom du joueur
-- • role parmi loup et villageois
-- • nom de la partie
-- • nb de tours joués par le joueur
-- • nb total de tours de la partie
-- • temps moyen de prise de décision du joueur

CREATE FUNCTION get_the_winner(@partyid INT)
RETURNS TABLE
AS
RETURN
(
    SELECT p.pseudo, r.description_role, pt.title_party, COUNT(DISTINCT t.id_turn) AS nb_turns_played,
        (SELECT COUNT(DISTINCT t.id_turn) FROM turns t WHERE t.id_party = pt.id_party) AS nb_total_turns,
        r.description_role
        AVG(pp.end_time - pp.start_time) AS avg_decision_time
    FROM players p
    INNER JOIN players_in_parties pip ON p.id_player = pip.id_player
    INNER JOIN roles r ON pip.id_role = r.id_role
    INNER JOIN parties pt ON pip.id_party = pt.id_party
    WHERE pt.id_party = @partyid
    GROUP BY p.pseudo, r.description_role, pt.title_party;
);

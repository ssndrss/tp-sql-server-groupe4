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
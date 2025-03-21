CREATE FUNCTION dbo.random_position(
    @rows INT,
    @cols INT,
    @id_party INT
)
RETURNS @result TABLE (
    row INT,
    col INT
)
AS
BEGIN
    DECLARE @row INT, @col INT;
    DECLARE @random_row FLOAT;
	DECLARE @random_col FLOAT;

    WHILE 1 = 1
    BEGIN
        SELECT TOP 1 @random_row = value FROM RAND;
    	SELECT TOP 1 @random_col = value FROM RAND;

        SET @row = CAST(ROUND(@random_row * (@rows - 1), 0) AS INT);
        SET @col = CAST(ROUND(@random_col * (@cols - 1), 0) AS INT);

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
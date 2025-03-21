ALTER TABLE parties ALTER COLUMN title_party VARCHAR(255);
ALTER TABLE roles ALTER COLUMN description_role VARCHAR(255);
ALTER TABLE players ALTER COLUMN pseudo VARCHAR(255);
ALTER TABLE players_in_parties ALTER COLUMN is_alive VARCHAR(50);
ALTER TABLE players_play ALTER COLUMN origin_position_col VARCHAR(50);
ALTER TABLE players_play ALTER COLUMN origin_position_row VARCHAR(50);
ALTER TABLE players_play ALTER COLUMN target_position_col VARCHAR(50);
ALTER TABLE players_play ALTER COLUMN target_position_row VARCHAR(50);

CREATE TABLE possible_positions (
    row INT,
    col INT
);

DECLARE @i INT = 0, @j INT;

WHILE @i < 10
BEGIN
    SET @j = 0;
    WHILE @j < 10
    BEGIN
        INSERT INTO possible_positions VALUES (@i, @j);
        SET @j = @j + 1;
    END
    SET @i = @i + 1;
END;



IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_CompleteTour')
    DROP TRIGGER trg_CompleteTour;


CREATE TRIGGER trg_CompleteTour
ON turns
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(end_time)
    BEGIN
        DECLARE @completed_turns TABLE (
            id_turn INT,
            id_party INT
        );
        
        INSERT INTO @completed_turns
        SELECT i.id_turn, i.id_party
        FROM inserted i
        JOIN deleted d ON i.id_turn = d.id_turn
        WHERE 
            i.end_time <> d.end_time
            AND i.end_time <= GETDATE();
        
        DECLARE @id_turn INT;
        DECLARE @id_party INT;
        
        DECLARE tour_cursor CURSOR FOR 
        SELECT id_turn, id_party FROM @completed_turns;
        
        OPEN tour_cursor;
        FETCH NEXT FROM tour_cursor INTO @id_turn, @id_party;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
	        
            EXEC COMPLETE_TOUR @id_turn = @id_turn, @id_party = @id_party;
    
            FETCH NEXT FROM tour_cursor INTO @id_turn, @id_party;
        END;
        
        CLOSE tour_cursor;
        DEALLOCATE tour_cursor;
    END;
END;

CREATE TRIGGER trg_UsernameToLower
ON players
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE players
    SET pseudo = LOWER(pseudo)
    WHERE id_player IN (SELECT id_player FROM inserted);
END;

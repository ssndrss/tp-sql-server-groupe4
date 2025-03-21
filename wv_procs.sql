

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'SEED_DATA')
    DROP PROCEDURE SEED_DATA;



CREATE PROCEDURE SEED_DATA
    @NB_PLAYERS INT,
    @PARTY_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @player_id INT;
    DECLARE @role_id INT;
    DECLARE @wolf_count INT = 0;
    DECLARE @villager_count INT = 0;
    DECLARE @wolf_quota INT;
    DECLARE @turn_id INT = 1;
    DECLARE @max_turns INT = 10;
    DECLARE @current_datetime DATETIME = GETDATE();
    DECLARE @turn_duration INT = 120; 
    DECLARE @villagers_alive INT;
    

    SET @wolf_quota = CEILING(@NB_PLAYERS * 0.3);
    

    IF NOT EXISTS (SELECT 1 FROM parties WHERE id_party = @PARTY_ID)
    BEGIN
        
        INSERT INTO parties (id_party, title_party, nb_tour)
        VALUES (@PARTY_ID, 'Game ' + CAST(@PARTY_ID AS VARCHAR(10)), @max_turns);
    END
    ELSE
    BEGIN
        
        SELECT @max_turns = nb_tour FROM parties WHERE id_party = @PARTY_ID;
    END;
    

    IF NOT EXISTS (SELECT 1 FROM roles WHERE id_role = 1) -- Loup
    BEGIN
        INSERT INTO roles (id_role, description_role)
        VALUES (1, 'Loup');
    END;
    
    IF NOT EXISTS (SELECT 1 FROM roles WHERE id_role = 2) -- Villageois
    BEGIN
        INSERT INTO roles (id_role, description_role)
        VALUES (2, 'Villageois');
    END;
    

    DECLARE @i INT = 1;
    WHILE @i <= @NB_PLAYERS
    BEGIN

        SET @player_id = @i;
        
        IF NOT EXISTS (SELECT 1 FROM players WHERE id_player = @player_id)
        BEGIN
            INSERT INTO players (id_player, pseudo)
            VALUES (@player_id, 'Player' + CAST(@player_id AS VARCHAR(10)));
        END;
        

        IF @wolf_count < @wolf_quota AND (RAND() < 0.5 OR @villager_count >= (@NB_PLAYERS - @wolf_quota))
        BEGIN
            SET @role_id = 1
            SET @wolf_count = @wolf_count + 1;
        END
        ELSE
        BEGIN
            SET @role_id = 2;
            SET @villager_count = @villager_count + 1;
        END;
        
        IF NOT EXISTS (SELECT 1 FROM players_in_parties WHERE id_player = @player_id AND id_party = @PARTY_ID)
        BEGIN
            INSERT INTO players_in_parties (id_party, id_player, id_role, is_alive)
            VALUES (@PARTY_ID, @player_id, @role_id, 'true');
        END;
        
        SET @i = @i + 1;
    END;
    

    SELECT @villagers_alive = COUNT(*) 
    FROM players_in_parties 
    WHERE id_party = @PARTY_ID AND id_role = 2 AND is_alive = 'true';
    

    SET @i = 1;
    WHILE @i <= @max_turns AND @villagers_alive > 0
    BEGIN

        INSERT INTO turns (id_turn, id_party, start_time, end_time)
        VALUES (
            (@PARTY_ID * 1000) + @i, 
            @PARTY_ID,
            @current_datetime,
            DATEADD(SECOND, @turn_duration, @current_datetime)
        );
        

        DECLARE player_cursor CURSOR FOR
        SELECT id_player FROM players_in_parties 
        WHERE id_party = @PARTY_ID AND is_alive = 'true';
        
        OPEN player_cursor;
        FETCH NEXT FROM player_cursor INTO @player_id;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @origin_col CHAR(1) = CHAR(ASCII('A') + CAST(RAND() * 8 AS INT));
            DECLARE @origin_row CHAR(1) = CAST(1 + CAST(RAND() * 8 AS INT) AS VARCHAR(1));
            DECLARE @target_col CHAR(1) = CHAR(ASCII('A') + CAST(RAND() * 8 AS INT));
            DECLARE @target_row CHAR(1) = CAST(1 + CAST(RAND() * 8 AS INT) AS VARCHAR(1));
            DECLARE @action_start DATETIME = DATEADD(SECOND, CAST(RAND() * (@turn_duration / 2) AS INT), @current_datetime);
            DECLARE @action_end DATETIME = DATEADD(SECOND, CAST(RAND() * (@turn_duration / 2) AS INT) + (@turn_duration / 2), @current_datetime);
            
            INSERT INTO players_play (
                id_player, 
                id_turn, 
                start_time, 
                end_time, 
                action, 
                origin_position_col, 
                origin_position_row, 
                target_position_col, 
                target_position_row
            )
            VALUES (
                @player_id,
                (@PARTY_ID * 1000) + @i,
                @action_start,
                @action_end,
                'MOVE',
                @origin_col,
                @origin_row,
                @target_col,
                @target_row
            );
            
            FETCH NEXT FROM player_cursor INTO @player_id;
        END;
        
        CLOSE player_cursor;
        DEALLOCATE player_cursor;
        

        DECLARE @wolf_positions TABLE (
            col VARCHAR(10),
            row VARCHAR(10)
        );
        
        INSERT INTO @wolf_positions
        SELECT DISTINCT pp.target_position_col, pp.target_position_row
        FROM players_play pp
        JOIN turns t ON pp.id_turn = t.id_turn
        JOIN players_in_parties pip ON pp.id_player = pip.id_player AND t.id_party = pip.id_party
        WHERE t.id_turn = (@PARTY_ID * 1000) + @i
        AND pip.id_role = 1 -- Loup
        AND pip.is_alive = 'true';
        
        DECLARE @eliminated_players TABLE (
            id_player INT
        );
        
        INSERT INTO @eliminated_players
        SELECT pp.id_player
        FROM players_play pp
        JOIN turns t ON pp.id_turn = t.id_turn
        JOIN players_in_parties pip ON pp.id_player = pip.id_player AND t.id_party = pip.id_party
        JOIN @wolf_positions wp ON pp.target_position_col = wp.col AND pp.target_position_row = wp.row
        WHERE t.id_turn = (@PARTY_ID * 1000) + @i
        AND pip.id_role = 2 
        AND pip.is_alive = 'true';
        

        UPDATE pip
        SET is_alive = 'false'
        FROM players_in_parties pip
        JOIN @eliminated_players ep ON pip.id_player = ep.id_player
        WHERE pip.id_party = @PARTY_ID;
        

        SELECT @villagers_alive = COUNT(*) 
        FROM players_in_parties 
        WHERE id_party = @PARTY_ID AND id_role = 2 AND is_alive = 'true';
        

        SET @current_datetime = DATEADD(SECOND, @turn_duration, @current_datetime);
        SET @i = @i + 1;
    END;
    

    SELECT 
        'Partie ' + CAST(@PARTY_ID AS VARCHAR(10)) AS Partie,
        @NB_PLAYERS AS 'Nombre de joueurs',
        @wolf_count AS 'Nombre de loups',
        @villager_count AS 'Nombre de villageois',
        @i - 1 AS 'Nombre de tours générés',
        @max_turns AS 'Nombre maximum de tours configuré',
        (SELECT COUNT(*) FROM players_in_parties WHERE id_party = @PARTY_ID AND is_alive = 'true' AND id_role = 2) AS 'Villageois survivants',
        CASE 
            WHEN @villagers_alive = 0 THEN 'Victoire des loups'
            ELSE 'Victoire des villageois'
        END AS 'Résultat de la partie'
    ;
END;


CREATE PROCEDURE COMPLETE_TOUR
    @TOUR_ID INT,
    @PARTY_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    CREATE TABLE #PlayerPositions (
        id_player INT,
        position_col VARCHAR(10),
        position_row VARCHAR(10),
        id_role INT,
        is_alive VARCHAR(10)
    );
    
    INSERT INTO #PlayerPositions (id_player, position_col, position_row, id_role, is_alive)
    SELECT 
        pp.id_player,
        pp.target_position_col,
        pp.target_position_row,
        pip.id_role,
        pip.is_alive
    FROM 
        players_play pp
    JOIN 
        players_in_parties pip ON pp.id_player = pip.id_player
    WHERE 
        pp.id_turn = @TOUR_ID
        AND pip.id_party = @PARTY_ID
        AND pip.is_alive = 'true';
    
    DECLARE @wolf_positions TABLE (
        position_col VARCHAR(10),
        position_row VARCHAR(10)
    );
    
    INSERT INTO @wolf_positions
    SELECT 
        position_col, 
        position_row
    FROM 
        #PlayerPositions
    WHERE 
        id_role = 1;
    
    DECLARE @eliminated_players TABLE (
        id_player INT
    );
    
    INSERT INTO @eliminated_players
    SELECT 
        pp.id_player
    FROM 
        #PlayerPositions pp
    JOIN 
        @wolf_positions wp ON pp.position_col = wp.position_col AND pp.position_row = wp.position_row
    WHERE 
        pp.id_role = 2
        AND pp.is_alive = 'true';
    
    UPDATE 
        players_in_parties
    SET 
        is_alive = 'false'
    FROM 
        players_in_parties pip
    JOIN 
        @eliminated_players ep ON pip.id_player = ep.id_player
    WHERE 
        pip.id_party = @PARTY_ID;
    

    DECLARE @villagers_alive INT;
    
    SELECT 
        @villagers_alive = COUNT(*)
    FROM 
        players_in_parties
    WHERE 
        id_party = @PARTY_ID
        AND id_role = 2 -- Villageois
        AND is_alive = 'true';
    

    IF @villagers_alive = 0
    BEGIN

        PRINT 'Partie ' + CAST(@PARTY_ID AS VARCHAR(10)) + ' terminée - Tous les villageois sont morts!';
    END
    
    DROP TABLE #PlayerPositions;
    

    SELECT 
        'Tour ' + CAST(@TOUR_ID AS VARCHAR(10)) + ' complété' AS Status,
        (SELECT COUNT(*) FROM @eliminated_players) AS PlayersEliminated,
        @villagers_alive AS VillagersRemaining,
        CASE WHEN @villagers_alive = 0 THEN 'Terminée - Victoire des loups' ELSE 'En cours' END AS GameStatus;
END;


CREATE PROCEDURE USERNAME_TO_LOWER
    @id_player INT
AS
BEGIN
    UPDATE players
    SET pseudo = LOWER(pseudo)
    WHERE id_player = @id_player;
END;


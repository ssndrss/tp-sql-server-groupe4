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
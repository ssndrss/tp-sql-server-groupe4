-- Créer une fonction random_role() qui renvoie le prochain rôle à
-- affecter au joueur en cours d’inscription en respectant les quotas
-- de loups et de villageois

CREATE FUNCTION random_role()
RETURNS VARCHAR(50)
AS
DECLARE
    nb_loups INT;
    nb_villageois INT;
    role VARCHAR(50);
BEGIN
    SELECT COUNT(*) INTO nb_loups FROM pp.players_in_parties INNER JOIN ON r.id_role = pp.id_role WHERE r.description_role = 'loup';
    SELECT COUNT(*) INTO nb_villageois FROM pp.players_in_parties INNER JOIN ON r.id_role = pp.id_role WHERE r.description_role = 'villageois';
    IF nb_loups < 3 THEN
        role := 'loup';
    ELSE
        role := 'villageois';
    END IF;
    RETURN role;
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
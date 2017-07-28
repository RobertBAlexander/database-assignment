--poly_admin is the admin priviliges of the Client, the Polyversal Administrator.--
--He is a separate user form the database adminiatrator--

GRANT SELECT, INSERT, UPDATE ON p_users TO poly_admin;

GRANT SELECT, INSERT, UPDATE ON p_units TO poly_admin;

GRANT SELECT, INSERT, UPDATE ON p_discounts TO poly_admin;

GRANT SELECT, INSERT, UPDATE ON p_clubs TO poly_admin;

GRANT SELECT, INSERT, UPDATE ON p_combat_tiles TO poly_admin;

GRANT SELECT, INSERT, UPDATE ON p_transport_capacities TO poly_admin;

GRANT SELECT, INSERT, UPDATE ON p_weapons TO poly_admin;

GRANT SELECT, INSERT, UPDATE ON p_formations TO poly_admin;

GRANT SELECT, INSERT, UPDATE ON p_army_lists TO poly_admin;

GRANT SELECT, INSERT, UPDATE ON p_army_rosters TO poly_admin;

GRANT SELECT, INSERT, UPDATE ON p_roster_histories TO poly_admin;

GRANT SELECT, INSERT, UPDATE ON p_user_histories TO poly_admin;
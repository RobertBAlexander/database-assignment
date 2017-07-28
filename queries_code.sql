--Show all vehicles in requested class limit(Medium--
--and Light) that can hold between 4 and 65 infantry--
--stands. Include creator and capacity cost in result--

SELECT user_name AS "Unit Creator",
       (class || ' ' ||  unit_name) AS "Unit Classification",
       mobility AS "Means of Transport",
       capacity AS "Max Transport Load",
       (capacity / 4) AS "Capacity Points Cost"
FROM p_units u
  INNER JOIN p_transport_capacities t
  ON t.unit_id = u.unit_id
WHERE (u.class = 'Medium' OR u.class = 'Light') AND t.capacity BETWEEN 4 AND 65
ORDER BY capacity ASC;


--If a user searched the database for army lists, and the formations in them.--
--User did not know specific name of army list, so seaerched 'Corp' in this section--

SELECT p_army_lists.user_name "Creator",
       army_name "Army Name/Faction",
       form_name "Permitted Formations"
FROM p_army_lists
INNER JOIN p_formation_in_army_list
  ON p_army_lists.army_id = p_formation_in_army_list.army_id
INNER JOIN p_formations
  ON p_formation_in_army_list.form_id = p_formations.form_id
WHERE p_army_lists.army_name LIKE '%Corp%'
ORDER BY form_name ASC;



--Show all weapons attached to the Encegon tank unit,--
--along with the number of weapons, their Cost--
--their AA ability, and their Arc of sight--
--As usual, all units(etc.) results should be shown--
--along with content creator. Order by points cost--

SELECT user_name "Unit Creator",
       (class || ' ' ||  unit_name) AS "Unit Classification",
       (wpn_category || ' ' || wpn_class) AS "Weapon Cagetory",
       wpn_qty AS "Quantity",
       ((targeting / 2) + wpn_class) * wpn_qty AS "Weapon Points Cost",
       (inf_cav_aa || vehicle_aa) AS "Anti Aircraft Capability",
       wpn_arc AS "Arc of Sight"
FROM p_units u
INNER JOIN p_weapon_loadouts l
  ON l.unit_id = u.unit_id
INNER JOIN  p_weapons w
  ON w.loadout_id = l.loadout_id
WHERE unit_name = 'Encegon'
ORDER BY ((targeting / 2) + wpn_class) * wpn_qty DESC;



--Display the number of units in each class that have been created--
--by users who do not work for Collins Epic Wargames(CEW in username)--
--Useful for CEW company to see what Class of units are most popular--
--as this may affect future balance changes in rules--
SELECT COUNT(unit_qty) AS "Number of Units",
       class AS "Unit Class"
FROM p_units
WHERE user_name NOT LIKE '%CEW'
GROUP BY class
HAVING COUNT(unit_qty) >= 1;



--Displays all the units available in the Big Push formation,--
--along with the user who created each unit--
--order by toughest units first--

SELECT form_name AS "Formation",
       unit_name AS "Unit Name",
       p_units.user_name AS "Unit Creator"
FROM p_unit_in_formation
INNER JOIN p_formations
  ON p_formations.form_id = p_unit_in_formation.form_id
INNER JOIN p_units
  ON p_unit_in_formation.unit_id = p_units.unit_id
WHERE p_unit_in_formation.form_id = 66666666665
ORDER BY armour DESC;



--Displays all "Official" army lists, created by the designer--
--of the game, Ken Whitehurst--
SELECT p_users.user_name "Creator",
       army_name
FROM p_users
INNER JOIN p_army_lists
  ON p_users.user_name = p_army_lists.user_name
WHERE p_users.user_name = 'KenCEW'
ORDER BY army_name ASC;


--show all combat Tiles created by people with CEW in their user_id--
--This will result in only seeing the official Images released by the company--
SELECT user_name, unit_name
FROM p_units
WHERE user_name NOT LIKE '%CEW'
ORDER BY user_name ASC;




--Using  part of a location of a club, find all members of that club,--
----full location of club, and club contact details.--
--this can be used to find all people in clubs in a certain country--
--or region. Very useful for organising country/region-wide events--

SELECT club_name AS "Club",  user_name AS "Club Member", profile_pic, c_location AS "Location of Club", club_email || ' ' || club_phone AS "Club Contact Details"
FROM p_users
INNER JOIN p_clubs
  ON p_users.member_of = p_clubs.club_name
WHERE c_location LIKE '%UK';


--Return all historical data related to one user, in order by timestamp--
--from most recent activity, back to beginning of user account--
--this will allow admin to review user trends, and check if any issues have occured--
--in user's pas that may inform current actions to be taken--

SELECT user_timestamp AS "Time of action", user_name AS "User Name",
user_type || ', ' || paid_type AS "Current status", is_banned AS  "Banned? (1=Y 0=N)"
FROM p_user_histories
WHERE user_name = 'robertBA'
ORDER BY user_timestamp DESC;

--Return all historical data related to army rosters with a max_points value--
--between 1000 and 3500 points. This will inform admin of popularity of--
--standard game's typical size. May inform future event planning, or game balance issues--

SELECT max_points AS "Points Limit", roster_name AS "Roster", user_name AS "Roster Creator", roster_timestamp AS "Date Created"
FROM p_roster_histories
WHERE max_points >= 500 AND max_points <= 5500
ORDER BY max_points DESC;
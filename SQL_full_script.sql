--drop all previous version of tables--

ALTER TABLE p_users
DROP CONSTRAINT p_users_members_fk
;

ALTER TABLE p_units
DROP CONSTRAINT p_unit_capacity_fk
;

ALTER TABLE p_units
DROP CONSTRAINT p_unit_loadout_fk
;

DROP TABLE p_user_histories;

DROP TABLE p_roster_histories;

DROP TABLE p_army_rosters;

DROP TABLE p_formation_in_army_list;

DROP TABLE p_army_lists;

DROP TABLE p_unit_in_formation;

DROP TABLE p_formations;

DROP TABLE p_weapons;

DROP TABLE p_weapon_loadouts;

DROP TABLE p_transport_capacities;

DROP TABLE p_units;

DROP TABLE p_combat_tiles;

DROP TABLE p_discounts;

DROP TABLE p_clubs;

DROP TABLE p_users;


--create tables, with alter statements in case of order creation issues--

CREATE TABLE p_users
(user_name VARCHAR2(20) CONSTRAINT p_users_user_name_pk PRIMARY KEY,
first_name VARCHAR2(30),
last_name VARCHAR2(30),
password VARCHAR2(20) NOT NULL,
user_email VARCHAR2(40) NOT NULL CONSTRAINT p_users_email_uk UNIQUE,
u_location VARCHAR2(120),
is_banned NUMBER(1, 0) DEFAULT 0 NOT NULL CHECK(is_banned >= 0 AND is_banned <= 1),
sub_id NUMBER(12, 0) DEFAULT NULL CONSTRAINT p_users_sub_id_uk UNIQUE,
member_of VARCHAR2(30) DEFAULT NULL,
user_type VARCHAR2(6) DEFAULT 'unpaid' NOT NULL CHECK (user_type = 'paid' OR user_type = 'unpaid'),
profile_pic VARCHAR2(80),
sub_date DATE,
sub_length NUMBER(4, 0),
purchase_id NUMBER(12, 0) DEFAULT NULL CONSTRAINT p_users_pur_id_uk UNIQUE,
date_paid DATE,
paid_type VARCHAR2(10) CHECK (paid_type = 'subscriber' OR paid_type = 'fully_paid'),
UNIQUE (user_name, user_type),
UNIQUE (user_name, sub_id),
CHECK (user_type = 'unpaid' OR paid_type = 'subscriber' OR (purchase_id IS NOT NULL AND date_paid IS NOT NULL)),
CHECK (user_type = 'unpaid' OR paid_type = 'fully_paid' OR (sub_id IS NOT NULL AND sub_date IS NOT NULL AND sub_length IS NOT NULL)),
CHECK (user_type = 'paid' OR profile_pic IS NULL)
);



CREATE TABLE p_clubs
(club_name VARCHAR2(30) CONSTRAINT p_club_club_name_pk PRIMARY KEY,
c_location VARCHAR2(120),
meet_times VARCHAR2(80),
club_email VARCHAR2(40) NOT NULL CONSTRAINT p_clubs_club_email_uk UNIQUE,
club_phone VARCHAR2(16) CONSTRAINT p_clubs_club_phone_uk UNIQUE,
organiser VARCHAR2(20) NOT NULL CONSTRAINT p_clubs_organiser_uk UNIQUE,
permission VARCHAR2(6) NOT NULL CHECK (permission = 'paid'),
FOREIGN KEY (organiser, permission) REFERENCES p_users(user_name, user_type)
);

-- can only do ALTER TABLE statement after p_clubs table is created --

ALTER TABLE p_users
ADD CONSTRAINT p_users_members_fk FOREIGN KEY (member_of) REFERENCES p_clubs(club_name)
;


CREATE TABLE p_discounts
(disc_code VARCHAR2(16) CONSTRAINT p_discounts_disc_code_pk PRIMARY KEY,
disc_type VARCHAR2(12) NOT NULL,
days NUMBER(5,0) NOT NULL,
activated NUMBER(1,0) DEFAULT 0 NOT NULL,
sub_id NUMBER(12,0) DEFAULT NULL,
CHECK(activated >= 0 AND activated <= 1),
CONSTRAINT p_disc_sub_idb_fk FOREIGN KEY (sub_id) REFERENCES p_users(sub_id),
CHECK(activated = 0 OR sub_id IS NOT NULL),
CHECK(activated = 1 OR sub_id IS NULL)
);

CREATE TABLE p_combat_tiles
(tile_id NUMBER(12,0) CONSTRAINT combat_tile_id_pk PRIMARY KEY,
tile_name VARCHAR2(40) NOT NULL,
image VARCHAR2(40) NOT NULL,
user_name VARCHAR2(20) NOT NULL,
CONSTRAINT p_tiles_user_name_fk FOREIGN KEY (user_name) REFERENCES p_users(user_name)
);



CREATE TABLE p_units
(unit_id NUMBER(12,0) CONSTRAINT p_units_unit_id_pk PRIMARY KEY,
unit_name VARCHAR2(30) NOT NULL,
user_name VARCHAR2(20) NOT NULL,
unit_qty NUMBER(2) DEFAULT 1 NOT NULL CHECK(unit_qty >= 1 AND unit_qty <= 10),
psych VARCHAR2(10) DEFAULT NULL,
class VARCHAR2(21) NOT NULL,
armour NUMBER(1,0) NOT NULL CHECK(armour >= 0 AND armour <= 5),
tech VARCHAR2(10) NOT NULL CHECK(tech = 'primitive' OR tech = 'typical' OR tech = 'advanced'),
mobility VARCHAR2(12) NOT NULL,
targeting NUMBER(2,0) NOT NULL CHECK (targeting = 4 OR targeting = 6 OR targeting = 8 OR targeting = 10 OR targeting = 12),
assault NUMBER(2,0) NOT NULL CHECK (assault = 4 OR assault = 6 OR assault = 8 OR assault = 10 OR assault = 12),
unit_rules VARCHAR2(60) DEFAULT NULL,
tile_id NUMBER(12) DEFAULT NULL,
capacity_id NUMBER(12,0) DEFAULT NULL,
loadout_id NUMBER(12,0) DEFAULT NULL,
CONSTRAINT p_units_user_name_fk FOREIGN KEY (user_name) REFERENCES p_users(user_name),
CONSTRAINT p_units_tile_id_fk FOREIGN KEY (tile_id) REFERENCES p_combat_tiles(tile_id),
UNIQUE (unit_name, user_name),
CHECK (capacity_id IS NULL OR loadout_id IS NULL)
);


CREATE TABLE p_transport_capacities
(capacity_id NUMBER(12,0) CONSTRAINT p_transport_capacities_id_pk PRIMARY KEY,
unit_id NUMBER(12,0),
capacity NUMBER(2,0) NOT NULL CHECK(capacity >= 1 AND capacity <= 90),
UNIQUE (unit_id),
CONSTRAINT transport_capacity_unit_id_fk FOREIGN KEY (unit_id) REFERENCES p_units(unit_id)
);


CREATE TABLE p_weapon_loadouts
(loadout_id NUMBER(12,0) CONSTRAINT p_weapon_loadout_id_pk PRIMARY KEY,
unit_id NUMBER(12,0),
UNIQUE (unit_id),
CONSTRAINT weapon_loadout_unit_id_fk FOREIGN KEY (unit_id) REFERENCES p_units(unit_id)
);


-- can only do ALTER TABLE statements after p_transport_capacities--
-- AND p_weapon_loadouts tables are created --

ALTER TABLE p_units
ADD CONSTRAINT p_unit_capacity_fk FOREIGN KEY (capacity_id) REFERENCES p_transport_capacities(capacity_id);

ALTER TABLE p_units
ADD CONSTRAINT p_unit_loadout_fk FOREIGN KEY (loadout_id) REFERENCES p_weapon_loadouts(loadout_id);


CREATE TABLE p_weapons
(wpn_id NUMBER(12,0) CONSTRAINT p_weapon_wpn_id_pk PRIMARY KEY,
wpn_category VARCHAR2(24) NOT NULL,
wpn_class NUMBER(1,0) NOT NULL CHECK (wpn_class >=1 AND wpn_class <= 5),
wpn_qty NUMBER(1,0) NOT NULL CHECK (wpn_qty >= 1 AND wpn_qty <= 6),
loadout_id NUMBER(12,0) NOT NULL,
inf_cav_aa NUMBER(1,0) CHECK (inf_cav_aa >= 0 AND inf_cav_aa <= 1),
vehicle_aa VARCHAR2(4) CHECK (vehicle_aa = 'yes' OR vehicle_aa = 'no' OR vehicle_aa = 'only'),
wpn_arc VARCHAR2(14),
wpn_type VARCHAR2(7) NOT NULL CHECK (wpn_type = 'inf/cav' OR wpn_type = 'vehicle'),
CONSTRAINT weapon_loadout_id_fk FOREIGN KEY (loadout_id) REFERENCES p_weapon_loadouts(loadout_id),
UNIQUE (wpn_category, wpn_class, loadout_id, inf_cav_aa, vehicle_aa, wpn_arc, wpn_type),
CHECK (inf_cav_aa IS NULL OR (vehicle_aa IS NULL AND wpn_arc IS NULL)),
CHECK (inf_cav_aa IS NOT NULL OR (vehicle_aa IS NOT NULL AND wpn_arc IS NOT NULL)),
CHECK (inf_cav_aa IS NULL OR wpn_type = 'inf/cav'),
CHECK ((vehicle_aa IS NULL AND wpn_arc IS NULL) OR wpn_type = 'vehicle')
);


CREATE TABLE p_formations
(form_id NUMBER(12,0) CONSTRAINT p_formation_form_id_pk PRIMARY KEY,
form_name VARCHAR2(20) NOT NULL,
cmd_form NUMBER(1,0) DEFAULT 0 NOT NULL CHECK(cmd_form >= 0 AND cmd_form <= 1),
cmd_id NUMBER(12,0) DEFAULT NULL,
user_name VARCHAR(20) NOT NULL,
CONSTRAINT formation_cmd_id_fk FOREIGN KEY (cmd_id) REFERENCES p_formations(form_id),
CONSTRAINT formation_user_name_fk FOREIGN KEY (user_name) REFERENCES p_users(user_name),
UNIQUE (form_name, user_name)
);

CREATE TABLE p_unit_in_formation
(unit_id NUMBER(12,0),
form_id NUMBER(12,0),
CONSTRAINT unit_in_form_unit_id_fk FOREIGN KEY (unit_id) REFERENCES p_units(unit_id),
CONSTRAINT unit_in_form_form_id_fk FOREIGN KEY (form_id) REFERENCES p_formations(form_id),
CONSTRAINT p_unit_in_form_unit_form_id_pk PRIMARY KEY (unit_id, form_id)
);


CREATE TABLE p_army_lists
(army_id NUMBER(12,0) CONSTRAINT p_army_list_army_id_pk PRIMARY KEY,
army_name VARCHAR2(40) NOT NULL,
army_rules VARCHAR2(60) DEFAULT NULL,
user_name VARCHAR2(20) NOT NULL,
CONSTRAINT army_list_user_name_fk FOREIGN KEY (user_name) REFERENCES p_users(user_name),
UNIQUE (army_name, user_name)
);


CREATE TABLE p_formation_in_army_list
(form_id NUMBER(12),
army_id NUMBER(12),
CONSTRAINT form_in_army_list_form_id_fk FOREIGN KEY (form_id) REFERENCES p_formations(form_id),
CONSTRAINT form_in_army_list_army_id_fk FOREIGN KEY (army_id) REFERENCES p_army_lists(army_id),
CONSTRAINT p_form_in_list_form_army_id_pk PRIMARY KEY (form_id, army_id)
);

CREATE TABLE p_army_rosters
(roster_name VARCHAR2(40),
max_points NUMBER(7,0) DEFAULT NULL,
army_id NUMBER(12,0),
user_name VARCHAR2(20),
CONSTRAINT p_army_roster_army_id_fk FOREIGN KEY (army_id) REFERENCES p_army_lists(army_id),
CONSTRAINT army_roster_user_name_fk FOREIGN KEY (user_name) REFERENCES p_users(user_name),
CONSTRAINT p_roster_name_user_name_pk PRIMARY KEY (roster_name, user_name)
);

CREATE TABLE p_roster_histories
(roster_name VARCHAR2(40),
roster_timestamp DATE,
user_name VARCHAR2(20),
army_id NUMBER(12,0),
max_points NUMBER(7,0) DEFAULT NULL,
CONSTRAINT roster_hist_roster_fk FOREIGN KEY (roster_name, user_name) REFERENCES p_army_rosters(roster_name, user_name),
CONSTRAINT roster_hist_user_fk FOREIGN KEY (user_name) REFERENCES p_users(user_name),
CONSTRAINT roster_hist_stamp_pk PRIMARY KEY (roster_name, user_name, roster_timestamp)
);

CREATE TABLE p_user_histories
(user_name VARCHAR2(20),
user_timestamp DATE,
is_banned NUMBER(1, 0) DEFAULT 0 NOT NULL CHECK(is_banned >= 0 AND is_banned <= 1),
user_type VARCHAR2(6) DEFAULT 'unpaid' NOT NULL CHECK (user_type = 'paid' OR user_type = 'unpaid'),
paid_type VARCHAR2(10) CHECK (paid_type = 'subscriber' OR paid_type = 'fully_paid'),
CONSTRAINT user_hist_name_fk FOREIGN KEY (user_name) REFERENCES p_users(user_name),
CONSTRAINT p_user_hist_name_stamp_pk PRIMARY KEY (user_name, user_timestamp)
);

--populate users, without member_of--

INSERT INTO p_users
(user_name, first_name, last_name, password, user_email, u_location, is_banned, user_type)
VALUES
('badbonnie', 'Bonnie', 'Andclyde', 'tommygun', 'bonnie@bank.us', 'Bienville Parish, Louisiana, U.S.A.', 1,'unpaid');

INSERT INTO p_users
(user_name, first_name, last_name, password, user_email, u_location, is_banned, user_type, profile_pic, purchase_id, date_paid, paid_type)
VALUES
('ByronCEW', 'Byron', 'Collins', 'publishize', 'admin@polyversal-game.com', 'Virginia, U.S.A', 0, 'paid', 'picofByron.jpg', 000000000001, TO_DATE('05/04/2017', 'DD/MM/YYYY'), 'fully_paid');

INSERT INTO p_users
(user_name, first_name, last_name, password, user_email, u_location, is_banned, user_type, profile_pic, purchase_id, date_paid, paid_type)
VALUES
('KenCEW', 'Ken', 'Whitehurst', 'designinator', 'ken@polyversal-game.com', 'Virginia, U.S.A.', 0, 'paid', 'kenWplayspolyversal.gif', 000000000002, TO_DATE('06/04/2017', 'DD/MM/YYYY'), 'fully_paid');

INSERT INTO p_users
(user_name, first_name, last_name, password, user_email, u_location, is_banned, sub_id, user_type, profile_pic, sub_date, sub_length, paid_type)
VALUES
('MikeHobbs', 'Mike', 'Hobbs', 'mnmpod', 'meeplespodcast@gmail.com', 'London, UK', 0, 000000000001, 'paid', 'mikey.png', TO_DATE('12/04/2017', 'DD/MM/YYYY'), 90, 'subscriber');

INSERT INTO p_users
(user_name, first_name, last_name, password, user_email, u_location, is_banned, user_type)
VALUES
('dicebaglady', 'Annie', 'Oakley', 'squeeeak', 'annie@badsquiddo.uk', 'London, UK', 0, 'unpaid');

INSERT INTO p_users
(user_name, first_name, last_name, password, user_email, u_location, is_banned, sub_id, user_type, profile_pic, purchase_id, date_paid, paid_type)
VALUES
('robertBA', 'Robert', 'Alexander', 'letmein', 'robert.b.alexamder@gmail.com', 'Waterford, Ireland', 0, 000000000002, 'paid', 'rba_img.png', 000000000003, TO_DATE('28/04/2017', 'DD/MM/YYYY'), 'fully_paid');

INSERT INTO p_users
(user_name, first_name, last_name, password, user_email, u_location, is_banned, user_type)
VALUES
('Brianer', 'Bryan', 'Bryansone', 'justbrian', 'brian@brianson.ie', 'Dublin, Ireland', 0, 'unpaid');

INSERT INTO p_users
(user_name, first_name, last_name, password, user_email, u_location, is_banned, user_type, profile_pic, purchase_id, date_paid, paid_type)
VALUES
('Timmy', 'Tim', 'Tom', 'summoner', 'timtom@thumb.ie', 'Waterford, Ireland', 1, 'paid', 'timmy.png', 000000000004, TO_DATE('09/05/2017', 'DD/MM/YYYY'), 'fully_paid');

INSERT INTO p_users
(user_name, first_name, last_name, password, user_email, u_location, is_banned, sub_id, user_type)
VALUES
('LazyDaisey', 'Daisey', 'Planter', 'inDafie1ds', 'lackadaisey@gmail.com', 'Galway, Ireland', 0, 000000000003, 'unpaid');

INSERT INTO p_users
(user_name, first_name, last_name, password, user_email, u_location, is_banned, user_type)
VALUES
('MrBlister', 'Ben', 'OShea', 'out4there', 'ben@gmail.com', 'Waterford, Ireland', 0, 'unpaid');

INSERT INTO p_users
(user_name, first_name, last_name, password, user_email, u_location, is_banned, sub_id, user_type, profile_pic, sub_date, sub_length, paid_type)
VALUES
('CraigM', 'Craig', 'Mac', 'warhead', 'craigm@gmail.com', 'Waterford, Ireland', 0, 000000000004, 'paid', 'craig.jpg', TO_DATE('07/05/2017', 'DD/MM/YYYY'), 60, 'subscriber');

INSERT INTO p_users
(user_name, first_name, last_name, password, user_email, u_location, is_banned, sub_id, user_type, sub_date, sub_length, paid_type)
VALUES
('Petermanman', 'Peter', 'Peterman', 'allpeter', 'peter@peterman.co.uk', 'Helisinki, Finland', 0, 000000000005, 'paid', TO_DATE('09/06/2017', 'DD/MM/YYYY'), 30, 'subscriber');

--populate clubs--

INSERT INTO p_clubs
(club_name, c_location, meet_times, club_email, club_phone, organiser, permission)
VALUES
('Polyversal HQ', 'Virginia, U.S.A.', 'every friday', 'admin@polyversal-game.com', '00-1-848353454', 'ByronCEW', 'paid');

INSERT INTO p_clubs
(club_name, c_location, meet_times, club_email, organiser, permission)
VALUES
('Meeples and Miniatures', 'London, UK', 'Wednesday 5:00pm, Saturday 2:00pm', 'meeplespodcast@gmail.com', 'MikeHobbs', 'paid');

INSERT INTO p_clubs
(club_name, c_location, meet_times, club_email, club_phone, organiser, permission)
VALUES
('Waterford Wargames, Waterford', 'Edmun Rice Center, Waterford, Ireland', 'Every second Wednesday at 5:30pm', 'craigm@gmail.com', 0837463756, 'CraigM', 'paid');

--update users after clubs created--

UPDATE p_users
SET member_of = 'Polyversal HQ'
WHERE user_name = 'ByronCEW'
;

UPDATE p_users
SET member_of = 'Polyversal HQ'
WHERE user_name = 'KenCEW'
;

UPDATE p_users
SET member_of = 'Meeples and Miniatures'
WHERE user_name = 'MikeHobbs'
;

UPDATE p_users
SET member_of = 'Meeples and Miniatures'
WHERE user_name = 'dicebaglady'
;

UPDATE p_users
SET member_of = 'Meeples and Miniatures'
WHERE user_name = 'Petermanman'
;

UPDATE p_users
SET member_of = 'Waterford Wargames, Waterford'
WHERE user_name = 'robertBA'
;

UPDATE p_users
SET member_of = 'Waterford Wargames, Waterford'
WHERE user_name = 'LazyDaisey'
;

UPDATE p_users
SET member_of = 'Waterford Wargames, Waterford'
WHERE user_name = 'CraigM'
;

--populate discounts--

INSERT INTO p_discounts
(disc_code, disc_type, days, activated, sub_id)
VALUES
('89h2fuh92h4g2c83', 'Promotion', 30, 1, 000000000001);

INSERT INTO p_discounts
(disc_code, disc_type, days, activated)
VALUES
('3jc84mgiutmeif8t', 'Competition', 90, 0);

INSERT INTO p_discounts
(disc_code, disc_type, days, activated, sub_id)
VALUES
('9jh5vg82amj09lkt', 'Free Trial', 30, 1, 000000000002);

INSERT INTO p_discounts
(disc_code, disc_type, days, activated, sub_id)
VALUES
('8unjmkijthbujnhy', 'Free Trial', 30, 1, 000000000002);

INSERT INTO p_discounts
(disc_code, disc_type, days, activated)
VALUES
('64b4g5vrgftdbchf', 'Free Trial', 30, 0);

INSERT INTO p_discounts
(disc_code, disc_type, days, activated)
VALUES
('3nd7fhr9tmghvigm', 'Gift', 60, 0);

--populate combat tiles--

INSERT INTO p_combat_tiles
(tile_id, tile_name, image, user_name)
VALUES
(111111111112, 'Encegon_tanks_advance', 'Encegon_tanks_massino.png', 'KenCEW');

INSERT INTO p_combat_tiles
(tile_id, tile_name, image, user_name)
VALUES
(111111111113, 'Heli_vulture', 'Copters_at_dusk.png', 'KenCEW');

INSERT INTO p_combat_tiles
(tile_id, tile_name, image, user_name)
VALUES
(111111111114, 'pioneer_ships', 'spaceship_construction_yard.png', 'KenCEW');

INSERT INTO p_combat_tiles
(tile_id, tile_name, image, user_name)
VALUES
(111111111115, 'TigerClaw_Superheavy', 'superheavy_tank_firing.png', 'KenCEW');

INSERT INTO p_combat_tiles
(tile_id, tile_name, image, user_name)
VALUES
(111111111116, 'Infantry_exit_APC', 'DRM_infantry_APC.jpg', 'robertBA');

INSERT INTO p_combat_tiles
(tile_id, tile_name, image, user_name)
VALUES
(111111111117, 'infantry_snipers', 'infantry_roof_lookout.jpg', 'robertBA');

--popullate units--

INSERT INTO p_units
(unit_id, unit_name, user_name, unit_qty, class, armour, tech, mobility, targeting, assault, tile_id)
VALUES
(222222222221, 'Encegon', 'KenCEW', 3, 'Medium', 2, 'typical', 'tracked', 8, 6, 111111111112);

INSERT INTO p_units
(unit_id, unit_name, user_name, unit_qty, class, armour, tech, mobility, targeting, assault, unit_rules, tile_id)
VALUES
(222222222222, 'Pioneer Starship', 'MikeHobbs', 1, 'Colossal', 4, 'advanced', 'Flyer', 4, 4, 'Drop from above',111111111114);

INSERT INTO p_units
(unit_id, unit_name, user_name, unit_qty, psych, class, armour, tech, mobility, targeting, assault)
VALUES
(222222222223, 'Land Train', 'robertBA', 1, 'relentless', 'Super Heavy', 5, 'primitive', 'tracked', 4, 10);

INSERT INTO p_units
(unit_id, unit_name, user_name, unit_qty, class, armour, tech, mobility, targeting, assault)
VALUES
(222222222224, 'Island Hopper', 'MikeHobbs', 3, 'Light', 1, 'typical', 'boat', 4, 4);

INSERT INTO p_units
(unit_id, unit_name, user_name, unit_qty, class, armour, tech, mobility, targeting, assault, unit_rules, tile_id)
VALUES
(222222222225, 'APC', 'KenCEW', 4, 'Medium', 3, 'typical', 'tracked', 4, 6, 'Fast Deployment', 111111111116);

INSERT INTO p_units
(unit_id, unit_name, user_name, unit_qty, psych, class, armour, tech, mobility, targeting, assault, tile_id)
VALUES
(222222222226, 'Heli Carrier', 'robertBA', 3, 'mercenary', 'Medium', 1, 'typical', 'flyer', 4, 4, 111111111113);

INSERT INTO p_units
(unit_id, unit_name, user_name, unit_qty, psych, class, armour, tech, mobility, targeting, assault)
VALUES
(222222222227, 'Hover Hop', 'MikeHobbs', 6, 'mercenary', 'Light', 0, 'typical', 'hover', 4, 4);

INSERT INTO p_units
(unit_id, unit_name, user_name, unit_qty, psych, class, armour, tech, mobility, targeting, assault, tile_id)
VALUES
(222222222228, 'Viper', 'KenCEW', 3, 'mercenary', 'Medium', 2, 'typical', 'flyer', 10, 4, 111111111113);

INSERT INTO p_units
(unit_id, unit_name, user_name, unit_qty, psych, class, armour, tech, mobility, targeting, assault, tile_id)
VALUES
(222222222229, 'Industrial Infantry', 'robertBA', 6, 'Untrained', 'Light', 0, 'primitive', 'infantry', 6, 8, 111111111116);

INSERT INTO p_units
(unit_id, unit_name, user_name, unit_qty, psych, class, armour, tech, mobility, targeting, assault, unit_rules, tile_id)
VALUES
(222222222210, 'Sniper Team', 'MikeHobbs', 2, 'Mercenary', 'Light', 0, 'advanced', 'infantry', 12, 4, 'Stealthy', 111111111117);

INSERT INTO p_units
(unit_id, unit_name, user_name, unit_qty, psych, class, armour, tech, mobility, targeting, assault, tile_id)
VALUES
(222222222211, 'Infantry Specialists', 'KenCEW', 4, 'Relentless', 'Heavy', 3, 'advanced', 'infantry', 10, 6, 111111111116);

--populate transport capacities--

INSERT INTO p_transport_capacities
(capacity_id, unit_id, capacity)
VALUES
(333333333331, 222222222222, 90);

INSERT INTO p_transport_capacities
(capacity_id, unit_id, capacity)
VALUES
(333333333332, 222222222223, 60);

INSERT INTO p_transport_capacities
(capacity_id, unit_id, capacity)
VALUES
(333333333333, 222222222224, 4);

INSERT INTO p_transport_capacities
(capacity_id, unit_id, capacity)
VALUES
(333333333334, 222222222225, 4);

INSERT INTO p_transport_capacities
(capacity_id, unit_id, capacity)
VALUES
(333333333335, 222222222226, 12);

INSERT INTO p_transport_capacities
(capacity_id, unit_id, capacity)
VALUES
(333333333336, 222222222227, 2);

--populate weapon loadouts--

INSERT INTO p_weapon_loadouts
(loadout_id, unit_id)
VALUES
(444444444441, 222222222221);

INSERT INTO p_weapon_loadouts
(loadout_id, unit_id)
VALUES
(444444444442, 222222222228);

INSERT INTO p_weapon_loadouts
(loadout_id, unit_id)
VALUES
(444444444443, 222222222229);

INSERT INTO p_weapon_loadouts
(loadout_id, unit_id)
VALUES
(444444444444, 222222222210);

INSERT INTO p_weapon_loadouts
(loadout_id, unit_id)
VALUES
(444444444445, 222222222211);

--update units--

UPDATE p_units
SET loadout_id = 444444444441
WHERE unit_id = 222222222221
;

UPDATE p_units
SET capacity_id = 333333333331
WHERE unit_id = 222222222222
;

UPDATE p_units
SET capacity_id = 333333333332
WHERE unit_id = 222222222223
;

UPDATE p_units
SET capacity_id = 333333333333
WHERE unit_id = 222222222224
;

UPDATE p_units
SET capacity_id = 333333333334
WHERE unit_id = 222222222225
;

UPDATE p_units
SET capacity_id = 333333333335
WHERE unit_id = 222222222226
;

UPDATE p_units
SET capacity_id = 333333333336
WHERE unit_id = 222222222227
;

UPDATE p_units
SET loadout_id = 444444444442
WHERE unit_id = 222222222228
;

UPDATE p_units
SET loadout_id = 444444444443
WHERE unit_id = 222222222229
;

UPDATE p_units
SET loadout_id = 444444444444
WHERE unit_id = 222222222210
;

UPDATE p_units
SET loadout_id = 444444444445
WHERE unit_id = 222222222211
;

--populate weapons--

INSERT INTO p_weapons
(wpn_id, wpn_category, wpn_class, wpn_qty, loadout_id, inf_cav_aa, wpn_type)
VALUES
(555555555551, 'Laser Small Arms', 3, 1, 444444444444, 1, 'inf/cav');

INSERT INTO p_weapons
(wpn_id, wpn_category, wpn_class, wpn_qty, loadout_id, inf_cav_aa, wpn_type)
VALUES
(555555555552, 'Conventional Small Arms', 2, 1, 444444444443, 0, 'inf/cav');

INSERT INTO p_weapons
(wpn_id, wpn_category, wpn_class, wpn_qty, loadout_id, inf_cav_aa, wpn_type)
VALUES
(555555555553, 'Chemical', 1, 2, 444444444445, 0, 'inf/cav');

INSERT INTO p_weapons
(wpn_id, wpn_category, wpn_class, wpn_qty, loadout_id, inf_cav_aa, wpn_type)
VALUES
(555555555554, 'Conventional Small Arms', 3, 1, 444444444445, 0, 'inf/cav');

INSERT INTO p_weapons
(wpn_id, wpn_category, wpn_class, wpn_qty, loadout_id, vehicle_aa, wpn_arc, wpn_type)
VALUES
(555555555555, 'Missiles', 4, 6, 444444444442, 'only', 'Forward 180', 'vehicle');

INSERT INTO p_weapons
(wpn_id, wpn_category, wpn_class, wpn_qty, loadout_id, vehicle_aa, wpn_arc, wpn_type)
VALUES
(555555555556, 'Missiles', 4, 6, 444444444441, 'yes', 'Full 360', 'vehicle');

INSERT INTO p_weapons
(wpn_id, wpn_category, wpn_class, wpn_qty, loadout_id, vehicle_aa, wpn_arc, wpn_type)
VALUES
(555555555557, 'Pulse Laser', 1, 1, 444444444441, 'no', 'Left 180', 'vehicle');

INSERT INTO p_weapons
(wpn_id, wpn_category, wpn_class, wpn_qty, loadout_id, vehicle_aa, wpn_arc, wpn_type)
VALUES
(555555555558, 'Pulse Laser', 1, 1, 444444444441, 'no', 'Right 180', 'vehicle');

--populate formations--

INSERT INTO p_formations
(form_id, form_name, cmd_form, user_name)
VALUES
(66666666661, 'Air Command', 1, 'KenCEW');

INSERT INTO p_formations
(form_id, form_name, cmd_form, user_name)
VALUES
(66666666662, 'Front Lines Command', 1, 'KenCEW');

INSERT INTO p_formations
(form_id, form_name, cmd_form, cmd_id, user_name)
VALUES
(66666666663, 'Sea Serpent', 0, 66666666661, 'KenCEW');

INSERT INTO p_formations
(form_id, form_name, cmd_form, cmd_id, user_name)
VALUES
(66666666664, 'Valkyrie', 0, 66666666661, 'KenCEW');

INSERT INTO p_formations
(form_id, form_name, cmd_form, cmd_id, user_name)
VALUES
(66666666665, 'Big Push', 0, 66666666662, 'robertBA');

INSERT INTO p_formations
(form_id, form_name, cmd_form, user_name)
VALUES
(66666666666, 'Hired Guns', 0, 'robertBA');

--populate unit_in_formation--

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222222, 66666666661);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222221, 66666666662);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222225, 66666666662);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222211, 66666666662);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222224, 66666666663);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222227, 66666666663);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222229, 66666666663);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222211, 66666666663);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222226, 66666666664);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222228, 66666666664);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222221, 66666666664);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222223, 66666666665);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222225, 66666666665);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222229, 66666666665);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222210, 66666666665);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222211, 66666666665);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222226, 66666666666);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222210, 66666666666);

INSERT INTO p_unit_in_formation
(unit_id, form_id)
VALUES
(222222222227, 66666666666);

--populate army lists--

INSERT INTO p_army_lists
(army_id, army_name, army_rules, user_name)
VALUES
(777777777771, 'United Corporations', 'Regimented discipline', 'KenCEW');

INSERT INTO p_army_lists
(army_id, army_name, user_name)
VALUES
(777777777772, 'Asiatic Republic', 'KenCEW');

INSERT INTO p_army_lists
(army_id, army_name, army_rules, user_name)
VALUES
(777777777773, 'Independant Industrialists', 'No Command Formations allowed', 'robertBA');

--populate formation_in_army_list --

INSERT INTO p_formation_in_army_list
(form_id, army_id)
VALUES
(66666666661, 777777777771);

INSERT INTO p_formation_in_army_list
(form_id, army_id)
VALUES
(66666666662, 777777777771);

INSERT INTO p_formation_in_army_list
(form_id, army_id)
VALUES
(66666666664, 777777777771);

INSERT INTO p_formation_in_army_list
(form_id, army_id)
VALUES
(66666666666, 777777777771);

INSERT INTO p_formation_in_army_list
(form_id, army_id)
VALUES
(66666666662, 777777777772);

INSERT INTO p_formation_in_army_list
(form_id, army_id)
VALUES
(66666666663, 777777777772);

INSERT INTO p_formation_in_army_list
(form_id, army_id)
VALUES
(66666666665, 777777777772);

INSERT INTO p_formation_in_army_list
(form_id, army_id)
VALUES
(66666666666, 777777777772);

INSERT INTO p_formation_in_army_list
(form_id, army_id)
VALUES
(66666666663, 777777777773);

INSERT INTO p_formation_in_army_list
(form_id, army_id)
VALUES
(66666666664, 777777777773);

INSERT INTO p_formation_in_army_list
(form_id, army_id)
VALUES
(66666666666, 777777777773);

--populate army rosters--

INSERT INTO p_army_rosters
(roster_name, max_points, army_id, user_name)
VALUES
('Mikes Mercenaries', 2000, 777777777773, 'MikeHobbs');

INSERT INTO p_army_rosters
(roster_name, max_points, army_id, user_name)
VALUES
('Independant small force', 1500, 777777777773, 'MikeHobbs');

INSERT INTO p_army_rosters
(roster_name, max_points, army_id, user_name)
VALUES
('All my units', 6000, 777777777773, 'MikeHobbs');

INSERT INTO p_army_rosters
(roster_name, max_points, army_id, user_name)
VALUES
('Starndard Corp', 2000, 777777777771, 'KenCEW');

INSERT INTO p_army_rosters
(roster_name, max_points, army_id, user_name)
VALUES
('Standard Republic', 2000, 777777777771, 'KenCEW');

INSERT INTO p_army_rosters
(roster_name, max_points, army_id, user_name)
VALUES
('Standard Industrialists', 2000, 777777777771, 'KenCEW');

INSERT INTO p_army_rosters
(roster_name, max_points, army_id, user_name)
VALUES
('Robs 2000pt tourney list', 2000, 777777777772, 'robertBA');

INSERT INTO p_army_rosters
(roster_name, army_id, user_name)
VALUES
('Campaign event list', 777777777772, 'robertBA');

INSERT INTO p_army_rosters
(roster_name, army_id, user_name)
VALUES
('Timmys test', 777777777773, 'Timmy');

INSERT INTO p_army_rosters
(roster_name, max_points, army_id, user_name)
VALUES
('Escalation league CorpArmy', 1000, 777777777771, 'CraigM');

INSERT INTO p_army_rosters
(roster_name, max_points, army_id, user_name)
VALUES
('Escalation league Robs Republic', 1000, 777777777772, 'robertBA');

--populate rosters histories--

INSERT INTO p_roster_histories
(roster_name, roster_timestamp, user_name, army_id)
VALUES
('All my units', TO_DATE ('05-04-2017 21:54:50', 'dd-mm-yyyy hh24:mi:ss'), 'MikeHobbs', 777777777773);

INSERT INTO p_roster_histories
(roster_name, roster_timestamp, user_name, army_id, max_points)
VALUES
('All my units', TO_DATE ('12-04-2017 21:24:50', 'dd-mm-yyyy hh24:mi:ss'), 'MikeHobbs', 777777777773, 4000);

INSERT INTO p_roster_histories
(roster_name, roster_timestamp, user_name, army_id, max_points)
VALUES
('All my units', TO_DATE ('21-04-2017 09:12:43', 'dd-mm-yyyy hh24:mi:ss'), 'MikeHobbs', 777777777773, 6000);

INSERT INTO p_roster_histories
(roster_name, roster_timestamp, user_name, army_id, max_points)
VALUES
('Escalation league Robs Republic', TO_DATE ('24-04-2017 15:24:17', 'dd-mm-yyyy hh24:mi:ss'), 'robertBA', 777777777772, 500);

INSERT INTO p_roster_histories
(roster_name, roster_timestamp, user_name, army_id, max_points)
VALUES
('Escalation league Robs Republic', TO_DATE ('12-03-2017 03:14:03', 'dd-mm-yyyy hh24:mi:ss'), 'robertBA', 777777777772, 1000);

--popualate user histories--

INSERT INTO p_user_histories
(user_name, user_timestamp, is_banned, user_type)
VALUES
('robertBA', TO_DATE ('05-04-2017 17:14:53', 'dd-mm-yyyy hh24:mi:ss'), 0, 'unpaid');

INSERT INTO p_user_histories
(user_name, user_timestamp, is_banned, user_type, paid_type)
VALUES
('robertBA', TO_DATE ('06-04-2017 21:54:50', 'dd-mm-yyyy hh24:mi:ss'), 0, 'paid', 'subscriber');

INSERT INTO p_user_histories
(user_name, user_timestamp, is_banned, user_type, paid_type)
VALUES
('robertBA', TO_DATE ('07-04-2017 17:14:53', 'dd-mm-yyyy hh24:mi:ss'), 1, 'paid', 'subscriber');

INSERT INTO p_user_histories
(user_name, user_timestamp, is_banned, user_type)
VALUES
('robertBA', TO_DATE ('20-04-2017 21:54:50', 'dd-mm-yyyy hh24:mi:ss'), 1, 'unpaid');

INSERT INTO p_user_histories
(user_name, user_timestamp, is_banned, user_type)
VALUES
('robertBA', TO_DATE ('21-04-2017 09:12:43', 'dd-mm-yyyy hh24:mi:ss'), 0, 'unpaid');

INSERT INTO p_user_histories
(user_name, user_timestamp, is_banned, user_type, paid_type)
VALUES
('robertBA', TO_DATE ('24-04-2017 15:24:17', 'dd-mm-yyyy hh24:mi:ss'), 0, 'paid', 'fully_paid');

INSERT INTO p_user_histories
(user_name, user_timestamp, is_banned, user_type)
VALUES
('badbonnie', TO_DATE ('01-04-2017 15:24:53', 'dd-mm-yyyy hh24:mi:ss'), 0, 'unpaid');

INSERT INTO p_user_histories
(user_name, user_timestamp, is_banned, user_type)
VALUES
('badbonnie', TO_DATE ('07-04-2017 17:54:50', 'dd-mm-yyyy hh24:mi:ss'), 1, 'unpaid');

INSERT INTO p_user_histories
(user_name, user_timestamp, is_banned, user_type, paid_type)
VALUES
('Timmy', TO_DATE ('12-03-2017 03:14:03', 'dd-mm-yyyy hh24:mi:ss'), 0, 'paid', 'fully_paid');
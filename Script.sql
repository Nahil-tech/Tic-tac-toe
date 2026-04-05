DROP SCHEMA IF EXISTS tictac2 CASCADE;  
CREATE SCHEMA tictac2;
SET SEARCH_PATH TO tictac2;

CREATE TABLE MORPION (
    id_morpion     SERIAL PRIMARY KEY,
    nom            VARCHAR(50) NOT NULL,
    image          VARCHAR(200) NOT NULL,
    pv             INT NOT NULL CHECK (pv >= 1),
    attaque        INT NOT NULL CHECK (attaque >= 1),
    mana           INT NOT NULL CHECK (mana >= 1),
    reussite       INT NOT NULL CHECK (reussite >= 1),
    CHECK (pv + attaque + mana + reussite = 15)
);

CREATE TABLE EQUIPE (
    id_equipe      SERIAL PRIMARY KEY,
    nom            VARCHAR(50) NOT NULL,
    couleur        VARCHAR(30) NOT NULL UNIQUE,
    date_creation  DATE NOT NULL
);

CREATE TABLE COMPOSER (
    id_equipe_morpion SERIAL PRIMARY KEY,
    id_equipe      INT REFERENCES EQUIPE(id_equipe) ON DELETE CASCADE,
    id_morpion     INT REFERENCES MORPION(id_morpion) ON DELETE CASCADE
);

CREATE TABLE CONFIGURATION (
    id_config      SERIAL PRIMARY KEY,
    date_config    DATE NOT NULL,
    taille_grille  INT NOT NULL CHECK (taille_grille IN (3, 4)),
    max_tours      INT NOT NULL CHECK (max_tours > 0)
);

CREATE TABLE PARTIE (
    id_partie      SERIAL PRIMARY KEY,
    date_debut     TIMESTAMP NOT NULL,
    date_fin       TIMESTAMP NULL,
    gagnante       INT NULL REFERENCES EQUIPE(id_equipe),
    id_config      INT NOT NULL REFERENCES CONFIGURATION(id_config)
);

CREATE TABLE PARTICIPATION (
    id_partie      INT REFERENCES PARTIE(id_partie) ON DELETE CASCADE,
    id_equipe      INT REFERENCES EQUIPE(id_equipe),
    PRIMARY KEY(id_partie, id_equipe)
);

CREATE TABLE JOURNAL (
    id_partie      INT NOT NULL REFERENCES PARTIE(id_partie) ON DELETE CASCADE,
    id_ligne       INT NOT NULL,
    new_ligne      INT,      -- Coordonnée X
    new_colonne    INT,      -- Coordonnée Y
    id_morpion     INT REFERENCES MORPION(id_morpion), -- AJOUTÉ : Quel pion ?
    id_equipe      INT REFERENCES EQUIPE(id_equipe),   -- AJOUTÉ : Quelle couleur ?
    date_action    TIMESTAMP NOT NULL,
    texte          TEXT NOT NULL,
    PRIMARY KEY (id_partie, id_ligne)
);

-- Insertion des 16 Morpions
INSERT INTO MORPION (nom, image, pv, attaque, mana, reussite) VALUES
('Dragon Feu', '/static/img/t1.png', 5, 4, 3, 3),
('Chevalier Noir', '/static/img/t2.png', 6, 3, 2, 4),
('Mage Arcane', '/static/img/t3.png', 3, 2, 6, 4),
('Elfe Chasseur', '/static/img/t4.png', 4, 5, 3, 3),
('Golem Pierre', '/static/img/t5.png', 7, 3, 2, 3),
('Ninja Ombre', '/static/img/t6.png', 4, 4, 2, 5),
('Prêtresse Lumière', '/static/img/t7.png', 4, 2, 5, 4),
('Barbare Rage', '/static/img/t8.png', 6, 5, 1, 3),
('Sorcière Noire', '/static/img/t9.png', 3, 3, 5, 4),
('Paladin Saint', '/static/img/t10.png', 5, 3, 4, 3),
('Assassin Lame', '/static/img/t11.png', 3, 6, 2, 4),
('Druide Nature', '/static/img/t12.png', 4, 3, 4, 4),
('Vampire Sang', '/static/img/t13.png', 5, 4, 2, 4),
('Phoenix Cendres', '/static/img/t14.png', 4, 3, 5, 3),
('Guerrier Titan', '/static/img/t15.png', 6, 4, 2, 3),
('Nécromancien', '/static/img/t16.png', 3, 2, 7, 3);

-- Insertion des Équipes
INSERT INTO EQUIPE (nom, couleur, date_creation) VALUES
('Les Dragons Rouges', 'red', '2024-01-15'),
('Les Aigles Bleus', 'blue', '2024-01-20'),
('Les Tigres Verts', 'green', '2024-02-01'),
('Les Lions Dorés', 'Or', '2024-02-10'),
('Les Loups Noirs', 'dark', '2024-02-15');

-- Composition des équipes (chaque équipe a 4 morpions)
INSERT INTO COMPOSER (id_equipe, id_morpion) VALUES
(1, 1), (1, 2), (1, 3), (1, 4),
(2, 5), (2, 6), (2, 7), (2, 8),
(3, 9), (3, 10), (3, 11), (3, 12),
(4, 13), (4, 14), (4, 15), (4, 16),
(5, 1), (5, 5), (5, 9), (5, 13);

-- Configurations de jeu
INSERT INTO CONFIGURATION (date_config, taille_grille, max_tours) VALUES
('2024-03-01', 3, 20),
('2024-03-05', 4, 30),
('2024-03-10', 3, 15),
('2024-03-15', 4, 25);

-- Parties
INSERT INTO PARTIE (date_debut, date_fin, gagnante, id_config) VALUES
('2024-03-20 14:30:00', '2024-03-20 15:15:00', 1, 1),
('2024-03-21 16:00:00', '2024-03-21 16:45:00', 2, 2),
('2024-03-22 10:00:00', '2024-03-22 10:35:00', 1, 3),
('2024-03-23 18:00:00', NULL, NULL, 4),
('2024-03-24 14:00:00', '2024-03-24 14:50:00', 3, 1);

-- Participation aux parties
INSERT INTO PARTICIPATION (id_partie, id_equipe) VALUES
(1, 1), (1, 2),
(2, 2), (2, 3),
(3, 1), (3, 4),
(4, 3), (4, 5),
(5, 1), (5, 3);

-- Journal des parties
INSERT INTO JOURNAL (id_partie, id_ligne, date_action, texte) VALUES
(1, 1, '2024-03-20 14:30:00', 'Début de la partie entre Les Dragons Rouges et Les Aigles Bleus'),
(1, 2, '2024-03-20 14:32:15', 'Les Dragons Rouges placent Dragon Feu en position (1,1)'),
(1, 3, '2024-03-20 14:35:20', 'Les Aigles Bleus placent Golem Pierre en position (2,2)'),
(1, 4, '2024-03-20 14:38:45', 'Dragon Feu attaque Golem Pierre - Dégâts: 4 PV'),
(1, 5, '2024-03-20 15:15:00', 'Victoire des Dragons Rouges!'),
(2, 1, '2024-03-21 16:00:00', 'Début de la partie entre Les Aigles Bleus et Les Tigres Verts'),
(2, 2, '2024-03-21 16:05:30', 'Les Aigles Bleus placent Ninja Ombre en position (0,0)'),
(2, 3, '2024-03-21 16:10:15', 'Les Tigres Verts placent Sorcière Noire en position (1,1)'),
(2, 4, '2024-03-21 16:45:00', 'Victoire des Aigles Bleus!'),
(3, 1, '2024-03-22 10:00:00', 'Début de la partie entre Les Dragons Rouges et Les Lions Dorés'),
(3, 2, '2024-03-22 10:05:00', 'Les Dragons Rouges placent Chevalier Noir en position (2,1)'),
(3, 3, '2024-03-22 10:35:00', 'Victoire des Dragons Rouges par abandon!'),
(4, 1, '2024-03-23 18:00:00', 'Début de la partie entre Les Tigres Verts et Les Loups Noirs'),
(4, 2, '2024-03-23 18:03:00', 'Les Tigres Verts placent Druide Nature en position (0,2)'),
(5, 1, '2024-03-24 14:00:00', 'Début de la partie entre Les Dragons Rouges et Les Tigres Verts'),
(5, 2, '2024-03-24 14:10:00', 'Les Tigres Verts placent Paladin Saint en position (1,1)'),
(5, 3, '2024-03-24 14:50:00', 'Victoire des Tigres Verts!');

# Morpion RPG

Un jeu de Morpion (Tic-Tac-Toe) revisité avec des mécaniques RPG, développé dans le cadre de l'UE INF2028L. Chaque case de la grille est occupée par un **personnage** doté de statistiques (PV, Attaque, Mana, Réussite), et deux équipes s'affrontent en mode normal ou avancé.

---

## Table des matières

- [Fonctionnalités](#-fonctionnalités)
- [Architecture du projet](#-architecture-du-projet)
- [Modèle de données](#-modèle-de-données)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Configuration de la base de données](#-configuration-de-la-base-de-données)
- [Lancement](#-lancement)
- [Pages et routes](#-pages-et-routes)

---

## Fonctionnalités

- **Gestion des équipes** — Créez vos équipes et choisissez les morpions (personnages) qui les composent parmi 16 disponibles.
- **Mode Normal** — Morpion classique sur grille 3×3 ou 4×4, deux équipes s'affrontent tour par tour.
- **Mode Avancé** — Chaque pion posé peut attaquer les pions adverses adjacents. Les combats sont résolus selon les statistiques (PV, Attaque, Mana, Réussite) avec une part de hasard.
- **Statistiques** — Consultez l'historique des parties, les équipes et leurs résultats.
- **Journalisation** — Chaque action de jeu est enregistrée en base de données.

---

## 🗂 Architecture du projet

Le projet suit l'architecture **MVC** imposée par le serveur `bdw-server` :

```
Morpion/
├── controleurs/          # Logique métier (Python)
│   ├── accueil.py
│   ├── equipe.py         # Création d'équipes et composition
│   ├── partie_normale.py # Mode de jeu classique
│   ├── partie_avancee.py # Mode de jeu avec combats RPG
│   └── stats.py          # Affichage des statistiques
├── model/                # Accès à la base de données
│   ├── model_pg.py       # Connexion PostgreSQL
│   ├── model_equipe.py   # Requêtes sur les équipes
│   ├── model_morpion.py  # Requêtes sur les morpions
│   ├── model_morpion.py  # Requêtes mode 2 (combats)
│   ├── model_partie_normale.py
│   └── model_stats.py
├── templates/            # Vues HTML (Jinja2)
│   ├── base.html
│   ├── accueil.html
│   ├── equipe.html
│   ├── partie_normale.html
│   ├── partie_avancee.html
│   └── stats.html
├── static/
│   ├── css/style.css
│   ├── js/style.js
│   └── img/             # Images des 16 morpions
├── routes.toml           # Définition des routes
└── init.py               # Initialisation de l'application
```

---

## Modèle de données

Le schéma PostgreSQL (`tictac2`) contient les tables suivantes :

| Table | Description |
|---|---|
| `MORPION` | Les 16 personnages jouables, avec leurs statistiques (PV, Attaque, Mana, Réussite — somme = 15) |
| `EQUIPE` | Les équipes créées par les joueurs (nom, couleur, date de création) |
| `COMPOSER` | Association many-to-many entre équipes et morpions |
| `CONFIGURATION` | Paramètres d'une partie (taille de grille, nombre de tours max) |
| `PARTIE` | Une partie avec ses dates, sa configuration et l'équipe gagnante |
| `PARTICIPATION` | Quelles équipes participent à quelle partie |
| `JOURNAL` | Log de chaque action effectuée pendant une partie |

**Schéma relationnel :**
```
MORPION(id_morpion, nom, image, pv, attaque, mana, reussite)
EQUIPE(id_equipe, nom, couleur, date_creation)
COMPOSER(id_equipe_morpion, #id_equipe, #id_morpion)
CONFIGURATION(id_config, date_config, taille_grille, max_tours)
PARTIE(id_partie, date_debut, date_fin, gagnante, #id_config)
PARTICIPATION(#id_partie, #id_equipe)
JOURNAL(#id_partie, id_ligne, new_ligne, new_colonne, #id_morpion, #id_equipe, date_action, texte)
```

Pour initialiser la base avec les données de départ (16 morpions, 5 équipes, parties exemples) :
```sh
psql -U <votre_utilisateur> -d <votre_base> -f Script.sql
```

---

## Prérequis

- **Python** ≥ 3.11.2
- **PostgreSQL** accessible (serveur local ou distant)
- Le serveur `bdw-server` (fourni dans le répertoire parent)

---

## Installation

**1. Créer et activer l'environnement virtuel** (depuis le répertoire `bdw-server`) :

```sh
python3 -m venv .venv

# Linux / macOS
source .venv/bin/activate

# Windows
.venv\Scripts\activate
# ou, si nécessaire :
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.venv\Scripts\activate
```

**2. Installer les dépendances :**

```sh
pip install --upgrade pip
pip install -r requirements.in
```

Les dépendances sont : `psycopg[binary]`, `logzero`, `Jinja2`.

---

## Configuration de la base de données

Copiez et adaptez le fichier `config-bd.toml` à la racine de `bdw-server` :

```toml
POSTGRESQL_SERVER   = "votre_serveur"
POSTGRESQL_USER     = "votre_utilisateur"
POSTGRESQL_PASSWORD = "votre_mot_de_passe"
POSTGRESQL_DATABASE = "votre_base"
POSTGRESQL_SCHEMA   = "tictac2"
```

---

## Lancement

Depuis le répertoire `bdw-server`, avec l'environnement virtuel activé :

```sh
python server.py websites/Morpion
```

L'application est alors accessible à l'adresse : [http://localhost:4242](http://localhost:4242)

**Options disponibles :**

| Option | Description | Défaut |
|---|---|---|
| `-p`, `--port` | Numéro de port | `4242` |
| `-c`, `--config` | Chemin vers le fichier de config BD | `config-bd.toml` |
| `-s`, `--schema` | Nom du schéma PostgreSQL | défini dans config |

---

## Pages et routes

| URL | Description |
|---|---|
| `/` | Page d'accueil |
| `/equipes` | Créer une équipe et choisir ses morpions |
| `/partie_normale` | Lancer une partie en mode classique |
| `/partie_avancee` | Lancer une partie en mode RPG avec combats |
| `/stats` | Voir les statistiques et l'historique des parties |

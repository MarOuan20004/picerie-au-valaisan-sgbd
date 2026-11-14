-- =============================================
-- SUPPRESSION DES TABLES (si elles existent)
-- =============================================
DROP TABLE Donne_Lieu_A CASCADE CONSTRAINTS;
DROP TABLE Subit CASCADE CONSTRAINTS;
DROP TABLE Est_Livrée_A CASCADE CONSTRAINTS;
DROP TABLE Ligne_Commande CASCADE CONSTRAINTS;
DROP TABLE Est_Disponible CASCADE CONSTRAINTS;
DROP TABLE Exerce CASCADE CONSTRAINTS;
DROP TABLE Lot_Contenant CASCADE CONSTRAINTS;
DROP TABLE Lot_Produit CASCADE CONSTRAINTS;
DROP TABLE Art_Pdt CASCADE CONSTRAINTS;
DROP TABLE Contenant CASCADE CONSTRAINTS;
DROP TABLE Client_Non_Oublie CASCADE CONSTRAINTS;
DROP TABLE Adresse_Livraison CASCADE CONSTRAINTS;
DROP TABLE Commande CASCADE CONSTRAINTS;
DROP TABLE Client CASCADE CONSTRAINTS;
DROP TABLE Perte CASCADE CONSTRAINTS;
DROP TABLE Article CASCADE CONSTRAINTS;
DROP TABLE Saisonalite CASCADE CONSTRAINTS;
DROP TABLE Produit CASCADE CONSTRAINTS;
DROP TABLE Activité CASCADE CONSTRAINTS;
DROP TABLE Producteur CASCADE CONSTRAINTS;

-- =============================================
-- CRÉATION DES TABLES
-- =============================================

-- Table Producteur
CREATE TABLE Producteur (
    email_producteur VARCHAR(100) PRIMARY KEY,
    nom VARCHAR2(50),
    numTel VARCHAR2(20),
    address VARCHAR2(150),
    GeoLoc VARCHAR2(50)
);

-- Table Activité
CREATE TABLE Activité (
    TypeActivité INT PRIMARY KEY,
    Description VARCHAR2(100)
);

-- Table Exerce
CREATE TABLE Exerce (
    email_producteur VARCHAR2(100) NOT NULL,
    type_activite INT NOT NULL,
    CONSTRAINT PK_Exerce PRIMARY KEY (email_producteur, type_activite),
    CONSTRAINT FK_Exerce_Producteur FOREIGN KEY (email_producteur) REFERENCES Producteur(email_producteur) ON DELETE CASCADE,
    CONSTRAINT FK_Exerce_Activite FOREIGN KEY (type_activite) REFERENCES Activité(TypeActivité) ON DELETE CASCADE
);

-- Table Produit
CREATE TABLE Produit (
    IdProduit INT PRIMARY KEY,
    nom_Produit VARCHAR2(100),
    categorie VARCHAR2(50),
    description VARCHAR2(4000),
    CaracteristiquesSpe VARCHAR2(4000),
    email_Producteur VARCHAR2(100) NOT NULL,
    CONSTRAINT FK_Producteur_Produit FOREIGN KEY (email_Producteur) REFERENCES Producteur(email_producteur)
);

-- Table Saisonalite
CREATE TABLE Saisonalite (
    date_debut DATE,
    date_fin DATE,
    CONSTRAINT chk_date_saisonnalite CHECK (date_debut < date_fin),
    CONSTRAINT pk_Saisonalite PRIMARY KEY (date_debut, date_fin)
);

-- Table Est_Disponible
CREATE TABLE Est_Disponible (
    IdProduit INT NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    CONSTRAINT PK_Est_Disponible PRIMARY KEY (IdProduit, date_debut, date_fin),
    CONSTRAINT FK_ED_Produit FOREIGN KEY (IdProduit) REFERENCES Produit(IdProduit) ON DELETE CASCADE,
    CONSTRAINT FK_ED_Saisonalite FOREIGN KEY (date_debut, date_fin) REFERENCES Saisonalite(date_debut, date_fin) ON DELETE CASCADE
);

-- Table Article
CREATE TABLE Article (
    IdArticle INT PRIMARY KEY,
    prixAchat NUMBER CHECK (prixAchat > 0),
    prixTTC NUMBER CHECK (prixTTC > 0)
);

-- Table Art_Pdt
CREATE TABLE Art_Pdt(
    IdArticle INT PRIMARY KEY,
    IdProduit INT NOT NULL,
    Mode_Conditionnement VARCHAR2(20),
    Quantite_Unitaire NUMBER CHECK (Quantite_Unitaire > 0),
    Unite VARCHAR2(20),
    Delai_Dispo NUMBER CHECK (Delai_Dispo > 0),
    Type_Dispo VARCHAR2(30),
    CONSTRAINT FK_Art_Pdt_Article FOREIGN KEY (IdArticle) REFERENCES Article(IdArticle) ON DELETE CASCADE,
    CONSTRAINT FK_Art_Pdt_Produit FOREIGN KEY (IdProduit) REFERENCES Produit(IdProduit) ON DELETE CASCADE,
    CONSTRAINT chk_Type_Dispo CHECK (Type_Dispo IN ('Sur Commande','En Stock','Sur Commande et En Stock')),
    CONSTRAINT chk_Mode_Conditionnement CHECK (Mode_Conditionnement IN ('Vrac','Pré-Conditionné'))
);

-- Table Contenant
CREATE TABLE Contenant(
    IdArticle INT PRIMARY KEY,
    Type VARCHAR2(20),
    Capacite NUMBER CHECK (Capacite > 0),
    Unite VARCHAR2(20),
    Caractere VARCHAR2(20),
    CONSTRAINT FK_Contenant_Article FOREIGN KEY (IdArticle) REFERENCES Article(IdArticle) ON DELETE CASCADE,
    CONSTRAINT chk_Unite CHECK (Unite IN ('L','g')),
    CONSTRAINT chk_Caractere CHECK (Caractere IN ('Réutilisable','Jetable'))
);

-- Table Lot_Produit
CREATE TABLE Lot_Produit(
    IdArticle INT NOT NULL,
    date_reception DATE NOT NULL,
    date_peremption VARCHAR2(20),
    type_date VARCHAR2(20),
    Qte_dispo NUMBER CHECK (Qte_dispo > 0),
    CONSTRAINT FK_Lot_Produit_Article FOREIGN KEY (IdArticle) REFERENCES Article(IdArticle) ON DELETE CASCADE,
    CONSTRAINT PK_Lot_Produit PRIMARY KEY(IdArticle, date_reception),
    CONSTRAINT chk_type_date CHECK (type_date IN ('DLC','DLUO'))
);

-- Table Lot_Contenant
CREATE TABLE Lot_Contenant(
    IdArticle INT NOT NULL,
    date_reception DATE NOT NULL,
    Qte_dispo NUMBER CHECK (Qte_dispo > 0),
    CONSTRAINT FK_Lot_Contenant_Article FOREIGN KEY (IdArticle) REFERENCES Article(IdArticle) ON DELETE CASCADE,
    CONSTRAINT PK_Lot_Contenant PRIMARY KEY(IdArticle, date_reception)
);

-- Table Perte
CREATE TABLE Perte (
    IdPerte INT PRIMARY KEY,
    datePerte DATE,
    naturePerte VARCHAR2(50),
    typePerte VARCHAR2(20),
    qtePerdue INT CHECK (qtePerdue > 0),
    unite VARCHAR2(20),
    CONSTRAINT chk_type_Perte CHECK (typePerte IN ('Contenant','Article'))
);

-- Table Client
CREATE TABLE Client (
    IdClient INT PRIMARY KEY
);

-- Table Client_Non_Oublie
CREATE TABLE Client_Non_Oublie(
    IdClient INT PRIMARY KEY,
    NomC VARCHAR2(30),
    PrenomC VARCHAR2(30),
    NumTelC VARCHAR2(15),
    EmailC VARCHAR2(50) NOT NULL,
    CONSTRAINT FK_Client_Non_Oublie_Client FOREIGN KEY (IdClient) REFERENCES Client(IdClient) ON DELETE CASCADE,
    CONSTRAINT UQ_Client_Non_Oublie_Email UNIQUE (EmailC)
);

-- Table Adresse_Livraison
CREATE TABLE Adresse_Livraison(
    AdresseLiv VARCHAR2(100) PRIMARY KEY,
    IdClient INT NOT NULL,
    CONSTRAINT FK_AdrLiv_Client FOREIGN KEY (IdClient) REFERENCES Client(IdClient) ON DELETE CASCADE
);

-- Table Commande
CREATE TABLE Commande(
    IdCommande INT PRIMARY KEY,
    date_Com DATE,
    Heure_Com VARCHAR2(8),
    Prix_Total NUMBER CHECK (Prix_Total > 0),
    Statut VARCHAR2(30),
    Mode_Paiement VARCHAR2(30),
    Mode_Recuperation VARCHAR2(30),
    IdClient INT NOT NULL,
    CONSTRAINT chk_Statut CHECK (Statut IN ('En Préparation', 'Prête','En Livraison','Récupérée | Livrée','Annulée')),
    CONSTRAINT chk_Mode_Paiement CHECK (Mode_Paiement IN ('Paiement en Ligne','Paiement en Boutique')),
    CONSTRAINT chk_Mode_Recuperation CHECK (Mode_Recuperation IN ('Retrait en Boutique','Livraison à Domicile')),
    CONSTRAINT FK_Client_Commande FOREIGN KEY (IdClient) REFERENCES Client(IdClient)
);

-- Table Ligne_Commande
CREATE TABLE Ligne_Commande(
    IdCommande INT NOT NULL,
    IdLC INT NOT NULL,
    IdArticle INT NOT NULL,
    QteCom NUMBER CHECK (QteCom > 0),
    PU NUMBER CHECK (PU >= 0),
    Sous_Total NUMBER CHECK (Sous_Total >= 0),
    CONSTRAINT PK_Ligne_Commande PRIMARY KEY (IdCommande, IdLC),
    CONSTRAINT FK_LC_Commande FOREIGN KEY (IdCommande) REFERENCES Commande(IdCommande) ON DELETE CASCADE,
    CONSTRAINT FK_LC_Article FOREIGN KEY (IdArticle) REFERENCES Article(IdArticle)
);

-- Table Subit
CREATE TABLE Subit(
    IdPertes INT PRIMARY KEY,
    IdArticle INT NOT NULL,
    date_reception DATE NOT NULL,
    CONSTRAINT FK_Subit_Perte FOREIGN KEY (IdPertes) REFERENCES Perte(IdPerte) ON DELETE CASCADE,
    CONSTRAINT FK_Subit_LotProduit FOREIGN KEY (IdArticle, date_reception) REFERENCES Lot_Produit (IdArticle, date_reception) ON DELETE CASCADE
);

-- Table Donne_Lieu_A
CREATE TABLE Donne_Lieu_A(
    IdPertes INT PRIMARY KEY,
    IdArticle INT NOT NULL,
    date_reception DATE NOT NULL,
    CONSTRAINT FK_Donne_Lieu_A_Perte FOREIGN KEY (IdPertes) REFERENCES Perte(IdPerte) ON DELETE CASCADE,
    CONSTRAINT FK_Donne_Lieu_A_Lot_Contenant FOREIGN KEY (IdArticle, date_reception) REFERENCES Lot_Contenant (IdArticle, date_reception) ON DELETE CASCADE
);

-- Table Est_Livrée_A
CREATE TABLE Est_Livrée_A(
    IdCommande INT PRIMARY KEY,
    AdresseLiv VARCHAR2(100) NOT NULL,
    CONSTRAINT FK_ELA_Commande FOREIGN KEY (IdCommande) REFERENCES Commande(IdCommande) ON DELETE CASCADE,
    CONSTRAINT FK_ELA_AdresseLiv FOREIGN KEY (AdresseLiv) REFERENCES Adresse_Livraison(AdresseLiv)
);

-- =============================================
-- INSERTION DES DONNÉES
-- =============================================

-- Producteur
INSERT INTO Producteur VALUES ('dupont@maraichers.fr', 'Maraîchers Dupont', '0123456789', '12 Chemin des Carottes, 80000 Amiens', '49.8941,2.2957');
INSERT INTO Producteur VALUES ('martin@vergersud.fr', 'Verger du Sud', '0234567891', '88 Route des Vergers, 84000 Avignon', '43.9493,4.8055');
INSERT INTO Producteur VALUES ('leroux@laitiers.fr', 'Laiterie Leroux', '0345678912', '25 Rue des Alpages, 74000 Annecy', '45.8992,6.1294');
INSERT INTO Producteur VALUES ('blanc@boulanger.fr', 'Atelier Blanc', '0456789123', '5 Rue de la Boulangerie, 44000 Nantes', '47.2184,-1.5536');
INSERT INTO Producteur VALUES ('moreau@epicerie.fr', 'Épicerie Moreau', '0567891234', '7 Allée des Abeilles, 37000 Tours', '47.3941,0.6848');
INSERT INTO Producteur VALUES ('perrin@bergerie.fr', 'Bergerie Perrin', '0678912345', '3 Route des Pâturages, 64000 Pau', '43.2951,-0.3708');
INSERT INTO Producteur VALUES ('durand@jusnature.fr', 'Presses Durand', '0789123456', '18 Chemin des Presses, 51100 Reims', '49.2583,4.0317');
INSERT INTO Producteur VALUES ('zen@kombucha.fr', 'Brassins Zen', '0891234567', '2 Impasse des Thés, 35000 Rennes', '48.1173,-1.6778');

-- Activité
INSERT INTO Activité VALUES (1, 'Maraîchage');
INSERT INTO Activité VALUES (2, 'Arboriculture');
INSERT INTO Activité VALUES (3, 'Élevage laitier');
INSERT INTO Activité VALUES (4, 'Boulangerie artisanale');
INSERT INTO Activité VALUES (5, 'Apiculture');
INSERT INTO Activité VALUES (6, 'Pastoralisme');
INSERT INTO Activité VALUES (7, 'Pressage de jus');
INSERT INTO Activité VALUES (8, 'Fermentation douce');

-- Exerce
INSERT INTO Exerce VALUES ('dupont@maraichers.fr', 1);
INSERT INTO Exerce VALUES ('martin@vergersud.fr', 2);
INSERT INTO Exerce VALUES ('leroux@laitiers.fr', 3);
INSERT INTO Exerce VALUES ('blanc@boulanger.fr', 4);
INSERT INTO Exerce VALUES ('moreau@epicerie.fr', 5);
INSERT INTO Exerce VALUES ('perrin@bergerie.fr', 6);
INSERT INTO Exerce VALUES ('durand@jusnature.fr', 7);
INSERT INTO Exerce VALUES ('zen@kombucha.fr', 8);

-- Produit
INSERT INTO Produit VALUES (1, 'Carottes Primeur', 'Légumes', 'Carottes croquantes récoltées chaque matin', 'Bottelettes lavées, calibre 16-20mm', 'dupont@maraichers.fr');
INSERT INTO Produit VALUES (2, 'Tomates Cœur de Bœuf', 'Légumes', 'Tomates anciennes très charnues', 'Variétés multicolores, maturité sur pied', 'dupont@maraichers.fr');
INSERT INTO Produit VALUES (3, 'Courgettes Soleil', 'Légumes', 'Courgettes jaunes et vertes', 'Cueillies à moins de 48h', 'dupont@maraichers.fr');
INSERT INTO Produit VALUES (4, 'Pommes Reine des Reinettes', 'Fruits', 'Pommes acidulées et croquantes', 'Tri manuel, calibre moyen', 'martin@vergersud.fr');
INSERT INTO Produit VALUES (5, 'Poires Conférence', 'Fruits', 'Poires fondantes de fin d''été', 'Teneur en sucre suivie chaque semaine', 'martin@vergersud.fr');
INSERT INTO Produit VALUES (6, 'Fraises Gariguette', 'Fruits', 'Fraises parfumées de plein champ', 'Conditionnées en barquettes bois', 'martin@vergersud.fr');
INSERT INTO Produit VALUES (7, 'Lait Cru des Alpages', 'Produits Laitiers', 'Lait entier cru embouteillé', 'Bouteilles consignées, filtrage doux', 'leroux@laitiers.fr');
INSERT INTO Produit VALUES (8, 'Yaourt Brassé Vanille', 'Produits Laitiers', 'Yaourt entier vanille bourbon', 'Fermentation lente 8h', 'leroux@laitiers.fr');
INSERT INTO Produit VALUES (9, 'Fromage de Brebis Crémeux', 'Produits Laitiers', 'Pâte molle de brebis', 'Affinage 4 semaines en cave', 'perrin@bergerie.fr');
INSERT INTO Produit VALUES (10, 'Pain de Campagne au Levain', 'Boulangerie', 'Pain cuit sur pierre', 'Hydratation 75%, levain naturel', 'blanc@boulanger.fr');
INSERT INTO Produit VALUES (11, 'Brioche Tressée Beurre', 'Boulangerie', 'Brioche généreuse', 'Beurre AOP, fermentation lente', 'blanc@boulanger.fr');
INSERT INTO Produit VALUES (12, 'Jus de Pomme Trouble', 'Boissons', 'Pur jus pressé à froid', 'Sans filtration, bouteille verre', 'durand@jusnature.fr');
INSERT INTO Produit VALUES (13, 'Kombucha Gingembre Doux', 'Boissons', 'Thé fermenté pétillant', 'Infusion bio, seconde fermentation', 'zen@kombucha.fr');
INSERT INTO Produit VALUES (14, 'Miel d''Acacia Pur', 'Épicerie', 'Miel liquide clair', 'Butinage forêts tourangelles', 'moreau@epicerie.fr');
INSERT INTO Produit VALUES (15, 'Confiture Framboise Maison', 'Épicerie', 'Confiture riche en fruits', 'Cuisson cuivre, 65% fruits', 'moreau@epicerie.fr');

-- Saisonalite
INSERT INTO Saisonalite VALUES (TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2026-06-30', 'YYYY-MM-DD'));
INSERT INTO Saisonalite VALUES (TO_DATE('2024-06-15', 'YYYY-MM-DD'), TO_DATE('2026-09-30', 'YYYY-MM-DD'));
INSERT INTO Saisonalite VALUES (TO_DATE('2024-09-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'));
INSERT INTO Saisonalite VALUES (TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'));

-- Est_Disponible
INSERT INTO Est_Disponible VALUES (1, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2026-06-30', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (2, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2026-06-30', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (3, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2026-06-30', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (4, TO_DATE('2024-06-15', 'YYYY-MM-DD'), TO_DATE('2026-09-30', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (4, TO_DATE('2024-09-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (5, TO_DATE('2024-06-15', 'YYYY-MM-DD'), TO_DATE('2026-09-30', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (6, TO_DATE('2024-06-15', 'YYYY-MM-DD'), TO_DATE('2026-09-30', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (7, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (8, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (9, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (10, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (11, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (12, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (13, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (14, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'));
INSERT INTO Est_Disponible VALUES (15, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'));

-- Article
INSERT INTO Article VALUES (1, 1.20, 2.30);
INSERT INTO Article VALUES (2, 2.20, 4.20);
INSERT INTO Article VALUES (3, 1.80, 3.60);
INSERT INTO Article VALUES (4, 2.10, 3.80);
INSERT INTO Article VALUES (5, 2.30, 4.10);
INSERT INTO Article VALUES (6, 3.00, 6.20);
INSERT INTO Article VALUES (7, 0.80, 1.60);
INSERT INTO Article VALUES (8, 1.00, 2.20);
INSERT INTO Article VALUES (9, 4.50, 8.50);
INSERT INTO Article VALUES (10, 1.20, 2.80);
INSERT INTO Article VALUES (11, 1.80, 4.20);
INSERT INTO Article VALUES (12, 2.30, 4.70);
INSERT INTO Article VALUES (13, 3.00, 6.00);
INSERT INTO Article VALUES (14, 5.00, 9.50);
INSERT INTO Article VALUES (15, 3.20, 6.40);
INSERT INTO Article VALUES (16, 0.70, 1.20);
INSERT INTO Article VALUES (17, 0.40, 0.90);
INSERT INTO Article VALUES (18, 0.10, 0.30);
INSERT INTO Article VALUES (19, 1.50, 3.00);

-- Art_Pdt
INSERT INTO Art_Pdt VALUES (1, 1, 'Vrac', 1, 'kg', 1, 'En Stock');
INSERT INTO Art_Pdt VALUES (2, 2, 'Pré-Conditionné', 0.8, 'kg', 2, 'Sur Commande et En Stock');
INSERT INTO Art_Pdt VALUES (3, 3, 'Vrac', 1, 'kg', 1, 'En Stock');
INSERT INTO Art_Pdt VALUES (4, 4, 'Pré-Conditionné', 1, 'kg', 2, 'En Stock');
INSERT INTO Art_Pdt VALUES (5, 5, 'Pré-Conditionné', 1, 'kg', 2, 'Sur Commande');
INSERT INTO Art_Pdt VALUES (6, 6, 'Pré-Conditionné', 0.25, 'kg', 1, 'En Stock');
INSERT INTO Art_Pdt VALUES (7, 7, 'Pré-Conditionné', 1, 'L', 1, 'En Stock');
INSERT INTO Art_Pdt VALUES (8, 8, 'Pré-Conditionné', 0.125, 'kg', 1, 'Sur Commande et En Stock');
INSERT INTO Art_Pdt VALUES (9, 9, 'Pré-Conditionné', 0.4, 'kg', 3, 'En Stock');
INSERT INTO Art_Pdt VALUES (10, 10, 'Pré-Conditionné', 1, 'unité', 1, 'En Stock');
INSERT INTO Art_Pdt VALUES (11, 11, 'Pré-Conditionné', 1, 'unité', 2, 'Sur Commande et En Stock');
INSERT INTO Art_Pdt VALUES (12, 12, 'Pré-Conditionné', 1, 'L', 2, 'En Stock');
INSERT INTO Art_Pdt VALUES (13, 13, 'Pré-Conditionné', 0.75, 'L', 4, 'Sur Commande et En Stock');
INSERT INTO Art_Pdt VALUES (14, 14, 'Pré-Conditionné', 0.25, 'kg', 5, 'En Stock');
INSERT INTO Art_Pdt VALUES (15, 15, 'Pré-Conditionné', 0.35, 'kg', 5, 'En Stock');

-- Contenant
INSERT INTO Contenant VALUES (16, 'Bouteille Standard', 1, 'L', 'Réutilisable');
INSERT INTO Contenant VALUES (17, 'Bocal Verre 500g', 500, 'g', 'Réutilisable');
INSERT INTO Contenant VALUES (18, 'Sac Kraft 2kg', 2000, 'g', 'Jetable');
INSERT INTO Contenant VALUES (19, 'Caisse Bois 5kg', 5000, 'g', 'Réutilisable');

-- Lot_Produit
INSERT INTO Lot_Produit VALUES (1, TO_DATE('2024-03-05', 'YYYY-MM-DD'), '2026-03-15', 'DLC', 40);
INSERT INTO Lot_Produit VALUES (1, TO_DATE('2024-03-12', 'YYYY-MM-DD'), '2026-03-22', 'DLC', 30);
INSERT INTO Lot_Produit VALUES (2, TO_DATE('2024-03-04', 'YYYY-MM-DD'), '2025-12-03', 'DLC', 35);
INSERT INTO Lot_Produit VALUES (2, TO_DATE('2024-03-10', 'YYYY-MM-DD'), '2025-12-03', 'DLC', 25);
INSERT INTO Lot_Produit VALUES (3, TO_DATE('2024-03-08', 'YYYY-MM-DD'), '2025-12-02', 'DLC', 28);
INSERT INTO Lot_Produit VALUES (3, TO_DATE('2024-03-15', 'YYYY-MM-DD'), '2026-12-02', 'DLC', 24);
INSERT INTO Lot_Produit VALUES (4, TO_DATE('2024-02-25', 'YYYY-MM-DD'), '2026-04-30', 'DLUO', 60);
INSERT INTO Lot_Produit VALUES (4, TO_DATE('2024-03-10', 'YYYY-MM-DD'), '2026-05-15', 'DLUO', 55);
INSERT INTO Lot_Produit VALUES (5, TO_DATE('2024-03-01', 'YYYY-MM-DD'), '2026-04-20', 'DLUO', 40);
INSERT INTO Lot_Produit VALUES (5, TO_DATE('2024-03-18', 'YYYY-MM-DD'), '2026-05-05', 'DLUO', 35);
INSERT INTO Lot_Produit VALUES (6, TO_DATE('2024-03-06', 'YYYY-MM-DD'), '2026-03-18', 'DLC', 32);
INSERT INTO Lot_Produit VALUES (6, TO_DATE('2024-03-13', 'YYYY-MM-DD'), '2026-03-25', 'DLC', 30);
INSERT INTO Lot_Produit VALUES (7, TO_DATE('2024-03-02', 'YYYY-MM-DD'), '2026-03-12', 'DLC', 80);
INSERT INTO Lot_Produit VALUES (7, TO_DATE('2024-03-09', 'YYYY-MM-DD'), '2026-03-19', 'DLC', 70);
INSERT INTO Lot_Produit VALUES (8, TO_DATE('2024-03-03', 'YYYY-MM-DD'), '2026-04-02', 'DLUO', 100);
INSERT INTO Lot_Produit VALUES (8, TO_DATE('2024-03-12', 'YYYY-MM-DD'), '2026-04-11', 'DLUO', 90);
INSERT INTO Lot_Produit VALUES (9, TO_DATE('2024-02-28', 'YYYY-MM-DD'), '2026-05-10', 'DLUO', 45);
INSERT INTO Lot_Produit VALUES (9, TO_DATE('2024-03-20', 'YYYY-MM-DD'), '2026-06-01', 'DLUO', 40);
INSERT INTO Lot_Produit VALUES (10, TO_DATE('2024-03-06', 'YYYY-MM-DD'), '2026-03-13', 'DLC', 60);
INSERT INTO Lot_Produit VALUES (10, TO_DATE('2024-03-14', 'YYYY-MM-DD'), '2026-03-21', 'DLC', 55);
INSERT INTO Lot_Produit VALUES (11, TO_DATE('2024-03-07', 'YYYY-MM-DD'), '2026-03-15', 'DLC', 50);
INSERT INTO Lot_Produit VALUES (11, TO_DATE('2024-03-16', 'YYYY-MM-DD'), '2026-03-24', 'DLC', 45);
INSERT INTO Lot_Produit VALUES (12, TO_DATE('2024-03-05', 'YYYY-MM-DD'), '2026-09-05', 'DLUO', 120);
INSERT INTO Lot_Produit VALUES (12, TO_DATE('2024-03-15', 'YYYY-MM-DD'), '2026-09-15', 'DLUO', 110);
INSERT INTO Lot_Produit VALUES (13, TO_DATE('2024-03-04', 'YYYY-MM-DD'), '2026-06-04', 'DLUO', 90);
INSERT INTO Lot_Produit VALUES (13, TO_DATE('2024-03-18', 'YYYY-MM-DD'), '2026-06-18', 'DLUO', 85);
INSERT INTO Lot_Produit VALUES (14, TO_DATE('2024-02-15', 'YYYY-MM-DD'), '2026-02-15', 'DLUO', 70);
INSERT INTO Lot_Produit VALUES (14, TO_DATE('2024-03-22', 'YYYY-MM-DD'), '2026-03-22', 'DLUO', 70);
INSERT INTO Lot_Produit VALUES (15, TO_DATE('2024-02-20', 'YYYY-MM-DD'), '2026-02-20', 'DLUO', 65);
INSERT INTO Lot_Produit VALUES (15, TO_DATE('2024-03-25', 'YYYY-MM-DD'), '2026-03-25', 'DLUO', 60);

-- Lot_Contenant
INSERT INTO Lot_Contenant VALUES (16, TO_DATE('2024-03-02', 'YYYY-MM-DD'), 120);
INSERT INTO Lot_Contenant VALUES (16, TO_DATE('2024-03-12', 'YYYY-MM-DD'), 150);
INSERT INTO Lot_Contenant VALUES (17, TO_DATE('2024-03-03', 'YYYY-MM-DD'), 200);
INSERT INTO Lot_Contenant VALUES (17, TO_DATE('2024-03-18', 'YYYY-MM-DD'), 180);
INSERT INTO Lot_Contenant VALUES (18, TO_DATE('2024-03-04', 'YYYY-MM-DD'), 250);
INSERT INTO Lot_Contenant VALUES (18, TO_DATE('2024-03-14', 'YYYY-MM-DD'), 230);
INSERT INTO Lot_Contenant VALUES (19, TO_DATE('2024-03-05', 'YYYY-MM-DD'), 90);
INSERT INTO Lot_Contenant VALUES (19, TO_DATE('2024-03-20', 'YYYY-MM-DD'), 85);

-- Perte
INSERT INTO Perte VALUES (1, TO_DATE('2024-03-18', 'YYYY-MM-DD'), 'Casse bottes carottes', 'Article', 6, 'kg');
INSERT INTO Perte VALUES (2, TO_DATE('2024-03-19', 'YYYY-MM-DD'), 'Bocaux fissurés', 'Contenant', 4, 'unité');
INSERT INTO Perte VALUES (3, TO_DATE('2024-03-22', 'YYYY-MM-DD'), 'Lait renversé', 'Article', 8, 'L');
INSERT INTO Perte VALUES (4, TO_DATE('2024-03-23', 'YYYY-MM-DD'), 'Caisse abîmée', 'Contenant', 2, 'unité');
INSERT INTO Perte VALUES (5, TO_DATE('2024-03-25', 'YYYY-MM-DD'), 'Pain invendu', 'Article', 3, 'unité');

-- Client
INSERT INTO Client VALUES (1);
INSERT INTO Client VALUES (2);
INSERT INTO Client VALUES (3);
INSERT INTO Client VALUES (4);
INSERT INTO Client VALUES (5);
INSERT INTO Client VALUES (6);

-- Client_Non_Oublie
INSERT INTO Client_Non_Oublie VALUES (1, 'Renaud', 'Camille', '0611223344', 'camille.renaud@email.com');
INSERT INTO Client_Non_Oublie VALUES (2, 'Moretti', 'Luc', '0622334455', 'luc.moretti@email.com');
INSERT INTO Client_Non_Oublie VALUES (3, 'Lambert', 'Julie', '0633445566', 'julie.lambert@email.com');
INSERT INTO Client_Non_Oublie VALUES (4, 'Henry', 'Thomas', '0644556677', 'thomas.henry@email.com');
INSERT INTO Client_Non_Oublie VALUES (5, 'Nguyen', 'Anh', '0655667788', 'anh.nguyen@email.com');
INSERT INTO Client_Non_Oublie VALUES (6, 'Petit', 'Claire', '0666778899', 'claire.petit@email.com');

-- Adresse_Livraison
INSERT INTO Adresse_Livraison VALUES ('18 Rue Victor Hugo, 59800 Lille', 1);
INSERT INTO Adresse_Livraison VALUES ('44 Avenue d''Alsace, 67000 Strasbourg', 2);
INSERT INTO Adresse_Livraison VALUES ('9 Quai des Arts, 44000 Nantes', 3);
INSERT INTO Adresse_Livraison VALUES ('72 Boulevard Voltaire, 75011 Paris', 4);
INSERT INTO Adresse_Livraison VALUES ('3 Impasse des Lilas, 38000 Grenoble', 5);
INSERT INTO Adresse_Livraison VALUES ('51 Rue Nationale, 59000 Lille', 6);

-- Commande
INSERT INTO Commande VALUES (1, TO_DATE('2024-03-20', 'YYYY-MM-DD'), '10:15', 16.90, 'Prête', 'Paiement en Ligne', 'Retrait en Boutique', 1);
INSERT INTO Commande VALUES (2, TO_DATE('2024-03-21', 'YYYY-MM-DD'), '14:45', 18.40, 'En Livraison', 'Paiement en Ligne', 'Livraison à Domicile', 2);
INSERT INTO Commande VALUES (3, TO_DATE('2024-03-22', 'YYYY-MM-DD'), '09:05', 21.00, 'Récupérée | Livrée', 'Paiement en Boutique', 'Retrait en Boutique', 3);
INSERT INTO Commande VALUES (4, TO_DATE('2024-03-23', 'YYYY-MM-DD'), '16:30', 31.60, 'En Préparation', 'Paiement en Ligne', 'Livraison à Domicile', 4);
INSERT INTO Commande VALUES (5, TO_DATE('2024-03-24', 'YYYY-MM-DD'), '11:10', 31.20, 'Prête', 'Paiement en Boutique', 'Retrait en Boutique', 5);
INSERT INTO Commande VALUES (6, TO_DATE('2024-03-25', 'YYYY-MM-DD'), '15:20', 17.00, 'En Livraison', 'Paiement en Ligne', 'Livraison à Domicile', 6);

-- Ligne_Commande
INSERT INTO Ligne_Commande VALUES (1, 1, 1, 2, 2.30, 4.60);
INSERT INTO Ligne_Commande VALUES (1, 2, 10, 1, 2.80, 2.80);
INSERT INTO Ligne_Commande VALUES (1, 3, 14, 1, 9.50, 9.50);
INSERT INTO Ligne_Commande VALUES (2, 1, 2, 1, 4.20, 4.20);
INSERT INTO Ligne_Commande VALUES (2, 2, 7, 3, 1.60, 4.80);
INSERT INTO Ligne_Commande VALUES (2, 3, 12, 2, 4.70, 9.40);
INSERT INTO Ligne_Commande VALUES (3, 1, 6, 1, 6.20, 6.20);
INSERT INTO Ligne_Commande VALUES (3, 2, 11, 2, 4.20, 8.40);
INSERT INTO Ligne_Commande VALUES (3, 3, 15, 1, 6.40, 6.40);
INSERT INTO Ligne_Commande VALUES (4, 1, 3, 1.5, 3.60, 5.40);
INSERT INTO Ligne_Commande VALUES (4, 2, 5, 2, 4.10, 8.20);
INSERT INTO Ligne_Commande VALUES (4, 3, 13, 3, 6.00, 18.00);
INSERT INTO Ligne_Commande VALUES (5, 1, 8, 6, 2.20, 13.20);
INSERT INTO Ligne_Commande VALUES (5, 2, 9, 1, 8.50, 8.50);
INSERT INTO Ligne_Commande VALUES (5, 3, 14, 1, 9.50, 9.50);
INSERT INTO Ligne_Commande VALUES (6, 1, 4, 3, 3.80, 11.40);
INSERT INTO Ligne_Commande VALUES (6, 2, 12, 1, 4.70, 4.70);
INSERT INTO Ligne_Commande VALUES (6, 3, 17, 1, 0.90, 0.90);

-- Subit
INSERT INTO Subit VALUES (1, 1, TO_DATE('2024-03-05', 'YYYY-MM-DD'));
INSERT INTO Subit VALUES (3, 7, TO_DATE('2024-03-02', 'YYYY-MM-DD'));
INSERT INTO Subit VALUES (5, 10, TO_DATE('2024-03-06', 'YYYY-MM-DD'));

-- Donne_Lieu_A
INSERT INTO Donne_Lieu_A VALUES (2, 17, TO_DATE('2024-03-03', 'YYYY-MM-DD'));
INSERT INTO Donne_Lieu_A VALUES (4, 19, TO_DATE('2024-03-05', 'YYYY-MM-DD'));

-- Est_Livrée_A
INSERT INTO Est_Livrée_A VALUES (2, '44 Avenue d''Alsace, 67000 Strasbourg');
INSERT INTO Est_Livrée_A VALUES (4, '72 Boulevard Voltaire, 75011 Paris');
INSERT INTO Est_Livrée_A VALUES (6, '51 Rue Nationale, 59000 Lille');

-- =============================================
-- VALIDATION
-- =============================================
COMMIT;

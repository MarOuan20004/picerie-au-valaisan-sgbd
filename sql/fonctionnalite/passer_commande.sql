BEGIN;

-- Prochain id de commande
SELECT NVL(MAX(IdCommande), 0) + 1 AS NEXT_ID FROM Commande;  -- ex : retourne 1003

-- Vérifier le stock pour les articles choisis (ex : article 501 et 777)
SELECT NVL(SUM(Qte_dispo), 0) AS STOCK_DISPO
FROM Lot_Produit
WHERE IdArticle = 501;  -- ex : 10

SELECT NVL(SUM(Qte_dispo), 0) AS STOCK_DISPO
FROM Lot_Produit
WHERE IdArticle = 777;  -- ex : 3

-- Afficher les infos d'article (ex : 501)
SELECT ar.idArticle, ar.prixttc, p.nom_produit, a.MODE_CONDITIONNEMENT
FROM Article ar
JOIN Art_Pdt a ON a.IDARTICLE = ar.IDARTICLE
JOIN Produit p ON p.IDPRODUIT = a.IDPRODUIT
WHERE ar.idArticle = 501;

-- Insérer la commande (En Préparation)
INSERT INTO Commande (IdCommande, date_Com, Heure_Com, Prix_Total, Statut, Mode_Paiement,
                      Mode_Recuperation, IdClient)
VALUES (1003, TRUNC(SYSDATE), TO_CHAR(SYSTIMESTAMP, 'HH24:MI'), 145.60, 'En Préparation',
        'Paiement en Ligne', 'Livraison à Domicile', 42);

-- Lignes de commande (PU calculés côté application, ici exemples)
INSERT INTO Ligne_Commande (IdCommande, IdLC, IdArticle, QteCom, PU, Sous_Total)
VALUES (1003, 1, 501, 2, 12.50, 25.00);

INSERT INTO Ligne_Commande (IdCommande, IdLC, IdArticle, QteCom, PU, Sous_Total)
VALUES (1003, 2, 777, 1.5, 40.40, 60.60);

-- Adresse de livraison
INSERT INTO Est_Livrée_A (IdCommande, AdresseLiv)
VALUES (1003, '15 Rue Emile Zola, 38400 St Martin d Heres');

COMMIT;

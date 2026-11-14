BEGIN;

-- Lister les commandes ouvertes
SELECT IdCommande, Statut, Prix_Total
FROM Commande
WHERE Statut IN ('En Préparation', 'Prête', 'En Livraison');

-- Exemple : IdCommande = 13, Statut = 'En Préparation'
-- Verrouiller les lots FIFO pour un article (ex : IdArticle = 6)
SELECT date_reception, Qte_dispo
FROM Lot_Produit
WHERE IdArticle = 6
ORDER BY date_reception
FOR UPDATE;

-- Décrémenter de manière conditionnelle (éviter la survente)
UPDATE Lot_Produit
SET Qte_dispo = Qte_dispo - 5
WHERE IdArticle = 6
  AND date_reception = TO_DATE('2025-11-01', 'YYYY-MM-DD')
  AND Qte_dispo >= 5;

-- Si l'update échoue (0 ligne), rollback/annuler si 'En Préparation'
-- Sinon, mise à jour du statut
UPDATE Commande
SET Statut = 'Prête'
WHERE IdCommande = 13;

COMMIT;
-- ROLLBACK si échec ; dans l'application, on annule automatiquement si en préparation et stock insuffisant.

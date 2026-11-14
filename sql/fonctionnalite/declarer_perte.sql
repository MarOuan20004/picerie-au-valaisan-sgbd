BEGIN;

-- Vérifier le stock de l’article (ex : IdArticle = 10)
SELECT SUM(lp.Qte_dispo) AS stock_total, MIN(a.Unite) AS Unite
FROM Lot_Produit lp
JOIN Art_Pdt a ON a.IdArticle = lp.IdArticle
WHERE lp.IdArticle = 10
GROUP BY lp.IdArticle;  -- ex : 12 kg

-- Insérer la perte (ex : 3 kg)
INSERT INTO Perte(IdPerte, datePerte, naturePerte, typePerte, qtePerdue, unite)
VALUES (2001, CURRENT_DATE, 'Casse', 'Article', 3, 'kg');

-- Déduire en FIFO des lots
SELECT date_reception, Qte_dispo
FROM Lot_Produit
WHERE IdArticle = 10
ORDER BY date_reception
FOR UPDATE;

UPDATE Lot_Produit
SET Qte_dispo = Qte_dispo - 3
WHERE IdArticle = 10
  AND date_reception = TO_DATE('2025-11-05', 'YYYY-MM-DD')
  AND Qte_dispo >= 3;

COMMIT;

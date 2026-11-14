BEGIN;

-- Lots périmant bientôt (fenêtre de 10 jours)
SELECT p.nom_produit,
       lp.Qte_dispo,
       a.Unite,
       ar.prixttc,
       TO_CHAR(CASE
                 WHEN REGEXP_LIKE(lp.date_peremption, '^[0-9]{2}-[A-Z]{3}-[0-9]{2}$')
                   THEN TO_DATE(lp.date_peremption, 'DD-MON-RR', 'NLS_DATE_LANGUAGE=AMERICAN')
                 WHEN REGEXP_LIKE(lp.date_peremption, '^[0-9]{4}-[0-9]{2}-[0-9]{2}$')
                   THEN TO_DATE(lp.date_peremption, 'YYYY-MM-DD')
                 ELSE NULL
               END, 'YYYY-MM-DD') AS peremption
FROM Lot_Produit lp
JOIN Art_Pdt a ON a.IdArticle = lp.IdArticle
JOIN Produit p ON p.IdProduit = a.IdProduit
JOIN Article ar ON ar.idArticle = a.idArticle
WHERE CASE
        WHEN REGEXP_LIKE(lp.date_peremption, '^[0-9]{2}-[A-Z]{3}-[0-9]{2}$')
          THEN TO_DATE(lp.date_peremption, 'DD-MON-RR', 'NLS_DATE_LANGUAGE=AMERICAN')
        WHEN REGEXP_LIKE(lp.date_peremption, '^[0-9]{4}-[0-9]{2}-[0-9]{2}$')
          THEN TO_DATE(lp.date_peremption, 'YYYY-MM-DD')
        ELSE NULL
      END BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) + 10
ORDER BY peremption;

-- Lots déjà périmés
SELECT p.nom_produit,
       lp.Qte_dispo,
       a.Unite,
       ar.prixttc,
       TO_CHAR(CASE
                 WHEN REGEXP_LIKE(lp.date_peremption, '^[0-9]{2}-[A-Z]{3}-[0-9]{2}$')
                   THEN TO_DATE(lp.date_peremption, 'DD-MON-RR', 'NLS_DATE_LANGUAGE=AMERICAN')
                 WHEN REGEXP_LIKE(lp.date_peremption, '^[0-9]{4}-[0-9]{2}-[0-9]{2}$')
                   THEN TO_DATE(lp.date_peremption, 'YYYY-MM-DD')
                 ELSE NULL
               END, 'YYYY-MM-DD') AS peremption
FROM Lot_Produit lp
JOIN Art_Pdt a ON a.IdArticle = lp.IdArticle
JOIN Produit p ON p.IdProduit = a.IdProduit
JOIN Article ar ON ar.idArticle = a.idArticle
WHERE CASE
        WHEN REGEXP_LIKE(lp.date_peremption, '^[0-9]{2}-[A-Z]{3}-[0-9]{2}$')
          THEN TO_DATE(lp.date_peremption, 'DD-MON-RR', 'NLS_DATE_LANGUAGE=AMERICAN')
        WHEN REGEXP_LIKE(lp.date_peremption, '^[0-9]{4}-[0-9]{2}-[0-9]{2}$')
          THEN TO_DATE(lp.date_peremption, 'YYYY-MM-DD')
        ELSE NULL
      END < TRUNC(SYSDATE)
ORDER BY peremption;

COMMIT;  -- lecture seule

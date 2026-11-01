-- Taux de défaut par tranche de score de crédit (jeu d'apprentissage uniquement)
SELECT
  CASE
    WHEN credit_score IS NULL THEN '0. manquant'
    WHEN credit_score < 620 THEN '1. < 620'
    WHEN credit_score < 660 THEN '2. 620-659'
    WHEN credit_score < 700 THEN '3. 660-699'
    WHEN credit_score < 740 THEN '4. 700-739'
    WHEN credit_score < 780 THEN '5. 740-779'
    ELSE '6. >= 780'
  END AS tranche_score,
  COUNT(*) AS nb_prets,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_population,
  COUNTIF(defaut_24m = 1) AS nb_defauts,
  ROUND(100 * AVG(defaut_24m), 2) AS taux_defaut,
  ROUND(AVG(defaut_24m) / (SUM(COUNTIF(defaut_24m = 1)) OVER () / SUM(COUNT(*)) OVER ()), 2)
    AS risque_relatif
FROM freddie_work.base_modele
WHERE jeu = 'apprentissage'
  AND defaut_24m IS NOT NULL
GROUP BY tranche_score
ORDER BY tranche_score
-- Taux de défaut, WoE et IV de la LTV par tranche (jeu d'apprentissage)
WITH classes AS (
  SELECT
    CASE
      WHEN ltv IS NULL THEN '0. manquant'
      WHEN ltv <= 60 THEN '1. <= 60'
      WHEN ltv <= 70 THEN '2. 61-70'
      WHEN ltv <= 75 THEN '3. 71-75'
      WHEN ltv <= 80 THEN '4. 76-80'
      WHEN ltv <= 85 THEN '5. 81-85'
      WHEN ltv <= 90 THEN '6. 86-90'
      WHEN ltv <= 95 THEN '7. 91-95'
      ELSE '8. > 95'
    END AS classe,
    defaut_24m
  FROM freddie_work.base_modele
  WHERE jeu = 'apprentissage'
    AND defaut_24m IS NOT NULL
),
comptes AS (
  SELECT
    classe,
    COUNT(*) AS nb_prets,
    COUNTIF(defaut_24m = 0) AS nb_bons,
    COUNTIF(defaut_24m = 1) AS nb_mauvais
  FROM classes
  GROUP BY classe
),
distributions AS (
  SELECT
    *,
    nb_bons / SUM(nb_bons) OVER () AS pct_bons,
    nb_mauvais / SUM(nb_mauvais) OVER () AS pct_mauvais
  FROM comptes
)
SELECT
  classe,
  nb_prets,
  ROUND(100 * nb_prets / SUM(nb_prets) OVER (), 1) AS pct_population,
  nb_mauvais,
  ROUND(100 * nb_mauvais / nb_prets, 2) AS taux_defaut,
  ROUND(SAFE.LN(pct_bons / pct_mauvais), 3) AS woe,
  ROUND((pct_bons - pct_mauvais) * SAFE.LN(pct_bons / pct_mauvais), 4) AS iv_classe,
  ROUND(SUM((pct_bons - pct_mauvais) * SAFE.LN(pct_bons / pct_mauvais)) OVER (), 3) AS iv_total
FROM distributions
ORDER BY classe
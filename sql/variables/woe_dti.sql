-- Taux de défaut, WoE et IV du DTI (taux d'endettement) par tranche (jeu d'apprentissage)
WITH classes AS (
  SELECT
    CASE
      WHEN dti IS NULL THEN '0. manquant'
      WHEN dti <= 20 THEN '1. <= 20'
      WHEN dti <= 30 THEN '2. 21-30'
      WHEN dti <= 36 THEN '3. 31-36'
      WHEN dti <= 43 THEN '4. 37-43'
      ELSE '5. > 43'
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
  ROUND(SAFE.LN(SAFE_DIVIDE(pct_bons, pct_mauvais)), 3) AS woe,
  ROUND((pct_bons - pct_mauvais) * SAFE.LN(SAFE_DIVIDE(pct_bons, pct_mauvais)), 4) AS iv_classe,
  ROUND(SUM((pct_bons - pct_mauvais) * SAFE.LN(SAFE_DIVIDE(pct_bons, pct_mauvais))) OVER (), 3) AS iv_total
FROM distributions
ORDER BY classe
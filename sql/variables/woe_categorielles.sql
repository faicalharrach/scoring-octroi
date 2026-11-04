-- WoE et IV des variables catégorielles, en une seule requête (jeu d'apprentissage)
WITH base AS (
  SELECT *
  FROM freddie_work.base_modele
  WHERE jeu = 'apprentissage'
    AND defaut_24m IS NOT NULL
),
longue AS (
  SELECT 'occupancy_status' AS variable, IFNULL(occupancy_status, 'manquant') AS classe, defaut_24m FROM base
  UNION ALL
  SELECT 'loan_purpose', IFNULL(loan_purpose, 'manquant'), defaut_24m FROM base
  UNION ALL
  SELECT 'channel', IFNULL(channel, 'manquant'), defaut_24m FROM base
  UNION ALL
  SELECT 'first_time_homebuyer', IFNULL(first_time_homebuyer, 'manquant'), defaut_24m FROM base
  UNION ALL
  SELECT 'number_of_borrowers', IFNULL(CAST(number_of_borrowers AS STRING), 'manquant'), defaut_24m FROM base
),
comptes AS (
  SELECT
    variable,
    classe,
    COUNT(*) AS nb_prets,
    COUNTIF(defaut_24m = 0) AS nb_bons,
    COUNTIF(defaut_24m = 1) AS nb_mauvais
  FROM longue
  GROUP BY variable, classe
),
distributions AS (
  SELECT
    *,
    nb_bons / SUM(nb_bons) OVER (PARTITION BY variable) AS pct_bons,
    nb_mauvais / SUM(nb_mauvais) OVER (PARTITION BY variable) AS pct_mauvais
  FROM comptes
)
SELECT
  variable,
  classe,
  nb_prets,
  ROUND(100 * nb_prets / SUM(nb_prets) OVER (PARTITION BY variable), 1) AS pct_population,
  nb_mauvais,
  ROUND(100 * nb_mauvais / nb_prets, 2) AS taux_defaut,
  ROUND(SAFE.LN(SAFE_DIVIDE(pct_bons, pct_mauvais)), 3) AS woe,
  ROUND(SUM((pct_bons - pct_mauvais) * SAFE.LN(SAFE_DIVIDE(pct_bons, pct_mauvais)))
        OVER (PARTITION BY variable), 3) AS iv_variable
FROM distributions
ORDER BY iv_variable DESC, variable, classe
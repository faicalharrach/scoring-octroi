-- WoE et IV du score de crédit, sur les 5 classes retenues (jeu d'apprentissage)
WITH classes AS (
  SELECT
    CASE
      WHEN credit_score IS NULL OR credit_score < 660 THEN '1. < 660 ou manquant'
      WHEN credit_score < 700 THEN '2. 660-699'
      WHEN credit_score < 740 THEN '3. 700-739'
      WHEN credit_score < 780 THEN '4. 740-779'
      ELSE '5. >= 780'
    END AS classe,
    defaut_24m
  FROM freddie_work.base_modele
  WHERE jeu = 'apprentissage'
    AND defaut_24m IS NOT NULL
),
comptes AS (
  SELECT
    classe,
    COUNTIF(defaut_24m = 0) AS nb_bons,
    COUNTIF(defaut_24m = 1) AS nb_mauvais
  FROM classes
  GROUP BY classe
),
distributions AS (
  SELECT
    classe,
    nb_bons,
    nb_mauvais,
    nb_bons / SUM(nb_bons) OVER () AS pct_bons,
    nb_mauvais / SUM(nb_mauvais) OVER () AS pct_mauvais
  FROM comptes
)
SELECT
  classe,
  nb_bons,
  nb_mauvais,
  ROUND(100 * pct_bons, 2) AS pct_bons,
  ROUND(100 * pct_mauvais, 2) AS pct_mauvais,
  ROUND(LN(SAFE_DIVIDE(pct_bons, pct_mauvais)), 3) AS woe,
  ROUND((pct_bons - pct_mauvais) * LN(SAFE_DIVIDE(pct_bons, pct_mauvais)), 4) AS iv_classe,
  ROUND(SUM((pct_bons - pct_mauvais) * LN(SAFE_DIVIDE(pct_bons, pct_mauvais))) OVER (), 3) AS iv_total
FROM distributions
ORDER BY classe
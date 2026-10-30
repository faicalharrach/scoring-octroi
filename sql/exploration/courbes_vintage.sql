-- Taux de défaut cumulé par année d'octroi, à 12, 24, 36 et 60 mois.
-- Défaut (provisoire) : 90 jours de retard ou plus, saisie (RA),
-- ou sortie avec perte (02 vente à un tiers, 03 vente à perte, 09 bien saisi revendu).
WITH evenements AS (
  SELECT
    loan_id,
    vintage,
    MIN(IF(SAFE_CAST(delinquency_status AS INT64) >= 3
           OR delinquency_status = 'RA'
           OR zero_balance_code IN ('02', '03', '09'),
           loan_age, NULL)) AS age_premier_defaut
  FROM freddie_raw.performance
  GROUP BY loan_id, vintage
)
SELECT
  vintage,
  COUNT(*) AS nb_prets,
  ROUND(100 * COUNTIF(age_premier_defaut <= 12) / COUNT(*), 2) AS defaut_12m,
  ROUND(100 * COUNTIF(age_premier_defaut <= 24) / COUNT(*), 2) AS defaut_24m,
  ROUND(100 * COUNTIF(age_premier_defaut <= 36) / COUNT(*), 2) AS defaut_36m,
  ROUND(100 * COUNTIF(age_premier_defaut <= 60) / COUNT(*), 2) AS defaut_60m,
  ROUND(100 * COUNTIF(age_premier_defaut IS NOT NULL) / COUNT(*), 2) AS defaut_total
FROM evenements
GROUP BY vintage
ORDER BY vintage
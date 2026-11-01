-- Table cible : une ligne par prêt, défaut à 24 mois.
-- Règles : docs/definition_defaut.md
CREATE SCHEMA IF NOT EXISTS freddie_work OPTIONS (location = 'EU');

CREATE OR REPLACE TABLE freddie_work.cible
CLUSTER BY vintage, loan_id
AS
WITH par_pret AS (
  SELECT
    loan_id,
    -- premier mois en défaut (NULL si jamais)
    MIN(IF(SAFE_CAST(delinquency_status AS INT64) >= 3
           OR delinquency_status = 'RA'
           OR zero_balance_code IN ('02', '03', '09'),
           loan_age, NULL)) AS age_premier_defaut,
    MAX(zero_balance_code) AS code_sortie,           -- un seul code par prêt
    MIN(IF(zero_balance_code IS NOT NULL, loan_age, NULL)) AS age_sortie,
    MAX(loan_age) AS age_max_observe
  FROM freddie_raw.performance
  GROUP BY loan_id
)
SELECT
  o.loan_id,
  o.vintage,
  p.age_premier_defaut,
  p.code_sortie,
  p.age_sortie,
  p.age_max_observe,
  CASE
    WHEN p.age_premier_defaut <= 24 THEN 1
    WHEN p.code_sortie = '96' AND p.age_sortie <= 24 THEN NULL
    WHEN p.age_max_observe >= 24 THEN 0
    WHEN p.code_sortie = '01' THEN 0
    ELSE NULL
  END AS defaut_24m,
  CASE
    WHEN p.age_premier_defaut <= 24 THEN 'defaut'
    WHEN p.code_sortie = '96' AND p.age_sortie <= 24 THEN 'exclu_rachat_vendeur'
    WHEN p.age_max_observe >= 24 THEN 'sain_observe_24m'
    WHEN p.code_sortie = '01' THEN 'sain_rembourse'
    WHEN p.code_sortie IS NULL THEN 'exclu_fenetre_incomplete'
    ELSE 'exclu_autre_sortie'
  END AS statut_cible,
  CASE
    WHEN o.vintage <= 2008 THEN 'analyse'
    WHEN o.vintage <= 2016 THEN 'apprentissage_test'
    WHEN o.vintage = 2017 THEN 'hors_periode'
    WHEN o.vintage <= 2021 THEN 'etude_covid'
    WHEN o.vintage <= 2023 THEN 'recent'
    ELSE 'production'
  END AS echantillon
FROM freddie_raw.origination AS o
LEFT JOIN par_pret AS p USING (loan_id)
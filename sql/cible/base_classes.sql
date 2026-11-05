-- Variables discrétisées selon docs/variables.md, appliquées à tous les prêts.
-- Une seule définition des classes, réutilisée par tous les échantillons.
CREATE OR REPLACE TABLE freddie_work.base_classes
CLUSTER BY jeu
AS
SELECT
  loan_id,
  vintage,
  jeu,
  defaut_24m,
  CASE
    WHEN credit_score IS NULL OR credit_score < 660 THEN '1. < 660 ou manquant'
    WHEN credit_score < 700 THEN '2. 660-699'
    WHEN credit_score < 740 THEN '3. 700-739'
    WHEN credit_score < 780 THEN '4. 740-779'
    ELSE '5. >= 780'
  END AS c_score,
  CASE
    WHEN dti IS NULL OR dti > 43 THEN '5. > 43 ou manquant'
    WHEN dti <= 20 THEN '1. <= 20'
    WHEN dti <= 30 THEN '2. 21-30'
    WHEN dti <= 36 THEN '3. 31-36'
    ELSE '4. 37-43'
  END AS c_dti,
  CASE
    WHEN ltv IS NULL OR ltv > 90 THEN '5. > 90 ou manquant'
    WHEN ltv <= 60 THEN '1. <= 60'
    WHEN ltv <= 75 THEN '2. 61-75'
    WHEN ltv <= 80 THEN '3. 76-80'
    ELSE '4. 81-90'
  END AS c_ltv,
  IF(number_of_borrowers >= 2, '2. deux ou plus', '1. un ou manquant') AS c_emprunteurs,
  IF(loan_purpose = 'N', '2. rachat simple', '1. achat ou rachat avec tresorerie') AS c_objet,
  IF(first_time_homebuyer = 'N', '2. non', '1. oui ou manquant') AS c_primo,
  IF(occupancy_status IN ('S', 'I'), '2. secondaire ou investissement', '1. residence principale') AS c_occupation
FROM freddie_work.base_modele
-- Base de modélisation : cible (une ligne par prêt) + caractéristiques à l'octroi.
-- Seules les informations connues le jour de l'octroi sont reprises :
-- rien qui vienne du fichier performance (sinon fuite d'information).
-- Les codes « non renseigné » du File Layout (9, 99, 999, 9999) deviennent NULL.
CREATE OR REPLACE TABLE freddie_work.base_modele
CLUSTER BY echantillon, vintage
AS
SELECT
  -- identification et cible
  c.loan_id,
  c.vintage,
  c.echantillon,
  c.statut_cible,
  c.defaut_24m,
  -- profil de l'emprunteur
  IF(o.credit_score BETWEEN 300 AND 850, o.credit_score, NULL) AS credit_score,
  NULLIF(o.dti, 999) AS dti,
  NULLIF(o.number_of_borrowers, 99) AS number_of_borrowers,
  NULLIF(o.first_time_homebuyer, '9') AS first_time_homebuyer,
  -- le prêt
  o.original_upb,
  o.original_interest_rate,
  o.original_loan_term,
  NULLIF(o.loan_purpose, '9') AS loan_purpose,
  NULLIF(o.channel, '9') AS channel,
  NULLIF(o.mi_pct, 999) AS mi_pct,
  -- le bien
  NULLIF(o.ltv, 999) AS ltv,
  NULLIF(o.cltv, 999) AS cltv,
  NULLIF(o.occupancy_status, '9') AS occupancy_status,
  NULLIF(o.property_type, '99') AS property_type,
  NULLIF(o.number_of_units, 99) AS number_of_units,
  o.property_state
FROM freddie_work.cible AS c
JOIN freddie_raw.origination AS o USING (loan_id)
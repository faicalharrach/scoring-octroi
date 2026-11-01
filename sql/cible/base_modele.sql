-- Base de modélisation : cible (une ligne par prêt) + caractéristiques à l'octroi.
-- Seules les informations connues le jour de l'octroi sont reprises :
-- rien qui vienne du fichier performance (sinon fuite d'information).
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
  o.credit_score,
  o.dti,
  o.number_of_borrowers,
  o.first_time_homebuyer,
  -- le prêt
  o.original_upb,
  o.original_interest_rate,
  o.original_loan_term,
  o.loan_purpose,
  o.channel,
  o.mi_pct,
  -- le bien
  o.ltv,
  o.cltv,
  o.occupancy_status,
  o.property_type,
  o.number_of_units,
  o.property_state
FROM freddie_work.cible AS c
JOIN freddie_raw.origination AS o USING (loan_id)
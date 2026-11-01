-- Contrôle : prêts, taux de défaut et qualité du score par échantillon
SELECT
  echantillon,
  COUNT(*) AS nb_prets,
  COUNTIF(defaut_24m IS NOT NULL) AS nb_avec_cible,
  ROUND(100 * AVG(defaut_24m), 2) AS taux_defaut_24m,
  ROUND(AVG(credit_score), 0) AS score_moyen,
  ROUND(100 * COUNTIF(credit_score IS NULL) / COUNT(*), 2) AS pct_score_manquant,
  ROUND(100 * COUNTIF(dti IS NULL) / COUNT(*), 2) AS pct_dti_manquant
FROM freddie_work.base_modele
GROUP BY echantillon
ORDER BY echantillon
-- Contrôle : nombre de prêts et taux de défaut par échantillon
SELECT
  echantillon,
  COUNT(*) AS nb_prets,
  COUNTIF(defaut_24m IS NOT NULL) AS nb_avec_cible,
  ROUND(100 * AVG(defaut_24m), 2) AS taux_defaut_24m,
  ROUND(AVG(credit_score), 0) AS score_moyen
FROM freddie_work.base_modele
GROUP BY echantillon
ORDER BY echantillon

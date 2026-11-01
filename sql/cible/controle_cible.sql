-- Contrôle : répartition des statuts et taux de défaut par vintage
SELECT
  vintage,
  echantillon,
  COUNT(*) AS nb_prets,
  COUNTIF(statut_cible = 'defaut') AS nb_defauts,
  COUNTIF(statut_cible LIKE 'sain%') AS nb_sains,
  COUNTIF(statut_cible LIKE 'exclu%') AS nb_exclus,
  ROUND(100 * AVG(defaut_24m), 2) AS taux_defaut_24m
FROM freddie_work.cible
GROUP BY vintage, echantillon
ORDER BY vintage
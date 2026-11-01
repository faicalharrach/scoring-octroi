-- Contrôle : les deux jeux doivent avoir des taux de défaut proches
SELECT
  jeu,
  COUNTIF(defaut_24m IS NOT NULL) AS nb_avec_cible,
  COUNTIF(defaut_24m = 1) AS nb_defauts,
  ROUND(100 * AVG(defaut_24m), 3) AS taux_defaut_24m
FROM freddie_work.base_modele
WHERE jeu IN ('apprentissage', 'test')
GROUP BY jeu
ORDER BY jeu
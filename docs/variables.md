# Analyse des variables

## credit_score (FICO)
- Classes : < 660 ou manquant | 660-699 | 700-739 | 740-779 | >= 780
- Fusion de < 620 (135 prêts) et 620-659 : trop peu de défauts pour une classe seule
- Manquants rangés avec les plus risqués : choix de prudence
- WoE monotone : -1,95 / -1,17 / -0,44 / +0,63 / +1,38
- IV = 1,045 : très forte, sans fuite (le FICO est connu à l'octroi)
- Limite : très peu de scores < 620 dans les données, car ces dossiers étaient refusés
  (réintégration des refusés non traitée)
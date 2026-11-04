# Analyse des variables

Analyse univariée sur le jeu d'apprentissage uniquement (222 915 prêts, 1 106 défauts).
Règle de sélection : IV < 0,02 écartée ; 0,02-0,1 candidate ; >= 0,1 retenue.
Valeurs manquantes : rangées avec la classe la plus risquée (prudence).

## Classement
| Variable | IV | Décision |
|---|---|---|
| credit_score | 1,045 | Retenue |
| dti | 0,297 | Retenue |
| number_of_borrowers | 0,291 | Retenue |
| ltv | 0,170 | Retenue |
| loan_purpose | 0,067 | Retenue |
| first_time_homebuyer | 0,028 | Candidate |
| occupancy_status | 0,021 | Candidate |
| channel | 0,006 | Écartée |

## Classes retenues
- credit_score : < 660 ou manquant | 660-699 | 700-739 | 740-779 | >= 780
- dti : <= 20 | 21-30 | 31-36 | 37-43 | > 43 ou manquant
- ltv : <= 60 | 61-75 | 76-80 | 81-90 | > 90 ou manquant
- number_of_borrowers : 1 ou manquant | 2
- loan_purpose : rachat simple (N) | achat ou rachat avec trésorerie (P, C)
- first_time_homebuyer : oui ou manquant | non
- occupancy_status : résidence principale | secondaire ou investissement

## Observations
- credit_score : IV très fort sans fuite ; le FICO résume l'historique de crédit
  (pas d'équivalent en France, faute de fichier positif). Très peu de scores
  < 620 : dossiers refusés à l'époque (réintégration des refusés non traitée).
- ltv : 29 % des prêts pile à 76-80 (seuil de l'assurance hypothécaire à 80 %).
  Inversion 61-70 / 71-75 corrigée par fusion ; cause non expliquée
  (pas liée à l'objet du prêt).
- dti : risque croissant sans saut à 43 % ; point neutre vers 31-36 %,
  proche du seuil HCSF français de 35 %.
- number_of_borrowers : un emprunteur seul fait 3 fois plus défaut que deux.
- occupancy_status : investisseurs moins risqués que les occupants, probablement
  un effet de sélection (critères d'octroi plus stricts après 2008).
- channel : décrit la banque et non le client ; écartée.
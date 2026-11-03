# Score d'octroi : de la définition du défaut à la grille de score

Projet de scoring crédit de bout en bout sur les données publiques
Freddie Mac (Single-Family Loan-Level Dataset, 1,4 million de prêts, 1999-2026).

## Avancement
- [x] Chargement dans BigQuery (76 millions de lignes mensuelles)
- [x] Définition du défaut : 90 jours de retard sous 24 mois (`docs/definition_defaut.md`)
- [x] Base de modélisation contrôlée : biais de sélection corrigé, codes sentinelles,
      exclusion des prêts HARP, découpage 70/30 reproductible
- [x] Première variable : score de crédit (IV = 1,045)
- [ ] Analyse des autres variables (LTV, DTI...)
- [ ] Grille de score (régression logistique)
- [ ] Validation hors période et suivi de stabilité
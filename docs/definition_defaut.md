# Définition du défaut

## Objectif du modèle
Estimer, au moment de l'octroi, la probabilité qu'un prêt fasse défaut
dans les 24 mois qui suivent.

## Unité statistique
Le prêt (`loan_id`). Une ligne par prêt dans la table cible.

## Événement de défaut
Un prêt est en défaut dès le premier mois où l'une de ces conditions est vraie :
- retard de 90 jours ou plus (`delinquency_status` >= 3) ;
- bien saisi (`delinquency_status` = 'RA') ;
- sortie avec perte (`zero_balance_code` 02, 03 ou 09).

Seuils de matérialité EBA (100 € et 1 % de l'encours) : satisfaits d'office,
trois mensualités impayées dépassent toujours ces deux seuils.

## Horizon
24 mois (`loan_age` <= 24). Choix appuyé sur les courbes de vintage :
à 12 mois, trop peu de défauts (~0,35 %) ; à 24 mois, ~0,8 % sur 2009-2016.

## Cible
- 1 : défaut dans les 24 mois ;
- 0 : prêt observé sans défaut, y compris s'il a été remboursé avant 24 mois
  (un remboursement est un comportement sain ; à tester en analyse de sensibilité) ;
- exclu : rachat par le vendeur (code 96, problème de dossier, pas de crédit) ;
- exclu : fenêtre de 24 mois incomplète à la date de dernière observation.
- exclu : prêts HARP (refinancement aidé de 2009-2018, sans étude de l'endettement) :
  restructurations et non octrois ; 100 % de leurs DTI sont manquants (81 128 prêts sur 2009-2016)

## Échantillons
| Usage | Vintages | Raison |
|---|---|---|
| Apprentissage / test | 2009-2016 | Période stable, fenêtre close avant le Covid |
| Hors période (out-of-time) | 2017 | Fenêtre close fin 2019, avant le Covid |
| Étude Covid | 2018-2021 | Reports d'échéance vus comme des retards |
| Récent (2e hors période) | 2022-2023 | Après le Covid, fenêtre close ; contrôle de stabilité |
| Production (sans cible) | 2024-2026 | Fenêtre incomplète : scorés, suivis par PSI |
| Analyse seulement | 1999-2008 | Pratiques d'octroi anciennes, crise de 2008 |

## Questions ouvertes
- Codes 15 et 16 (prêts revendus) : défaut seulement s'il y a eu 90 jours de retard avant ?
- Covid : utiliser `payment_deferral` pour neutraliser les reports d'échéance ?

## Mise en œuvre
- Requête : `sql/cible/table_cible.sql` -> table `freddie_work.cible`
- Contrôle : `sql/cible/controle_cible.sql`
- Colonnes : `defaut_24m` (1 / 0 / NULL = sans cible),
  `statut_cible` (motif de chaque valeur), `echantillon` (usage du prêt)
- Ordre des règles : fenêtre incomplète > HARP > défaut > rachat vendeur > observé 24 mois > remboursé
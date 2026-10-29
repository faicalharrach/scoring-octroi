"""Schéma des fichiers Freddie Mac (Single-Family Loan-Level Dataset).

Source : File Layout de juillet 2026 (docs/freddie/file_layout.xlsx).
Les fichiers n'ont pas d'en-tête : l'ordre des colonnes ci-dessous suit
exactement la colonne « Field Position » du File Layout.

Règle de typage :
- "string"  : identifiants et codes, même quand ils ressemblent à des nombres
              (code postal, statut de retard, motif de sortie...) ;
- "Int64"   : entiers qui peuvent être vides (I majuscule = entier « nullable ») ;
- "float64" : montants et taux.
Les dates AAAAMM restent en texte ici ; on les convertit à l'étape de nettoyage.
"""

# Fichier d'octroi : une ligne par prêt, figée au jour de l'octroi.
ORIGINATION = [
    ("credit_score", "Int64"),                  # 1  Classic FICO
    ("first_payment_date", "string"),           # 2  AAAAMM
    ("first_time_homebuyer", "string"),         # 3
    ("maturity_date", "string"),                # 4  AAAAMM
    ("msa", "string"),                          # 5  code de zone urbaine
    ("mi_pct", "Int64"),                        # 6  % d'assurance hypothécaire
    ("number_of_units", "Int64"),               # 7
    ("occupancy_status", "string"),             # 8
    ("cltv", "Int64"),                          # 9  tous prêts cumulés / valeur du bien
    ("dti", "Int64"),                           # 10 taux d'endettement
    ("original_upb", "float64"),                # 11 montant emprunté
    ("ltv", "Int64"),                           # 12 ce prêt / valeur du bien
    ("original_interest_rate", "float64"),      # 13
    ("channel", "string"),                      # 14
    ("prepayment_penalty", "string"),           # 15
    ("amortization_type", "string"),            # 16
    ("property_state", "string"),               # 17
    ("property_type", "string"),                # 18
    ("postal_code", "string"),                  # 19 3 chiffres, zéros en tête possibles
    ("loan_id", "string"),                      # 20 clé de jointure avec la performance
    ("loan_purpose", "string"),                 # 21
    ("original_loan_term", "Int64"),            # 22 en mois
    ("number_of_borrowers", "Int64"),           # 23
    ("seller_name", "string"),                  # 24
    ("super_conforming", "string"),             # 25
    ("pre_harp_loan_id", "string"),             # 26
    ("special_eligibility_program", "string"),  # 27
    ("harp_indicator", "string"),               # 28
    ("property_valuation_method", "string"),    # 29
    ("interest_only", "string"),                # 30
    ("vantage_score", "Int64"),                 # 31 VantageScore 4.0
]

# Fichier de performance : une ligne par prêt ET par mois.
PERFORMANCE = [
    ("loan_id", "string"),                          # 1
    ("period", "string"),                           # 2  mois observé, AAAAMM
    ("current_upb", "float64"),                     # 3  capital restant dû
    ("delinquency_status", "string"),               # 4  mois de retard ("RA" possible)
    ("loan_age", "Int64"),                          # 5
    ("remaining_months", "Int64"),                  # 6
    ("defect_settlement_date", "string"),           # 7
    ("modification_flag", "string"),                # 8
    ("zero_balance_code", "string"),                # 9  motif de sortie du prêt
    ("zero_balance_date", "string"),                # 10
    ("current_interest_rate", "float64"),           # 11
    ("non_interest_bearing_upb", "float64"),        # 12
    ("ddlpi", "string"),                            # 13 échéance de la dernière mensualité payée
    ("mi_recoveries", "float64"),                   # 14
    ("net_sales_proceeds", "string"),               # 15 montant, ou code "C"/"U"
    ("non_mi_recoveries", "float64"),               # 16
    ("total_expenses", "float64"),                  # 17
    ("legal_costs", "float64"),                     # 18
    ("maintenance_costs", "float64"),               # 19
    ("taxes_insurance", "float64"),                 # 20
    ("misc_expenses", "float64"),                   # 21
    ("actual_loss", "float64"),                     # 22
    ("cumulative_modification_costs", "float64"),   # 23
    ("interest_rate_step", "string"),               # 24
    ("payment_deferral", "string"),                 # 25
    ("eltv", "Int64"),                              # 26 LTV estimée à date
    ("zero_balance_removal_upb", "float64"),        # 27
    ("delinquent_accrued_interest", "float64"),     # 28
    ("delinquency_due_to_disaster", "string"),      # 29
    ("borrower_assistance_plan", "string"),         # 30
    ("current_period_modification_costs", "float64"),  # 31
    ("interest_bearing_upb", "float64"),            # 32
    ("mi_cancellation", "string"),                  # 33
    ("servicer_name", "string"),                    # 34
    ("bankruptcy_cramdown_costs", "float64"),       # 35
]
"""Conversion des zip Freddie Mac en Parquet, une année d'octroi à la fois.

Usage :
    python -m src.freddie.to_parquet              # toutes les années présentes
    python -m src.freddie.to_parquet 2009 2010    # seulement ces années
"""

import re
import sys
import time

import pandas as pd
import pyarrow as pa

from src.freddie.apercu import RACINE, RAW, lire
from src.freddie.schema import ORIGINATION, PERFORMANCE

PARQUET = RACINE / "data" / "parquet" / "freddie"

# Colonnes AAAAMM converties en vraies dates (1er jour du mois)
DATES_ORIG = ["first_payment_date", "maturity_date"]
DATES_PERF = ["period", "zero_balance_date", "ddlpi", "defect_settlement_date"]


def annees_disponibles() -> list[int]:
    """Années pour lesquelles un fichier sample_AAAA.zip est présent."""
    annees = []
    for chemin in RAW.glob("sample_*.zip"):
        m = re.fullmatch(r"sample_(\d{4})\.zip", chemin.name)
        if m:
            annees.append(int(m.group(1)))
    return sorted(annees)


def en_date(serie: pd.Series) -> pd.Series:
    """'201004' -> 2010-04-01. Une valeur mal formée fait échouer le script (voulu).

    Le type date32 est imposé : même une colonne entièrement vide reste une DATE,
    sinon BigQuery verrait une DATE pour une année et un TIMESTAMP pour une autre.
    """
    dates = pd.to_datetime(serie, format="%Y%m", errors="raise")
    return dates.astype(pd.ArrowDtype(pa.date32()))


def convertir(annee: int) -> None:
    debut = time.time()
    orig = lire(annee, "orig", ORIGINATION)
    perf = lire(annee, "perf", PERFORMANCE)

    # Contrôles : on s'arrête plutôt que de charger des données incohérentes
    assert orig["loan_id"].is_unique, "loan_id en double dans orig"
    assert perf["loan_id"].isin(orig["loan_id"]).all(), "prêts de perf absents de orig"
    assert not perf.duplicated(["loan_id", "period"]).any(), "mois en double dans perf"

    for col in DATES_ORIG:
        orig[col] = en_date(orig[col])
    for col in DATES_PERF:
        perf[col] = en_date(perf[col])

    # Année d'octroi (vintage) : indispensable pour les analyses par génération
    orig["vintage"] = annee
    perf["vintage"] = annee

    PARQUET.mkdir(parents=True, exist_ok=True)
    orig.to_parquet(PARQUET / f"orig_{annee}.parquet", index=False)
    perf.to_parquet(PARQUET / f"perf_{annee}.parquet", index=False)
    print(f"{annee} : {len(orig):>7,} prêts | {len(perf):>10,} lignes perf | {time.time() - debut:5.1f} s")


def main(annees: list[int]) -> None:
    for annee in annees:
        convertir(annee)


if __name__ == "__main__":
    main([int(a) for a in sys.argv[1:]] or annees_disponibles())
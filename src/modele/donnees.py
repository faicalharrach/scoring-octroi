"""Extraction de la base discrétisée depuis BigQuery, avec cache local en Parquet.

Usage : python -m src.modele.donnees   (force le rafraîchissement du cache)
"""

import os
from pathlib import Path

import pandas as pd
from google.cloud import bigquery

RACINE = Path(__file__).resolve().parents[2]
CACHE = RACINE / "data" / "modele" / "base_classes.parquet"
TABLE = "freddie_work.base_classes"
VARIABLES = ["c_score", "c_dti", "c_ltv", "c_emprunteurs", "c_objet", "c_primo", "c_occupation"]


def charger(rafraichir: bool = False) -> pd.DataFrame:
    """Lit le cache local s'il existe ; sinon (ou si rafraichir=True) interroge BigQuery."""
    if CACHE.exists() and not rafraichir:
        return pd.read_parquet(CACHE)
    client = bigquery.Client(project=os.environ.get("GCP_PROJECT"))
    df = client.query(f"SELECT * FROM `{client.project}.{TABLE}`").to_dataframe()
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    df.to_parquet(CACHE, index=False)
    return df


if __name__ == "__main__":
    df = charger(rafraichir=True)
    print(f"{len(df):,} prêts x {df.shape[1]} colonnes\n")
    resume = df.groupby("jeu").agg(nb_prets=("loan_id", "size"), taux_defaut=("defaut_24m", "mean"))
    print(resume)
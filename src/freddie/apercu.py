"""Aperçu d'une année du sample Freddie Mac, sans rien décompresser sur le disque.

Usage : python -m src.freddie.apercu 2010
"""

import sys
import zipfile
from pathlib import Path

import pandas as pd

from src.freddie.schema import ORIGINATION, PERFORMANCE

RACINE = Path(__file__).resolve().parents[2]
RAW = RACINE / "data" / "raw" / "freddie"


def lire(annee: int, fichier: str, schema: list, nrows: int | None = None) -> pd.DataFrame:
    """Lit sample_<fichier>_<annee>.txt directement dans le zip."""
    with zipfile.ZipFile(RAW / f"sample_{annee}.zip") as z:
        with z.open(f"sample_{fichier}_{annee}.txt") as f:
            return pd.read_csv(
                f,
                sep="|",
                header=None,                       # pas de ligne d'en-tête
                names=[nom for nom, _ in schema],  # noms tirés du File Layout
                dtype=dict(schema),                # types imposés, pas devinés
                index_col=False,                   # tolère un "|" en fin de ligne
                nrows=nrows,
            )


def nb_champs(annee: int, fichier: str) -> int:
    """Nombre de champs sur la 1re ligne brute (contrôle du schéma)."""
    with zipfile.ZipFile(RAW / f"sample_{annee}.zip") as z:
        with z.open(f"sample_{fichier}_{annee}.txt") as f:
            ligne = f.readline().decode().rstrip("\r\n")
    return len(ligne.split("|"))


def main(annee: int) -> None:
    for fichier, schema in [("orig", ORIGINATION), ("perf", PERFORMANCE)]:
        print(f"\n===== {fichier} {annee} =====")
        n = nb_champs(annee, fichier)
        statut = "OK" if n == len(schema) else "ÉCART : vérifier le File Layout"
        print(f"Champs dans le fichier : {n} | colonnes du schéma : {len(schema)} -> {statut}")

    orig = lire(annee, "orig", ORIGINATION)
    perf = lire(annee, "perf", PERFORMANCE)
    print(f"\norig : {orig.shape[0]:,} prêts x {orig.shape[1]} colonnes")
    print(f"perf : {perf.shape[0]:,} lignes x {perf.shape[1]} colonnes")
    print(f"Prêts présents dans les deux fichiers : {orig.loan_id.isin(perf.loan_id).mean():.1%}")

    print("\n--- 1er prêt (orig), en colonne ---")
    print(orig.iloc[0].to_string())

    print("\n--- Statut de retard (perf) ---")
    print(perf.delinquency_status.value_counts(dropna=False).head(10).to_string())

    print("\n--- Motif de sortie (perf) ---")
    print(perf.zero_balance_code.value_counts(dropna=False).to_string())


if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 2010)
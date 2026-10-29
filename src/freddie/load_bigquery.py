"""Chargement des Parquet Freddie Mac dans BigQuery (dataset freddie_raw).

Usage :
    export GCP_PROJECT=ton-projet-gcp
    python -m src.freddie.load_bigquery

Rechargement complet à chaque exécution : la 1re année remplace la table
(WRITE_TRUNCATE), les suivantes s'ajoutent (WRITE_APPEND). Relancer le script
donne donc toujours le même résultat, sans doublons (idempotence).
"""

import os

from google.cloud import bigquery

from src.freddie.to_parquet import PARQUET

DATASET = "freddie_raw"
LOCATION = "EU"

TABLES = {
    # 1 ligne par prêt : petite table, regroupée par année d'octroi
    "origination": {"motif": "orig_*.parquet", "partition": None, "cluster": ["vintage", "loan_id"]},
    # 1 ligne par prêt et par mois : partitionnée par mois observé, regroupée par prêt
    "performance": {"motif": "perf_*.parquet", "partition": "period", "cluster": ["loan_id"]},
}


def charger_table(client: bigquery.Client, table: str, conf: dict) -> None:
    table_id = f"{client.project}.{DATASET}.{table}"
    fichiers = sorted(PARQUET.glob(conf["motif"]))
    if not fichiers:
        raise FileNotFoundError(f"Aucun fichier {conf['motif']} : lancer d'abord src.freddie.to_parquet")

    for i, chemin in enumerate(fichiers):
        job_config = bigquery.LoadJobConfig(
            source_format=bigquery.SourceFormat.PARQUET,
            write_disposition=(bigquery.WriteDisposition.WRITE_TRUNCATE if i == 0
                               else bigquery.WriteDisposition.WRITE_APPEND),
            clustering_fields=conf["cluster"],
        )
        if conf["partition"]:
            job_config.time_partitioning = bigquery.TimePartitioning(
                type_=bigquery.TimePartitioningType.MONTH, field=conf["partition"])

        with open(chemin, "rb") as f:
            job = client.load_table_from_file(f, table_id, job_config=job_config)
        job.result()  # attend la fin du job ; lève une erreur si le chargement échoue
        print(f"  {chemin.name:<22} -> {job.output_rows:>10,} lignes")

    print(f"{table_id} : {client.get_table(table_id).num_rows:,} lignes au total\n")


def verifier(client: bigquery.Client) -> None:
    """Nombre de prêts et de lignes par année d'octroi, à comparer avec la conversion."""
    requete = f"""
        SELECT o.vintage, o.nb_prets, p.nb_lignes
        FROM (SELECT vintage, COUNT(*) AS nb_prets FROM `{client.project}.{DATASET}.origination` GROUP BY vintage) o
        JOIN (SELECT vintage, COUNT(*) AS nb_lignes FROM `{client.project}.{DATASET}.performance` GROUP BY vintage) p
        USING (vintage)
        ORDER BY vintage
    """
    print(client.query(requete).to_dataframe().to_string(index=False))


def main() -> None:
    client = bigquery.Client(project=os.environ.get("GCP_PROJECT"))
    dataset = bigquery.Dataset(f"{client.project}.{DATASET}")
    dataset.location = LOCATION
    client.create_dataset(dataset, exists_ok=True)

    for table, conf in TABLES.items():
        print(f"Chargement de {table}")
        charger_table(client, table, conf)
    verifier(client)


if __name__ == "__main__":
    main()
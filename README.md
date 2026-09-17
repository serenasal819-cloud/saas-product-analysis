# SaaS Product Analytics Platform

**Serena Salman · Data engineering portfolio project**

A working event analytics platform with immutable delivery receipts, tenant-aware deduplication, a quarantine queue, late-arrival correction and SQL models for adoption, retention, sessions and ordered activation funnels. It includes a local report, Kafka transport code, an Airflow DAG, a Spark/Databricks snapshot job and Snowflake/dbt models.

This is a new portfolio implementation using synthetic data. Its measured outputs are described below. It does not claim the production latency reduction mentioned in historical resume experience.

## Start in one command

Requires **Python 3.11 or newer**. No external packages, Docker, API keys or cloud accounts are required for the complete local workflow. From this project's folder:

```sh
python -m saas_analytics demo
```

Use `python3` on macOS/Linux if needed, or `py -3` on Windows. Open **`output/demo/report/index.html`** in a browser. The included **`examples/report/index.html`** is also ready to open immediately, without running a command.

Run the automated behavioral checks:

```sh
python -m unittest discover -s tests -v
```

## Actual results from the bundled demo

| Measure | Result |
|---|---:|
| Tenant-scoped users | 100 |
| Tenants | 4 |
| Accepted unique events | 3,322 |
| Late events recovered | 169 |
| Duplicate deliveries suppressed | 12 |
| Conflicting deliveries quarantined | 1 |
| Invalid deliveries quarantined | 4 |
| Signup → project → report → export | 100 → 80 → 72 → 24 users |

Arrival times and behavior are generated. These numbers demonstrate pipeline behavior; they are not customer outcomes or performance benchmarks.

## What is implemented

- **Bronze:** original deliveries with durable source locators and unique receipt IDs.
- **Silver:** validated events keyed by `(tenant_id, event_id)`; conflicts retain the first accepted business event and quarantine the new version.
- **Gold:** six SQL marts: daily KPIs, user funnel, funnel summary, weekly retention, feature adoption and sessions.
- **Recovery:** transactional ingestion, safe replay, atomic model replacement and full-refresh correction of historical late arrivals.
- **Observability:** run receipts, quarantine records, arrival-latency metrics and Prometheus-format output.
- **Presentation:** a self-contained HTML report, full CSV downloads and JSON evidence.
- **Delivery:** Python CI definition, a Dockerfile and optional service adapters.

## Run the stages independently

```sh
python -m saas_analytics ingest --input examples/inputs/events.jsonl --database output/manual/analytics.db --as-of 2026-09-01T12:00:00Z
python -m saas_analytics build --database output/manual/analytics.db --as-of 2026-09-01T12:00:00Z --output output/manual/before
python -m saas_analytics ingest --input examples/inputs/late_events.jsonl --database output/manual/analytics.db --as-of 2026-09-01T12:00:00Z
python -m saas_analytics build --database output/manual/analytics.db --as-of 2026-09-01T12:00:00Z --output output/manual/after
```

Compare the before and after reports. Run either ingestion command again: accepted-event totals and mart counts remain unchanged. A fresh output/database path starts a separate experiment without deleting any previous evidence.

## Repository map

```text
saas_analytics/          Ingestion engine, CLI, reporting and transport adapters
saas_analytics/sql/      Six executable local SQL models
tests/                  Behavior, isolation, recovery and offset-ordering tests
dbt/                    Snowflake transformations and data tests
dags/                   Airflow 3 TaskFlow orchestration
integrations/           Spark and Databricks snapshot materialization
examples/               Synthetic deliveries and actual generated reports
docs/                   Architecture, metric definitions and deployment instructions
```

Read [architecture](docs/ARCHITECTURE.md), [metric definitions](docs/METRICS.md), [operations](docs/RUNBOOK.md), [integrations](docs/INTEGRATIONS.md) and [verification](docs/VERIFICATION.md).

## Integration status

| Component | Delivered | Executed during this build |
|---|---|---|
| Python / SQLite / SQL / reports | Complete local runtime | Yes |
| Kafka | Producer, durable consumer, commit-order tests, optional broker Compose file | Commit behavior tested with a simulated consumer; live broker not run |
| Airflow | Retrying TaskFlow DAG for the complete demo | Airflow runtime unavailable here |
| Spark / Databricks | Validated snapshot to Parquet or Delta | Spark/Databricks runtime unavailable here |
| Snowflake / dbt | Run-scoped publisher, warehouse SQL and data tests | No Snowflake account supplied |
| GitHub Actions / Docker | CI definition and container build files | Files supplied; hosted CI and container build not run |

SQLite and full-refresh marts keep this demonstration self-contained. They are not a claim of distributed throughput, production access controls or a deployed streaming service.

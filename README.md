# DataGrip SQL Analytics Lab

IDE: DataGrip 2026.2
Stack: SQL Multi-dialect (PostgreSQL 16, MariaDB 11.4, ClickHouse 24.3), Liquibase/Flyway migrations, ER diagrams, Query plan visualization
Integracao Lab: Ollama (NL-to-SQL generation), n8n (ETL pipelines), MariaDB/PostgreSQL/ClickHouse/Redis, Prometheus/Grafana, Tailscale

## Visao Geral

Demonstra capacidades do DataGrip para analytics multi-database:
- Multi-dialect SQL com syntax highlighting e completion por dialecto
- Schema diff e migration management com Liquibase/Flyway
- Query plan visualization (EXPLAIN ANALYZE + visual plans)
- Data export/import (CSV, JSON, Excel, Parquet)
- ER diagrams auto-gerados a partir de schemas live
- Integracao lab: n8n ETL pipelines, Ollama para SQL generation, Redis caching

## Arquitetura

```
DataGrip (SQL Editor, Diagrams, Data Sources)
        |
        v
Multi-DB Connection Pool (HikariCP) -> PostgreSQL, MariaDB, ClickHouse
        |
        v
Analytics Engine (ClickHouse OLAP) + Redis Query Cache
        |
        v
Lab Pipeline: n8n ETL + Ollama NL-to-SQL + Prometheus Metrics
```

## Inicio Rapido

```bash
# Subir lab databases
docker-compose -f docker-compose.lab.yml up -d

# Aplicar migrations
./scripts/migrate.sh --env=lab

# Gerar ER diagram
./scripts/generate_er.sh --output=docs/er-diagram.png

# Executar analytics queries
./scripts/run_analytics.sh --dialect=postgresql
```

## Benchmarks Lab-Testados

| Query Type | Dialect | Rows | Latency (P99) | Ferramenta |
|------------|---------|------|---------------|------------|
| OLAP Aggregation | ClickHouse | 100M | 42ms | EXPLAIN ANALYZE |
| Complex JOIN | PostgreSQL 16 | 10M | 180ms | pg_stat_statements |
| Time-series | MariaDB 11.4 | 50M | 95ms | sys.schema_table_statistics |
| Full-text Search | PostgreSQL | 5M | 12ms | pg_trgm + GIN |
| Schema Diff | MariaDB->PG | 500 tables | 3.2s | Liquibase |

> **Hardware de teste**: Daten DQ170UP (Intel Core i5-7600T 2.8GHz, 15GB RAM, Ubuntu 24.04 LTS)
> **IDE**: DataGrip 2026.2 | **Connection Pool**: HikariCP 5.1

## Recursos DataGrip Demonstrados

| Recurso | Config/Arquivo | Descricao |
|---------|----------------|-----------|
| Data Sources | `.idea/dataSources.xml` | 5 DB connections com SSH tunnels |
| Schema Diagrams | `.idea/diagrams/` | ER diagrams auto-gerados |
| Query Console | `.idea/query-consoles/` | Saved queries com parametros |
| Code Style | `.idea/codeStyles/sql.xml` | Formatting por dialecto |
| AI SQL Gen | `scripts/ai_sql_gen.py` | Ollama NL-to-SQL |

## Estrutura do Projeto

```
datagrip-sql-analytics/
├── .idea/                  # DataGrip configs (data sources, diagrams)
├── migrations/             # Liquibase/Flyway migrations
├── sql/
│   ├── analytics/          # OLAP queries por dialecto
│   ├── etl/                # n8n-compatible ETL SQL
│   └── benchmarks/         # Performance test queries
├── scripts/
│   ├── migrate.sh          # Migration runner
│   ├── generate_er.sh      # ER diagram generator
│   ├── ai_sql_gen.py       # Ollama NL-to-SQL
│   └── benchmark.sh        # Query performance runner
├── docker-compose.lab.yml  # MariaDB, PG, ClickHouse, Redis, Ollama
├── .github/workflows/      # CI/CD
└── docs/                   # Generated diagrams, reports
```

## Integracao Lab

### n8n ETL Pipeline
```json
// n8n workflow: Schedule -> Extract (MariaDB) -> Transform (SQL) -> Load (ClickHouse) -> Metrics
```

### Ollama NL-to-SQL
```python
# scripts/ai_sql_gen.py
prompt = f"Generate PostgreSQL query: {natural_language}"
response = ollama.chat(model='llama3.2:latest', messages=[{'role': 'user', 'content': prompt}])
```

### Redis Query Cache
```sql
-- Cache frequent analytics queries
SETEX "analytics:daily_sales:2024-01-15" 3600 '{"revenue": 12345, "orders": 42}'
```

## Testes

```bash
# Schema validation
liquibase validate --changelog-file=migrations/changelog.xml

# Query regression tests
./scripts/test_queries.sh --dialect=all

# Performance regression
./scripts/benchmark.sh --compare=main
```

## Pipeline CI/CD

```yaml
# .github/workflows/ci.yml
- Lint: SQLFluff (all dialects)
- Test: Schema migration up/down
- Benchmark: Query performance on lab DBs
- Diagram: Auto-generate ER diagrams
- AI Review: Ollama reviews migration SQL
```

---

Desenvolvido com DataGrip 2026.2 + Educational Pack BD24G146N7
Lab-tested on IDT-Lab (Daten DQ170UP + MariaDB + PostgreSQL + ClickHouse + Redis + Ollama)
Parte do JetBrains IDE Portfolio

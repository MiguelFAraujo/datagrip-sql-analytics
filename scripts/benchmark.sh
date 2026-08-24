#!/bin/bash
# SQL Benchmark Runner for DataGrip Lab

set -euo pipefail

DIALECT="${1:-all}"
OUTPUT_DIR="benchmarks/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "=== DataGrip SQL Analytics Benchmarks ==="
echo "Dialect: $DIALECT"
echo "Output: $OUTPUT_DIR"

run_mariadb_benchmarks() {
    echo "Running MariaDB benchmarks..."
    for query in sql/analytics/oltp_queries.sql; do
        mysql -h localhost -P 3307 -u lab -plabpass analytics < "$query" 2>&1 | tee -a "$OUTPUT_DIR/mariadb.log"
    done
}

run_postgresql_benchmarks() {
    echo "Running PostgreSQL benchmarks..."
    for query in sql/analytics/oltp_queries.sql; do
        PGPASSWORD=labpass psql -h localhost -p 5433 -U lab -d analytics -f "$query" 2>&1 | tee -a "$OUTPUT_DIR/postgresql.log"
    done
}

run_clickhouse_benchmarks() {
    echo "Running ClickHouse benchmarks..."
    for query in sql/analytics/olap_queries.sql; do
        clickhouse-client -h localhost --port 9000 -u lab --password labpass -d analytics -q "$(cat "$query")" 2>&1 | tee -a "$OUTPUT_DIR/clickhouse.log"
    done
}

case "$DIALECT" in
    mariadb) run_mariadb_benchmarks ;;
    postgresql) run_postgresql_benchmarks ;;
    clickhouse) run_clickhouse_benchmarks ;;
    all)
        run_mariadb_benchmarks
        run_postgresql_benchmarks
        run_clickhouse_benchmarks
        ;;
    *) echo "Unknown dialect: $DIALECT"; exit 1 ;;
esac

echo "Benchmarks complete. Results in $OUTPUT_DIR"

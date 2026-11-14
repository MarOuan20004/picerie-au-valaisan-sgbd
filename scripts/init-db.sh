#!/usr/bin/env bash
# ==============================================================================
# Initialisation de la base de donnees Oracle (Schema + Donnees)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCHEMA_SQL="${ROOT_DIR}/sql/creation_insertion/schema.sql"

ORACLE_USER="${ORACLE_USER:-${DB_USER:-elhadarm}}"
ORACLE_PASS="${ORACLE_PASSWORD:-${ORACLE_PASS:-${DB_PASSWORD:-elhadarm}}}"
ORACLE_HOST="${ORACLE_HOST:-oracle1.ensimag.fr}"
ORACLE_PORT="${ORACLE_PORT:-1521}"
ORACLE_SID="${ORACLE_SID:-oracle1}"

echo "==> Initialisation de la base de donnees Oracle..."
echo "Cible : ${ORACLE_USER}@${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SID}"
echo "Fichier SQL : ${SCHEMA_SQL}"

if command -v sqlplus >/dev/null 2>&1; then
    echo "Execution via SQL*Plus..."
    sqlplus -S "${ORACLE_USER}/${ORACLE_PASS}@${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SID}" @"${SCHEMA_SQL}"
    echo "==> Initialisation terminee."
else
    echo "Note : L'utilitaire sqlplus n'est pas installe localement."
    echo "Vous pouvez executer le script '${SCHEMA_SQL}' directement"
    echo "depuis Oracle SQL Developer, DBeaver ou sur les serveurs Ensimag via :"
    echo "  sqlplus ${ORACLE_USER}/${ORACLE_PASS}@oracle1.ensimag.fr:1521:oracle1 @${SCHEMA_SQL}"
fi

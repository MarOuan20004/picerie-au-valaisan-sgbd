#!/usr/bin/env bash
# ==============================================================================
# Lancement de l'application Epicier / Gerant (EpicierApp)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

"${SCRIPT_DIR}/compile.sh"

CLASSPATH="${ROOT_DIR}/target/classes:${ROOT_DIR}/bin:${ROOT_DIR}/libs/ojdbc17.jar:${ROOT_DIR}/src/main/resources"

echo "==> Lancement de l'Espace Epicier..."
java -cp "${CLASSPATH}" jdbc.EpicierApp "$@"

#!/usr/bin/env bash
# ==============================================================================
# Script de compilation du projet Au Valaisan
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "==> Compilation du projet Au Valaisan..."

if command -v mvn >/dev/null 2>&1; then
    echo "Compilation avec Apache Maven..."
    mvn -f "${ROOT_DIR}/pom.xml" compile
else
    echo "Maven non detecte, compilation directe avec javac..."
    mkdir -p "${ROOT_DIR}/bin"
    javac -encoding UTF-8 \
          -cp "${ROOT_DIR}/libs/ojdbc17.jar" \
          -d "${ROOT_DIR}/bin" \
          $(find "${ROOT_DIR}/src/main/java" -name "*.java")
fi

echo "==> Compilation terminee avec succes."

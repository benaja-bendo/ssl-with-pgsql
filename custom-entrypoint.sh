#!/bin/bash

set -e

# Exécuter le script de génération de certificats
/usr/local/bin/generate_certs.sh

# Démarrer PostgreSQL
exec docker-entrypoint.sh "$@"

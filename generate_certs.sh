#!/bin/bash

# Définir le répertoire des certificats
CERTS_DIR="/var/lib/postgresql/certs"

# Créer le dossier des certificats s'il n'existe pas déjà
mkdir -p "$CERTS_DIR"

# Générer la clé privée de l'autorité de certification (4096 bits)
echo "Génération de la clé privée de l'autorité de certification (rootCA.key)..."
openssl genrsa -out "$CERTS_DIR/rootCA.key" 4096

# Créer un certificat auto-signé pour l'autorité de certification valable 10 ans (3650 jours)
echo "Création du certificat auto-signé pour l'autorité de certification (rootCA.crt)..."
openssl req -x509 -new -nodes -key "$CERTS_DIR/rootCA.key" -sha256 -days 3650 -out "$CERTS_DIR/rootCA.crt" \
-subj "/C=FR/ST=YourState/L=YourCity/O=YourOrganization/OU=YourDepartment/CN=localhost"

# Générer une clé privée de 2048 bits pour le serveur PostgreSQL
echo "Génération de la clé privée du serveur PostgreSQL (server.key)..."
openssl genrsa -out "$CERTS_DIR/server.key" 2048

# Créer une demande de signature de certificat (CSR) pour le serveur PostgreSQL
echo "Création de la demande de signature de certificat (server.csr)..."
openssl req -new -key "$CERTS_DIR/server.key" -out "$CERTS_DIR/server.csr" \
-subj "/C=FR/ST=YourState/L=YourCity/O=YourOrganization/OU=YourDepartment/CN=localhost"

# Signer la CSR avec l'autorité de certification pour générer un certificat valide pendant 1 an (365 jours)
echo "Signature de la CSR avec l'autorité de certification (server.crt)..."
openssl x509 -req -in "$CERTS_DIR/server.csr" -CA "$CERTS_DIR/rootCA.crt" -CAkey "$CERTS_DIR/rootCA.key" -CAcreateserial -out "$CERTS_DIR/server.crt" -days 365 -sha256

# Protéger la clé privée du serveur PostgreSQL (server.key)
echo "Protection de la clé privée du serveur PostgreSQL (server.key)..."
chmod 600 "$CERTS_DIR/server.key"

# Conversion en format valide pour les applications Java (PKCS #8)
echo "Conversion de la clé privée du serveur en format PKCS #8 (server.pk8)..."
openssl pkcs8 -topk8 -inform PEM -outform DER -in "$CERTS_DIR/server.key" -out "$CERTS_DIR/server.pk8" -nocrypt

echo "Tous les certificats ont été générés avec succès dans le dossier $CERTS_DIR."


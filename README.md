# Serveur PostgreSQL protégé par SSL/TLS

## Structure des dossiers

```bash
.
├── certs
│   ├── rootCA.key         # Clé privée de l'autorité de certification (CA)
│   ├── rootCA.crt         # Certificat auto-signé de l'autorité de certification
│   ├── server.key         # Clé privée du serveur PostgreSQL
│   ├── server.csr         # Demande de signature de certificat (CSR) pour le serveur PostgreSQL
│   ├── server.crt         # Certificat signé pour le serveur PostgreSQL
│   ├── server.pk8         # Clé privée du serveur au format PKCS #8 (pour applications Java)
│   └── rootCA.srl         # Numéro de série pour la signature des certificats (généré automatiquement)
```

## Générer les certificats TLS

1- Créer une autorité de certification (CA) : Cette autorité sera utilisée pour signer le certificat du serveur PostgreSQL.

```bash
# Créer le dossier certs avant d'exécuter la commande OpenSSL
mkdir -p certs

# Générer la clé privée de l'autorité de certification (4096 bits)
openssl genrsa -out ./certs/rootCA.key 4096

# Créer un certificat auto-signé pour l'autorité de certification valable 10 ans (3650 jours)
openssl req -x509 -new -nodes -key certs/rootCA.key -sha256 -days 3650 -out certs/rootCA.crt \
-subj "/C=FR/ST=YourState/L=YourCity/O=YourOrganization/OU=YourDepartment/CN=localhost"
```

2- Générer une clé pour le serveur PostgreSQL : Cette clé sera utilisée pour le chiffrement des connexions.

```bash
# Générer une clé privée de 2048 bits pour le serveur PostgreSQL
openssl genrsa -out certs/server.key 2048

# Créer une demande de signature de certificat (CSR) pour le serveur PostgreSQL
openssl req -new -key certs/server.key -out certs/server.csr \
-subj "/C=FR/ST=YourState/L=YourCity/O=YourOrganization/OU=YourDepartment/CN=localhost"
```

3- Signer la demande CSR avec l'autorité de certification (CA) : Cette étape transforme la demande de certificat en un certificat valide pour le serveur PostgreSQL.

```bash
# Signer la CSR avec l'autorité de certification pour générer un certificat valide pendant 1 an (365 jours)
openssl x509 -req -in certs/server.csr -CA certs/rootCA.crt -CAkey certs/rootCA.key -CAcreateserial -out certs/server.crt -days 365 -sha256
```

4- Protéger la clé privée du serveur PostgreSQL : Assurez-vous que seule l'utilisateur PostgreSQL puisse accéder à la clé privée.

```bash
chmod 600 certs/server.key
```

## Conversion en format valide pour les applications Java

Si votre application Java nécessite l'utilisation d'une clé au format PKCS #8, vous pouvez convertir la clé privée du serveur au format .pk8 :

```bash
openssl pkcs8 -topk8 -inform PEM -outform DER -in certs/server.key -out certs/server.pk8 -nocrypt
```

Cette conversion est utile pour assurer la compatibilité avec certaines applications Java qui préfèrent le format .pk8.

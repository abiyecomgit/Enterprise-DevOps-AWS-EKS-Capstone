
#!/bin/bash

# ==================================================
# TechPathway - Amazon RDS MySQL Setup
# ==================================================
# Purpose:
# 1. Load database configuration from .env
# 2. Verify required database settings
# 3. Import SQL schema into Amazon RDS
# 4. Restart the TechPathway application
# 5. Verify application status
#
# Run on the original EC2 server after deploy_ec2.sh
# Usage: bash scripts/setup_rds.sh
# ==================================================

set -euo pipefail

APP_DIR="/var/www/techpathway"
ENV_FILE="$APP_DIR/.env"
SCHEMA_FILE="$APP_DIR/schema.sql"
SERVICE_NAME="techpathway"

echo ""
echo "=========================================="
echo "       TechPathway - RDS Setup"
echo "=========================================="

# STEP 1: Check environment file

if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: Environment file not found."
    echo "Expected location: $ENV_FILE"
    exit 1
fi

# STEP 2: Load environment variables

set -a
source "$ENV_FILE"
set +a

echo "Environment configuration loaded."

# STEP 3: Validate database configuration

required_vars=(
    MYSQL_HOST
    MYSQL_PORT
    MYSQL_USER
    MYSQL_PASSWORD
    MYSQL_DB
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var:-}" ]; then
        echo "ERROR: $var is missing or empty."
        echo "Check your .env configuration."
        exit 1
    fi
done

echo ""
echo "Database configuration:"
echo "Host:     $MYSQL_HOST"
echo "Port:     $MYSQL_PORT"
echo "Database: $MYSQL_DB"
echo "User:     $MYSQL_USER"
echo ""

# STEP 4: Verify MySQL client

if ! command -v mysql >/dev/null 2>&1; then
    echo "ERROR: MySQL client is not installed."
    exit 1
fi

# STEP 5: Verify SQL schema file

if [ ! -f "$SCHEMA_FILE" ]; then
    echo "ERROR: SQL schema file not found."
    echo "Expected location: $SCHEMA_FILE"
    exit 1
fi

# STEP 6: Create a protected MySQL credentials file

MYSQL_CNF="$(umask 077; mktemp)"

cleanup() {
    rm -f "$MYSQL_CNF"
}

trap cleanup EXIT

{
    printf '[client]\n'
    printf 'password="%s"\n' \
        "$(printf '%s' "$MYSQL_PASSWORD" | sed 's/\\/\\\\/g; s/"/\\"/g')"
} > "$MYSQL_CNF"

# STEP 7: Import schema into Amazon RDS

echo "Loading schema into Amazon RDS..."

if mysql \
    --defaults-extra-file="$MYSQL_CNF" \
    -h "$MYSQL_HOST" \
    -P "$MYSQL_PORT" \
    -u "$MYSQL_USER" \
    "$MYSQL_DB" < "$SCHEMA_FILE"; then

    echo "SUCCESS: Schema and seed data loaded into RDS."

else
    echo "ERROR: Database schema import failed."
    exit 1
fi

# Remove temporary credentials before continuing

cleanup
trap - EXIT

# STEP 8: Restart TechPathway application

echo ""
echo "Restarting TechPathway application..."

if sudo systemctl restart "$SERVICE_NAME"; then
    echo "Application restart command completed."
else
    echo "ERROR: Application restart failed."
    exit 1
fi

sleep 2

# STEP 9: Verify application status

if sudo systemctl is-active --quiet "$SERVICE_NAME"; then

    echo ""
    echo "SUCCESS: TechPathway application is running."
    echo "Application restarted after RDS setup."

else

    echo ""
    echo "ERROR: TechPathway application failed to start."
    echo "Check logs using:"
    echo "sudo journalctl -u $SERVICE_NAME -n 50"

    exit 1
fi

echo ""
echo "=========================================="
echo "       RDS Setup Completed"
echo "=========================================="

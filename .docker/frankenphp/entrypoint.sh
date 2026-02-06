#!/bin/sh

set -e

# Install Composer dependencies if needed
if [ ! -d "vendor" ] || [ ! -f "vendor/autoload.php" ]; then
    echo "📦 Installing Composer dependencies..."
    composer install --no-interaction --prefer-dist --optimize-autoloader
fi

# Prepare directory for persistent binary
mkdir -p /app/public/.docker/frankenphp/bin
mkdir -p /root/.laravel-octane

# Binary paths
FRANKENPHP_PERSISTENT="/app/public/.docker/frankenphp/bin/frankenphp"
FRANKENPHP_DOWNLOADED="/root/.laravel-octane/frankenphp"
FRANKENPHP_SYSTEM="/usr/local/bin/frankenphp"

# Check if system binary exists (comes with the image)
if [ -f "$FRANKENPHP_SYSTEM" ]; then
    echo "✅ System binary found ($FRANKENPHP_SYSTEM)"
    
    # Test if the binary works (check version)
    if "$FRANKENPHP_SYSTEM" version > /dev/null 2>&1; then
        echo "✅ System binary is functional"
    else
        echo "⚠️  System binary did not respond, but continuing..."
    fi
    
    # If persistent doesn't exist, copy from system
    if [ ! -f "$FRANKENPHP_PERSISTENT" ]; then
        echo "📦 Copying system binary to persistent volume..."
        cp "$FRANKENPHP_SYSTEM" "$FRANKENPHP_PERSISTENT"
        chmod +x "$FRANKENPHP_PERSISTENT"
    fi
    
    # Create symlink where Octane expects it
    rm -f "$FRANKENPHP_DOWNLOADED"
    ln -sf "$FRANKENPHP_SYSTEM" "$FRANKENPHP_DOWNLOADED"
    chmod +x "$FRANKENPHP_DOWNLOADED"
    echo "✅ Symlink created: $FRANKENPHP_DOWNLOADED -> $FRANKENPHP_SYSTEM"
elif [ -f "$FRANKENPHP_PERSISTENT" ]; then
    echo "✅ Using persistent binary..."
    rm -f "$FRANKENPHP_DOWNLOADED"
    ln -sf "$FRANKENPHP_PERSISTENT" "$FRANKENPHP_DOWNLOADED"
    chmod +x "$FRANKENPHP_PERSISTENT"
    echo "✅ Symlink created: $FRANKENPHP_DOWNLOADED -> $FRANKENPHP_PERSISTENT"
else
    echo "📦 Waiting for Octane to download the binary..."
    # Monitor binary download and copy to persistent volume in background
    (
        sleep 5
        i=0
        while [ $i -lt 120 ]; do
            if [ -f "$FRANKENPHP_DOWNLOADED" ] && [ ! -f "$FRANKENPHP_PERSISTENT" ]; then
                echo "📦 Binary downloaded! Copying to persistent volume..."
                cp "$FRANKENPHP_DOWNLOADED" "$FRANKENPHP_PERSISTENT"
                chmod +x "$FRANKENPHP_PERSISTENT"
                echo "✅ Binary persisted"
                break
            fi
            sleep 1
            i=$((i + 1))
        done
    ) &
fi

# Clear OPcache before starting
php -r "if (function_exists('opcache_reset')) { opcache_reset(); echo 'OPcache cleared\n'; }"

# Clear Laravel cache
php artisan config:clear || true
php artisan cache:clear || true
php artisan route:clear || true
php artisan view:clear || true

# Start Octane with FrankenPHP in watch mode
exec php artisan octane:frankenphp --host=0.0.0.0 --port=8090 --admin-port=2019 --watch --no-interaction

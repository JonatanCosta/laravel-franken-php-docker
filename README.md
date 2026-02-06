# Laravel FrankenPHP Docker

Docker Compose setup to test Laravel with FrankenPHP and Octane.

## 📋 Prerequisites

- Docker
- Docker Compose
- Make (optional)

## 🚀 Quick Start

### Using Make

```bash
make up
```

### Using Docker Compose directly

```bash
docker-compose -f docker-compose.yml up -d
```

## 🏗️ Architecture

This project sets up a Docker environment with:

- **FrankenPHP**: Modern web server based on Caddy with PHP 8.2 support
- **Laravel Octane**: FrankenPHP driver for high performance
- **PHP 8.2**: With essential extensions (PDO, MySQL, GD, BCMath, Sockets, PCNTL)

## 📦 Project Structure

```
.
├── .docker/
│   └── frankenphp/
│       ├── Dockerfile          # Custom Docker image
│       ├── entrypoint.sh       # Initialization script
│       └── Caddyfile           # Caddy configuration
├── docker-compose.yml          # Docker Compose configuration
├── Makefile                    # Useful commands
└── README.md                   # This file
```

## 🔧 Configuration

### Ports

- **8090**: HTTP (internal port 8090)
- **8091**: HTTPS
- **8091/UDP**: HTTP/3

### Environment Variables

- `COMPOSER_MEMORY_LIMIT=2G`: Memory limit for Composer
- `ENVIRONMENT=local`: Execution environment

### Volumes

- `.:/app/public`: Laravel application code
- `./.docker/frankenphp/bin:/app/public/.docker/frankenphp/bin`: Persistent FrankenPHP binary
- `caddy_data`: Caddy data (certificates)
- `caddy_config`: Caddy configuration

## 📝 Features

### Entrypoint Script

The `entrypoint.sh` script automatically performs:

1. **Dependency installation**: Installs Composer dependencies if needed
2. **Binary management**: 
   - Checks for system binary
   - Copies to persistent volume
   - Creates symlinks for Octane
   - Monitors automatic download if necessary
3. **Cache clearing**: Clears OPcache and Laravel caches
4. **Initialization**: Starts Octane with FrankenPHP in watch mode

### Installed PHP Extensions

- `pdo` / `pdo_mysql`: MySQL database support
- `calendar`: Calendar functions
- `gd`: Image manipulation
- `bcmath`: Arbitrary precision mathematics
- `sockets`: Socket programming
- `pcntl`: Process control

## 🛠️ Useful Commands

### View logs

```bash
docker-compose logs -f php-frankenphp
```

### Access container

```bash
docker-compose exec php-frankenphp sh
```

### Rebuild image

```bash
docker-compose build --no-cache php-frankenphp
```

### Stop containers

```bash
docker-compose down
```

### Stop and remove volumes

```bash
docker-compose down -v
```

## 🌐 Accessing the Application

After starting the containers, the application will be available at:

- **HTTP**: http://localhost:8090
- **HTTPS**: https://localhost:8091
- **HTTP/3**: https://localhost:8091 (via UDP)

## 📚 Additional Resources

- [FrankenPHP Documentation](https://frankenphp.dev/)
- [Laravel Octane Documentation](https://laravel.com/docs/octane)
- [Caddy Documentation](https://caddyserver.com/docs/)

## 🔒 Security

The Caddyfile includes default security headers:

- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: SAMEORIGIN`
- `X-XSS-Protection: 1; mode=block`

## 📄 License

This project is a Docker configuration template for development.

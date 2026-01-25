#!/bin/bash
set -e

# StyleMCP Deployment Script
# Usage: ./deploy.sh [command]
# Commands: setup, start, stop, restart, logs, update

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[StyleMCP]${NC} $1"; }
warn() { echo -e "${YELLOW}[Warning]${NC} $1"; }
error() { echo -e "${RED}[Error]${NC} $1"; exit 1; }

# Check for Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
    fi
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        error "Docker Compose is not installed. Please install Docker Compose first."
    fi
}

# Determine docker compose command
docker_compose() {
    if docker compose version &> /dev/null; then
        docker compose "$@"
    else
        docker-compose "$@"
    fi
}

# Setup environment
setup() {
    log "Setting up StyleMCP..."

    # Create .env file if it doesn't exist
    if [ ! -f .env ]; then
        log "Creating .env file..."
        cat > .env << EOF
# StyleMCP Configuration
# Generate a secure API key: openssl rand -hex 32
STYLEMCP_API_KEY=

# GitHub webhook secret (optional)
# Generate: openssl rand -hex 20
GITHUB_WEBHOOK_SECRET=

# Port (default: 3000)
PORT=3000
EOF
        warn ".env file created. Please edit it to set your API key."
    fi

    # Create certs directory
    mkdir -p certs

    log "Setup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Edit .env to set STYLEMCP_API_KEY"
    echo "  2. Run: ./deploy.sh start"
    echo ""
    echo "For SSL (optional):"
    echo "  1. Place fullchain.pem and privkey.pem in ./certs/"
    echo "  2. Edit nginx.conf to uncomment HTTPS server block"
    echo "  3. Run: ./deploy.sh start --profile with-nginx"
}

# Build and start
start() {
    check_docker
    log "Building and starting StyleMCP..."

    # Load environment
    if [ -f .env ]; then
        export $(grep -v '^#' .env | xargs)
    fi

    docker_compose up -d --build "$@"

    log "StyleMCP is starting..."
    echo ""
    echo "Endpoints:"
    echo "  Health:  http://localhost:${PORT:-3000}/health"
    echo "  API:     http://localhost:${PORT:-3000}/api/validate"
    echo "  MCP SSE: http://localhost:${PORT:-3000}/api/mcp/sse"
    echo ""
    echo "View logs: ./deploy.sh logs"
}

# Stop
stop() {
    check_docker
    log "Stopping StyleMCP..."
    docker_compose down
    log "Stopped."
}

# Restart
restart() {
    stop
    start "$@"
}

# View logs
logs() {
    check_docker
    docker_compose logs -f "$@"
}

# Update (pull latest and restart)
update() {
    log "Updating StyleMCP..."
    git pull origin main || warn "Git pull failed, continuing with local files"
    restart "$@"
}

# Health check
health() {
    local port=${PORT:-3000}
    local response=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${port}/health")
    if [ "$response" = "200" ]; then
        log "StyleMCP is healthy"
        curl -s "http://localhost:${port}/health" | jq .
    else
        error "StyleMCP health check failed (HTTP $response)"
    fi
}

# Test API
test_api() {
    local port=${PORT:-3000}
    local api_key=${STYLEMCP_API_KEY:-}

    log "Testing StyleMCP API..."

    local headers=""
    if [ -n "$api_key" ]; then
        headers="-H 'X-Api-Key: $api_key'"
    fi

    echo "Testing validation..."
    curl -s -X POST "http://localhost:${port}/api/validate" \
        -H "Content-Type: application/json" \
        ${api_key:+-H "X-Api-Key: $api_key"} \
        -d '{"text": "Click here to learn more!"}' | jq .

    echo ""
    log "API test complete"
}

# Show help
help() {
    echo "StyleMCP Deployment Script"
    echo ""
    echo "Usage: ./deploy.sh [command]"
    echo ""
    echo "Commands:"
    echo "  setup    - Initialize configuration files"
    echo "  start    - Build and start the server"
    echo "  stop     - Stop the server"
    echo "  restart  - Restart the server"
    echo "  logs     - View server logs"
    echo "  update   - Pull latest code and restart"
    echo "  health   - Check server health"
    echo "  test     - Test the API"
    echo "  help     - Show this help"
    echo ""
    echo "Options:"
    echo "  --profile with-nginx  - Include Nginx reverse proxy"
}

# Main
case "${1:-help}" in
    setup)   setup ;;
    start)   shift; start "$@" ;;
    stop)    stop ;;
    restart) shift; restart "$@" ;;
    logs)    shift; logs "$@" ;;
    update)  shift; update "$@" ;;
    health)  health ;;
    test)    test_api ;;
    help)    help ;;
    *)       error "Unknown command: $1. Run './deploy.sh help' for usage." ;;
esac

#!/bin/bash

# Exit immediately if a command exits with a non-zero status, use as necessary
# set -e

# pass the domain to the script as it executes the build, or use the default domain
DOMAIN=${1:-petstore.getYourMojoOn.com}

echo "Using domain: ${DOMAIN}"

# Define relative paths
CERT_PATH="./certs"
CONFIG_PATH="./config"

# Install Docker
if ! command -v docker &> /dev/null
then
    echo "Docker could not be found, installing..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null
then
    echo "Docker Compose could not be found, installing..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully."
else
    echo "Docker Compose is already installed."
fi

# Create directories for certificates and configurations
mkdir -p ${CERT_PATH}
mkdir -p ${CONFIG_PATH}

# Generate SSL Certificates
echo "Generating SSL certificates..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${CERT_PATH}/nginx.key -out ${CERT_PATH}/nginx.crt -subj "/CN=${DOMAIN}"
echo "SSL certificates generated."

# Create Nginx configuration
cat <<EOF > ${CONFIG_PATH}/nginx.conf
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    sendfile on;
    log_format  main  '\$remote_addr - xf \$http_x_forwarded_for - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent"';
    server {
        listen 80;
        listen 443 ssl;

        access_log  /var/log/nginx/access.log  main;

        server_name ${DOMAIN};

        ssl_certificate /etc/nginx/certs/nginx.crt;
        ssl_certificate_key /etc/nginx/certs/nginx.key;

        location /v3 {
            proxy_pass http://petstore:8080/v3;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
        location /v2 {
            proxy_pass http://petstore:8080/v2;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
        location / {
            proxy_pass http://petstore:8080;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF
echo "Nginx configuration created."

# Create Docker Compose file
cat <<EOF > ${CONFIG_PATH}/docker-compose.yml
version: '3.3'
services:
  petstore:
    image: swaggerapi/petstore3:latest
    ports:
      - "8080"
    environment:
      - SWAGGER_HOST=https://${DOMAIN}
      - SWAGGER_BASE_PATH=/v3
    restart: unless-stopped

  nginx:
    image: nginx:latest
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ${PWD}/${CERT_PATH}:/etc/nginx/certs:ro
      - ${PWD}/${CONFIG_PATH}/nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - petstore
    restart: unless-stopped
EOF
echo "Docker Compose file created."

# Run Docker Compose
cd ${CONFIG_PATH}
sudo docker-compose up -d
echo "Docker Compose has been started ${DOMAIN} in detached mode."

# Install net-tools
if ! command -v ifconfig &> /dev/null
then
    echo "ifconfig not found, installing..."
    sudo apt install net-tools -y
    echo "net-tools installed successfully."
else
    echo "net-tools is already installed."
fi

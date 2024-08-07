REMOTE_PORT=8080

# Generate a random subdomain name (e.g., 8 characters long)
SUBDOMAIN=$(openssl rand -hex 4)

# Nginx configuration path
NGINX_CONFIG="/etc/nginx/conf.d/${SUBDOMAIN}.conf"

# Check if the subdomain already exists
if [ -f "$NGINX_CONFIG" ]; then
    echo "Subdomain $SUBDOMAIN already exists. Generating a new one."
    exit 1
fi

# Create a new Nginx configuration for the subdomain
echo "Creating Nginx configuration for subdomain: $SUBDOMAIN.theemperorsplace.com"

sudo bash -c "cat > $NGINX_CONFIG" <<EOL
server {
    listen 80;
    server_name ${SUBDOMAIN}.theemperorsplace.com;

    location / {
        proxy_pass http://localhost:$REMOTE_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# Test the new Nginx configuration for syntax errors
if sudo nginx -t; then
    # Reload Nginx to apply changes
    sudo systemctl reload nginx
    echo "Nginx has been updated and reloaded successfully."
    echo "You can now access your service at http://${SUBDOMAIN}.theemperorsplace.com"
else
    # If there's an error, remove the bad config file and exit
    sudo rm -f $NGINX_CONFIG
    echo "Error in Nginx configuration. Configuration not applied."
  
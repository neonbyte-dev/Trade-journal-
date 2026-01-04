#!/bin/bash
# Deploy Trade Journal Bot to DigitalOcean
# Run this script from your local machine: ./deploy.sh

DROPLET_IP="167.71.99.109"
REMOTE_DIR="/root/trade-journal-bot"

echo "Deploying Trade Journal Bot to DigitalOcean..."

# Step 1: Create directory on server
ssh root@$DROPLET_IP "mkdir -p $REMOTE_DIR"

# Step 2: Copy files to server
rsync -avz --exclude '__pycache__' --exclude '*.pyc' --exclude '.git' --exclude 'trades.db' \
    ./ root@$DROPLET_IP:$REMOTE_DIR/

# Step 3: Copy local .env and set ENVIRONMENT=digitalocean
# NOTE: This copies YOUR local .env file - make sure it has valid credentials
scp .env root@$DROPLET_IP:$REMOTE_DIR/.env
ssh root@$DROPLET_IP "echo 'ENVIRONMENT=digitalocean' >> $REMOTE_DIR/.env"

# Step 4: Install dependencies
ssh root@$DROPLET_IP "cd $REMOTE_DIR && pip3 install python-telegram-bot python-dotenv requests anthropic"

# Step 5: Kill any existing bot process
ssh root@$DROPLET_IP "pkill -f 'python3.*bot.py' || true"

# Step 6: Start the bot with nohup
ssh root@$DROPLET_IP "cd $REMOTE_DIR && nohup python3 bot.py > bot.log 2>&1 &"

echo ""
echo "Deployment complete!"
echo "Check status: ssh root@$DROPLET_IP 'ps aux | grep bot.py'"
echo "View logs: ssh root@$DROPLET_IP 'tail -f $REMOTE_DIR/bot.log'"

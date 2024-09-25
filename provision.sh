#!/bin/bash

sudo apt-get install -y \
    curl \
    unzip \
    wget \
    git \
    neofetch \
    htop \
    nano \
    build-essential \
    software-properties-common

# ssh sChallenge Response Authentication
sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config

# Configurer l'authentification par clé publique
chmod 700 /home/vagrant/.ssh
cat /home/vagrant/data/id_ed25519.pub >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys


# Create a script to generate the banner dynamically
cat << 'EOF' > /usr/local/bin/generate_banner.sh
#!/bin/bash
{
  echo "Welcome to F3lin Lab"
  echo ""
  echo "Hostname: $(hostname)"
  echo "IP Address: $(hostname -I | awk '{print $1}')"
  echo "OS: $(grep PRETTY_NAME /etc/os-release | cut -d'=' -f2 | tr -d '\"')"
  echo "CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | sed 's/^ *//')"
  echo "Memory: $(free -h | awk '/^Mem:/ {print $2}')"
  echo "Disk: $(df -h / | awk 'NR==2 {print $2}')"
  echo ""
  cat /home/vagrant/data/banner.ascii
} > /etc/ssh/banner.txt
EOF

chmod +x /usr/local/bin/generate_banner.sh

# Run the banner generation script
/usr/local/bin/generate_banner.sh

# Configure SSH to use the generated banner file
echo "Banner /etc/ssh/banner.txt" >> /etc/ssh/sshd_config

# Configure the message of the day (MOTD)
cat << 'EOF' > /etc/update-motd.d/99-custom-motd
#!/bin/bash
/usr/local/bin/generate_banner.sh
EOF
chmod +x /etc/update-motd.d/99-custom-motd

# Restart the SSH service to apply the changes
systemctl restart sshd

chmod +x /home/vagrant/data/install_oh_my_posh.sh

bash /home/vagrant/data/install_oh_my_posh.sh
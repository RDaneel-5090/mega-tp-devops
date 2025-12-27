# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Mega TP - Infrastructure DevOps Haute Disponibilité
# Déploiement automatisé avec Vagrant et Ansible
# Auteur: [Votre Nom]
# Date: Décembre 2025

# Configuration réseau
NETWORK_PREFIX = "192.168.56"
ADMIN_IP = "#{NETWORK_PREFIX}.10"
NODE01_IP = "#{NETWORK_PREFIX}.11"
NODE02_IP = "#{NETWORK_PREFIX}.12"
WINSRV_IP = "#{NETWORK_PREFIX}.13"
VIP_IP = "#{NETWORK_PREFIX}.100"  # IP Flottante pour le cluster HA

# Configuration du domaine AD
AD_DOMAIN = "lab.local"
AD_NETBIOS = "LAB"

Vagrant.configure("2") do |config|
  
  # Désactiver la mise à jour automatique des Guest Additions
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  # ============================================
  # Machine Admin - Ubuntu Server 22.04
  # Rôle: Contrôleur Ansible + Serveur Zabbix
  # ============================================
  config.vm.define "admin", primary: true do |admin|
    admin.vm.box = "ubuntu/jammy64"
    admin.vm.hostname = "admin"
    admin.vm.network "private_network", ip: ADMIN_IP

    admin.vm.provider "virtualbox" do |vb|
      vb.name = "TP-Admin"
      vb.memory = 4096
      vb.cpus = 2
      vb.gui = false
    end

    # Synchronisation du dossier Ansible
    admin.vm.synced_folder "./ansible", "/home/vagrant/ansible", create: true

    # Provisionnement de la machine Admin
    admin.vm.provision "shell", inline: <<-SHELL
      set -e
      echo "=== Configuration de la machine Admin ==="
      
      # Mise à jour des paquets
      export DEBIAN_FRONTEND=noninteractive
      apt-get update -qq
      apt-get upgrade -y -qq
      
      # Installation des dépendances
      apt-get install -y -qq software-properties-common curl wget gnupg2 sshpass python3-pip
      
      # Installation d'Ansible
      apt-add-repository --yes --update ppa:ansible/ansible
      apt-get install -y -qq ansible
      
      # Installation des modules Python pour Ansible (Windows)
      pip3 install pywinrm requests-ntlm --quiet
      
      # Configuration SSH pour Ansible
      mkdir -p /home/vagrant/.ssh
      ssh-keygen -t rsa -b 4096 -f /home/vagrant/.ssh/id_rsa -N "" -q
      chown -R vagrant:vagrant /home/vagrant/.ssh
      chmod 700 /home/vagrant/.ssh
      chmod 600 /home/vagrant/.ssh/id_rsa
      
      # Configuration Ansible
      mkdir -p /etc/ansible
      cat > /etc/ansible/ansible.cfg << 'EOF'
[defaults]
inventory = /home/vagrant/ansible/inventory/hosts.yml
host_key_checking = False
retry_files_enabled = False
timeout = 30
forks = 10
log_path = /var/log/ansible.log
roles_path = /home/vagrant/ansible/roles

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
pipelining = True
EOF

      echo "=== Machine Admin configurée avec succès ==="
    SHELL
  end

  # ============================================
  # Node01 - RedHat/CentOS Stream 9
  # Rôle: Nœud Cluster HA (Web + Samba)
  # ============================================
  config.vm.define "node01" do |node01|
    node01.vm.box = "generic/centos9s"
    node01.vm.hostname = "node01"
    node01.vm.network "private_network", ip: NODE01_IP

    node01.vm.provider "virtualbox" do |vb|
      vb.name = "TP-Node01"
      vb.memory = 2048
      vb.cpus = 2
      vb.gui = false
    end

    # Provisionnement initial
    node01.vm.provision "shell", inline: <<-SHELL
      set -e
      echo "=== Configuration initiale de Node01 ==="
      
      # Configuration SSH pour Ansible
      sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
      systemctl restart sshd
      
      # Création de l'utilisateur ansible
      useradd -m -s /bin/bash ansible 2>/dev/null || true
      echo "ansible:ansible" | chpasswd
      echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
      chmod 440 /etc/sudoers.d/ansible
      
      # Configuration SSH pour l'utilisateur ansible
      mkdir -p /home/ansible/.ssh
      chmod 700 /home/ansible/.ssh
      chown -R ansible:ansible /home/ansible/.ssh
      
      # Désactivation de SELinux temporairement pour le déploiement initial
      setenforce 0 || true
      sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
      
      # Configuration du hostname dans /etc/hosts
      echo "#{ADMIN_IP} admin admin.#{AD_DOMAIN}" >> /etc/hosts
      echo "#{NODE01_IP} node01 node01.#{AD_DOMAIN}" >> /etc/hosts
      echo "#{NODE02_IP} node02 node02.#{AD_DOMAIN}" >> /etc/hosts
      echo "#{WINSRV_IP} winsrv winsrv.#{AD_DOMAIN}" >> /etc/hosts
      echo "#{VIP_IP} cluster-vip cluster-vip.#{AD_DOMAIN}" >> /etc/hosts
      
      echo "=== Node01 configuré avec succès ==="
    SHELL
  end

  # ============================================
  # Node02 - RedHat/CentOS Stream 9
  # Rôle: Nœud Cluster HA (Web + Samba)
  # ============================================
  config.vm.define "node02" do |node02|
    node02.vm.box = "generic/centos9s"
    node02.vm.hostname = "node02"
    node02.vm.network "private_network", ip: NODE02_IP

    node02.vm.provider "virtualbox" do |vb|
      vb.name = "TP-Node02"
      vb.memory = 2048
      vb.cpus = 2
      vb.gui = false
    end

    # Provisionnement initial
    node02.vm.provision "shell", inline: <<-SHELL
      set -e
      echo "=== Configuration initiale de Node02 ==="
      
      # Configuration SSH pour Ansible
      sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
      systemctl restart sshd
      
      # Création de l'utilisateur ansible
      useradd -m -s /bin/bash ansible 2>/dev/null || true
      echo "ansible:ansible" | chpasswd
      echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
      chmod 440 /etc/sudoers.d/ansible
      
      # Configuration SSH pour l'utilisateur ansible
      mkdir -p /home/ansible/.ssh
      chmod 700 /home/ansible/.ssh
      chown -R ansible:ansible /home/ansible/.ssh
      
      # Désactivation de SELinux temporairement
      setenforce 0 || true
      sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
      
      # Configuration du hostname dans /etc/hosts
      echo "#{ADMIN_IP} admin admin.#{AD_DOMAIN}" >> /etc/hosts
      echo "#{NODE01_IP} node01 node01.#{AD_DOMAIN}" >> /etc/hosts
      echo "#{NODE02_IP} node02 node02.#{AD_DOMAIN}" >> /etc/hosts
      echo "#{WINSRV_IP} winsrv winsrv.#{AD_DOMAIN}" >> /etc/hosts
      echo "#{VIP_IP} cluster-vip cluster-vip.#{AD_DOMAIN}" >> /etc/hosts
      
      echo "=== Node02 configuré avec succès ==="
    SHELL
  end

  # ============================================
  # WinSrv - Windows Server 2019
  # Rôle: Contrôleur de Domaine Active Directory
  # ============================================
  config.vm.define "winsrv" do |winsrv|
    winsrv.vm.box = "gusztavvargadr/windows-server-2019-standard"
    winsrv.vm.hostname = "winsrv"
    winsrv.vm.network "private_network", ip: WINSRV_IP
    
    # Configuration de la communication
    winsrv.vm.communicator = "winrm"
    winsrv.winrm.username = "vagrant"
    winsrv.winrm.password = "vagrant"
    winsrv.winrm.transport = :plaintext
    winsrv.winrm.basic_auth_only = true
    winsrv.vm.boot_timeout = 600
    winsrv.winrm.timeout = 300
    winsrv.winrm.retry_limit = 20

    winsrv.vm.provider "virtualbox" do |vb|
      vb.name = "TP-WinSrv"
      vb.memory = 4096
      vb.cpus = 2
      vb.gui = false
    end

    # Provisionnement PowerShell pour WinRM
    winsrv.vm.provision "shell", privileged: true, inline: <<-SHELL
      Write-Host "=== Configuration de WinRM pour Ansible ==="
      
      # Configuration WinRM
      winrm quickconfig -q
      winrm set winrm/config/service '@{AllowUnencrypted="true"}'
      winrm set winrm/config/service/auth '@{Basic="true"}'
      winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'
      
      # Configuration du pare-feu pour WinRM
      netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=tcp localport=5985
      netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=tcp localport=5986
      
      # Activation de l'exécution de scripts PowerShell
      Set-ExecutionPolicy Unrestricted -Force
      
      # Configuration du hostname dans le fichier hosts
      Add-Content -Path "C:\\Windows\\System32\\drivers\\etc\\hosts" -Value "#{ADMIN_IP} admin"
      Add-Content -Path "C:\\Windows\\System32\\drivers\\etc\\hosts" -Value "#{NODE01_IP} node01"
      Add-Content -Path "C:\\Windows\\System32\\drivers\\etc\\hosts" -Value "#{NODE02_IP} node02"
      Add-Content -Path "C:\\Windows\\System32\\drivers\\etc\\hosts" -Value "#{VIP_IP} cluster-vip"
      
      # Redémarrage du service WinRM
      Restart-Service WinRM
      
      Write-Host "=== WinRM configuré avec succès ==="
    SHELL
  end

  # ============================================
  # Provisionnement final depuis Admin
  # Distribution des clés SSH et lancement Ansible
  # ============================================
  config.vm.define "admin" do |admin|
    admin.vm.provision "shell", run: "always", inline: <<-SHELL
      echo "=== Distribution des clés SSH ==="
      
      # Attendre que les autres machines soient prêtes
      sleep 10
      
      # Distribution de la clé SSH vers les nœuds Linux
      for node in #{NODE01_IP} #{NODE02_IP}; do
        sshpass -p 'ansible' ssh-copy-id -o StrictHostKeyChecking=no -i /home/vagrant/.ssh/id_rsa.pub ansible@$node 2>/dev/null || true
      done
      
      # Test de connexion
      echo "Test de connexion aux nœuds..."
      ssh -o StrictHostKeyChecking=no -i /home/vagrant/.ssh/id_rsa ansible@#{NODE01_IP} "hostname" 2>/dev/null && echo "Node01: OK" || echo "Node01: En attente..."
      ssh -o StrictHostKeyChecking=no -i /home/vagrant/.ssh/id_rsa ansible@#{NODE02_IP} "hostname" 2>/dev/null && echo "Node02: OK" || echo "Node02: En attente..."
      
      echo "=== Infrastructure prête pour le déploiement Ansible ==="
      echo ""
      echo "Pour déployer l'infrastructure complète:"
      echo "  vagrant ssh admin"
      echo "  cd /home/vagrant/ansible"
      echo "  ansible-playbook site.yml"
    SHELL
  end
end

# 🚀 Mega TP - Infrastructure DevOps Haute Disponibilité

[![Vagrant](https://img.shields.io/badge/Vagrant-2.3+-blue.svg)](https://www.vagrantup.com/)
[![Ansible](https://img.shields.io/badge/Ansible-2.15+-red.svg)](https://www.ansible.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Table des Matières

- [Présentation](#-présentation)
- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Installation Rapide](#-installation-rapide)
- [Guide Détaillé](#-guide-détaillé)
- [Missions Implémentées](#-missions-implémentées)
- [Accès aux Services](#-accès-aux-services)
- [Commandes Utiles](#-commandes-utiles)
- [Dépannage](#-dépannage)
- [Captures d'écran](#-captures-décran)

---

## 🎯 Présentation

Ce projet implémente une infrastructure DevOps complète avec **haute disponibilité**, **sécurisation** et **supervision** automatisées via **Vagrant** et **Ansible**.

### Objectifs du Projet

- ✅ Déploiement automatisé de 4 machines virtuelles
- ✅ Cluster Pacemaker/Corosync en haute disponibilité
- ✅ Services Web (Nginx) et Fichiers (Samba) redondants
- ✅ Active Directory avec durcissement sécuritaire
- ✅ Supervision centralisée avec Zabbix

---

## 🏗 Architecture

### Schéma d'Infrastructure

```
┌──────────────────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE DEVOPS HA                          │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│    ┌─────────────┐                                                   │
│    │   Client    │                                                   │
│    └──────┬──────┘                                                   │
│           │                                                          │
│           ▼                                                          │
│    ┌─────────────┐         VIP: 192.168.56.100                       │
│    │  VIP (HA)   │◄────────────────────────────┐                     │
│    └──────┬──────┘                             │                     │
│           │                                     │                    │
│    ┌──────┴──────┬─────────────────────────────┤                     │
│    ▼             ▼                             │                     │
│  ┌───────────────────┐   ┌───────────────────┐ │                     │
│  │     Node01        │   │     Node02        │ │                     │
│  │  192.168.56.11    │   │  192.168.56.12    │ │                     │
│  │  ─────────────    │   │  ─────────────    │ │                     │
│  │  • Nginx (HA)     │◄─►│  • Nginx (HA)     │ │  Corosync           │
│  │  • Samba (HA)     │   │  • Samba (HA)     │ │  Heartbeat          │
│  │  • Pacemaker      │   │  • Pacemaker      │ │                     │
│  │  • Zabbix Agent   │   │  • Zabbix Agent   │ │                     │
│  │  RedHat/CentOS 9  │   │  RedHat/CentOS 9  │ │                     │
│  └─────────┬─────────┘   └─────────┬─────────┘ │                     │
│            │                       │           │                     │
│            └───────────┬───────────┘           │                     │
│                        │                       │                     │
│                        ▼                       │                     │
│  ┌───────────────────────────────────────────┐ │                     │
│  │              Admin Server                  │ │                    │
│  │           192.168.56.10                    │ │                    │
│  │  ───────────────────────                   │ │                    │
│  │  • Ansible Controller                      │ │                    │
│  │  • Zabbix Server                           │─┘                    │
│  │  • Ubuntu 22.04                            │                      │
│  └───────────────────────────────────────────┘                       │
│                        │                                             │
│                        │ Ansible (WinRM)                             │
│                        ▼                                             │
│  ┌───────────────────────────────────────────┐                       │
│  │           Windows Server                   │                      │
│  │           192.168.56.13                    │                      │
│  │  ───────────────────────                   │                      │
│  │  • Active Directory (DC)                   │                      │
│  │  • DNS Server                              │                      │
│  │  • LAPS                                    │                      │
│  │  • Windows Server 2019                     │                      │
│  └───────────────────────────────────────────┘                       │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Configuration Réseau

| Machine | Hostname | IP | OS | Rôle |
|---------|----------|----|----|------|
| Admin | admin | 192.168.56.10 | Ubuntu 22.04 | Ansible Controller, Zabbix Server |
| Node01 | node01 | 192.168.56.11 | CentOS 9 Stream | Cluster HA (Nginx, Samba) |
| Node02 | node02 | 192.168.56.12 | CentOS 9 Stream | Cluster HA (Nginx, Samba) |
| WinSrv | winsrv | 192.168.56.13 | Windows Server 2019 | Active Directory DC |
| **VIP** | cluster-vip | **192.168.56.100** | - | IP Flottante du Cluster |

---

## 📦 Prérequis

### Logiciels Requis

- **VirtualBox** 7.0+ ([Télécharger](https://www.virtualbox.org/))
- **Vagrant** 2.3+ ([Télécharger](https://www.vagrantup.com/downloads))
- **Git** ([Télécharger](https://git-scm.com/downloads))

### Ressources Système Recommandées

- **RAM**: 16 Go minimum (les VMs utilisent ~12 Go au total)
- **CPU**: 4 cœurs minimum
- **Stockage**: 50 Go d'espace disque libre

### Plugins Vagrant (Optionnel)

```bash
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-reload
```

---

## 🚀 Installation Rapide

### 1. Cloner le Dépôt

```bash
git clone https://github.com/votre-username/mega-tp-devops.git
cd mega-tp-devops
```

### 2. Démarrer l'Infrastructure

```bash
# Déployer toutes les VMs
vagrant up

# Attendre environ 15-20 minutes pour le déploiement initial
```

### 3. Lancer la Configuration Ansible

```bash
# Se connecter à la machine Admin
vagrant ssh admin

# Exécuter le playbook principal
cd /home/vagrant/ansible
ansible-playbook site.yml
```

### 4. Vérifier le Déploiement

```bash
# Vérifier l'état du cluster
ssh ansible@192.168.56.11 "sudo pcs status"

# Accéder à Zabbix
# URL: http://192.168.56.10/zabbix
# Login: Admin / zabbix
```

---

## 📘 Guide Détaillé

### Structure du Projet

```
mega-tp-devops/
├── Vagrantfile                 # Configuration des VMs
├── README.md                   # Documentation
├── ansible/
│   ├── ansible.cfg             # Configuration Ansible
│   ├── site.yml                # Playbook principal
│   ├── inventory/
│   │   └── hosts.yml           # Inventaire des hôtes
│   └── roles/
│       ├── common/             # Configuration commune Linux
│       ├── ha-cluster/         # Pacemaker & Corosync
│       ├── nginx-ha/           # Nginx en HA
│       ├── samba-ha/           # Samba en HA
│       ├── security-linux/     # Durcissement Linux
│       ├── zabbix-server/      # Serveur Zabbix
│       ├── zabbix-agent/       # Agent Zabbix
│       ├── windows-ad/         # Active Directory
│       └── windows-hardening/  # Durcissement Windows
└── zabbix/
    └── dashboards/             # Screenshots/exports Zabbix
```

### Déploiement Étape par Étape

#### Phase 1: Démarrage des VMs

```bash
# Démarrer uniquement une VM spécifique
vagrant up admin
vagrant up node01
vagrant up node02
vagrant up winsrv
```

#### Phase 2: Configuration Ansible

```bash
vagrant ssh admin
cd /home/vagrant/ansible

# Tester la connectivité
ansible all -m ping

# Déployer par étapes
ansible-playbook site.yml --tags common
ansible-playbook site.yml --tags cluster
ansible-playbook site.yml --tags nginx
ansible-playbook site.yml --tags samba
ansible-playbook site.yml --tags security
ansible-playbook site.yml --tags zabbix
ansible-playbook site.yml --tags windows
```

---

## ✅ Missions Implémentées

### Mission 1: Haute Disponibilité (HA)

| Composant | Status | Description |
|-----------|--------|-------------|
| Pacemaker | ✅ | Gestionnaire de ressources cluster |
| Corosync | ✅ | Couche de messagerie cluster |
| VIP | ✅ | 192.168.56.100 - IP Flottante |
| Nginx HA | ✅ | Serveur web Active/Passive |
| Samba HA | ✅ | Partage de fichiers SMB |
| Colocation | ✅ | VIP + Nginx + Samba basculent ensemble |

**Fonctionnement**: En cas de panne de Node01, toutes les ressources (VIP, Nginx, Samba) basculent automatiquement sur Node02.

### Mission 2: Sécurisation Linux

| Mesure | Status | Description |
|--------|--------|-------------|
| Firewalld | ✅ | Ports ouverts: SSH, HTTP, Cluster, Zabbix |
| SSH Hardening | ✅ | Root désactivé, MaxAuthTries=3 |
| Mises à jour auto | ✅ | dnf-automatic configuré |
| Audit | ✅ | auditd activé avec règles |
| Sysctl | ✅ | ASLR, SYN cookies, etc. |

### Mission 3: Windows Server & AD

| Composant | Status | Description |
|-----------|--------|-------------|
| AD DS | ✅ | Domaine: lab.local |
| LAPS | ✅ | Gestion des mots de passe locaux |
| Guest désactivé | ✅ | Compte invité désactivé |
| Pare-feu | ✅ | Activé sur tous les profils |
| Politique MDP | ✅ | 12 caractères, complexité |
| SMBv1 | ✅ | Désactivé |
| LLMNR | ✅ | Désactivé |

### Mission 4: Supervision Zabbix

| Composant | Status | Description |
|-----------|--------|-------------|
| Zabbix Server | ✅ | http://192.168.56.10/zabbix |
| Agents Node01/02 | ✅ | Monitoring complet |
| CPU/RAM | ✅ | Métriques système |
| Nginx status | ✅ | Disponibilité web |
| Cluster status | ✅ | État du cluster HA |
| Alertes | ✅ | Ping, Agent unreachable |

---

## 🔗 Accès aux Services

### URLs et Identifiants

| Service | URL | Identifiants |
|---------|-----|--------------|
| **Zabbix** | http://192.168.56.10/zabbix | Admin / zabbix |
| **Web (VIP)** | http://192.168.56.100 | - |
| **Samba** | \\\\192.168.56.100\share | Guest ou nobody |
| **AD** | lab.local | LAB\Administrator / Admin2025! |

### Ports Utilisés

| Port | Service | Protocole |
|------|---------|-----------|
| 22 | SSH | TCP |
| 80 | HTTP (Nginx) | TCP |
| 443 | HTTPS | TCP |
| 445 | SMB (Samba) | TCP |
| 2224 | PCS Web UI | TCP |
| 5404-5405 | Corosync | UDP |
| 10050 | Zabbix Agent | TCP |
| 10051 | Zabbix Server | TCP |
| 5985 | WinRM HTTP | TCP |

---

## 🛠 Commandes Utiles

### Gestion du Cluster

```bash
# État du cluster
sudo pcs status

# Ressources du cluster
sudo pcs resource show

# Basculer manuellement les ressources
sudo pcs resource move ha_services node02
sudo pcs resource clear ha_services

# Mettre un nœud en maintenance
sudo pcs node standby node01
sudo pcs node unstandby node01

# Logs du cluster
sudo journalctl -u pacemaker -f
sudo journalctl -u corosync -f
```

### Gestion des VMs Vagrant

```bash
# État des VMs
vagrant status

# Redémarrer une VM
vagrant reload node01

# Recréer une VM
vagrant destroy node01 -f && vagrant up node01

# SSH vers une VM
vagrant ssh admin
vagrant ssh node01
```

### Tests de Haute Disponibilité

```bash
# Test 1: Arrêter Node01 et vérifier le basculement
vagrant halt node01
curl http://192.168.56.100  # Doit fonctionner via Node02

# Test 2: Redémarrer Node01
vagrant up node01

# Test 3: Vérifier que les services sont revenus
ssh ansible@192.168.56.11 "sudo pcs status"
```

---

## 🔧 Dépannage

### Problèmes Courants

#### Le cluster ne démarre pas

```bash
# Vérifier les logs
sudo journalctl -u pcsd -n 50
sudo journalctl -u corosync -n 50

# Réinitialiser l'authentification
sudo pcs cluster auth node01 node02 -u hacluster -p [password]
sudo pcs cluster start --all
```

#### Zabbix inaccessible

```bash
# Vérifier les services
sudo systemctl status zabbix-server
sudo systemctl status apache2
sudo systemctl status mysql

# Redémarrer les services
sudo systemctl restart zabbix-server apache2
```

#### WinRM ne fonctionne pas

```powershell
# Sur Windows Server
winrm quickconfig -force
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
Restart-Service WinRM
```

#### Connectivité Ansible

```bash
# Test de ping
ansible all -m ping

# Debug de connexion
ansible node01 -m ping -vvvv
```

---

## 📸 Captures d'Écran

> 📁 Les captures d'écran sont disponibles dans le dossier `zabbix/dashboards/`

### Éléments à capturer pour le rendu:

1. **État du Cluster** (`pcs status`)
2. **Dashboard Zabbix** avec métriques CPU/RAM
3. **Page Web** via la VIP (192.168.56.100)
4. **Console AD** sur Windows Server

---

## 👥 Auteurs

- **RDaneel-5090** - *Développement initial*

## 🙏 Remerciements

- Documentation Ansible: https://docs.ansible.com/
- Documentation Pacemaker: https://clusterlabs.org/pacemaker/doc/
- Documentation Zabbix: https://www.zabbix.com/documentation/

---

<div align="center">
  <b>⭐ Si ce projet vous a été utile, n'hésitez pas à lui donner une étoile ! ⭐</b>
</div>

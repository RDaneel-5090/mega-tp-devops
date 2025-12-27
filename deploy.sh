#!/bin/bash
# ============================================
# Script de déploiement rapide
# Mega TP - Infrastructure DevOps HA
# ============================================

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions d'affichage
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Afficher la bannière
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     MEGA TP - Infrastructure DevOps Haute Disponibilité     ║"
echo "║                    Script de Déploiement                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Vérifier les prérequis
info "Vérification des prérequis..."

if ! command -v vagrant &> /dev/null; then
    error "Vagrant n'est pas installé. Veuillez l'installer d'abord."
fi

if ! command -v VBoxManage &> /dev/null; then
    error "VirtualBox n'est pas installé. Veuillez l'installer d'abord."
fi

success "Prérequis vérifiés"

# Menu principal
echo ""
echo "Que souhaitez-vous faire ?"
echo "1) Déployer l'infrastructure complète"
echo "2) Démarrer uniquement les VMs"
echo "3) Lancer Ansible (configuration)"
echo "4) Vérifier l'état du cluster"
echo "5) Détruire l'infrastructure"
echo "6) Quitter"
echo ""
read -p "Votre choix [1-6]: " choice

case $choice in
    1)
        info "Déploiement de l'infrastructure complète..."
        vagrant up
        success "VMs démarrées"
        
        info "Attente de la stabilisation..."
        sleep 30
        
        info "Lancement de la configuration Ansible..."
        vagrant ssh admin -c "cd /home/vagrant/ansible && ansible-playbook site.yml"
        success "Configuration terminée"
        
        echo ""
        success "Infrastructure déployée avec succès !"
        echo ""
        echo "📊 Zabbix: http://192.168.56.10/zabbix (Admin/zabbix)"
        echo "🌐 Web HA: http://192.168.56.100"
        echo "📁 Samba: \\\\192.168.56.100\\share"
        ;;
    2)
        info "Démarrage des VMs..."
        vagrant up
        success "VMs démarrées"
        ;;
    3)
        info "Lancement d'Ansible..."
        vagrant ssh admin -c "cd /home/vagrant/ansible && ansible-playbook site.yml"
        success "Configuration Ansible terminée"
        ;;
    4)
        info "Vérification de l'état du cluster..."
        vagrant ssh admin -c "ssh ansible@192.168.56.11 'sudo pcs status'"
        ;;
    5)
        warning "Attention: Cette action va détruire toutes les VMs !"
        read -p "Êtes-vous sûr ? (oui/non): " confirm
        if [ "$confirm" == "oui" ]; then
            info "Destruction de l'infrastructure..."
            vagrant destroy -f
            success "Infrastructure détruite"
        else
            info "Opération annulée"
        fi
        ;;
    6)
        info "Au revoir !"
        exit 0
        ;;
    *)
        error "Choix invalide"
        ;;
esac

echo ""

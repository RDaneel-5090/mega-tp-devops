# Configuration du Dashboard Zabbix

## Accès à Zabbix

- **URL**: http://192.168.56.10/zabbix
- **Utilisateur**: Admin
- **Mot de passe**: zabbix

## Étapes de Configuration

### 1. Ajouter les Hôtes

1. Aller dans **Configuration** > **Hosts** > **Create host**
2. Configurer Node01:
   - **Host name**: node01
   - **Groups**: Linux servers
   - **Interfaces**: 
     - Type: Agent
     - IP: 192.168.56.11
     - Port: 10050

3. Répéter pour Node02 avec l'IP 192.168.56.12

### 2. Importer le Template Personnalisé

1. Aller dans **Configuration** > **Templates** > **Import**
2. Sélectionner le fichier `template_ha_cluster.xml`
3. Cliquer sur **Import**

### 3. Lier le Template aux Hôtes

1. Aller dans **Configuration** > **Hosts**
2. Cliquer sur node01
3. Aller dans l'onglet **Templates**
4. Chercher et ajouter:
   - Template OS Linux by Zabbix agent
   - Template HA Cluster (notre template personnalisé)
5. Répéter pour node02

### 4. Créer le Dashboard Personnalisé

1. Aller dans **Monitoring** > **Dashboards**
2. Cliquer sur **Create dashboard**
3. Nom: "HA Cluster Overview"

#### Widgets à ajouter:

**Widget 1: État du Cluster**
- Type: Problems by severity
- Hosts: node01, node02
- Problem tags: cluster

**Widget 2: CPU/RAM Node01**
- Type: Graph (classic)
- Host: node01
- Items: 
  - CPU utilization
  - Memory utilization

**Widget 3: CPU/RAM Node02**
- Type: Graph (classic)
- Host: node02
- Items:
  - CPU utilization
  - Memory utilization

**Widget 4: Disponibilité Web**
- Type: Plain text
- Host: node01, node02
- Item: nginx.http.check

**Widget 5: État des Services**
- Type: Item value
- Items:
  - node01: cluster.status
  - node01: nginx.status
  - node01: samba.status
  - node02: cluster.status
  - node02: nginx.status
  - node02: samba.status

**Widget 6: Alertes Récentes**
- Type: Problems
- Hosts: node01, node02
- Show: All problems

### 5. Configurer les Alertes

1. Aller dans **Configuration** > **Actions** > **Trigger actions**
2. Créer une action pour les alertes cluster:
   - Name: "HA Cluster Alert"
   - Conditions: 
     - Trigger name contains "Cluster"
     - Trigger name contains "Nginx"
     - Trigger name contains "Samba"
   - Operations: Send message to Admin

### 6. Captures d'écran à Réaliser

Pour le rendu, capturer:

1. **Dashboard principal** montrant:
   - CPU/RAM des deux nœuds
   - État des services (vert = OK)
   - Aucune alerte active

2. **Vue Problems** montrant:
   - Pas de problèmes = cluster sain

3. **Page Hosts** montrant:
   - node01 et node02 avec statut "Enabled"
   - Icône verte = agent accessible

4. **Test de failover**:
   - Capturer avant/après l'arrêt d'un nœud
   - Montrer la bascule des services

## Métriques Surveillées

| Métrique | Description | Seuil d'alerte |
|----------|-------------|----------------|
| cluster.status | État du cluster | = 0 (DOWN) |
| cluster.nodes.online | Nœuds en ligne | < 2 |
| nginx.status | Service Nginx | = 0 (DOWN) |
| nginx.http.check | Site accessible | = 0 (INACCESSIBLE) |
| nginx.response.time | Temps de réponse | > 5000ms |
| samba.status | Service Samba | = 0 (DOWN) |
| CPU utilization | Utilisation CPU | > 90% |
| Memory utilization | Utilisation RAM | > 90% |

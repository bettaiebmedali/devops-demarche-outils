# Lab Vagrant

## Objectifs du Lab
- Installer Vagrant et VirtualBox (ou tout autre provider de machines virtuelles)
- Créer une machine virtuelle simple avec Vagrant
- Gérer la machine virtuelle avec les commandes de base Vagrant
- Configurer une machine virtuelle via le Vagrantfile
- Provisions de base (ex. : installation de packages via shell script)

## Prérequis
- Avoir Vagrant installé
- Avoir VirtualBox installé

## Étapes du Lab

### 1. Initialisation d'un projet Vagrant
```bash
mkdir vagrant-lab && cd vagrant-lab
vagrant init
```

Modifier le fichier **Vagrantfile** :
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
end
```

### 2. Démarrer la machine virtuelle
```bash
vagrant up
vagrant status
vagrant ssh
```

### 3. Arrêter, redémarrer et détruire la machine
```bash
vagrant halt
vagrant up
vagrant destroy
```

### 4. Provisioning avec un script shell
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -y nginx
  SHELL
end
```

```bash
vagrant up --provision
vagrant ssh
sudo systemctl status nginx
```

### 5. Partage de répertoires
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.synced_folder "./data", "/vagrant_data"
end
```

```bash
mkdir data
vagrant up
vagrant ssh
ls /vagrant_data
```

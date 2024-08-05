#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Update the system
sudo apt update -y && sudo apt upgrade -y

# Install Ansible 
sudo apt install ansible -y

# Install Java
sudo apt install openjdk-11-jdk -y

# Install Jenkins 
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
sudo systemctl enable jenkins 
sudo systemctl start jenkins

# Install AWS-CLI
sudo apt install python3-pip -y
sudo snap install aws-cli --classic

# Install Docker 
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

# Install Kubernetes using Native Package Manager 
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl

echo "All installations completed."
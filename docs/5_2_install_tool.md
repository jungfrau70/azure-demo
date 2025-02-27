
## **1. Jumpbox에서 설치**

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

sudo apt-get update && sudo apt-get install -y ca-certificates curl
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

sudo snap install docker
sudo groupadd docker
sudo usermod -aG docker $USER


```



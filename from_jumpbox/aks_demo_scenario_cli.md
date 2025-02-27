# Azure Kubernetes Service(AKS) 데모 실습 (업데이트된 구성)

---

## **구성 범위**
- **네트워크:** VNet, Subnet (Hub & Spoke)
- **AKS 배포:** Private Cluster + ACR 연동
- **스토리지:** Azure Files (PVC)
- **모니터링:** Azure Monitor (Log Analytics, Managed Prometheus, Grafana)
- **트래픽 관리:** Application Gateway, Ingress Nginx Gateway
- **보안 및 정책:** Azure Policy 적용
- **배포:** Application Deployment (Helm 활용 가능)
- **CI/CD 연계:** Azure DevOps 또는 GitHub Actions (선택 사항)

---

## **1. 네트워크 구성 (Hub & Spoke)**
### **1.1 VNet 및 서브넷 생성**
```sh
RESOURCE_GROUP="aks-demo-rg"
LOCATION="koreacentral"
HUB_VNET="hub-vnet"
SPOKE_VNET="spoke-vnet"
HUB_SUBNET="hub-subnet"
SPOKE_SUBNET="spoke-subnet"

# 리소스 그룹 생성
az group create --name $RESOURCE_GROUP --location $LOCATION

# Hub VNet 생성
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name $HUB_VNET \
    --address-prefixes 10.0.0.0/16 \
    --subnet-name $HUB_SUBNET \
    --subnet-prefix 10.0.1.0/24

# Spoke VNet 생성
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name $SPOKE_VNET \
    --address-prefixes 10.1.0.0/16 \
    --subnet-name $SPOKE_SUBNET \
    --subnet-prefix 10.1.1.0/24

# VNet 피어링 설정
az network vnet peering create \
    --resource-group $RESOURCE_GROUP \
    --name HubToSpoke \
    --vnet-name $HUB_VNET \
    --remote-vnet $SPOKE_VNET \
    --allow-vnet-access

az network vnet peering create \
    --resource-group $RESOURCE_GROUP \
    --name SpokeToHub \
    --vnet-name $SPOKE_VNET \
    --remote-vnet $HUB_VNET \
    --allow-vnet-access
```

---

## **2. AKS 배포 (Private Cluster)**
### **2.1 JumpBox (Bastion) 설정**
```sh
# JumpBox VM 생성
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name JumpBox \
    --image UbuntuLTS \
    --vnet-name $HUB_VNET \
    --subnet $HUB_SUBNET \
    --admin-username azureuser \
    --generate-ssh-keys

# Bastion 서비스 생성
az network bastion create \
    --resource-group $RESOURCE_GROUP \
    --name MyBastion \
    --vnet-name $HUB_VNET \
    --public-ip-address BastionPublicIP
```

### **2.2 Private AKS 클러스터 배포**
```sh
AKS_NAME="myaks-cluster"
ACR_NAME="myaksacr"

# ACR 생성
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Premium --admin-enabled true

# AKS 클러스터 생성 (Azure CNI Overlay 적용)
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_NAME \
    --enable-managed-identity \
    --node-count 3 \
    --network-plugin azure \
    --enable-cni-overlay \
    --vnet-subnet-id "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/virtualNetworks/$SPOKE_VNET/subnets/$SPOKE_SUBNET" \
    --enable-private-cluster \
    --enable-aad \
    --enable-addons monitoring \
    --attach-acr $ACR_NAME
```

---

## **3. 모니터링 및 로깅**
```sh
# Managed Prometheus 및 Grafana 활성화
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_NAME \
    --enable-managed-prometheus \
    --enable-grafana
```

---

## **4. 트래픽 관리 (Ingress 및 Application Gateway)**
```sh
# Application Gateway 생성
az network application-gateway create \
    --resource-group $RESOURCE_GROUP \
    --name myAppGateway \
    --sku Standard_v2

# Ingress Controller 배포
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install my-ingress ingress-nginx/ingress-nginx
```

---

## **5. 스토리지 구성 (Azure Files PVC)**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurefile-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurefile-csi
  resources:
    requests:
      storage: 10Gi
```

---


## **6. 데모용 애플리케이션 배포**
```yaml
# 웹 애플리케이션 (Sticky Session 및 Pod IP 표시)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: myaksacr.azurecr.io/webapp:latest
        ports:
        - containerPort: 80
        env:
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  selector:
    app: webapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-ingress
spec:
  rules:
  - host: webapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: webapp-service
            port:
              number: 80
```
---


## **7. 보안 강화 예제 및 적용/제거 방법**
```sh
# 네트워크 정책 적용 (Ingress 제한)
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-external
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: webapp
  policyTypes:
  - Ingress
  ingress: []
EOF

```
---

## **8. Azure Policy 적용 (보안 강화)**
```sh
az policy assignment create --policy "Deny-Public-IP" --scope "/subscriptions/<SUBSCRIPTION_ID>"
```

## **9. Azure Policy 예제 (특정 VM 크기 제한)**
```sh
az policy definition create --name "Limit-VM-SKU" --rules policy.json --mode All
az policy assignment create --policy "Limit-VM-SKU" --scope "/subscriptions/<SUBSCRIPTION_ID>"
```

---

## **10. GitHub Actions 기반 CI/CD 연계**
```yaml
name: AKS Deployment
on:
  push:
    branches:
      - main
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3
      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - name: Set Kubernetes Context
        run: az aks get-credentials --resource-group aks-demo-rg --name myaks-cluster --overwrite-existing
      - name: Deploy Application
        run: kubectl apply -f webapp-deployment.yaml
```

---

---

## **11. 자원 정리 (클린업)**
```sh
az group delete --name $RESOURCE_GROUP --yes --no-wait
```


######################################################################################################################################
---

## **Terraform 기반 인프라 배포**
```hcl
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "aks_demo" {
  name     = "aks-demo-rg"
  location = "koreacentral"
}
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "myaks-cluster"
  location            = azurerm_resource_group.aks_demo.location
  resource_group_name = azurerm_resource_group.aks_demo.name
  dns_prefix          = "myaks"
  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
}
```


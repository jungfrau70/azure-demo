## **Private AKS + Cloud Shell + Operator 시나리오**  

관리자가 **Private AKS 클러스터를 생성**하고, 
오퍼레이터가 **Cloud Shell을 사용하여 AKS 상태를 점검**하는 시나리오


## **1️⃣ Private AKS 클러스터 생성**  

### **🔹 ① VNet 및 서브넷 생성 (Private AKS용)**
```bash
# 변수 설정
RESOURCE_GROUP="rg-spoke2"
VNET_NAME="vnet-spoke2"
AKS_SUBNET_NAME="snet-aks-private"
AKS_CLUSTER_NAME="myPrivateAKSCluster"
LOCATION="koreacentral"

1. **리소스 그룹 생성**
   ```bash
   az group create --name $RESOURCE_GROUP --location $LOCATION
   ```

2. **VNet 및 서브넷 생성**
    ```bash
    az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name $VNET_NAME \
    --address-prefixes 10.1.0.0/16 \
    --subnet-name $AKS_SUBNET_NAME \
    --subnet-prefix 10.1.1.0/24
    ```

    ```bash
    az network vnet list --output table
    az network vnet subnet delete --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $AKS_SUBNET_NAME
    az network vnet delete --resource-group $RESOURCE_GROUP --name $VNET_NAME
    ```
   
3. **Private AKS 클러스터 생성**    
    ```bash
    VNET_SUBNET_ID=$(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $AKS_SUBNET_NAME --query id --output tsv)   

    az aks create \
        --resource-group $RESOURCE_GROUP \
        --name $AKS_CLUSTER_NAME \
        --node-count 3 \
        --network-plugin azure \
        --vnet-subnet-id $VNET_SUBNET_ID \
        --enable-private-cluster \
        --enable-managed-identity \
        --generate-ssh-keys
    ```

✅ **이제 AKS는 Private 환경에서만 접근 가능해.**

---

### **🔹 ③ Private AKS에 연결을 위한 Jumpbox VM 생성**  
Cloud Shell에서는 Private AKS에 직접 접근할 수 없기 때문에, **Jumpbox VM을 만들어 Cloud Shell에서 SSH 접속 후 AKS 작업을 수행**해야 해.  

```bash
# Jumpbox VM을 위한 서브넷 생성
JUMPBOX_SUBNET_NAME="jumpboxSubnet"
az network vnet subnet create \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $VNET_NAME \
    --name $JUMPBOX_SUBNET_NAME \
    --address-prefix 10.0.2.0/24

# Jumpbox VM 생성
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name JumpboxVM \
    --image UbuntuLTS \
    --vnet-name $VNET_NAME \
    --subnet $JUMPBOX_SUBNET_NAME \
    --admin-username azureuser \
    --generate-ssh-keys
```

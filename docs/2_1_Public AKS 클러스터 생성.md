## **Public AKS + Cloud Shell + Operator 시나리오**  

관리자가 **Public AKS 클러스터를 생성**하고, 
오퍼레이터가 **Cloud Shell을 사용하여 AKS 상태를 점검**하는 시나리오

---

### **1️⃣ 관리자: Public AKS 클러스터 생성**
**📌 목표:**  
- 관리자가 Public AKS 클러스터를 구성  
- RBAC 설정을 통해 오퍼레이터 권한 부여  

# 변수 설정

SUBSCRIPTION_ID=$(az account show --query id --output tsv)
az account set --subscription $SUBSCRIPTION_ID
LOCATION="koreacentral"

RESOURCE_GROUP_1="rg-spoke1"
VNET_NAME_1="vnet-spoke1"
AKS_SUBNET_NAME_1="snet-aks-private"
AKS_CLUSTER_NAME_1="public-aks"

RESOURCE_GROUP_2="rg-spoke2"
VNET_NAME_2="vnet-spoke2"
AKS_SUBNET_NAME_2="snet-aks-private"
AKS_CLUSTER_NAME_2="myaks"


1. **리소스 그룹 생성**
    ```bash
    az group create --name $RESOURCE_GROUP_1 --location $LOCATION
    ```

2. **VNet 및 서브넷 생성**
    ```bash
    az network vnet create \
    --resource-group $RESOURCE_GROUP_1 \
    --name $VNET_NAME_1 \
    --address-prefixes 10.2.0.0/16 \
    --subnet-name $AKS_SUBNET_NAME_1 \
    --subnet-prefix 10.2.1.0/24
    ```


<!-- 2. **SSH 키를 직접 생성**  
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/public_aks_ssh_key -N ""
   --ssh-key-value ~/.ssh/public_aks_ssh_key.pub   
   ``` -->

3. **Public AKS 클러스터 생성**  
   ```bash
    VNET_SUBNET_ID_1=$(az network vnet subnet show --resource-group $RESOURCE_GROUP_1 --vnet-name $VNET_NAME_1 --name $AKS_SUBNET_NAME_1 --query id --output tsv)   

    az aks create \
    --resource-group $RESOURCE_GROUP_1 \
    --vnet-subnet-id $VNET_SUBNET_ID_1 \
    --name $AKS_CLUSTER_NAME_1 \
    --node-count 2 \
    --generate-ssh-keys

   ```

# az aks delete --resource-group $RESOURCE_GROUP_1 --name $AKS_CLUSTER_NAME_1 --yes --no-wait

###
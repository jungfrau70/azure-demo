## **Private AKS + Cloud Shell + Operator 시나리오**  

관리자가 **Private AKS 클러스터를 생성**하고, 
오퍼레이터가 **Cloud Shell을 사용하여 AKS 상태를 점검**하는 시나리오


## **1️⃣ Private AKS 클러스터 생성**  

### **🔹 ① VNet 및 서브넷 생성 (Private AKS용)**
```bash

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
    az group create --name $RESOURCE_GROUP_2 --location $LOCATION
    ```

2. **VNet 및 서브넷 생성**
    ```bash
    az network vnet create \
    --resource-group $RESOURCE_GROUP_2 \
    --name $VNET_NAME_2 \
    --address-prefixes 10.3.0.0/16 \
    --subnet-name $AKS_SUBNET_NAME_2 \
    --subnet-prefix 10.3.1.0/24
    ```

    # ```bash
    # az network vnet list --output table
    # az network vnet subnet delete --resource-group $RESOURCE_GROUP_2 --vnet-name $VNET_NAME_2 --name $AKS_SUBNET_NAME_2
    # az network vnet delete --resource-group $RESOURCE_GROUP --name $VNET_NAME
    # ```
   
3. **Private AKS 클러스터 생성**    
    ```bash
    VNET_SUBNET_ID_2=$(az network vnet subnet show --resource-group $RESOURCE_GROUP_2 --vnet-name $VNET_NAME_2 --name $AKS_SUBNET_NAME_2 --query id --output tsv)   

    az aks create \
        --resource-group $RESOURCE_GROUP_2 \
        --name $AKS_CLUSTER_NAME_2 \
        --node-count 3 \
        --network-plugin azure \
        --vnet-subnet-id $VNET_SUBNET_ID_2 \
        --enable-private-cluster \
        --private-dns-zone "System" \
        --enable-managed-identity \
        --generate-ssh-keys
    ```


# az aks delete --resource-group $RESOURCE_GROUP_2 --name $AKS_CLUSTER_NAME_2 --yes --no-wait

---


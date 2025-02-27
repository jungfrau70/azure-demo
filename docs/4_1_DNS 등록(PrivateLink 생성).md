**Azure Cloud Shell이 인터넷을 거치지 않고 Private Endpoint를 통해 Private AKS API 서버에 직접 연결**  
즉, **Cloud Shell에서 kubectl을 실행하여 Private AKS 클러스터를 관리**


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

PRIVATE_DNS_LINK_NAME="aksprivatednslink"
PRIVATE_ENDPOINT_NAME="aksprivatednslink"
PRIVATE_CONNECTION_NAME="aks-private-connection"

---

## **🔹 ③ Private DNS Zone 구성**

Private Link를 사용하면, **Cloud Shell이 올바른 Private Endpoint를 찾도록 Private DNS를 설정**해야 해.  

즉, "privatelink.koreacentral.azmk8s.io"라는 이름의 Private DNS Zone을 생성하는 명령어입니다.
privatelink 자체를 생성하는 것이 아니라, AKS의 Private Link를 위한 DNS 영역을 설정하는 것입니다.

```bash
# Private DNS Zone 생성
az network private-dns zone create \
    --resource-group $RESOURCE_GROUP_2 \
    --name "privatelink.$LOCATION.azmk8s.io"


# Private DNS Zone과 VNet 연결
az network private-dns link vnet create \
    --resource-group $RESOURCE_GROUP_2 \
    --zone-name "privatelink.$LOCATION.azmk8s.io" \
    --name $PRIVATE_DNS_LINK_NAME \
    --virtual-network $VNET_NAME_2 \
    --registration-enabled true

az network private-dns link vnet show \
    --resource-group $RESOURCE_GROUP_2 \
    --zone-name "privatelink.$LOCATION.azmk8s.io" \
    --name $PRIVATE_DNS_LINK_NAME


# Private DNS Zone과 VNet 연결 삭제
# az network private-dns link vnet delete \
#     --resource-group $RESOURCE_GROUP_2 \
#     --zone-name "privatelink.$LOCATION.azmk8s.io" \
#     --name $PRIVATE_DNS_LINK_NAME

# AKS 리소스 ID 확인
RESOURCE_ID=$(az aks show \
    --resource-group $RESOURCE_GROUP_2 \
    --name $AKS_CLUSTER_NAME_2 \
    --query "id" \
    --output tsv)

echo "RESOURCE_ID: $RESOURCE_ID"

# Group ID 확인
GROUP_IDS=$(az network private-link-resource list \
    --resource-group $RESOURCE_GROUP_2 \
    --name $AKS_CLUSTER_NAME_2 \
    --type Microsoft.KubernetesConfiguration/privateLinkScopes \
    --query "[].groupId" \
    --output tsv)

echo "GROUP_IDS: $GROUP_IDS"


# Private Endpoint 생성

SUBSCRIPTION_ID=$(az account show --query id --output tsv)
az account set --subscription $SUBSCRIPTION_ID
LOCATION="koreacentral"

RESOURCE_GROUP_1="rg-spoke1"
VNET_NAME_1="vnet-spoke1"
AKS_CLUSTER_NAME_1="public-aks"

RESOURCE_GROUP_2="rg-spoke2"
VNET_NAME_2="vnet-spoke2"
AKS_SUBNET_NAME="snet-aks-private"
AKS_CLUSTER_NAME_2="myaks"

PRIVATE_DNS_LINK_NAME="aksprivatednslink"
PRIVATE_ENDPOINT_NAME="aksprivatednslink"
PRIVATE_CONNECTION_NAME="aks-private-connection"

PRIVATE_CONNECTION_RESOURCE_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_2/providers/Microsoft.ContainerService/managedClusters/$AKS_CLUSTER_NAME_2"

echo "PRIVATE_CONNECTION_RESOURCE_ID: $PRIVATE_CONNECTION_RESOURCE_ID"

az network private-endpoint create \
    --resource-group $RESOURCE_GROUP_2 \
    --name $PRIVATE_ENDPOINT_NAME \
    --vnet-name $VNET_NAME_2 \
    --subnet $AKS_SUBNET_NAME \
    --private-connection-resource-id $PRIVATE_CONNECTION_RESOURCE_ID \
    --group-id "management" \
    --connection-name $PRIVATE_CONNECTION_NAME


az network private-endpoint show \
    --resource-group $RESOURCE_GROUP_2 \
    --name $PRIVATE_ENDPOINT_NAME \
    --query "customNetworkInterface.ipConfigurations[0].privateIpAddress" \
    --output tsv

az network private-endpoint show \
    --resource-group $RESOURCE_GROUP_2 \
    --name $PRIVATE_ENDPOINT_NAME \
    --output tsv

PRIVATE_IP=$(az network private-endpoint show 
    --resource-group $RESOURCE_GROUP_2 \
    --name $PRIVATE_ENDPOINT_NAME \
    --query "customNetworkInterface.ipConfigurations[0].privateIpAddress" \
    --output tsv)

echo "PRIVATE_IP: $PRIVATE_IP"

PRIVATE_IP=10.3.1.92
az network private-dns record-set a add-record \
    --resource-group $RESOURCE_GROUP_2 \
    --zone-name "privatelink.$LOCATION.azmk8s.io" \
    --record-set-name "$AKS_CLUSTER_NAME_2" \
    --ipv4-address $PRIVATE_IP


az network private-endpoint update \
    --resource-group $RESOURCE_GROUP_2 \
    --name $PRIVATE_ENDPOINT_NAME \
    --set privateLinkServiceConnectionState.status=Approved


```

az network private-dns record-set a list \
    --resource-group $RESOURCE_GROUP_2 \
    --zone-name "privatelink.$LOCATION.azmk8s.io" 


## **2️⃣ Private DNS Zone 확인**  
```bash
az network private-dns zone list --resource-group $RESOURCE_GROUP_2 --output table
```


## **4️⃣ Private DNS Zone과 VNet 연결 확인**  
```bash
az network private-dns link vnet list --resource-group $RESOURCE_GROUP_2 --zone-name "privatelink.$LOCATION.azmk8s.io" --output table
```

## **5️⃣ Private DNS Zone과 AKS 연결 확인**
az network private-dns record-set a list \
    --resource-group $RESOURCE_GROUP_2 \
    --zone-name "privatelink.$LOCATION.azmk8s.io" \
    --output table



**AKS 자격 증명 가져오기**
```bash
az aks get-credentials --resource-group $RESOURCE_GROUP_1 --name $AKS_CLUSTER_NAME_1
az aks get-credentials --resource-group $RESOURCE_GROUP_2 --name $AKS_CLUSTER_NAME_2

```

**Kubernetes 상태 확인**
이제, kubectl 명령어로 접근 가능

```bash
kubectl get nodes
kubectl get pods -A
```



############################################################################


위 명령어에서:
- `--connection-name $PRIVATE_CONNECTION_NAME` → Private Endpoint와 AKS 간의 연결 이름

즉, AKS Private API에 대한 Private Endpoint를 만들 때 필수적으로 사용됩니다.

---

### **4️⃣ Private Connection 확인 방법**
이미 만들어진 Private Endpoint의 연결을 확인하려면 아래 명령어를 실행하세요.

```bash
az network private-endpoint-connection list \
    --resource-group $RESOURCE_GROUP_2 \
    --output table
```

💡 **출력 예시**
```
Name                        PrivateLinkService ConnectionState
--------------------------  ---------------------------------
aks-private-connection      Approved
```
- **`Name`**: `PRIVATE_CONNECTION_NAME` 값  
- **`ConnectionState`**: `"Approved"` 상태인지 확인 (Pending 상태면 승인 필요)

---

### **🔍 요약**
✔ `$PRIVATE_CONNECTION_NAME` = Private Endpoint와 AKS를 연결하는 **고유한 이름**  
✔ 일반적으로 `"aks-private-connection"` 같은 이름을 사용  
✔ Private Endpoint 생성 시 `--connection-name` 옵션에서 사용  
✔ `az network private-endpoint-connection list` 로 확인 가능  

추가 질문 있으면 알려주세요! 🚀
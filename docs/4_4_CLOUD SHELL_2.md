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
AKS_CLUSTER_NAME_2="private-aks"


# 각 그룹의 Object ID 가져오기
OPERATOR_GROUP_OBJECT_ID=$(az ad group show --group aks-operators --query id --output tsv)
ADMIN_GROUP_OBJECT_ID=$(az ad group show --group aks-admins --query id --output tsv)
CLUSTER_ADMIN_GROUP_OBJECT_ID=$(az ad group show --group aks-cluster-admins --query id --output tsv)
DEVELOPER_GROUP_OBJECT_ID=$(az ad group show --group aks-developers --query id --output tsv)

# 각 사용자의 Object ID 가져오기
OPERATOR_OBJECT_ID=$(az ad user show --id operator@jupyteronlinegmail.onmicrosoft.com --query id --output tsv)
ADMIN_OBJECT_ID=$(az ad user show --id admin@jupyteronlinegmail.onmicrosoft.com --query id --output tsv)
CLUSTER_ADMIN_OBJECT_ID=$(az ad user show --id clusteradmin@jupyteronlinegmail.onmicrosoft.com --query id --output tsv)
DEVELOPER_OBJECT_ID=$(az ad user show --id developer@jupyteronlinegmail.onmicrosoft.com --query id --output tsv)


✅ **이제 Cloud Shell이 AKS API 서버의 Private Endpoint를 찾을 수 있음!**  

---

## **🔹 ④ Cloud Shell에서 Private Link를 사용하여 AKS API 서버 접근**
이제 Cloud Shell에서 AKS API 서버에 연결하고 `kubectl`을 실행할 수 있음!  

### **✅ Cloud Shell에서 AKS API 서버 연결**
```bash
# AKS 자격 증명 가져오기
az aks get-credentials --resource-group $RESOURCE_GROUP_2 --name $AKS_CLUSTER_NAME_2  --overwrite-existing

# Kubernetes 상태 확인
kubectl get nodes
kubectl get pods -A
```
✅ **Cloud Shell에서 Jumpbox 없이 Private Link를 통해 Private AKS API 서버에 직접 접근 가능!**  

---

## **📌 정리: Private Link로 Cloud Shell에서 Private AKS 관리하기**
| 단계 | 작업 내용 |
|------|----------|
| **① Private AKS 클러스터 배포** | Private Endpoint를 통해서만 접근 가능하도록 설정 |
| **② Private Endpoint 생성** | AKS API 서버를 위한 Private Link Endpoint 생성 |
| **③ Private DNS 설정** | Cloud Shell이 Private Endpoint를 찾을 수 있도록 구성 |
| **④ Cloud Shell에서 `kubectl` 실행** | Jumpbox 없이 Private Link를 통해 Kubernetes 관리 가능! |

✅ **이제 Cloud Shell에서 인터넷을 거치지 않고 Private AKS를 안전하게 관리할 수 있음!** 🚀  
추가 질문 있으면 말해줘!
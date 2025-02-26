오퍼레이터, 관리자, 클러스터 관리자가 공유할 **공유 스토리지**

SUBSCRIPTION_ID=$(az account show --query id --output tsv)
az account set --subscription $SUBSCRIPTION_ID
LOCATION="koreacentral"

STORAGE_ACCOUNT_NAME=akscloudshellstorage
RESOURCE_GROUP=rg-aks-cloudshell
LOCATION=koreacentral

OPERATOR_GROUP="aks-operators"
ADMIN_GROUP="aks-admins"
CLUSTER_MANAGER_GROUP="aks-cluster-managers"
DEVELOPERS_GROUP="aks-developers"

STORAGE_ACCOUNT_NAME=akscloudshellstorage
FILE_SHARE_NAME=aks-quickshell-share
MOUNT_POINT=~/quickshell
STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --query [0].value --output tsv)

RESOURCE_GROUP=rg-aks-cloudshell
LOCATION=koreacentral

echo "🔹 스토리지 계정 이름: $STORAGE_ACCOUNT_NAME"
echo "🔹 공유 폴더 이름: $FILE_SHARE_NAME"
echo "🔹 마운트 포인트: $MOUNT_POINT"
echo "🔹 스토리지 키: $STORAGE_KEY"

---

## **4. Azure Cloud Shell에서 공유 스토리지 마운트**


### **4.1 기본적으로 Storage Account를 Cloud Shell에 연결**
```sh
az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP
```
이후, Cloud Shell의 기본 스토리지가 자동으로 연결됩니다.

###

az storage account update --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --enable-files-aadds true

az cloud-shell create --storage-account $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP


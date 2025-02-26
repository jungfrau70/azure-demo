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


### **🔹 공유 폴더 내용 확인**  
```bash
STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --query [0].value --output tsv)

az storage file list \
    --share-name $FILE_SHARE_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $STORAGE_KEY \
    --output table
```


### **4.3 스크립트 다운로드 및 실행**
```bash
cat <<EOF > ~/aks_archi_checklist.sh
#!/bin/bash

# 변수 설정
STORAGE_ACCOUNT_NAME="akscloudshellstorage"
FILE_SHARE_NAME="aks-quickshell-share"

STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --resource-group rg-aks-cloudshell --query [0].value --output tsv)

# 파일 다운로드
az storage file download \
    --share-name $FILE_SHARE_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $STORAGE_KEY \
    --path aks_archi_checklist.sh \
    --dest ./aks_archi_checklist.sh

# 스크립트 실행
bash mkdir -p $MOUNT_POINT
bash mount -t cifs //$STORAGE_ACCOUNT_NAME.file.core.windows.net/$FILE_SHARE_NAME $MOUNT_POINT -o vers=3.0,username=$STORAGE_ACCOUNT_NAME,password=$STORAGE_KEY,dir_mode=0777,file_mode=0777,sec=ntlmssp
bash ./aks_archi_checklist.sh

EOF

chmod +x ~/aks_archi_checklist.sh




오퍼레이터, 관리자, 클러스터 관리자가 공유할 **공유 스토리지**

**Azure Cloud Shell**에서 사용하도록 **Azure Storage Account**와 **파일 공유(Azure Files)** 로 구성  


---

## **구성 목표**
1. **Azure Storage Account** 생성  
2. **Azure Files (SMB/NFS 공유 폴더) 생성**  
3. **Azure AD 기반의 RBAC 권한 할당** (오퍼레이터, 관리자, 클러스터 관리자)  
4. **Azure Cloud Shell에서 공유 스토리지 마운트**  

---

## **1. Azure Storage Account 생성**
```sh
STORAGE_ACCOUNT_NAME=akscloudshellstorage
RESOURCE_GROUP=rg-aks-cloudshell
LOCATION=koreacentral

az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 
```
- `Standard_LRS`: 기본적인 지역 복제 저장소 사용  
- `StorageV2`: 최신 스토리지 종류  


---

## **2. Azure Files 공유 폴더 생성**
```sh
FILE_SHARE_NAME=aks-shared-scripts
az storage share-rm create \
  --storage-account $STORAGE_ACCOUNT_NAME \
  --name $FILE_SHARE_NAME \
  --quota 100
```
- `--quota 100`: 100GB 크기의 공유 폴더 생성  

---

## **3. Azure AD 기반 RBAC 권한 할당**
Azure AD 그룹을 생성하고, 이를 Azure Files에 연결하여 역할 기반 접근 제어(RBAC)를 설정할 수 있습니다.

### **3.1 오퍼레이터, 관리자 외 그룹 생성**
```sh
OPERATOR_GROUP="aks-operators"
ADMIN_GROUP="aks-admins"
CLUSTER_MANAGER_GROUP="aks-cluster-managers"
DEVELOPERS_GROUP="aks-developers"


```

### **3.2 스토리지 권한 부여**
Azure Files에 대한 `Storage File Data SMB Share Contributor` 역할을 할당하여 사용자가 읽기/쓰기/삭제가 가능하도록 설정합니다.

```sh
az role assignment create \
  --assignee "<OPERATOR_AZURE_AD_OBJECT_ID>" \
  --role "Storage File Data SMB Share Contributor" \
  --scope "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME"

az role assignment create \
  --assignee "<ADMIN_AZURE_AD_OBJECT_ID>" \
  --role "Storage File Data SMB Share Contributor" \
  --scope "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME"

az role assignment create \
  --assignee "<CLUSTER_MANAGER_AZURE_AD_OBJECT_ID>" \
  --role "Storage File Data SMB Share Contributor" \
  --scope "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME"
```

> **참고:** `Storage File Data SMB Share Contributor` 역할은 Azure Files를 사용할 때 필요하며, 개별 사용자 또는 그룹의 **Azure AD Object ID**를 설정해야 합니다.

---

## **4. Azure Cloud Shell에서 공유 스토리지 마운트**
Azure Cloud Shell에서 공유 스토리지를 마운트하는 방법은 두 가지가 있습니다.  

### **4.1 기본적으로 Storage Account를 Cloud Shell에 연결**
```sh
az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP
```
이후, Cloud Shell의 기본 스토리지가 자동으로 연결됩니다.

### **4.2 수동으로 SMB/NFS 마운트**
Azure Cloud Shell에서는 **SMB 프로토콜**을 통해 파일 공유를 마운트할 수 있습니다.

#### **4.2.1 SMB 마운트 (Linux)**
```sh
sudo mkdir /mnt/aks-shared
sudo mount -t cifs //<STORAGE_ACCOUNT_NAME>.file.core.windows.net/$FILE_SHARE_NAME /mnt/aks-shared \
  -o vers=3.0,username=<STORAGE_ACCOUNT_NAME>,password=<STORAGE_KEY>,dir_mode=0777,file_mode=0777,sec=ntlmssp
```
- `<STORAGE_ACCOUNT_NAME>`: Azure Storage Account 이름  
- `<STORAGE_KEY>`: Storage Account의 Access Key (보안 필요)  

#### **4.2.2 NFS 마운트**
Azure Files에서 NFS를 활성화한 경우 다음 명령어를 실행합니다.
```sh
sudo mkdir /mnt/aks-shared
sudo mount -t nfs <STORAGE_ACCOUNT_NAME>.file.core.windows.net:/$FILE_SHARE_NAME /mnt/aks-shared
```

---

## **5. 사용 예시**
Cloud Shell에서 공유 폴더에 접근하고 파일을 생성하는 예제입니다.

```sh
cd /mnt/aks-shared
echo "AKS 공유 폴더 테스트" > test.txt
cat test.txt
```
> 모든 사용자가 `/mnt/aks-shared`에서 공유된 파일을 확인할 수 있습니다.

---

## **정리**
✅ **Storage Account** 및 **Azure Files**를 생성  
✅ **Azure AD RBAC 역할을 활용하여 사용자 그룹에 권한 할당**  
✅ **Azure Cloud Shell에서 공유 스토리지 마운트**  

이제 오퍼레이터, 관리자, 클러스터 관리자는 Cloud Shell에서 공유 폴더를 사용하여 파일을 공유하고 협업할 수 있습니다!
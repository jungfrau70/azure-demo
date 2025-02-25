#!/bin/bash

# 환경 변수 로드
export $(grep -v '^#' .env | xargs)

# 로그 파일 초기화
echo "Azure 환경 구성 시작: $(date)" > $LOG_FILE

# Azure 로그인 확인
az account show &> /dev/null
if [ $? -ne 0 ]; then
    echo "Azure CLI 로그인이 필요합니다." | tee -a $LOG_FILE
    exit 1
fi

# 1. 리소스 그룹 생성
echo "리소스 그룹 생성: $RESOURCE_GROUP" | tee -a $LOG_FILE
az group create --name $RESOURCE_GROUP --location $LOCATION --output none

# 2. Key Vault 사용 가능 여부 확인
KEYVAULT_EXISTS=$(az keyvault show --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP --query "name" -o tsv 2>/dev/null)
if [ "$KEYVAULT_EXISTS" == "$KEYVAULT_NAME" ]; then
    echo "Key Vault 사용 가능: $KEYVAULT_NAME" | tee -a $LOG_FILE
    USE_KEYVAULT=true
else
    echo "Key Vault를 사용할 수 없음. .env 파일의 값 사용" | tee -a $LOG_FILE
    USE_KEYVAULT=false
fi

# 3. 스토리지 계정 및 컨테이너 생성
echo "스토리지 계정 생성: $STORAGE_ACCOUNT" | tee -a $LOG_FILE
az storage account create --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS --output none

# 4. 스토리지 키 또는 Key Vault에서 비밀 가져오기
if [ "$USE_KEYVAULT" = true ]; then
    echo "Key Vault에서 스토리지 키 가져오기" | tee -a $LOG_FILE
    STORAGE_KEY=$(az keyvault secret show --vault-name $KEYVAULT_NAME --name "StorageKey" --query "value" -o tsv)
else
    echo "스토리지 키 직접 가져오기" | tee -a $LOG_FILE
    STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT --query "[0].value" -o tsv)
fi

# 5. Blob 컨테이너 생성
echo "Blob 컨테이너 생성: $CONTAINER_NAME" | tee -a $LOG_FILE
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT --account-key $STORAGE_KEY --output none

# 6. RBAC 역할 할당
echo "관리자에게 Storage Blob Data Contributor 권한 부여" | tee -a $LOG_FILE
az role assignment create --assignee $ADMIN_PRINCIPAL_ID --role "Storage Blob Data Contributor" --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT" --output none

echo "사용자에게 Storage Blob Data Reader 권한 부여" | tee -a $LOG_FILE
az role assignment create --assignee $USER_PRINCIPAL_ID --role "Storage Blob Data Reader" --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT" --output none

# 7. 스크립트 업로드 (관리자만 수행)
SCRIPT_NAME="check_script.sh"
echo "스크립트 업로드: $SCRIPT_NAME" | tee -a $LOG_FILE
az storage blob upload --container-name $CONTAINER_NAME --file $SCRIPT_NAME --name $SCRIPT_NAME --account-name $STORAGE_ACCOUNT --account-key $STORAGE_KEY --output none

# 8. SAS 토큰 생성 (사용자가 다운로드할 수 있도록)
echo "SAS 토큰 생성" | tee -a $LOG_FILE
SAS_TOKEN=$(az storage blob generate-sas --account-name $STORAGE_ACCOUNT --container-name $CONTAINER_NAME --name $SCRIPT_NAME --permissions r --expiry $(date -u -d "1 year" '+%Y-%m-%dT%H:%MZ') --output tsv --account-key $STORAGE_KEY)

echo "사용자 다운로드 링크: https://$STORAGE_ACCOUNT.blob.core.windows.net/$CONTAINER_NAME/$SCRIPT_NAME?$SAS_TOKEN" | tee -a $LOG_FILE

echo "Azure 환경 구성 완료: $(date)" | tee -a $LOG_FILE

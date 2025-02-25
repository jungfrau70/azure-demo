#!/bin/bash

# .env 파일 로드
export $(grep -v '^#' .env | xargs)

# 스크립트 업로드
az storage blob upload \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER_NAME \
  --file download_and_run.sh \
  --name download_and_run.sh \
  --overwrite
  
# SAS URL 생성
SAS_TOKEN=$(az storage blob generate-sas \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER_NAME \
  --name $BLOB_NAME \
  --permissions r \
  --expiry $(date -u -d "$SAS_EXPIRY_DAYS days" +%Y-%m-%dT%H:%MZ) \
  --https-only \
  --output tsv)

# 최종 다운로드 URL 출력
DOWNLOAD_URL="https://$STORAGE_ACCOUNT.blob.core.windows.net/$CONTAINER_NAME/$BLOB_NAME?$SAS_TOKEN"

echo "✅ 스크립트 다운로드 URL:"
echo $DOWNLOAD_URL

# .env 파일 로드
export $(grep -v '^#' .env | xargs)

# Azure Files 공유 생성 (최초 1회만 실행)
az storage share create \
  --account-name $STORAGE_ACCOUNT \
  --name scripts-share

# 공유 폴더 내 디렉터리 생성 (선택 사항)
az storage directory create \
  --account-name $STORAGE_ACCOUNT \
  --share-name scripts-share \
  --name scripts

# `download_and_run.sh` 업로드
az storage file upload \
  --account-name $STORAGE_ACCOUNT \
  --share-name scripts-share \
  --source download_and_run.sh \
  --path scripts/download_and_run.sh

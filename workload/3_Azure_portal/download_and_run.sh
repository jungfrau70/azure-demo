# Azure Files에서 다운로드
az storage file download \
  --account-name <STORAGE_ACCOUNT> \
  --share-name scripts-share \
  --path scripts/download_and_run.sh \
  --dest download_and_run.sh

# 실행 권한 부여 및 실행
chmod +x download_and_run.sh
./download_and_run.sh

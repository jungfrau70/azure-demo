## Azure 로그인
az login --tenant jupyteronlinegmail.onmicrosoft.com

## Azure 구독 설정
az account set --subscription [subscription-id]
az account show
    
## Azure 홈 테넌트 ID 확인
az account show --query homeTenantId -o tsv

## Azure 환경 변수 설정
export AZURE_HOME_TENANT_ID=$(az account show --query homeTenantId -o tsv)
echo $AZURE_HOME_TENANT_ID  # 환경 변수 확인


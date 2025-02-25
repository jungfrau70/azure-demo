# Azure Hub-Spoke 인프라 배포 가이드

## 1. 사전 준비사항

### 1.1. 필수 도구 설치
- [Azure CLI](https://docs.microsoft.com/ko-kr/cli/azure/install-azure-cli)
- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 이상)
- [Git](https://git-scm.com/downloads)

### 1.2. Azure 로그인
```bash
# Azure CLI 로그인
az login

# 구독 선택 (필요한 경우)
az account set --subscription "구독ID"
```

### 1.3. GitHub Personal Access Token 발급
1. GitHub 계정으로 로그인 후 Settings → Developer settings → Personal access tokens
2. Generate new token (classic) 선택
3. 권한 설정:
   - [x] repo (전체)
   - [x] admin:repo_hook
   - [x] read:packages
   - [x] write:packages
   - [x] delete:packages

## 2. Azure 구독 설정
1. Azure 포털에서 구독 ID 확인
2. .env 파일의 SUBSCRIPTION_ID 값 수정

## 3. GitHub 설정
1. GitHub 계정 생성
2. Personal Access Token 발급:
   - Settings → Developer settings → Personal access tokens
   - Generate new token (classic)
   - 권한 설정:
     - [x] repo (전체)
     - [x] admin:repo_hook
     - [x] read:packages
     - [x] write:packages
     - [x] delete:packages
3. .env 파일의 GITHUB_TOKEN 값 수정

## 4. 환경 변수 설정
1. .env.example 파일을 .env로 복사
2. 필수 값 수정:
   - SUBSCRIPTION_ID
   - GITHUB_TOKEN
   - GITHUB_OWNER
   - GITHUB_REPO

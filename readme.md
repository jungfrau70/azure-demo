# Azure Hub-Spoke 인프라 배포 가이드

## 1. 사전 준비사항
prerequisites.md 참고

## 2. 프로젝트 설정

### 2.1. 환경 설정
1. 프로젝트 구조 생성:
   ```bash
   ./create_terraform_structure.sh
   ```

2. Azure 로그인 및 환경 설정:
   ```bash
   az login
   az account set --subscription $TF_VAR_subscription_id
   ```

3.  SSH 키 생성성:
   ```bash
   # SSH 키 생성
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_aks

   # 공개키 내용 확인
   cat ~/.ssh/id_rsa_aks.pub
   ```

   # 환경변수 파일에 공개키 내용 추가
   export TF_VAR_ssh_public_key="ssh_public_key"


3. 환경 변수 설정:
   # Hub
   terraform-hub\terraform.tfvars
   
   # Spoke
   terraform-spoke\terraform.tfvars


4. AKS node 크기 설정
   # 현재 가용 VM sku 확인
   az vm list-sizes --location koreacentral --output table
   az network private-endpoint list --resource-group rg-spoke-dev -o table
   
   # 크기 설정
   export TF_VAR_aks_node_size="Standard_D8s_v3"

## 3. 디렉토리 구조
```
.
├── terraform-hub/
│   ├── modules/
│   │   ├── network/        # Hub VNet, 서브넷
│   │   ├── monitoring/     # Log Analytics, Prometheus
│   │   └── security/       # Azure Policy
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── terraform-spoke/
│   ├── modules/
│   │   ├── network/        # Spoke VNet, Peering
│   │   ├── aks/           # AKS 클러스터, ACR
│   │   ├── storage/       # Azure Files
│   │   ├── gateway/       # App Gateway, Ingress
│   │   └── application/   # 앱 배포, CI/CD
│   └── environments/
│       └── dev/
│           ├── main.tf
│           ├── variables.tf
│           └── terraform.tfvars
│
├── .env                    # 환경 변수 설정
├── create_terraform_structure.sh
├── init_terraform_env.sh
└── README.md
```

## 4. 배포 순서

### 4.1. Hub 배포 (공통 인프라)
```bash
cd terraform-hub
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

### 4.2. Spoke 배포 (애플리케이션 인프라)
```bash
cd terraform-spoke/environments/dev
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## 5. 리소스 정리
```bash
# Spoke 리소스 삭제
cd terraform-spoke/environments/dev
terraform destroy -auto-approve

# Hub 리소스 삭제
cd ../../terraform-hub
terraform destroy -auto-approve
```

## 6. 로깅
terraform 실행 결과를 로그 파일로 저장:

### 6.1. 로그 파일 구조
```
terraform_logs/
├── terraform_YYYYMMDD_HHMMSS.log    # 전체 실행 로그
├── plan_YYYYMMDD_HHMMSS.log         # Plan 실행 결과
├── plan_detail_YYYYMMDD_HHMMSS.log  # Plan 상세 내용
└── apply_YYYYMMDD_HHMMSS.log        # Apply 실행 결과
```

### 6.2. 로그 생성 방식
```bash
# Hub/Spoke 환경 모두 동일한 스크립트 사용
./terraform.sh
```

### 6.3. 로그 관리 기능
- 타임스탬프 포함된 로그 자동 생성
- 30일 이상 된 로그 자동 정리
- 로그 파일 자동 압축 (gzip)
- Plan/Apply 실행 결과 분리 저장
- 상세 계획 내용 별도 저장

### 6.4. 로그 저장 위치
- Hub 환경: `terraform-hub/terraform_logs/`
- Spoke 환경: `terraform-spoke/environments/dev/terraform_logs/`

### 6.5. 로그 파일 형식
```
# 전체 실행 로그
terraform_YYYYMMDD_HHMMSS.log

# Plan 실행 결과
plan_YYYYMMDD_HHMMSS.log

# Plan 상세 내용
plan_detail_YYYYMMDD_HHMMSS.log

# Apply 실행 결과
apply_YYYYMMDD_HHMMSS.log
```

### 6.6. 로그 내용
- 실행 시작/종료 시간
- Plan 실행 결과
- 리소스 변경 사항 상세 내역
- Apply 실행 결과
- 에러 및 경고 메시지

## 7. 보안 모듈 구성

### 7.1. 보안 모듈 개요
Security 모듈은 다음과 같은 구성요소를 포함합니다:
- Bastion Host NSG
- Jumpbox NSG
- 네트워크 보안 규칙

### 7.2. 보안 규칙 설정 예시
```hcl
security_rules = [
  {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "22"
    source_address_prefix     = "VirtualNetwork"
    destination_address_prefix = "*"
  }
]
```

### 7.3. 주요 보안 설정
- Bastion 서브넷: 외부에서의 안전한 접근을 위한 진입점
- Jumpbox 서브넷: 내부 리소스 관리를 위한 관리 지점
- NSG 규칙: 최소 권한 원칙에 따른 네트워크 접근 제어


############################################################################
# azure-demo


# 1. Application Gateway 먼저 삭제
terraform destroy -target="module.application-gateway.azurerm_application_gateway.appgw" -auto-approve

# 2. 잠시 대기
sleep 30

# 3. Public IP 삭제
terraform destroy -target="module.application-gateway.azurerm_public_ip.appgw" -auto-approve

# 4. 나머지 리소스 삭제
terraform destroy -target="module.aks" \
  -target="module.database" \
  -target="module.spoke_network" \
  -auto-approve

terraform apply -target="module.aks" -auto-approve

# 5. 최종 정리
terraform destroy -auto-approve



az aks create --resource-group $TF_VAR_resource_group_name --name $TF_VAR_aks_cluster_name --network-plugin azure \
            --vnet-subnet-id "/subscriptions/$TF_VAR_subscription_id/resourceGroups/$TF_VAR_resource_group_name/providers/Microsoft.Network/virtualNetworks/$TF_VAR_vnet_name/subnets/$TF_VAR_aks_subnet_name" --enable-aad --enable-managed-identity --attach-acr $TF_VAR_acr_name  --ssh-key-value ~/.ssh/id_rsa_aks.pub


az aks create --resource-group $TF_VAR_resource_group_name --name $TF_VAR_aks_cluster_name --network-plugin azure \
            --vnet-subnet-id /subscriptions/b6f97aed-4542-491f-a94c-e0f05563485c/resourceGroups/rg-spoke-dev/providers/Microsoft.Network/virtualNetworks/vnet-spoke-dev/subnets/snet-aks --ssh-key-value ~/.ssh/id_rsa_aks.pub



###############################################################################

$ az network vnet subnet list --resource-group rg-spoke-dev --vnet-name vnet-spoke-dev --query "[].{Name:name, Address:addressPrefix}" -o table
Name            Address
--------------  -----------
GatewaySubnet   10.2.7.0/24
snet-app        10.2.4.0/24
snet-aks        10.2.0.0/22
snet-appgw      10.2.8.0/24
snet-db         10.2.5.0/24
snet-endpoints  10.2.6.0/24

az network vnet subnet list --resource-group rg-spoke-dev --vnet-name vnet-spoke-dev -o table

## 1. 네트워크 구성

### 1.1. Hub 네트워크 (10.0.0.0/16)
- AzureFirewallSubnet: 10.0.1.0/24
- AzureBastionSubnet: 10.0.2.0/24
- Jumpbox Subnet: 10.0.3.0/24
- KeyVault Subnet: 10.0.4.0/24

### 1.2. Spoke 네트워크 (10.2.0.0/16)
- AKS Subnet: 10.2.1.0/24
- Load Balancer Subnet: 10.2.2.0/28
- App Gateway Subnet: 10.2.3.0/24
- Endpoints Subnet: 10.2.4.0/24
- App Subnet: 10.2.5.0/24
- DB Subnet: 10.2.6.0/24
- Gateway Subnet: 10.2.7.0/24

### 1.3. AKS 네트워크 설정
- 네트워크 플러그인: Azure CNI
- 서비스 CIDR: 10.0.0.0/16
- DNS 서비스 IP: 10.0.0.10
- Docker Bridge CIDR: 172.17.0.1/16

## 2. 보안 구성
- Key Vault
- NSG (Bastion, Jumpbox)
- Azure Firewall
- Private Endpoints

## 3. 컨테이너 구성
- Premium SKU ACR
- AKS (Azure CNI)

## 4. 모니터링
- Log Analytics Workspace
- Monitor Action Group

## 5. 배포 순서
1. Hub 인프라 배포
2. Spoke 인프라 배포
3. AKS 및 애플리케이션 배포

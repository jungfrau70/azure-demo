# Azure Hub-Spoke 서브넷 구성

## Hub VNet (10.0.0.0/16)

| 서브넷 이름 | 주소 범위 | 용도 |
|------------|-----------|------|
| AzureFirewallSubnet | 10.0.1.0/24 | Azure Firewall |
| AzureBastionSubnet | 10.0.2.0/24 | Azure Bastion 서비스 |
| Jumpbox Subnet | 10.0.3.0/24 | 관리용 Jumpbox VM |
| KeyVault Subnet | 10.0.4.0/24 | Key Vault 서비스 |

## Spoke VNet (10.2.0.0/16)

| 서브넷 이름 | 주소 범위 | 용도 |
|------------|-----------|------|
| AKS Subnet | 10.2.1.0/24 | AKS 노드 및 파드 |
| Load Balancer Subnet | 10.2.2.0/28 | 내부 로드밸런서 |
| App Gateway Subnet | 10.2.3.0/24 | Application Gateway |
| Endpoints Subnet | 10.2.4.0/24 | Private Endpoints |
| App Subnet | 10.2.5.0/24 | 애플리케이션 서비스 |
| DB Subnet | 10.2.6.0/24 | 데이터베이스 서비스 |
| Gateway Subnet | 10.2.7.0/24 | VPN/ExpressRoute Gateway |

## 서비스 엔드포인트 구성

| 서브넷 | 서비스 엔드포인트 |
|--------|-------------------|
| AKS Subnet | Microsoft.ContainerRegistry |
| DB Subnet | Microsoft.Sql |

## NSG 구성

| NSG 이름 | 적용 서브넷 |
|----------|-------------|
| Bastion_NSG | AzureBastionSubnet |
| Jumpbox_NSG | Jumpbox Subnet |
| Aks_NSG | AKS Subnet |
| Endpoints_NSG | Endpoints Subnet |
| Loadbalancer_NSG | Load Balancer Subnet |
| Appgw_NSG | App Gateway Subnet | 
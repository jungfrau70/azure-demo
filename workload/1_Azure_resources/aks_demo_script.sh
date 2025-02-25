#!/bin/bash

# Load environment variables
source ./aks_env.sh

# 1. Infra 구성
az network vnet create --resource-group $RESOURCE_GROUP --name $HUB_VNET --address-prefixes 10.0.0.0/16
az network vnet create --resource-group $RESOURCE_GROUP --name $SPOKE_VNET --address-prefixes 10.1.0.0/16

az network vnet subnet create --resource-group $RESOURCE_GROUP --vnet-name $HUB_VNET --name $HUB_SUBNET --address-prefixes 10.0.1.0/24
az network vnet subnet create --resource-group $RESOURCE_GROUP --vnet-name $SPOKE_VNET --name $SPOKE_SUBNET --address-prefixes 10.1.1.0/24

# 2. AKS 구성
az aks create --resource-group $RESOURCE_GROUP --name $AKS_NAME --network-plugin azure --vnet-subnet-id "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/virtualNetworks/$SPOKE_VNET/subnets/$SPOKE_SUBNET" --enable-aad --enable-managed-identity --attach-acr $ACR_NAME

# 3. AKS 사용자 관리
az ad group create --display-name OperatorGroup --mail-nickname OperatorGroup
az ad group create --display-name ManagerGroup --mail-nickname ManagerGroup
az ad group create --display-name AdminGroup --mail-nickname AdminGroup

# Assign Roles
az role assignment create --assignee "OperatorGroup" --role "Azure Kubernetes Service Cluster User Role"
az role assignment create --assignee "ManagerGroup" --role "Azure Kubernetes Service Contributor"
az role assignment create --assignee "AdminGroup" --role "Azure Kubernetes Service Administrator"

# 4. Azure Portal 및 CLI를 통한 모니터링
az storage account create --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS
az storage share create --name aksshared --account-name $STORAGE_ACCOUNT

# 5. AKS 모니터링 (Prometheus 배포)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install my-prometheus prometheus-community/prometheus

# 6. 스토리지 구성 (PV 와 PVC)
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml

# 7. 웹앱 배포 및 Ingress Controller 설정
az network application-gateway create --resource-group $RESOURCE_GROUP --name $APP_GW_NAME --sku Standard_v2
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install $INGRESS_NAME ingress-nginx/ingress-nginx
kubectl apply -f webapp-deployment.yaml

# 8. Azure Policy 적용
cat <<EOF > policy.json
{
    "policyRule": {
        "if": {
            "allOf": [
                {"field": "type", "equals": "Microsoft.Network/publicIPAddresses"}
            ]
        },
        "then": {
            "effect": "deny"
        }
    }
}
EOF
az policy definition create --name $POLICY_NAME --rules policy.json --mode All
az policy assignment create --policy $POLICY_NAME --scope "/subscriptions/$SUBSCRIPTION_ID"

# 9. 사용자 유형별 작업 가능 유무 시연
echo "Admin, Manager, Operator 역할 테스트 진행 필요"

# 10. 자원 회수 (서비스 종료)
az aks delete --name $AKS_NAME --resource-group $RESOURCE_GROUP --yes --no-wait
az group delete --name $RESOURCE_GROUP --yes --no-wait

# 결과 확인 및 저장
az aks show --name $AKS_NAME --resource-group $RESOURCE_GROUP > aks_status.json
az network application-gateway show --name $APP_GW_NAME --resource-group $RESOURCE_GROUP > app_gw_status.json
kubectl get all -o json > k8s_status.json

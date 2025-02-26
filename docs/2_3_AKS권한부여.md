
1. **Vnet 목록 조회**  
```bash
az network vnet list --output table
```

2. **변수 설정**  
```bash

SUBSCRIPTION_ID=$(az account show --query id --output tsv)
az account set --subscription $SUBSCRIPTION_ID
LOCATION="koreacentral"

RESOURCE_GROUP_1="rg-spoke1"
VNET_NAME_1="vnet-spoke1"
AKS_SUBNET_NAME_1="snet-aks-private"
AKS_CLUSTER_NAME_1="public-aks"

RESOURCE_GROUP_2="rg-spoke2"
VNET_NAME_2="vnet-spoke2"
AKS_SUBNET_NAME_2="snet-aks-private"
AKS_CLUSTER_NAME_2="myaks"


# 각 그룹의 Object ID 가져오기
OPERATOR_GROUP_OBJECT_ID=$(az ad group show --group aks-operators --query id --output tsv)
ADMIN_GROUP_OBJECT_ID=$(az ad group show --group aks-admins --query id --output tsv)
CLUSTER_ADMIN_GROUP_OBJECT_ID=$(az ad group show --group aks-cluster-admins --query id --output tsv)
DEVELOPER_GROUP_OBJECT_ID=$(az ad group show --group aks-developers --query id --output tsv)

# 각 사용자의 Object ID 가져오기
OPERATOR_OBJECT_ID=$(az ad user show --id operator@jupyteronlinegmail.onmicrosoft.com --query id --output tsv)
ADMIN_OBJECT_ID=$(az ad user show --id admin@jupyteronlinegmail.onmicrosoft.com --query id --output tsv)
CLUSTER_ADMIN_OBJECT_ID=$(az ad user show --id clusteradmin@jupyteronlinegmail.onmicrosoft.com --query id --output tsv)
DEVELOPER_OBJECT_ID=$(az ad user show --id developer@jupyteronlinegmail.onmicrosoft.com --query id --output tsv)

echo "🔹 그룹 정보:"
echo "   - 오퍼레이터: $OPERATOR_GROUP_OBJECT_ID"
echo "   - 관리자: $ADMIN_GROUP_OBJECT_ID"
echo "   - 클러스터 관리자: $CLUSTER_ADMIN_GROUP_OBJECT_ID"
echo "   - 개발자: $DEVELOPER_GROUP_OBJECT_ID"

echo "🔹 사용자 정보:"
echo "   - 오퍼레이터: $OPERATOR_OBJECT_ID"
echo "   - 관리자: $ADMIN_OBJECT_ID"
echo "   - 클러스터 관리자: $CLUSTER_ADMIN_OBJECT_ID"
echo "   - 개발자: $DEVELOPER_OBJECT_ID"

```

### **사용자 그룹별 필요 권한**
| 사용자 그룹 | 필요 역할 |
|------------|----------|
| **클러스터 사용자 (kubectl 사용 가능)** | `Azure Kubernetes Service Cluster User Role` |
| **클러스터 관리자 (kubectl + AKS 관리 가능)** | `Azure Kubernetes Service Cluster Admin Role` |
| **AKS 리소스 관리자 (Azure Portal/CLI로 AKS 관리)** | `Contributor` 또는 `Azure Kubernetes Service Contributor Role` |
- **클러스터 관리자**(kubectl + 관리 작업 가능)나 **AKS 관리 작업을 수행할 사용자**는 추가적인 역할(`Admin Role`, `Contributor Role` 등)이 필요  


# PUBLIC AKS 클러스터 권한 부여

## 클러스터 사용자 (kubectl 사용 가능) - aks-operators 그룹에 부여
```bash
az role assignment create --assignee $OPERATOR_GROUP_OBJECT_ID \
    --role "Azure Kubernetes Service RBAC Reader" \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_1/providers/Microsoft.ContainerService/managedClusters/$AKS_CLUSTER_NAME_1
```

## 클러스터 관리자 (kubectl + AKS 관리 가능) - aks-cluster-admins 그룹에 부여
```bash
az role assignment create --assignee $CLUSTER_ADMIN_GROUP_OBJECT_ID \
    --role "Azure Kubernetes Service RBAC Admin" \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_1/providers/Microsoft.ContainerService/managedClusters/$AKS_CLUSTER_NAME_1
```

## AKS 리소스 관리자 (Azure Portal/CLI로 AKS 관리) - aks-admins 그룹에 부여
```bash
az role assignment create --assignee $ADMIN_GROUP_OBJECT_ID \
    --role "Azure Kubernetes Service RBAC Cluster Admin" \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_1
```

## 개발자 그룹 - 필요에 따라 추가 가능
```bash
az role assignment create --assignee $DEVELOPER_GROUP_OBJECT_ID \
    --role "Azure Kubernetes Service RBAC Reader" \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_1/providers/Microsoft.ContainerService/managedClusters/$AKS_CLUSTER_NAME_1
```


# PRIVATE AKS 클러스터 권한 부여

## 클러스터 사용자 (kubectl 사용 가능) - aks-operators 그룹에 부여
```bash
az role assignment create --assignee $OPERATOR_GROUP_OBJECT_ID \
    --role "Azure Kubernetes Service Cluster User Role" \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_2/providers/Microsoft.ContainerService/managedClusters/$AKS_CLUSTER_NAME_2
```

## 클러스터 관리자 (kubectl + AKS 관리 가능) - aks-cluster-admins 그룹에 부여
```bash
az role assignment create --assignee $CLUSTER_ADMIN_GROUP_OBJECT_ID \
    --role "Azure Kubernetes Service Cluster Admin Role" \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_2/providers/Microsoft.ContainerService/managedClusters/$AKS_CLUSTER_NAME_2
```

## AKS 리소스 관리자 (Azure Portal/CLI로 AKS 관리) - aks-admins 그룹에 부여
```bash
az role assignment create --assignee $ADMIN_GROUP_OBJECT_ID \
    --role "Azure Kubernetes Service Contributor Role" \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_2
```

## 개발자 그룹 - 필요에 따라 추가 가능
```bash
az role assignment create --assignee $DEVELOPER_GROUP_OBJECT_ID \
    --role "Azure Kubernetes Service Cluster User Role" \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_2/providers/Microsoft.ContainerService/managedClusters/$AKS_CLUSTER_NAME_2
```


# 권한 확인

```bash
az role assignment list --assignee $OPERATOR_GROUP_OBJECT_ID --all --output table
az role assignment list --assignee $CLUSTER_ADMIN_GROUP_OBJECT_ID --all --output table
az role assignment list --assignee $ADMIN_GROUP_OBJECT_ID --all --output table
az role assignment list --assignee $DEVELOPER_GROUP_OBJECT_ID --all --output table
```



###






















############################################################################################################
1. **오퍼레이터에게 AKS 접근 권한 부여**  
   ```bash
   az role assignment create \
     --assignee $OPERATOR_OBJECT_ID \
     --role "Azure Kubernetes Service Cluster User Role" \
     --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_1/providers/Microsoft.ContainerService/managedClusters/$AKS_CLUSTER_NAME_1

   az role assignment create \
     --assignee $OPERATOR_OBJECT_ID \
     --role "Azure Kubernetes Service Cluster User Role" \
     --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_2/providers/Microsoft.ContainerService/managedClusters/$AKS_CLUSTER_NAME_2
   az role assignment list --assignee $OPERATOR_OBJECT_ID --output table

   ```
   - `<OPERATOR_AZURE_AD_OBJECT_ID>`: 오퍼레이터의 Azure AD Object ID  
   - `<SUBSCRIPTION_ID>`: 현재 사용 중인 Azure 구독 ID  


---

2. **관리자에게 AKS 접근 권한 부여**  
   ```bash
   az role assignment create \
     --assignee $ADMIN_OBJECT_ID \
     --role "Azure Kubernetes Service Cluster Admin Role" \
     --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_1/providers/Microsoft.ContainerService/managedClusters/$AKS_CLUSTER_NAME_1

   az role assignment create \
     --assignee $ADMIN_OBJECT_ID \
     --role "Azure Kubernetes Service Cluster Admin Role" \
     --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_2/providers/Microsoft.ContainerService/managedClusters/$AKS_CLUSTER_NAME_2
   
   az role assignment list --assignee $ADMIN_OBJECT_ID --output table

   ```

3. **클러스터 관리자에게 AKS 접근 권한 부여**  
   ```bash
   az role assignment create \
     --assignee $CLUSTER_ADMIN_OBJECT_ID \
     --role "Azure Kubernetes Service Cluster Admin Role" \
     --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_1/providers/Microsoft.ContainerService/managedClusters/$AKS_CLUSTER_NAME_1
   
   az role assignment create \
     --assignee $CLUSTER_ADMIN_OBJECT_ID \
     --role "Azure Kubernetes Service Cluster Admin Role" \
     --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_2/providers/Microsoft.ContainerService/managedClusters/$AKS_CLUSTER_NAME_2
   
   az role assignment list --assignee $CLUSTER_ADMIN_OBJECT_ID --output table

   ```

### **각 역할 비교 (정리)**  

| 역할 | 설명 | `kubectl` 사용 | AKS 관리 가능 (Azure Portal/CLI) |
|------|------|---------------|--------------------------------|
| **Azure Kubernetes Service Cluster User Role** | 클러스터 사용자 역할, `kubectl` 사용 가능 (RBAC 필요) | ✅ 가능 | ❌ 불가능 |
| **Azure Kubernetes Service Cluster Admin Role** | 클러스터 관리자 역할, `kubectl` 전체 권한 (RBAC 필요) | ✅ 가능 | ❌ 불가능 |
| **Azure Kubernetes Service Contributor Role** | AKS 클러스터 자체 관리 가능 (생성, 수정, 삭제 등) | ❌ 직접 불가 | ✅ 가능 |
| **Contributor** | 리소스 그룹 내 모든 리소스 관리 가능 (AKS 포함) | ❌ 직접 불가 | ✅ 가능 |

### **주요 차이점**
- `"Azure Kubernetes Service Cluster User Role"`은 **`kubectl` 사용을 위한 최소한의 권한**만 제공하지만,  
  - AKS 자체를 관리할 수는 없음 (예: 클러스터 업그레이드, 노드 풀 조정 등 불가)  
- `"Azure Kubernetes Service Cluster Admin Role"`은 **클러스터 내 모든 권한을 가짐**  
- `"Azure Kubernetes Service Contributor Role"`은 **AKS 클러스터를 생성, 수정, 삭제할 수 있지만 `kubectl`을 바로 사용할 수는 없음**  
- `"Contributor"`는 **리소스 그룹 내 모든 리소스를 관리 가능** (`AKS 관리 포함`)  

---

### **결론**
👉 **"Azure Kubernetes Service Cluster User Role"은 kubectl 사용이 목적이고, AKS 클러스터 자체를 관리하려면 추가적인 역할(`Admin Role`, `Contributor Role` 등)이 필요하다"**는 의미


###
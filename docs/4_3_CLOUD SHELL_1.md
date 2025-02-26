## 1. **Azure CLI로 권한 확인**
### (1) 현재 로그인 계정 확인
```sh
az account show --output table
```
위 명령어를 실행하여 현재 로그인된 Azure 계정을 확인하세요.  

### (2) AKS 클러스터에 대한 역할 확인
```sh
az role assignment list --assignee $OPERATOR_OBJECT_ID --all --output table
```


---

## 2. **kubectl을 사용하여 클러스터 접근 확인**

### (1) Public AKS 클러스터에 대한 `kubeconfig` 설정
```sh
az aks get-credentials --resource-group $RESOURCE_GROUP_1 --name $AKS_CLUSTER_NAME_1 --overwrite-existing
```
이 명령어를 실행하면 `~/.kube/config` 파일이 설정되며, 이후 `kubectl`을 사용할 수 있습니다.  

### (2) 클러스터 연결 확인
```sh
kubectl get nodes
```
정상적으로 노드 목록이 출력되면 클러스터에 대한 접근이 가능한 상태입니다.  



### (3) Private AKS 클러스터에 대한 `kubeconfig` 설정
```sh
az aks get-credentials --resource-group $RESOURCE_GROUP_2 --name $AKS_CLUSTER_NAME_2 --overwrite-existing
```
이 명령어를 실행하면 `~/.kube/config` 파일이 설정되며, 이후 `kubectl`을 사용할 수 있습니다.  

### (4) 클러스터 연결 확인
```sh
kubectl get nodes
```

### Context 변경 및 기본 context 설정
```sh
kubectl config use-context $AKS_CLUSTER_NAME_1
```


### Cloud Shell에서 Private AKS 클러스터에 대한 `kubeconfig` 설정
```sh
az aks get-credentials --resource-group $RESOURCE_GROUP_2 --name $AKS_CLUSTER_NAME_2 --overwrite-existing
```
이 명령어를 실행하면 `~/.kube/config` 파일이 설정되며, 이후 `kubectl`을 사용할 수 있습니다.  

정상적으로 노드 목록이 출력되면 클러스터에 대한 접근이 가능한 상태입니다.

만약 권한이 부족하면 `forbidden` 오류가 발생할 수 있습니다.


---



##########################################################################################################

## 3. **RBAC(Role-Based Access Control) 확인**
AKS에서는 **RBAC**을 통해 세부적인 권한이 관리됩니다.  

### (1) 현재 사용자 정보 확인
```sh
kubectl auth can-i list pods --all-namespaces
```
이 명령어를 실행하여 Pod 목록 조회 권한이 있는지 확인할 수 있습니다.  
`yes`라면 조회 가능, `no`라면 권한이 부족한 것입니다.  

### (2) 본인의 권한 조회
```sh
kubectl get rolebindings --all-namespaces | grep <내 Azure AD Object ID>
```
또는  
```sh
kubectl describe clusterrolebindings
```
본인이 속한 역할과 권한을 확인할 수 있습니다.  

---

## 4. **Cluster User Role의 제한 사항**
- `Azure Kubernetes Service Cluster User Role`은 **클러스터 정보 조회** 및 **kubectl 사용**은 가능하지만, 리소스 배포(`kubectl apply`), 삭제(`kubectl delete`), 수정(`kubectl edit`) 등의 관리 권한이 제한될 수 있습니다.  
- 추가적인 작업이 필요하다면 관리자에게 `Azure Kubernetes Service RBAC Reader` 또는 `Contributor` 역할 추가를 요청해야 합니다.  

---

## 5. **추가적인 권한 요청이 필요할 때**
현재 역할로 원하는 작업을 수행할 수 없다면, 아래 방법 중 하나를 통해 관리자로부터 권한을 요청하세요.  

### (1) 현재 역할 확인
```sh
az role assignment list --assignee <내 Azure AD Object ID> --output table
```
### (2) 필요한 역할 요청
- 클러스터의 리소스를 조회만 하면 된다면: `Azure Kubernetes Service RBAC Reader`
- 클러스터에서 리소스를 배포/수정해야 한다면: `Azure Kubernetes Service RBAC Writer` 또는 `Contributor`

요청할 때 **관리자(Azure AD Global Administrator 또는 Subscription Owner)**에게 아래와 같이 요청하면 됩니다.  
```txt
현재 AKS에서 `Azure Kubernetes Service Cluster User Role` 권한을 보유 중입니다.
추가적으로 [필요한 역할] 역할을 할당해 주실 수 있을까요?
```

---

이제 AKS 클러스터에 정상적으로 접근할 수 있는지 확인하고, 필요한 경우 관리자에게 추가 권한을 요청해보세요! 🚀




########################################################################################

### **2️⃣ 오퍼레이터: Cloud Shell에서 AKS 상태 점검**
**📌 목표:**  
- Cloud Shell을 사용하여 AKS 클러스터 상태를 점검  
- `kubectl`을 이용해 노드 및 파드 상태 확인  

**🔹 실행 절차:**  
1. **Azure Cloud Shell에서 `kubectl` 및 `az` 사용 가능 여부 확인**  
   ```bash
   az --version
   kubectl version --client
   ```

2. **AKS 클러스터 인증 정보 가져오기**  
   ```bash
   az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
   ```

3. **클러스터 노드 상태 확인**  
   ```bash
   kubectl get nodes
   ```

4. **전체 네임스페이스의 파드 상태 확인**  
   ```bash
   kubectl get pods -A
   ```

5. **AKS 모니터링 추가 정보 확인**  
   ```bash
   kubectl top nodes
   kubectl top pods -A
   ```

---

### **3️⃣ 테스트 성공 기준**
✅ **관리자**  
- AKS 클러스터가 정상적으로 생성되었는가?  
- 오퍼레이터에게 적절한 권한이 부여되었는가?  

✅ **오퍼레이터**  
- Cloud Shell에서 AKS 클러스터 접근이 가능한가?  
- `kubectl get nodes`로 노드 상태를 조회할 수 있는가?  
- `kubectl get pods -A`로 파드 상태를 확인할 수 있는가?  

---

이제 직접 실행해보고, 특정 단계에서 문제가 발생하면 로그를 확인해보자! 🚀



## **2️⃣ AKS 클러스터 권한 부여 (오퍼레이터, 운영자, 관리자)**  

### **🔹 ① 오퍼레이터 (Kubernetes 상태 조회만 가능)**  
```bash
az role assignment create \
    --assignee $OPERATOR_OBJECT_ID \
    --role "Azure Kubernetes Service Cluster User Role" \
    --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/myResourceGroup/providers/Microsoft.ContainerService/managedClusters/myAKSCluster
```



### **🔹 AKS 접근 권한 부여**  
```bash
az role assignment create \
    --assignee "<OPERATOR_AZURE_AD_OBJECT_ID>" \
    --role "Azure Kubernetes Service Cluster User Role" \
    --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/myResourceGroup/providers/Microsoft.ContainerService/managedClusters/myAKSCluster
```
---






## **2️⃣ AKS 클러스터 권한 부여 (오퍼레이터, 운영자, 관리자)**  

### **🔹 ① 오퍼레이터 (Kubernetes 상태 조회만 가능)**  
```bash
az role assignment create \
    --assignee $OPERATOR_OBJECT_ID \
    --role "Azure Kubernetes Service Cluster User Role" \
    --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/myResourceGroup/providers/Microsoft.ContainerService/managedClusters/myAKSCluster
```



### **🔹 AKS 접근 권한 부여**  
```bash
az role assignment create \
    --assignee "<OPERATOR_AZURE_AD_OBJECT_ID>" \
    --role "Azure Kubernetes Service Cluster User Role" \
    --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/myResourceGroup/providers/Microsoft.ContainerService/managedClusters/myAKSCluster
```
---



---
---

## **3️⃣ 오퍼레이터가 수행할 Kubernetes 상태 점검 스크립트**  
🔹 Cloud Shell이 아니라 **Jumpbox VM에서 실행할 수 있도록 구성**해야 해.

### **🔹 Jumpbox에서 실행할 `check_aks_status.sh`**
```bash
#!/bin/bash

echo "🔹 AKS 클러스터 인증 정보 가져오기..."
az aks get-credentials --resource-group myPrivateAKSResourceGroup --name myPrivateAKS --overwrite-existing

echo "🔹 노드 상태 확인..."
kubectl get nodes -o wide

echo "🔹 모든 네임스페이스의 파드 상태 확인..."
kubectl get pods -A --sort-by=.status.phase

echo "🔹 Kubernetes 컨트롤 플레인 구성 요소 상태 확인..."
kubectl get componentstatuses

echo "🔹 네임스페이스 목록 확인..."
kubectl get namespaces

echo "🔹 노드 리소스 사용량 확인..."
kubectl top nodes

echo "🔹 파드 리소스 사용량 확인..."
kubectl top pods -A

echo "✅ Kubernetes 상태 점검 완료!"
```

---




## **3️⃣ 오퍼레이터: Cloud Shell에서 공유 폴더 마운트 후 Bash 실행**  
### **🔹 Cloud Shell에서 공유 폴더 마운트**  
```bash
# Cloud Shell에서 스토리지 연결 정보 가져오기
export STORAGE_KEY=$(az storage account keys list \
    --resource-group myStorageGroup \
    --account-name mystorageaks \
    --query '[0].value' --output tsv)

# 공유 폴더 마운트
mkdir -p /mnt/cloudshell-share
mount -t cifs //mystorageaks.file.core.windows.net/cloudshell-share /mnt/cloudshell-share \
    -o vers=3.0,username=mystorageaks,password=$STORAGE_KEY,dir_mode=0777,file_mode=0777
```

### **🔹 공유 폴더 내 Bash 스크립트 실행**  
```bash
cd /mnt/cloudshell-share
bash setup.sh
```

---

## **✅ 시나리오 성공 기준**  
🔹 **Azure AD 그룹 생성 및 사용자 추가 완료**  
🔹 **스토리지 계정 및 공유 폴더 생성 완료**  
🔹 **Cloud Shell에서 공유 폴더 마운트 및 스크립트 실행 성공**  

---

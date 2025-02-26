## **Public AKS + Cloud Shell + Operator 시나리오**  

관리자가 **Public AKS 클러스터를 생성**하고, 
오퍼레이터가 **Cloud Shell을 사용하여 AKS 상태를 점검**하는 시나리오

---

### **1️⃣ 관리자: Public AKS 클러스터 생성**
**📌 목표:**  
- 관리자가 Public AKS 클러스터를 구성  
- RBAC 설정을 통해 오퍼레이터 권한 부여  

**🔹 실행 절차:**  
1. **Azure 리소스 그룹 생성**  
   ```bash
   az group create --name rg-spoke1 --location koreacentral
   ```

2. **SSH 키를 직접 생성**  
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/public_aks_ssh_key -N ""
   ```

3. **Public AKS 클러스터 생성**  
   ```bash
    az aks create \
    --resource-group rg-spoke1 \
    --name myPublicAKSCluster \
    --node-count 2 \
    --enable-addons monitoring \
    --ssh-key-value ~/.ssh/public_aks_ssh_key.pub
   ```

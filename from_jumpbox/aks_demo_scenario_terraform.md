Terraform을 사용하여 위의 Azure 리소스를 최대한 코드로 정의할 수 있습니다. 일부 기능(예: Azure Policy 적용 및 GitHub Actions 연계)은 CLI 또는 별도 구성 파일을 통해 처리해야 하지만, 대부분의 리소스는 Terraform으로 구축할 수 있습니다.

아래는 Terraform을 사용하여 주요 구성 요소를 정의한 코드입니다.

---

### **1. 네트워크 구성 (Hub & Spoke)**
```hcl
provider "azurerm" {
  features {}
}

variable "resource_group" {
  default = "aks-demo-rg"
}

variable "location" {
  default = "koreacentral"
}

resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = "hub-vnet"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "hub_subnet" {
  name                 = "hub-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "spoke_vnet" {
  name                = "spoke-vnet"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "spoke_subnet" {
  name                 = "spoke-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "HubToSpoke"
  resource_group_name          = azurerm_resource_group.aks_rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "SpokeToHub"
  resource_group_name          = azurerm_resource_group.aks_rg.name
  virtual_network_name         = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  allow_virtual_network_access = true
}
```

---

### **2. Private AKS 배포**
```hcl
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "myaks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "myaks"

  default_node_pool {
    name       = "agentpool"
    node_count = 3
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_mode   = "transparent"
  }

  private_cluster_enabled = true

  addon_profile {
    oms_agent {
      enabled = true
    }
  }
}
```

---

### **3. Managed Prometheus 및 Grafana 설정**
```hcl
resource "azurerm_monitor_workspace" "monitoring" {
  name                = "aks-monitor"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
}

resource "azurerm_kubernetes_cluster" "aks_monitoring" {
  depends_on = [azurerm_kubernetes_cluster.aks]

  name                = "myaks-monitoring"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  addon_profile {
    oms_agent {
      enabled = true
    }
    azure_monitor_metrics {
      enabled = true
    }
  }
}
```

---

### **4. Application Gateway 및 Ingress**
```hcl
resource "azurerm_application_gateway" "app_gateway" {
  name                = "myAppGateway"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location

  sku {
    name = "Standard_v2"
  }
}
```

---

### **5. Azure Files PVC**
Azure Files PVC는 Kubernetes 리소스이므로 Terraform에서 직접 정의하지 않고 `kubectl apply -f`를 이용하는 것이 일반적입니다.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurefile-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurefile-csi
  resources:
    requests:
      storage: 10Gi
```

---

### **6. GitHub Actions 기반 CI/CD**
GitHub Actions 관련 코드는 Terraform에서 직접 관리하기 어렵기 때문에, `.github/workflows/aks-deploy.yaml` 파일을 생성하여 설정해야 합니다.

---

### **7. 자원 정리**
Terraform에서는 `terraform destroy` 명령을 사용하여 모든 리소스를 정리할 수 있습니다.

```sh
terraform destroy -auto-approve
```

---

### **결론**
Terraform을 활용하여 대부분의 리소스를 코드로 정의할 수 있으며, 일부 설정(Azure Policy 적용, GitHub Actions 설정 등)은 수동으로 처리해야 합니다. 이 접근 방식은 **재현 가능성, 자동화, 관리 효율성**을 높이는 데 큰 장점이 있습니다. 

필요하면 더 상세한 부분을 추가할 수 있으니, 추가하고 싶은 내용이 있으면 알려주세요! 🚀
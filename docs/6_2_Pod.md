
ACR_NAME="hubacr35au3ynt.azurecr.io"

RESOURCE_GROUP="rg-hub"

HUB_RG="rg-hub"
HUB_VNET_NAME="vnet-hub"
HUB_LOCATION="koreacentral"

JUMPBOX_VM_NAME="Jumpbox-VM"
JUMPBOX_SUBNET_NAME="snet-jumpbox"
PASSWORD="bright2n@1234"

BASTION_NAME="hub-bastion"
BASTION_SUBNET_NAME="snet-bastion"
BASTION_PIP_NAME="hub-bastion-pip"


ACR_ID=$(az acr show --name $ACR_NAME --query id --output tsv)
echo "ACR_ID: $ACR_ID"



Azure Container Registry(ACR) 계정을 만들려면 Azure CLI 또는 Azure Portal을 사용할 수 있습니다.  

### **Azure CLI를 사용하는 방법**  
1. **Azure 로그인**  
   ```sh
   az login
   ```








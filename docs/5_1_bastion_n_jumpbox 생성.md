HUB_RG="rg-hub"
HUB_VNET_NAME="vnet-hub"
HUB_LOCATION="koreacentral"

JUMPBOX_VM_NAME="Jumpbox-VM"
JUMPBOX_SUBNET_NAME="snet-jumpbox"
PASSWORD="bright2n@1234"

BASTION_NAME="hub-bastion"
BASTION_SUBNET_NAME="snet-bastion"
BASTION_PIP_NAME="hub-bastion-pip"


az network public-ip create \
    --resource-group $HUB_RG  \
    --name $BASTION_PIP_NAME \
    --sku Standard \
    --allocation-method Static

Bastion_PIP=$(az network public-ip show --name $BASTION_PIP_NAME --resource-group $HUB_RG --query ipAddress -o tsv
)

# Create the jumpbox VM
az vm create \
    --resource-group $HUB_RG \
    --name $JUMPBOX_VM_NAME \
    --image Ubuntu2204 \
    --admin-username azureuser \
    --admin-password $PASSWORD \
    --vnet-name $HUB_VNET_NAME \
    --subnet $JUMPBOX_SUBNET_NAME \
    --size Standard_B2s \
    --storage-sku Standard_LRS \
    --os-disk-name $JUMPBOX_VM_NAME-VM-osdisk \
    --os-disk-size-gb 128 \
    --public-ip-address $Bastion_PIP \
    --nsg "" 

# Create the Bastion Host
az network bastion create \
    --resource-group $HUB_RG \
    --name $BASTION_NAME \
    --public-ip-address $BASTION_PIP_NAME \
    --vnet-name $HUB_VNET_NAME \
    --location $LOCATION

az network bastion show \
    --resource-group $HUB_RG \
    --name $BASTION_NAME    

JUMPBOX_VM_ID=$(az vm show -g $HUB_RG -n $JUMPBOX_VM_NAME --query id -o tsv)

az network bastion rdp --name $BASTION_NAME --resource-group $HUB_RG --target-resource-id $JUMPBOX_VM_ID






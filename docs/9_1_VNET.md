RESOURCE_GROUP_1="rg-spoke1"
VNET_NAME_1="vnet-spoke1"
AKS_SUBNET_NAME_1="snet-aks-private"
AKS_CLUSTER_NAME_1="public-aks"

RESOURCE_GROUP_2="rg-spoke2"
VNET_NAME_2="vnet-spoke2"
AKS_SUBNET_NAME_2="snet-aks-private"
AKS_CLUSTER_NAME_2="myaks"

NODE_RESOURCE_GROUP_1=$(az aks show -g $RESOURCE_GROUP_1 -n $AKS_CLUSTER_NAME_1 --query "nodeResourceGroup" -o tsv)
echo "NODE_RESOURCE_GROUP_1: $NODE_RESOURCE_GROUP_1"
az network vnet list -g $NODE_RESOURCE_GROUP_1 --query "[].name"

NODE_RESOURCE_GROUP_2=$(az aks show -g $RESOURCE_GROUP_2 -n $AKS_CLUSTER_NAME_2 --query "nodeResourceGroup" -o tsv)
echo "NODE_RESOURCE_GROUP_2: $NODE_RESOURCE_GROUP_2"
az network vnet list -g $NODE_RESOURCE_GROUP_2 --query "[].name"

az aks show -g <AKS_ResourceGroup> -n <AKS_Cluster> --query "nodeResourceGroup"
az network vnet list -g <NodeResourceGroup> --query "[].name"



terraform import azurerm_resource_group.spoke_rg /subscriptions/b6f97aed-4542-491f-a94c-e0f05563485c/resourceGroups/rg-spoke2

terraform state rm azurerm_resource_group.spoke_rg


# 1. 먼저 state에서 리소스 그룹 제거
terraform state rm azurerm_resource_group.spoke_rg

# 2. 리소스 그룹 import
terraform import azurerm_resource_group.spoke_rg /subscriptions/b6f97aed-4542-491f-a94c-e0f05563485c/resourceGroups/rg-spoke2
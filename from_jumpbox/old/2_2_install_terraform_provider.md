#######################################################################################

## Terraform Provider 설치

https://registry.terraform.io/providers/hashicorp/azurerm/latest



## **🔍 오류 원인**  
Terraform이 기존 `terraform.lock.hcl` 파일에서 `azurerm` 버전을 `3.117.0`으로 잠가 두었기 때문에, 새로운 버전 `4.20.0`을 사용할 수 없다는 오류입니다.

Terraform은 이전에 다운로드한 프로바이더 버전을 `terraform.lock.hcl` 파일에 저장하며, 명시적으로 업데이트하지 않으면 기존 버전을 계속 재사용합니다.

---

## **✅ 해결 방법 (업데이트 적용)**  

1. **기존 `.terraform` 디렉터리 및 잠긴 버전 삭제**  
   ```sh
   rm -rf .terraform terraform.lock.hcl
   ```

2. **다시 초기화 및 업그레이드 실행**  
   ```sh
   terraform init -upgrade
   ```
   - `-upgrade` 옵션을 사용하면 새로운 버전 (`4.20.0`)을 다운로드하면서 기존 버전 (`3.117.0`)을 제거합니다.

3. **적용된 프로바이더 버전 확인**  
   ```sh
   terraform providers
   ```
   - 여기에서 `azurerm` 버전이 `4.20.0`으로 변경되었는지 확인하세요.

---

## **🚀 정리**  
오류는 **이전 버전(3.117.0)이 잠겨 있어서** 발생한 것이며, `rm -rf .terraform terraform.lock.hcl` 후 `terraform init -upgrade`를 실행하면 해결됩니다.  

PS C:\Users\JIH\githubs\azure-demo\1_Azure_resources> terraform init -upgrade
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "4.20.0"...
- Installing hashicorp/azurerm v4.20.0...
- Installed hashicorp/azurerm v4.20.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

#######################################################################################

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan -out=plan.tfplan

# Apply the configuration
terraform apply plan.tfplan -auto-approve

# Destroy the resources
terraform destroy -auto-approve -var-file="terraform.tfvars"

# Delete the resources
terraform destroy -auto-approve -var-file="terraform.tfvars"










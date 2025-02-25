#!/bin/bash

# 타임스탬프를 사용하여 출력 파일 이름 생성
timestamp=$(date +%Y%m%d_%H%M%S)
output_dir="terraform_logs"
mkdir -p $output_dir

# outputs.tf 파일이 있다면 삭제
if [ -f "outputs.tf" ]; then
    echo "중복된 outputs.tf 파일을 삭제합니다..."
    rm outputs.tf
fi

# backend.hcl 파일 확인
if [ ! -f "backend.hcl" ]; then
    cat > backend.hcl << EOF
storage_account_name = "terraformstate5428"
container_name      = "tfstate"
key                = "hub.tfstate"
resource_group_name = "terraform-state-rg"
EOF
    echo "backend.hcl 파일이 생성되었습니다."
fi

# terraform init (필요한 경우)
if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init -backend-config=backend.hcl
fi

# plan 실행 및 로그 저장
echo "Terraform plan 실행 중..."
terraform plan -out=tfplan 2>&1 | tee "${output_dir}/plan_${timestamp}.log"

# plan 실행 결과 확인
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "Plan failed"
    rm -f tfplan
    exit 1
fi

# plan 파일 내용 저장 (human-readable 형식)
terraform show -no-color tfplan 2>&1 | tee "${output_dir}/plan_detail_${timestamp}.log"

# 사용자 확인
read -p "계획을 실행하시겠습니까? (y/n) " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    # apply 실행 및 로그 저장
    terraform apply tfplan 2>&1 | tee "${output_dir}/apply_${timestamp}.log"
    apply_status=${PIPESTATUS[0]}
    
    if [ $apply_status -ne 0 ]; then
        echo "Apply failed"
        rm -f tfplan
        exit 1
    fi
fi

# plan 파일 정리
rm -f tfplan

echo "Terraform 작업이 완료되었습니다."
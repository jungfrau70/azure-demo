#!/bin/bash

# 환경 변수 설정
export AZURE_HOME_TENANT_ID=$(az account show --query homeTenantId -o tsv)

echo "AZURE_HOME_TENANT_ID: $AZURE_HOME_TENANT_ID"
#!/bin/bash

# Azure Storage Account
export STORAGE_ACCOUNT="aksdemostorage"
export SUBSCRIPTION_ID="b6f97aed-4542-491f-a94c-e0f05563485c"
export TENANT_ID="jupyteronlinegmail.onmicrosoft.com"

export PROJECT_NAME="aks-demo"
export ENVIRONMENT="dev"

# 환경 변수 설정
export LOCATION="koreacentral"
export HUB_VNET="vnet-hub-dev"
export HUB_SUBNET="snet-hub-dev"
export ACR_NAME="myaksacr"

export SPOKE_VNET="vnet-spoke-dev"
export RESOURCE_GROUP="rg-spoke-dev"
export SPOKE_SUBNET="snet-aks"
export AKS_NAME="aks-cluster-dev"

export POLICY_NAME="Deny-Public-IP"
export APP_GW_NAME="myAppGateway"
export INGRESS_NAME="my-ingress"



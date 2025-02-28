## **1️⃣ AGIC Ingress 설정**

# Ingress 매니페스트 작성
cat > wordpress-ingress.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: wordpress-ingress
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: wordpress-service
            port:
              number: 80
EOF

# Service 매니페스트 작성
cat > wordpress-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: wordpress-service
spec:
  selector:
    app: wordpress
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

# 리소스 배포
kubectl apply -f wordpress-service.yaml
kubectl apply -f wordpress-ingress.yaml

## **2️⃣ 연결 테스트**

# Application Gateway 공인 IP 확인
APPGW_PIP=$(az network public-ip show \
    --resource-group $SPOKE_RG \
    --name $APPGW_NAME-PIP \
    --query ipAddress \
    --output tsv)

echo "WordPress URL: http://$APPGW_PIP" 
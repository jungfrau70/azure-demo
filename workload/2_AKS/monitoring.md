Azure Kubernetes Service에서 Grafana와 Prometheus를 이용한 모니터링
===================================================

Kubernetes는 소프트웨어 배포, 스케일링, 관리를 자동화하기 위한 오픈소스 컨테이너 오케스트레이션 시스템입니다.
하지만 분산 시스템의 특성상 클러스터 내에서 일어나는 모든 것을 모니터링하는 것이 쉽지 않습니다.
Prometheus와 Grafana가 이러한 경험을 개선해줍니다.

## 개요

**Prometheus**는 이벤트 모니터링과 알림에 사용되는 무료 소프트웨어입니다. HTTP 풀 모델을 사용하여 시계열 데이터베이스에 메트릭을 기록하며, 유연한 쿼리와 실시간 알림 기능을 제공합니다.

**Grafana**는 멀티 플랫폼 오픈소스 분석 및 대화형 시각화 웹 애플리케이션입니다. 지원되는 데이터 소스에 연결하면 웹용 차트, 그래프, 알림을 제공합니다.

이 가이드에서는 Azure Kubernetes Service(AKS)를 사용하여 Kubernetes 클러스터를 설정하고 Prometheus와 Grafana를 배포하여 모니터링 데이터를 수집하고 시각화하는 방법을 알아보겠습니다.

## 단계별 가이드

### 1단계 - Azure 계정 로그인 및 리소스 그룹 생성 ✅
```bash
az login
az group create --name aks-prometheus --location centralindia
```

### 2단계 - AKS 클러스터 생성 및 설정 ✅
```bash
# AKS 클러스터 생성
az aks create --resource-group aks-prometheus --name aks1 --node-count 3 --node-vm-size Standard_B2s --generate-ssh-keys

# 자격 증명 가져오기
az aks get-credentials --resource-group aks-prometheus --name aks1

# 노드 상태 확인
kubectl get nodes
```

### 3단계 - Prometheus 및 Grafana 설치 ✅
```bash
# Helm 저장소 추가
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Prometheus 스택 설치
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

# Pod 상태 확인
kubectl --namespace monitoring get pods -l "release=prometheus"
```

### 4단계 - Prometheus 설정 ✅
```bash
# 포트 포워딩 설정
kubectl port-forward --namespace monitoring service/prometheus-kube-prometheus-prometheus 9090

# 접속 확인: http://localhost:9090
```

### 5단계 - Grafana 설정 ✅
```bash
# 포트 포워딩 설정
kubectl port-forward --namespace monitoring service/prometheus-grafana 8080:80

# 접속 확인: http://localhost:8080
```

### 6단계 - Azure Container Registry(ACR) 설정 ✅
- Azure Portal에서 Container Registry 생성
- AKS와 ACR 연동 설정

### 7단계 - 샘플 애플리케이션 준비 ✅

**Dockerfile 생성:**
```dockerfile
FROM python:3.7-slim
RUN pip install flask
WORKDIR /app
COPY firstapp.py /app/firstapp.py
ENTRYPOINT ["python"]
CMD ["/app/firstapp.py"]
```

**firstapp.py:**
```python
from flask import Flask
app = Flask('first-app')

@app.route('/')
def hello():
    return "Hello World! Lets sail together - First App.\n"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

**테스트 코드:**
```python
import unittest
from firstapp import hello

class TestFirstApp(unittest.TestCase):
    def test_hello(self):
        self.assertEqual(hello(), "Hello World! Lets sail together - First App.\n")

if __name__ == '__main__':
    unittest.main()
```

### 8단계 - 컨테이너 이미지 빌드 및 푸시 ✅
```bash
# 이미지 빌드
docker build --tag first-app:v2 .

# ACR에 푸시
docker push shaaksacr.azurecr.io/first-app:v2
```

### 9단계 - 애플리케이션 배포 ✅

**firstapp.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: first-app
spec:
  replicas: 1
  selector:
    matchLabels:
      run: first-app
  template:
    metadata:
      labels:
        run: first-app
    spec:
      containers:
      - name: first-app
        image: shaaksacr.azurecr.io/first-app:v2
        ports:
        - name: http
          containerPort: 80
```

```bash
kubectl apply -f firstapp.yaml
kubectl get pods
```

### 10단계 - 서비스 노출 ✅

**firstappservice.yaml:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: "first-app-service"
spec:
  selector:
    run: "first-app"
  ports:
  - protocol: "TCP"
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

```bash
kubectl apply -f firstappservice.yaml
kubectl get svc
```

### 11단계 - 모니터링 대시보드 설정 ✅

Grafana에서 다음 메트릭 모니터링:
1. CPU 사용량
2. 메모리 사용량
3. 네트워크 사용량

## 결과
- 모든 단계가 성공적으로 완료되었습니다 ✅
- 시스템이 정상적으로 모니터링되고 있습니다 ✅
- 메트릭이 실시간으로 수집되고 있습니다 ✅

## 다음 단계
- 알림 규칙 설정
- 커스텀 대시보드 구성
- 추가 메트릭 모니터링 설정

---
태그: `Azure`, `Kubernetes`, `Monitoring`, `Grafana`, `Prometheus`, `DevOps`


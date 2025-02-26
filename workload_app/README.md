"# tf_demo" 

# 애플리케이션 배포 가이드

## 1. 애플리케이션 구조
```
app/
├── src/              # 애플리케이션 소스 코드
├── Dockerfile        # 컨테이너 이미지 빌드 설정
├── charts/           # Helm 차트
└── .github/          # GitHub Actions 워크플로우
```

## 2. 배포 방법
1. 소스 코드 푸시
2. GitHub Actions 워크플로우 실행
3. AKS 클러스터에 자동 배포

## 3. 모니터링
- Azure Monitor
- Log Analytics
- Prometheus/Grafana 

#!/bin/bash

# Docker 재빌드 및 실행 스크립트
# 사용법: ./rebuild.sh

echo "🔄 Docker 컨테이너 재빌드 및 실행 중..."
echo ""

# 기존 컨테이너 중지 및 제거
echo "📦 기존 컨테이너 중지..."
docker-compose down

# Docker 이미지 재빌드
echo ""
echo "🏗️  Docker 이미지 빌드..."
docker-compose build

# 컨테이너 실행
echo ""
echo "🚀 컨테이너 시작..."
docker-compose up -d

# 상태 확인
echo ""
echo "✅ 완료! 컨테이너 상태:"
docker-compose ps

echo ""
echo "🌐 브라우저에서 확인: http://localhost:8081"
echo ""

# 로그 확인 옵션
read -p "📋 로그를 확인하시겠습니까? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    docker-compose logs -f
fi
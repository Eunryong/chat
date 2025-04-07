FROM node:18-alpine

WORKDIR /app

# 필요한 패키지 설치
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git

# package.json 복사
COPY package*.json ./

# 의존성 설치
RUN npm install

# 소스 코드 복사
COPY . .

# 포트 설정
EXPOSE 8080 8443

# 서버 실행
CMD ["npm", "start"] 
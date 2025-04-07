require('dotenv').config();
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');

const app = express();
app.use(cors());

const server = http.createServer(app);
const io = socketIo(server, {
    cors: {
        origin: '*',
        methods: ['GET', 'POST'],
    },
});

// 연결된 클라이언트 저장
const connectedClients = new Map();

io.on('connection', (socket) => {
    console.log('새로운 클라이언트 연결:', socket.id);

    // 클라이언트 등록
    socket.on('register', (userId) => {
        connectedClients.set(userId, socket.id);
        console.log(`사용자 등록: ${userId} (${socket.id})`);
    });

    // WebRTC 시그널링
    socket.on('offer', (data) => {
        const { to, offer } = data;
        const targetSocketId = connectedClients.get(to);
        if (targetSocketId) {
            io.to(targetSocketId).emit('offer', {
                from: socket.id,
                offer: offer,
            });
        }
    });

    socket.on('answer', (data) => {
        const { to, answer } = data;
        const targetSocketId = connectedClients.get(to);
        if (targetSocketId) {
            io.to(targetSocketId).emit('answer', {
                from: socket.id,
                answer: answer,
            });
        }
    });

    socket.on('ice-candidate', (data) => {
        const { to, candidate } = data;
        const targetSocketId = connectedClients.get(to);
        if (targetSocketId) {
            io.to(targetSocketId).emit('ice-candidate', {
                from: socket.id,
                candidate: candidate,
            });
        }
    });

    // 연결 해제
    socket.on('disconnect', () => {
        console.log('클라이언트 연결 해제:', socket.id);
        for (const [userId, socketId] of connectedClients.entries()) {
            if (socketId === socket.id) {
                connectedClients.delete(userId);
                break;
            }
        }
    });
});

const PORT = process.env.PORT || 8080;
server.listen(PORT, () => {
    console.log(`서버가 포트 ${PORT}에서 실행 중입니다.`);
});

import express from 'express';
import http from 'http';
import mongoose from 'mongoose';
import cors from 'cors';
import jwt from 'jsonwebtoken';
import {Server as SocketIOServer} from 'socket.io';
import authRoutes from './routes/auth';
import {jwtSecret, mongoURI} from './config/config';
import Message from './models/Message';

const app = express();
const server = http.createServer(app);
const io = new SocketIOServer(server, {
    cors: {
        origin: "http://localhost:63342", // Replace with the origin of your client
        methods: ["GET", "POST"],
        allowedHeaders: ["my-custom-header"],
        credentials: true
    }
});

// Middleware
app.use(express.json());
app.use(cors());

// Database connection
mongoose.connect(mongoURI)
    .then(() => console.log('MongoDB connected'))
    .catch((err) => console.log('MongoDB connection error:', err));

// Routes
app.use('/api/auth', authRoutes);

// Socket.io middleware for authentication
io.use((socket, next) => {
    const token = socket.handshake.auth.token;
    try {
        socket.data.user = jwt.verify(token, jwtSecret) as { id: string, username: string };
        next();
    } catch (err) {
        next(new Error('Authentication error'));
    }
});

// Function to emit all messages to a socket
async function emitAllMessages(socket: any) {
    try {
        const messages = await Message.find().sort({ createdAt: 1 }).limit(100);
        socket.emit('allMessages', messages);
    } catch (err) {
        console.error('Error fetching messages:', err);
    }
}

// Chatroom logic
io.on('connection', async (socket) => {
    console.log('New client connected:', socket.data.user.username);
    const welcomeMessage = new Message({
        user: "Chat bot",
        text: socket.data.user.username + " a rejoint le chat",
        createdAt: Date.now()
    });
    await welcomeMessage.save();
    const messages = await Message.find().sort({ createdAt: 1 }).limit(100);

    // Emit the new message to all connected clients
    io.emit('allMessages', messages);

    // Send all messages to the newly connected client
    await emitAllMessages(socket);

    socket.on('chatMessage', async (msg) => {
        try {
            // Save the message to the database
            const newMessage = new Message({
                user: socket.data.user.username,
                text: msg,
                createdAt: Date.now()
            });
            await newMessage.save();

            // Send updated message list to all connected clients
            const messages = await Message.find().sort({ createdAt: 1 }).limit(100);
            io.emit('allMessages', messages);
        } catch (err) {
            console.error('Error saving message:', err);
        }
    });

    socket.on('disconnect', async () => {
        console.log('Client disconnected');
        const leftMessage = new Message({
            user: "Chat bot",
            text: socket.data.user.username + " a quitté le chat",
            createdAt: Date.now()
        });
        await leftMessage.save();

        // Emit the new message to all connected clients
        const messages = await Message.find().sort({ createdAt: 1 }).limit(100);
        io.emit('allMessages', messages);
    });
});

// Start the server
const PORT = process.env.PORT || 8000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
app.get('/', (req, res) => res.json('Server running'));


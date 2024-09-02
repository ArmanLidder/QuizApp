const socket = io('http://localhost:8000');

const registerForm = document.getElementById('registerForm');
const loginForm = document.getElementById('loginForm');
const chatContainer = document.getElementById('chat-container');
const authContainer = document.getElementById('auth-container');
const messagesDiv = document.getElementById('messages');
const messageInput = document.getElementById('messageInput');
const sendButton = document.getElementById('sendButton');
const logoutButton = document.getElementById('logoutButton');

let token = '';

registerForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const username = document.getElementById('registerUsername').value;
    const password = document.getElementById('registerPassword').value;

    try {
        const response = await fetch('http://localhost:8000/api/auth/register', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, password })
        });

        const data = await response.json();
        if (response.ok) {
            alert('Registration successful! Please log in.');
        } else {
            alert(data.msg);
        }
    } catch (err) {
        console.error('Error:', err);
    }
});

loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const username = document.getElementById('loginUsername').value;
    const password = document.getElementById('loginPassword').value;

    try {
        const response = await fetch('http://localhost:8000/api/auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, password })
        });

        const data = await response.json();
        if (response.ok) {
            token = data.token;
            socket.auth = { token };
            socket.connect();
            authContainer.style.display = 'none';
            chatContainer.style.display = 'block';
        } else {
            alert(data.msg);
        }
    } catch (err) {
        console.error('Error:', err);
    }
});

sendButton.addEventListener('click', () => {
    const message = messageInput.value;
    if (message) {
        socket.emit('chatMessage', message);
        messageInput.value = '';
    }
});

logoutButton.addEventListener('click', () => {
    socket.disconnect();
    authContainer.style.display = 'block';
    chatContainer.style.display = 'none';
});

socket.on('allMessages', (messages) => {
    messagesDiv.innerHTML = '';
    messages.forEach(msg => {
        const messageElement = document.createElement('div');
        messageElement.textContent = `${msg.user} ${msg.createdAt}: ${msg.text}`;
        messagesDiv.appendChild(messageElement);
    });
});

socket.on('message', (msg) => {
    const messageElement = document.createElement('div');
    messageElement.textContent = `${msg.user} ${msg.createdAt}: ${msg.text}`;
    messagesDiv.appendChild(messageElement);
});

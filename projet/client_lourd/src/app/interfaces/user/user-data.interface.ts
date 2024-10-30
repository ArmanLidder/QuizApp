export interface User {
    uid: string;
    email: string;
    username: string;
    avatar: string;
    friends: string[];
    currency: number;
    achievements: number[];
    level: number;
    prestige: number;
    isConnected: boolean;
    stats: UserStats;
    loginHistory: LoginHistory[];
    gameHistory: GameHistory[];
    friendRequests: FriendRequest[];
    settings: UserSettings;
}

interface UserStats {
    gamesPlayed: number;
    gamesWon: number;
    avgCorrectAnswers: number;
    avgGameTime: number;
    correctAnswers: number;
    gameTime: number;
}

export interface LoginHistory {
    eventType: 'login' | 'logout';
    timestamp: any;
}

interface GameHistory {
    result: 'win' | 'loss';
    timestamp: any;
    score: number;
    gameMode: string;
}

export interface FriendRequest {
    fromUserId: string;
    toUserId: string;
}

interface UserSettings {
    theme: 'light' | 'dark';
    language: 'en' | 'fr';
    notificationsEnabled: boolean;
}

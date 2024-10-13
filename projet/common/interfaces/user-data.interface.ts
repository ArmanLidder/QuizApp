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
}

interface LoginHistory {
    eventType: 'login' | 'logout';
    timestamp: Date;
}

interface GameHistory {
    result: 'win' | 'loss';
    timestamp: Date;
    score: number;
    gameMode: string;
}

interface FriendRequest {
    fromUserId: string;
    toUserId: string;
    status: 'pending' | 'accepted' | 'rejected';
}

interface UserSettings {
    theme: 'light' | 'dark';
    language: 'en' | 'fr';
    notificationsEnabled: boolean;
}

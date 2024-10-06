interface Statistic {
    playedGames: number;
    wonGames: number;
    goodAnswersPerGame: number;
    avgTimePerGame: number;
}

interface LoginHistory {
    connexion_type: number; // login = 0 and logout = 1
    date: Date;
}

interface GameHistory {
    result: number; // won = 0 and lost = 1
    date: Date;
}

export interface UserData {
    email: string;
    username: string;
    password: string;
    connected: boolean;
    avatar: string;
    friends: string[];
    blocks: string[];
    achievements: number[];
    stats: Statistic;
    login_history: LoginHistory;
    history_game: GameHistory;
}

export interface UserModificationData {
    email: string;
    username: string;
    password: string;
    avatar: string;
}

export interface UserAuthData {
    username: string;
    password: string;
}
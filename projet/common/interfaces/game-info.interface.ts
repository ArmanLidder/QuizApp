export interface GameInfo {
    gameName: string;
    startTime: string;
    playersCount: number;
    bestScore: number;
}

export interface GameConfig {
    hostUserId?: string;
    gameType?: string;
    private?: boolean; // visbilité de la partie
    onGoing?: string; // partie en cours
    price?: number; // prix d'une partie
    friendsOnly?: boolean; // prix d'une partie
    prestige?: number; // niveau de prestige
    IA?: boolean;
}

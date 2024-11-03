export interface GameListItem {
    room: number;
    quizId: string;
    numberOfPlayers: number;
    hostUserId: string;
    gameType: string;
    private: boolean; // visbilité de la partie
    onGoing: boolean; // partie en cours
    price: number; // prix d'une partie
    friendsOnly: boolean; // prix d'une partie
    prestige: number;
}

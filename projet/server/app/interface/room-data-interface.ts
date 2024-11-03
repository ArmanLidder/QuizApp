import { Game } from '@app/classes/game/game';
import { Team } from "@app/classes/team/team";

type TeamId = number;

export interface RoomData {
    room: number;
    quizId: string;
    players: Map<string, string>;
    locked: boolean;
    game: Game;
    timer: NodeJS.Timer;
    bannedNames: string[];
    hostUserId?: string;
    gameType?: string;
    private?: boolean; // visbilité de la partie
    onGoing?: boolean; // partie en cours
    price?: number; // prix d'une partie
    friendsOnly?: boolean; // prix d'une partie
    teams?: Map<TeamId, Team>; // teams
    prestige: number;
}


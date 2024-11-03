import {Service} from 'typedi';
import {HOST_USERNAME} from '@common/names/host-username';
import {RoomData} from '@app/interface/room-data-interface';
import {GameConfig} from "@common/interfaces/game-info.interface";
import {GameListItem} from "@common/interfaces/room-interface";
import {Team} from "@app/classes/team/team";

type SocketId = string;
type Username = string;
type TeamId = number;

const DEFAULT_TEAM_ID = 1;

@Service()
export class RoomManagingService {
    private rooms: Map<number, RoomData>;

    constructor() {
        this.rooms = new Map<number, RoomData>();
    }

    get roomMap() {
        return this.rooms;
    }

    clearRoomTimer(roomId: number) {
        const room = this.getRoomById(roomId);
        if (room) clearInterval(room.timer);
    }

    getRoomById(roomId: number) {
        return this.rooms.get(roomId);
    }

    getGameByRoomId(roomId: number) {
        return this.rooms.get(roomId)?.game;
    }

    addRoom(quizId: string, config?: GameConfig): number {
        const roomId = this.generateUniqueRoomId();
        const roomData: RoomData = {
            room: roomId,
            quizId,
            players: new Map<Username, SocketId>(),
            locked: false,
            game: null,
            bannedNames: [],
            timer: null,
            hostUserId: config.hostUserId,
            gameType: config.gameType,
            private: config.private,
            onGoing: false,
            price: config.price,
            friendsOnly: config.friendsOnly,
            teams: new Map<TeamId, Team>(),
            prestige: config.prestige,
        };
        this.rooms.set(roomId, roomData);
        return roomId;
    }

    deleteRoom(roomId: number): void {
        this.clearRoomTimer(roomId);
        this.rooms.delete(roomId);
    }

    addUser(roomId: number, username: string, socketId: string) {
        this.getRoomById(roomId).players.set(username, socketId);
        // new code
        if (this.getRoomById(roomId).gameType !== 'classic' && HOST_USERNAME !== username) this.addNewUserInTeam(roomId, username)
    }

    getSocketIdByUsername(roomId: number, username: string): string {
        return this.getRoomById(roomId).players.get(username);
    }

    getUsernameBySocketId(roomId: number, userSocketId: string): string {
        const playersMap = this.getRoomById(roomId).players;
        for (const [username] of playersMap.entries()) {
            if (playersMap.get(username) === userSocketId) return username;
        }
        return undefined;
    }

    startGame(roomId: number) {
        const gameConfig: RoomData = this.rooms.get(roomId);
        gameConfig.onGoing = true;
        this.rooms.set(roomId, gameConfig)
    }

    getGamesConfig(): GameListItem[] {
        const gameList: GameListItem[] = []
        this.rooms.forEach((roomData: RoomData, roomCode: number) => {
            let gameItem = {
                room: roomCode,
                quizId: roomData.quizId,
                numberOfPlayers: roomData.players.size,
                hostUserId: roomData.hostUserId,
                gameType: roomData.gameType,
                private: roomData.private,
                onGoing: roomData.onGoing,
                price: roomData.price,
                friendsOnly: roomData.friendsOnly,
                prestige: roomData.prestige,
            } as GameListItem;
            gameList.push(gameItem);
        });
        return gameList;
    }

    createNewTeam(roomId: number, name: string) {
        this.removeUserInTeam(roomId, name);
        const teams = this.getRoomById(roomId).teams;
        const newTeamId = teams.size + 1;
        teams.set(newTeamId, new Team(name));
    }

    joinTeam(roomId: number, name: string, newTeamId: number) {
        const team = this.getRoomById(roomId).teams.get(Number(newTeamId));
        if (team) {
            this.removeUserInTeam(roomId, name);
            team.addMember(name);
        } else {
            this.createNewTeam(roomId, name)
        }
    }

    removeUserFromRoom(roomId: number, name: string): void {
        const playerMap = this.getRoomById(roomId).players;
        playerMap.delete(name);
        // new code
        if (this.getRoomById(roomId).gameType !== 'classic') this.removeUserInTeam(roomId, name);
    }

    removeUserBySocketId(userSocketId: string) {
        for (const [roomId, roomData] of this.rooms.entries()) {
            for (const [username, socketId] of roomData.players.entries()) {
                if (userSocketId === socketId) {
                    this.removeUserFromRoom(roomId, username);
                    return {roomId, username};
                }
            }
        }
        return undefined;
    }

    getUsernamesArray(roomId: number) {
        if (roomId !== undefined) {
            const players = Array.from(this.getRoomById(roomId).players.keys());
            players.splice(players.indexOf(HOST_USERNAME), 1);
            return players;
        } else return undefined;
    }

    banUser(roomId: number, name: string): void {
        this.rooms.get(roomId).bannedNames.push(name);
        this.removeUserFromRoom(roomId, name);
    }

    isNameUsed(roomId: number, name: string): boolean {
        const room = this.getRoomById(roomId);
        return Array.from(room.players.keys()).some((username) => username.toLowerCase() === name.toLowerCase());
    }

    isNameBanned(roomId: number, name: string): boolean {
        const room = this.getRoomById(roomId);
        return Array.from(room.bannedNames).some((username) => username.toLowerCase() === name.toLowerCase());
    }

    isRoomLocked(roomId: number): boolean {
        return this.getRoomById(roomId).locked;
    }

    changeLockState(roomId: number): void {
        const room = this.rooms.get(roomId);
        room.locked = !room.locked;
    }

    private isRoomExistent(code: number): boolean {
        return this.rooms.has(code);
    }

    private generateUniqueRoomId(): number {
        let roomId: number;
        const UPPER_BOUND_MULTIPLIER = 9000;
        const LOWER_BOUND = 1000;
        do {
            roomId = Math.floor(Math.random() * UPPER_BOUND_MULTIPLIER) + LOWER_BOUND;
        } while (this.isRoomExistent(roomId));
        return roomId;
    }

    private addNewUserInTeam(roomId: number, username: string) {
        const teams = this.getRoomById(roomId).teams;
        if (teams.size === 0) teams.set(DEFAULT_TEAM_ID, new Team(username));
        else teams.get(DEFAULT_TEAM_ID).addMember(username);
    }

    private removeUserInTeam(roomId: number, name: string) {
        const teamMap = this.getRoomById(roomId).teams
        teamMap.forEach((team: Team, teamId: number) => {
            if (team.members.includes(name)) {
                const isEmpty = team.removeMember(name);
                if (isEmpty) {
                    teamMap.delete(teamId);
                    this.reassignTeamId(roomId);
                }
            }
        });
    }

    private reassignTeamId(roomId: number) {
        const teamMap = this.getRoomById(roomId).teams
        let id = 1;
        const newTeamMap = new Map<TeamId, Team>();
        if (teamMap) teamMap.forEach((team: Team, teamId: number) => {
            newTeamMap.set(id++, team);
        });
        if (teamMap.size > 0) this.getRoomById(roomId).teams = newTeamMap;
    }
}

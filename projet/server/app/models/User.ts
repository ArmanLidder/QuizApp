import mongoose, { Model } from 'mongoose';
import * as bcrypt from 'bcryptjs'

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

interface NotificationFriend {
    sender_username: string;
}

interface IUser {
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
    friend_request: NotificationFriend;
}

interface IUserMethods {
    comparePassword(candidatePassword: string): Promise<boolean>;
}

type UserModel = Model<IUser, {}, IUserMethods>;

interface UserDocument extends mongoose.Document, IUser, IUserMethods {}

const UserSchema = new mongoose.Schema<UserDocument, UserModel>({
    email: { type: String, required: true },
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    connected: { type: Boolean, default: false},
    avatar: { type: String, required: true },
    friends: [String],
    blocks: [String],
    achievements: [String],
    stats: [{
        playedGames: Number,
        wonGames: Number,
        goodAnswersPerGame: Number,
        avgTimePerGame: Number,
    }],
    login_history: [{
        connexion_type: Number, // login = 0 and logout = 1
        date: Date,
    }],
    history_game: [{
        result: Number, // won = 0 and lost = 1
        date: Date,
    }],
    friend_request : [String]
});

UserSchema.pre<UserDocument>(
    'save',
    async function (next) {
    if (!this.isModified('password')) return next();
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    this.connected = false
    next();
});

UserSchema.methods.comparePassword = async function(this: UserDocument, candidatePassword: string): Promise<boolean> {
    return await bcrypt.compare(candidatePassword, this.password);
};

const User = mongoose.model<UserDocument, UserModel>('User', UserSchema);
export default User;
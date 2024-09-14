import mongoose, { Model } from 'mongoose';
import bcrypt from 'bcryptjs';

interface IUser {
    username: string;
    password: string;
    connected: boolean;
}

interface IUserMethods {
    comparePassword(candidatePassword: string): Promise<boolean>;
}

type UserModel = Model<IUser, {}, IUserMethods>;

interface UserDocument extends mongoose.Document, IUser, IUserMethods {}

const UserSchema = new mongoose.Schema<UserDocument, UserModel>({
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    connected: { type: Boolean, default: false}
});

UserSchema.pre<UserDocument>('save', async function (next) {
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
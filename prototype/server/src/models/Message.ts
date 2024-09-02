import mongoose, { Model } from 'mongoose';

interface IMessage {
    // canal: string
    user: string;
    text: string;
    createdAt: Date;
}

interface MessageDocument extends mongoose.Document, IMessage {}

const MessageSchema = new mongoose.Schema<MessageDocument>({
    // canal: { type: String, required: true }
    user: { type: String, required: true },
    text: { type: String, required: true },
    createdAt: { type: Date, default: Date.now }
});

const Message = mongoose.model<MessageDocument, Model<IMessage, {}>>('Message', MessageSchema);

export default Message;
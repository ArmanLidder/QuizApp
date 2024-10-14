// old will not use
// export interface Message {
//     sender: string;
//     content: string;
//     time: string;
// }

export interface Message {
    userUid: string;
    message: string;
    createdAt?: any;
}

export interface Canal {
    id?: string;
    name: string;
    isPrivate: boolean;
    permittedUsers: string[]; // List of user.uid to check who can join
    messages: Message[];
}

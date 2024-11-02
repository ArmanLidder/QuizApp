import * as admin from 'firebase-admin';
import { ServiceAccount } from 'firebase-admin/lib/credential';
import { Service } from 'typedi';
import * as serviceAccount from "../../../key_firebase.json";

@Service()
export class FirebaseService {
    public db;
    public admin;

    constructor() {
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount as ServiceAccount),
        });
        this.db = admin.firestore();
        this.admin = admin;
    }

    get firestore() {
        return this.db;
    }

    get firebase() {
        return this.admin;
    }
}

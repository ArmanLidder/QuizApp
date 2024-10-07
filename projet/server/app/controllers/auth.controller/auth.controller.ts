import { Request, Response, Router } from 'express';
import { Service } from 'typedi';
import * as jwt from 'jsonwebtoken';
import User from '../../models/User';
import * as multer from 'multer';
import * as path from "path";
import * as process from "process";
import { promises as fs } from 'fs';
import * as dotenv from "dotenv";
dotenv.config()

const EmptyCredentialError = "Le nom utilisateur ne peut pas être vide";
const UserExistError = "L'utilisateur existe déjà";
const UserNotFoundError = "Le nom d'utilisateur n'existe pas";
const WrongPasswordError = "Le mot de passe est incorrect";
const ServerError = "Erreur de serveur";
const AlreadyConnected = "Une autre session est déjà ouverte sur un autre client";


const storage = multer.diskStorage({
    destination: path.join(process.cwd() , '/assets/tmp_avatar'),
    filename: function(req, file, cb){
        const username = req.body.username;


        cb(null, username + path.extname(file.originalname))
    }
});
const upload = multer({storage: storage});


@Service()
export class AuthController {
    router: Router;

    constructor() {
        this.configureRouter();
    }

    private configureRouter(): void {
        this.router = Router();

        this.router.post('/register', upload.single('file'), async (req: any, res: any) => {
            try {
                await this.register(req, res);
            } catch (err) {
                return res.status(500).json({ msg: ServerError });
            }
        });

        this.router.post('/login', async (req: Request, res: Response) => {
            try {
                // Retrieves credential
                const { username, password } = req.body;
                // Validate credential
                if (!username || !password) return res.status(400).json({ msg: EmptyCredentialError });
                const user = await User.findOne({ username }).exec();
                if (!user) return res.status(400).json({ msg: UserNotFoundError });
                const connected = user.connected
                if (connected) return res.status(400).json({ msg: AlreadyConnected })
                const isMatch = await user.comparePassword(password);
                if (!isMatch) return res.status(400).json({ msg: WrongPasswordError });
                const login_data = {
                    connexion_type: 0, // login = 0 and logout = 1
                    date: Date.now(),
                }
                await User.findOneAndUpdate({username}, {connected: true, $push:{login_history: login_data}})
                // Send Auth token if credential are valid
                const token = jwt.sign({ id: user._id, username: user.username }, process.env.JWT_SECRET, { expiresIn: 10000000000 });
                return res.status(200).json({ token });
            } catch (err) {
                // console.error(err); // For Debug purpose
                return res.status(500).json({ msg: ServerError });
            }
        });
    }

    private async register(req: any, res: any) {
        const username = req.body.username;
        const email = req.body.email;
        const password = req.body.password;
        let avatar = req.body.avatar;

        // Check if user already exist before continuing
        let user = await User.findOne({ username }).exec();
        if (user) return res.status(400).json({ msg: UserExistError });

        // For debug purpose

        const userData = {
            email,
            username,
            password,
            avatar,
            friends: ['karim', 'arman', 'test'],
            blocks: ['karim', 'arman', 'test'],
            achievements: [1,2,3],
            currency: 40,
            playerLevel: 12,
            playerPrestige: 302,
            stats: {
                playedGames: 5,
                wonGames: 4,
                goodAnswersPerGame: 10,
                avgTimePerGame: 100.1,
            },
            history_game: [
                {result: 0, date: Date.now()},
                {result: 1, date: Date.now()},
                {result: 1, date: Date.now()},
                {result: 1, date: Date.now()},
                {result: 1, date: Date.now()},

            ],
            friend_request : ['putain', 'de', 'merde']
        }

        user = new User(userData);
        const user_id = user._id.toHexString();
        console.log(user_id)
        await user.save();
        if (!avatar.includes('_')) {
            const new_avatar =  user_id + '.' + avatar.split(".").pop()
            await User.findOneAndUpdate({_id: user_id}, {avatar: new_avatar});
            console.log(`Avatar value before save: ${new_avatar}`);
            await this.saveValidAvatar(avatar, new_avatar);
        }
        return res.status(201).json({msg: "Le compte utilisateur a été crée avec succès!"});
    }

    private async saveValidAvatar(old_filename: string, new_filename: string) {
        try {
            const filepath = process.cwd() + '/assets/tmp_avatar/' + old_filename;
            const destinationPath = process.cwd() + '/assets/avatar/' + new_filename ;

            // Enable read and write permissions
            await fs.chmod(process.cwd() + '/assets/tmp_avatar/', fs.constants.O_RDWR);
            await fs.chmod(process.cwd() + '/assets/avatar/', fs.constants.O_RDWR);

            // Copy the file to the destination
            await fs.copyFile(filepath, destinationPath);
            await fs.unlink(filepath);
        } catch (error) {
            await fs.unlink(process.cwd() + '/assets/tmp_avatar/' + old_filename);
            console.error('Error moving file:', error);
        }
    }
}

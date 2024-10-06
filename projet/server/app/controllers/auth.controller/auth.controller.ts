import { Request, Response, Router } from 'express';
import { Service } from 'typedi';
import { UserModificationData } from "@common/interfaces/user-data.interface";
import * as jwt from 'jsonwebtoken';
import User from '../../models/User';
import * as multer from 'multer';
import * as path from "path";
import * as process from "process";
import { promises as fs } from 'fs';

const jwtSecret = "karim benzema Easter EGG équipe 103"
const EmptyCredentialError = "Le nom utilisateur ne peut pas être vide";
const UserExistError = "L'utilisateur existe déjà";
const UserNotFoundError = "Le nom d'utilisateur n'existe pas";
const WrongPasswordError = "Le mot de passe est incorrect";
const ServerError = "Erreur de serveur";
const AlreadyConnected = "Une autre session est déjà ouverte sur un autre client";
// const UsernameError = "Le nom d'utilisateur ne peut contenir que des lettres et des chiffres, et ne doit pas avoir d'espaces."
// const EmailError = "L'adresse courriel doit être valide. Ex: karimbenzema@polyquiz.ca"

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

        // // Avatar image upload after validation
        // this.router.post('/register/avatar', upload.single('file'), async (req: any, res: any) => {
        //     console.log("adding file ... supposedly!")
        // });

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
                const token = jwt.sign({ id: user._id, username: user.username }, jwtSecret, { expiresIn: 10000000000 });
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
        const avatar = req.body.avatar;

        // Check if user already exist before continuing
        let user = await User.findOne({ username }).exec();
        if (user) return res.status(400).json({ msg: UserExistError });

        const userData: UserModificationData = { email, username, password, avatar }
        user = new User(userData);
        await user.save();
        if (!avatar.includes('_')) {
            console.log('saving it!')
            await this.saveValidAvatar(avatar);
        }
        return res.status(201).json({msg: "Le compte utilisateur a été créer avec succès!"});
    }

    private async saveValidAvatar(filename: string) {
        try {
            const filepath = process.cwd() + '/assets/tmp_avatar/' + filename;
            const destinationPath = process.cwd() + '/assets/avatar/' + filename ;
            // Copy the file to the destination
            await fs.chmod(process.cwd() + '/assets/tmp_avatar/', fs.constants.O_RDWR);
            await fs.chmod(process.cwd() + '/assets/avatar/', fs.constants.O_RDWR);

            await fs.copyFile(filepath, destinationPath);
            await fs.unlink(filepath);
            console.log(`File moved from ${filepath} to ${destinationPath}`);
        } catch (error) {
            console.error('Error moving file:', error);
        }
    }
}

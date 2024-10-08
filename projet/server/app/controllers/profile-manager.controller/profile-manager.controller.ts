import { Request, Response, Router } from 'express';
import { Service } from 'typedi';
import * as jwt from "jsonwebtoken";
import User from '../../models/User';
import { UserProfile } from "@common/interfaces/user-data.interface";
import { UserModificationData } from "@common/interfaces/user-data.interface";
import * as multer from 'multer';
import * as path from "path";
import * as process from "process";
import { promises as fs } from 'fs';
import * as dotenv from "dotenv";
dotenv.config();

const storage = multer.diskStorage({
    destination: path.join(process.cwd() , '/assets/tmp_avatar'),
    filename: function(req, file, cb){
        console.log('Calling Multer storage')
        const username = req.body.username;
        cb(null, username + path.extname(file.originalname))
    }
});
const upload = multer({storage: storage});

@Service()
export class ProfileManagerController {
    router: Router;

    constructor() {
        this.configureRouter();
    }

    private configureRouter(): void {
        this.router = Router();

        this.router.get('/', async (req: Request, res: Response) => {
            console.log("Receiving get profile request")
            try {
                const token = req.headers['authorization'];
                const data = jwt.verify(token, process.env.JWT_SECRET) as { id: string };
                const profileId = data.id
                const profileData: UserProfile = await User.findById(profileId);
                return res.status(200).json(profileData);
            } catch (error) {
                console.log(error);
                return res.status(500).send('Server error');
            }
        });

        this.router.get('/:username', async (req: Request, res: Response) => {
            console.log("Receiving get profile with username request")
            try {
                const token = req.headers['authorization'];
                jwt.verify(token, process.env.JWT_SECRET) as { id: string };
                const username = req.params.username;
                const profileData: UserProfile = await User.findOne({username});
                return res.status(200).json(profileData);
            } catch (error) {
                console.log(error.message)
                return res.status(500).send('Server error');
            }
        });

        this.router.patch('/', upload.single('file'), async (req: Request, res: Response) => {
            console.log("Receiving patch profile request")
            try {
                const token = req.headers['authorization'];
                const data = jwt.verify(token, process.env.JWT_SECRET) as { id: string };
                const userId = data.id;
                const usernameAndAvatar: UserModificationData = req.body;
                let avatarUrl: string = usernameAndAvatar.avatar;
                const username = usernameAndAvatar.username;
                if (!usernameAndAvatar.avatar.includes('_')) {
                    const fileExt = "." + usernameAndAvatar.avatar.split('.').pop();
                    const newFilePath = userId + fileExt;
                    await this.saveValidAvatar(usernameAndAvatar.avatar, newFilePath);
                    avatarUrl = newFilePath;
                }
                const profileData: UserProfile = await User.findOneAndUpdate({_id: userId}, {username: username, avatar: avatarUrl}, {new: true});
                return res.status(200).json(profileData);
            } catch (error) {
                console.log(error.message)
                return res.status(500).send('Server error');
            }
        });
    }

    private async saveValidAvatar(old_filename: string, new_filename: string) {
        try {
            const filepath = process.cwd() + '/assets/tmp_avatar/' + old_filename;
            const destinationPath = process.cwd() + '/assets/avatar/' + new_filename;

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

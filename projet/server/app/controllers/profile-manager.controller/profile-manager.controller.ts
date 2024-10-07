import { Request, Response, Router } from 'express';
import { Service } from 'typedi';
import * as dotenv from "dotenv";
import * as jwt from "jsonwebtoken";
import User from '../../models/User';
import { UserProfile } from "@common/interfaces/user-data.interface";

dotenv.config();


@Service()
export class ProfileManagerController {
    router: Router;

    constructor() {
        this.configureRouter();
    }

    private configureRouter(): void {
        this.router = Router();

        this.router.get('/', async (req: Request, res: Response) => {
            try {
                const token = req.headers['authorization'];
                const data = jwt.verify(token, process.env.JWT_SECRET) as { id: string, username: string };
                const profileId = data.id
                console.log(profileId)
                const profileData: UserProfile = await User.findById(profileId);
                console.log(profileData)
                return res.status(200).json(profileData);
            } catch (error) {
                console.log(error);
                return res.status(500).send('Server error');

            }
        });

        this.router.get('/:username', async (req: Request, res: Response) => {
            try {
                //
                const token = req.headers['authorization'];
                jwt.verify(token, process.env.JWT_SECRET) as { id: string, username: string };
                const username = req.params.username;
                const profileData: UserProfile = await User.findOne({username});
                return res.status(200).json(profileData);
            } catch (error) {
                console.log(error.message)
                return res.status(500).send('Server error');
            }
        });

    }
}

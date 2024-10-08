import { Request, Response, Router } from 'express';
import { Service } from 'typedi';
import * as fs from 'fs';
import * as path from 'path';
import * as process from "process";


@Service()
export class AvatarController {
    router: Router;

    constructor() {
        this.configureRouter();
    }

    private configureRouter(): void {
        this.router = Router();


        this.router.get('/', async (req: Request, res: Response) => {
            console.log("Receiving avatar request")
            try {
                const avatarDir = path.join(process.cwd(), '/assets/avatar');
                fs.readdir(avatarDir, (err, files) => {
                    if (err) return res.status(500).send('Server error while reading directory');

                    // Filter files that start with "default"
                    const defaultAvatars = files.filter(file => file.startsWith('default'));

                    // Check if any default avatars are found
                    if (defaultAvatars.length > 0) return res.status(200).json({defaultAvatars})
                    else return res.status(404).send('No default avatars found');
                });
                return null;
            } catch (error) {
                console.log(error.message)
                return res.status(500).send('Server error');
            }
        });

    }
}

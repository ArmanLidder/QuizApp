import { Router, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import User from '../models/User';
import { jwtSecret } from '../config/config';

const EmptyCredentialError = "Le nom utilisateur ne peut pas être vide";
const EmptySpaceInNameError = "Le nom d'utilisateur ne peut pas contenir d'espaces vides"
const UserExistError = "L'utilisateur existe déjà";
const UserNotFoundError = "Le nom d'utilisateur n'existe pas";
const WrongPasswordError = "Le mot de passe est incorrect";
const ServerError = "Erreur de serveur";
const AlreadyConnected = "Une autre session est déjà ouverte sur un autre client";
const router = Router();

router.post('/register', async (req: Request, res: Response) => {
    try {
        // Retrieves credential
        const { username, password } = req.body;

        const usernameRegex = /^[a-zA-Z0-9]+$/;
        if (!usernameRegex.test(username)) {
            return res.status(400).json({ msg: "Le nom d'utilisateur ne peut contenir que des lettres et des chiffres, et ne doit pas avoir d'espaces." });
        }

        let user = await User.findOne({ username }).exec();
        if (user) return res.status(400).json({ msg: UserExistError });

        // If valid => save new User to BD
        user = new User({ username, password });
        await user.save();

        // Send Auth token which expires in one hour
        const token = jwt.sign({ id: user._id, username: user.username}, jwtSecret, { expiresIn: 3600 });
        res.json({ token });
    } catch (err) {
        // console.error(err); // For debug purpose
        res.status(500).json({ msg: ServerError });
    }
});

router.post('/login', async (req: Request, res: Response) => {
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

        await User.findOneAndUpdate({username}, {connected: true})
        // Send Auth token if credential are valid
        const token = jwt.sign({ id: user._id, username: user.username }, jwtSecret, { expiresIn: 10000000000 });

        res.json({ token });
    } catch (err) {
        // console.error(err); // For Debug purpose
        res.status(500).json({ msg: ServerError });
    }
});

export default router;
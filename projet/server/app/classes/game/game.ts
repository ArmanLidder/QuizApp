import {Answers} from '@app/interface/game-interface';
import {QuizService} from '@app/services/quiz.service/quiz.service';
import {Quiz, QuizChoice, QuizQuestion} from '@common/interfaces/quiz.interface';
import {Score} from '@common/interfaces/score.interface';
import {BONUS_MULTIPLIER, MAX_PERCENTAGE} from '@common/constants/game.const';
import {format, utcToZonedTime} from 'date-fns-tz';
import {GameInfo} from '@common/interfaces/game-info.interface';
import {HistoryService} from '@app/services/history.service/history.service';
import {QuestionType} from "@common/enums/question-type.enum";
import {EXACT_ANSWER, INCORRECT_ANSWER, WITHIN_MARGIN} from "@common/constants/statistic-zone.component.const";

type Username = string;
type Players = Map<Username, Score>;
type PlayerAnswers = Map<Username, Answers>;
type ChoiceStats = Map<string, number>;

type QRECategory = 'Dans l\'intervalle' | 'Exact' | 'Incorrect';
type QREStats = Map<QRECategory, number>;

export class Game {
    currIndex: number = 0;
    quiz: Quiz;
    players: Players = new Map();
    playersAnswers: PlayerAnswers = new Map();
    currentQuizQuestion: QuizQuestion;
    question: string;

    choicesStats: ChoiceStats = new Map();
    qreStats: QREStats = new Map([
        [WITHIN_MARGIN, 0],
        [EXACT_ANSWER, 0],
        [INCORRECT_ANSWER, 0]
    ]);

    //Map where key is userID, value is a pair (qreCategory,answerValue) basically we are always storing a player's most recent value
    playerQREAnswer: Map<string, [QRECategory, number]> = new Map();

    activityStatusStats: [number, number] = [0, 0];
    correctChoices: string[] = [];
    duration: number;
    paused = false;
    startTimeCalcul: number = 0

    gameHistoryInfo: GameInfo = { gameName: '', startTime: '', playersCount: 0, bestScore: 0 };

    constructor(
        usernames: string[],
        private readonly quizService: QuizService,
        private readonly historyService: HistoryService,
    ) {
        this.configurePlayers(usernames);
        this.startTimeCalcul = new Date().getTime();
        this.gameHistoryInfo.playersCount = usernames.length;
        const timeZone = 'America/Montreal';
        const zonedDate = utcToZonedTime(new Date(), timeZone);
        this.gameHistoryInfo.startTime = format(zonedDate, 'yyyy-MM-dd HH:mm:ss', { timeZone });
        console.log("Game History Info Date: ", this.gameHistoryInfo.startTime);
    }

    async setup(id: string) {
        await this.getQuiz(id);
    }

    next() {
        this.playersAnswers.clear();
        this.choicesStats.clear();
        this.qreStats.clear();
        this.currIndex++;
        this.setValues();
    }

    storePlayerAnswer(username: string, time: number, playerAnswer: string[] | string) {
        this.playersAnswers.set(username, { answers: playerAnswer, time: this.duration - time });
    }

    removePlayer(username: string) {
        this.playersAnswers.delete(username);
        this.players.delete(username);
    }

    updateScores() {
        this.playersAnswers.forEach((player, username) => {
            if (this.currentQuizQuestion.type === QuestionType.QCM ){
                if (this.validateAnswer(player.answers as string[])) this.handleGoodAnswer(username);
                else this.handleWrongAnswer(username);
            } else if (this.currentQuizQuestion.type === QuestionType.QRE ){
                const userAnswer = player.answers as string
                const isCorrect = this.validateQREAnswer(userAnswer);
                isCorrect ? this.handleQREGoodAnswer(username) : this.handleWrongAnswer(username);
            }
        });
    }

    validateQREAnswer(answer: string) {
        if (answer === '' || answer === null || answer === undefined) return false;

        const userAnswer = Number(answer);
        if (isNaN(userAnswer)) {
            return false;
        }
        const min = this.currentQuizQuestion.interval.min;
        const max = this.currentQuizQuestion.interval.max;
        const correctAnswer = this.currentQuizQuestion.answer;
        const margin = this.currentQuizQuestion.margin;

        if (userAnswer < min || userAnswer > max) {
            return false;
        }

        const lowerBound = correctAnswer - margin;
        const upperBound = correctAnswer + margin;
        return userAnswer >= lowerBound && userAnswer <= upperBound;
    }


    private handleGoodAnswer(username: string) {
        const oldScore = this.players.get(username);
        const points = this.currentQuizQuestion.points;
        let newScore: Score;

        const fastestPlayers = this.getFastestPlayer();
        if (fastestPlayers) {
            newScore = {
                points: fastestPlayers.has(username) ? oldScore.points + this.addBonusPoint(points) : oldScore.points + points,
                bonusCount: fastestPlayers.has(username) ? oldScore.bonusCount + 1 : oldScore.bonusCount,
                isBonus: fastestPlayers.has(username),
                goodAnswerCounter: oldScore.goodAnswerCounter + 1,
            };
        } else {
            newScore = {
                points: oldScore.points + points,
                bonusCount: oldScore.bonusCount,
                isBonus: false,
                goodAnswerCounter: oldScore.goodAnswerCounter + 1,
            };
        }
        this.players.set(username, newScore);
    }

    private handleQREGoodAnswer(username: string) {
        const oldScore = this.players.get(username);
        const points = this.currentQuizQuestion.points;
        const correctAnswer = this.currentQuizQuestion.answer;

        let newScore: Score;
        const playerAnswer = Number(this.playersAnswers.get(username)?.answers);

        const isExactMatch = playerAnswer === correctAnswer;

        if (isExactMatch && this.currentQuizQuestion.margin !== 0) {
            newScore = {
                points: oldScore.points + this.addBonusPoint(points),
                bonusCount: oldScore.bonusCount + 1,
                isBonus: true,
                goodAnswerCounter: oldScore.goodAnswerCounter + 1,
            };
        }  else {
            newScore = {
                points: oldScore.points + points,
                bonusCount: oldScore.bonusCount,
                isBonus: false,
                goodAnswerCounter: oldScore.goodAnswerCounter + 1,
            };
        }
        this.players.set(username, newScore);
    }


    updateChoicesStats(isSelected: boolean, index: number) {
        const answer = this.currentQuizQuestion.choices[index].text;
        const oldValue = this.choicesStats.get(answer);
        this.choicesStats.set(answer, isSelected ? oldValue + 1 : oldValue - 1);
    }

    updateQREStats(selectedAnswer: number, user: string) {
        const previousAnswer = this.playerQREAnswer.get(user);
        if (previousAnswer) {
            this.qreStats.set(previousAnswer[0],this.qreStats.get(previousAnswer[0])-1) //previousAnswer[0] is one of the three categories exact,within,incorrect
        }
        if (this.currentQuizQuestion.answer === selectedAnswer) {
            this.qreStats.set(EXACT_ANSWER, (this.qreStats.get(EXACT_ANSWER) || 0)+1);
            this.playerQREAnswer.set(user,[EXACT_ANSWER, selectedAnswer]);
        } else if (this.validateQREAnswer(selectedAnswer.toString())){
            this.qreStats.set(WITHIN_MARGIN, (this.qreStats.get(WITHIN_MARGIN) || 0)+1);
            this.playerQREAnswer.set(user,[WITHIN_MARGIN, selectedAnswer]);
        } else {
            this.qreStats.set(INCORRECT_ANSWER, (this.qreStats.get(INCORRECT_ANSWER) || 0)+1);
            this.playerQREAnswer.set(user,[INCORRECT_ANSWER, selectedAnswer]);
        }
    }

    updatePlayerScores(playerCorrections: Map<string, number>) {
        playerCorrections.forEach((percentage, username) => {
            const playerScore = this.players.get(username);
            if (playerScore) {
                playerScore.points = playerScore.points + this.currentQuizQuestion.points * (percentage / MAX_PERCENTAGE);
                playerScore.isBonus = false;
            }
        });
    }

    switchActivityStatus(isActive: boolean) {
        this.activityStatusStats[0] = isActive ? this.activityStatusStats[0] + 1 : this.activityStatusStats[0] - 1;
        this.activityStatusStats[1] = isActive ? this.activityStatusStats[1] - 1 : this.activityStatusStats[1] + 1;
    }

    async updateGameHistory() {
        this.gameHistoryInfo.gameName = this.quiz.title;
        let maxPts = 0;
        for (const score of this.players.values()) {
            maxPts = Math.max(maxPts, score.points);
        }
        this.gameHistoryInfo.bestScore = maxPts;
        await this.historyService.add(this.gameHistoryInfo);
    }

    private validateAnswer(playerAnswers: string[]) {
        if (playerAnswers.length === 0) return false;
        for (const answer of playerAnswers) {
            if (!this.correctChoices.includes(answer)) {
                return false;
            }
        }
        return true;
    }


    private addBonusPoint(points: number) {
        return points * BONUS_MULTIPLIER;
    }

    private handleWrongAnswer(username: string) {
        this.players.get(username).isBonus = false;
        this.playersAnswers.delete(username);
    }

    private getAllPlayersCorrectAnswer() {
        const playersCorrectAnswer: PlayerAnswers = new Map();
        this.playersAnswers.forEach((player, username) => {
            if (this.validateAnswer(player.answers as string[])) {
                playersCorrectAnswer.set(username, player);
            }
        });
        return playersCorrectAnswer;
    }

    private getFastestPlayer() {
        let lowestTime = Infinity;
        const lowestTimePlayers: PlayerAnswers = new Map();
        const playerAnswers = this.getAllPlayersCorrectAnswer();
        for (const [username, answers] of playerAnswers) {
            if (answers.time < lowestTime) {
                lowestTime = answers.time;
                lowestTimePlayers.clear();
                lowestTimePlayers.set(username, answers);
            } else if (answers.time === lowestTime) {
                lowestTimePlayers.set(username, answers);
            }
        }
        return lowestTimePlayers.size === 1 ? lowestTimePlayers : null;
    }

    private configurePlayers(usernames: string[]) {
        usernames.forEach((username) => {
            const score = { points: 0, bonusCount: 0, isBonus: false, goodAnswerCounter: 0 };
            this.players.set(username, score);
        });
    }

    private setValues() {
        this.currentQuizQuestion = this.quiz.questions[this.currIndex];
        this.question = this.currentQuizQuestion.text;
        this.getAllCorrectChoices();
        this.duration = this.quiz.duration;
        this.currentQuizQuestion.choices?.forEach((choice) => {
            this.choicesStats.set(choice.text, 0);
        });
        this.activityStatusStats = [0, this.players.size];
    }

    private getAllCorrectChoices() {
        this.currentQuizQuestion.choices?.forEach((choice: QuizChoice) => {
            if (choice.isCorrect) this.correctChoices.push(choice.text);
        });
    }

    private async getQuiz(quizId: string) {
        this.quiz = await this.quizService.getById(quizId);
        this.setValues();
    }
}

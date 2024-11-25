import {Injectable} from '@angular/core';
import {OpenAI} from 'openai';

@Injectable({
    providedIn: 'root'
})
export class OpenaiService {

    private openai: OpenAI;

    init() {
        this.openai = new OpenAI({
            apiKey: "API_KEY_HERE",
            dangerouslyAllowBrowser: true
        });
    }

    correctAnswer(answer: string, question: string, lang: string) {
        const prompt = this.generatePrompt(answer, question, lang);
        return this.openai.chat.completions.create({
            model: 'gpt-3.5-turbo',
            messages: [{role: 'user', content: prompt}],
        });
    }


    private generatePrompt(answer: string, question: string, lang: string) {
        return lang === "fr" ? `
        Évalue la réponse donnée à la question suivante:
        Question: ${question}
        Réponse: ${answer}

        Aa. 0%
        Bb. 50%
        Cc. 100%

        Justifie avec une phrase de 50 mots et donne le score associé (Aa, Bb Cc)
        ` :
            `
        Evaluate the following answer to the following question:
        Question: ${question}
        Answer: ${answer}
        
        Aa. 0%
        Bb. 50%
        Cc. 100%
        
        Justify with a 50-word sentence and provide the associated score (Aa, Bb, Cc). 
        `
    }
}

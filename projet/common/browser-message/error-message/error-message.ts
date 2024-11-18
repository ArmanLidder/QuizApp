import { HOST_USERNAME } from '../../names/host-username';

export namespace ErrorDictionary {
    export const ISSUES = 'les problèmes suivants'; //unused
    export const ISSUE = 'le problème suivant'; //unused
    export const FILE_CONTAINS = 'Le fichier que vous tenter d\'importer contient le(s) problème(s) suivant(s)'
    export const SOLUTION = '\n\n Veuillez corriger cela. '; //unused
    export const QUIZ_DELETED = 'Ce quiz a été supprimé, veuillez choisir un autre.';
    export const QUIZ_INVISIBLE = 'Ce quiz est maintenant caché, veuillez choisir un autre.';
    export const QUIZ_ALREADY_EXIST = 'Un quiz ayant le même titre existe déjà';
    export const WRONG_PASSWORD = 'Mot de passe incorrect. Veuillez réessayer!';
    export const CHAR_NUM_ERROR = "Le nom de l'utilisateur doit contenir au moins un caractère!"; //unused
    export const ORGANISER_NAME_ERROR = `Le nom de l'utilisateur ne peut pas être ${HOST_USERNAME}!`; //unused
    export const VALIDATION_CODE_ERROR = 'Votre code doit contenir seulement 4 chiffres (ex: 1234)';
    export const ROOM_CODE_EXPIRED = 'Le code ne correspond a aucune partie en cours. Veuillez réessayer';
    export const ROOM_LOCKED = 'La partie est vérouillée. Veuillez réessayer.';
    export const NAME_EMPTY = 'Le nom ne doit pas être vide!';
    export const BAN_MESSAGE = 'Vous avez été banni du lobby et vous ne pouvez plus rentrez.';
    export const NAME_ALREADY_USED = 'Le nom choisi est déjà utiliser. Veuillez choisir un autre.'; //should be unused since names are always unique
    export const ERROR_TITLE_IMPORT = "Erreur lors de l'importation";//unused
}

export namespace SocketEvent {
    export const END_QUESTION = 'endQuestion';
    export const GET_SCORE = 'getScore';
    export const TIME_TRANSITION = 'timeTransition';
    export const FINAL_TIME_TRANSITION = 'finalTimeTransition';
    export const REMOVED_FROM_GAME = 'removedFromGame';
    export const START_TRANSITION = 'startTransition';
    export const SHOW_RESULT = 'showResult';
    export const NEXT_QUESTION = 'nextQuestion';
    export const REFRESH_CHOICES_STATS = 'refreshChoicesStats';
    export const GET_INITIAL_QUESTION = 'getInitialQuestion';
    export const GET_NEXT_QUESTION = 'getNextQuestion';
    export const REMOVED_PLAYER = 'removedPlayer';
    export const END_QUESTION_AFTER_REMOVAL = 'endQuestionFromRemoval';
    export const GATHER_PLAYERS_USERNAME = 'gatherPlayerUsername';
    export const JOIN_GAME = 'playerJoin';
    export const VALIDATE_USERNAME = 'validateUsername';
    export const VALIDATE_ROOM_ID = 'validateRoomId';
    export const GET_MESSAGES = 'getMessages';
    export const GET_USERNAME = 'getUsername';
    export const RECEIVED_MESSAGE = 'messageReceived';
    export const HOST_LEFT = 'hostAbandonnement';
    export const PLAYER_LEFT = 'playerAbandonnement';
    export const GET_QUESTION = 'getQuestion';
    export const SUBMIT_ANSWER = 'submitAnswer';
    export const TIME = 'time';
    export const UPDATE_SELECTION = 'updateSelection';
    export const UPDATE_QRE_SELECTION = 'updateQRESelection'
    export const UPDATE_INTERACTION = 'updateInteraction';
    export const NEW_PLAYER = 'newPlayer';
    export const BAN_PLAYER = 'banPlayer';
    export const TOGGLE_ROOM_LOCK = 'toggleRoomRock';
    export const START = 'start';
    export const CREATE_ROOM = 'createRoom';
    export const CONNECTION = 'connection';
    export const NEW_MESSAGE = 'newMessage'
    export const TOGGLE_CHAT_PERMISSION = 'toggleChatPermission';
    export const SEND_ACTIVITY_STATUS = 'sendActivityStatus';
    export const NEW_RESPONSE_INTERACTION = 'newResponseInteraction';
    export const GET_PLAYER_ANSWERS = 'getPlayerAnswers';
    export const PLAYER_QRL_CORRECTION = 'playerQrlCorrection';
    export const EVALUATION_OVER = 'evaluationOver';
    export const REFRESH_ACTIVITY_STATS = 'refreshActivityStats';
    export const PAUSE_TIMER = 'pauseTimer'
    export const PANIC_MODE = 'panicMode'
    export const GAME_STATUS_DISTRIBUTION = 'gameStatsDistribution';
    export const GET_USER_DATA = 'getUserData';
    export const REFRESH_QRE_STATS= 'refreshQREStats';
    export const UPDATE_GAME_LIST = 'update_game_list';
    export const GET_GAME_LIST = 'get_game_list';
    export const SAVE_FINAL_GAME_STATS = 'save_final_game_stats';

    export const GET_TEAMS = "get_teams";
    export const CREATE_TEAM = "create_team";
    export const JOIN_TEAM = "join_team";

    export const GET_GAME_TYPE = "get_game_type";

    export const NEW_OBSERVER_GAME = "new_observer";
    export const GET_OBSERVER_PLAYER_LIST = "get_observer_player_list";
    export const SENDING_OBSERVER_PLAYER_LIST = "sending_observer_player_list";
    export const CHANGE_OBSERVED_PLAYER = "change_observed_player";
    export const GET_QRE_ANSWER_FOR_OBS = "get_qre_answer_obs";
    export const GET_QRL_INTERACTION = "get_qrl_interaction_obs";
    export const GET_QRL_ANSWER_FOR_OBS = "get_qrl_answer_obs";
    export const INITIAL_HOST_DATA = "initial_host_data";


    export const REQUEST_HOST_GAME_STATUS = "request_host_game_stautus";
    export const RECEIVING_HOST_GAME_STATUS = "receiving_game_status";
    export const SENDING_HOST_GAME_STATUS = "sending_host_game_status";
    export const OBS_QCM_INTERACTION = "obs_qcm_interaction";
    export const RECEIVE_PLAYER_GAME_STATUS = "receive_player_game_status";
}



const int STATUS_INDEX = 3;
const int CAN_TALK = 4;

enum SortType {
  SORT_BY_NAME,
  SORT_BY_SCORE,
  SORT_BY_STATUS,
}

const int ORDER_INITIAL_MULTIPLIER = 1;
const int ORDER_MULTIPLIER = -1;

const String ORDER_ICON_UP = 'fa-solid fa-up-long';
const String ORDER_ICON_DOWN = 'fa-solid fa-down-long';
const int PLAYER_NOT_FOUND_INDEX = -1;

typedef Player = List<dynamic>;
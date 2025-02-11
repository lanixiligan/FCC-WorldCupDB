#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "truncate games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    # get winner team_id
    WIN_TEAM_ID=$($PSQL "select team_id from teams where name = '$WINNER'")
    # if not found
    if [[ -z $WIN_TEAM_ID ]]
    then
      # insert team
      INSERT_TEAM_RESULT=$($PSQL "insert into teams (name) values ('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
      # get new team_id
      WIN_TEAM_ID=$($PSQL "select team_id from teams where name = '$WINNER'")
    fi

    # get opponent team_id
    OPP_TEAM_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")
    # if not found
    if [[ -z $OPP_TEAM_ID ]]
    then
      # insert team
      INSERT_TEAM_RESULT=$($PSQL "insert into teams (name) values ('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
      # get new team_id
      OPP_TEAM_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")
    fi

    # insert game
    INSERT_GAME_RESULT=$($PSQL "insert into games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) values ($YEAR, '$ROUND', $WIN_TEAM_ID, $OPP_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into games, $YEAR, $ROUND, $WIN_TEAM_ID, $OPP_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS
    fi
  fi
done

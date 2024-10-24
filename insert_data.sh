#!/bin/bash
#choses the wordcup test if the first argument is test. ./insert_data.sh "test", OR ./insert_data.sh 
if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Clear existing data
$PSQL "TRUNCATE TABLE games, teams;"

# Read from the CSV file, skipping the header
cat games.csv | tail -n +2 | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  # Insert teams, avoid duplicates
  for team in "$winner" "$opponent"; do
    $PSQL "INSERT INTO teams (name) VALUES ('$team') ON CONFLICT (name) DO NOTHING;"
  done

  # Get team IDs
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")

  # Insert game data
  $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
done

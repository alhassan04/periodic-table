#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

GET_ELEMENT() {
  ATOMIC_NUMBER=$1
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
  NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
  ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
  MELTING_POINT_CELIUS=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
  BOILING_POINT_CELIUS=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
  TYPE=$($PSQL "SELECT type FROM types LEFT JOIN properties USING(type_id) WHERE properties.atomic_number=$ATOMIC_NUMBER;")
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELIUS celsius and a boiling point of $BOILING_POINT_CELIUS celsius."
}

if [[ ! $1 ]]
then
  echo Please provide an element as an argument.
else
  if [[ $1 =~ ^[0-9]+$ ]] 
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
    if [[ -z $ATOMIC_NUMBER ]]
    then
      echo I could not find that element in the database.
    else
      GET_ELEMENT $ATOMIC_NUMBER
    fi
  else
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol='$1'")
    if [[ -z $SYMBOL ]]
    then
      NAME=$($PSQL "SELECT name FROM elements WHERE name='$1'")
      if [[ -z $NAME ]]
      then
        echo I could not find that element in the database.
      else
        ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$NAME'")
        GET_ELEMENT $ATOMIC_NUMBER
      fi
    else
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$SYMBOL'")
      GET_ELEMENT $ATOMIC_NUMBER
    fi
  fi
fi
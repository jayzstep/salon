#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "Please select a service:"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME 
  do
  echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please enter a valid option."
  else
    SERVICE_NAME=$($PSQL"SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    

    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "Please enter a valid option."
    else
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWhat is your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
    echo -e "\nWhat time would you like, please use hh:mm -format"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    FORMATTED_SERVICE_NAME=$(echo $SERVICE_NAME | sed -r 's/^ * |  *$//')
    FORMATTED_SERVICE_TIME=$(echo $SERVICE_TIME | sed -r 's/^ * |  *$//')
    FORMATTED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -r 's/^ * |  *$//')

    echo -e "\nI have put you down for a $FORMATTED_SERVICE_NAME at $FORMATTED_SERVICE_TIME, $FORMATTED_CUSTOMER_NAME."
    fi

    
  fi

}

REMOVE_SPACES() {
$1 | sed -r 's/^ * |  *$//g'
}

MAIN_MENU
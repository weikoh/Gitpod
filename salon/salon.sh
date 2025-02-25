#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU () {
if [[ $1 ]]
then
  echo -e "\n$1"
fi
SERVICES_MENU
}

SERVICES_MENU () {
AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME"
done
read SERVICE_ID_SELECTED
#CUSTOMER_PHONE, CUSTOMER_NAME, and SERVICE_TIME
# is number entered as service id is in database
SERVICE_ID=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")  
if [[ -z $SERVICE_ID ]]
    then
      # send to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      #get customer info
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      #is customer pone in database?
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
      #if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then

        #get new customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
        read SERVICE_TIME

        #insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
       
        fi
      # get customer_id
        CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
        INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments (customer_id, service_id, time) values ('$CUSTOMER_ID','$SERVICE_ID','$SERVICE_TIME')")
        CUSTOMER_SERVICE_NAME=$($PSQL "select name from services where service_id='$SERVICE_ID'")

        echo "I have put you down for a $CUSTOMER_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
 
fi
}
MAIN_MENU

#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

#Displayin available servies

AVAILABLE_SERVICES=$($PSQL "SELECT service_id FROM services")

echo -e "\n~~~ SERVICES IN OUR SALON~~~\n"

function MAIN_MENU()
{
  echo -e "\nServices Available at the moment:\n"
  echo "$AVAILABLE_SERVICES" | while read AVAILABLE_SERVICE_ID 
  do
  
    AVAILABLE_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$AVAILABLE_SERVICE_ID")
    echo  "$AVAILABLE_SERVICE_ID) $AVAILABLE_SERVICE_NAME"

  done
 
  echo -e "\nWhat service would you like to book?"
  read SERVICE_ID_SELECTED

  #if user reponse is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]];then
    MAIN_MENU "Please Select the available menu"

  else
    #if the service_id is not available 
    USR_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $USR_SERVICE_NAME ]]
    then
      echo "The service doesnot exist. Please Try again."
      MAIN_MENU 
    
    else  
      
        echo "Phone number: "
        read CUSTOMER_PHONE             

        #Checking if phone number exists in our database
        CUSTOMER_CHECK=$($PSQL "SELECT customer_id FROM customers WHERE EXISTS(SELECT phone FROM customers where phone = '$CUSTOMER_PHONE')")
        
        if [[ -z $CUSTOMER_CHECK ]] 
        then
          echo -e "\nYou are a new customer\n"
          echo "Your Name: "
          read CUSTOMER_NAME

          INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          
          if [[ $INSERT_CUSTOMER == "INSERT 0 1" ]]
          then
            echo -e "\nNew Customer: $CUSTOMER_NAME with phone: $CUSTOMER_PHONE. Added into our database\n"  
            
            #finding the  customer id
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
            echo "At what time will you want the appointment for $USR_SERVICE_NAME?"
            read SERVICE_TIME

            INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED) ")
          
            if [[ $INSERT_APPOINTMENT == "INSERT 0 1" ]]
            then
              echo -e "\nI have put you down for a $USR_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
            fi 

          fi

        else
          #IF the customer already exists  
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")      
          echo -e "\nWelcome back $CUSTOMER_NAME, Good to see you\n"

          #finding the  customer id
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
          echo "At what time will you want the appointment for $USR_SERVICE_NAME?"
          read SERVICE_TIME

          INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED) ")
          
          if [[ $INSERT_APPOINTMENT == "INSERT 0 1" ]]
          then
            echo -e "\nI have put you down for a $USR_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
          fi
                   
        fi 
    fi
  fi
}

MAIN_MENU








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
    echo  -e "$AVAILABLE_SERVICE_ID) $AVAILABLE_SERVICE_NAME\n"
  done

  echo -e "\nWhat service would you like to book?"
  read SERVICE_ID_SELECTED
  SERVICE_SELECT
}


function SERVICE_SELECT()
{
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
      echo "Are you our regular customer?(y/n)"
      read RES
      
      #Checing for a regular customer
      if [[ $RES == 'Y' || $RES == 'y' ]]
      then
        echo "My dear customer"
      else
        
        
        echo "Phone number: "
        read CUSTOMER_PHONE
        echo "Appointment time: "
        read SERVICE_TIME
        
        #Checking if phone number exists in our database
        PHONE_CHECK=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        if [[ -z $PHONE_CHECK ]] 
        then
          echo "Your Name: "
          read CUSTOMER_NAME
          
          INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSOTMER_PHONE')")
          echo "New Customer: $CUSTOMER_NAME with phone: $CUSTOMER_PHONE. Added into our database"
        fi

      echo "$CUSTOMER_NAME Booked the appointment for $SERVICE_ID_SELECTED)$USR_SERVICE_NAME at: $SERVICE_TIME" 
      fi
    

    fi

  fi
}

MAIN_MENU






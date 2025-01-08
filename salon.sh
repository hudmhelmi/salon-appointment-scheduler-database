#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  # If an argument (message) is passed, display it
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Retrieve list of services
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  
  # Display services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  
  # Prompt for service ID
  echo "Enter the service ID:"
  read SERVICE_ID_SELECTED

  # Validate numeric input
  if [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Invalid input. Please enter a valid numeric service ID."
    return
  fi

  # Check if service exists
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # If the service does not exist, re-display menu with error message
  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
    return
  else
    # Prompt for customer phone
    echo "Enter the customer's phone number:"
    read CUSTOMER_PHONE

    # Check if customer exists
    CUSTOMER_EXISTS=$($PSQL "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # If customer does not exist, create new record
    if [[ -z "$CUSTOMER_EXISTS" ]]
    then 
      echo "Enter the customer's name:"
      read CUSTOMER_NAME
      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    # Retrieve customer info
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # Prompt for appointment time
    echo "Enter the appointment time:"
    read SERVICE_TIME

    # Insert new appointment
    INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time)
                                    VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # Confirm appointment
    echo "I have put you down for a $(echo $SERVICE_NAME_SELECTED | sed -r 's/^ *| *$//g') at \
$(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), \
$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi
}

MAIN_MENU

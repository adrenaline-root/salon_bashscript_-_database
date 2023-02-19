#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
SERVICES=$($PSQL "SELECT * FROM services")

SERVICE_MENU() {
	echo -e "How may we help you today?\n"	
	echo "$SERVICES" | sed 's/|/) /g'
}

echo -e "\n~~ Wellcome to our SALON ~~\n"

SERVICE_MENU

read SERVICE_ID_SELECTED

if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then 
	SERVICE_MENU
else
	SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
	if [[ -z $SERVICE_ID_SELECTED ]]
	then 
		echo "Please, introduce a valid service option."
    SERVICE_MENU
	else
		SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
		
		# get customer info
		echo -e "\nCan you tell me your phone number?\n"
		read CUSTOMER_PHONE
		
		# get customer_id from phone_number
		CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
		
		# if no costumer id found
		if [[ -z $CUSTOMER_ID ]]
		then 
			# insert customer to database
			echo "What's your name?"
			read CUSTOMER_NAME
			$PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
			
			# get costumer id
			CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
		fi
		
		# get service time
		echo -e "\nWhat time you would like to come?"
		read SERVICE_TIME
	
		# insert appointment	
		INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
		
		# if insert appointment was succesfull
		if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
		then 
			echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
		fi
	fi
fi
		
		

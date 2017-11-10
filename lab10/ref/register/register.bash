#!/bin/bash
PATTERN="51201[4][0-9]{4}"
PATTERN2="201[23][0-9]{4}"
PATTERN3="ZS201[34][0-9]{4}"
EXAMPLE_ID="5120140001"
EXAMPLE_ID2="20130001"
EXAMPLE_ID3="ZS20130001"
GROUP="students"
RETURN=1

sudo groupadd $GROUP > /dev/null 2>&1 #make sure group is created before
while [ $RETURN != 0 ]
do

  ID=`dialog --stdout --inputbox  "Input your student ID as your account [ 0 means quit ]:" 15 40`

  if [ $ID == 0 ]; then
    exit
  fi

  if [[ ! $ID =~ $PATTERN ]] || [ ${#ID} != ${#EXAMPLE_ID} ]; then
    if [[ ! $ID =~ $PATTERN3 ]] || [ ${#ID} != ${#EXAMPLE_ID3} ]; then
      if [[ ! $ID =~ $PATTERN2 ]] || [ ${#ID} != ${#EXAMPLE_ID2} ]; then
        dialog --msgbox "Your ID doesn't match the pattern of your student's ID,Please input again!" 15 40
        continue
      fi
    fi
  fi

  sudo useradd -G docker -g $GROUP -s /bin/bash -d /home/$ID $ID > /dev/null 2>&1

  RETURN=$?

  if [ $RETURN != 0 ]; then
    dialog --msgbox  "The account you chosen is invalid, please try again!" 15 40
  fi

done

sudo mkdir /home/$ID
sudo chown $ID /home/$ID -R
sudo chmod 700 /home/$ID

echo "Set password of your account:"
if ! sudo passwd $ID
then
  sudo userdel -r $ID > /dev/null 2>&1
  dialog --msgbox  "ERROR, Your account $ID is NOT setup, please try again!" 15 40
else
#clear
  dialog --msgbox  "Congratulation! Your account $ID is setup. " 15 40
fi

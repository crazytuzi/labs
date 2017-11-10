for i in /home/*
  do 
    USERS=${i##*/}
    echo $USERS
    chown -R $USERS $i
  done

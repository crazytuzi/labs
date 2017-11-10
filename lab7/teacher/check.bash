#!/bin/bash
#DESCRIPTION: this script is used to create a container and check student's result
#OPERATE METHOD: check.bash  exp_num  Eg:  check.bash  
#HISTORY:
#        2016/04/28 zch first release
#        2016/05/13 zch second add GUI
#        2016/05/13 zch third  add statistics

LAB_IP_PATTERN="^10.11."
PUBLIC_DOMAIN="vlab.cs.swust.edu.cn"
IMAGE="libo/exp_server:v5.0"
SUBMIT_DIR="/data/submit"
EXP_PATTERN="^lab[0-9]{1,}"
CONTAINER_PORT="8888"

# 1----from local, no ssh
# 2----from Lab
sshFromOuter()
{
# Get IP where user 'ssh'es from
CLIENT_IP=$(echo $SSH_CLIENT | awk '{print $1}')

if [ -z $CLIENT_IP ] 
  then
    return 1
  else
    if [[ $CLIENT_IP =~ ${LAB_IP_PATTERN} ]]
      then
        return 2
      else
        return 0
    fi
fi

}

create()
{
if ! docker inspect $USER > /dev/null 2>&1 
  then
    docker run --name $USER \
    --user root \
    -e NB_UID=$(id -u $USER) \
    -e GRANT_SUDO=yes \
    -v "$1":/notebooks \
    -d $IMAGE \
    start-notebook.sh \
    --notebook-dir=/notebooks \
    > /dev/null 2>&1
  fi
}

myaddress()
{
CONTAINER_IP=$(docker inspect $USER | grep "IPAddress" | grep -Pom 1 '[0-9.]{7,15}')

if [ -z ${CONTAINER_IP} ]
  then
    echo "Not start yet!"
    return 1
fi

if sshFromOuter
  then
    TMP_PORT=`echo $CONTAINER_IP | awk -F "." '{printf $4}'`
    PUBLIC_PORT=`printf "%03d" $TMP_PORT`        
    IP=${PUBLIC_DOMAIN}
    PORT=50${PUBLIC_PORT}
  else
    # start from lab or locally
    IP=${CONTAINER_IP}
    PORT=${CONTAINER_PORT}
fi

echo "Please open your web browser, visit http://${IP}:${PORT}/"

}

# search student's score for list
printscore()
{
if [ ! -z $1 -a -f $1 ]
 then
   SCORE=
   readscore $1 $2
   if [ ! -z "${SCORE}" ]
     then
       echo \($SCORE\)
   fi
fi
}

readscore()
{
if [ ! -z $1 -a -f $1 ]
 then
    SCORE=$(grep ^$2 $1)
fi
}

# read lab for checking
read -p "Input lab# for checking:" LAB 

test -z $LAB && exit 1
# print list of students
INDEX=1
SCOREFILE=${SUBMIT_DIR}/.score/lab${LAB}
test -d ${SUBMIT_DIR}/.score || sudo mkdir ${SUBMIT_DIR}/.score
test -f ${SCOREFILE} || sudo touch ${SCOREFILE}
for DIR in ${SUBMIT_DIR}/*
  do
    if [ -d ${DIR}/lab${LAB} ]
      then
        SCORE=
        echo -n "$INDEX  "
        readscore $SCOREFILE ${DIR##*/}
        if [ ! -z "${SCORE}" ]
          then
            echo $SCORE
          else
            echo "${DIR##*/}"
        fi
        INDEX=$(($INDEX+1))
      fi
  done
SCORE=

# read start ID for checking
read -p "Input start student ID for checking:" ID

test -z $ID && exit 1
# create docker and mount every student's submition
START=1
for DIR in ${SUBMIT_DIR}/*
  do
    if [ ! ${START} == 0 ]
      then
        if [ ${DIR##*/} == $ID ]
          then
            START=0
        fi
    fi
    if [ ${START} == 0 ]
      then
        if [ -d ${DIR}/lab${LAB} ]
          then
            echo "=============Checking student ${DIR##*/} ==============="
            # read .score
            printscore $SCOREFILE ${DIR##*/}

            echo "Openning experiment environment, please wait ......" 

            docker inspect $USER > /dev/null 2>&1 && \
            docker rm -f $USER > /dev/null 2>&1 
            create ${DIR}/lab${LAB}

            myaddress

            read -p "Mark this experiment (enter:skip, q:quit): " INPUT
            if [ ! -z $INPUT ]
              then
                if [ ! $INPUT = "q" -a ! $INPUT = "Q" ]
                  then
                    if grep -i ^${DIR##*/} ${SCOREFILE} >/dev/null 2>&1
                      then
                        echo "Marked, ignored"
                      else
                        sudo bash -c "echo ${DIR##*/},$INPUT,${USER},$(date) >> $SCOREFILE"
                    fi
                  else
                    break
                fi
            fi
        fi
    fi
  done
#close
docker inspect $USER > /dev/null 2>&1 &&
docker rm -f $USER > /dev/null 2>&1 

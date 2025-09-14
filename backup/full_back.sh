#!/bin/bash

TASK="full_back"
BACK_DIR=$1
DB_USER=$2
DB_PASS=$3

LOG_DIR="${BACK_DIR}/log"
LOG_FILE=""

function make_logs()
{
	mkdir -p "$LOG_DIR"

	DATE=$(date +%Y%m%d%H%M%S)
	LOG_FILE="${LOG_DIR}/${TASK}_${DATE}.log"
	touch $LOG_FILE
}

function print_msg()
{
	Message=$1
	Date=$(date "+%Y%m%d %H:%M:%S")
	echo "${Date} [${TASK}] ${Message}" >> $LOG_FILE
	echo "${Date} ${Message}"
}

if [ -z "${BACK_DIR}" ]; then
	echo "Missing \$BACK_DIR Parameters."
	exit 1;
fi

make_logs

print_msg "#------------------------"
print_msg "# Start ${TASK}"
print_msg "#------------------------"

set -o pipefail

if [ -z "${DB_USER}" ]; then
	mysqldump -A 2>>$LOG_FILE | gzip > "${BACK_DIR}/${HOSTNAME}_${TASK}_$(date +%Y%m%d%H%M%S).sql.gz"
else
	mysqldump -u ${DB_USER} -p${DB_PASS} -A 2>>$LOG_FILE | gzip > "${BACK_DIR}/${HOSTNAME}_${TASK}_$(date +%Y%m%d%H%M%S).sql.gz"
fi

if [ $? -ne 0 ]; then
	print_msg "[ERROR] mysqldump failed at $(date)"
	exit 1
fi

print_msg "#------------------------"
print_msg "# End ${TASK}"
print_msg "#------------------------"

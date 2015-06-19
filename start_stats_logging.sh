#!/bin/bash
###################################################################
# This script logs server stats like iostat -xt, iostat -xd for a specific file system
# It also logs server stats like  free -m , vmstat  
# It also creates a script that is used for stopping the stats logging and launching 
# log conversion utility. This stop script (stop_stats_logging.sh) is dynamically created  
# as it needs the pids and the log files names from the current run
# You can un/comment what you need to log using the sets of PROCs and PIDs 
# or add more PROCs for more types of logging
# Usage: ./ <this_script_file_name>.sh
###################################################################
# Before using this script, enter the io filesystem device in IODEVICE for which stats has to be collected
# Get the device name using command: df <the directory path>
# The directory path will be the directory where the files reside e.g. data directory for which 
# the io activity needs to be measured  
# Example, for the /srv directory...run these commands....
# [root@db1v1 tmp]# df /srv
# Filesystem     1K-blocks    Used Available Use% Mounted on
# /dev/vda1       30961660 9315608  20073292  32% /
# So /dev/vda1 is the filesystem device to use - IODEVICE 
# Provide the extension to be used in the log file name - LOGFILE_EXTENSION
# Provide the interval in seconds to be used to capture iostat - INTERVAL 
###################################################################
# Disclaimer: This script is field developed for general testing purposes.
# This script is not Supported by IBM.
#
# Author: Anuj Jain
# Email: jainanuj@us.ibm.com
# Date/Version: 2015-05-15
###################################################################

IODEVICE=/dev/vda
LOGFILE_EXTENSION=dev_vda1
INTERVAL=2


# Other advanced configuration may not need to be changed
# Report the logfile names, processess,  pids so that logging can be killed/stopped later.
# Hostname and Timestamp will be appended to log file for each run.
HOSTNAME=`hostname -s`
TSTAMP=`date +%Y-%m-%d.%H.%M.%S`
LOGFILE_EXTENSION=$HOSTNAME-$LOGFILE_EXTENSION-$TSTAMP
LOGFILE_CONVERTER_SCRIPT=convert_log_to_csv.sh

PROC1="iostat -xt"
PID1=""
LOGFILENAME1="iostat_xt-"$LOGFILE_EXTENSION.log
LOGFILEPROCESSOR_ARG1=iostat_xt

PROC2="iostat -dt"
PID2=""
LOGFILENAME2="iostat_dt-"$LOGFILE_EXTENSION.log
LOGFILEPROCESSOR_ARG2=iostat_dt

PROC3="free -m"
PID3=""
LOGFILENAME3="memstat-"$LOGFILE_EXTENSION.log
LOGFILEPROCESSOR_ARG3=memstat

PROC4="vmstat"
PID4=""
LOGFILENAME4="vmstat-"$LOGFILE_EXTENSION.log
LOGFILEPROCESSOR_ARG4=vmstat

# Following commands start the logging processes
nohup $PROC1 $IODEVICE $INTERVAL > $LOGFILENAME1 &
nohup $PROC2 $IODEVICE $INTERVAL > $LOGFILENAME2 &
nohup $PROC3 -s$INTERVAL > $LOGFILENAME3 &
nohup $PROC4 -t -n $INTERVAL > $LOGFILENAME4 &

# Get the process pids for later use
PID1=`ps -ef | grep "$PROC1" | grep -v grep | awk 'NR==1' |  awk '{print $2}'`
PID2=`ps -ef | grep "$PROC2" | grep -v grep | awk 'NR==1' |  awk '{print $2}'`
PID3=`ps -ef | grep "$PROC3" | grep -v grep | awk 'NR==1' |  awk '{print $2}'`
PID4=`ps -ef | grep "$PROC4" | grep -v grep | awk 'NR==1' |  awk '{print $2}'`

echo
echo "---------"
echo "Logging started for device $IODEVICE with the following processes and pids..."
echo $PROC1 : $PID1
echo $PROC2 : $PID2
echo $PROC3 : $PID3
echo $PROC4 : $PID4
echo "Log files will be saved with extension $LOGFILE_EXTENSION"
echo

# Create the processes kill and log conversion launch script
echo "#!/bin/bash" > stop_stats_logging.sh
echo "# This script is used for stopping the stats logging and launching"  >> stop_stats_logging.sh
echo "# log conversion utility. This stop script (stop_stats_logging.sh) is dynamically created"  >> stop_stats_logging.sh
echo "# by start_stats_logging.sh as it needs the pids and the log files names from the run"  >> stop_stats_logging.sh
echo "echo \"Stopping statslogging by killing processes $PID1 $PID2 $PID3 $PID4\"" >> stop_stats_logging.sh
echo "kill -9 $PID1 $PID2 $PID3 $PID4" >> stop_stats_logging.sh
echo "echo \"Done.\"" >> stop_stats_logging.sh
echo "echo " >> stop_stats_logging.sh
echo "echo \"Current raw log files have extension $LOGFILE_EXTENSION\"" >> stop_stats_logging.sh
echo "echo \"Select next action: [C]Convert raw files to CSV [D]Discard the raw log files [S]Skip and do nothing.\"" >> stop_stats_logging.sh
echo "echo -n \"Enter C | D | S: \"" >> stop_stats_logging.sh
echo "read nextaction"  >> stop_stats_logging.sh
echo "echo \"You entered: \$nextaction\" " >> stop_stats_logging.sh
echo "if [ \"\$nextaction\" == \"C\" ]" >> stop_stats_logging.sh
echo "then" >> stop_stats_logging.sh
echo "        echo \"Converting raw logs to CSV. This can take sometime depending on log sizes. Please be patient.\"" >> stop_stats_logging.sh
echo "        ./$LOGFILE_CONVERTER_SCRIPT $LOGFILEPROCESSOR_ARG1 $LOGFILENAME1" >> stop_stats_logging.sh
echo "        ./$LOGFILE_CONVERTER_SCRIPT $LOGFILEPROCESSOR_ARG2 $LOGFILENAME2" >> stop_stats_logging.sh
echo "        ./$LOGFILE_CONVERTER_SCRIPT $LOGFILEPROCESSOR_ARG3 $LOGFILENAME3" >> stop_stats_logging.sh
echo "        ./$LOGFILE_CONVERTER_SCRIPT $LOGFILEPROCESSOR_ARG4 $LOGFILENAME4" >> stop_stats_logging.sh
echo "        echo \"Converted log files to CSV. Done.\"" >> stop_stats_logging.sh
echo "fi" >> stop_stats_logging.sh
echo "if [ \"\$nextaction\" == \"D\" ]" >> stop_stats_logging.sh
echo "then" >> stop_stats_logging.sh
echo "        echo \"Deleting raw log files with extension $LOGFILE_EXTENSION....\"" >> stop_stats_logging.sh
echo "        rm -f  $LOGFILENAME1" >> stop_stats_logging.sh
echo "        rm -f  $LOGFILENAME2" >> stop_stats_logging.sh
echo "        rm -f  $LOGFILENAME3" >> stop_stats_logging.sh
echo "        rm -f  $LOGFILENAME4" >> stop_stats_logging.sh
echo "fi" >> stop_stats_logging.sh
echo "if [ \"\$nextaction\" == \"S\" ]" >> stop_stats_logging.sh
echo "then" >> stop_stats_logging.sh
echo "        echo \"Leaving raw log files as is.\"" >> stop_stats_logging.sh
echo "fi" >> stop_stats_logging.sh
echo "echo Done."  >> stop_stats_logging.sh
chmod 755 stop_stats_logging.sh
#echo "rm -f stop_stats_logging.sh" >> stop_stats_logging.sh

echo "---------"
#ps -ef | grep iostat
echo "- Make sure to kill the processes after you are done otherwise they will keep logging indefinitely."
#echo  - "Use command 'kill -9 $PID1 $PID2 $PID3 $PID4' to kill the logging processes that were just started."
echo "- Use 'ps -ef | grep iostat' , 'ps -ef | grep vmstat' ,  and 'ps -ef | grep free' to check and identify the processes and pids."
echo "- Or, run the script ./stop_stats_logging.sh that will be saved in the directory with the kill command and pids."
  
echo




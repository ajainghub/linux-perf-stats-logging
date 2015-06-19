#!/bin/bash
###################################################################
# This script processes iostat,vmstat,free command output files to create a CSV
# Usage: <thisscriptfilename>.sh <logtype> <input log file name>
###################################################################
# This script is largely a generic processor for files that have repeated sets of data lines
# and the lines need to be aggregated into one CSV type output
# INITIAL_LINE_OFFSET sets the number of initial lines that should be skipped before meaningful data lines begin
# DATA_LINE_RESET is the number of lines in the repeated set of data lines. These will be processed and combined to 
# one single output line OUTPUT_LINE  
# LINE_NUMBER is the actual line number that is being read from the file
# DATA_LINE_NUMBER is the line number in any set of data lines 
##################################################################
# Disclaimer: This script is field developed for general testing purposes.
# This script is not Supported by IBM.
#
# Author: Anuj Jain
# Email: jainanuj@us.ibm.com
# Date/Version: 2015-05-15
##################################################################

if [ "$#" -ne 2 ]
        then
        echo "No argument supplied. Usage:  ./convert_log_to_csv.sh < iostat_xt | iostat_dt | vmstat | memstat > <raw log file name>"
        exit
fi
CONVERSION_STATUS=0

##########################################################################################
##########################################################################################
##########################################################################################

if [ "$1" == "iostat_xt" ]
then
echo "Converting iostat_xt file type $1 to CSV..."
#log file name that will be precessed (entered as cmd line param)
LOG_FILENAME="$2"
OUTPUT_FILENAME=$2.csv
#Variables for processing file
INITIAL_LINE_OFFSET=2
DATA_LINE_RESET=7
#If all the data should be logged or only selected KPIs
#If selected KPIs are used then the headers must be updated to match the data that is extracted for writing to csv
LOG_KPIS="SELECTED" # "ALL" | "SELECTED"

#create new output file with relevant initial entries
#echo "Output for $LOGFILENAME. CSV Headers will go here." > $OUTPUT_FILENAME
OUTPUT_HEADERS_ALL="Timestamp,CPU%user,CPU%nice,CPU%system,CPU%iowait,CPU%steal,CPU%idle,IO-rrqm/s,IO-wrqm/s,IO-r/s,IO-w/s,IO-rsec/s,IO-wsec/s,IO-avgrq-sz,IO-avgqu-sz,IO-await,IO-svctm,IO-%util"
OUTPUT_HEADERS_SELECTED="Timestamp,CPU%iowait,CPU%idle,IO-%util"

if [ "$LOG_KPIS" == "ALL" ]
then
OUTPUT_HEADERS=$OUTPUT_HEADERS_ALL
fi
if [ "$LOG_KPIS" == "SELECTED" ]
then
OUTPUT_HEADERS=$OUTPUT_HEADERS_SELECTED
fi
echo $OUTPUT_HEADERS > $OUTPUT_FILENAME

#Start processing
LINE_NUMBER=0
DATA_LINE_NUMBER=0

echo "Starting to process file $1....."
while read -r line
do
	LINE_NUMBER=`expr $LINE_NUMBER + 1`
	DATA_LINE_NUMBER=`expr $DATA_LINE_NUMBER + 1`

	if [ "$LINE_NUMBER" -lt `expr $INITIAL_LINE_OFFSET + 1` ]
	then
		#echo "Skipping inital offset line $LINE_NUMBER"
		DATA_LINE_NUMBER=0
	else
	        if [ "$DATA_LINE_NUMBER" -gt "$DATA_LINE_RESET" ]
        	then
			#reset data line to 1
			DATA_LINE_NUMBER=1              

			#write the line contents known so far
                        #OUTPUT_LINE=$(echo $OUTPUT_LINE | tr -d '\n')
                        echo $OUTPUT_LINE >> $OUTPUT_FILENAME

			#reset for captuting next line content
			OUTPUT_LINE=""
        	fi

		#linecontent=$line
		#echo "line content $linecontent"
		#echo $LINE_NUMBER:$DATA_LINE_NUMBER:$line >> $OUTPUT_FILENAME

                #Logic on how should the content from each line be extracted to build output lines..
                case "$DATA_LINE_NUMBER" in
	
                        1)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine1--$line >> $OUTPUT_FILENAME
				#This is the timestamp 
				#04/16/2015 11:39:08 AM
				#Write as is based on output headers
				OUTPUT_LINE=$line
                                ;;
                        2)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine2--$line >> $OUTPUT_FILENAME
				#This is a header line 
				#avg-cpu:  %user   %nice %system %iowait  %steal   %idle                             
				#Write as nothing just skip
				;;
                        3)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine3--$line >> $OUTPUT_FILENAME
				#This is line with values of above headers 
				#           3.62    0.00    2.25    0.94    0.04   93.16                                
				#Write as tokenized values based on ouptput headers
                                tok1=$(echo $line | cut -d' ' -f1)
                                tok2=$(echo $line | cut -d' ' -f2)
                                tok3=$(echo $line | cut -d' ' -f3)
                                tok4=$(echo $line | cut -d' ' -f4)
                                tok5=$(echo $line | cut -d' ' -f5)
                                tok6=$(echo $line | cut -d' ' -f6)
                                #OUTPUT_LINE=$OUTPUT_LINE,$tok1,$tok2,$tok3,$tok4,$tok5,$tok6
				if [ "$LOG_KPIS" == "ALL" ]
				then
	      	                       OUTPUT_LINE=$OUTPUT_LINE,$tok1,$tok2,$tok3,$tok4,$tok5,$tok6
				fi
				if [ "$LOG_KPIS" == "SELECTED" ]
				then
	                               OUTPUT_LINE=$OUTPUT_LINE,$tok4,$tok6
				fi
				;;
                        4)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine4--$line >> $OUTPUT_FILENAME
				#This is blank line 
				#
				#Write as nothing just skip.
				;;
                        5)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine5--$line >> $OUTPUT_FILENAME
				#This is another header line 
				#Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s avgrq-sz avgqu-sz   await  svctm  %util
				#Write as nothing just skip
                                ;;
                        6)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine6--$line >> $OUTPUT_FILENAME
				#This is line with data of above headers 
				#vda               0.07     8.31    2.00    6.23   151.82   116.39    32.57     0.10   11.59   1.61   1.33
				#Write as tokenized values based on ouptput headers
                                tok1=$(echo $line | cut -d' ' -f1)
                                tok2=$(echo $line | cut -d' ' -f2)
                                tok3=$(echo $line | cut -d' ' -f3)
                                tok4=$(echo $line | cut -d' ' -f4)
                                tok5=$(echo $line | cut -d' ' -f5)
                                tok6=$(echo $line | cut -d' ' -f6)
                                tok7=$(echo $line | cut -d' ' -f7)
                                tok8=$(echo $line | cut -d' ' -f8)
                                tok9=$(echo $line | cut -d' ' -f9)
                                tok10=$(echo $line | cut -d' ' -f10)
                                tok11=$(echo $line | cut -d' ' -f11)
                                tok12=$(echo $line | cut -d' ' -f12)
                                #OUTPUT_LINE=$OUTPUT_LINE,$tok2,$tok3,$tok4,$tok5,$tok6,$tok7,$tok8,$tok9,$tok10,$tok11,$tok12
                                if [ "$LOG_KPIS" == "ALL" ]
                                then    
                                       OUTPUT_LINE=$OUTPUT_LINE,$tok2,$tok3,$tok4,$tok5,$tok6,$tok7,$tok8,$tok9,$tok10,$tok11,$tok12
                                fi
                                if [ "$LOG_KPIS" == "SELECTED" ]
                                then
                                       OUTPUT_LINE=$OUTPUT_LINE,$tok12
                                fi 		
				;;
                        7)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine7--$line >> $OUTPUT_FILENAME
				#This is the last and a blank line
				#
				#Write as nothing just skip
				;;
                        #8)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine8--$line >> $OUTPUT_FILENAME
                        #        #This is xxxx line
                        #        #
                        #        #Write as
			#	 #logic goes here
                        #        ;;

                        *)      echo "Beyond known number of data lines set. If you see this then something is wrong in the original file or processing."$line >> $OUTPUT_FILENAME
		                ;;
                esac

	fi

done < "$LOG_FILENAME"
echo "Done. Processed file saved as $OUTPUT_FILENAME"
CONVERSION_STATUS=1

fi # End of if for processing iostat_xt

##########################################################################################
##########################################################################################
##########################################################################################


if [ "$1" == "iostat_dt" ]
then
echo "Converting iostat_dt file type $1 to CSV..."
#log file name that will be precessed (entered as cmd line param)
LOG_FILENAME="$2"
OUTPUT_FILENAME=$2.csv
#Variables for processing file
INITIAL_LINE_OFFSET=2
DATA_LINE_RESET=4
#If all the data should be logged or only selected KPIs
#If selected KPIs are used then the headers must be updated to match the data that is extracted for writing to csv
LOG_KPIS="SELECTED" # "ALL" | "SELECTED"

#create new output file with relevant initial entries
#echo "Output for $LOGFILENAME. CSV Headers will go here." > $OUTPUT_FILENAME
OUTPUT_HEADERS_ALL="Timestamp,IO-tps,IO-Blk_read/s,IO-Blk_wrtn/s,IO-Blk_read,IO-Blk_wrtn"
OUTPUT_HEADERS_SELECTED="Timestamp,IO-tps,IO-Blk_read,IO-Blk_wrtn"

if [ "$LOG_KPIS" == "ALL" ]
then
OUTPUT_HEADERS=$OUTPUT_HEADERS_ALL
fi
if [ "$LOG_KPIS" == "SELECTED" ]
then
OUTPUT_HEADERS=$OUTPUT_HEADERS_SELECTED
fi

echo $OUTPUT_HEADERS > $OUTPUT_FILENAME

#Start processing
LINE_NUMBER=0
DATA_LINE_NUMBER=0

echo "Starting to process file $1....."
while read -r line
do
	LINE_NUMBER=`expr $LINE_NUMBER + 1`
	DATA_LINE_NUMBER=`expr $DATA_LINE_NUMBER + 1`

	if [ "$LINE_NUMBER" -lt `expr $INITIAL_LINE_OFFSET + 1` ]
	then
		#echo "Skipping inital offset line $LINE_NUMBER"
		DATA_LINE_NUMBER=0
	else
	        if [ "$DATA_LINE_NUMBER" -gt "$DATA_LINE_RESET" ]
        	then
			#reset data line to 1
			DATA_LINE_NUMBER=1              

			#write the line contents known so far
                        #OUTPUT_LINE=$(echo $OUTPUT_LINE | tr -d '\n')
                        echo $OUTPUT_LINE >> $OUTPUT_FILENAME

			#reset for captuting next line content
			OUTPUT_LINE=""
        	fi

		#linecontent=$line
		#echo "line content $linecontent"
		#echo $LINE_NUMBER:$DATA_LINE_NUMBER:$line >> $OUTPUT_FILENAME

                #Logic on how should the content from each line be extracted to build output lines..
                case "$DATA_LINE_NUMBER" in
	
                        1)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine1--$line >> $OUTPUT_FILENAME
				#This is the timestamp 
				#04/16/2015 11:39:08 AM
				#Write as is based on output headers
				OUTPUT_LINE=$line
                                ;;
                        2)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine2--$line >> $OUTPUT_FILENAME
				#This is a header line 
				#Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
				#Write as nothing just skip
				;;
                        3)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine3--$line >> $OUTPUT_FILENAME
				#This is line with values of above headers 
				#vda               8.23       151.82       116.39  721533106  553147936                                
				#Write as tokenized values based on ouptput headers
                                tok1=$(echo $line | cut -d' ' -f1)
                                tok2=$(echo $line | cut -d' ' -f2)
                                tok3=$(echo $line | cut -d' ' -f3)
                                tok4=$(echo $line | cut -d' ' -f4)
                                tok5=$(echo $line | cut -d' ' -f5)
                                tok6=$(echo $line | cut -d' ' -f6)
                                #OUTPUT_LINE=$OUTPUT_LINE,$tok2,$tok3,$tok4,$tok5,$tok6
                                if [ "$LOG_KPIS" == "ALL" ]
                                then
					OUTPUT_LINE=$OUTPUT_LINE,$tok2,$tok3,$tok4,$tok5,$tok6
                                fi
                                if [ "$LOG_KPIS" == "SELECTED" ]
                                then
					OUTPUT_LINE=$OUTPUT_LINE,$tok2,$tok5,$tok6
                                fi
				;;
                        4)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine4--$line >> $OUTPUT_FILENAME
				#This is blank line 
				#
				#Write as nothing just skip.
				;;
                        #8)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine8--$line >> $OUTPUT_FILENAME
                        #        #This is xxxx line
                        #        #
                        #        #Write as
			#	 #logic goes here
                        #        ;;

                        *)      echo "Beyond known number of data lines set. If you see this then something is wrong in the original file or processing."$line >> $OUTPUT_FILENAME
		                ;;
                esac

	fi

done < "$LOG_FILENAME"
echo "Done. Processed file saved as $OUTPUT_FILENAME"

CONVERSION_STATUS=1
fi # End of if for processing iostat_dt

##########################################################################################
##########################################################################################
##########################################################################################


if [ "$1" == "vmstat" ]
then
echo "Converting vmstat file type $1 to CSV..."
#log file name that will be precessed (entered as cmd line param)
LOG_FILENAME="$2"
OUTPUT_FILENAME=$2.csv
#Variables for processing file
INITIAL_LINE_OFFSET=2
DATA_LINE_RESET=1
#If all the data should be logged or only selected KPIs
#If selected KPIs are used then the headers must be updated to match the data that is extracted for writing to csv
LOG_KPIS="SELECTED" # "ALL" | "SELECTED"

#create new output file with relevant initial entries
#echo "Output for $LOGFILENAME. CSV Headers will go here." > $OUTPUT_FILENAME
OUTPUT_HEADERS="Timestamp,procs-r,procs-b,mem-swpd,mem-free,mem-buff,mem-cache,swap-si,swap-so,io-bi,io-bo,system-in,system-cs,cpu-us,cpu-sy,cpu-id,cpu-wa,cpu-st"
OUTPUT_HEADERS_SELECTED="Timestamp,mem-free,io-bi,io-bo,cpu-st"
if [ "$LOG_KPIS" == "ALL" ]
then
OUTPUT_HEADERS=$OUTPUT_HEADERS_ALL
fi
if [ "$LOG_KPIS" == "SELECTED" ]
then
OUTPUT_HEADERS=$OUTPUT_HEADERS_SELECTED
fi

echo $OUTPUT_HEADERS > $OUTPUT_FILENAME

#Start processing
LINE_NUMBER=0
DATA_LINE_NUMBER=0

echo "Starting to process file $1....."
while read -r line
do
	LINE_NUMBER=`expr $LINE_NUMBER + 1`
	DATA_LINE_NUMBER=`expr $DATA_LINE_NUMBER + 1`

	if [ "$LINE_NUMBER" -lt `expr $INITIAL_LINE_OFFSET + 1` ]
	then
		#echo "Skipping inital offset line $LINE_NUMBER"
		DATA_LINE_NUMBER=0
	else
	        if [ "$DATA_LINE_NUMBER" -gt "$DATA_LINE_RESET" ]
        	then
			#reset data line to 1
			DATA_LINE_NUMBER=1              

			#write the line contents known so far
                        #OUTPUT_LINE=$(echo $OUTPUT_LINE | tr -d '\n')
                        echo $OUTPUT_LINE >> $OUTPUT_FILENAME

			#reset for captuting next line content
			OUTPUT_LINE=""
        	fi

		#linecontent=$line
		#echo "line content $linecontent"
		#echo $LINE_NUMBER:$DATA_LINE_NUMBER:$line >> $OUTPUT_FILENAME

                #Logic on how should the content from each line be extracted to build output lines..
                case "$DATA_LINE_NUMBER" in
	
                        1)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine3--$line >> $OUTPUT_FILENAME
				#This is line with values of above headers 
				# 2  0      0  81176  93656 473576    0    0    73    61    5    2  4  2 93  1  0        2015-04-20 18:26:01 ED
				#Write as tokenized values based on ouptput headers
                                tok1=$(echo $line | cut -d' ' -f1)
                                tok2=$(echo $line | cut -d' ' -f2)
                                tok3=$(echo $line | cut -d' ' -f3)
                                tok4=$(echo $line | cut -d' ' -f4)
                                tok5=$(echo $line | cut -d' ' -f5)
                                tok6=$(echo $line | cut -d' ' -f6)
                                tok7=$(echo $line | cut -d' ' -f7)
                                tok8=$(echo $line | cut -d' ' -f8)
                                tok9=$(echo $line | cut -d' ' -f9)
                                tok10=$(echo $line | cut -d' ' -f10)
                                tok11=$(echo $line | cut -d' ' -f11)
                                tok12=$(echo $line | cut -d' ' -f12)
                                tok13=$(echo $line | cut -d' ' -f13)
                                tok14=$(echo $line | cut -d' ' -f14)
                                tok15=$(echo $line | cut -d' ' -f15)
                                tok16=$(echo $line | cut -d' ' -f16)
                                tok17=$(echo $line | cut -d' ' -f17)
                                tok18=$(echo $line | cut -d' ' -f18)
                                tok19=$(echo $line | cut -d' ' -f19)
                                tok20=$(echo $line | cut -d' ' -f20)                                
                                tok21=$(echo $line | cut -d' ' -f21)
                                #OUTPUT_LINE="$OUTPUT_LINE$tok18 $tok19 $tok20,$tok1,$tok2,$tok3,$tok4,$tok5,$tok6,$tok7,$tok8,$tok9,$tok10,$tok11,$tok12,$tok13,$tok14,$tok15,$tok16,$tok17"
                                #OUTPUT_LINE........
                                if [ "$LOG_KPIS" == "ALL" ]
                                then
                                       OUTPUT_LINE="$OUTPUT_LINE$tok18 $tok19 $tok20,$tok1,$tok2,$tok3,$tok4,$tok5,$tok6,$tok7,$tok8,$tok9,$tok10,$tok11,$tok12,$tok13,$tok14,$tok15,$tok16,$tok17"
                                fi
                                if [ "$LOG_KPIS" == "SELECTED" ]
                                then
                                       OUTPUT_LINE="$OUTPUT_LINE$tok18 $tok19 $tok20,$tok4,$tok9,$tok10,$tok17"
                                fi
				;;
                        #8)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine8--$line >> $OUTPUT_FILENAME
                        #        #This is xxxx line
                        #        #
                        #        #Write as
			#	 #logic goes here
                        #        ;;

                        *)      echo "Beyond known number of data lines set. If you see this then something is wrong in the original file or processing."$line >> $OUTPUT_FILENAME
		                ;;
                esac

	fi

done < "$LOG_FILENAME"
echo "Done. Processed file saved as $OUTPUT_FILENAME"

CONVERSION_STATUS=1
fi # End of if for processing vmstat

##########################################################################################
##########################################################################################
##########################################################################################
if [ "$1" == "memstat" ]
then
echo "Converting memory file type $1 to CSV..."
#log file name that will be precessed (entered as cmd line param)
LOG_FILENAME="$2"
OUTPUT_FILENAME=$2.csv
#Variables for processing file
INITIAL_LINE_OFFSET=0
DATA_LINE_RESET=5
#If all the data should be logged or only selected KPIs
#If selected KPIs are used then the headers must be updated to match the data that is extracted for writing to csv
LOG_KPIS="SELECTED" # "ALL" | "SELECTED"

#create new output file with relevant initial entries
#echo "Output for $LOGFILENAME. CSV Headers will go here." > $OUTPUT_FILENAME
OUTPUT_HEADERS="mem-total,mem-used,mem-free,mem-shared,mem-buffers,mem-cached,mem-+/-buffers/cache-used,mem-+-buffers/cache-free,mem-swap-total,mem-swap-used,mem-swap-free"
OUTPUT_HEADERS_SELECTED="mem-total,mem-used,mem-free"

if [ "$LOG_KPIS" == "ALL" ]
then
OUTPUT_HEADERS=$OUTPUT_HEADERS_ALL
fi
if [ "$LOG_KPIS" == "SELECTED" ]
then
OUTPUT_HEADERS=$OUTPUT_HEADERS_SELECTED
fi
echo $OUTPUT_HEADERS > $OUTPUT_FILENAME

#Start processing
LINE_NUMBER=0
DATA_LINE_NUMBER=0

echo "Starting to process file $1....."
while read -r line
do
	LINE_NUMBER=`expr $LINE_NUMBER + 1`
	DATA_LINE_NUMBER=`expr $DATA_LINE_NUMBER + 1`

	if [ "$LINE_NUMBER" -lt `expr $INITIAL_LINE_OFFSET + 1` ]
	then
		#echo "Skipping inital offset line $LINE_NUMBER"
		DATA_LINE_NUMBER=0
	else
	        if [ "$DATA_LINE_NUMBER" -gt "$DATA_LINE_RESET" ]
        	then
			#reset data line to 1
			DATA_LINE_NUMBER=1              

			#write the line contents known so far
                        #OUTPUT_LINE=$(echo $OUTPUT_LINE | tr -d '\n')
                        echo $OUTPUT_LINE >> $OUTPUT_FILENAME

			#reset for captuting next line content
			OUTPUT_LINE=""
        	fi

		#linecontent=$line
		#echo "line content $linecontent"
		#echo $LINE_NUMBER:$DATA_LINE_NUMBER:$line >> $OUTPUT_FILENAME

                #Logic on how should the content from each line be extracted to build output lines..
                case "$DATA_LINE_NUMBER" in
	
                        1)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine1--$line >> $OUTPUT_FILENAME
				#This is the header 
				#             total       used       free     shared    buffers     cached
				#Write as nothing just skip
                                ;;
                        2)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine2--$line >> $OUTPUT_FILENAME
				#This is a data line 
				#Mem:           996        900         95          0         84        451
				#Write as tokenized value based on output headers
                                tok1=$(echo $line | cut -d' ' -f1)
                                tok2=$(echo $line | cut -d' ' -f2)
                                tok3=$(echo $line | cut -d' ' -f3)
                                tok4=$(echo $line | cut -d' ' -f4)
                                tok5=$(echo $line | cut -d' ' -f5)
                                tok6=$(echo $line | cut -d' ' -f6)
                                tok7=$(echo $line | cut -d' ' -f7)
                                #OUTPUT_LINE=$OUTPUT_LINE$tok2,$tok3,$tok4,$tok5,$tok6,$tok7
                                if [ "$LOG_KPIS" == "ALL" ]
                                then
                                       OUTPUT_LINE=$OUTPUT_LINE$tok2,$tok3,$tok4,$tok5,$tok6,$tok7
                                fi
                                if [ "$LOG_KPIS" == "SELECTED" ]
                                then
                                       OUTPUT_LINE=$OUTPUT_LINE$tok2,$tok3,$tok4
                                fi
				;;
                        3)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine3--$line >> $OUTPUT_FILENAME
				#This is line with values of above headers 
				#-/+ buffers/cache:        365        631
				#Write as tokenized values based on ouptput headers
                                tok1=$(echo $line | cut -d' ' -f1)
                                tok2=$(echo $line | cut -d' ' -f2)
                                tok3=$(echo $line | cut -d' ' -f3)
                                tok4=$(echo $line | cut -d' ' -f4)
                                tok5=$(echo $line | cut -d' ' -f5)
                                tok6=$(echo $line | cut -d' ' -f6)
                                #OUTPUT_LINE=$OUTPUT_LINE,$tok3,$tok4
                                if [ "$LOG_KPIS" == "ALL" ]
                                then
                                       OUTPUT_LINE=$OUTPUT_LINE,$tok3,$tok4
                                fi
                                #if [ "$LOG_KPIS" == "SELECTED" ]
                                #then
				       #Skipping as no selecetd KPI
                                       #OUTPUT_LINE=$OUTPUT_LINE,$tok3,$tok4
                                #fi
				;;
                        4)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine3--$line >> $OUTPUT_FILENAME
                                #This is line with values of above headers
                                #Swap:            0          0          0
                                #Write as tokenized values based on ouptput headers
                                tok1=$(echo $line | cut -d' ' -f1)
                                tok2=$(echo $line | cut -d' ' -f2)
                                tok3=$(echo $line | cut -d' ' -f3)
                                tok4=$(echo $line | cut -d' ' -f4)
                                tok5=$(echo $line | cut -d' ' -f5)
                                tok6=$(echo $line | cut -d' ' -f6)
                                #OUTPUT_LINE=$OUTPUT_LINE,$tok2,$tok3,$tok4
                                if [ "$LOG_KPIS" == "ALL" ]
                                then
                                       OUTPUT_LINE=$OUTPUT_LINE,$tok2,$tok3,$tok4
                                fi
                                #if [ "$LOG_KPIS" == "SELECTED" ]
                                #then
                                       #Skipping as no selecetd KPI
                                       #OUTPUT_LINE=$OUTPUT_LINE,$tok2,$tok3,$tok4
                                #fi
                                ;;
                        5)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine1--$line >> $OUTPUT_FILENAME
                                #This is blank line 
                                #
                                #Write as nothing just skip
                                ;;
                        #8)      #echo $LINE_NUMBER:$DATA_LINE_NUMBER:FromLine8--$line >> $OUTPUT_FILENAME
                        #        #This is xxxx line
                        #        #
                        #        #Write as
			#	 #logic goes here
                        #        ;;

                        *)      echo "Beyond known number of data lines set. If you see this then something is wrong in the original file or processing."$line >> $OUTPUT_FILENAME
		                ;;
                esac

	fi

done < "$LOG_FILENAME"
echo "Done. Processed file saved as $OUTPUT_FILENAME"

CONVERSION_STATUS=1
fi # End of if for processing memstat

##########################################################################################
##########################################################################################
##########################################################################################


if [ "$CONVERSION_STATUS" -eq 0 ]
        then
        echo "Invalid arguments. Usage:  ./convert_log_to_csv.sh < iostat_xt | iostat_dt | vmstat | memstat > <raw log file name>"
        exit
fi


#!/bin/bash

source /var/www/html/powercompare/bin/activate

usage()
{
    echo "usage: execute.sh [-d|--date] <201901> [-m|--sendmail]"
}

while [ "$1" != "" ]; do
    case $1 in
        -d | --date )           shift
                                date=$1
                                ;;
        -m | --sendmail )       sendmail=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ "$sendmail" = "1" ]; then
    python3 /var/www/html/powercompare/power.py -d $date --sendmail > /var/www/html/powercompare/output/html/powerOutput_$(date +"%d%m%Y").html || exit 1
    # Email Output (headers must be in .html file)
    # ssmtp -t < powerOutput_$(date +"%d%m%Y").html
    
    echo 'Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' >> /var/www/html/powercompare/output/html/powerOutput_$(date +"%d%m%Y").html || exit 1
    echo 'Content-Disposition: attachment; filename="powerCompare_'$date'_'$(date +"%d%m%Y")'.xlsx"' >> /var/www/html/powercompare/output/html/powerOutput_$(date +"%d%m%Y").html || exit 1
    echo 'Content-Transfer-Encoding: base64' >> /var/www/html/powercompare/output/html/powerOutput_$(date +"%d%m%Y").html || exit 1
    b64Excel="$(cat /var/www/html/powercompare/output/excel/powerCompare_"$date"_"$(date +"%d%m%Y")".xlsx | base64)"
    echo $b64Excel >> /var/www/html/powercompare/output/html/powerOutput_$(date +"%d%m%Y").html || exit 1
    echo '--multipart-boundary--' >> /var/www/html/powercompare/output/html/powerOutput_$(date +"%d%m%Y").html || exit 1
    ssmtp -t < /var/www/html/powercompare/output/html/powerOutput_$(date +"%d%m%Y").html
    # cat powerOutput_$(date +"%d%m%Y").html | (cat - && uuencode /var/www/html/powercompare/powerCompare_201901_07022019.xlsx) | ssmtp -t

else 
    python3 /var/www/html/powercompare/power.py -d $date
fi


# ( cat powerOutput_07022019.html; uuencode powerCompare_201901_07022019.xlsx powerCompare_201901_07022019.xlsx ) | mail -s "Powertest1" -a "Content-Type: text/html" ndomino@newtelco.de

# https://stackoverflow.com/questions/33470547/send-html-message-with-attachement-pdf-from-shell
# https://stackoverflow.com/questions/10479340/bash-sending-html-with-an-attached-file
# http://www.shelldorado.com/articles/mailattachments.html

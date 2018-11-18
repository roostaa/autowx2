#!/bin/bash

# NOAA sat pass gallery preparation
# generates a single html snippet with a current pass

enchancements=('MCIR-precip' 'HVC' 'MSA' 'therm' 'HVCT-precip')

# fileNameCore="$1"
# satellite="$2"
# start="$3"
# duration="$4"
# peak="$5"
# azimuth="$6"
# freq="$7"

# static values for tests
# imgdir=/home/filips/bin/autowx2/var/www/recordings/noaa/img/2018/09/08/
#imgdir=/home/filips/github/autowx2/var/www/recordings/noaa/img/2018/09/08/
#fileNameCore="20181114-1818_NOAA-18"
#fileNameCore=20180908-1626_NOAA-19
#wwwDir="/home/filips/github/autowx2/var/www/"
#wwwRootPath='file:///home/filips/github/autowx2/var/www/'



# prorgam itself - variables
outHtml="$imgdir/$fileNameCore.html"  # html for this single pass
indexHtml="$imgdir/index.html"        # main index file for a given day
htmlTemplate="$wwwDir/index.tpl"


# ---single gallery preparation------------------------------------------------#

makethumb() {
    obrazek="$1"
    local thumbnail=$(basename "$obrazek" .jpg)".th.jpg"
    convert -define jpeg:size=200x200 "$obrazek" -thumbnail '200x200^' granite: +swap -gravity center -extent 200x200 -composite -quality 82 "$thumbnail"
    echo "$thumbnail"
    }

logFile="$imgdir/$fileNameCore.log"   # log file to read from

varDate=$(sed '1q;d' $logFile)
varSat=$(sed '3q;d' $logFile)
varStart=$(sed '4q;d' $logFile) # unused
varDur=$(sed '5q;d' $logFile)
varPeak=$(sed '6q;d' $logFile)
varFreq=$(sed '7q;d' $logFile)

dateTime=$(date -d @$varStart +"%Y-%m-%d")

cd $imgdir

echo "<h2>$varSat | $varDate</h2>" > $outHtml
echo "<p>f=${varFreq}Hz, peak: ${varPeak}°, duration: ${varDur}s</p>" >> $outHtml

for enchancement in "${enchancements[@]}"
do
    echo "**** $enchancement"
    obrazek="$fileNameCore-$enchancement+map.jpg"
    sizeof=$(du -sh "$obrazek" | cut -f 1)
    # generate thumbnail
    thumbnail=$(makethumb "$obrazek")
    echo "<a href='$obrazek'><img src='$thumbnail' alt='$enchancement' title='$enchancement | $sizeof' class="img-thumbnail" /></a> " >> $outHtml
done

thumbnail=$(makethumb "$fileNameCore-spectrogram.jpg")
echo "<a href='$fileNameCore-spectrogram.jpg'><img src='$thumbnail' alt=''spectrogram' class="img-thumbnail" /></a>" >> $outHtml


# ----consolidate data from the given day ------------------------------------#
# generates neither headers nor footer of the html file

echo "" > $indexHtml.tmp
for htmlfile in $(ls $imgdir/*.html | grep -v "index.html")
do
  cat $htmlfile >> $indexHtml.tmp
done

# ---------- generates pages according to the template file -------------------

date=$(date)
htmlTitle="NOAA images | $dateTime"
htmlBody=$(cat $indexHtml.tmp)

source $htmlTemplate > $indexHtml
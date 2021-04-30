#!/bin/sh
echo
echo "----------Flash Memory Usage----------"
echo "               Start     End     Size"
echo "Bootloader  8000000  8007fff   8000 (32Kb)"
arm-none-eabi-nm -S -s $1.elf -t d| awk 'BEGIN {FS = " "; start=0;etext=0;edata=0;} {if ($3 == "g_pfnVectors"){start=$1};if($3 == "_etext"){etext=$1};if ($3 == "_sidata"){edata=$1};} END{printf("Text       %8x %8x %6x (%dKb)\n", start, etext, etext-start, (etext-start)/1024);}'
awk  < $1.map 'BEGIN {FS = " "; strline=0; strcnt=0; strsz=0} {if (strline==1){strline=0;strcnt++;strsz+=strtonum($2)};if(strline==0 && ($1 ~ /\.str1\.1/)){strline=1};} END{printf("Strings                      %6x (%dKb)\n", strsz, strsz/1024);}'
awk  < $1.map 'BEGIN {FS = " "; exidx=0; extab=0;fill=0;} {if ($1 == ".ARM"){exidx=strtonum($3)};if ($1 == "*fill*"){fill+=strtonum($3)};if ($1 == ".ARM.extab" && $4 == ""){extab=strtonum($3)};} END{printf("ARM.exidx                    %6x (%dKb)\n", exidx, exidx/1024); printf("ARM.extab                    %6x (%dKb)\n", extab, extab/1024);printf("Fill                         %6x (%dKb)\n", fill, fill/1024);}'
arm-none-eabi-nm -S --size-sort -s $1.elf -t d| grep " r \| R \| v \| V" | awk 'BEGIN {FS = " "; main=0;ram0=0;} {main+=$2;} END{printf("Const                          %x (%dKb)\n", main, main/1024);}'
arm-none-eabi-nm -S -s $1.elf -t d| awk 'BEGIN {FS = " "; start=0;etext=0;edata=0;} {if ($3 == "g_pfnVectors"){start=$1};if($3 == "_etext"){etext=$1};if ($3 == "_sidata"){edata=$1};} END{printf("ROData     %8x %8x %6x (%dKb)\n", etext, edata, edata - etext, (edata-etext)/1024); printf("Flash      %8x %8x %6x (%dKb)\n", 0x8000000, edata, edata - 134217728, (edata - 134217728)/1024);}'

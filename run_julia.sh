
../JuliaShell.sh $1 1 $2 $3 >> $4
printf "," >> $4
../JuliaShell.sh $1 2 $2 $3 >> $4
printf "," >> $4
../JuliaShell.sh $1 4 $2 $3 >> $4
printf "," >> $4
../JuliaShell.sh $1 6 $2 $3 >> $4
printf "," >> $4
../JuliaShell.sh $1 8 $2 $3 >> $4
printf "," >> $4
../JuliaShell.sh $1 16 $2 $3 >> $4
printf "," >> $4
../JuliaShell.sh $1 32 $2 $3 >> $4
printf "," >> $4
../JuliaShell.sh $1 48 $2 $3 >> $4
printf "," >> $4
../JuliaShell.sh $1 54 $2 $3 >> $4
printf "\n" >> $4

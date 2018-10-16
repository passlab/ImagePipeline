
./ImagePipelineMain 1 1 2 1 >> $1
printf "," >> $1
./ImagePipelineMain 1 2 4 1 >> $1
printf "," >> $1
./ImagePipelineMain 1 4 8 1 >> $1
printf "," >> $1
./ImagePipelineMain 1 6 12 1 >> $1
printf "," >> $1
./ImagePipelineMain 1 8 16 1 >> $1
printf "," >> $1
./ImagePipelineMain 1 16 32 1 >> $1
printf "," >> $1
./ImagePipelineMain 1 32 64 1 >> $1
printf "," >> $1
./ImagePipelineMain 1 48 96 1 >> $1
printf "," >> $1
./ImagePipelineMain 1 54 108 1 >> $1
printf "\n" >> $1

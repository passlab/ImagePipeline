#!/bin/bash

OUTER_NUM=1
INNER_NUM=1
NUM_IMAGES=8
AUTO_CONFIG=1

if (($# < 2)); then
    echo "Usage: JuliaShell OUTER_NUM INNER_NUM [NUM_IMAGES AUTO_CONFIG]"
    exit
fi

OUTER_NUM=$1
INNER_NUM=$2

if (($# > 2)); then
    NUM_IMAGES=$3
fi

if (($# > 3)); then
    AUTO_CONFIG=$4
fi

MAX_NUM_THREADS=108
IMAGE="test0.jpg"
LEFT_OVER=$NUM_IMAGES
LOOP=0

START_TIME=$(date +%s.%N)

if ((AUTO_CONFIG == 1)); then
    if ((MAX_NUM_THREADS < NUM_IMAGES)); then
        LEFT_OVER=$(echo $NUM_IMAGES%$MAX_NUM_THREADS | bc)
        LOOP=$(echo $NUM_IMAGES-$LEFT_OVER | bc)
        export JULIA_NUM_THREADS=$MAX_NUM_THREADS
        ~/julia-1.0.1/bin/julia ../julia_loop.jl $LOOP $MAX_NUM_THREADS 0
    fi

    if (($LEFT_OVER != 0)); then
        export JULIA_NUM_THREADS=$LEFT_OVER
        ~/julia-1.0.1/bin/julia ../julia_loop.jl $LEFT_OVER $MAX_NUM_THREADS $LOOP
    fi
else
    export export JULIA_NUM_THREADS=$OUTER_NUM
    ~/julia-1.0.1/bin/julia ../julia_loop_fix_inner_num.jl $NUM_IMAGES $INNER_NUM
fi

END_TIME=$(date +%s.%N)

ELAPSED_TIME=$(echo $END_TIME-$START_TIME | bc)

echo "Elapsed time: " $ELAPSED_TIME

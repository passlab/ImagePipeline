/*
   Copyright 2012 Will Sackfield

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

#include <stdio.h>
#include <stdlib.h>
#include "ImagePipelineDriver.h"
#include <omp.h>

int main(int argc,char* argv[]) {

    if (argc < 3) {
        printf("Invalid arguments are given.\n");
        printf("Usage: ./example OUTER_OMP_THREAD_NUM INNER_OPENCV_THREAD_NUM\n");
        printf("Such as ./example 4 8\n");
        return 1;
    }

    int outer_num = atoi(argv[1]);
    int inner_num = atoi(argv[2]);
    int loops = 8;
    if (argc > 3) {
        loops = atoi(argv[3]);
    }
    double total_time = read_timer();
    double average_time;
    char * image = "test0.jpg";
    // parallel
#pragma omp parallel for num_threads(outer_num) firstprivate(image, loops)
    for (int i = 0; i < loops; i++) {
        processImage(i, image, inner_num);
    }

    for (int i = 0; i < loops; i++) {
        average_time += times[i];
    }
    average_time /= loops;

    total_time = read_timer() - total_time;

    printf("The total time is: %.2f\nThe average time is %.2f\n", total_time, average_time);

	return EXIT_SUCCESS;
}

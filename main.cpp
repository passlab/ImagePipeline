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
#include <thread>
#include <omp.h>

int main(int argc,char* argv[]) {

    if (argc < 3) {
        printf("Invalid arguments are given.\n");
        printf("Usage: ./example OUTER_OMP_THREAD_NUM INNER_OPENCV_THREAD_NUM NUM_IMAGES [0|1] FOR AUTO_CONFIG\n");
        printf("Such as ./example 4 8\n");
        return 1;
    }

    int outer_num = atoi(argv[1]);
    int inner_num = atoi(argv[2]);
    int auto_config = 1;
    int num_images = 8;
    if (argc > 3) {
        num_images = atoi(argv[3]);
    }
    if (argc > 4) {
        auto_config = atoi(argv[4]);
    }
    double average_time;
    char * image = "test0.jpg";
    // parallel
    int max_threads = std::thread::hardware_concurrency() - 2;
    int left_over = num_images;
    int loop = 0;
    double total_time = read_timer();

    if (auto_config) {
        if (max_threads < num_images) {
            left_over = num_images % max_threads;
            loop = num_images - left_over;
#pragma omp parallel for num_threads(max_threads) firstprivate(image, loop)
            for (int i = 0; i < loop; i++) {
                processImage(i, image, 1);
            }
        }

        if (left_over != 0) {
        int num_inner_threads = max_threads / left_over;
        int temp = max_threads % left_over;
#pragma omp parallel num_threads(left_over) firstprivate(num_inner_threads)
        {
            int thread_id = omp_get_thread_num();
            if (thread_id < temp) num_inner_threads++;
            processImage(thread_id + loop, image, num_inner_threads);
        }
        }
        //printf("auto-config outer and inner parallelism\n");
        //printf("%d images are processed with 1 inner threads\n", loop);
        //printf("%d images are processed with %d or %d inner threads\n", left_over, num_inner_threads, num_inner_threads+1);
    } else {
#pragma omp parallel for num_threads(outer_num)
        for (int i = 0; i < num_images; i++) {
            processImage(i, image, inner_num);
        }
        //printf("Manual set outer and inner parallelism: %d outer threads %d inner threads\n", outer_num, inner_num);
    }
    total_time = read_timer() - total_time;

    for (int i = 0; i < num_images; i++) {
        average_time += times[i];
    }
    average_time /= num_images;

    //printf("Elapsed time: %.2fs\n", total_time);
    //printf("Average time: %.2fs\n", average_time);

    //printf("%.2f", average_time);
    printf("%.2f", total_time);

	return EXIT_SUCCESS;
}

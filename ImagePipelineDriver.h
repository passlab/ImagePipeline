//
// Created by Yonghong Yan on 10/14/18.
//

#ifndef IMAGEPIPELINE_IMAGEPIPELINEDRIVER_H
#define IMAGEPIPELINE_IMAGEPIPELINEDRIVER_H

extern double read_timer();
extern double read_timer_ms();
extern double times[];
extern void processImage(int, char * image);
extern void setCVNumThreads(int num_threads);

#endif //IMAGEPIPELINE_IMAGEPIPELINEDRIVER_H

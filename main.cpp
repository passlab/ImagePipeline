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

#include "ImagePipeline.h"
#include <omp.h>
#include <string>
#include <sys/time.h>

using namespace IP;
using namespace cv;
using namespace std;

#define ANGLE(p1,p2,p3) (((p1.x-p3.x)*(p2.x-p3.x))+((p1.y-p3.y)*(p2.y-p3.y)))/sqrt(((pow(p1.x-p3.x,2.0)+pow(p1.y-p3.y,2.0))*(pow(p2.x-p3.x,2.0)+pow(p2.y-p3.y,2.0)))+1e-10)

double read_timer_ms() {
    struct timeval t;
    gettimeofday(&t, 0);
    return t.tv_sec * 1000ULL + t.tv_usec / 1000ULL;
}

double read_timer() {
    return read_timer_ms() * 1.0e-3;
}

void findSquares(const cv::Mat inputImage,const void* context)
{
	if(context == NULL || inputImage.type() != CV_8U)
		return;
	
	vector<vector<Point> >* contextVector = (vector<vector<Point> >*)context;
	vector<vector<Point> > contours;
	
	findContours(inputImage,contours,CV_RETR_LIST,CV_CHAIN_APPROX_SIMPLE);
	
	for(int i=0;i<contours.size();i++)
	{
		vector<Point> approx;
		approxPolyDP(Mat(contours[i]),approx,arcLength(Mat(contours[i]),true)*0.02,true);
		if(approx.size() == 4 && fabs(contourArea(Mat(approx))) > 1000 && isContourConvex(Mat(approx)))
		{
			double maxCosine = 0.0;
			for(int j=2;j<5;j++)
				maxCosine = MAX(maxCosine,fabs(ANGLE(approx[j%4],approx[j-2],approx[j-1])));
			if(maxCosine < 0.3)
				contextVector->push_back(approx);
		}
	}
}

int main(int argc,char* argv[]) {
    double times[8];
    int outer_num = atoi(argv[1]);
    int inner_num = atoi(argv[2]);
    double total_time = read_timer();
    if (inner_num > 0) {
        setNumThreads(inner_num);
    }
    // parallel
#pragma omp parallel for num_threads(outer_num)
    for (int i = 0; i < 8; i++) {
        double time = read_timer();
        ImageGraph graph;
        graph.addNode(downscaleImageBy2);
        graph.addNode(upscaleImageBy2);
        graph.addNode(splitChannels);
        graph.addNode(split11Thresholds);
        graph.addNode(findSquares);

        vector<vector<Point> > contextVector;
        ImagePipeline pipeline(graph);
        std::string filename = "test" + std::to_string(i) + ".jpg";
        cout << filename << "\n";
        Mat inputImage = imread(filename);

        printf("New outer thread %d.\n", omp_get_thread_num());
        pipeline.feed(inputImage,&contextVector);
        
        for(int j=0;j<contextVector.size();j++) {
            const Point* p = &contextVector[j][0];
            int n = (int)contextVector[j].size();
            polylines(inputImage,&p,&n,1,true,Scalar(0,255,0),3,CV_AA);
        }
        filename = "res_" + filename;
        imwrite(filename, inputImage);
        time = read_timer() - time;
        printf("Iteration %d -- Thread %d -- Time: %f\n", i, omp_get_thread_num(), time);
        times[i] = time;
    }

    total_time = read_timer() - total_time;

    printf("The total time is: %f\n", total_time);

	return EXIT_SUCCESS;
}

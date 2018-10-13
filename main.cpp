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
/*
// ---------------------------

// Define a pixel
typedef Point3_<uint8_t> Pixel;

// A complicated threshold is defined so
// a non-trivial amount of computation
// is done at each pixel.
void complicatedThreshold(Pixel &pixel)
{
  if (pow(double(pixel.x)/10,2.5) > 100)
  {
    pixel.x = 255;
    pixel.y = 255;
    pixel.z = 255;
  }
  else
  {
    pixel.x = 0;
    pixel.y = 0;
    pixel.z = 0;
  }
}

// Parallel execution with function object.
struct Operator
{
  void operator ()(Pixel &pixel, const int * position) const
  {
    // Perform a simple threshold operation
    complicatedThreshold(pixel);
  }
};

void processImage(const cv::Mat inputImage) {
    inputImage.forEach<Pixel>(Operator());
}
*/

// ---------------------

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

    if (argc < 3) {
        printf("Invalid arguments are given.\n");
        printf("Usage: ./example OUTER_OMP_THREAD_NUM INNER_OPENCV_THREAD_NUM\n");
        printf("Such as ./example 4 8\n");
        return 1;
    }

    double times[8];
    int outer_num = atoi(argv[1]);
    int inner_num = atoi(argv[2]);
    double total_time = read_timer();
    double average_time;
    if (inner_num > 0) {
        setNumThreads(inner_num);
    }
    // parallel
#pragma omp parallel for num_threads(outer_num)
    for (int i = 0; i < 8; i++) {
        
        ImageGraph graph;
        graph.addNode(downscaleImage); // resize, parallel_for
        graph.addNode(denoiseImage); // denoise, parallel_for
        graph.addNode(smoothImage); // smooth, parallel_for
        //graph.addNode(splitChannels);
        //graph.addNode(split11Thresholds);
        graph.addNode(findSquares);

        vector<vector<Point> > contextVector;
        ImagePipeline pipeline(graph);
       
        std::string filename = "test" + std::to_string(i) + ".jpg";
        cout << filename << "\n";
        printf("New outer thread %d.\n", omp_get_thread_num());
        Mat inputImage = imread(filename);

        double time = read_timer();
        //processImage(&inputImage);
        
        pipeline.feed(inputImage,&contextVector);
        /*
        for(int j=0;j<contextVector.size();j++) {
            const Point* p = &contextVector[j][0];
            int n = (int)contextVector[j].size();
            polylines(inputImage,&p,&n,1,true,Scalar(0,255,0),3,CV_AA);
        }
        */
        time = read_timer() - time;
        filename = "res_" + filename;
        imwrite(filename, inputImage);
        printf("Iteration %d -- Thread %d -- Time: %f\n", i, omp_get_thread_num(), time);
        times[i] = time;
    }

    for (int i = 0; i < 8; i++) {
        average_time += times[i];
    }
    average_time /= 8;

    total_time = read_timer() - total_time;

    printf("The total time is: %.2f\nThe average time is %.2f\n", total_time, average_time);

	return EXIT_SUCCESS;
}

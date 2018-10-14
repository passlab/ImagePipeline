signsight: clear main.o ImagePipeline.o
	#g++ main.o ImagePipeline.o -L../opencv/omp/install/lib -I../opencv/omp/install/include/opencv2 -lopencv_core -lopencv_highgui -lopencv_photo -lopencv_imgproc -lopencv_imgcodecs -fopenmp -lpthread -o example
	#g++ main.o ImagePipeline.o -L../opencv/tbb/install/lib -I../opencv/tbb/install/include/opencv2 -lopencv_core -lopencv_highgui -lopencv_photo -lopencv_imgproc -lopencv_imgcodecs -fopenmp -lpthread -o example
	g++ main.o ImagePipeline.o -lopencv_core -lopencv_highgui -lopencv_photo -lopencv_imgproc -fopenmp -lpthread -o example

clear:
	rm -f *.o
	rm -f example

main.o:
	g++ -c main.cpp -o main.o -fopenmp -pthread -std=c++11

ImagePipeline.o:
	g++ -c ImagePipeline.cpp -o ImagePipeline.o -std=c++11

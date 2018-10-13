signsight: clear main.o ImagePipeline.o
	#icc main.o ImagePipeline.o -L../opencv/omp/install/lib -I../opencv/omp/install/include/opencv2 -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_imgcodecs -fopenmp -lpthread -o example
	#g++ main.o ImagePipeline.o -L../opencv/omp/install/lib -I../opencv/omp/install/include/opencv2 -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_imgcodecs -fopenmp -lpthread -o example
	g++ main.o ImagePipeline.o -L../opencv/tbb/install/lib -I../opencv/tbb/install/include/opencv2 -lopencv_core -lopencv_highgui -lopencv_photo -lopencv_imgproc -lopencv_imgcodecs -fopenmp -lpthread -o example

clear:
	rm -f *.o
	rm -f example

main.o:
	#icc -c main.cpp -o main.o -fopenmp -pthread
	g++ -c main.cpp -o main.o -fopenmp -pthread

ImagePipeline.o:
	#icc -c ImagePipeline.cpp -o ImagePipeline.o
	g++ -c ImagePipeline.cpp -o ImagePipeline.o

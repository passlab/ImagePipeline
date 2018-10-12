signsight: clear main.o ImagePipeline.o
	g++ main.o ImagePipeline.o -I../opencv/omp/install/include/opencv2 -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_imgcodecs -fopenmp -lpthread -o example

	#g++ main.o ImagePipeline.o -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_imgcodecs -o example
clear:
	rm -f *.o
	rm -f example

main.o:
	g++ -c main.cpp -o main.o -fopenmp -pthread

ImagePipeline.o:
	g++ -c ImagePipeline.cpp -o ImagePipeline.o


## To compile and run
To use customized installed OpenCV library, set OpenCV_ROOT cmake variable so it will find the one you need. 

```
mkdir build

cd build

cmake -DOpenCV_ROOT=opencv_install_folder ..

make

```

## To compile OpenCV on carina
We turned off CUDA support because there are some errors with related to CUDA_nppi lib
```
cmake -DCMAKE_INSTALL_PREFIX=/opt/opencv-2.4.13.6-openmp-install -DWITH_OPENMP=ON -DWITH_CUDA=OFF ..
```

```
cmake -DCMAKE_INSTALL_PREFIX=/opt/opencv-2.4.13.6-tbb-install -DWITH_TBB=ON -DWITH_CUDA=OFF ..
```

Then on carina, the build of ImagePipeline has to use the build folder of opencv-2.4.13.6, not the install folder and it has to use OpenCV_DIR cmake variable

```
cmake -DOpenCV_DIR=/home/yanyh/opencv-2.4.13.6/build-openmp ..
```

ImagePipeline 1.0
==============

ImagePipeline is a C++ API for designing OpenCV solutions through the use of pipelines rather than a set of specific functions. The inspiration came from spending lots of time meshing methods together to obtain efficient solutions preventing the use of repeating preprocessing steps, by using this API I can simply share the pipeline and when adding my ImageGraph (a set of preprocessing steps) to the pipeline it will make a tree representing the most efficient way of combining the graphs.

The example contains an implementation of the squares OpenCV demo program written in this way.

Distributed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0 "Apache License, Version 2.0")
Compiled and tested on OSX

Third party code
----------------

- [tree.hh](http://tree.phi-sci.com "tree.hh: an STL-like C++ tree class")

Dependencies
------------

- [opencv](http://opencv.willowgarage.com/wiki/ "OpenCV")

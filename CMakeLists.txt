cmake_minimum_required(VERSION 3.2)
project(ImagePipeline)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES
        ImagePipeline.cpp
        ImagePipeline.h
        ImagePipelineDriver.cpp
        ImagePipelineDriver.h
        tree.hh)

set(CMAKE_C_FLAGS "-fopenmp")
set(CMAKE_CXX_FLAGS "-fopenmp")
find_package( OpenCV REQUIRED )
include_directories( ${OpenCV_INCLUDE_DIRS} )
# link_directories()

add_library(ImagePipeline SHARED ${SOURCE_FILES})
target_link_libraries(ImagePipeline ${OpenCV_LIBS})

# only need those flags for main.cpp OpenMP code
add_executable(ImagePipelineMain main.cpp ${SOURCE_FILES})
target_link_libraries(ImagePipelineMain ${OpenCV_LIBS})

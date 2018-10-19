import ctypes
import sys
from multiprocessing import Pool
import time

def caller(argv):
    threadID = argv[0]
    threadNum = argv[1]
    LP_c_char = ctypes.POINTER(ctypes.c_char)
    imagePipeline.processImage.argtypes = (ctypes.c_int, LP_c_char, ctypes.c_int)
    imageName = ctypes.create_string_buffer("test0.jpg".encode('utf-8'))

    imagePipeline.processImage(threadID, imageName, threadNum)


if __name__ == '__main__':

    outerNumber = 1
    innerNumber = 1
    imageAmount = 8
    autoConfig = 1

    argc = len(sys.argv)
    if argc > 2:
        outerNumber = int(sys.argv[1])
        innerNumber = int(sys.argv[2])
    if argc > 3:
        imageAmount = int(sys.argv[3])
    if argc > 4:
        autoConfig = int(sys.argv[4])

    imagePipeline = ctypes.cdll.LoadLibrary('./libImagePipeline.so')
    maxThreads = 108
    leftOver = imageAmount
    loop = 0

    startTime = time.time()
    if autoConfig:
        if maxThreads < imageAmount:
            leftOver = imageAmount % maxThreads
            loop = imageAmount - leftOver
            outerWorkers = Pool(maxThreads)
            argv = [[i, 1] for i in range(loop)]
            outerWorkers.map(caller, argv)

        if leftOver != 0:
            outerWorkers = Pool(leftOver)
            threadLimitDiff = maxThreads%leftOver
            argv = [[loop+i, maxThreads//leftOver] for i in range(leftOver)]
            for i in range(threadLimitDiff):
                argv[i][1] += 1
            outerWorkers.map(caller, argv)
    else:
        outerWorkers = Pool(outerNumber)
        argv = [[i, innerNumber] for i in range(outerNumber)]
        outerWorkers.map(caller, argv)

    elapsedTime = time.time() - startTime

    print('{:.2f}'.format(elapsedTime), end='')


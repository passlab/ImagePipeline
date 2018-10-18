import ctypes
import sys
from multiprocessing import Pool

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

    imagePipeline = ctypes.cdll.LoadLibrary('./ImagePipeline.so')
    maxThreads = 108
    leftOver = imageAmount
    loop = 0

    LP_c_char = ctypes.POINTER(ctypes.c_char)
    LP_LP_c_char = ctypes.POINTER(LP_c_char)
    imageName = "test0.jpg"
    unitArgv = (LP_c_char * (4))()
    unitArgv[0] = ctypes.create_string_buffer("")
    unitArgv[2] = ctypes.create_string_buffer(imageName)
    unitArgv[3] = ctypes.create_string_buffer(1)
    pipeline.main.argtypes = (ctypes.c_int, LP_LP_c_char)

    startTime = time.time()
    if autoConfig:
        if maxThreads < imageAmount:
            leftOver = imageAmount % maxThreads
            loop = imageAmount - leftOver
            outerWorkers = Pool(maxThreads)
           # rawArgv = [loop, maxThreads, 0]
            cppArgv = [unitArgv for i in range(maxThreads)]
            for i in range(maxThreads):
                #enc_arg = str(raw_argv[i-1]).encode('utf-8')
                cppArgv[i][1] = ctypes.create_string_buffer(str(i))

            #cppArgv = [[ctypes.create_string_buffer(""), ctypes.create_string_buffer(i), ctypes.create_string_buffer(imageName), ctypes.create_string_buffer(1)] for i in range(maxThreads)]

                    #enc_arg = str(raw_argv[i-1]).encode('utf-8')
            outerWorkers.map(imagePipeline, cppArgv)

        if leftOver != 0:
            outerWorkers = Pool(leftOver)
            #rawArgv = [leftOver, maxThreads, loop]
            threadLimitDiff = maxThreads%leftOver
            unitArgv[3] = ctypes.create_string_buffer(str(maxThreads//leftOver))
            cppArgv = [unitArgv for i in range(leftOver)]
            for i in range(leftOver):
                #enc_arg = str(raw_argv[i-1]).encode('utf-8')
                #cppArgv[1] = ctypes.create_string_buffer(enc_arg)
                cppArgv[i][1] = ctypes.create_string_buffer(str(loop+i))
                if i < threadLimitDiff:
                    cppArgv[3] = ctypes.create_string_buffer(str(maxThreads//leftOver+1))
            outerWorkers.map(imagePipeline, cppArgv)
    else:
        outerWorkers = Pool(outerNumber)
        unitArgv[3] = ctypes.create_string_buffer(str(innerNumber))
        #rawArgv = [leftOver, maxThreads, loop]
        cppArgv = [unitArgv for i in range(outerNumber)]
        for i in range(outerNumber):
            cppArgv[i][1] = ctypes.create_string_buffer(str(i))
        outerWorkers.map(imagePipeline, cppArgv)

    elapsedTime = time.time() - startTime

    print(elapsedTime)

# calculate outer and inner number
# outer_number = pool_number
# inner_number = opencv_numer
    '''
    raw_argv = ["main", "2", "8", "4"]

    for i in  range(argc):
        enc_arg = raw_argv[i].encode('utf-8')
        argv[i] = ctypes.create_string_buffer(enc_arg)

    pipeline.main(argc, argv)
    #pipeline.test(1, 8)
    '''
    

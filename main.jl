using Distributed
using Printf
# check https://www.juliabloggers.com/julia-calling-c-a-minimal-example/

function main(ARGS::Array{String,1})
    outer_num::Int32 = 1
    inner_num::Int32 = 1
    loop_count::Int32 = 8

    if length(ARGS) == 1
        out_num = parse(Int32, ARGS[1])
    elseif length(ARGS) == 2
        outer_num = parse(Int32, ARGS[1])
        inner_num = parse(Int32, ARGS[2])
    elseif length(ARGS) >2  
        outer_num = parse(Int32, ARGS[1])
        inner_num = parse(Int32, ARGS[2])
        loop_count = parse(Int32, ARGS[3])
    end

    @printf "num of threads: %d\n" Threads.nthreads()

    image = "test0.jpg"

    t1 = time_ns()
    Threads.@threads for i = 1:loop_count
#                    @printf "Thread %d for %d\n" Threads.threadid() i
                    ccall((:processImage, "libImagePipeline"), Cvoid, (Int32, Cstring, Int32), i, image, inner_num)
                 end
    t2 = time_ns()
    elasped = (t2 - t1)/1.0e9
    @printf "Elapsed time: %fn" elapsed

end

@printf "Usage main <outer_num> <inner_num>\n"
@printf "outer_num, i.e. number of threads for Julia to use\n"
@printf "should be set by JULIA_NUM_THREADS env \n"

main(ARGS)

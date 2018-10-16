using Distributed
using Printf
# check https://www.juliabloggers.com/julia-calling-c-a-minimal-example/

function main(ARGS::Array{String,1})
    outer_num::Int32 = 1
    inner_num::Int32 = 1
    num_images::Int32 = 8
    auto_config::Int8 = 1

    if length(ARGS) > 1
        outer_num = parse(Int32, ARGS[1])
    end
    if length(ARGS) > 2
        inner_num = parse(Int32, ARGS[2])
    end
    if length(ARGS) > 3
        num_images = parse(Int32, ARGS[3])
    end
    if length(ARGS) > 4
        auto_config = parse(Int32, ARGS[4])
    end

    max_num_threads::Int32 = Threads.nthreads()
#    @printf "num of threads: %d\n" Threads.nthreads()

    image = "test0.jpg"

    t1 = time_ns()
    if auto_config == 1
        if max_threads < num_images
            left_over = num_images % max_threads
            loop = num_images - left_over
            Threads.@threads for i = 0:loop-1
#               @printf "Thread %d for %d\n" Threads.threadid() i
                ccall((:processImage, "libImagePipeline"), Cvoid, (Int32, Cstring, Int32), i, image, 1)
               end
         end

        num_inner_threads = fill(max_threads / left_over, max_num_threads)
        temp = max_threads % left_over
        Threads.nthreads() = left_over # This is not working, Julia cannot change # threads to use after it starts
        Threads.@threads for i = 0:left_over-1
            if i < temp
                num_inner_threads[i]++
            end
            ccall((:processImage, "libImagePipeline"), Cvoid, (Int32, Cstring, Int32), loop+i, image, num_inner_threads[i])
        end
        @printf "auto-config outer and inner parallelism\n"
        @printf "%d images are processed with 1 inner threads\n" loop
        @printf "%d images are processed with %d or %d inner threads\n" left_over num_inner_threads num_inner_threads+1
    else
        Threads.@threads for i = 0:num_images-1
#           @printf "Thread %d for %d\n" Threads.threadid() i
            ccall((:processImage, "libImagePipeline"), Cvoid, (Int32, Cstring, Int32), i, image, inner_num)
        end
        @printf "Manual set outer and inner parallelism: %d outer threads %d inner threads\n" outer_num inner_num
    end
    t2 = time_ns()
    elapsed = (t2 - t1)/1.0e9
    average_time = 0.0
    times = cglobal((:times, :libImagePipeline), Ref{Float64})
    for i = 0:num_images-1
        average_time += unsafe_load(times, i)
    end
    average_time /= num_images;

    @printf "Elapsed time: %.2fs\n" elapsed
    @printf "Average time: %.2fs\n" average_time
end

@printf "Usage main <outer_num> <inner_num> [num_images] [0|1 for auto_config]\n"
@printf "outer_num, i.e. number of threads for Julia to use\n"
@printf "should be set by JULIA_NUM_THREADS env \n"

main(ARGS)

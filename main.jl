using Distributed
using Printf
# check https://www.juliabloggers.com/julia-calling-c-a-minimal-example/

function main(args::Array{String,1})
    outer_num::Int32 = 1
    inner_num::Int32 = 1
    num_images::Int32 = 8
    auto_config::Int8 = 1

    if length(args) > 1
        outer_num = parse(Int32, args[1])
    end
    if length(args) > 2
        inner_num = parse(Int32, args[2])
    end
    if length(args) > 3
        num_images = parse(Int32, args[3])
    end
    if length(args) > 4
        auto_config = parse(Int32, args[4])
    end

    max_num_threads::Int32 = Threads.nthreads()
#    @printf "num of threads: %d\n" Threads.nthreads()

    image = "test0.jpg"
    left_over::Int32 = num_images
    loop::Int32 = 0

    t1 = time_ns()
    if auto_config == 1
        if max_num_threads < num_images
            left_over = num_images % max_num_threads
            loop = num_images - left_over
            Threads.@threads for i = 0:loop-1
#               @printf "Thread %d for %d\n" Threads.threadid() i
                ccall((:processImage, "libImagePipeline"), Cvoid, (Int32, Cstring, Int32), i, image, 1)
               end
         end

        if left_over != 0
            num_inner_threads = fill(max_num_threads / left_over, max_num_threads)
            temp = max_num_threads % left_over
            #Threads.nthreads() = left_over # This is not working, Julia cannot change # threads to use after it starts
            Threads.@threads for i = 0:left_over-1
                if i < temp
                    num_inner_threads[i] = num_inner_threads[i] + 1
                end
                ccall((:processImage, "libImagePipeline"), Cvoid, (Int32, Cstring, Int32), loop+i, image, num_inner_threads[i])
            end
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
@printf "outer_num, i.e. number of threads for Julia to use %d\n" Threads.nthreads()
@printf "should be set by JULIA_NUM_THREADS env \n"

main(ARGS)

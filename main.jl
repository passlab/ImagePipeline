using Distributed
using Printf
# check https://www.juliabloggers.com/julia-calling-c-a-minimal-example/


function julia_loop(num_images::Int32, num_threads::Int32)
    image = "test0.jpg"
    if num_threads < num_images # Each image is processed sequentially
        Threads.@threads for i = 0:num_images-1
                ccall((:processimage, "libimagepipeline"), cvoid, (int32, cstring, int32), i, image, 1)
                end
                1
    elseif # Each image is processed in parallel
         num_inner::Int32 = fill(num_threads / left_over, num_threads)
         temp = num_threads % left_over
         Threads.@threads for i = 0:num_images-1
                if i < temp
                    num_inner[i] = num_inner[i] + 1
                end
                ccall((:processImage, "libImagePipeline"), Cvoid, (Int32, Cstring, Int32), loop+i, image, num_inner[i])
         end
         num_inner[1]
    end
end

function julia_loop_fix_inner_num(num_images::Int32, num_inner_threads::Int32)
    image = "test0.jpg"
    Threads.@threads for i = 0:num_images-1
        ccall((:processimage, "libimagepipeline"), cvoid, (int32, cstring, int32), i, image, num_inner_threads)
    end
end


function main(args::Array{String,1})
    outer_num::Int32 = 1
    inner_num::Int32 = 1
    num_images::Int32 = 8
    auto_config::Int32 = 1

    if length(args) >= 1
        outer_num = parse(Int32, args[1])
    end
    if length(args) >= 2
        inner_num = parse(Int32, args[2])
    end
    if length(args) >= 3
        num_images = parse(Int32, args[3])
    end
    if length(args) >= 4
        auto_config = parse(Int32, args[4])
    end

    max_num_threads::Int32 = 108
    @printf "JULIA_NUM_THREADS: %d, outer_num: %d, inner_num: %d, num_images: %d, auto_config: %d\n" Threads.nthreads() outer_num inner_num num_images auto_config
    image = "test0.jpg"
    left_over::Int32 = num_images
    loop::Int32 = 0

    @printf "================================================================\n"
    t1 = time_ns()
    if auto_config == 1
        num_inner_threads = 1
        if max_num_threads < num_images
            left_over = num_images % max_num_threads
            loop = num_images - left_over
            julia_loop(loop, max_num_threads)
        end
        if left_over != 0
            num_inner_threads = julia_loop(left_over, max_num_threads)
        end
        @printf "Auto-config outer and inner parallelism:\n"
        @printf "\t%d images are processed with 1 inner threads\n" loop
        @printf "\t%d images are processed with %d or %d inner threads\n" left_over num_inner_threads num_inner_threads+1
    else
        julia_loop_fix_inner_num(num_images, inner_num);
        @printf "Using outer and inner parallelism: %d outer threads %d inner threads\n" outer_num inner_num
    end
    t2 = time_ns()
    elapsed = (t2 - t1)/1.0e9
    average_time = 0.0
```
    # this is NOT working for accessing a global variable in C
    times = cglobal((:times, :libImagePipeline), Ref{Float64})
    for i = 0:num_images-1
        average_time += unsafe_load(times, i)
    end
```
    average_time = elapsed / num_images;

    @printf "Elapsed time: %.2fs\n" elapsed
    @printf "Average time: %.2fs\n" average_time
end

@printf "Usage main <outer_num> <inner_num> [num_images] [0|1 for auto_config]\n"
@printf "\touter_num, i.e. nun_threads for Julia to use %d can only be set by \n" Threads.nthreads()
@printf "\tJULIA_NUM_THREADS env, e.g. export JULIA_NUM_THREADS=4 \n"

main(ARGS)

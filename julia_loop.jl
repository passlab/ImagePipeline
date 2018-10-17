using Distributed
using Printf

function julia_loop(num_images::Int32, num_threads::Int32, index::Int32)
    image = "test0.jpg"
    if num_threads < num_images # Each image is processed sequentially
        Threads.@threads for i = 0:num_images-1
                ccall((:processImage, "libImagePipeline"), Cvoid, (Int32, Cstring, Int32), i, image, 1)
                end
                1
    else # Each image is processed in parallel
         num_inner = fill(div(num_threads, num_images), num_images)
         temp = num_threads % num_images
         Threads.@threads for i = 1:num_images
                if i < temp+1
                    num_inner[i] = num_inner[i] + 1
                end
                ccall((:processImage, "libImagePipeline"), Cvoid, (Int32, Cstring, Int32), index+i, image, num_inner[i])
         end
         num_inner[1]
    end
end

function main(args::Array{String,1})
    num_images::Int32 = 8
    num_threads::Int32 = 108;
    index::Int32 = 0;    

    if length(args) >= 1
        num_images = parse(Int32, args[1])
    end
    if length(args) >= 2
        num_threads = parse(Int32, args[2])
    end
    if length(args) >= 3
        index = parse(Int32, args[3])
    end

    julia_loop(num_images, num_threads, index)
end

main(ARGS)

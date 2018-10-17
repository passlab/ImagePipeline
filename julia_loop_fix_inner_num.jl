using Distributed
using Printf
# check https://www.juliabloggers.com/julia-calling-c-a-minimal-example/

function julia_loop_fix_inner_num(num_images::Int32, num_inner_threads::Int32)
    image = "test0.jpg"
    Threads.@threads for i = 0:num_images-1
        ccall((:processImage, "libImagePipeline"), Cvoid, (Int32, Cstring, Int32), i, image, num_inner_threads)
    end
end

function main(args::Array{String,1})
    num_images::Int32 = 8
    num_inner_threads::Int32 = 108;

    if length(args) >= 1
        num_images = parse(Int32, args[1])
    end
    if length(args) >= 2
        num_threads = parse(Int32, args[2])
    end

    julia_loop_fix_inner_num(num_images, num_threads)
end

main(ARGS)

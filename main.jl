using Distributed
using Printf
# check https://www.juliabloggers.com/julia-calling-c-a-minimal-example/

function main(out_num::Int32, inner_num::Int32)
    @printf "num of threads: %d\n" Threads.nthreads()

    loop::Int32 = 0
    image = "test0.jpg"

    Threads.@threads for i = 1:loop
                    # Threads.threadid()
                     ccall((:processImage, "libImagePipeline"), Cvoid, (Int32, Cstring, Int32), i, image, inner_num)
                 end

end

@printf "Usage main <outer_num> <inner_num>\n"

main(parse(Int32, ARGS[1]), parse(Int32, ARGS[2]))

# This file is a part of Julia. License is MIT: https://julialang.org/license

## dummy stub for https://github.com/JuliaBinaryWrappers/OpenSpecFun_jll.jl
baremodule OpenSpecFun_jll
using Base, Libdl
Base.Experimental.@compiler_options compile=min optimize=0 infer=false

const PATH_list = String[]
const LIBPATH_list = String[]

export libopenspecfun

# These get calculated in __init__()
const PATH = Ref("")
const LIBPATH = Ref("")
artifact_dir::String = ""
libopenspecfun_handle::Ptr{Cvoid} = C_NULL
libopenspecfun_path::String = ""

if Sys.iswindows()
    const libopenspecfun = "libopenspecfun.dll"
elseif Sys.isapple()
    const libopenspecfun = "@rpath/libopenspecfun.dylib"
else
    const libopenspecfun = "libopenspecfun.so"
end

function __init__()
    global libopenspecfun_handle = dlopen(libopenspecfun)
    global libopenspecfun_path = dlpath(libopenspecfun_handle)
    global artifact_dir = dirname(Sys.BINDIR)
    LIBPATH[] = dirname(libopenspecfun_path)
    push!(LIBPATH_list, LIBPATH[])
end

# JLLWrappers API compatibility shims
is_available() = true
find_artifact_dir() = artifact_dir
dev_jll() = error("stdlib JLLs cannot be dev'ed")
best_wrapper = nothing
get_libopenspecfun_path() = libopenspecfun_path

end  # module OpenSpecFun_jll

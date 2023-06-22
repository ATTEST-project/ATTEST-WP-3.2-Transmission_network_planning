# This function extracts only that data from the ODS file which is mentioned
# in the field header and then saves the data for each entity of a power system
# Entities (Bus, Lines, Gens, Loads etc)


function data_reader(array_data,nEntr,fields,header,data,data_cont,type_cont) # type_cont = Type Container
    for j in 1:nEntr
        for  i in 1:size(fields,1)
            idx = findall(x->x==fields[i],header)
            data_cont[i] = data[j,idx[1,1]]
        end
        b = type_cont(data_cont ...)
        array_data[j,1]=b
    end
    return array_data
end

function findall3(f, a::Array{T, N}) where {T, N}
    j = 1
    b = Vector{Int}(undef, length(a))
    @inbounds for i in eachindex(a)
        @inbounds if f(a[i])
            b[j] = i
            j += 1
        end
    end
    resize!(b, j-1)
    sizehint!(b, length(b))
    return b
end

function boolean_func(b::Int64,map, a)

    A= (a[i[1]] for i in  indexin(b,map) if ~isnothing(indexin(b,map)[1]))
    if !isempty(A)

        return a[indexin(b,map)[1]]
    else
        return 0

    end
end



function boolean_func_injection(c::Int64,s::Int64,t::Int64,b::Int64,pinj_dict_c,N)
    A=(pinj_dict_c[[c,s,t,b,j]] for j in N if ~isempty(N))
    if !isempty(A)

        return sum(pinj_dict_c[[c,s,t,b,j]] for j in N)
    else
        return 0
    end
end

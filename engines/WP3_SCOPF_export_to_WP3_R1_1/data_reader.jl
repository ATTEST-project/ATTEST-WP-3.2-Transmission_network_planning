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

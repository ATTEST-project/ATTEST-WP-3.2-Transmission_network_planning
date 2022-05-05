#---contingencies-----
sheetname = "contingencies";
fields = ["cont", "From", "To"]; # Fields that have to be read from the file
raw_data =
    ods_readall(filename; sheetsNames = [sheetname], innerType = "Matrix")
raw_data = raw_data[sheetname]   # Conversion from Dict to Array

header = raw_data[1, :]
data = raw_data[2:end, :]
data = convert(Array{Float64}, data)
data_cont = zeros(size(fields, 1))               # data_cont = Data Container
nCont = Int64(size(data, 1))

global array_contin_lines = Array{contingencies}(undef, nLines)

array_contin_lines = data_reader( array_contin_lines, nCont, fields, header, data, data_cont, contingencies )

# ------
idx_from_line = []
idx_to_line = []
for i = 1:nLines                                                                # nLines = nTrsf + nTransmission lines
    push!(idx_from_line, rdata_lines[i,1])                                # Saving 'from' end of lines in a vector
    push!(idx_to_line,  rdata_lines[i,2])                                    # Saving 'to' end of lines in a vector
end
idx_line = [idx_from_line idx_to_line]

idx_from_line_c = []
idx_to_line_c = []
for i = 1:nCont                                                                # nLines = nTrsf + nTransmission lines
    push!(idx_from_line_c, array_contin_lines[i].from_contin)                                # Saving 'from' end of lines in a vector
    push!(idx_to_line_c, array_contin_lines[i].to_contin)                                    # Saving 'to' end of lines in a vector
end
idx_line_c = [idx_from_line_c idx_to_line_c]

list_of_contingency_lines = []
for i = 1:nCont
    from_search = findall(x -> x == idx_line_c[i, 1], idx_line[:, 1])
    to_search = findall(x -> x == idx_line_c[i, 2], idx_line[:, 2])
    contingency_line = intersect(from_search, to_search)
    push!(list_of_contingency_lines, contingency_line)
    # push!(ss,ss1)
end
#
#

idx_parallel=[]
for i in 1:nLines
    if size(idx_plines[i],1)==2
        push!(idx_parallel,[i])
    else
        push!(idx_parallel,[])
    end
end


data_for_each_contingency = []
idx_contin_branches = []
idx_pll=[findall(x -> x == list_of_contingency_lines[c], idx_parallel) for c in 1:nCont]
idx_pll_aux=findall(x -> x != [], idx_pll)
idx_npll=findall(x -> x ==[], idx_pll)
nCont_nprll=size(idx_npll,1)
nCont_prll =nCont-nCont_nprll

idx_sep_pll=[]
for  c in 1:nCont
    idx_separation=findall(x -> x == list_of_contingency_lines[c], idx_parallel)
    if ~isempty(idx_separation)
    push!(idx_sep_pll,idx_separation)
end
end
idx_sep_npll=setdiff(list_of_contingency_lines,idx_sep_pll)
final_sep=[idx_sep_pll;idx_sep_npll]
final_sep=vcat(final_sep...)
# idx_sep_1=[]
# for  c in 1:nCont
#     idx_separation=findall(x -> x != list_of_contingency_lines[c], idx_parallel)
#     if ~isempty(idx_separation)
#     push!(idx_sep_1,idx_separation)
# end
# end

# nCont_parallel    =

for c in 1:nCont
             if ~isempty(idx_pll[c])
                 push!(idx_contin_branches, collect(1:nLines))
                  # nline_data = [rdata_lines[idx_pll[1,1],1] rdata_lines[idx_pll[1,1],2]
                  #             0.5*data_for_each_contingency[c][idx_pll[c]].line_g
                  #             0.5*data_for_each_contingency[c][idx_pll[c]].line_b
                  #             0.5*data_for_each_contingency[c][idx_pll[c]].line_g_shunt
                  #             0.5*data_for_each_contingency[c][idx_pll[c]].line_b_shunt
                  #             0.5*data_for_each_contingency[c][idx_pll[c]].line_Smax_A
                  #           rdata_lines[idx_pll[1,1],8] ]
                 # push!( data_for_each_contingency, Line(nline_data) )

         else
             find_contingencies = setdiff(collect(1:nLines), list_of_contingency_lines[c][1])
             push!(idx_contin_branches, find_contingencies)

             # idx_pll=idx_pll[1,1]
            # push!( data_for_each_contingency, array_lines[idx_contin_branches[c], :], )

        end
    end

    for c in 1:nCont
      push!( data_for_each_contingency, array_lines[idx_contin_branches[c], :], )
    end
# idx_contin_branches = []
# idx_pll=[findall(x -> x == list_of_contingency_lines[c], idx_parallel) for c in 1:nCont]
nline_data_c=[]
for c in 1:nCont
         if ~isempty(idx_pll[c])
             # idx_pll=
             idx_pll_a=idx_pll[c]
             idx_pll_a=idx_pll_a[1,1]
                 # push!(idx_contin_branches, collect(1:nLines))
                 c1=rdata_lines[idx_pll_a,1]
                 c2=rdata_lines[idx_pll_a,2]
                 c3=0.5*data_for_each_contingency[c][idx_pll_a].line_g
                 c4=0.5*data_for_each_contingency[c][idx_pll_a].line_b
                 c5=0.5*data_for_each_contingency[c][idx_pll_a].line_g_shunt
                 c6=0.5*data_for_each_contingency[c][idx_pll_a].line_b_shunt
                 c7=0.5*data_for_each_contingency[c][idx_pll_a].line_Smax_A
                 c8=rdata_lines[idx_pll_a,8]
                  c9 = [ c1 c2 c3 c4 c5 c6 c7 c8]
                  push!(nline_data_c,Line(c1,c2,c3,c4,c5,c6,c7,c8))
                              # rdata_lines[idx_pll_aux,1]
                              # rdata_lines[idx_pll_aux,2]
                              # 0.5*data_for_each_contingency[c][idx_pll_aux].line_g
                              # 0.5*data_for_each_contingency[c][idx_pll_aux].line_b ]
                              # 0.5*data_for_each_contingency[c][idx_pll_aux].line_g_shunt
                              # 0.5*data_for_each_contingency[c][idx_pll_aux].line_b_shunt
                              # 0.5*data_for_each_contingency[c][idx_pll_aux].line_Smax_A
                            # rdata_lines[idx_pll_aux,8] ]
                 # push!( data_for_each_contingency, Line(nline_data) )

         # else
         #     find_contingencies = setdiff(collect(1:nLines), list_of_contingency_lines[c][1])
         #     push!(idx_contin_branches, find_contingencies)
         #
         #     # idx_pll=idx_pll[1,1]
         #    push!( data_for_each_contingency, array_lines[idx_contin_branches[c], :], )

        end
    end

# data_for_each_contingency[1]

for c in 1:nCont
  # for c in 26
         if ~isempty(idx_pll[c])
             # idx_pll=
             idx_pll_a=idx_pll[c]
             idx_pll_a=idx_pll_a[1,1]
             idx_pll_b=findall(x -> x == idx_pll[c], idx_sep_pll)
             idx_pll_b=idx_pll_b[1,1]
    data_for_each_contingency[c][idx_pll_a]=nline_data_c[idx_pll_b]
      # push!( data_for_each_contingency, nline_data_c[c] )
    end
end
# for c in 1:nCont
# if ~isempty(idx_pll[c])
#     idx_1=findall(x -> x == c, idx_pll)
#     idx_1=idx_1[1,1]
# # idx_pll_aux=idx_pll[c]
# # idx_pll_aux=idx_pll_aux[1,1]
# data_for_each_contingency[idx_pll_aux[c]][idx_pll_aux[c]]=nline_data_c[idx_1]
#   # push!( data_for_each_contingency, nline_data_c[c] )
# end
# end

    # for i = 1:nCont
    #     # push!( data_for_each_contingency, data_for_contingency[idx_contin_branches[i], :], )
    #     push!( data_for_each_contingency, array_lines[idx_contin_branches[i], :], )
    # end

# for c = 1:nCont
#     # idx_pll=[findall(x -> x == list_of_contingency_lines[c], idx_parallel) for c in 1:nCont]
#     if ~isempty(idx_pll[c])
#             idx_pll=idx_pll[1,1]
#          nline_data = [rdata_lines[idx_pll[1,1],1] rdata_lines[idx_pll[1,1],2]
#                          0.5*data_for_each_contingency[c][idx_pll[c]].line_g
#                          0.5*data_for_each_contingency[c][idx_pll[c]].line_b
#                          0.5*data_for_each_contingency[c][idx_pll[c]].line_g_shunt
#                          0.5*data_for_each_contingency[c][idx_pll[c]].line_b_shunt
#                          0.5*data_for_each_contingency[c][idx_pll[c]].line_Smax_A
#                        rdata_lines[idx_pll[1,1],8] ]
#             push!( data_for_each_contingency, Line(nline_data) )
#         else
#         push!( data_for_each_contingency, array_lines[idx_contin_branches[c], :], )
#     end
# end


# #------------------- Code for handling the parallel lines ----------------------
# idx_plines_c = []                                                                  # Indices of parallel lines
# for i in 1:size(data_line_prim,1)
#     line = transpose(data_line_prim[i,1:2])
#     plines = line.-data_line_prim[:,1:2]
#     i0_from = findall(x->x==0.0,plines[:,1])
#     i0_to   = findall(x->x==0.0,plines[:,2])
#     ilines  = intersect(i0_from,i0_to)
#     # ilines  = findall(x->x==0.0,plines[:,1])
#     if isempty(idx_plines_c)
#         push!(idx_plines_c,ilines)
#     elseif isempty(findall(x->x==ilines,idx_plines_c))
#         push!(idx_plines_c,ilines)
#     else
#         # do nothing!
#     end
# end

# new_line_data_c = []
# for c in 1:nCont
#   for i in 1:nLines
#      if list_of_contingency_lines[c]==idx_parallel[i]
#          ilines = idx_parallel[i]
#          y_line_eq = 0.5*(rdata_lines[ilines,3]+rdata_lines[ilines,4]im)
#          y_eq      = 0.5*(rdata_lines[ilines,5]+rdata_lines[ilines,6]im)
#          amp_eq_A =  0.5*rdata_lines[ilines,7]
#          # amp_eq_B = sum(data[ilines,8],dims=1)
#          # amp_eq_C = sum(data[ilines,9],dims=1)
#          nline_data = [rdata_lines[ilines[1,1],1] rdata_lines[ilines[1,1],2] real(y_line_eq) imag(y_line_eq) real(y_eq) imag(y_eq) amp_eq_A rdata_lines[ilines[1,1],8] ]
#          push!(new_line_data_c,nline_data)
#      else
#         push!(new_line_data_c,new_line_data[i])
#      end
#  end
# end
# # data_for_each_contin=[]
#
# # for c in 1:nCont
# #          push!(data_for_each_contin,new_line_data_c[c+(nLines-1)*(c-1):c*nLines])
# # end
# new_line_data_c=vcat(new_line_data_c...)
# global     array_lines_con = Array{Line}(undef, nLines , 1)
# fields  = ["From","To","g (pu)","b (pu)","g_sh (pu)","b_sh (pu)","RATE_A","br_status"]; # Fields that have to be read from the file
# header= fields
# data_cont = zeros(size(data[1,:],1))
#
# # for c = 1:nCont
# #     for i in 1:nLines
# #        if list_of_contingency_lines[c]==idx_parallel[i]
# #     array_lines_con = Array{Line}(undef, nLines , 1)
#     array_lines_contin = data_reader( array_lines_con, nLines , fields, header, new_line_data_c, data_cont, Line)
# #     push!(nw_contin, array_lines_contin)
# #        else
# #     push!( nw_contin, array_lines[idx_contin_branches[c], :], )
# # end
# # end
# # end
#
#
#
#
#
#
#      data = vcat(new_line_data_c...)
#      ##----------------------------------------------------------------------------##
#
#      data_cont = zeros(size(data[1,:],1))               # data_cont = Data Container
#      # nLines    = Int64(size(data,1))
#      global array_lines_modify = Array{Line}(undef,nLines,1)
#      fields  = ["From","To","g (pu)","b (pu)","g_sh (pu)","b_sh (pu)","RATE_A","br_status"]; # Fields that have to be read from the file
#      header= fields
#      array_lines_modify = data_reader(array_lines_modify,nLines,fields,header,data,data_cont,Line)
#
#
#
#


     # rheader_lines = header    # Exporting raw header of lines sheet
     # rdata_lines = data        # Exporting raw data of lines sheet
     #
     # raw_data = nothing
     # header = nothing
     # data = nothing

#
#     # if isempty(list_of_contingency_lines[c,1]== idx_plines_c[i,1]  && list_of_contingency_lines[c,2]== idx_plines_c[i,2])
#     idx_conting_lines=findall(x->x==list_of_contingency_lines[c,1][1],idx_plines_c[i,1][1])
#     if isempty(idx_conting_lines)
#     ilines = idx_plines_c[i,1]
#     y_line_eq = sum(data_line_prim[ilines,3]+data_line_prim[ilines,4]im,dims=1)
#     y_eq = sum(data_line_prim[ilines,5]+data_line_prim[ilines,6]im,dims=1)
#     amp_eq_A = sum(data_line_prim[ilines,7],dims=1)
#     # amp_eq_B = sum(data[ilines,8],dims=1)
#     # amp_eq_C = sum(data[ilines,9],dims=1)
#     nline_data = [transpose(data_line_prim[ilines[1,1],1:2]) real(y_line_eq) imag(y_line_eq) real(y_eq) imag(y_eq) amp_eq_A transpose(data_line_prim[ilines[1,1],8:end])]
#     push!(new_line_data,nline_data)
#    end
#  end
# end
#
# data = vcat(new_line_data...)
# ##----------------------------------------------------------------------------##
# data_cont = zeros(size(fields,1))               # data_cont = Data Container
# nLines    = Int64(size(data,1))
# global array_lines = Array{Line}(undef,nLines,1)

# array_lines = data_reader(array_lines,nLines,fields,header,data,data_cont,Line)
#
# rheader_lines = header    # Exporting raw header of lines sheet
# rdata_lines = data        # Exporting raw data of lines sheet
#
# raw_data = nothing
# header = nothing
# data = nothing


# end
# nCont=1
#
# fields = [ "From", "To", "r (pu)", "x (pu)", "g_sh (pu)", "b_sh (pu)", "RATE_A", "RATE_B", "RATE_C", "tap_ratio", "angle", "br_status", "ang_min", "ang_max", "tap_ratio_min", "tap_ratio_max" ]; # Fields that have to be read from the file
# header = fields
# data_cont = zeros(size(fields, 1))
# # data=data_for_each_contingency[1]
# # global array_lines_con = Array{Line_contin}(undef,nLines-1,1)
# nw_contin = []
#
# # array_lines_contin = data_reader(array_lines_contin,nLines-1,fields,header,data,data_cont,Line_contin)
# for i = 1:nCont
#     array_lines_con = Array{Line_contin}(undef, nLines-1 , 1)
#     data_new = data_for_each_contingency[i]
#     array_lines_contin = data_reader( array_lines_con, nLines-1 , fields, header, data_new, data_cont, Line_contin)
#     push!(nw_contin, array_lines_contin)
# end
# #  nw_contin is an array of structures for contingencies
header=nothing
data=nothing

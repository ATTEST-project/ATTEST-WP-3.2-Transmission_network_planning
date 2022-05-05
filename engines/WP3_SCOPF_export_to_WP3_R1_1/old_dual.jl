

# active_flow_contin_aux=@expression(acopf, [c in 1:nCont, s in 1:nSc, t in 1:nTP, b in 1:nBus, j in node_data_contin[c][b].node_cnode_c; ~isempty(node_data_contin[c][b].node_num_c)],
#
#             # sqrt((pinj_dict_c[[c,s,t,b,j]])^2+(qinj_dict_c[[c,s,t,b,j]])^2)
# pinj_dict_c[[c,s,t,b,j]]
#             )
# active_flow_contin=JuMP.value.(active_flow_contin_aux)
# active_flow_contin_dict=Dict{Array{Int64,1},Float64}()
# for c in 1:nCont, b in 1:nBus, j in 1:size(node_data_contin[c][b].node_num_c,1)
#     push!(active_flow_contin_dict, [c,node_data_contin[c][b].node_num_c[j],node_data_contin[c][b].node_cnode_c[j]]=>value(active_flow_contin[c,1,1,node_data_contin[c][b].node_num_c[j],node_data_contin[c][b].node_cnode_c[j]]) )
# end
# for c in 1:nCont, l in 1:length(idx_from_line_c[c])
#     push!(active_flow_contin_dict, [c,l]=>value(active_flow_contin[c,1,1,l]) )
# end
# flow_contin1=[zeros(length(idx_from_line_c[c]),1) for c in 1:nCont]
# flow_contin1=[[[active_flow_contin_dict[[c,l]]] for l in 1:length(idx_from_line_c[c])] for c in 1:nCont]

# flow6=Dict{String,Any}("$c"=>Dict{Int64,Any}() for c=1:nCont)
# # each_contin_dict=Dict{Array{Float64,1},Float64}()
# #
# flow3=collect(active_flow_contin_dict)
# #
# # flow4=push!(each_contin_dict, "$c"=>(flow3[i][2] for c in 1:nCont, i in 1:size(flow3,1) if c==flow3[i][1][1]))
# for  c in 1:nCont
#         push!(flow6, "$c"=>[[flow3[i][1][2]; flow3[i][1][3]; flow3[i][2]] for i in 1:size(flow3,1) if c==flow3[i][1][1]] )
# end
#
# flow7=deepcopy(flow6)
#
#
# for c in 1:nCont
# local    all_nonrequired=[]
# from=[flow6["$c"][i][1] for  i in 1:size(flow6["$c"],1)]
# to= [flow6["$c"][i][2] for  i in 1:size(flow6["$c"],1)]
# for j in 1:length(flow6["$c"])
# idx_from=findall(x->x==flow6["$c"][j][2], from)
# idx_to  =findall(x->x==flow6["$c"][j][1], to)
# idx_total=intersect(idx_from, idx_to)
# if ~isempty(idx_total)
#     push!(all_nonrequired, [j,idx_total[1]])
# end
#
# end
#
# for i in all_nonrequired
#
# deleteat!(all_nonrequired, findall(x->x==[i[2],i[1]],all_nonrequired ))
# end
# local finall_remove=[]
# for i in all_nonrequired
#     push!(finall_remove, i[2])
#
# end
#
# deleteat!(flow7["$c"], sort!(finall_remove) )
# end
# # active_flow_contin_final=[zeros(nLines,1) for c in 1:nCont]
# active_flow_contin_final=[[flow7["$c"][j][3] for j in 1:length(idx_from_line_c[c])] for c in 1:nCont ]
# # active_flow_contin_final=[[flow7["$c"][j][3] for j in 1:length(nLines)] for c in 1:nCont ]
# flow8=deepcopy(flow7)
# for c in 1
#     # for c in 1:nCont
#  # local counter=[]
#
#     for l in 1:length(idx_from_line_c[c])
#     # ft_line = findall(x->x==bus_num,idx_from_line_c[c])                               # index of all lines which are connected to bus i (bus i is present in 'from' column)
#     # tf_line = findall(x->x==bus_num,idx_to_line_c[c])                                 # index of all lines which are connected to bus i (bus i is present in 'to' column)
#     # # telem   = size(ft_line,1)+size(tf_line,1)
#     #
#     # ft_bus  = idx_to_line_c[c][ft_line]                                                # buses connected to bus i (bus i is present in 'from' column)
#     # tf_bus  = idx_from_line_c[c][tf_line]                                              # buses connected to bus i (bus i is present in 'to' column)
#     #
#     # b_lines  = union(ft_line,tf_line)
#     ft_line_1=findall(x->x==flow7["$c"][l][1],idx_from_line_c[c])
#     tf_line_1  = findall(x->x==flow7["$c"][l][1],idx_to_line_c[c])
#     # ft_bus_1  = idx_to_line_c[c][ft_line_1]                                                # buses connected to bus i (bus i is present in 'from' column)
#     # tf_bus_1  = idx_from_line_c[c][tf_line_1]
#     b_lines_1  = union(ft_line_1,tf_line_1)
#
#     ft_line_2=findall(x->x==flow7["$c"][l][2],idx_from_line_c[c])
#     tf_line_2  = findall(x->x==flow7["$c"][l][2],idx_to_line_c[c])
#     # ft_bus_2  = idx_to_line_c[c][ft_line_2]                                                # buses connected to bus i (bus i is present in 'from' column)
#     # tf_bus_2  = idx_from_line_c[c][tf_line_2]
#     b_lines_2  = union(ft_line_2,tf_line_2)
#     line_target=intersect(b_lines_1, b_lines_2)
#     # push!(counter,line_target[1])
#     # if isempty(findall(x->x==l ,counter))
# replace!(flow8["$c"], flow8["$c"][l]=>flow7["$c"][line_target[1]])
# # replace!(flow8["$c"], flow8["$c"][line_target[1]]=>flow7["$c"][l])
# # end
# end
# end

# if flow7["1"][1][1]==3 && flow7["1"][1][2]==1
# for c in 1:nCont, l in 1:nLines
#     if ~isempty(findall(x->x==l, id))
# end
# # end
# # end
#
# # for c in 1:nCont
# #     for j in 1:length(flow6["$c"])
# #         # for k in 1:j
# #             for k in 1:length(flow6["$c"])
# #             if j!=k
# #
# #         if flow6["$c"][k][1]==flow6["$c"][j][2]  && flow6["$c"][k][2]==flow6["$c"][j][1]
# #             if flow6["$c"][k][3]>flow6["$c"][j][3]
# #                 deleteat!(flow6["$c"], [j])
# #                 # setdiff( flow6["$c"], flow6["$c"][j])
# #             else
# #                 deleteat!(flow6["$c"], [k])
# #                 # setdiff( flow6["$c"], flow6["$c"][k])
# #             end
# #         end
# #     end
# # end
# # end
# # end
#
#
#
# flow_contin1=[zeros(nLines,1) for i in 1:nCont]
#
# for c in 1:nCont, b in 1:nBus, j in 1:2*length(idx_from_line_c[c])
#  # if haskey(flow_values_contin_dict, [c,idx_from_line_c[c][j],idx_to_line_c[c][j]])
#       if idx_from_line_c[c][j]==flow6["c"][j][1] && idx_to_line_c[c][j]==flow6["c"][j][2]
#      # flow_contin1[c][findall(x->x==node_data_contin[c][b].node_num_c[1], idx_from_line)]=flow_values_contin_dict[[c,idx_from_line_c[c][j],idx_to_line_c[c][j]]]
#      flow_contin1[c][findall(x->x==node_data_contin[c][b].node_num_c[1], idx_from_line)]=flow_values_contin_dict[[c,idx_from_line_c[c][j],idx_to_line_c[c][j]]]
#
#  end
# end
# flow_contin2=[[flow_values_contin_dict[[c,idx_from_line_c[c][j],idx_to_line_c[c][j]]] for j in 1:length(idx_from_line_c[c])] for c in 1:nCont ]


# for c in 1:nCont, b in 1:nBus, j in 1:size(node_data_contin[c][b].node_num_c,1)
#     if haskey(flow_values_contin_dict, [c,node_data_contin[c][b].node_num_c[j],node_data_contin[c][b].node_cnode_c[j]])
#         flow_contin1[c,findall(x->x==node_data_contin[c][b].node_num_c[1], idx_from_line)]=flow_values_contin_dict[[c,node_data_contin[c][b].node_num_c[j],node_data_contin[c][b].node_cnode_c[j]]]
#     end
# end


# idx_line_dict=Dict{Array{Int64,1},Int64}()
# for i in 1:nLines, c in 1:nCont, b in 1:nBus, j in 1:size(node_data_contin[c][b].node_num_c,1)
#     push!(idx_line_dict, i=>[node_data_contin[c][b].node_num_c[j],node_data_contin[c][b].node_cnode_c[j]])
# end
# flow_final_contin=[flow_values_contin_dict[c,node_data_contin[c][b].node_num_c[j],node_data_contin[c][b].node_cnode_c[j]]   for c in 1:nCont, b in 1:nBus, j in 1:size(node_data_contin[c][b].node_num_c,1)]
#
# flow1_contin=[[Base.getindex(flow_values_contin_dict, [c,node_data_contin[c][b].node_num_c[j],node_data_contin[c][b].node_cnode_c[j]] ) for j in 1:size(node_data_contin[c][b].node_num_c,1) ] for c in 1:nCont, b in 1:nBus]

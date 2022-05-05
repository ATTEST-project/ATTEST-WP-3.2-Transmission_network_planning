#----------------------- Formatting of Node data -------------------------------
#----------------------------- Node Data ---------------------------------------
#1 |  2  | 3  | 4  |   5   |  6  |  7  |   8   |  9  |  10 |   11    |   12    | 13 | 14 | 15
#N | CN | CL | Gsh | Gsh_l | G_l | Bsh | Bsh_l | B_l | tap | tap_min | tap_max | F | T   | Idx Trsf
# Information of all parmeters related to each Node
for i in 1:nBus
    bus_num = nw_buses[i].bus_num
    bus_num = bus_num[1,1]
    ft_line = findall(x->x==bus_num,idx_from_line)                               # index of all lines which are connected to bus i (bus i is present in 'from' column)
    tf_line = findall(x->x==bus_num,idx_to_line)                                 # index of all lines which are connected to bus i (bus i is present in 'to' column)
    telem   = size(ft_line,1)+size(tf_line,1)

    ft_bus  = idx_to_line[ft_line]                                                # buses connected to bus i (bus i is present in 'from' column)
    tf_bus  = idx_from_line[tf_line]                                              # buses connected to bus i (bus i is present in 'to' column)

    b_lines  = union(ft_line,tf_line)                                            # indexes of all lines connected to bus (b) i
    b_cbuses = union(ft_bus,tf_bus)                                              # buses connected to bus i

    gij_line = real(yij_line[b_lines,1])
    bij_line = imag(yij_line[b_lines,1])

    gij_line_sh = real(yij_line_sh[b_lines,1])
    bij_line_sh = imag(yij_line_sh[b_lines,1])
    smax_line = [nw_lines[i].line_Smax_A for i in b_lines]
    # tp_rt     = vcat(tap_ratio[ft_line],tap_ratio[tf_line])
    # tp_rt_min = vcat(tap_ratio_min[ft_line],tap_ratio_min[tf_line])
    # tp_rt_max = vcat(tap_ratio_max[ft_line],tap_ratio_max[tf_line])
    # from_col  = idx_from_line[b_lines,1]
    # to_col    = idx_to_line[b_lines,1]
    bus       = repeat([bus_num],telem)
    # iTap      = idx_tap[b_lines,end]
    # push!(node_data,node(bus,b_cbuses,b_lines,gij_line_sh,gij_line,bij_line_sh,bij_line,tp_rt,tp_rt_min,tp_rt_max,from_col,to_col,iTap))
    push!(node_data,node(bus,b_cbuses,b_lines,gij_line_sh,gij_line,bij_line_sh,bij_line,smax_line))

end
# node_data_ok=[]
# for i in 1:nBus
#     if ~isempty(node_data[i,1].node_num)
#         push!(node_data_ok,node_data[i])
#     end
# end
# #---------------------TRANSFORMATOR---------------------------
for i in 1:nBus
    bus_num = nw_buses[i].bus_num
    bus_num = bus_num[1,1]
    ft_line = findall(x->x==bus_num,idx_from_trans)                               # index of all lines which are connected to bus i (bus i is present in 'from' column)
    tf_line = findall(x->x==bus_num,idx_to_trans)                                 # index of all lines which are connected to bus i (bus i is present in 'to' column)
    telem   = size(ft_line,1)+size(tf_line,1)

    ft_bus  = idx_to_trans[ft_line]                                                # buses connected to bus i (bus i is present in 'from' column)
    tf_bus  = idx_from_trans[tf_line]                                              # buses connected to bus i (bus i is present in 'to' column)

    b_lines  = union(ft_line,tf_line)                                            # indexes of all lines connected to bus (b) i
    b_cbuses = union(ft_bus,tf_bus)                                              # buses connected to bus i

    gij_trans = real(yij_trans[b_lines,1])
    bij_trans = imag(yij_trans[b_lines,1])

    gij_trans_sh = real(yij_trans_sh[b_lines,1])
    bij_trans_sh = imag(yij_trans_sh[b_lines,1])

    # tp_rt     = vcat(tap_ratio[ft_line],tap_ratio[tf_line])
    tp_rt = tap_ratio[b_lines,1]
    tp_rt_min = tap_ratio_min[b_lines,1]
    tp_rt_max = tap_ratio_max[b_lines,1]
    # from_col  = idx_from_line[b_lines,1]
    # to_col    = idx_to_line[b_lines,1]
    bus       = repeat([bus_num],telem)
    # iTap      = idx_tap[b_lines,end]
    # push!(node_data,node(bus,b_cbuses,b_lines,gij_line_sh,gij_line,bij_line_sh,bij_line,tp_rt,tp_rt_min,tp_rt_max,from_col,to_col,iTap))
    push!(node_data_trans,node_t(bus,b_cbuses,b_lines,gij_trans_sh,gij_trans,bij_trans_sh,bij_trans,tp_rt,tp_rt_min,tp_rt_max))

end
# node_data_trans_ok=[]
# for i in 1:nBus
#     if ~isempty(node_data_trans[i,1].node_num)
#         push!(node_data_trans_ok,node_data_trans[i])
#     end
# end
#
# total_node_data=[node_data,node_data_trans]

# a1=[]
# a2=[]
# total_node=[]
# for i in 1:nBus
#     if ~isempty(node_data[i,1].node_num)  && ~isempty(node_data_trans[i,1].node_num)
#
#         push!(total_node,[node_data[i,1];node_data_trans[i,1]])
# #     end
# #     if ~isempty(node_data_trans[i,1].node_num)
# #         push!(a2,i)
# # end
# #     # else
# #     #     push!(a3,i)
#     end
# end

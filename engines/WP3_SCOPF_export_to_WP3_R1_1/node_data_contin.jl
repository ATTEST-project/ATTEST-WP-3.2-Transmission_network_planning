node_data_c      = []
# for c in 1:nCont
for c in 1:nCont
  for i in 1:nBus
    bus_num = nw_buses[i].bus_num
    ft_line = findall(x->x==bus_num,idx_from_line_c[c])                               # index of all lines which are connected to bus i (bus i is present in 'from' column)
    tf_line = findall(x->x==bus_num,idx_to_line_c[c])                                 # index of all lines which are connected to bus i (bus i is present in 'to' column)
    telem   = size(ft_line,1)+size(tf_line,1)

    ft_bus  = idx_to_line_c[c][ft_line]                                                # buses connected to bus i (bus i is present in 'from' column)
    tf_bus  = idx_from_line_c[c][tf_line]                                              # buses connected to bus i (bus i is present in 'to' column)

    b_lines  = union(ft_line,tf_line)                                            # indexes of all lines connected to bus (b) i
    b_cbuses = union(ft_bus,tf_bus)                                              # buses connected to bus i

    gij_line = real(yij_line_c[c][b_lines,1])
    bij_line = imag(yij_line_c[c][b_lines,1])

    gij_line_sh = real(yij_line_sh_c[c][b_lines,1])
    bij_line_sh = imag(yij_line_sh_c[c][b_lines,1])
      smax_line = line_smax_c[c][b_lines,1]

    # tp_rt     = vcat(tap_ratio_c[c][ft_line],tap_ratio_c[c][tf_line])
    # tp_rt_min = vcat(tap_ratio_min_c[c][ft_line],tap_ratio_min_c[c][tf_line])
    # tp_rt_max = vcat(tap_ratio_max_c[c][ft_line],tap_ratio_max_c[c][tf_line])
    # from_col  = idx_from_line_c[c][b_lines,1]
    # to_col    = idx_to_line_c[c][b_lines,1]
    bus       = repeat([bus_num],telem)
    # iTap      = idx_tapp[b_lines,end]

    push!(node_data_c,node_c(bus,b_cbuses,b_lines,gij_line_sh,gij_line,bij_line_sh,bij_line,smax_line))

   end
end
node_data_contin =[]

for i in 1:nCont
    # push!(node_data_contin, node_data_c[i+(nLines-2)*(i-1):i+(nLines-2)*(i-1)+(nLines-2)])
    push!(node_data_contin, node_data_c[i+(nBus-1)*(i-1):nBus*i])
end

#------------------- Formatting of Lines Data ----------------------------------





# tap_ratio_max_c  = []
# tap_ratio_min_c  = []
# node_data_c      = []
# error_msg_c      = []
# yii_sh_c         = []
#


#-------------------------------------------------------------------------------
# idx_from_line_c  = [data_for_each_contingency[i][j].line_from for i in 1:nCont for j in 1:5]
# idx_from_line_c_tmp  = [nw_contin[i][j].line_from_c for i in 1:nCont for j in 1:5]
# idx_from_line_c  = transpose(reshape(sizeidx_from_line_c_tmp))
idx_from_line_c_np=[]
idx_to_line_c_np=[]
yij_line_c_np=[]
yij_line_sh_c_np=[]
line_smax_c_np=[]

idx_from_line_c_p=[]
idx_to_line_c_p=[]
yij_line_c_p=[]
yij_line_sh_c_p=[]
line_smax_c_p=[]
# for c in 1:nCont
#   #   if isempty(idx_pll[c])
#   # for i in 1:nLines-1                                                                # nLines = nTrsf + nTransmission lines
#     push!(idx_from_line_c_np,data_for_each_contingency[c][i].line_from)                                # Saving 'from' end of lines in a vector
#     push!(idx_to_line_c_np,data_for_each_contingency[c][i].line_to)                                    # Saving 'to' end of lines in a vector
#     push!(yij_line_c_np,data_for_each_contingency[c][i].line_g+(data_for_each_contingency[c][i].line_b)im)               # Line admittance calculated from the given r and x values
#     push!(yij_line_sh_c_np,data_for_each_contingency[c][i].line_g_shunt+(data_for_each_contingency[c][i].line_b_shunt)im)     # Shunt line admittance
#     push!(line_smax_c_np,data_for_each_contingency[c][i].line_Smax_A)
#
#      end
#  else
#      for i in 1:nLines                                                                # nLines = nTrsf + nTransmission lines
#        push!(idx_from_line_c_p,data_for_each_contingency[c][i].line_from)                                # Saving 'from' end of lines in a vector
#        push!(idx_to_line_c_p,data_for_each_contingency[c][i].line_to)                                    # Saving 'to' end of lines in a vector
#        push!(yij_line_c_p,data_for_each_contingency[c][i].line_g+(data_for_each_contingency[c][i].line_b)im)               # Line admittance calculated from the given r and x values
#        push!(yij_line_sh_c_p,data_for_each_contingency[c][i].line_g_shunt+(data_for_each_contingency[c][i].line_b_shunt)im)     # Shunt line admittance
#        push!(line_smax_c_p,data_for_each_contingency[c][i].line_Smax_A)
#
#         end
#
#
#    end
# end
#
#
#
# # for c in 1:nCont
# #     for i in 1:nLines-1
# #         push!(idx_from_line_c,data_for_each_contingency[c][i].line_from)
# #         push!(idx_to_line_c,data_for_each_contingency[c][i].line_to)
# #         push!(yij_line_c,inv(data_for_each_contingency[c][i].line_r+(data_for_each_contingency[c][i].line_x)im))
# #         push!(yij_line_sh_c,data_for_each_contingency[c][i].line_g_shunt+(data_for_each_contingency[c][i].line_b_shunt)im)
# #         push!(line_smax_c,data_for_each_contingency[c][i].line_Smax_A)
# #         push!(tap_ratio_c,data_for_each_contingency[c][i].line_tap_ratio)
# #         push!(tap_ratio_min_c,data_for_each_contingency[c][i].line_tap_ratio_min)
# #         push!(tap_ratio_max_c,data_for_each_contingency[c][i].line_tap_ratio_max)
# #
# #     end
# # end
# # idx_from_line_new=[]
# # for c in 1:nCont
# #     if isempty(idx_pll[c])
# #   # for i in 1:nLines-1
# #       idx_from_aux=idx_from_line_c[1:size(data_for_each_contingency[c],1)]
# #       push!(idx_from_line_new,idx_from_aux)
# #   end
#
# idx_from_line_c_np=[idx_from_line_c_np[i+(nLines-2)*(i-1):i+(nLines-2)*(i-1)+(nLines-2)] for i in 1:nCont_nprll]
# idx_to_line_c_np  =[idx_to_line_c_np[i+(nLines-2)*(i-1):i+(nLines-2)*(i-1)+(nLines-2)] for i in 1:nCont_nprll ]
# yij_line_c_np     =[yij_line_c_np[i+(nLines-2)*(i-1):i+(nLines-2)*(i-1)+(nLines-2)] for i in 1:nCont_nprll]
# yij_line_sh_c_np  =[yij_line_sh_c_np[i+(nLines-2)*(i-1):i+(nLines-2)*(i-1)+(nLines-2)] for i in 1:nCont_nprll]
# line_smax_c_np    =[line_smax_c_np[i+(nLines-2)*(i-1):i+(nLines-2)*(i-1)+(nLines-2)] for i in 1:nCont_nprll]
#
#
#
# idx_from_line_c_p=[idx_from_line_c_p[i+(nLines-1)*(i-1):i+(nLines-1)*(i-1)+(nLines-1)] for i in 1:nCont_prll]
# idx_to_line_c_p  =[idx_to_line_c_p[i+(nLines-1)*(i-1):i+(nLines-1)*(i-1)+(nLines-1)] for i in 1:nCont_prll ]
# yij_line_c_p     =[yij_line_c_p[i+(nLines-1)*(i-1):i+(nLines-1)*(i-1)+(nLines-1)] for i in 1:nCont_prll]
# yij_line_sh_c_p  =[yij_line_sh_c_p[i+(nLines-1)*(i-1):i+(nLines-1)*(i-1)+(nLines-1)] for i in 1:nCont_prll]
# line_smax_c_p    =[line_smax_c_p[i+(nLines-1)*(i-1):i+(nLines-1)*(i-1)+(nLines-1)] for i in 1:nCont_prll]
#
# idx_from_line_c  =[idx_from_line_c_p;idx_from_line_c_np]
# idx_to_line_c  =[idx_to_line_c_p;idx_to_line_c_np]
# yij_line_c  =[yij_line_c_p;yij_line_c_np]
# yij_line_sh_c  =[yij_line_sh_c_p;yij_line_sh_c_np]
# line_smax_c  =[line_smax_c_p;line_smax_c_np]
idx_from_line_c=[]
idx_to_line_c  =[]
yij_line_c     =[]
yij_line_sh_c  =[]
line_smax_c    =[]
for c in 1:nCont
    # for i in 1:size(data_for_each_contingency[c],1)
        idx_from_line_c_aux=[data_for_each_contingency[c][i].line_from for i in 1:size(data_for_each_contingency[c],1)]
        idx_to_line_c_aux=[data_for_each_contingency[c][i].line_to for i in 1:size(data_for_each_contingency[c],1)]
        yij_line_c_g=[data_for_each_contingency[c][i].line_g for i in 1:size(data_for_each_contingency[c],1)]
        yij_line_c_b=[data_for_each_contingency[c][i].line_b for i in 1:size(data_for_each_contingency[c],1)]
        yij_line_sh_c_g=[data_for_each_contingency[c][i].line_g_shunt for i in 1:size(data_for_each_contingency[c],1)]
        yij_line_sh_c_b=[data_for_each_contingency[c][i].line_b_shunt for i in 1:size(data_for_each_contingency[c],1)]
        line_smax_c_aux=[data_for_each_contingency[c][i].line_Smax_A for i in 1:size(data_for_each_contingency[c],1)]
        push!(idx_from_line_c,idx_from_line_c_aux)
        push!(idx_to_line_c,idx_to_line_c_aux)
        push!(yij_line_c,yij_line_c_g+(yij_line_c_b)im   )
        push!(yij_line_sh_c,yij_line_sh_c_g+(yij_line_sh_c_b)im  )
        push!(line_smax_c,line_smax_c_aux)

    # end
end

# idx_from_line_c=[data_for_each_contingency[c][i].line_from for c in 1:nCont for i in 1:size(data_for_each_contingency[c],1) ]
#
# idx_from_line_c=[idx_from_line_c[c+(size(data_for_each_contingency[c],1)-1)*(c-1):c+(size(data_for_each_contingency[c],1)-1)*(c-1)+(size(data_for_each_contingency[c],1)-1)] for c in 1:1]

# tap_ratio_c  =[tap_ratio_c[i+(nLines-2)*(i-1):i+(nLines-2)*(i-1)+(nLines-2)] for i in 1:nCont]
# tap_ratio_min_c  =[tap_ratio_min_c[i+(nLines-2)*(i-1):i+(nLines-2)*(i-1)+(nLines-2)] for i in 1:nCont]
# tap_ratio_max_c  =[tap_ratio_max_c[i+(nLines-2)*(i-1):i+(nLines-2)*(i-1)+(nLines-2)] for i in 1:nCont]


# idx_from_line_c  = [data_for_each_contingency[i][:,1] for i in 1:nCont]
# idx_to_line_c    = [data_for_each_contingency[i][:,2] for i in 1:nCont]
# denominator      = [data_for_each_contingency[i][:,3].^2+data_for_each_contingency[i][:,4].^2  for i in 1:nCont]
# yij_line_c       = [data_for_each_contingency[i][:,3]./denominator[i]-(data_for_each_contingency[i][:,4]./denominator[i])im for i in 1:nCont  ]
# yij_line_sh_c    = [data_for_each_contingency[i][:,5]+data_for_each_contingency[i][:,6]im  for i in 1:nCont]
# line_smax_c      = [data_for_each_contingency[i][:,7] for i in 1:nCont]
# tap_ratio_c      = [data_for_each_contingency[i][:,10] for i in 1:nCont]
# tap_ratio_min_c  = [data_for_each_contingency[i][:,15] for i in 1:nCont]
# tap_ratio_max_c  = [data_for_each_contingency[i][:,16] for i in 1:nCont]

# nTrsf = [size(findall(x->x!=0.0,tap_ratio_c[i]),1)  for i in 1:nCont]
# #---------------------- Saving the indices of transformer ----------------------
# ones=[]
# for i in 1:nCont
#     ones_temp=1:nLines-1
#     push!(ones,ones_temp)
# end
# # for c in 1:nCont
# dLines_c = [idx_from_line_c idx_to_line_c ones ]
# tapp=[]
#
# for i in 1:nCont
#  float_tapp = convert.(Float64,tap_ratio_c[i])
#  push!(tapp,float_tapp)
# end
# # end
#
#     global idx_tapp = []
#     global ctr = 0
# for c in 1:nCont
#     for i in 1:size(tapp[c],1)
#         tap = tapp[c][i]
#         if tap != 0.0                                                            # Transformer branch
#             global  ctr = ctr+1
#             push!(idx_tapp,ctr)
#         elseif tap == 0.0                                                        # Transmission/Distribution line
#             push!(idx_tapp,0)
#         end
#     end
# end
# idx_tapp= reshape(idx_tapp,nCont,nLines-1)
#
# dLines_c = [dLines_c tapp]
# idx_tapp=transpose(idx_tapp)

# node_data_c      = []
# # for c in 1:nCont
# for c in 1:nCont
#   for i in 1:nBus
#     bus_num = nw_buses[i].bus_num
#     ft_line = findall(x->x==bus_num,idx_from_line_c[c])                               # index of all lines which are connected to bus i (bus i is present in 'from' column)
#     tf_line = findall(x->x==bus_num,idx_to_line_c[c])                                 # index of all lines which are connected to bus i (bus i is present in 'to' column)
#     telem   = size(ft_line,1)+size(tf_line,1)
#
#     ft_bus  = idx_to_line_c[c][ft_line]                                                # buses connected to bus i (bus i is present in 'from' column)
#     tf_bus  = idx_from_line_c[c][tf_line]                                              # buses connected to bus i (bus i is present in 'to' column)
#
#     b_lines  = union(ft_line,tf_line)                                            # indexes of all lines connected to bus (b) i
#     b_cbuses = union(ft_bus,tf_bus)                                              # buses connected to bus i
#
#     gij_line = real(yij_line_c[c][b_lines,1])
#     bij_line = imag(yij_line_c[c][b_lines,1])
#
#     gij_line_sh = real(yij_line_sh_c[c][b_lines,1])
#     bij_line_sh = imag(yij_line_sh_c[c][b_lines,1])
#
#     tp_rt     = vcat(tap_ratio_c[c][ft_line],tap_ratio_c[c][tf_line])
#     tp_rt_min = vcat(tap_ratio_min_c[c][ft_line],tap_ratio_min_c[c][tf_line])
#     tp_rt_max = vcat(tap_ratio_max_c[c][ft_line],tap_ratio_max_c[c][tf_line])
#     from_col  = idx_from_line_c[c][b_lines,1]
#     to_col    = idx_to_line_c[c][b_lines,1]
#     bus       = repeat([bus_num],telem)
#     iTap      = idx_tapp[b_lines,end]
#
#     push!(node_data_c,node_c(bus,b_cbuses,b_lines,gij_line_sh,gij_line,bij_line_sh,bij_line,tp_rt,tp_rt_min,tp_rt_max,from_col,to_col,iTap))
#    end
# end
# node_data_contin =[]
# for i in 1:nCont
#     push!(node_data_contin, node_data_c[i+(nLines-2)*(i-1):i+(nLines-2)*(i-1)+(nLines-2)])
# end

#------------------- Formatting the transformer data----------------------------
# tdata_c = []
# for c in 1:nCont
#     for i in 1:nBus
#     tdata_tap     = node_data_contin[c][i].node_idx_trsf_c
#     tdata_tap_min = node_data_contin[c][i].node_tap_ratio_min_c
#     tdata_tap_max = node_data_contin[c][i].node_tap_ratio_max_c
#     aa  = hcat(tdata_tap,tdata_tap_min,tdata_tap_max)
#     push!(tdata_c,aa)
#     end
# end

# tdata_cc =[]
# for i in 1:nCont
#     push!(tdata_cc, tdata_c[i+(nLines-2)*(i-1):i+(nLines-2)*(i-1)+(nLines-2)])
# end
#
# tdata_cc = [unique(vcat(tdata_cc[i]...),dims=1)  for i in 1:nCont]

# itap_tr_c = [findall(x->x!=0.0,tdata_cc[:,1][i]) for i in 1:nCont]      # Index of transformer not equal to zero
# itap_0_c  = [findall(x->x==0.0,tdata_cc[:,1][i]) for i in 1:nCont]       # Index of transformer equal to zero
# itap_r_c = []                                  # Rows that has to be removed based on the idx_r values
# for c in 1:nCont
# for i in 1:size(itap_0_c[c],1)
#     if iszero(tdata_cc[c][itap_0_c[i,1],:])       # Complete row is zero
#         push!(itap_r_c,itap_0_c[i,1])         # Saving the index of zero row in order to delete ir
#     elseif iszero(tdata_cc[c][itap_0_c[i,1],1]) && (!iszero(tdata_cc[c][itap_0_c[i,1],2]) || !iszero(tdata_cc[c][itap_0_c[i,1],3]))
#         global error_msg = "ERROR! The tap ratio is set to 0 but min and max tap ratio values are not set to zero. Is this a transformer branch or a distribution line?"
#         println(error_msg)
#         println("Check the transformer data!")      # Transformer branch constraint is not set for this condition
#     # elseif !iszero(tdata[itap_0[i,1],1]) && (iszero(tdata[itap_0[i,1],2]) && iszero(tdata[itap_0[i,1],3]))
#     #     global error_msg = "ERROR! The transformer min and max tap ratios are both set to 0"
#     #     println(error_msg)
#     #     println("Check the transformer data!")                                      # Transformer branch power injection constraint is replaced by the transmission line constraint
#     end
# end
# end
# itap_c = [union(setdiff(itap_0_c[i],itap_r_c[i])) for i in 1:nCont]
# # tdata = tdata[itap,:]
# tdata_cc = tdata_cc[itap_c, :]

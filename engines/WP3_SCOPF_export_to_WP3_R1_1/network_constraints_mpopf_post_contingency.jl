#------------------------ Network Constraints ----------------------------------
# ------------------------------------------------------------------------------
#---------------------------- Voltage Constraint -------------------------------
# for c in 1:nCont
#       for s in 1:nSc
#          for t in 1:nTP
#              for i in 1:nBus
#              # it is supposed that the voltage min and max are the same as normal operation
#                 # nd      = node_data[i,1].node_num
#                 # nd_num  = unique(nd)
#                 # nd_num  = nd_num[1,1]
#                 # idx_bus_gsheet  = findall(x->x==i,bus_data_gsheet)
#                 idx_bus_gsheet  = findall(x->x==i,bus_data_gsheet)
#                 idx_nd_num = findall(x->x==i,rdata_buses[:,1])
#                 idx_nd_num = idx_nd_num[1,1]
#                 # idx_bus_lsheet  = findall(x->x==nd_num,bus_data_lsheet)
#                 # idx_RES = findall(x->x==nd_num,RES_bus)
#             if nw_buses[i].bus_type==3                                           # Fixing the voltage at that bus whose type is 3 (Assuming this to be the Point of Common Coupling!)
#                 @constraint(acopf,f_c[c,s,t,i]==0.0)
#                 @constraint(acopf,(nw_buses[i].bus_vmin-v_relax_factor_min)<=e_c[c,s,t,i]<=(nw_buses[i].bus_vmax+v_relax_factor_max))
#
#             else
#                 @constraint(acopf,(nw_buses[i].bus_vmin-v_relax_factor_min)^2<=(e_c[c,s,t,i]^2+f_c[c,s,t,i]^2)<=(nw_buses[i].bus_vmax+v_relax_factor_max)^2)
#
#             # if ~isempty(idx_bus_gsheet)
#             #     idx_bus_gsheet  =idx_bus_gsheet[1,1]
#             #     @NLconstraint(acopf,sqrt(e_c[c,s,t,i]^2+f_c[c,s,t,i]^2)==(nw_gens[idx_bus_gsheet].gen_V_set))
#             # elseif nw_buses[idx_nd_num].bus_type==3
#             #     @constraint(acopf,(nw_buses[idx_nd_num].bus_vmin)^2<=(e_c[c,s,t,idx_nd_num]^2+f_c[c,s,t,idx_nd_num]^2)<=(nw_buses[idx_nd_num].bus_vmax)^2)
#             # else                                                                 # Constraint on the remaining buses
#                 # @constraint(acopf,f_c[c,s,t,idx_bus_gsheet]==array_bus[idx_bus_gsheet].bus_v_init_im)
#             end
#             # end
#      #  The following constraint limits the load shedding to be lower than the forecasted load at load buses and zero at others
# # idx_RES         = findall(x->x==nd_num,RES_bus)
#         # @constraint(acopf,0.0<=pen_lsh_c[c,s,t,idx_nd_num]<=prof_ploads[idx_nd_num,t])
#         # @constraint(acopf,0.0<=pen_ws_c[c,s,t,idx_RES]<=prof_PRES[s,t,idx_RES])
#
#
#         # @constraint(acopf,0.0<=Dn[c,s,t,idx_nd_num]<=prof_PRES[s,t,1])
#
#         end
#         end
#     end
# end

# @constraint(acopf, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus; nw_buses[i].bus_type==3], f_c[c,s,t,i]==0)
for c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus
    if  nw_buses[i].bus_type==3
        fix(f_c[c,s,t,i],0)
    end
end
for c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus
    if  nw_buses[i].bus_type==3
        set_lower_bound(e_c[c,s,t,i],nw_buses[i].bus_vmin)
        set_upper_bound(e_c[c,s,t,i],nw_buses[i].bus_vmax)
    end
end
# @constraint(acopf, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus; nw_buses[i].bus_type==3], nw_buses[i].bus_vmin+v_relax_factor_min<=e_c[c,s,t,i]<=nw_buses[i].bus_vmax+v_relax_factor_max)
@constraint(acopf, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus; nw_buses[i].bus_type!=3], (nw_buses[i].bus_vmin-v_relax_factor_min)^2<=(e_c[c,s,t,i]^2+f_c[c,s,t,i]^2)<=(nw_buses[i].bus_vmax+v_relax_factor_max)^2)



# @constraint(acopf,[c=1:nCont,s=1:nSc,t=1:nTP,i=1:nLoads],0.0<=pen_lsh_c[c,s,t,i]<=prof_ploads[i,t] )
# for c=1:nCont,s=1:nSc,t=1:nTP,i=1:nLoads
#     set_lower_bound(pen_lsh_c[c,s,t,i],0)
#     set_upper_bound(pen_lsh_c[c,s,t,i],prof_ploads[i,t])
# end
# @constraint(acopf, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nRES], 0.0<=pen_ws_c[c,s,t,i]<=prof_PRES[s,t,i])
# for c=1:nCont,s=1:nSc,t=1:nTP,i=1:nRES
#     set_lower_bound(pen_ws_c[c,s,t,i],0)
#     set_upper_bound(pen_ws_c[c,s,t,i],prof_PRES[s,t,i])
# end
# for c in 1:nCont
#     for s in 1:nSc
#         for t in 1:nTP
#             for i in 1:nBus
#                 nd      = node_data[i,1].node_num
#                 nd_num  = unique(nd)
#                 nd_num  = nd_num[1,1]
#                 idx_nd_num = findall(x->x==nd_num,rdata_buses[:,1])
#                 idx_nd_num = idx_nd_num[1,1]
#                 @constraint(acopf,0.0<=pen_lsh_c[c,s,t,idx_nd_num]<=prof_ploads[idx_nd_num,t])
#                 # @constraint(acopf,0.0<=pen_ws[s,t,idx_RES]<=prof_PRES[s,t,idx_RES])
#
#             end
#         end
#     end
# end
# for c in 1: nCont
#     for s in 1:nSc
#             for t in 1:nTP
#                 for i in 1:nRES
#                     # nd      = node_data[i,1].node_num
#                     # nd_num  = unique(nd)
#                     # nd_num  = nd_num[1,1]
#                     # idx_nd_num = findall(x->x==nd_num,rdata_buses[:,1])
#                     # idx_nd_num = idx_nd_num[1,1]
#                     # @constraint(acopf,0.0<=pen_lsh[s,t,idx_nd_num]<=prof_ploads[idx_nd_num,t])
#                     @constraint(acopf,0.0<=pen_ws_c[c,s,t,i]<=prof_PRES[s,t,i])
#
#                 end
#             end
#         end
# end
# ##--------------------- Non-Curtailable Gens -----------------------------------

# for c in 1:nCont
#                                                               # Here, 'nGens' is replaced by 'nNcurt_gen' parameter
#       for s in 1:nSc
#         for t in 1:nTP
#             for i in 1:nGens
#             # gbus = Int64(nd_ncurt_gen[i,1])
#             # pg_c = Pg_c[c,s,t,i]
#             # qg_c = Qg_c[c,s,t,i]
#             # @constraint(acopf,pg_min[s,t,i_ncurt_gens[i][1]]<=Pg_c[c,s,t,i]<=pg_max[s,t,i_ncurt_gens[i][1]])
#             # @constraint(acopf,qg_min[s,t,i_ncurt_gens[i][1]]<=Qg_c[c,s,t,i]<=qg_max[s,t,i_ncurt_gens[i][1]])
#             # @constraint(acopf,pg_min[s,t,i_ncurt_gens[i][1]]<=pg_c<=pg_max[s,t,i_ncurt_gens[i][1]])
#             # @constraint(acopf,qg_min[s,t,i_ncurt_gens[i][1]]<=qg_c)
#             # if  i==15
#             # # @constraint(acopf,Qg[s,t,i]==nw_gens[i].gen_Qg_avl)
#             # @constraint(acopf,Pg_c[c,s,t,i]==nw_gens[i].gen_Pg_avl)
#             # else
#             @constraint(acopf,pg_min[i]<= Pg_c[c,s,t,i]<=pg_max[i])
#             @constraint(acopf,qg_min[i]<=Qg_c[c,s,t,i]<=qg_max[i])
#             # end
#
#
#         end
#     end
#     end
# end

# @constraint(acopf, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nGens], pg_min[i]<= Pg_c[c,s,t,i]<=pg_max[i])
# @constraint(acopf, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nGens], qg_min[i]<=Qg_c[c,s,t,i]<=qg_max[i])
for c=1:nCont,s=1:nSc,t=1:nTP,i=1:nGens
    if pg_min[i]==0 && pg_max[i]==0
         fix(Pg_c[c,s,t,i],0)
    else
    set_lower_bound(Pg_c[c,s,t,i],pg_min[i])
    set_upper_bound(Pg_c[c,s,t,i],pg_max[i])
   end
    # set_lower_bound(Qg_c[c,s,t,i],qg_min[i])
    # set_upper_bound(Qg_c[c,s,t,i],qg_max[i])


end


#
# @constraint(acopf,
# [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus, j=1:size(node_data_trans[i].node_cnode,1);
# node_data_trans[i].node_tratio_min[j]!=1 || node_data_trans[i].node_tratio_max[j]!=1
# ],
# node_data_trans[i].node_tratio_min[j]<=tratio_c[c,s, t, i]<= node_data_trans[i].node_tratio_max[j]
# # tratio[s, t, i]== tratio[s, t, node_data_trans[i].node_cnode[j]]
# )
# @constraint(acopf,
# [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus, j=1:size(node_data_trans[i].node_cnode,1);
# node_data_trans[i].node_tratio_min[j]!=1 || node_data_trans[i].node_tratio_max[j]!=1
# ],
# # node_data_trans[i].node_tratio_min[j]<=tratio[s, t, i]<= node_data_trans[i].node_tratio_max[j]
# tratio_c[c,s, t, i]== tratio_c[c,s, t, node_data_trans[i].node_cnode[j]]
#
# )
# for c in 1:nCont
#     for s = 1:nSc
#         for t = 1:nTP                                                               # Here oen can replace nTP=1, if only element in the first time period has to be set!
#             for i = 1:nBus
#                 idx_nd_nw_buses = findall(x->x==i,rdata_buses[:,1])
#                 idx_nd_nw_buses=idx_nd_nw_buses[1,1]
#
#                   if ~isempty(node_data_trans[idx_nd_nw_buses,1].node_num)
#                       for j in 1:size(node_data_trans[idx_nd_nw_buses].node_cnode,1)
#
#                          idx_cnode_c=node_data_trans[idx_nd_nw_buses].node_cnode[j]
#                          idx_cnode_c=idx_cnode_c[1,1]
#                          tratio_min=node_data_trans[idx_nd_nw_buses].node_tratio_min[j]
#                          tratio_min=tratio_min[1,1]
#                          tratio_max=node_data_trans[idx_nd_nw_buses].node_tratio_max[j]
#                          tratio_max=tratio_max[1,1]
#                      if !(tratio_min!=1 || tratio_max!=1)
#                           fix(tratio_c[c,s, t, idx_nd_nw_buses], 1)
#                       end
#                   end
#                   end
#               end
#           end
#       end
#   end
# # end
#
# @constraint(acopf,[c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus,idx_bus_shunt   = findall(x->x==i,rdata_shunts[:,1]);
#                     ~isempty(idx_bus_shunt)],
#              nw_shunts[idx_bus_shunt].shunt_bshmin<=shnt_c[c,s,t,i]<=nw_shunts[idx_bus_shunt].shunt_bshmax
#             )
tratio_c=ones(nCont,nSc,nTP,nBus)

#---- Flexible load -----------------
# # for c=1:nCont,s=1:nSc,t=1:nTP,i=1:nFl
# #     set_lower_bound(p_fl_inc_c[c,s,t,i],0)
# #     set_upper_bound(p_fl_inc_c[c,s,t,i],load_inc_prct*prof_ploads[i,t])
#
# #     set_lower_bound(p_fl_dec_c[c,s,t,i],0)
# #     set_upper_bound(p_fl_dec_c[c,s,t,i],load_dec_prct*prof_ploads[i,t])
# # end
# @constraint(acopf,[c=1:nCont,s=1:nSc,i=1:nFl],sum(p_fl_inc_c[c,s,t,i] for t in 1:nTP)-sum(p_fl_dec_c[c,s,t,i] for t in 1:nTP)==0)

# @constraint(acopf,[c=1:nCont,s=1:nSc,t=1:nTP,i=1:nFl],p_fl_inc_c[c,s,t,i]/(load_inc_prct*prof_ploads[nd_fl[i],t])+p_fl_dec_c[c,s,t,i]/(load_dec_prct*prof_ploads[nd_fl[i],t]) <=1)
# @constraint(acopf,[c=1:nCont,s=1:nSc,t=1:nTP,i=1:nFl],q_fl_inc_c[c,s,t,i]/(load_inc_prct*prof_ploads[nd_fl[i],t])+q_fl_dec_c[c,s,t,i]/(load_dec_prct*prof_ploads[nd_fl[i],t]) <=1)
@constraint(acopf,[c=1:nCont,s=1:nSc,t=1:nTP,i=1:nFl;upper_flex_p_inc[i] != 0 && upper_flex_p_dec[i] != 0 ],p_fl_inc_c[c,s,t,i]/(upper_flex_p_inc[i])+p_fl_dec_c[c,s,t,i]/(upper_flex_p_dec[i]) <=1)
@constraint(acopf,[c=1:nCont,s=1:nSc,t=1:nTP,i=1:nFl;upper_flex_q_inc[i] != 0 && upper_flex_q_dec[i] != 0 ],q_fl_inc_c[c,s,t,i]/(upper_flex_q_inc[i])+q_fl_dec_c[c,s,t,i]/(upper_flex_q_dec[i]) <=1)



#---------------------Longitudnal Branch Current limit--------------------------
# if nCont_prll!=0
# for c in 1:nCont_prll
#     for s in 1:nSc
#         for t in 1:nTP
#             # if isempty(idx_pll[c])
#                 for i in 1:nLines
#                     gij_line_c = real(yij_line_c[c][i,1])
#                     bij_line_c = imag(yij_line_c[c][i,1])
#                     f_bus    = idx_from_line_c[c][i]
#                     t_bus    = idx_to_line_c[c][i]
#                     idx_f_bus_c = findall(x->x==f_bus,rdata_buses[:,1])
#                     idx_t_bus_c = findall(x->x==t_bus,rdata_buses[:,1])
#                     idx_f_bus_c = idx_f_bus_c[1,1]
#                     idx_t_bus_c = idx_t_bus_c[1,1]
#                     Smax_ij_c = (line_smax_c[c][i])./sbase
#                     Imax_lpu_c  = line_smax_c[c][i]
#                     lcrnt_lng_c_1 = @NLexpression(acopf,(gij_line_c^2+bij_line_c^2)*((e_c[c,s,t,idx_f_bus_c]-e_c[c,s,t,idx_t_bus_c])^2 + (f_c[c,s,t,idx_f_bus_c]-f_c[c,s,t,idx_t_bus_c])^2 ))
#                     @NLconstraint(acopf,lcrnt_lng_c_1<=Imax_lpu_c^2)
#                     exp = string("Contingency_$c-","Line_$i-","Sc_$s-","TP_$t")
#                     con_exp[:Icrnt][exp] = lcrnt_lng_c_1
#                 # end
#             end
#         end
#     end
# end
# end
# if nCont_prll!=0
# for c in 1:nCont_prll
#     for s in 1:nSc
#         for t in 1:nTP
#                 # for i in 1:nLines-1
#                     for i in 1:nLines
#                     # gij_line_c = real(yij_line_c[c][i,1])
#                     # bij_line_c = imag(yij_line_c[c][i,1])
#                     # f_bus    = idx_from_line_c[c][i]
#                     # t_bus    = idx_to_line_c[c][i]
#                     gij_line_c = real(yij_line[i,1])
#                     bij_line_c = imag(yij_line[i,1])
#
#                     f_bus    = nw_lines[i].line_from
#                     t_bus    = nw_lines[i].line_to
#                     idx_f_bus_c = findall(x->x==f_bus,rdata_buses[:,1])
#                     idx_t_bus_c = findall(x->x==t_bus,rdata_buses[:,1])
#                     idx_f_bus_c = idx_f_bus_c[1,1]
#                     idx_t_bus_c = idx_t_bus_c[1,1]
#
#                     if final_sep[c]==i
#                     Imax_lpu_c  = 0.5*nw_lines[i].line_Smax_A
#                     lcrnt_lng_c_1 = @NLexpression(acopf,((0.5*gij_line_c)^2+(0.5*bij_line_c)^2)*((e_c[c,s,t,idx_f_bus_c]-e_c[c,s,t,idx_t_bus_c])^2 + (f_c[c,s,t,idx_f_bus_c]-f_c[c,s,t,idx_t_bus_c])^2 ))
#                     @NLconstraint(acopf,lcrnt_lng_c_1<=Imax_lpu_c^2)
#                     else
#                     Imax_lpu_c  = nw_lines[i].line_Smax_A
#                     lcrnt_lng_c_2 = @NLexpression(acopf,(gij_line_c^2+bij_line_c^2)*((e_c[c,s,t,idx_f_bus_c]-e_c[c,s,t,idx_t_bus_c])^2 + (f_c[c,s,t,idx_f_bus_c]-f_c[c,s,t,idx_t_bus_c])^2 ))
#                     @NLconstraint(acopf,lcrnt_lng_c_2<=Imax_lpu_c^2)
#
#                     # exp = string("Contingency_$c-","Line_$i-","Sc_$s-","TP_$t")
#                     # con_exp[:Icrnt][exp] = lcrnt_lng_c_2
#
#                     # idx_f_bus_c = findall(x->x==f_bus,rdata_buses[:,1])
#                     # idx_t_bus_c = findall(x->x==t_bus,rdata_buses[:,1])
#                     # idx_f_bus_c = idx_f_bus_c[1,1]
#                     # idx_t_bus_c = idx_t_bus_c[1,1]
#                     # Smax_ij_c = (line_smax_c[c][i])./sbase
#                     # Imax_lpu_c  = line_smax_c[c][i]
#                     # lcrnt_lng_c_2 = @NLexpression(acopf,(gij_line_c^2+bij_line_c^2)*((e_c[c,s,t,idx_f_bus_c]-e_c[c,s,t,idx_t_bus_c])^2 + (f_c[c,s,t,idx_f_bus_c]-f_c[c,s,t,idx_t_bus_c])^2 ))
#                     # @NLconstraint(acopf,lcrnt_lng_c_2<=Imax_lpu_c^2)
#                     # exp = string("Contingency_$c-","Line_$i-","Sc_$s-","TP_$t")
#                     # con_exp[:Icrnt][exp] = lcrnt_lng_c_2
#                end
#            end
#         end
#     end
# end
# end
#

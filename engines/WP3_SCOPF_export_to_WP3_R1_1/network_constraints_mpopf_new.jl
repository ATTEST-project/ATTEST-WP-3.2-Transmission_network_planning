# for s in 1:nSc
#         for t in 1:nTP
#             for i in 1:nBus
#         # nd      = node_data[i,1].node_num
#         # nd_num  = unique(nd)
#         # nd_num  = nd_num[1,1]
#         # idx_nd_num = findall(x->x==nd_num,rdata_buses[:,1])
#         # idx_nd_num = idx_nd_num[1,1]
#             # if nw_buses[i].bus_type==3                                           # Fixing the voltage at that bus whose type is 3 (Assuming this to be the Point of Common Coupling!)
#             #     @constraint(acopf,0.0<=f[s,t,idx_nd_num]<=eps(1.0))
#             #     @constraint(acopf,nw_buses[idx_nd_num].bus_vmin<=e[s,t,idx_nd_num]<=nw_buses[idx_nd_num].bus_vmax)
#             # else                                                                 # Constraint on the remaining buses
#             #     @constraint(acopf,(nw_buses[idx_nd_num].bus_vmin)^2<=(e[s,t,idx_nd_num]^2+f[s,t,idx_nd_num]^2)<=(nw_buses[idx_nd_num].bus_vmax)^2)
#             # end
#             if nw_buses[i].bus_type==3                                           # Fixing the voltage at that bus whose type is 3 (Assuming this to be the Point of Common Coupling!)
#                 @constraint(acopf,f[s,t,i]==0)
#                 @constraint(acopf,nw_buses[i].bus_vmin<=e[s,t,i]<=nw_buses[i].bus_vmax)
#             else                                                                 # Constraint on the remaining buses
#                 @constraint(acopf,(nw_buses[i].bus_vmin)^2<=(e[s,t,i]^2+f[s,t,i]^2)<=(nw_buses[i].bus_vmax)^2)
#             # end
#             #  idx_bus_gsheet  = findall(x->x==i,bus_data_gsheet)
#             # if nw_buses[i].bus_type==3                                           # Fixing the voltage at that bus whose type is 3 (Assuming this to be the Point of Common Coupling!)
#             #     @constraint(acopf,0.0<=f[s,t,i]<=eps(1.0))
#             #     @constraint(acopf,e[s,t,i]==1.0611)
#             # elseif ~isempty(idx_bus_gsheet)
#             #         idx_bus_gsheet=idx_bus_gsheet[1,1]                                                             # Constraint on the remaining buses
#             #     @constraint(acopf,(e[s,t,i]^2+f[s,t,i]^2)==(nw_gens[idx_bus_gsheet].gen_V_set)^2)
#             # else
#             #     @constraint(acopf,(nw_buses[i].bus_vmin-0.15)^2<=(e[s,t,i]^2+f[s,t,i]^2)<=(nw_buses[i].bus_vmax+0.15)^2)
#             #
#             end
#
#
#
#
#
#             # idx_RES         = findall(x->x==nd_num,RES_bus)
#             # # idx_RES  =idx_RES[1,1]
#             # @constraint(acopf,0.0<=pen_lsh[s,t,idx_nd_num]<=prof_ploads[idx_nd_num,t])
#             # @constraint(acopf,0.0<=pen_ws[s,t,idx_RES]<=prof_PRES[s,t,idx_RES])
#
#         end
#     end
# end
# @constraint(acopf, [s=1:nSc,t=1:nTP,i=1:nBus; nw_buses[i].bus_type==3], f[s,t,i]==0)
for s=1:nSc,t=1:nTP,i=1:nBus
    if  nw_buses[i].bus_type==3
        fix(f[s,t,i],0)
    end
end
# @constraint(acopf, [s=1:nSc,t=1:nTP,i=1:nBus; nw_buses[i].bus_type==3], nw_buses[i].bus_vmin<=e[s,t,i]<=nw_buses[i].bus_vmax)
for s=1:nSc,t=1:nTP,i=1:nBus
    if  nw_buses[i].bus_type==3
        set_lower_bound(e[s,t,i],nw_buses[i].bus_vmin)
        set_upper_bound(e[s,t,i],nw_buses[i].bus_vmax)
    end
end
@constraint(acopf, [s=1:nSc,t=1:nTP,i=1:nBus; nw_buses[i].bus_type!=3], (nw_buses[i].bus_vmin)^2<=(e[s,t,i]^2+f[s,t,i]^2)<=(nw_buses[i].bus_vmax)^2)

#----------------load shedding -----------------
# @constraint(acopf,[s=1:nSc,t=1:nTP,i=1:nLoads],0.0<=pen_lsh[s,t,i]<=prof_ploads[i,t] )
# for s=1:nSc,t=1:nTP,i=1:nLoads
#     set_lower_bound(pen_lsh[s,t,i],0)
#     set_upper_bound(pen_lsh[s,t,i],prof_ploads[i,t])
# end
# for s in 1:nSc
#         for t in 1:nTP
#             for i in 1:nBus
#                 # nd      = node_data[i,1].node_num
#                 # nd_num  = unique(nd)
#                 # nd_num  = nd_num[1,1]
#                 # idx_nd_num = findall(x->x==nd_num,rdata_buses[:,1])
#                 # idx_nd_num = idx_nd_num[1,1]
#                 # @constraint(acopf,0.0<=pen_lsh[s,t,idx_nd_num]<=prof_ploads[idx_nd_num,t])
#                 @constraint(acopf,0.0<=pen_lsh[s,t,i]<=prof_ploads[i,t])
#                 # @constraint(acopf,0.0<=pen_ws[s,t,idx_RES]<=prof_PRES[s,t,idx_RES])
#
#             end
#         end
#     end
#----------------wind spillage-----------------
# @constraint(acopf, [s=1:nSc,t=1:nTP,i=1:nRES], 0.0<=pen_ws[s,t,i]<=prof_PRES[s,t,i])
# for s=1:nSc,t=1:nTP,i=1:nRES
#     set_lower_bound(pen_ws[s,t,i],0)
#     set_upper_bound(pen_ws[s,t,i],prof_PRES[s,t,i])
# end
    # for s in 1:nSc
    #         for t in 1:nTP
    #             for i in 1:nRES
    #                 # nd      = node_data[i,1].node_num
    #                 # nd_num  = unique(nd)
    #                 # nd_num  = nd_num[1,1]
    #                 # idx_nd_num = findall(x->x==nd_num,rdata_buses[:,1])
    #                 # idx_nd_num = idx_nd_num[1,1]
    #                 # @constraint(acopf,0.0<=pen_lsh[s,t,idx_nd_num]<=prof_ploads[idx_nd_num,t])
    #                 @constraint(acopf,0.0<=pen_ws[s,t,i]<=prof_PRES[s,t,i])
    #
    #             end
    #         end
    #     end

#------------------- Transformer tap ratio constraint --------------------------
# for i in 1:size(tdata,1)
#     for s in 1:nSc
#         for t in 1:nTP
#             if (tdata[i,1]!=0.0) && (tdata[i,2]!=0.0) && (tdata[i,3]!=0.0)
#                 idx = Int64(tdata[i,1])
#                 @constraint(acopf,tdata[idx,2]<=tratio[s,t,idx]<=tdata[idx,3])
#             end
#         end
#     end
# end
#-------------Active and reactive power limits on generators--------------------
# for i in 1:nGens
#     for s in 1:nSc
#         for t in 1:nTP
              # gbus = Int64(bus_data_gsheet[i,1])
#             pg = Pg[s,t,i]
#             qg = Qg[s,t,i]
#             @constraint(acopf,pg_min[s,t,i]<=pg<=pg_max[s,t,i])
#             @constraint(acopf,qg_min[s,t,i]<=qg<=qg_max[s,t,i])
#         end
#     end
# end
#--------------------- Non-Curtailable Gens -----------------------------------
                                                           # Here, 'nGens' is replaced by 'nNcurt_gen' parameter
#     for s in 1:nSc
#         for t in 1:nTP
#             # for i in 1:nNcurt_gen
#                 for i in 1:nGens
#
#                 # for i in 3:5
#             # gbus = Int64(nd_ncurt_gen[i,1])
#             # pg = Pg[s,t,i]
#             # qg = Qg[s,t,i]
#             # @constraint(acopf,pg_min[s,t,i_ncurt_gens[i][1]]<= Pg[s,t,i]<=pg_max[s,t,i_ncurt_gens[i][1]])
#             # @constraint(acopf,qg_min[s,t,i_ncurt_gens[i][1]]<=Qg[s,t,i]<=qg_max[s,t,i_ncurt_gens[i][1]])
#             # if  i==13
#             # # @constraint(acopf,Qg[s,t,i]==nw_gens[i].gen_Qg_avl)
#             # @constraint(acopf,Pg[s,t,i]==nw_gens[i].gen_Pg_avl)
#             # else
#             @constraint(acopf,pg_min[i]<= Pg[s,t,i]<=pg_max[i])
#             @constraint(acopf,qg_min[i]<=Qg[s,t,i]<=qg_max[i])
#             # end
#         end
#     end
# end
# @constraint(acopf, [s=1:nSc,t=1:nTP,i=1:nGens], pg_min[i]<= Pg[s,t,i]<=pg_max[i])
# @constraint(acopf, [s=1:nSc,t=1:nTP,i=1:nGens], qg_min[i]<=Qg[s,t,i]<=qg_max[i])
for s=1:nSc,t=1:nTP,i=1:nGens
    if pg_min[i]==0 && pg_max[i]==0
     fix(Pg[s,t,i],0)
   else
    set_lower_bound(Pg[s,t,i],pg_min[i])
    set_upper_bound(Pg[s,t,i],pg_max[i])
   end
    # set_lower_bound(Qg[s,t,i],qg_min[i])
    # set_upper_bound(Qg[s,t,i],qg_max[i])
end

#---- Flexible load -----------------
# # for s=1:nSc,t=1:nTP,i=1:nFl
# #     set_lower_bound(p_fl_inc[s,t,i],0)
# #    set_upper_bound(p_fl_inc[s,t,i],load_inc_prct*prof_ploads[i,t])
# #
# #     set_lower_bound(p_fl_dec[s,t,i],0)
# #     set_upper_bound(p_fl_dec[s,t,i],load_dec_prct*prof_ploads[i,t])
# # end
# @constraint(acopf,[s=1:nSc,i=1:nFl],sum(p_fl_inc[s,t,i] for t in 1:nTP)==sum(p_fl_dec[s,t,i] for t in 1:nTP))

# @constraint(acopf,[s=1:nSc,t=1:nTP,i=1:nFl],p_fl_inc[s,t,i]/(load_inc_prct*prof_ploads[nd_fl[i],t])+p_fl_dec[s,t,i]/(load_dec_prct*prof_ploads[nd_fl[i],t]) <=1)
# @constraint(acopf,[s=1:nSc,t=1:nTP,i=1:nFl],q_fl_inc[s,t,i]/(load_inc_prct_q*prof_qloads[nd_fl[i],t])+q_fl_dec[s,t,i]/(load_dec_prct_q*prof_qloads[nd_fl[i],t]) <=1)
@constraint(acopf,[s=1:nSc,t=1:nTP,i=1:nFl;upper_flex_p_inc[i] != 0 && upper_flex_p_dec[i] != 0 ],p_fl_inc[s,t,i]/(upper_flex_p_inc[i])+p_fl_dec[s,t,i]/(upper_flex_p_dec[i]) <=1)
@constraint(acopf,[s=1:nSc,t=1:nTP,i=1:nFl;upper_flex_q_inc[i] != 0 && upper_flex_q_dec[i] != 0 ],q_fl_inc[s,t,i]/(upper_flex_q_inc[i])+q_fl_dec[s,t,i]/(upper_flex_q_dec[i]) <=1)

#---------------------Longitudnal Branch Current limit--------------------------

# gij_lin = real(yij_line)
# bij_lin = imag(yij_line)
# l_crnt_const=@constraint(acopf,
# # begin
#  [i=1:nLines,s=1:nSc,t=1:nTP,
#  f_bus    = nw_lines[i].line_from,
#  t_bus    = nw_lines[i].line_to,
#  idx_f_bus = findall(x->x==f_bus,rdata_buses[:,1]),
#  idx_t_bus = findall(x->x==t_bus,rdata_buses[:,1]),
#  ],
#
# (gij_lin[i]^2+bij_lin[i]^2)*((e[s,t,idx_f_bus]-e[s,t,idx_t_bus])^2 + (f[s,t,idx_f_bus]-f[s,t,idx_t_bus])^2)<=(nw_lines[i].line_Smax_A)^2
# # end
#  )
#-------------------------tratio

# # for c in 1:nCont
#     for s = 1:nSc
#         for t = 1:nTP
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
#                           fix(tratio[s, t, idx_nd_nw_buses], 1)
#                       end
#                   end
#                   end
#               end
#           end
#       end

tratio=ones(nSc,nTP,nBus)
# ----------------------------shunt---------------------------
# @constraint(acopf,[s=1:nSc,t=1:nTP,i=1:nBus,idx_bus_shunt   = findall(x->x==i,rdata_shunts[:,1]);
#                     ~isempty(idx_bus_shunt)],
#              nw_shunts[idx_bus_shunt].shunt_bshmin<=shnt[s,t,i]<=nw_shunts[idx_bus_shunt].shunt_bshmax
#             )

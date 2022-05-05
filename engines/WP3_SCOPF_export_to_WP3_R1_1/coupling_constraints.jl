#------ preventive mode generation-------
# ramp_rate=[array_gens[i].gen_ramp_30./sbase for i in 1:nGens]
# for c in 1:nCont
#     for s in 1:nSc
#         for t in 1:nTP
#             for i in 1:nGens
#                 if i!=15
#             # for i in 3:5
#             # @NLconstraint(acopf,(Pg_c[c,s,t,i]-Pg[s,t,i])^2<=ramp_rate[i]^2)
#             # @constraint(acopf,-eps(1.0)<=Pg_c[c,s,t,3]-Pg[s,t,3]<=eps(1.0))
#             # @constraint(acopf,-eps(1.0)<=Pg_c[c,s,t,2]-Pg[s,t,2]<=eps(1.0))
#             # @constraint(acopf,-eps(1.0)<=Pg_c[c,s,t,i]-Pg[s,t,i]<=eps(1.0))
#             @constraint(acopf,Pg_c[c,s,t,i]-Pg[s,t,i]==0.0)
#             # @NLconstraint(acopf,diff[c,s,t,i]<=ramp_rate[i])
#             # @NLconstraint(acopf,diff[c,s,t,i]<=200)
#         end
#         end
#     end
# end
# end

#-------preventive mode voltage
# delta_voltage=[nw_buses[i].bus_delta_v for i in 1:nBus]
# for c in 1:nCont
#       for s in 1:nSc
#          for t in 1:nTP
#              for i in 1:nGens
#                  # for i in 3:5
#
#              # it is supposed that the voltage min and max are the same as normal operation
#                 # nd      = node_data[i,1].node_num
#                 # nd_num  = unique(nd)
#                 # nd_num  = nd_num[1,1]
#                 # idx_nd_num = findall(x->x==nd_num,rdata_buses[:,1])
#                 # idx_nd_num = idx_nd_num[1,1]
#                 @NLconstraint(acopf,e_c[c,s,t,bus_data_gsheet[i]]^2 +f_c[c,s,t,bus_data_gsheet[i]]^2 ==e[s,t,bus_data_gsheet[i]]^2 +f[s,t,bus_data_gsheet[i]]^2)
#
#         end
#         end
#     end
# end
#---------------------------
####------ Corrective mode generation------
# ramp_rate=[array_gens[i].gen_ramp_30./sbase for i in 1:nGens]
ramp_rate=2
# for c in 1:nCont
#     for s in 1:nSc
#         for t in 1:nTP
#             for i in 1:nGens
#             # for i in 3:5
#             # @NLconstraint(acopf,(Pg_c[c,s,t,i]-Pg[s,t,i])^2<=ramp_rate[i]^2)
#             @NLconstraint(acopf,(Pg_c[c,s,t,i]-Pg[s,t,i])^2<=ramp_rate^2)
#
#
#         end
#     end
# end
# end
@constraint(acopf, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nGens],
(Pg_c[c,s,t,i]-Pg[s,t,i])^2<=ramp_rate^2
)
#########-------corrective mode voltage
## delta_voltage=[nw_buses[i].bus_delta_v for i in 1:nBus]
# delta_voltage=0.03
# for c in 1:nCont
#       for s in 1:nSc
#          for t in 1:nTP
#              for i in 1:nGens
#                  # for i in 3:5
#
#              # it is supposed that the voltage min and max are the same as normal operation
#                 # nd      = node_data[i,1].node_num
#                 # nd_num  = unique(nd)
#                 # nd_num  = nd_num[1,1]
#                 # idx_nd_num = findall(x->x==nd_num,rdata_buses[:,1])
#                 # idx_nd_num = idx_nd_num[1,1]
#             if nw_buses[bus_data_gsheet[i]].bus_type==3                                           # Fixing the voltage at that bus whose type is 3 (Assuming this to be the Point of Common Coupling!)
#                 # @NLconstraint(acopf,(e_c[c,s,t,bus_data_gsheet[i]]-e[s,t,bus_data_gsheet[i]])^2<=delta_voltage[bus_data_gsheet[i]]^2)
#                 @NLconstraint(acopf,(e_c[c,s,t,bus_data_gsheet[i]]-e[s,t,bus_data_gsheet[i]])^2<=delta_voltage^2)
#             else                                                                 # Constraint on the remaining buses
#                 # @NLconstraint(acopf,(sqrt(e_c[c,s,t,bus_data_gsheet[i]]^2 +f_c[c,s,t,bus_data_gsheet[i]]^2) -sqrt(e[s,t,bus_data_gsheet[i]]^2 +f[s,t,bus_data_gsheet[i]]^2))^2<=delta_voltage[bus_data_gsheet[i]]^2)
#                 @NLconstraint(acopf,(sqrt(e_c[c,s,t,bus_data_gsheet[i]]^2 +f_c[c,s,t,bus_data_gsheet[i]]^2) -sqrt(e[s,t,bus_data_gsheet[i]]^2 +f[s,t,bus_data_gsheet[i]]^2))^2<=delta_voltage^2)
#
#             end
#         end
#         end
#     end
# end

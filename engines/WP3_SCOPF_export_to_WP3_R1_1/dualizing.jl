##----------active line flow for each line for each state------------------
flow_normal_aux_s=@expression(acopf, [s in 1:nSc, t in 1:nTP, l in 1:nLines],
(value.(pinj_dict_sr[[s,t,idx_from_line[l],idx_to_line[l]]]))^2+(value.(qinj_dict_sr[[s,t,idx_from_line[l],idx_to_line[l]]]))^2
  )

flow_normal_s=JuMP.value.(flow_normal_aux_s).^0.5


flow_normal_aux_r=@expression(acopf, [s in 1:nSc, t in 1:nTP, l in 1:nLines],
(value.(pinj_dict_sr[[s,t,idx_to_line[l],idx_from_line[l]]]))^2+(value.(qinj_dict_sr[[s,t,idx_to_line[l],idx_from_line[l]]]))^2
 )
flow_normal_r=JuMP.value.(flow_normal_aux_r).^0.5









flow_contin_aux_s=@expression(acopf, [c in 1:nCont, s in 1:nSc, t in 1:nTP,l in 1:length(idx_from_line_c[c]) ],
sqrt((value.(pinj_dict_c_sr[[c,s,t,idx_from_line_c[c][l],idx_to_line_c[c][l]]]))^2+(value.(qinj_dict_c_sr[[c,s,t,idx_from_line_c[c][l],idx_to_line_c[c][l]]]))^2)
            )
flow_contin_s=JuMP.value.(flow_contin_aux_s)

flow_contin_aux_r=@expression(acopf, [c in 1:nCont, s in 1:nSc, t in 1:nTP,l in 1:length(idx_from_line_c[c]) ],
sqrt((value.(pinj_dict_c_sr[[c,s,t,idx_to_line_c[c][l],idx_from_line_c[c][l]]]))^2+(value.(qinj_dict_c_sr[[c,s,t,idx_to_line_c[c][l],idx_from_line_c[c][l]]]))^2)
            )
flow_contin_r=JuMP.value.(flow_contin_aux_r)

# ##----------reactive line flow for each line for each state------------------
# reactive_flow_normal_aux=@expression(acopf, [s in 1:nSc, t in 1:nTP, l in 1:nLines],
# # sqrt((pinj_dict[[s,t,b,j]])^2+(qinj_dict[[s,t,b,j]])^2)
# qinj_dict[[s,t,idx_from_line[l],idx_to_line[l]]]
#  )
# reactive_flow_normal=JuMP.value.(reactive_flow_normal_aux)
#
#
#
# reactive_flow_contin_aux=@expression(acopf, [c in 1:nCont, s in 1:nSc, t in 1:nTP,l in 1:length(idx_from_line_c[c]) ],
#
#             # sqrt((pinj_dict_c[[c,s,t,b,j]])^2+(qinj_dict_c[[c,s,t,b,j]])^2)
# qinj_dict_c[[c,s,t,idx_from_line_c[c][l],idx_to_line_c[c][l]]]
#             )
# reactive_flow_contin=JuMP.value.(reactive_flow_contin_aux)



#------dual values of the line flow constraints----------------------


line_flow_normal_dual_s=JuMP.dual.(line_flow_normal_s)
# line_flow_normal_dual_s=line_flow_normal_dual_s[1,1,:]

line_flow_normal_dual_r=JuMP.dual.(line_flow_normal_r)
# line_flow_normal_dual_r=line_flow_normal_dual_r[1,1,:]



line_flow_contin_dual_s=JuMP.dual.(line_flow_contin_s)
line_flow_contin_dual_r=JuMP.dual.(line_flow_contin_r)






#-------------dual values of poewr balance constraints----------
active_poewr_balance_normal_dual=JuMP.dual.(active_poewr_balance_normal)
active_poewr_balance_normal_dual=active_poewr_balance_normal_dual[1,1,:]



reactive_poewr_balance_normal_dual=JuMP.dual.(reactive_poewr_balance_normal)
reactive_poewr_balance_normal_dual=reactive_poewr_balance_normal_dual[1,1,:]



active_poewr_balance_contin_dual=JuMP.dual.(active_poewr_balance_contin)
active_poewr_balance_contin_dual=active_poewr_balance_contin_dual[:,1,1,:]

reactive_poewr_balance_contin_dual=JuMP.dual.(reactive_poewr_balance_contin)
reactive_poewr_balance_contin_dual=reactive_poewr_balance_contin_dual[:,1,1,:]

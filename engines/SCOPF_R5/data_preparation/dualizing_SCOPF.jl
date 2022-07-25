# output=Dict(
pinj_dict=output[:pinj_dict]
qinj_dict=output[:qinj_dict]
pinj_dict_c=output[:pinj_dict_c]
qinj_dict_c=output[:qinj_dict_c]
active_power_balance_normal=output[:active_power_balance_normal]
active_power_balance_contin=output[:active_power_balance_contin]
reactive_power_balance_normal=output[:reactive_power_balance_normal]
reactive_power_balance_contin=output[:reactive_power_balance_contin]
line_flow_normal_s=output[:line_flow_normal_s]
line_flow_normal_r=output[:line_flow_normal_r]
line_flow_normal_trans_s=output[:line_flow_normal_trans_s]
line_flow_normal_trans_r=output[:line_flow_normal_trans_r]
line_flow_contin_s=output[:line_flow_contin_s]
line_flow_contin_r=output[:line_flow_contin_r]
line_flow_contin_trans_s=output[:line_flow_contin_trans_s]
line_flow_contin_trans_r=output[:line_flow_contin_trans_r]
total_cost=output[:total_cost]
cost_gen=output[:cost_gen]
cost_pen_lsh=output[:cost_pen_lsh]
cost_fl=output[:cost_fl]
cost_str=output[:cost_str]
cost_pen_ws=output[:cost_pen_ws]
cost_pen_lsh_c=output[:cost_pen_lsh_c]
cost_pen_ws_c=output[:cost_pen_ws_c]
cost_fl_c=output[:cost_fl_c]
cost_str_c=output[:cost_str_c]
# )

##----------active and reactive line flow for each line for normal state------------------
active_line_flow_normal_lines=@expression(model_name, [ b in 1:nBus, j in node_data[b].node_cnode; ~isempty(node_data[b].node_num)], value.(pinj_dict[[1,b,j]]))
active_line_flow_normal_trans=@expression(model_name, [ b in 1:nBus, j in node_data_trans[b,1].node_cnode; ~isempty(node_data_trans[b,1].node_num)], value.(pinj_dict[[1,b,j]]))
active_line_flow_normal=Dict{Tuple{Int64,Int64},Float64}()

for i in eachindex(active_line_flow_normal_lines)
    push!(active_line_flow_normal, i=>value.(active_line_flow_normal_lines[i]))
end

for i in eachindex(active_line_flow_normal_trans)
    push!(active_line_flow_normal, i=>value.(active_line_flow_normal_trans[i]))
end

reactive_line_flow_normal_lines=@expression(model_name, [ b in 1:nBus, j in node_data[b].node_cnode; ~isempty(node_data[b].node_num)], value.(qinj_dict[[1,b,j]]))
reactive_line_flow_normal_trans=@expression(model_name, [ b in 1:nBus, j in node_data_trans[b,1].node_cnode; ~isempty(node_data_trans[b,1].node_num)], value.(qinj_dict[[1,b,j]]))
reactive_line_flow_normal=Dict{Tuple{Int64,Int64},Float64}()

for i in eachindex(reactive_line_flow_normal_lines)
    push!(reactive_line_flow_normal, i=>value.(reactive_line_flow_normal_lines[i]))
end

for i in eachindex(reactive_line_flow_normal_trans)
    push!(reactive_line_flow_normal, i=>value.(reactive_line_flow_normal_trans[i]))
end
#--------------active and reactive power flow for post contingency states--------------------
active_line_flow_contin_lines=@expression(model_name, [c in 1:nCont, b in 1:nBus, j in node_data_contin[c][b].node_cnode_c; ~isempty(node_data_contin[c][b].node_num_c)], value.(pinj_dict_c[[c,1,1,b,j]]))
active_line_flow_contin_trans=@expression(model_name, [c in 1:nCont, b in 1:nBus, j in node_data_trans[b,1].node_cnode;     ~isempty(node_data_trans[b,1].node_num)],     value.(pinj_dict_c[[c,1,1,b,j]]))
active_line_flow_contin=Dict{NTuple{3,Int64},Float64}()

for i in eachindex(active_line_flow_contin_lines)
    push!(active_line_flow_contin, i=>value.(active_line_flow_contin_lines[i]))
end

for i in eachindex(active_line_flow_contin_trans)
    push!(active_line_flow_contin, i=>value.(active_line_flow_contin_trans[i]))
end
reactive_line_flow_contin_lines=@expression(model_name, [c in 1:nCont, b in 1:nBus, j in node_data_contin[c][b].node_cnode_c; ~isempty(node_data_contin[c][b].node_num_c)], value.(qinj_dict_c[[c,1,1,b,j]]))
reactive_line_flow_contin_trans=@expression(model_name, [c in 1:nCont, b in 1:nBus, j in node_data_trans[b,1].node_cnode;     ~isempty(node_data_trans[b,1].node_num)],     value.(qinj_dict_c[[c,1,1,b,j]]))
reactive_line_flow_contin=Dict{NTuple{3,Int64},Float64}()

for i in eachindex(reactive_line_flow_contin_lines)
    push!(reactive_line_flow_contin, i=>value.(reactive_line_flow_contin_lines[i]))
end

for i in eachindex(reactive_line_flow_contin_trans)
    push!(reactive_line_flow_contin, i=>value.(reactive_line_flow_contin_trans[i]))
end


#------dual values of the line flow constraints----------------------


line_flow_normal_dual_s=JuMP.dual.(line_flow_normal_s)
# line_flow_normal_dual_s=line_flow_normal_dual_s[1,1,:]

line_flow_normal_dual_r=JuMP.dual.(line_flow_normal_r)
# line_flow_normal_dual_r=line_flow_normal_dual_r[1,1,:]
for i in 1:nLines
    if line_flow_normal_dual_r[i]>line_flow_normal_dual_s[i]   #maximum value between i-j and j-i
        replace(line_flow_normal_dual_s, line_flow_normal_dual_s[i]=>line_flow_normal_dual_r[i])
    end
end


line_flow_normal_trans_dual_s=JuMP.dual.(line_flow_normal_trans_s)
line_flow_normal_trans_dual_r=JuMP.dual.(line_flow_normal_trans_r)

for i in 1:nTrans
    if line_flow_normal_trans_dual_r[i]>line_flow_normal_trans_dual_s[i]    #maximum value between i-j and j-i
        replace(line_flow_normal_trans_dual_s, line_flow_normal_trans_dual_s[i]=>line_flow_normal_trans_dual_r[i])
    end
end

line_flow_normal_dict=Dict{NTuple{2,Int64},Float64}()
for i in 1:nLines
    push!(line_flow_normal_dict, (idx_from_line[i],idx_to_line[i])=>line_flow_normal_dual_s[i])
end

for i in 1:nTrans
    push!(line_flow_normal_dict, (idx_from_trans[i],idx_to_trans[i])=>line_flow_normal_trans_dual_s[i])
end










line_flow_contin_dual_s=JuMP.dual.(line_flow_contin_s)
line_flow_contin_dual_r=JuMP.dual.(line_flow_contin_r)
 for i in eachindex(line_flow_contin_dual_s)   #maximum value between i-j and j-i
     if line_flow_contin_dual_r[i]>line_flow_contin_dual_s[i]
          replace(line_flow_contin_dual_s, line_flow_contin_dual_s[i] =>line_flow_contin_dual_r[i])
      end
  end

line_flow_contin_trans_dual_s=JuMP.dual.(line_flow_contin_trans_s)
line_flow_contin_trans_dual_r=JuMP.dual.(line_flow_contin_trans_r)
for i in eachindex(line_flow_contin_trans_dual_s)    #maximum value between i-j and j-i
    if line_flow_contin_trans_dual_r[i]>line_flow_contin_trans_dual_s[i]
         replace(line_flow_contin_trans_dual_s, line_flow_contin_trans_dual_s[i] =>line_flow_contin_trans_dual_r[i])
     end
 end

 line_flow_contin_dict=Dict{NTuple{3,Int64},Float64}()

for c in 1:nCont, i=1:length(idx_from_line_c[c])
    push!(line_flow_contin_dict, (c,idx_from_line_c[c][i],idx_to_line_c[c][i])=>line_flow_contin_dual_s[c,1,1,i])
end
for c in 1:nCont, i=1:nTrans
    push!(line_flow_contin_dict, (c,idx_from_trans[i],idx_to_trans[i])=>line_flow_contin_trans_dual_s[c,1,1,i])
end


#----------voltage mag and angles-------------
(v_sq,voltage_gen,volt_ang,v_sq_c,voltage_gen_c,volt_ang_c)=rect_to_polar("contin")

volt_mag_normal=Dict{NTuple{1,Int64},Float64}()
for i in 1:nBus
    push!(volt_mag_normal, (i,)=>voltage_gen[1,i])
end
volt_ang_normal=Dict{NTuple{1,Int64},Float64}()
for i in 1:nBus
    push!(volt_ang_normal, (i,)=>volt_ang[1,i])
end

volt_mag_contin=Dict{NTuple{2,Int64},Float64}()
for c in 1:nCont, i in 1:nBus
    push!(volt_mag_contin, (c,i)=>voltage_gen_c[c,1,1,i])
end
volt_ang_contin=Dict{NTuple{2,Int64},Float64}()
for  c in 1:nCont,i in 1:nBus
    push!(volt_ang_contin, (c,i)=>volt_ang_c[c,1,1,i])
end

#-------------dual values of power balance constraints----------
active_power_balance_normal_dual=JuMP.dual.(active_power_balance_normal)
active_power_balance_normal_dual=active_power_balance_normal_dual[1,:]
active_power_balance_normal_dual_dict=Dict{NTuple{1,Int64},Float64}()
for i in 1:nBus
    push!(active_power_balance_normal_dual_dict, (i,)=>active_power_balance_normal_dual[i])
end

reactive_power_balance_normal_dual=JuMP.dual.(reactive_power_balance_normal)
reactive_power_balance_normal_dual=reactive_power_balance_normal_dual[1,:]

reactive_power_balance_normal_dual_dict=Dict{NTuple{1,Int64},Float64}()
for i in 1:nBus
    push!(reactive_power_balance_normal_dual_dict, (i,)=>reactive_power_balance_normal_dual[i])
end


active_power_balance_contin_dual=JuMP.dual.(active_power_balance_contin)
active_power_balance_contin_dual=active_power_balance_contin_dual[:,1,1,:]
active_power_balance_contin_dual_dict=Dict{NTuple{2,Int64},Float64}()
for  c in 1:nCont,i in 1:nBus
    push!(active_power_balance_contin_dual_dict, (c,i)=>active_power_balance_contin_dual[c,i])
end


reactive_power_balance_contin_dual=JuMP.dual.(reactive_power_balance_contin)
reactive_power_balance_contin_dual=reactive_power_balance_contin_dual[:,1,1,:]
reactive_power_balance_contin_dual_dict=Dict{NTuple{2,Int64},Float64}()
for  c in 1:nCont,i in 1:nBus
    push!(reactive_power_balance_contin_dual_dict, (c,i)=>reactive_power_balance_contin_dual[c,i])
end


#
# flow_normal_aux_s=@expression(acopf, [s in 1:nSc, t in 1:nTP, l in 1:nLines],
# (value.(pinj_dict_sr[[s,t,idx_from_line[l],idx_to_line[l]]]))^2+(value.(qinj_dict_sr[[s,t,idx_from_line[l],idx_to_line[l]]]))^2
#   )
#
# flow_normal_s=JuMP.value.(flow_normal_aux_s).^0.5
#
#
# flow_normal_aux_r=@expression(acopf, [s in 1:nSc, t in 1:nTP, l in 1:nLines],
# (value.(pinj_dict_sr[[s,t,idx_to_line[l],idx_from_line[l]]]))^2+(value.(qinj_dict_sr[[s,t,idx_to_line[l],idx_from_line[l]]]))^2
#  )
# flow_normal_r=JuMP.value.(flow_normal_aux_r).^0.5
#
#
# flow_contin_aux_s=@expression(acopf, [c in 1:nCont, s in 1:nSc, t in 1:nTP,l in 1:length(idx_from_line_c[c]) ],
# sqrt((value.(pinj_dict_c_sr[[c,s,t,idx_from_line_c[c][l],idx_to_line_c[c][l]]]))^2+(value.(qinj_dict_c_sr[[c,s,t,idx_from_line_c[c][l],idx_to_line_c[c][l]]]))^2)
#             )
# flow_contin_s=JuMP.value.(flow_contin_aux_s)
#
# flow_contin_aux_r=@expression(acopf, [c in 1:nCont, s in 1:nSc, t in 1:nTP,l in 1:length(idx_from_line_c[c]) ],
# sqrt((value.(pinj_dict_c_sr[[c,s,t,idx_to_line_c[c][l],idx_from_line_c[c][l]]]))^2+(value.(qinj_dict_c_sr[[c,s,t,idx_to_line_c[c][l],idx_from_line_c[c][l]]]))^2)
#             )
# flow_contin_r=JuMP.value.(flow_contin_aux_r)

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

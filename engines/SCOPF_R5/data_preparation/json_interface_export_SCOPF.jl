










lines=[ones(nLines,1) for i in 1:nCont]
for i in 1:nCont
    for j in 1:nLines
        if j== list_of_contingency_lines[i][1]
            lines[i][j]=0
        end
    end
end
##---------------active line flow for each state------------
# flow_normal_dict=Dict{Int64,Float64}()
# flow_normal_dict_dual=Dict{Int64,Float64}()
#
# # flow_values_normal
# for l in 1:nLines
#     if flow_normal_s[1,1,l]>=flow_normal_r[1,1,l]
#     push!(flow_normal_dict, l=>flow_normal_s[1,1,l] )
#     push!(flow_normal_dict_dual, l=>line_flow_normal_dual_s[1,1,l] )
# elseif flow_normal_s[1,1,l]<flow_normal_r[1,1,l]
#     push!(flow_normal_dict, l=>flow_normal_r[1,1,l] )
#     push!(flow_normal_dict_dual, l=>line_flow_normal_dual_r[1,1,l] )
# end
# end
# flow_normal_final     =[flow_normal_dict[i] for i in 1:nLines]
# flow_normal_final_dual=[flow_normal_dict_dual[i] for i in 1:nLines]
#
#
#
# flow_contin_dict=Dict{Array{Int64,1},Float64}()
# flow_contin_dict_dual=Dict{Array{Int64,1},Float64}()
#
#
# for c in 1:nCont, l in 1:nLines
#  if ~isempty(idx_pll[c])
#      if flow_contin_s[c,1,1,l]>=flow_contin_r[c,1,1,l]
#      push!(flow_contin_dict, [c,l]=>value(flow_contin_s[c,1,1,l]) )
#      push!(flow_contin_dict_dual, [c,l]=>value(line_flow_contin_dual_s[c,1,1,l]) )
#      elseif flow_contin_s[c,1,1,l]<flow_contin_r[c,1,1,l]
#      push!(flow_contin_dict, [c,l]=>value(flow_contin_r[c,1,1,l]) )
#      push!(flow_contin_dict_dual, [c,l]=>value(line_flow_contin_dual_r[c,1,1,l]) )
#       end
# elseif isempty(idx_pll[c])
#     if l==list_of_contingency_lines[c][1]
#     push!(flow_contin_dict, [c,l]=>0 )
#     push!(flow_contin_dict_dual, [c,l]=>0 )
# elseif l<list_of_contingency_lines[c][1]
#     if flow_contin_s[c,1,1,l]>=flow_contin_r[c,1,1,l]
#     push!(flow_contin_dict, [c,l]=>value(flow_contin_s[c,1,1,l]) )
#     push!(flow_contin_dict_dual, [c,l]=>value(line_flow_contin_dual_s[c,1,1,l]) )
#    elseif flow_contin_s[c,1,1,l]<flow_contin_r[c,1,1,l]
#     push!(flow_contin_dict, [c,l]=>value(flow_contin_r[c,1,1,l]) )
#     push!(flow_contin_dict_dual, [c,l]=>value(line_flow_contin_dual_r[c,1,1,l]) )
#     end
# elseif  l>list_of_contingency_lines[c][1]
#     if flow_contin_s[c,1,1,l-1]>=flow_contin_r[c,1,1,l-1]
#     push!(flow_contin_dict, [c,l]=>value(flow_contin_s[c,1,1,l-1]) )
#     push!(flow_contin_dict_dual, [c,l]=>value(line_flow_contin_dual_s[c,1,1,l-1]) )
# elseif flow_contin_s[c,1,1,l-1]<flow_contin_r[c,1,1,l-1]
#     push!(flow_contin_dict, [c,l]=>value(flow_contin_r[c,1,1,l-1]) )
#     push!(flow_contin_dict_dual, [c,l]=>value(line_flow_contin_dual_r[c,1,1,l-1]) )
#     end
# end
# end
# end
# flow_contin1=[zeros(nLines,1) for c in 1:nCont]
# flow_contin1=[[flow_contin_dict[[c,l]] for l in 1:nLines] for c in 1:nCont]
# flow_contin1_dual=[zeros(nLines,1) for c in 1:nCont]
# flow_contin1_dual=[[flow_contin_dict_dual[[c,l]] for l in 1:nLines] for c in 1:nCont]

# ##---------------reactive line flow for each state------------
# reactive_flow_normal_dict=Dict{Int64,Float64}()
# # flow_values_normal
# for l in 1:nLines
#     push!(reactive_flow_normal_dict, l=>value(reactive_flow_normal[1,1,l]) )
# end
# reactive_flow_normal_final=[reactive_flow_normal_dict[i] for i in 1:nLines]
#
#
#
# reactive_flow_contin_dict=Dict{Array{Int64,1},Float64}()
#
#
# for c in 1:nCont, l in 1:nLines
#     if ~isempty(idx_pll[c])
#     push!(reactive_flow_contin_dict, [c,l]=>value(reactive_flow_contin[c,1,1,l]) )
# elseif isempty(idx_pll[c])
#     if l==list_of_contingency_lines[c][1]
#     push!(reactive_flow_contin_dict, [c,l]=>0 )
# elseif l<list_of_contingency_lines[c][1]
#     push!(reactive_flow_contin_dict, [c,l]=>value(reactive_flow_contin[c,1,1,l]) )
# elseif  l>list_of_contingency_lines[c][1]
#     push!(reactive_flow_contin_dict, [c,l]=>value(reactive_flow_contin[c,1,1,l-1]) )
# end
# end
# end
# flow_contin1_q=[zeros(nLines,1) for c in 1:nCont]
# flow_contin1_q=[[active_flow_contin_dict[[c,l]] for l in 1:nLines] for c in 1:nCont]
##-----------------line flow  dual-------------------


# active_flow_contin_dual_dict=Dict{Array{Int64,1},Float64}()
#
#
# for c in 1:nCont, l in 1:nLines
#     if ~isempty(idx_pll[c])
#     push!(active_flow_contin_dual_dict, [c,l]=>value(line_flow_contin_dual[c,1,1,l]) )
# elseif isempty(idx_pll[c])
#     if l==list_of_contingency_lines[c][1]
#     push!(active_flow_contin_dual_dict, [c,l]=>0 )
# elseif l<list_of_contingency_lines[c][1]
#     push!(active_flow_contin_dual_dict, [c,l]=>value(line_flow_contin_dual[c,1,1,l]) )
# elseif  l>list_of_contingency_lines[c][1]
#     push!(active_flow_contin_dual_dict, [c,l]=>value(line_flow_contin_dual[c,1,1,l-1]) )
# end
# end
# end
# flow_contin_active_dual=[zeros(nLines,1) for c in 1:nCont]
# flow_contin_active_dual=[[active_flow_contin_dual_dict[[c,l]] for l in 1:nLines] for c in 1:nCont]
##-------------------flexiblility at each bus------------------
flex_array_inc=[zeros(nBus,1) ]
flex_array_dec=[zeros(nBus,1) ]
for b in 1:nBus
    for i in nd_fl
        if i==b
            idx_flex=findall(x->x==i, nd_fl )
flex_array_inc[1][b]=JuMP.value.(p_fl_inc[1,idx_flex[1]])
flex_array_dec[1][b]=JuMP.value.(p_fl_dec[1,idx_flex[1]])
end
end
end
flex_array_contin_inc=[zeros(nBus,1) for c in 1:nCont]
flex_array_contin_dec=[zeros(nBus,1) for c in 1:nCont]
for c in 1:nCont, b in 1:nBus,i in nd_fl
        if i==b
            idx_flex=findall(x->x==i, nd_fl )
flex_array_contin_inc[c][b]=JuMP.value.(p_fl_inc_c[c,1,1,idx_flex[1]])
flex_array_contin_dec[c][b]=JuMP.value.(p_fl_dec_c[c,1,1,idx_flex[1]])
# end
end
end


flex_array_inc_q=[zeros(nBus,1) ]
flex_array_dec_q=[zeros(nBus,1) ]
for b in 1:nBus
    for i in nd_fl
        if i==b
            idx_flex=findall(x->x==i, nd_fl )
flex_array_inc_q[1][b]=JuMP.value.(q_fl_inc[1,idx_flex[1]])
flex_array_dec_q[1][b]=JuMP.value.(q_fl_dec[1,idx_flex[1]])
end
end
end
flex_array_contin_inc_q=[zeros(nBus,1) for c in 1:nCont]
flex_array_contin_dec_q=[zeros(nBus,1) for c in 1:nCont]
for c in 1:nCont, b in 1:nBus,i in nd_fl
        if i==b
            idx_flex=findall(x->x==i, nd_fl )
flex_array_contin_inc_q[c][b]=JuMP.value.(q_fl_inc_c[c,1,1,idx_flex[1]])
flex_array_contin_dec_q[c][b]=JuMP.value.(q_fl_dec_c[c,1,1,idx_flex[1]])
# end
end
end
##-------------------active load curtailment----------------------------------
active_load_curt=[zeros(nBus,1) ]
# flex_array_dec=[zeros(nBus,1) ]
for b in 1:nBus
    for i in bus_data_lsheet
        if i==b
            idx_lc=findall(x->x==i, bus_data_lsheet )
active_load_curt[1][b]=JuMP.value.(pen_lsh[1,idx_lc[1]])
# flex_array_dec[1][b]=JuMP.value.(p_fl_dec[1,idx_flex[1]])
end
end
end
active_load_curt_c=[zeros(nBus,1) for c in 1:nCont]
# flex_array_contin_dec=[zeros(nBus,1) for c in 1:nCont]
for c in 1:nCont, b in 1:nBus,i in bus_data_lsheet
        if i==b
            idx_lc=findall(x->x==i, bus_data_lsheet )
active_load_curt_c[c][b]=JuMP.value.(pen_lsh_c[c,1,1,idx_lc[1]])
# flex_array_contin_dec[c][b]=JuMP.value.(p_fl_dec_c[c,1,1,idx_flex[1]])
# end
end
end

##-------------------reactive load curtailment----------------------------------
reactive_load_curt=[zeros(nBus,1) ]
# flex_array_dec=[zeros(nBus,1) ]
for b in 1:nBus
    for i in bus_data_lsheet
        if i==b
            idx_lc=findall(x->x==i, bus_data_lsheet )
reactive_load_curt[1][b]=JuMP.value.(tan(acos(power_factor))*pen_lsh[1,idx_lc[1]])
# flex_array_dec[1][b]=JuMP.value.(p_fl_dec[1,idx_flex[1]])
end
end
end
reactive_load_curt_c=[zeros(nBus,1) for c in 1:nCont]
# flex_array_contin_dec=[zeros(nBus,1) for c in 1:nCont]
for c in 1:nCont, b in 1:nBus,i in bus_data_lsheet
        if i==b
            idx_lc=findall(x->x==i, bus_data_lsheet )
reactive_load_curt_c[c][b]=JuMP.value.(tan(acos(power_factor))*pen_lsh_c[c,1,1,idx_lc[1]])
# flex_array_contin_dec[c][b]=JuMP.value.(p_fl_dec_c[c,1,1,idx_flex[1]])
# end
end
end
##-------------------Generation output- (active)---------------------------------
pgen=[zeros(nBus,1) ]
pgen_neg=[zeros(nBus,1) ]
# flex_array_dec=[zeros(nBus,1) ]
for b in 1:nBus
    for i in bus_data_gsheet
        if i==b
            idx_pg=findall(x->x==i, bus_data_gsheet )
pgen[1][b]=JuMP.value.(Pg[1,idx_pg[1]])
# flex_array_dec[1][b]=JuMP.value.(p_fl_dec[1,idx_flex[1]])
end
end
if haskey(new_data, "negGen")
for i in neg_gen_bus
    if i==b
        idx_pg_neg=findall(x->x==i, neg_gen_bus )
pgen_neg[1][b]=JuMP.value.(Pg_neg[1,idx_pg_neg[1]])
# flex_array_dec[1][b]=JuMP.value.(p_fl_dec[1,idx_flex[1]])
end
end
end
end
pgen_c=[zeros(nBus,1) for c in 1:nCont]
pgen_neg_c=[zeros(nBus,1) for c in 1:nCont]
# flex_array_contin_dec=[zeros(nBus,1) for c in 1:nCont]
for c in 1:nCont, b in 1:nBus,i in bus_data_gsheet
        if i==b
            idx_pg=findall(x->x==i, bus_data_gsheet )
pgen_c[c][b]=JuMP.value.(Pg_c[c,1,1,idx_pg[1]])
# flex_array_contin_dec[c][b]=JuMP.value.(p_fl_dec_c[c,1,1,idx_flex[1]])
# end
end
end
if haskey(new_data, "negGen")
for c in 1:nCont, b in 1:nBus,i in neg_gen_bus
        if i==b
            idx_pg_neg=findall(x->x==i, neg_gen_bus )
pgen_neg_c[c][b]=JuMP.value.(Pg_neg_c[c,1,1,idx_pg_neg[1]])
# flex_array_contin_dec[c][b]=JuMP.value.(p_fl_dec_c[c,1,1,idx_flex[1]])
# end
end
end
end
##-------------------Generation output- (reactive)---------------------------------
qgen=[zeros(nBus,1) ]
qgen_neg=[zeros(nBus,1) ]
# flex_array_dec=[zeros(nBus,1) ]
for b in 1:nBus
    for i in bus_data_gsheet
        if i==b
            idx_qg=findall(x->x==i, bus_data_gsheet )
qgen[1][b]=JuMP.value.(Qg[1,idx_qg[1]])
# flex_array_dec[1][b]=JuMP.value.(p_fl_dec[1,idx_flex[1]])
end
end
if haskey(new_data, "negGen")
for i in neg_gen_bus
    if i==b
        idx_qg_neg=findall(x->x==i, neg_gen_bus )
qgen_neg[1][b]=JuMP.value.(Qg_neg[1,idx_qg_neg[1]])
# flex_array_dec[1][b]=JuMP.value.(p_fl_dec[1,idx_flex[1]])
end
end
end
end
qgen_c=[zeros(nBus,1) for c in 1:nCont]
qgen_neg_c=[zeros(nBus,1) for c in 1:nCont]
# flex_array_contin_dec=[zeros(nBus,1) for c in 1:nCont]
for c in 1:nCont, b in 1:nBus,i in bus_data_gsheet
        if i==b
            idx_qg=findall(x->x==i, bus_data_gsheet )
qgen_c[c][b]=JuMP.value.(Qg_c[c,1,1,idx_qg[1]])
# flex_array_contin_dec[c][b]=JuMP.value.(p_fl_dec_c[c,1,1,idx_flex[1]])
# end
end
end
if haskey(new_data, "negGen")
for c in 1:nCont, b in 1:nBus,i in neg_gen_bus
        if i==b
            idx_qg_neg=findall(x->x==i, neg_gen_bus )
qgen_neg_c[c][b]=JuMP.value.(Qg_neg_c[c,1,1,idx_qg_neg[1]])
# flex_array_contin_dec[c][b]=JuMP.value.(p_fl_dec_c[c,1,1,idx_flex[1]])
# end
end
end
end
# include("old_dual.jl")

# active_power_balance_contin_dual = [active_power_balance_contin_dual[r,:] for r in 1:size(active_power_balance_contin_dual,1)]
# reactive_power_balance_contin_dual = [reactive_power_balance_contin_dual[r,:] for r in 1:size(reactive_power_balance_contin_dual,1)]
if cost_fl==nothing
    cost_fl=0
end
if cost_fl_c==nothing
    cost_fl_c=0
end
if cost_pen_lsh==nothing
    cost_pen_lsh=0
end
if cost_pen_lsh_c==nothing
    cost_pen_lsh_c=0
end
if cost_pen_ws==nothing
    cost_pen_ws=0
end
if cost_pen_ws_c==nothing
    cost_pen_ws_c=0
end


costs=[JuMP.value.(cost_gen),JuMP.value.(cost_fl)[1],JuMP.value.(cost_fl_c)[1],JuMP.value.(cost_pen_lsh)[1],JuMP.value.(cost_pen_lsh_c)[1],JuMP.value.(cost_pen_ws)[1],JuMP.value.(cost_pen_ws_c)[1] ]

# costs=[JuMP.value.(cost_gen),
#        [JuMP.value.(cost_fl)[1] ; cost_fl!=nothing],
#        [JuMP.value.(cost_fl_c)[1] ; cost_fl_c!=nothing],
#        [JuMP.value.(cost_pen_lsh)[1] ; cost_pen_lsh!=nothing],
#        [JuMP.value.(cost_pen_lsh_c)[1] ; cost_pen_lsh_c!=nothing],
#        [JuMP.value.(cost_pen_ws)[1] ; cost_pen_ws!=nothing],
#        [JuMP.value.(cost_pen_ws_c; cost_pen_ws_c!=nothing)[1] ]
#         ]
#
# # load_curtailment_n=[JuMP.value.(pen_lsh[1,:])]
# # load_curtailment_c=[JuMP.value.(pen_lsh_c[:,1,1,:])]
# s="{ \"cont_list\" : $lines,
#       # \"OPF_bra\" : $flow_normal_final,
#       # \"OPF_bra_con\" : $flow_contin1,
#       # \"OPF_Pbal\" :$active_power_balance_normal_dual,
#       # \"OPF_Pbal_con\" :$active_power_balance_contin_dual,
#       # \"OPF_Qbal\" :$reactive_power_balance_normal_dual,
#       # \"OPF_Qbal_con\" : $reactive_power_balance_contin_dual,
#       # \"dual_bra\":$flow_normal_final_dual,
#       # \"dual_bra_con\":$flow_contin1_dual,
#       # \"OPF_cost\" :$costs,
#        \"plc_result\" :$active_load_curt,
#        \"plc_result_con\" :$active_load_curt_c,
#        \"qlc_result\" :$reactive_load_curt,
#        \"qlc_result_con\" :$reactive_load_curt_c,
#        \"OPF_Pflex_inc\" :$flex_array_inc,
#        \"OPF_Pflex_inc_con\" :$flex_array_contin_inc,
#        \"OPF_Pflex_dec\" :$flex_array_dec,
#       \"OPF_Pflex_dec_con\" : $flex_array_contin_dec,
#        \"OPF_Qflex_inc\" :$flex_array_inc_q,
#        \"OPF_Qflex_inc_con\" :$flex_array_contin_inc_q,
#        \"OPF_Qflex_dec\" :$flex_array_dec_q,
#        \"OPF_Qflex_dec_con\" :$flex_array_contin_dec_q,
#        \"OPF_Pgen\" :$pgen,
#        \"OPF_Pgen_con\" :$pgen_c,
#        \"OPF_Qgen\":$qgen,
#        \"OPF_Qgen_con\" :$qgen_c,
#        \"OPF_Pgen_neg\":$pgen_neg,
#        \"OPF_Pgen_neg_con\":$pgen_neg_c,
#        \"OPF_Qgen_neg\" :$qgen_neg,
#        \"OPF_Qgen_neg_con\" :$qgen_neg_c
#
#       } "
#
#
# s = replace(s, ";" => ",") # activate this for correct JSON export
#
# #Please note that parallel lines are merged initially,
# io = open("export_WP3.json", "a");
# # io = open("export_WP3.m", "a");
# write(io, s)
# close(io)
##

#
# s=Dict(:OPF_bra_active_normal => active_line_flow_normal,
#        :OPF_bra_reactive_normal => reactive_line_flow_normal,
#        :OPF_bra_active_contin => active_line_flow_contin,
#        :OPF_bra_reactive_contin => reactive_line_flow_contin,
#        :OPF_thermal_limit_max_dual_normal=>line_flow_normal_dict,
#        :OPF_thermal_limit_max_dual_contin=>line_flow_contin_dict,
#        :OPF_volt_mag_normal=>volt_mag_normal,
#        :OPF_volt_ang_normal=>volt_ang_normal,
#        :OPF_volt_mag_contin=>volt_mag_contin,
#        :OPF_volt_ang_contin=>volt_ang_contin,
#        :active_power_balance_normal_dual=>active_power_balance_normal_dual_dict,
#        :reactive_power_balance_normal_dual=>reactive_power_balance_normal_dual_dict,
#        :active_power_balance_contin_dual=>active_power_balance_contin_dual_dict,
#        :reactive_power_balance_contin_dual=>reactive_power_balance_contin_dual_dict,
#        :cont_list=>lines,
#        :OPF_cost=> costs,
#        :plc_result=> active_load_curt,
#        :plc_result_con=>active_load_curt_c,
#        :qlc_result=>reactive_load_curt,
#        :qlc_result_con=>reactive_load_curt_c,
#        :OPF_Pflex_inc=>flex_array_inc,
#        :OPF_Pflex_inc_con=>flex_array_contin_inc,
#        :OPF_Pflex_dec=>flex_array_dec,
#        :OPF_Pflex_dec_con=>flex_array_contin_dec,
#        :OPF_Qflex_inc=>flex_array_inc_q,
#        :OPF_Qflex_inc_con=>flex_array_contin_inc_q,
#        :OPF_Qflex_dec=>flex_array_dec_q,
#        :OPF_Qflex_dec_con=>flex_array_contin_dec_q,
#        :OPF_Pgen=>pgen,
#        :OPF_Pgen_con=>pgen_c,
#        :OPF_Qgen=>qgen,
#        :OPF_Qgen_con=>qgen_c,
#        :OPF_Pgen_neg=>pgen_neg,
#        :OPF_Pgen_neg_con=>pgen_neg_c,
#        :OPF_Qgen_neg=>qgen_neg,
#        :OPF_Qgen_neg_con=>qgen_neg_c
#        )

##

s=Dict(:OPF_bra_active_normal => active_line_flow_normal,
       :OPF_bra_reactive_normal => reactive_line_flow_normal,
       :OPF_bra_active_contin => active_line_flow_contin,
       :OPF_bra_reactive_contin => reactive_line_flow_contin,
       :OPF_thermal_limit_max_dual_normal=>line_flow_normal_dict,
       :OPF_thermal_limit_max_dual_contin=>line_flow_contin_dict,
       :active_power_balance_normal_dual=>active_power_balance_normal_dual_dict,
       :reactive_power_balance_normal_dual=>reactive_power_balance_normal_dual_dict,
       :active_power_balance_contin_dual=>active_power_balance_contin_dual_dict,
       :reactive_power_balance_contin_dual=>reactive_power_balance_contin_dual_dict,
       :cont_list=>lines,
       :OPF_cost=> costs,
       :plc_result=> active_load_curt,
       :plc_result_con=>active_load_curt_c,
       :qlc_result=>reactive_load_curt,
       :qlc_result_con=>reactive_load_curt_c,
       :OPF_Pflex_inc=>flex_array_inc,
       :OPF_Pflex_inc_con=>flex_array_contin_inc,
       :OPF_Pflex_dec=>flex_array_dec,
       :OPF_Pflex_dec_con=>flex_array_contin_dec,
       :OPF_Qflex_inc=>flex_array_inc_q,
       :OPF_Qflex_inc_con=>flex_array_contin_inc_q,
       :OPF_Qflex_dec=>flex_array_dec_q,
       :OPF_Qflex_dec_con=>flex_array_contin_dec_q,
       :OPF_Pgen=>pgen,
       :OPF_Pgen_con=>pgen_c,
       :OPF_Qgen=>qgen,
       :OPF_Qgen_con=>qgen_c,
       :OPF_volt_mag_contin=>volt_mag_contin,
       :OPF_volt_ang_contin=>volt_ang_contin,
       )
 stringdata = JSON.json(s)
#Please note that parallel lines are merged initially,
# io = open("export_WP3.json", "a");
 open("data_preparation\\export_WP3.json", "a") do f
write(f, stringdata)
end



# # retrieve the values from dictionaries
# new_data = Dict()
# open("data_preparation\\export_WP3.json", "r") do g
#         global new_data
#     new_data=JSON.parse(g)
#
# end
# #
# contin= 12
# from_line=1
# to_line=96
# new_data["OPF_bra_active_contin"]["($contin, $from_line, $to_line)"]

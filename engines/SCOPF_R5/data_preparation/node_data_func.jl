
(idx_from_line,idx_to_line,yij_line,yij_line_sh,idx_from_trans,idx_to_trans,yij_trans,yij_trans_sh,tap_ratio,tap_ratio_min,tap_ratio_max)=f_line_data(array_lines,nw_trans)
(idx_from_line_c,idx_to_line_c,yij_line_c,yij_line_sh_c,line_smax_c)=f_lines_data_contin(data_for_each_contingency)

node_data=f_node_data(nBus,idx_from_line,idx_to_line,nw_lines,yij_line,yij_line_sh)
node_data_trans=f_node_data_trans(nBus,nw_buses,idx_from_trans,idx_to_trans,yij_trans,yij_trans_sh,tap_ratio,tap_ratio_min,tap_ratio_max)
node_data_new=f_node_data_new(nBus,idx_from_line,idx_to_line,nw_lines,yij_line,yij_line_sh,nw_buses,idx_from_trans,idx_to_trans,yij_trans,yij_trans_sh,tap_ratio,tap_ratio_min,tap_ratio_max)
node_data_contin=f_node_data_contin(nCont,nBus,nw_buses,idx_from_line_c,idx_to_line_c,yij_line_c,yij_line_sh_c,line_smax_c)

(bus_data_lsheet,cost_flex_load,idx_St_lsheet,iFl,nFl,nd_fl,nd_fl_bus)=load_data(nLoads,nw_loads,rheader_loads)
(Pg_max,Pg_min,Qg_max,Qg_min,cA_gen,cB_gen,cC_gen,bus_data_gsheet,pg_max,pg_min,qg_max,qg_min,cost_a_gen,cost_b_gen,cost_c_gen)=gen_data(nGens,nTP,nw_gens)# include("load_data_mpopf.jl")
(idx_St_Strsheet,iStr_active,nStr_active,nd_Str_active,bus_data_Ssheet,cost_a_str,cost_b_str,cost_c_str)=storage_data(rheader_storage,nTP,nw_storage)
from_to_map_t=trans_map_t(nBus,node_data_trans)

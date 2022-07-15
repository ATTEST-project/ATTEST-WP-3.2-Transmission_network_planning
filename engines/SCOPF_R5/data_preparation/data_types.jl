# Data Types
#---------------------------Structure for Bus-----------------------------------
mutable struct Bus
    bus_num::Int64
    bus_type::Int64         # 1. PQ; 2. PV; 3. Slack/Ref
    bus_area::Int64
    bus_vnom::Float64       # base kV (value is given in kV)
    bus_vmax::Float64       # pu
    bus_vmin::Float64       # pu
    bus_v_init_re::Float64
    bus_v_init_im::Float64
end
#---------------------------Structure for Lines-----------------------------------
mutable struct Line
    line_from::Int64         # from bus
    line_to::Int64           # to bus
    line_g::Float64          # pu
    line_b::Float64          # pu
    line_g_shunt::Float64    # pu
    line_b_shunt::Float64    # pu
    line_Smax_A::Float64     # Long terms line rating given in MVA
    line_br_status::Int64    # Branch Status
end
#---------------------------Structure for Generator-----------------------------------
mutable struct Gens
    gen_bus_num::Int64
    gen_Pg_avl::Float64      # real power output (MW)
    gen_Qg_avl::Float64      # reactive power output  (MVAr)
    gen_Qg_max::Float64      # maximum reactive power output  (MVAr)
    gen_Qg_min::Float64      # minimum reactive power output  (MVAr)
    gen_V_set::Float64       # voltage magnitude set point; this value is used only if opf.use_vg option in non-zero. Otherwise, the voltage value is determined by the voltage limits set for the corresponding bus
    gen_P_max::Float64       # maximum active power output  (MW)
    gen_P_min::Float64       # minimum reactive power output  (MW)
    gcost_a::Float64
    gcost_b::Float64
    gcost_c::Float64
end

#---------------------------- Structure for Loads------------------------------
mutable struct Loads
    load_bus_num::Int64
    load_P::Float64
    load_Q::Float64
    load_ShFr::Float64      # Shunt conductance of capacitve devices
    load_ShFrMin::Float64      # Shunt susceptance of capactive devices
    load_ShFrMax::Float64
    load_ShFrOK::Float64
    load_ShCost::Float64
end

#------------Structure for Transformers--------------
mutable struct Transf
    trans_bus_from::Int64
    trans_bus_to::Int64
    trans_g::Float64
    trans_b::Float64
    trans_bsh::Float64
    trans_ratio::Float64
    trans_rmin::Float64
    trans_rmax::Float64
    trans_Snom::Float64
    trans_BStatus0::Float64
end
#---- Structure for saving all the relevant inforamtion related to a node ------
mutable struct node
    node_num::Array{Int64,1}
    node_cnode::Array{Int64,1}
    node_iline::Array{Int64,1}
    node_gij_sh::Array{Float64,1}
    node_gij_sr::Array{Float64,1}
    node_bij_sh::Array{Float64,1}
    node_bij_sr::Array{Float64,1}
    node_smax::Array{Float64,1}
    node_parallel::Array{Float64,1}
    # node_trtio_min::Array{Float64,1}
    # node_tratio_max::Array{Float64,1}
    # node_tap_ratio::Array{Float64,1}
    # node_tap_ratio_min::Array{Float64,1}
    # node_tap_ratio_max::Array{Float64,1}
    # node_from::Array{Int64,1}
    # node_to::Array{Int64,1}
    # node_idx_trsf::Array{Int64,1}
end
mutable struct node_t
    node_num::Array{Int64,1}
    node_cnode::Array{Int64,1}
    node_iline::Array{Int64,1}
    node_gij_sh::Array{Float64,1}
    node_gij_sr::Array{Float64,1}
    node_bij_sh::Array{Float64,1}
    node_bij_sr::Array{Float64,1}
    node_tratio::Array{Float64,1}
    node_tratio_min::Array{Float64,1}
    node_tratio_max::Array{Float64,1}
    # node_tap_ratio::Array{Float64,1}
    # node_tap_ratio_min::Array{Float64,1}
    # node_tap_ratio_max::Array{Float64,1}
    # node_from::Array{Int64,1}
    # node_to::Array{Int64,1}
    # node_idx_trsf::Array{Int64,1}
end

# #---------------- Structure for saving Generator Cost --------------------------
# mutable struct gen_cost
#     gcost_bus::Int64
#     gcost_a::Float64
#     gcost_b::Float64
#     gcost_c::Float64
# end
# #---------------- Structure for saving Storage Cost --------------------------
# mutable struct str_cost
#     str_cost_bus::Int64
#     str_cost_a::Float64
#     str_cost_b::Float64
#     str_cost_c::Float64
# end
#------------ Structure for saving the active power load profiles --------------
mutable struct profile_P
    prfP_bus::Int64
    prfP_t1::Float64
    # prfP_t2::Float64
    # prfP_t3::Float64
    # prfP_t4::Float64
    # prfP_t5::Float64
    # prfP_t6::Float64
    # prfP_t7::Float64
    # prfP_t8::Float64
    # prfP_t9::Float64
    # prfP_t10::Float64
    # prfP_t11::Float64
    # prfP_t12::Float64
    # prfP_t13::Float64
    # prfP_t14::Float64
    # prfP_t15::Float64
    # prfP_t16::Float64
    # prfP_t17::Float64
    # prfP_t18::Float64
    # prfP_t19::Float64
    # prfP_t20::Float64
    # prfP_t21::Float64
    # prfP_t22::Float64
    # prfP_t23::Float64
    # prfP_t24::Float64
end
#------------ Structure for saving the reactive power load profiles ------------
mutable struct profile_Q
    prfQ_bus::Int64
    prfQ_t1::Float64
    # prfQ_t2::Float64
    # prfQ_t3::Float64
    # prfQ_t4::Float64
    # prfQ_t5::Float64
    # prfQ_t6::Float64
    # prfQ_t7::Float64
    # prfQ_t8::Float64
    # prfQ_t9::Float64
    # prfQ_t10::Float64
    # prfQ_t11::Float64
    # prfQ_t12::Float64
    # prfQ_t13::Float64
    # prfQ_t14::Float64
    # prfQ_t15::Float64
    # prfQ_t16::Float64
    # prfQ_t17::Float64
    # prfQ_t18::Float64
    # prfQ_t19::Float64
    # prfQ_t20::Float64
    # prfQ_t21::Float64
    # prfQ_t22::Float64
    # prfQ_t23::Float64
    # prfQ_t24::Float64
end
#-------------- Structure for saving the shunts--------------
mutable struct shunts
   shunt_bus::Int64
   shunt_bsh0::Float64
   shunt_bshmin::Float64
   shunt_bshmax::Float64
end
#--------------- Structure for saving the storage model ------------------------
mutable struct energy_storage
    storage_bus::Int64
    storage_Ps::Float64
    storage_Qs::Float64
    storage_e_init::Float64
    storage_e_rat::Float64
    storage_ch_rat::Float64
    storage_dis_rat::Float64
    storage_ch_eff::Float64
    storage_dis_eff::Float64
    storage_th_rat::Float64
    storage_q_min::Float64
    storage_q_max::Float64
    storage_r::Float64
    storage_x::Float64
    storage_p_loss::Float64
    storage_q_loss::Float64
    storage_status::Float64
    storage_soc_initial::Float64
    storage_soc_min::Float64
    storage_soc_max::Float64
    storage_e_rat_min::Float64
    storage_e_initial::Float64
    storage_cost_a::Float64
    storage_cost_b::Float64
    storage_cost_c::Float64
end

#------------------ Structure for saving the base MVA --------------------------
mutable struct base_mva
    sbase::Float64
end




#-------------------------------------------------------------------------------

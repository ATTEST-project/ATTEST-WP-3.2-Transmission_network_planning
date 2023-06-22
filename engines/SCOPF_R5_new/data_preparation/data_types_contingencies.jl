#----------------- Structure for saving the contingency infos------
mutable struct contingencies
    contin_num::Int64
    from_contin::Int64
    to_contin::Int64
end
mutable struct node_c
    node_num_c::Array{Int64,1}
    node_cnode_c::Array{Int64,1}
    node_iline_c::Array{Int64,1}
    node_gij_sh_c::Array{Float64,1}
    node_gij_sr_c::Array{Float64,1}
    node_bij_sh_c::Array{Float64,1}
    node_bij_sr_c::Array{Float64,1}
    node_smax_c::Array{Float64,1}
    # node_tap_ratio_c::Array{Float64,1}
    # node_tap_ratio_min_c::Array{Float64,1}
    # node_tap_ratio_max_c::Array{Float64,1}
    # node_from_c::Array{Int64,1}
    # node_to_c::Array{Int64,1}
    # node_idx_trsf_c::Array{Int64,1}
end
mutable struct Line_contin
    line_from_c::Int64         # from bus
    line_to_c::Int64           # to bus
    line_g_c::Float64          # pu
    line_b_c::Float64          # pu
    line_g_shunt_c::Float64    # pu
    line_b_shunt_c::Float64    # pu
    line_Smax_A_c::Float64     # Long terms line rating given in MVA
    line_br_status_c::Int64    # Branch Status
end

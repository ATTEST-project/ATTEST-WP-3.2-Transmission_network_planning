acopf = Model(Ipopt.Optimizer)
# set_optimizer_attributes(acopf,"mu_strategy"=>"adaptive")
set_optimizer_attributes(acopf,"tol"=>1e-05)
set_optimizer_attributes(acopf,"mumps_mem_percent"=>100)
# set_optimizer_attributes(acopf,"barrier_tol_factor"=>1e-6)
# @variables(
#     acopf,
#     begin
#
#         # Pg[i=1:nSc, j=1:nTP,k=1:nGens]
#         # Qg[i=1:nSc, j=1:nTP,k=1:nGens]
#
#         # nGens and nCurt_gen now forms the complete nGens
#         # Pg[i = 1:nSc, j = 1:nTP, k = 1:nGens]
#         # Qg[i = 1:nSc, j = 1:nTP, k = 1:nGens]
#         # Pg_curt[i = 1:nSc, j = 1:nTP, k = 1:nCurt_gen]
#         # tratio should be a variable!!!!!!!!!!!!!!!
#
#         # tratio[i = 1:nSc, j = 1:nTP, k = 1:nBus]
#         #   shnt[i = 1:nSc, j = 1:nTP, k = 1:nBus]
#
#
#       # Pg[i = 1:nSc, j = 1:nTP, k = 1:nGens]
#       # Qg[i = 1:nSc, j = 1:nTP, k = 1:nGens]
#
#
#         #----post contingency variables--V P Q--and curtailable-------
#       #   e_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nBus]#,(start = 1.00)                                  # This procedure can be used to set the start values of all variables
#       #   f_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nBus]
#       #   delta_v[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nBus]
#       #
#       #   # nGens and nCurt_gen now forms the complete nGens
#       #   Pg_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nGens]
#       #   Qg_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nGens]
#       #   # Pg_curt_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nCurt_gen]
#       #   s[c = 1:nCont, i = 1:nSc,j = 1:nTP]
#       #   #----
#       # diff[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nGens]
#       #   # tratio[i=1:nSc, j=1:nTP,k=1:nTrsf]
#         #--------------- Variables for Energy Storage Model ------------------------
#         # p_ch[i = 1:nSc, j = 1:nTP, k = 1:nStr_active]
#         # p_dis[i = 1:nSc, j = 1:nTP, k = 1:nStr_active]
#         # soc[i = 1:nSc, j = 1:nTP, k = 1:nStr_active]
#         # p_strg[i = 1:nSc, j = 1:nTP, k = 1:nStr_active]
#
#         # bin_ch[i=1:nSc,j=1:nTP,k=1:nStr_active],Bin                                 # Use these variables for mixed-integer model of a battery
#         # bin_dis[i=1:nSc,j=1:nTP,k=1:nStr_active],Bin                                # Use these variables for mixed-integer model of a battery
#
#         #---------------- Variables for Felxible Loads ----------------------------
#         # p_fl_inc[i = 1:nSc, j = 1:nTP, k = 1:nFl]
#         # p_fl_dec[i = 1:nSc, j = 1:nTP, k = 1:nFl]
#         # p_fl_free[i = 1:nSc, j = 1:nTP, k = 1:nFl]
#
#         #-----post contingency variables ---storage and flexible load----------
#
#         # p_ch_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nStr_active]
#         # p_dis_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nStr_active]
#         # soc_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nStr_active]
#         # p_strg_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nStr_active]
#         #
#         # p_fl_inc_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nFl]
#         # p_fl_dec_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nFl]
#
#         # q_fl_inc[i=1:nSc,j=1:nTP,k=1:nFl]                                          # Variables for controlling the reactive power of a load (not used in the code!)
#         # q_fl_dec[i=1:nSc,j=1:nTP,k=1:nFl]
#     end
# )
@variable(acopf, e[i = 1:nSc, j = 1:nTP, k = 1:nBus], start=0.9)#,(start = 1.00)                                  # This procedure can be used to set the start values of all variables
@variable(acopf, f[i = 1:nSc, j = 1:nTP, k = 1:nBus], start=0.0)
@variable(acopf, pen_ws[i = 1:nSc, j = 1:nTP, k = 1:nRES], start=0.5*prof_PRES[i,j,k],lower_bound=0.0, upper_bound=prof_PRES[i,j,k])
@variable(acopf, pen_lsh[i = 1:nSc, j = 1:nTP, k = 1:nLoads], start=0.5*prof_ploads[k,j],lower_bound=0.0, upper_bound=prof_ploads[k,j])
@variable(acopf, Pg[i = 1:nSc, j = 1:nTP, k = 1:nGens], start=nw_gens[k].gen_Pg_avl)
@variable(acopf, Qg[i = 1:nSc, j = 1:nTP, k = 1:nGens], start=nw_gens[k].gen_Qg_avl,lower_bound=qg_min[k],upper_bound=qg_max[k])
# @variable(acopf, p_ch[i = 1:nSc, j = 1:nTP, k = 1:nStr_active], start=0.5*array_storage[k].storage_ch_rat/sbase,lower_bound=0.0,upper_bound=array_storage[k].storage_ch_rat/sbase)
# @variable(acopf, p_dis[i = 1:nSc, j = 1:nTP, k = 1:nStr_active], start=0.5*array_storage[k].storage_dis_rat/sbase,lower_bound=0.0,upper_bound=array_storage[k].storage_dis_rat/sbase)
# @variable(acopf, soc[i = 1:nSc, j = 1:nTP, k = 1:nStr_active], start=0.5*array_storage[k].storage_e_rat/sbase,lower_bound=array_storage[k].storage_e_rat_min/sbase, upper_bound=array_storage[k].storage_e_rat/sbase)
# @variable(acopf, p_fl_inc[i = 1:nSc, j = 1:nTP, k = 1:nFl], start=0.5*load_inc_prct*prof_ploads[k,j],lower_bound=0.0, upper_bound=load_inc_prct*prof_ploads[nd_fl[k],j])
# @variable(acopf, p_fl_dec[i = 1:nSc, j = 1:nTP, k = 1:nFl], start=0.5*load_dec_prct*prof_ploads[k,j],lower_bound=0.0, upper_bound=load_dec_prct*prof_ploads[nd_fl[k],j])
# @variable(acopf, q_fl_inc[i = 1:nSc, j = 1:nTP, k = 1:nFl], start=0.5*load_inc_prct*prof_qloads[k,j],lower_bound=0.0, upper_bound=load_inc_prct_q*prof_qloads[nd_fl[k],j])
# @variable(acopf, q_fl_dec[i = 1:nSc, j = 1:nTP, k = 1:nFl], start=0.5*load_dec_prct*prof_ploads[k,j],lower_bound=0.0, upper_bound=load_dec_prct_q*prof_qloads[nd_fl[k],j])
@variable(acopf, p_fl_inc[i = 1:nSc, j = 1:nTP, k = 1:nFl],lower_bound=0.0, upper_bound=upper_flex_p_inc[k])
@variable(acopf, p_fl_dec[i = 1:nSc, j = 1:nTP, k = 1:nFl],lower_bound=0.0, upper_bound=upper_flex_p_dec[k])
@variable(acopf, q_fl_inc[i = 1:nSc, j = 1:nTP, k = 1:nFl],lower_bound=0.0, upper_bound=upper_flex_q_inc[k])
@variable(acopf, q_fl_dec[i = 1:nSc, j = 1:nTP, k = 1:nFl],lower_bound=0.0, upper_bound=upper_flex_q_dec[k])
if  haskey(new_data, "negGen")
    @variable(acopf, Pg_neg[i = 1:nSc, j = 1:nTP, k = 1:size(new_data["negGen"],1)], lower_bound=new_data["negGen"][k][4]/new_data["negGen"][k][2], upper_bound=new_data["negGen"][k][3]/new_data["negGen"][k][2])
    @variable(acopf, Qg_neg[i = 1:nSc, j = 1:nTP, k = 1:size(new_data["negGen"],1)], lower_bound=new_data["negGen"][k][6]/new_data["negGen"][k][2], upper_bound=new_data["negGen"][k][5]/new_data["negGen"][k][2])

end

obj_exp = Dict()                                                                 # Use to save the expression of objective

con_exp = Dict{Symbol,Any}(:pb_p=>Dict{String,Any}(),:pb_q=>Dict{String,Any}(),:vol => Dict{String,Any}(),:Icrnt=>Dict{String,Any}(),:S_from=>Dict{String,Any}(),:S_to=>Dict{String,Any}(),:pft=>Dict{String,Any}(),:qft=>Dict{String,Any}(),:ptf=>Dict{String,Any}(),:qtf=>Dict{String,Any}())    # pb = power balance, vol = voltage, Icrnt = Longitudnal current


# @variables(
#     acopf,
#     begin
#
#
#         #----post contingency slack variables---------
#         #  this is for active load shedding
#         # pen_lsh_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nBus]
#         # pen_ws_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nRES]
#         # pen_flx_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nFl]
#         # p_fl_free_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nFl]
#         pen_lsh[i = 1:nSc, j = 1:nTP, k = 1:nBus]
#         # pen_ws[i = 1:nSc, j = 1:nTP, k = 1:nRES]
#         # This is for active variable generation shedding
#         # Dn[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nBus]
#     end
# )

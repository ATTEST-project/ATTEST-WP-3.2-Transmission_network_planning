
v_sq  =JuMP.value.(e[:,:,:]).^2+JuMP.value.(f[:,:,:]).^2
v_sq_c=JuMP.value.(e_c[:,:,:,:]).^2+JuMP.value.(f_c[:,:,:,:]).^2

shunt_expression=@expression(acopf,[s=1:nSc,t=1:nTP,i=1:nBus;~isempty(findall(x->x==i,rdata_shunts[:,1]))],
nw_shunts[findall(x->x==i,rdata_shunts[:,1])[1]].shunt_bsh0*(v_sq[s,t,i])
 )
# shunt_value=[JuMP.value.(shunt_expression[i]) for i in eachindex(JuMP.value.(shunt_expression)) ]
shunt_value=[JuMP.value.(shunt_expression[s,t,i]) for s=1:nSc,t=1:nTP, i in rdata_shunts[:,1]]


shunt_expression_c=@expression(acopf,[c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus;~isempty(findall(x->x==i,rdata_shunts[:,1]))],
nw_shunts[findall(x->x==i,rdata_shunts[:,1])[1]].shunt_bsh0*(v_sq_c[c,s,t,i])
 )
# shunt_value=[JuMP.value.(shunt_expression[i]) for i in eachindex(JuMP.value.(shunt_expression)) ]
shunt_value_c=[JuMP.value.(shunt_expression_c[c,s,t,i]) for c=1:nCont,s=1:nSc,t=1:nTP, i in rdata_shunts[:,1]]


# v_sq  =JuMP.value.(e [:,:,:]).^2+JuMP.value.(f[:,:,:]).^2
# v_sq_c=JuMP.value.(e_c[:,:,:,:]).^2+JuMP.value.(f_c[:,:,:,:]).^2

save("Stoc_MP_SCOPF_CPLEX_PF.jld"
, "Pg",JuMP.value.(Pg[:,:,:])
, "Pg_c",JuMP.value.(Pg_c[:,:,:,:])
, "Qg",JuMP.value.(Qg[:,:,:])
, "Qg_c",JuMP.value.(Qg_c[:,:,:,:])
, "shunt",shunt_value[:,:,:]
, "shunt_c",shunt_value_c[:,:,:,:]
, "RES"  ,prof_PRES
# , "e_c",JuMP.value.(e_c[:,:,:,:])
# , "f_c",JuMP.value.(f_c[:,:,:,:])
, "v_sq", v_sq
 , "v_sq_c",v_sq_c
# ,"teta",JuMP.value.(teta[:,:,:])
# ,"teta_c",JuMP.value.(teta_c[:,:,:,:])
# , "f",JuMP.value.(f[:,:,:])
# ,"volt_mag",(JuMP.value.(e[:,:,:]).^2+JuMP.value.(f[:,:,:]).^2).^0.5
# ,"volt_mag_c",(JuMP.value.(e_c[:,:,:,:]).^2+JuMP.value.(f_c[:,:,:,:]).^2).^0.5
# ,"longit_currnt",[JuMP.value.(longitud[i]) for i in indexf]
# ,"longit_currnt_c",[JuMP.value.(longitud_c[i]) for i in indexfinder]
, "pen_ws",JuMP.value.(pen_ws[:,:,:])
, "pen_lsh",JuMP.value.(pen_lsh[:,:,:])
, "pen_ws_c",JuMP.value.(pen_ws_c[:,:,:,:])
, "pen_lsh_c",JuMP.value.(pen_lsh_c[:,:,:,:])
# , "p_fl_inc",JuMP.value.(p_fl_inc[:,:,:])
# , "p_fl_dec",JuMP.value.(p_fl_dec[:,:,:])
# , "p_fl_inc_c",JuMP.value.(p_fl_inc_c[:,:,:,:])
# , "p_fl_dec_c",JuMP.value.(p_fl_dec_c[:,:,:,:])
# , "p_ch",JuMP.value.(p_ch[:,:,:])
# , "p_dis",JuMP.value.(p_dis[:,:,:])
# , "p_ch_c",JuMP.value.(p_ch_c[:,:,:,:])
# , "p_dis_c",JuMP.value.(p_dis_c[:,:,:,:])
,"cost_gen", JuMP.value.(cost_gen)
,"cost_lsh",JuMP.value.(cost_pen_lsh)
,"cost_lsh_c",JuMP.value.(cost_pen_lsh_c)
,"cost_ws",JuMP.value.(cost_pen_ws)
,"cost_ws_c",JuMP.value.(cost_pen_ws_c)
# ,"cost_fl",JuMP.value.(cost_fl)
# ,"cost_fl_c",JuMP.value.(cost_fl_c)
# ,"cost_str",JuMP.value.(cost_str)
# ,"cost_str_c",JuMP.value.(cost_str_c)
  ,"Objective",JuMP.objective_value(acopf)
  ,"time",JuMP.solve_time(acopf)
)


include("old_save.jl")

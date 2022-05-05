#-----------------------------Solve the model-----------------------------------
# include("model_sol_mpopf.jl")
long_crtnt=zeros(length(1:nCont),length(1:nSc),length(1:nTP),length(1:nBus))
# for j=1:size(node_data_contin[c][i].node_cnode_c,1)
    # gij_line_c = node_data_contin[c][i].node_gij_sr_c[j],
    # bij_line_c = node_data_contin[c][i].node_bij_sr_c[j],
    # idx_cnode_c=node_data_contin[c][i].node_cnode_c[j]
    # long=[node_data_contin[c][i].node_cnode_c[1:size(node_data_contin[c][i].node_cnode_c,1)] for c in 1:nCont,i in 1:nBus]
# long =[]
#     for c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus,j=1:size(node_data_contin[c][i].node_cnode_c,1),
#                            s=node_data_contin[c][i].node_gij_sr_c[j]
#                            push!(long,s)
#                        end
#
#     long_crtnt[:,:,:,:]=
#      # (
#     node_data_contin[1:nCont][1:nBus].node_gij_sr_c[1:size(node_data_contin[1:nCont][1:nBus].node_cnode_c,1)]
    # +node_data_contin[1:nCont][1:nBus].node_bij_sr_c[1:size(node_data_contin[1:nCont][1:nBus].node_cnode_c,1)]^2)
    # *((JuMP.value.(e_c[1:nCont,1:nSc,1:nTP,1:nBus])-JuMP.value.(e_c[1:nCont,1:nSc,1:nTP,node_data_contin[1:nCont][1:nBus].node_cnode_c[1:size(node_data_contin[1:nCont][1:nBus].node_cnode_c,1)]])).^2
    # + (JuMP.value.(f_c[1:nCont,1:nSc,1:nTP,1:nBus])-JuMP.value.(f_c[1:nCont,1:nSc,1:nTP,node_data_contin[1:nCont][1:nBus].node_cnode_c[1:size(node_data_contin[1:nCont][1:nBus].node_cnode_c,1)]])).^2 )
    # push!(long_c,long_crtnt^0.5)
# end
# longitud=@expression(acopf,
# # begin
#  [s=1:nSc,t=1:nTP,i=1:nLines,
#  f_bus    = nw_lines[i].line_from,
#  t_bus    = nw_lines[i].line_to,
#  # idx_f_bus = findall(x->x==f_bus,rdata_buses[:,1]),
#  # idx_t_bus = findall(x->x==t_bus,rdata_buses[:,1]),
#  ],
#
# ((gij_lin[i]^2+bij_lin[i]^2))*(((e[s,t,f_bus]-e[s,t,t_bus])^2 + (f[s,t,f_bus]-f[s,t,t_bus])^2))
# # end
#  )
# gij_line_c=real(yij_line_c)
# bij_line_c=imag(yij_line_c)
# longitud_c=@expression(acopf, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nLines,
# # # f_bus    = idx_from_line_c[c][i],
# # # t_bus    = idx_to_line_c[c][i],
# #                       gij_line_c = node_data_contin[c][i].node_gij_sr_c[1:size(node_data_contin[c][i].node_cnode_c,1)],
# #                       bij_line_c = node_data_contin[c][i].node_bij_sr_c[1:size(node_data_contin[c][i].node_cnode_c,1)],
# #                       idx_cnode_c= node_data_contin[c][i].node_cnode_c[1:size(node_data_contin[c][i].node_cnode_c,1)]
#                      ],
# (gij_line_c^2
# +bij_line_c^2)
# *((e_c[c,s,t,f_bus]-e_c[c,s,t,t_bus])^2
# + (f_c[c,s,t,f_bus]-f_c[c,s,t,t_bus])^2 )
#
#                      )
#=
save("Final_S_MP_SCOPF.jld"
     , "Pg",JuMP.value.(Pg[:,:,:])
     , "Pg_c",JuMP.value.(Pg_c[:,:,:,:])
     , "Qg",JuMP.value.(Qg[:,:,:])
     , "Qg_c",JuMP.value.(Qg_c[:,:,:,:])
     , "e_c",JuMP.value.(e_c[:,:,:,:])
     , "f_c",JuMP.value.(f_c[:,:,:,:])
     , "e",JuMP.value.(e[:,:,:])
     , "f",JuMP.value.(f[:,:,:])
     ,"volt_mag",(JuMP.value.(e[:,:,:]).^2+JuMP.value.(f[:,:,:]).^2).^0.5
     ,"volt_mag_c",(JuMP.value.(e_c[:,:,:,:]).^2+JuMP.value.(f_c[:,:,:,:]).^2).^0.5
     ,"longit_currnt",JuMP.value.(longitud)
     ,"longit_currnt_c",(JuMP.value.(longitud_c))
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
# longitudinal_sqr=[load("result_1scen.jld")["longit_currnt"][1,t,i,nw_lines[i].line_from,nw_lines[i].line_to] for t in 1:nTP, i in 1:nLines]
# longitudinal=longitudinal_sqr.^0.5
# ods_write("longitudinal.ods",Dict(("TestSheet",3,2)=>longitudinal))
# longitudinal_sqr_c=[load("result_1scen.jld")["longit_currnt_c"][1,1,t,i,idx_from_line_c[1][i],idx_to_line_c[1][i]] for t in 1:nTP, i in 1:nLines]
# longitudinal_c=longitudinal_sqr_c.^0.5
# ods_write("longitudinal_c.ods",Dict(("TestSheet",3,2)=>longitudinal_c))
# volt_mag_normal=load("result_1scen.jld")["volt_mag"][1,:,:]
# ods_write("volt_mag_normal.ods", Dict(("TestSheet",3,2)=>volt_mag_normal))
# volt_mag_contin=load("result_1scen.jld")["volt_mag_c"][1,1,:,:]
# ods_write("volt_mag_contin.ods", Dict(("TestSheet",3,2)=>volt_mag_contin))
pgen=load("Final_S_MP_SCOPF_OK.jld")["Pg"][1,:,:]
=#

# include("03_first_PF.jl")

# JuMP.dual.(longitud_contin)
# idx_l_dual_dict=Dict{Array{Int64,1},Float64}()
# for i in eachindex(l_crnt_const)
#     if (JuMP.dual.(l_crnt_const)[i])>0.1
#         push!(idx_l_dual_dict, i=>1)
#     end
# end
#
# longitud_contin_dic=[]
# for i in eachindex(longitud_contin)
#     if JuMP.dual.(longitud_contin[i])>0.1 || JuMP.dual.(longitud_contin[i])<-0.1
#         # push!(longitud_contin_dic,JuMP.dual.(longitud_contin[i]))
#         push!(longitud_contin_dic,i)
#     end
# end



function trans_map_t(nBus,node_data_trans)
    from_to_map_t=Dict()
    for i in 1:nBus

     if  ~isempty(node_data_trans[i,1].node_num)
       for j in 1:size(node_data_trans[i,1].node_num,1)
           from_node=findall(x->x==node_data_trans[i,1].node_num[j,1], idx_from_trans)
           to_node  =findall(x->x==node_data_trans[i,1].node_cnode[j,1], idx_to_trans)

           check_idx= intersect(from_node,to_node)
           push!(from_to_map_t, [i,j]=> check_idx)
       end
   end
end

return from_to_map_t
end
function rect_to_polar(indicator)
    if indicator=="normal"
v_sq  =JuMP.value.(e[:,:]).^2+JuMP.value.(f[:,:]).^2
# v_sq_c=JuMP.value.(e_c[:,:,:,:]).^2+JuMP.value.(f_c[:,:,:,:]).^2
voltage_gen=JuMP.value.(v_sq[:,:]).^0.5
volt_ang=2*atan.(JuMP.value.(f[:,:])./(voltage_gen+JuMP.value.(e[:,:])))
v_sq_c=0
voltage_gen_c=0
volt_ang_c=0
return v_sq,voltage_gen,volt_ang,v_sq_c,voltage_gen_c,volt_ang_c
elseif indicator=="contin"
    v_sq  =JuMP.value.(e[:,:]).^2+JuMP.value.(f[:,:]).^2
    # v_sq_c=JuMP.value.(e_c[:,:,:,:]).^2+JuMP.value.(f_c[:,:,:,:]).^2
    voltage_gen=v_sq.^0.5
    volt_ang=2*atan.(JuMP.value.(f[:,:])./(voltage_gen+JuMP.value.(e[:,:])))
    v_sq_c  =JuMP.value.(e_c[:,:,:,:]).^2+JuMP.value.(f_c[:,:,:,:]).^2
    # v_sq_c=JuMP.value.(e_c[:,:,:,:]).^2+JuMP.value.(f_c[:,:,:,:]).^2
    voltage_gen_c=v_sq_c.^0.5
    volt_ang_c=2*atan.(JuMP.value.(f_c[:,:,:,:])./(voltage_gen_c+JuMP.value.(e_c[:,:,:,:])))

    return v_sq,voltage_gen,volt_ang,v_sq_c,voltage_gen_c,volt_ang_c
end

end
function variables_n(model_name)
      # if OPF_or_SCOPF==0
      # variable_by_name(model_name, "e[1,1,1]")  all of e[1,1,1] is the name
          @variable(model_name, e[ j = 1:nTP, k = 1:nBus], start=1)#,(start = 1.00)                                  # This procedure can be used to set the start values of all variables
          @variable(model_name, f[ j = 1:nTP, k = 1:nBus], start=0.0)
          # @variable(model_name, slack[ j = 1:nTP, k = 1:nBus , m = 1:nBus], start=0.0,lower_bound=0.0)
          @variable(model_name, pen_ws[ j = 1:nTP, k = 1:nRES], start=0.5*prof_PRES[1,j,k],lower_bound=0.0, upper_bound=prof_PRES[1,j,k])
          @variable(model_name, pen_lsh[ j = 1:nTP, k = 1:nLoads], start=0.5*prof_ploads[k,j],lower_bound=0.0, upper_bound=prof_ploads[k,j])
          # @variable(model_name, Pg[ j = 1:nTP, k = 1:nGens], start=nw_gens[k].gen_Pg_avl,lower_bound=pg_min[k],upper_bound=pg_max[k])
          # @variable(model_name, Qg[ j = 1:nTP, k = 1:nGens], start=nw_gens[k].gen_Qg_avl,lower_bound=qg_min[k],upper_bound=qg_max[k])
          @variable(model_name, Pg[ j = 1:nTP, k = 1:nGens])
          @variable(model_name, Qg[ j = 1:nTP, k = 1:nGens])

          # @variable(model_name, slack_pb_p[ t= 1:nTP, i=1:nBus], lower_bound=0)
          # @variable(model_name, slack_pb_n[ t= 1:nTP, i=1:nBus], lower_bound=0)
          # @variable(model_name, slack_rb_p[ t= 1:nTP, i=1:nBus], lower_bound=0)
          # @variable(model_name, slack_rb_n[ t= 1:nTP, i=1:nBus], lower_bound=0)
         p_fl_inc=nothing
         p_fl_dec=nothing
         q_fl_inc=nothing
         q_fl_dec=nothing
           if nFl!=0
               # @variable(model_name, p_fl_inc[ j = 1:nTP, k = 1:nFl], start=0.5*load_inc_prct*prof_ploads[k,j],lower_bound=0.0, upper_bound=load_inc_prct*prof_ploads[nd_fl_bus[k],j])
               # @variable(model_name, p_fl_dec[ j = 1:nTP, k = 1:nFl], start=0.5*load_dec_prct*prof_ploads[k,j],lower_bound=0.0, upper_bound=load_dec_prct*prof_ploads[nd_fl_bus[k],j])
    @variable(model_name, p_fl_inc[ j = 1:nTP, k = 1:nFl],lower_bound=0.0, upper_bound=upper_flex_p_inc[k])
    @variable(model_name, p_fl_dec[ j = 1:nTP, k = 1:nFl],lower_bound=0.0, upper_bound=upper_flex_p_dec[k])
    @variable(model_name, q_fl_inc[ j = 1:nTP, k = 1:nFl],lower_bound=0.0, upper_bound=upper_flex_q_inc[k])
    @variable(model_name, q_fl_dec[ j = 1:nTP, k = 1:nFl],lower_bound=0.0, upper_bound=upper_flex_q_dec[k])
          end
          p_ch=nothing
          p_dis=nothing
          soc=nothing
          if nStr_active!=0

          @variable(model_name, p_ch[ j = 1:nTP, k = 1:nStr_active], start=0.5*array_storage[k].storage_ch_rat/sbase,lower_bound=0.0,upper_bound=array_storage[k].storage_ch_rat/sbase)
          @variable(model_name, p_dis[ j = 1:nTP, k = 1:nStr_active], start=0.5*array_storage[k].storage_dis_rat/sbase,lower_bound=0.0,upper_bound=array_storage[k].storage_dis_rat/sbase)
          @variable(model_name, soc[ j = 1:nTP, k = 1:nStr_active], start=0.5*array_storage[k].storage_e_rat/sbase,lower_bound=array_storage[k].storage_e_rat_min/sbase, upper_bound=array_storage[k].storage_e_rat/sbase)
      end
      Pg_neg=nothing
      Qg_neg=nothing
      if  haskey(new_data, "negGen")
          @variable(model_name, Pg_neg[ j = 1:nTP, k = 1:size(new_data["negGen"],1)], lower_bound=new_data["negGen"][k][4]/new_data["negGen"][k][2], upper_bound=new_data["negGen"][k][3]/new_data["negGen"][k][2])
          @variable(model_name, Qg_neg[ j = 1:nTP, k = 1:size(new_data["negGen"],1)], lower_bound=new_data["negGen"][k][6]/new_data["negGen"][k][2], upper_bound=new_data["negGen"][k][5]/new_data["negGen"][k][2])

      end
      return e, f, Pg, Qg, pen_ws, pen_lsh, p_fl_inc, p_fl_dec,q_fl_inc,q_fl_dec, p_ch, p_dis, soc,Pg_neg,Qg_neg

end
function variables_c(model_name)

          # SCOPF part----------------------------------------------------------------------------

          # @variable(model_name,  e_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nBus],start=array_bus[k].bus_v_init_re)
          # @variable(model_name, f_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nBus], start=array_bus[k].bus_v_init_im)
         @variable(model_name,  e_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nBus],start=0.9)
         @variable(model_name,  f_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nBus], start=0.0)
          # @variable(model_name, slack_pb_p_c[c = 1:nCont,s=1:nSc, t= 1:nTP, i=1:nBus], lower_bound=0)
          # @variable(model_name, slack_pb_n_c[c = 1:nCont,s=1:nSc, t= 1:nTP, i=1:nBus], lower_bound=0)
          # @variable(model_name, slack_rb_p_c[c = 1:nCont,s=1:nSc, t= 1:nTP, i=1:nBus], lower_bound=0)
          # @variable(model_name, slack_rb_n_c[c = 1:nCont,s=1:nSc, t= 1:nTP, i=1:nBus], lower_bound=0)


          @variable(model_name, pen_ws_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nRES], start=0.5*prof_PRES[i,j,k], lower_bound=0.0, upper_bound=prof_PRES[i,j,k])
          @variable(model_name, pen_lsh_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nLoads], start=0.5*prof_ploads[k,j],lower_bound=0.0, upper_bound=prof_ploads[k,j])
          @variable(model_name, Pg_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nGens])
          @variable(model_name, Qg_c[c = 1:nCont, i = 1:nSc, j = 1:nTP, k = 1:nGens])
          p_fl_inc_c=nothing
          p_fl_dec_c=nothing
          q_fl_inc_c=nothing
          q_fl_dec_c=nothing
          if   nFl!=0
              # @variable(model_name, p_fl_inc_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nFl], start=0.5*load_inc_prct*prof_ploads[k,j],lower_bound=0.0, upper_bound=load_inc_prct*prof_ploads[nd_fl_bus[k],j])
              # @variable(model_name, p_fl_dec_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nFl], start=0.5*load_dec_prct*prof_ploads[k,j],lower_bound=0.0, upper_bound=load_dec_prct*prof_ploads[nd_fl_bus[k],j])
              @variable(model_name, p_fl_inc_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nFl], lower_bound=0.0, upper_bound=upper_flex_p_inc[k])
              @variable(model_name, p_fl_dec_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nFl], lower_bound=0.0, upper_bound=upper_flex_p_dec[k])
              @variable(model_name, q_fl_inc_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nFl], lower_bound=0.0, upper_bound=upper_flex_q_inc[k])
              @variable(model_name, q_fl_dec_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nFl], lower_bound=0.0, upper_bound=upper_flex_q_dec[k])

          end
          p_ch_c=nothing
          p_dis_c=nothing
          soc_c=nothing
          if nStr_active!=0
          @variable(model_name, p_ch_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nStr_active], start=0.5*array_storage[k].storage_ch_rat/sbase,lower_bound=0.0,upper_bound=array_storage[k].storage_ch_rat/sbase)
          @variable(model_name, p_dis_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nStr_active], start=0.5*array_storage[k].storage_dis_rat/sbase,lower_bound=0.0,upper_bound=array_storage[k].storage_dis_rat/sbase)
          @variable(model_name, soc_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:nStr_active], start=0.5*array_storage[k].storage_e_rat/sbase,lower_bound=array_storage[k].storage_e_rat_min/sbase, upper_bound=array_storage[k].storage_e_rat/sbase)
            end
            Pg_neg_c=nothing
            Qg_neg_c=nothing
            if haskey(new_data, "negGen")
    @variable(model_name, Pg_neg_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:size(new_data["negGen"],1)], lower_bound=new_data["negGen"][k][4]/new_data["negGen"][k][2], upper_bound=new_data["negGen"][k][3]/new_data["negGen"][k][2])
    @variable(model_name, Qg_neg_c[c = 1:nCont,i = 1:nSc, j = 1:nTP, k = 1:size(new_data["negGen"],1)], lower_bound=new_data["negGen"][k][6]/new_data["negGen"][k][2], upper_bound=new_data["negGen"][k][5]/new_data["negGen"][k][2])

end
       return  e_c, f_c, Pg_c, Qg_c, pen_ws_c, pen_lsh_c, p_fl_inc_c ,p_fl_dec_c, q_fl_inc_c ,q_fl_dec_c,p_ch_c, p_dis_c, soc_c,Pg_neg_c,Qg_neg_c

end
# e, f, Pg, Qg, e_c, f_c, Pg_c, Qg_c=variables(1,model_name)

function voltage_cons_n(model_name,volt_type)
    # if OS==0
        for t=1:nTP,i=1:nBus
            if  nw_buses[i].bus_type==3
                fix(f[t,i],0)
            end
        end
        if volt_type=="fixed"
            vol_const_nr=@constraint(model_name, [t=1:nTP,i=1:nBus; ~isempty(findall(x->x==i, bus_data_gsheet)) ], e[t,i]^2+f[t,i]^2==(nw_gens[findall(x->x==i, bus_data_gsheet)[1]].gen_V_set)^2)
                return vol_const_nr
        elseif volt_type=="range"
            vol_const_nr1=@constraint(model_name, [t=1:nTP,i=1:nBus], (e[t,i]^2+f[t,i]^2)<=(nw_buses[i].bus_vmax)^2)
            vol_const_nr2=@constraint(model_name, [t=1:nTP,i=1:nBus], (nw_buses[i].bus_vmin)^2<=(e[t,i]^2+f[t,i]^2))
               return vol_const_nr1,vol_const_nr2
        end
    # no_zero_react=[]
    # for i in 1:nGens
    #     if qg_min[i]==0 && qg_max[i]==0
    #         push!(no_zero_react, i)
    #     end
    # end
    #
    # bus_data_gsheet_no_z_reac=deepcopy(bus_data_gsheet)
    # # for i in no_zero_react
    #     deleteat!(bus_data_gsheet_no_z_reac,no_zero_react)
    # # end
    # vol_const_nr=@constraint(model_name, [s=1:nSc,t=1:nTP,i=1:nBus; ~isempty(findall(x->x==i, bus_data_gsheet)) ], e[t,i]^2+f[t,i]^2==(nw_gens[findall(x->x==i, bus_data_gsheet)[1]].gen_V_set)^2)
    # vol_const_nr=@constraint(model_name, [s=1:nSc,t=1:nTP,i=1:nBus], (nw_buses[i].bus_vmin)^2<=(e[t,i]^2+f[t,i]^2)<=(nw_buses[i].bus_vmax)^2)

    # @constraint(model_name, [s=1:nSc,t=1:nTP,i=1:nBus; ~isempty(findall(x->x==i, bus_data_gsheet_no_z_reac)) ], e[t,i]^2+f[t,i]^2==(nw_gens[findall(x->x==i, bus_data_gsheet_no_z_reac)[1]].gen_V_set)^2)
    # @constraint(model_name, [s=1:nSc,t=1:nTP,i=1:nBus; ~isempty(findall(x->x==i, bus_data_gsheet_no_z_reac)) ], (nw_gens[findall(x->x==i, bus_data_gsheet)[1]].gen_V_set-0.009)^2<=(e[t,i]^2+f[t,i]^2)<=(nw_gens[findall(x->x==i, bus_data_gsheet)[1]].gen_V_set+0.009)^2)

 return vol_const_nr
end

function voltage_cons_c(model_name,volt_type_c)
    for c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus
        if  nw_buses[i].bus_type==3
            fix(f_c[c,s,t,i],0)
        end
    end
    if volt_type_c=="fixed"
        vol_const_cn=@constraint(model_name, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus; ~isempty(findall(x->x==i, bus_data_gsheet)) ], e_c[c,s,t,i]^2+f_c[c,s,t,i]^2==(nw_gens[findall(x->x==i, bus_data_gsheet)[1]].gen_V_set)^2)
           return vol_const_cn
       elseif volt_type_c=="range"
    vol_const_cn1=@constraint(model_name, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus], (e_c[c,s,t,i]^2+f_c[c,s,t,i]^2)<=(nw_buses[i].bus_vmax+v_relax_factor_max)^2)
    vol_const_cn2=@constraint(model_name, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus], (nw_buses[i].bus_vmin-v_relax_factor_min)^2<=(e_c[c,s,t,i]^2+f_c[c,s,t,i]^2))

    # vol_const_cn=@constraint(model_name, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus], (nw_buses[i].bus_vmin)^2<=(e_c[c,s,t,i]^2+f_c[c,s,t,i]^2)<=(nw_buses[i].bus_vmax)^2)
        return vol_const_cn1,vol_const_cn2
     end
end
# voltage_cons(0,model_name)

#
# function tratio_f(OS,model_name)
# if OS==0
#     tratio=ones(nSc,nTP,nBus,nBus)
#     tratio_c=0
#     return tratio,tratio_c
# elseif  OS==1
#     tratio=ones(nSc,nTP,nBus,nBus)
#     tratio_c=ones(nCont,nSc,nTP,nBus,nBus)
#     return tratio,tratio_c
# end
# end

# tratio=tratio_f(0,model_name)
function gen_limits_n(model_name,gen_type)
if gen_type=="range"
    for t=1:nTP,i=1:nGens
        if pg_min[i]==0 && pg_max[i]==0
         fix(Pg[t,i],0)
       else
 set_lower_bound(Pg[t,i],pg_min[i])
 set_upper_bound(Pg[t,i],pg_max[i])
    end
end
for t=1:nTP,i=1:nGens
    if qg_min[i]==0 && qg_max[i]==0
     fix(Qg[t,i],0)
   else
set_lower_bound(Qg[t,i],qg_min[i])
set_upper_bound(Qg[t,i],qg_max[i])
end
end
elseif gen_type=="fixed"
# end
    for t=1:nTP,i=1:nGens
     if    nw_buses[bus_data_gsheet[i]].bus_type!=3
             fix(Pg[t,i],nw_gens[i].gen_Pg_avl)
    end
end
end

end

function gen_limits_c(model_name,gen_type_c)
if gen_type_c=="range"
    for c=1:nCont, s=1:nSc,t=1:nTP,i=1:nGens
        if pg_min[i]==0 && pg_max[i]==0
         fix(Pg_c[c,s,t,i],0)
       else
 set_lower_bound(Pg_c[c,s,t,i],pg_min[i])
 set_upper_bound(Pg_c[c,s,t,i],pg_max[i])
    end
end
for c=1:nCont,s=1:nSc,t=1:nTP,i=1:nGens
    if qg_min[i]==0 && qg_max[i]==0
     fix(Qg_c[c,s,t,i],0)
   else
set_lower_bound(Qg_c[c,s,t,i],qg_min[i])
set_upper_bound(Qg_c[c,s,t,i],qg_max[i])
end
end
elseif gen_type_c=="fixed"
    for c=1:nCont,s=1:nSc,t=1:nTP,i=1:nGens
     if    nw_buses[bus_data_gsheet[i]].bus_type!=3
             fix(Pg_c[c,s,t,i],nw_gens[i].gen_Pg_avl)
    end
end
end
end

function FL_cons_normal(model_name)
    # @constraint(model_name,[i=1:nFl],sum(p_fl_inc[t,i] for t in 1:nTP)==sum(p_fl_dec[t,i] for t in 1:nTP))
    # @constraint(model_name,[t=1:nTP,i=1:nFl],p_fl_inc[t,i]/(load_inc_prct*prof_ploads[nd_fl_bus[i],t])+p_fl_dec[t,i]/(load_dec_prct*prof_ploads[nd_fl_bus[i],t]) <=1)

    @constraint(model_name,[t=1:nTP,i=1:nFl;upper_flex_p_inc[i] != 0 && upper_flex_p_dec[i] != 0 ],p_fl_inc[t,i]/(upper_flex_p_inc[i])+p_fl_dec[t,i]/(upper_flex_p_dec[i]) <=1)
    @constraint(model_name,[t=1:nTP,i=1:nFl;upper_flex_q_inc[i] != 0 && upper_flex_q_dec[i] != 0 ],q_fl_inc[t,i]/(upper_flex_q_inc[i])+q_fl_dec[t,i]/(upper_flex_q_dec[i]) <=1)
    # if nFl!=0
    #     for i in 1:nFl, t in 1:nTP
    #         if upper_flex_p_inc[i] == 0
    #             fix(p_fl_inc[t,i], 0)
    #         end
    #         if upper_flex_p_dec[i] == 0
    #             fix(p_fl_dec[t,i], 0)
    #         end
    #         if upper_flex_q_inc[i] == 0
    #             fix(q_fl_inc[t,i], 0)
    #         end
    #         if upper_flex_q_dec[i] == 0
    #             fix(q_fl_dec[t,i], 0)
    #         end
    #
    #
    #     end
    # end
end

function FL_cons_contin(model_name)
    # @constraint(model_name,[c=1:nCont,s=1:nSc,i=1:nFl],sum(p_fl_inc_c[c,s,t,i] for t in 1:nTP)-sum(p_fl_dec_c[c,s,t,i] for t in 1:nTP)==0)
    # @constraint(model_name,[c=1:nCont,s=1:nSc,t=1:nTP,i=1:nFl],p_fl_inc_c[c,s,t,i]/(load_inc_prct*prof_ploads[nd_fl_bus[i],t])+p_fl_dec_c[c,s,t,i]/(load_dec_prct*prof_ploads[nd_fl_bus[i],t]) <=1)
    @constraint(model_name,[c=1:nCont,s=1:nSc,t=1:nTP,i=1:nFl;upper_flex_p_inc[i] != 0 && upper_flex_p_dec[i] != 0 ],p_fl_inc_c[c,s,t,i]/(upper_flex_p_inc[i])+p_fl_dec_c[c,s,t,i]/(upper_flex_p_dec[i]) <=1)
    @constraint(model_name,[c=1:nCont,s=1:nSc,t=1:nTP,i=1:nFl;upper_flex_q_inc[i] != 0 && upper_flex_q_dec[i] != 0 ],q_fl_inc_c[c,s,t,i]/(upper_flex_q_inc[i])+q_fl_dec_c[c,s,t,i]/(upper_flex_q_dec[i]) <=1)
    # if nFl!=0
    #     for c in 1:nCont,s in 1:nSc,t in 1:nTP,i in 1:nFl
    #         if upper_flex_p_inc[i] == 0
    #             fix(p_fl_inc_c[c,s,t,i], 0)
    #         end
    #         if upper_flex_p_dec[i] == 0
    #             fix(p_fl_dec_c[c,s,t,i], 0)
    #         end
    #         if upper_flex_q_inc[i] == 0
    #             fix(q_fl_inc_c[c,s,t,i], 0)
    #         end
    #         if upper_flex_q_dec[i] == 0
    #             fix(q_fl_dec_c[c,s,t,i], 0)
    #         end
    #
    #
    #     end
    # end
end

function storage_cons_normal(model_name)
@constraint(model_name,
            [t=1:nTP,j = 1:nStr_active; t==1],
            soc[t,j]==array_storage[j].storage_e_initial/sbase
            +p_ch[t,j]*array_storage[j].storage_ch_eff
            -p_dis[t,j]*(array_storage[j].storage_dis_eff^-1)
            )
@constraint(model_name,
           [t=1:nTP,j = 1:nStr_active; t!=1],
           soc[t,j]==soc[t-1,j]
           +p_ch[t,j]*array_storage[j].storage_ch_eff
           -p_dis[t,j]*(array_storage[j].storage_dis_eff^-1)
                        )

@constraint(model_name,
           [t=1:nTP,j = 1:nStr_active],
           p_ch[t,j]/(array_storage[j].storage_ch_rat/sbase)+p_dis[t,j]/(array_storage[j].storage_dis_rat/sbase)<=1
           )
@constraint(model_name,
          [ j = 1:nStr_active],
          soc[nTP,j]==array_storage[j].storage_e_initial/sbase
          )
end
function storage_cons_contin(model_name)
@constraint(model_name,
            [c=1:nCont,s=1:nSc,t=1:nTP,j = 1:nStr_active; t==1],
            soc_c[c,s,t,j]==array_storage[j].storage_e_initial/sbase
            +p_ch_c[c,s,t,j]*array_storage[j].storage_ch_eff
            -p_dis_c[c,s,t,j]*(array_storage[j].storage_dis_eff^-1)
            )
@constraint(model_name,
           [c=1:nCont,s=1:nSc,t=1:nTP,j = 1:nStr_active; t!=1],
           soc_c[c,s,t,j]==soc_c[c,s,t-1,j]
           +p_ch_c[c,s,t,j]*array_storage[j].storage_ch_eff
           -p_dis_c[c,s,t,j]*(array_storage[j].storage_dis_eff^-1)
                        )

@constraint(model_name,
           [c=1:nCont,s=1:nSc,t=1:nTP,j = 1:nStr_active],
           p_ch_c[c,s,t,j]/(array_storage[j].storage_ch_rat/sbase)+p_dis_c[c,s,t,j]/(array_storage[j].storage_dis_rat/sbase)<=1
           )

@constraint(model_name,
          [c=1:nCont,s=1:nSc, j = 1:nStr_active],
          soc_c[c,s,nTP,j]==array_storage[j].storage_e_initial/sbase
          )
end
# gen_limits(0,model_name)
function line_expression_n(model_name)

    # if OS==0
        pinj_dict=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()
        qinj_dict=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()
        # pinj_dict_sr=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()
        # qinj_dict_sr=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()


        # for s in 1:nSc
            for t in 1:nTP
                for i in 1:nBus
                    # for i in [47]
                    idx_nd_nw_buses = i
                    # idx_fr_trans =findall(x->x==i,idx_from_trans)
                    # idx_t_trans =findall(x->x==i,idx_to_trans)
                    # idx_bus_lsheet  = findall(x->x==i,bus_data_lsheet)              # Index of buses in load sheet
                    # idx_bus_gsheet  = findall(x->x==i,bus_data_gsheet)
                    # idx_bus_shunt   = findall(x->x==i,rdata_shunts[:,1])
                    # idx_fl = findall(x->x==i,nd_fl)
                    # idx_RES         = findall(x->x==i,RES_bus)
                    # idx_str         = findall(x->x==i,nd_Str_active)
                if  ~isempty(node_data[i,1].node_num)


                    for j in 1:size(node_data[i,1].node_num,1)                                                # length of each node vector in 'node_data' variable

                        gij_line    = node_data[i,1].node_gij_sr[j,1]
                        bij_line    = node_data[i,1].node_bij_sr[j,1]
                        cnctd_nd    = node_data[i,1].node_cnode[j,1]
                        # idx_cnctd_nd = findall(x->x==cnctd_nd,rdata_buses[:,1])
                        idx_cnctd_nd = cnctd_nd
                        gij_line_sh = node_data[i,1].node_gij_sh[j,1]
                        bij_line_sh = node_data[i,1].node_bij_sh[j,1]
                        smax        =node_data[i,1].node_smax[j,1]

                        pij      = (
                        ((gij_line_sh/2)*(e[t,idx_nd_nw_buses]^2+f[t,idx_nd_nw_buses]^2) )       # Line shunt conductance (Must be divided by 2)
                        + ((gij_line)*(e[t,idx_nd_nw_buses]^2+f[t,idx_nd_nw_buses]^2) )       # Line shunt conductance (Must be divided by 2)
                        + (-bij_line*(f[t,idx_nd_nw_buses]*e[t,idx_cnctd_nd]-e[t,idx_nd_nw_buses]*f[t,idx_cnctd_nd]) )
                        + (-gij_line*(e[t,idx_nd_nw_buses]*e[t,idx_cnctd_nd]+f[t,idx_nd_nw_buses]*f[t,idx_cnctd_nd]) )
                                   )
                        qij      = (
                        (-(bij_line_sh/2)*(e[t,idx_nd_nw_buses]^2+f[t,idx_nd_nw_buses]^2) )      # Line shunt susceptance (Must be divided by 2)
                        + (-(bij_line)*(e[t,idx_nd_nw_buses]^2+f[t,idx_nd_nw_buses]^2) )      # Line shunt susceptance (Must be divided by 2)
                        + (  bij_line*(e[t,idx_nd_nw_buses]*e[t,idx_cnctd_nd]+f[t,idx_nd_nw_buses]*f[t,idx_cnctd_nd]) )
                        + ( -gij_line*(f[t,idx_nd_nw_buses]*e[t,idx_cnctd_nd]-e[t,idx_nd_nw_buses]*f[t,idx_cnctd_nd]) )
                                    )
                                # pij = (+pinj_ij_sh+pinj_ij_sr0+pinj_ij_sr1+pinj_ij_sr2)
                                # qij = (+qinj_ij_sh+qinj_ij_sr0+qinj_ij_sr1+qinj_ij_sr2)
                                # pij_sr = (+pinj_ij_sh+pinj_ij_sr0+pinj_ij_sr1+pinj_ij_sr2)
                                # qij_sr = (+qinj_ij_sh+qinj_ij_sr0+qinj_ij_sr1+qinj_ij_sr2)


                                # @NLconstraint(model_name,pij^2+qij^2<=smax^2)
                        # end
                        push!(pinj_dict,  [t,idx_nd_nw_buses,idx_cnctd_nd] => pij)
                        push!(qinj_dict,  [t,idx_nd_nw_buses,idx_cnctd_nd] => qij)
                        # push!(pinj_dict_sr,  [t,idx_nd_nw_buses,idx_cnctd_nd] => pij_sr)
                        # push!(qinj_dict_sr,  [t,idx_nd_nw_buses,idx_cnctd_nd] => qij_sr)

                        # push!(pinj_expr_1netw,pij)
                        # push!(qinj_expr_1netw,qij)
                        # push!(line_to_bus_topology_1,[idx_nd_nw_buses,idx_cnctd_nd])
                    end
               end
                if ~isempty(node_data_trans[i,1].node_num)
                    for j in 1:size(node_data_trans[i,1].node_num,1)                                                # length of each node vector in 'node_data' variable
                        gij_line_transf    = node_data_trans[i,1].node_gij_sr[j,1]
                        bij_line_transf    = node_data_trans[i,1].node_bij_sr[j,1]
                        cnctd_nd = node_data_trans[i,1].node_cnode[j,1]
                        # idx_cnctd_nd_trans = findall(x->x==cnctd_nd,rdata_buses[:,1])
                        idx_cnctd_nd_trans = cnctd_nd
                        gij_line_sh_transf = 0.5*node_data_trans[i,1].node_gij_sh[j,1]
                        bij_line_sh_transf = 0.5*node_data_trans[i,1].node_bij_sh[j,1]
                        tratio             = 1/node_data_trans[i,1].node_tratio[j,1]
                        from_node=findall(x->x==node_data_trans[i,1].node_num[j,1], idx_from_trans)
                        to_node  =findall(x->x==node_data_trans[i,1].node_cnode[j,1], idx_to_trans)

                        check_idx= intersect(from_node,to_node)
                        if ~isempty(check_idx)  #this means from


                         # Florin transformer model
                         pijt1  =(
                          ((tratio^2)*(gij_line_sh_transf/2+gij_line_transf)*(e[t,idx_nd_nw_buses]^2+f[t,idx_nd_nw_buses]^2) )
                         + ((tratio)*(-gij_line_transf)*(e[t,idx_nd_nw_buses]*e[t,idx_cnctd_nd_trans]+f[t,idx_nd_nw_buses]*f[t,idx_cnctd_nd_trans]) )
                         - ((tratio)*(-bij_line_transf)*(e[t,idx_nd_nw_buses]*f[t,idx_cnctd_nd_trans]-e[t,idx_cnctd_nd_trans]*f[t,idx_nd_nw_buses]) )
                                  )
                         qijt1  = (((tratio^2)*(-bij_line_sh_transf/2- bij_line_transf)*(e[t,idx_nd_nw_buses]^2+f[t,idx_nd_nw_buses]^2) )
                         + ((tratio)*(-gij_line_transf)*(e[t,idx_cnctd_nd_trans]*f[t,idx_nd_nw_buses]-e[t,idx_nd_nw_buses]*f[t,idx_cnctd_nd_trans]) )
                         + ((tratio)*bij_line_transf*(e[t,idx_nd_nw_buses]*e[t,idx_cnctd_nd_trans]+f[t,idx_nd_nw_buses]*f[t,idx_cnctd_nd_trans]) )
                                  )
                                # pijt1 = (+pinj_ij_sh_trans+pinj_ij_sr1_trans-pinj_ij_sr2_trans)
                                # qijt1 = (+qinj_ij_sh_trans+qinj_ij_sr1_trans+qinj_ij_sr2_trans)
                                # pij = ( -pinj_ij_sr2_trans)
                                # qij = @NLexpression(model_name, +qinj_ij_sh_trans+qinj_ij_sr2_trans)
                                push!(pinj_dict,  [t,idx_nd_nw_buses,idx_cnctd_nd_trans] => pijt1)
                                push!(qinj_dict,  [t,idx_nd_nw_buses,idx_cnctd_nd_trans] => qijt1)
                        elseif isempty(check_idx)
                            pijt1  = (((gij_line_sh_transf/2+gij_line_transf)*(e[t,idx_nd_nw_buses]^2+f[t,idx_nd_nw_buses]^2) )
                            + ((tratio)*(-gij_line_transf)*(e[t,idx_nd_nw_buses]*e[t,idx_cnctd_nd_trans]+f[t,idx_nd_nw_buses]*f[t,idx_cnctd_nd_trans]) )
                            - ((tratio)*(-bij_line_transf)*(e[t,idx_nd_nw_buses]*f[t,idx_cnctd_nd_trans]-e[t,idx_cnctd_nd_trans]*f[t,idx_nd_nw_buses]) )
                                         )
                            qijt1  = (((-bij_line_sh_transf/2- bij_line_transf)*(e[t,idx_nd_nw_buses]^2+f[t,idx_nd_nw_buses]^2) )
                            + ((tratio)*(-gij_line_transf)*(e[t,idx_cnctd_nd_trans]*f[t,idx_nd_nw_buses]-e[t,idx_nd_nw_buses]*f[t,idx_cnctd_nd_trans]) )
                            + ((tratio)*bij_line_transf*(e[t,idx_nd_nw_buses]*e[t,idx_cnctd_nd_trans]+f[t,idx_nd_nw_buses]*f[t,idx_cnctd_nd_trans]) )
                                       )
                                   # pijt1 = (+pinj_ij_sh_trans+pinj_ij_sr1_trans-pinj_ij_sr2_trans)
                                   # qijt1 = (+qinj_ij_sh_trans+qinj_ij_sr1_trans+qinj_ij_sr2_trans)
                                   push!(pinj_dict,  [t,idx_nd_nw_buses,idx_cnctd_nd_trans] => pijt1)
                                   push!(qinj_dict,  [t,idx_nd_nw_buses,idx_cnctd_nd_trans] => qijt1)
                          end



                         end
                     end


                end
            end
        # end

        return pinj_dict,qinj_dict#,pinj_dict_sr,qinj_dict_sr
    end

function line_expression_c(model_name)
        pinj_dict_c=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()
        qinj_dict_c=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()
        # pinj_dict_c_sr=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()
        # qinj_dict_c_sr=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()


        for c in 1:nCont#,s in 1:nSc, t in 1:nTP,i in 1:nBus
            for s in 1:nSc
                for t in 1:nTP
                    for i in 1:nBus

                    # nd      = node_data_contin[c][i].node_num_c                                    # Node num is independant of time period and scenario
                    # nd_num  = unique(nd)
                    # nd_num  = nd_num[1,1]
                    idx_nd_nw_buses=i
                    # idx_nd_nw_buses = indexin(i,rdata_buses[:,1])[1]
                    # idx_nd_nw_buses = idx_nd_nw_buses[1,1]
                    # idx_fr_trans =findall(x->x==i,idx_from_trans)
                    # idx_t_trans =findall(x->x==i,idx_to_trans)
                    # idx_bus_lsheet  = findall(x->x==i,bus_data_lsheet)              # Index of buses in load sheet
                    # idx_bus_gsheet  = findall(x->x==i,bus_data_gsheet)
                    # idx_bus_shunt   = findall(x->x==i,rdata_shunts[:,1])
                    # idx_RES         = findall(x->x==i,RES_bus)
                    # idx_fl = findall(x->x==i,nd_fl)
                    # idx_str         = findall(x->x==i,nd_Str_active)

                        if  ~isempty(node_data_contin[c][i].node_num_c)


                            for j in 1:size(node_data_contin[c][i].node_num_c,1)                                                # length of each node vector in 'node_data' variable

                                gij_line    = node_data_contin[c][i].node_gij_sr_c[j]
                                bij_line    = node_data_contin[c][i].node_bij_sr_c[j]
                                cnctd_nd    = node_data_contin[c][i].node_cnode_c[j]
                                # idx_cnctd_nd = findall(x->x==cnctd_nd,rdata_buses[:,1])
                                idx_cnctd_nd = cnctd_nd
                                gij_line_sh = node_data_contin[c][i].node_gij_sh_c[j]
                                bij_line_sh = node_data_contin[c][i].node_bij_sh_c[j]
                                smax=         node_data_contin[c][i].node_smax_c[j]
                                pij      = @expression(model_name,
                                ((gij_line_sh/2)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )       # Line shunt conductance (Must be divided by 2)
                                + ((gij_line)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )       # Line shunt conductance (Must be divided by 2)
                                + (-bij_line*(f_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd]-e_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd]) )
                                + (-gij_line*(e_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd]+f_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd]) )
                                            )
                                qij      =  @expression(model_name,
                                (-(bij_line_sh/2)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )      # Line shunt susceptance (Must be divided by 2)
                                + (-(bij_line)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )      # Line shunt susceptance (Must be divided by 2)
                                + (  bij_line*(e_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd]+f_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd]) )
                                + ( -gij_line*(f_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd]-e_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd]) )
                                              )
                                        # pij = (pinj_ij_sh+pinj_ij_sr0+pinj_ij_sr1+pinj_ij_sr2)
                                        # qij = (qinj_ij_sh+qinj_ij_sr0+qinj_ij_sr1+qinj_ij_sr2)
                                        # pij_sr = (pinj_ij_sh+pinj_ij_sr0+pinj_ij_sr1+pinj_ij_sr2)
                                        # qij_sr = (qinj_ij_sh+qinj_ij_sr0+qinj_ij_sr1+qinj_ij_sr2)

                                # end
                                    # @NLconstraint(model_name,pij^2+qij^2<=smax^2)
                                    push!(pinj_dict_c,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd] => pij)
                                    push!(qinj_dict_c,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd] => qij)
                                    # push!(pinj_dict_c_sr,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd] => pij_sr)
                                    # push!(qinj_dict_c_sr,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd] => qij_sr)

                                # push!(pinj_expr_1netw,pij)
                                # push!(qinj_expr_1netw,qij)
                                # push!(line_to_bus_topology_1_c,[idx_nd_nw_buses,idx_cnctd_nd])
                            end
                       end
                        if ~isempty(node_data_trans[i,1].node_num)
                            for j in 1:size(node_data_trans[i,1].node_num,1)                                                # length of each node vector in 'node_data' variable
                                gij_line_transf    = node_data_trans[i,1].node_gij_sr[j,1]
                                bij_line_transf    = node_data_trans[i,1].node_bij_sr[j,1]
                                cnctd_nd = node_data_trans[i,1].node_cnode[j,1]
                                # idx_cnctd_nd_trans = findall(x->x==cnctd_nd,rdata_buses[:,1])
                                idx_cnctd_nd_trans = cnctd_nd
                                gij_line_sh_transf = node_data_trans[i,1].node_gij_sh[j,1]
                                bij_line_sh_transf = node_data_trans[i,1].node_bij_sh[j,1]
                                tratio             = 1/node_data_trans[i,1].node_tratio[j,1]
                                # from_node=findall(x->x==node_data_trans[i,1].node_num[j,1], idx_from_trans)
                                # to_node  =findall(x->x==node_data_trans[i,1].node_cnode[j,1], idx_to_trans)
                                check_idx= values(from_to_map_t[[i,j]])
                                # check_idx= intersect(from_node,to_node)
                                if ~isempty(check_idx)  #this means from
                                    # Florin transformer model
                                    pijt1  =  @expression(model_name,
                                    ((tratio^2)*(gij_line_sh_transf/2+gij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )
                                    + ((tratio)*(-gij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd_trans]+f_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]) )
                                    - ((tratio)*(-bij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]-e_c[c,s,t,idx_cnctd_nd_trans]*f_c[c,s,t,idx_nd_nw_buses]) )
                                                         )
                                    qijt1  =  @expression(model_name,
                                    ((tratio^2)*(-bij_line_sh_transf/2- bij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )
                                    + ((tratio)*(-gij_line_transf)*(e_c[c,s,t,idx_cnctd_nd_trans]*f_c[c,s,t,idx_nd_nw_buses]-e_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]) )
                                    + ((tratio)*bij_line_transf*(e_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd_trans]+f_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]) )
                                             )
                                           # pijt1 = (+pinj_ij_sh_trans+pinj_ij_sr1_trans-pinj_ij_sr2_trans)
                                           # qijt1 = (+qinj_ij_sh_trans+qinj_ij_sr1_trans+qinj_ij_sr2_trans)
                                           # pij = ( -pinj_ij_sr2_trans)
                                           # qij = @NLexpression(model_name, +qinj_ij_sh_trans+qinj_ij_sr2_trans)
                                           push!(pinj_dict_c,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => pijt1)
                                           push!(qinj_dict_c,  [c, s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => qijt1)
                                    elseif isempty(check_idx)  #this means from
                                               # Florin transformer model
                                               pijt1  = @expression(model_name,
                                                ((gij_line_sh_transf/2+gij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )
                                               + ((tratio)*(-gij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd_trans]+f_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]) )
                                               - ((tratio)*(-bij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]-e_c[c,s,t,idx_cnctd_nd_trans]*f_c[c,s,t,idx_nd_nw_buses]) )
                                                                  )
                                               qijt1  =  @expression(model_name,
                                               ((-bij_line_sh_transf/2- bij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )
                                               + ((tratio)*(-gij_line_transf)*(e_c[c,s,t,idx_cnctd_nd_trans]*f_c[c,s,t,idx_nd_nw_buses]-e_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]) )
                                               + ((tratio)*bij_line_transf*(e_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd_trans]+f_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]) )
                                                         )
                                                      # pijt1 = (+pinj_ij_sh_trans+pinj_ij_sr1_trans-pinj_ij_sr2_trans)
                                                      # qijt1 = (+qinj_ij_sh_trans+qinj_ij_sr1_trans+qinj_ij_sr2_trans)
                                                      # pij = ( -pinj_ij_sr2_trans)
                                                      # qij = @NLexpression(model_name, +qinj_ij_sh_trans+qinj_ij_sr2_trans)
                                                      push!(pinj_dict_c,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => pijt1)
                                                      push!(qinj_dict_c,  [c, s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => qijt1)

                                       end
                                 end
                             end
            end
            end
         end
        end

return         pinj_dict_c,qinj_dict_c

# end

end


# (pinj_dict,qinj_dict,pinj_dict_sr,qinj_dict_sr)=line_expression(0,model_name)


function active_power_bal_n(model_name,pinj_dict)


        active_power_balance_normal=@constraint(model_name, [ t in 1:nTP, b in 1:nBus],

         reduce(+, (Pg[t,i] for i in findall(x->x==b,bus_data_gsheet) if ~isempty(findall(x->x==b,bus_data_gsheet))); init=0)
         +
         reduce(+, (prof_PRES[1,t,i] for i in findall(x->x==b,RES_bus) if ~isempty(findall(x->x==b,RES_bus))); init=0)
         +
         reduce(+, (pen_lsh[t,i] for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)
         -
         reduce(+, (pen_ws[t,i] for i in findall(x->x==b,RES_bus) if ~isempty(findall(x->x==b,RES_bus))); init=0)
         # -
         # reduce(+, (p_ch[t,i] for i in findall(x->x==b,nd_Str_active) if ~isempty(findall(x->x==b,nd_Str_active))); init=0)
         # +
         # reduce(+, (p_dis[t,i] for i in findall(x->x==b,nd_Str_active) if ~isempty(findall(x->x==b,nd_Str_active))); init=0)
         +
         reduce(+, (Pg_neg[t,i] for i in findall(x->x==b,neg_gen_bus) if haskey(new_data, "negGen") && ~isempty(findall(x->x==b,neg_gen_bus))); init=0)

        # +slack_pb_p[t,b]-slack_pb_n[t,b]
          # ==reduce(+, (pinj_dict[[t,b,node_data[b].node_cnode[j]]] for j in 1:size(node_data[b].node_num,1) if ~isempty(node_data[b].node_num)); init=0)
          ==reduce(+, (pinj_dict[[t,b,j]] for j in node_data[b].node_cnode if ~isempty(node_data[b].node_num)); init=0)

          +
          # reduce(+, (pinj_dict[[t,b,node_data_trans[b,1].node_cnode[j]]] for j in 1:size(node_data_trans[b,1].node_num,1) if ~isempty(node_data_trans[b,1].node_num)); init=0)
          reduce(+, (pinj_dict[[t,b,j]] for j in node_data_trans[b,1].node_cnode if ~isempty(node_data_trans[b,1].node_num)); init=0)

          # reduce(+, (pinj_dict[[t,b,node_data[b].node_cnode[j]]] for j in 1:size(node_data[b].node_num,1) if ~isempty(node_data[b].node_num); init=0)
          # sum(pinj_dict[[t,b,node_data[b].node_cnode[j]]] for j in 1:size(node_data[b].node_num,1) )
          +
          reduce(+, (prof_ploads[i,t]  for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)
          +
          reduce(+, (p_fl_inc[t,i] for i in findall(x->x==b,nd_fl) if ~isempty(findall(x->x==b,nd_fl))); init=0)
          -
          reduce(+, (p_fl_dec[t,i] for i in findall(x->x==b,nd_fl) if ~isempty(findall(x->x==b,nd_fl))); init=0)


              )

return active_power_balance_normal
end
function active_power_bal_c(model_name,pinj_dict_c)


    active_power_balance_contin=@constraint(model_name, [c in 1:nCont, s in 1:nSc, t in 1:nTP, b in 1:nBus],

     reduce(+, (Pg_c[c,s,t,i] for i in findall(x->x==b,bus_data_gsheet) if ~isempty(findall(x->x==b,bus_data_gsheet))); init=0)
     +
     reduce(+, (prof_PRES[s,t,i] for i in findall(x->x==b,RES_bus) if ~isempty(findall(x->x==b,RES_bus))); init=0)
     +
     reduce(+, (pen_lsh_c[c,s,t,i] for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)
     -
     reduce(+, (pen_ws_c[c,s,t,i] for i in findall(x->x==b,RES_bus) if ~isempty(findall(x->x==b,RES_bus))); init=0)
     # -
     # reduce(+, (p_ch_c[c,s,t,i] for i in findall(x->x==b,nd_Str_active) if ~isempty(findall(x->x==b,nd_Str_active))); init=0)
     # +
     # reduce(+, (p_dis_c[c,s,t,i] for i in findall(x->x==b,nd_Str_active) if ~isempty(findall(x->x==b,nd_Str_active))); init=0)
     +
     reduce(+, (Pg_neg_c[c,s,t,i] for i in findall(x->x==b,neg_gen_bus) if haskey(new_data, "negGen") && ~isempty(findall(x->x==b,neg_gen_bus))); init=0)


      # ==reduce(+, (pinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]] for j in 1:size(node_data_contin[c][b].node_num_c,1) if ~isempty(node_data_contin[c][b].node_num_c)); init=0)

    # +slack_pb_p_c[c,s,t,b]
    # -slack_pb_n_c[c,s,t,b]
      ==reduce(+, (pinj_dict_c[[c,s,t,b,j]] for j in node_data_contin[c][b].node_cnode_c if ~isempty(node_data_contin[c][b].node_num_c)); init=0)

      +
      # reduce(+, (pinj_dict_c[[c,s,t,b,node_data_trans[b,1].node_cnode[j]]] for j in 1:size(node_data_trans[b,1].node_num,1) if ~isempty(node_data_trans[b,1].node_num)); init=0)
      reduce(+, (pinj_dict_c[[c,s,t,b,j]] for j in node_data_trans[b,1].node_cnode if ~isempty(node_data_trans[b,1].node_num)); init=0)
      # sum(pinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]] for j in 1:size(node_data_contin[c][b].node_num_c,1) )
      +
      reduce(+, (prof_ploads[i,t]  for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)
      +
      reduce(+, (p_fl_inc_c[c,s,t,i] for i in findall(x->x==b,nd_fl) if ~isempty(findall(x->x==b,nd_fl))); init=0)
      -
      reduce(+, (p_fl_dec_c[c,s,t,i] for i in findall(x->x==b,nd_fl) if ~isempty(findall(x->x==b,nd_fl))); init=0)


          )

return active_power_balance_contin

end

# active_poewr_balance_normal=active_poewr_bal(0,model_name)

function reactive_power_bal_n(model_name,qinj_dict)


              reactive_power_balance_normal=@constraint(model_name, [ t in 1:nTP, b in 1:nBus],

               reduce(+, (Qg[t,i] for i in findall(x->x==b,bus_data_gsheet) if ~isempty(findall(x->x==b,bus_data_gsheet))); init=0)
               +
               reduce(+, (tan(acos(power_factor))*pen_lsh[t,i] for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)
                # ==reduce(+, (qinj_dict[[t,b,node_data[b].node_cnode[j]]] for j in 1:size(node_data[b].node_num,1) if ~isempty(node_data[b].node_num)); init=0)
                +
                reduce(+, (Qg_neg[t,i] for i in findall(x->x==b,neg_gen_bus) if haskey(new_data, "negGen") && ~isempty(findall(x->x==b,neg_gen_bus))); init=0)

        # +slack_rb_p[t,b]-slack_rb_n[t,b]
                ==reduce(+, (qinj_dict[[t,b,j]] for j in node_data[b].node_cnode if ~isempty(node_data[b].node_num)); init=0)

                +
                # reduce(+, (qinj_dict[[t,b,node_data_trans[b,1].node_cnode[j]]] for j in 1:size(node_data_trans[b,1].node_num,1) if ~isempty(node_data_trans[b,1].node_num)); init=0)
                reduce(+, (qinj_dict[[t,b,j]] for j in node_data_trans[b,1].node_cnode if ~isempty(node_data_trans[b,1].node_num)); init=0)

                # sum(qinj_dict[[t,b,node_data[b].node_cnode[j]]] for j in 1:size(node_data[b].node_num,1) )
                +
                reduce(+, (prof_qloads[i,t]  for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)

                -
                # reduce(+, (nw_shunts[i].shunt_bsh0*(e[t,b]^2+f[t,b]^2)  for i in findall(x->x==b,rdata_shunts[:,1]) if ~isempty(findall(x->x==b,rdata_shunts[:,1]))); init=0)
                reduce(+, (nw_shunts[i].shunt_bsh0  for i in findall(x->x==b,rdata_shunts[:,1]) if ~isempty(findall(x->x==b,rdata_shunts[:,1]))); init=0)

                +
                reduce(+, (q_fl_inc[t,i] for i in findall(x->x==b,nd_fl) if ~isempty(findall(x->x==b,nd_fl))); init=0)
                -
                reduce(+, (q_fl_dec[t,i] for i in findall(x->x==b,nd_fl) if ~isempty(findall(x->x==b,nd_fl))); init=0)

                    )

                    return reactive_power_balance_normal
end

function reactive_power_bal_c(model_name,qinj_dict_c)

          reactive_power_balance_contin=@constraint(model_name, [c in 1:nCont, s in 1:nSc, t in 1:nTP, b in 1:nBus],

           reduce(+, (Qg_c[c,s,t,i] for i in findall(x->x==b,bus_data_gsheet) if ~isempty(findall(x->x==b,bus_data_gsheet))); init=0)
           +
           reduce(+, (tan(acos(power_factor))*pen_lsh_c[c,s,t,i] for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)

            # ==reduce(+, (qinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]] for j in 1:size(node_data_contin[c][b].node_num_c,1) if ~isempty(node_data_contin[c][b].node_num_c)); init=0)
            +
            reduce(+, (Qg_neg_c[c,s,t,i] for i in findall(x->x==b,neg_gen_bus) if haskey(new_data, "negGen") && ~isempty(findall(x->x==b,neg_gen_bus))); init=0)
            # +slack_rb_p_c[c,s,t,b]-slack_rb_n_c[c,s,t,b]
            ==reduce(+, (qinj_dict_c[[c,s,t,b,j]] for j in node_data_contin[c][b].node_cnode_c if ~isempty(node_data_contin[c][b].node_num_c)); init=0)
            +
            # reduce(+, (qinj_dict_c[[c,s,t,b,node_data_trans[b,1].node_cnode[j]]] for j in 1:size(node_data_trans[b,1].node_num,1) if ~isempty(node_data_trans[b,1].node_num)); init=0)
            reduce(+, (qinj_dict_c[[c,s,t,b,j]] for j in node_data_trans[b,1].node_cnode if ~isempty(node_data_trans[b,1].node_num)); init=0)
            # sum(qinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]] for j in 1:size(node_data_contin[c][b].node_num_c,1) )
            +
            reduce(+, (prof_qloads[i,t]  for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)

            -
            # reduce(+, (nw_shunts[i].shunt_bsh0*(e_c[c,s,t,b]^2+f_c[c,s,t,b]^2)  for i in findall(x->x==b,rdata_shunts[:,1]) if ~isempty(findall(x->x==b,rdata_shunts[:,1]))); init=0)
            reduce(+, (nw_shunts[i].shunt_bsh0  for i in findall(x->x==b,rdata_shunts[:,1]) if ~isempty(findall(x->x==b,rdata_shunts[:,1]))); init=0)

            +
            reduce(+, (q_fl_inc_c[c,s,t,i] for i in findall(x->x==b,nd_fl) if ~isempty(findall(x->x==b,nd_fl))); init=0)
            -
            reduce(+, (q_fl_dec_c[c,s,t,i] for i in findall(x->x==b,nd_fl) if ~isempty(findall(x->x==b,nd_fl))); init=0)

                )
      return reactive_power_balance_contin


end

# reactive_poewr_balance_normal=reactive_poewr_bal(0,model_name)
function longitudinal_current_contin(model_name)
longit_contin=@constraint(model_name, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nBus,j=1:size(node_data_contin[c][i].node_cnode_c,1),
                      gij_line_c = node_data_contin[c][i].node_gij_sr_c[j],
                      bij_line_c = node_data_contin[c][i].node_bij_sr_c[j],
                      idx_cnode_c=node_data_contin[c][i].node_cnode_c[j]
                     ],

(gij_line_c^2+bij_line_c^2)*((e_c[c,s,t,i]-e_c[c,s,t,idx_cnode_c])^2 + (f_c[c,s,t,i]-f_c[c,s,t,idx_cnode_c])^2 )<=(node_data_contin[c][i].node_smax_c[j])^2
)
return longit_contin
end

function longitudinal_current_normal(model_name)
    gij_lin = real(yij_line)
    bij_lin = imag(yij_line)
    longit_normal=@constraints(model_name,
    begin
     [i=1:nLines,t=1:nTP,
     f_bus    = nw_lines[i].line_from,
     t_bus    = nw_lines[i].line_to,
     idx_f_bus = findall(x->x==f_bus,rdata_buses[:,1]),
     idx_t_bus = findall(x->x==t_bus,rdata_buses[:,1]),
     ],

    (gij_lin[i]^2+bij_lin[i]^2)*((e[t,idx_f_bus]-e[t,idx_t_bus])^2 + (f[t,idx_f_bus]-f[t,idx_t_bus])^2)<=(nw_lines[i].line_Smax_A)^2
    end
     )
    return longit_normal

end

function line_flow_n(model_name,pinj_dict,qinj_dict,full_indicator )

     line_flow_normal_s=@NLconstraint(model_name, [t in 1:nTP, l in 1:nLines],
 (pinj_dict[[t,idx_from_line[l],idx_to_line[l]]])^2+(qinj_dict[[t,idx_from_line[l],idx_to_line[l]]])^2<=(nw_lines[l].line_Smax_A)^2
                                         )

     line_flow_normal_trans_s=@NLconstraint(model_name, [t in 1:nTP, tr in 1:nTrans],
 (pinj_dict[[t,idx_from_trans[tr],idx_to_trans[tr]]])^2+(qinj_dict[[t,idx_from_trans[tr],idx_to_trans[tr]]])^2<=(nw_trans[tr].trans_Snom)^2
                                      )
          line_flow_normal_r=nothing
          line_flow_normal_trans_r=nothing
          if full_indicator=="full"
 line_flow_normal_r=@NLconstraint(model_name, [ t in 1:nTP, l in 1:nLines],
     (pinj_dict[[t,idx_to_line[l],idx_from_line[l]]])^2+(qinj_dict[[t,idx_to_line[l],idx_from_line[l]]])^2<=(nw_lines[l].line_Smax_A)^2
                                      )
 line_flow_normal_trans_r=@NLconstraint(model_name, [t in 1:nTP, tr in 1:nTrans],
 (pinj_dict[[t,idx_to_trans[tr],idx_from_trans[tr]]])^2+(qinj_dict[[t,idx_to_trans[tr],idx_from_trans[tr]]])^2<=(nw_trans[tr].trans_Snom)^2
                                      )

         end
return line_flow_normal_s,line_flow_normal_r,line_flow_normal_trans_s,line_flow_normal_trans_r

end

function line_flow_c(model_name,pinj_dict_c,qinj_dict_c,full_indicator )
    line_flow_contin_s=@NLconstraint(model_name, [c in 1:nCont, s in 1:nSc, t in 1:nTP, l in 1:length(idx_from_line_c[c])],
                # (pinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]])^2+(qinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]])^2<=(node_data_contin[c][b].node_smax_c[j])^2
                (pinj_dict_c[[c,s,t,idx_from_line_c[c][l],idx_to_line_c[c][l]]])^2+(qinj_dict_c[[c,s,t,idx_from_line_c[c][l],idx_to_line_c[c][l]]])^2<=(line_smax_c[c][l])^2
                )
    line_flow_contin_trans_s=@NLconstraint(model_name, [c in 1:nCont, s in 1:nSc, t in 1:nTP, tr in 1:nTrans],
(pinj_dict_c[[c,s,t,idx_from_trans[tr],idx_to_trans[tr]]])^2+(qinj_dict_c[[c,s,t,idx_from_trans[tr],idx_to_trans[tr]]])^2<=(nw_trans[tr].trans_Snom)^2
               )
                line_flow_contin_r=nothing
                line_flow_contin_trans_r=nothing
                if full_indicator=="full"
    line_flow_contin_r=@NLconstraint(model_name, [c in 1:nCont, s in 1:nSc, t in 1:nTP, l in 1:length(idx_from_line_c[c])],

                            # (pinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]])^2+(qinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]])^2<=(node_data_contin[c][b].node_smax_c[j])^2
                            (pinj_dict_c[[c,s,t,idx_to_line_c[c][l],idx_from_line_c[c][l]]])^2+(qinj_dict_c[[c,s,t,idx_to_line_c[c][l],idx_from_line_c[c][l]]])^2<=(line_smax_c[c][l])^2

                            )
    line_flow_contin_trans_r=@NLconstraint(model_name, [c in 1:nCont, s in 1:nSc, t in 1:nTP, tr in 1:nTrans],
(pinj_dict_c[[c,s,t,idx_to_trans[tr],idx_from_trans[tr]]])^2+(qinj_dict_c[[c,s,t,idx_to_trans[tr],idx_from_trans[tr]]])^2<=(nw_trans[tr].trans_Snom)^2
               )
                        end
return line_flow_contin_s,line_flow_contin_r,line_flow_contin_trans_s,line_flow_contin_trans_r

end

function coupling_constraint(model_name)
ramp_rate=2
coupling1=@constraint(model_name, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nGens],Pg_c[c,s,t,i]-Pg[t,i]<=ramp_rate)
coupling2=@constraint(model_name, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nGens],-ramp_rate<=Pg_c[c,s,t,i]-Pg[t,i])
# @constraint(model_name, [c=1:nCont,s=1:nSc,t=1:nTP,i=1:nGens],Pg_c[c,s,t,i]-Pg[t,i])
return coupling1,coupling2
end
function objective_SCOPF(model_name,OPF_opt)
     if OPF_opt==0
         cost_mod_fac=new_gen_cost
#         cost_gen=@expression(model_name,
#                     sum(
#                             cost_mod_fac*Pg[t,i]*Pg[t,i]*cost_a_gen[i]*(sbase^2)
#                             +
#                             cost_mod_fac*Pg[t,i]*cost_b_gen[i]*sbase
#                             +
#                             cost_mod_fac*cost_c_gen[i] for t in 1:nTP,i in 1:nGens )
# )

#### changed the constraint to make gencost a minimal value
    cost_gen=@expression(model_name, sum( cost_mod_fac*Pg[t,i]*sbase for t in 1:nTP,i in 1:nGens)  )
# penalty cost
penalty_cost=1e3 *sbase # update penalty cost with *sbase
cost_pen_lsh_aux=@expression(model_name,
                    [i=1:nBus ; ~isempty(findall(x->x==i,bus_data_lsheet)) ],
                    sum(cost_mod_fac*penalty_cost*(pen_lsh[t,findall(x->x==i,bus_data_lsheet)]) for t in 1:nTP)
                             )
               cost_pen_lsh=@expression(model_name,sum(cost_pen_lsh_aux))
# # -----Generation curtailment----
cost_pen_ws_aux=@expression(model_name,
                    [i=1:nBus; ~isempty(findall(x->x==i,RES_bus)) ],
                    sum(cost_mod_fac*penalty_cost*(pen_ws[t,findall(x->x==i,RES_bus)]) for t in 1:nTP)
                             )
               cost_pen_ws=@expression(model_name,if !isempty(prof_PRES) sum(cost_pen_ws_aux) end)
#
# # -------------penalty cost post contingency states------------
# # --------loadshedding cost-----
#
cost_pen_lsh_aux_c=@expression(model_name,
                   [i=1:nBus ; ~isempty(findall(x->x==i,bus_data_lsheet)) ],
                   sum(cost_mod_fac*penalty_cost*(pen_lsh_c[c,s,t,findall(x->x==i,bus_data_lsheet)]) for c in 1:nCont,s in 1:nSc,t in 1:nTP)
                             )
cost_pen_lsh_c=@expression(model_name,sum(cost_pen_lsh_aux_c))

#------penalties on active power balance ----------
# cost_penalty_aux_pb=@expression(acopf,
#                        [i=1:nBus ],
#                            sum(penalty_cost*(slack_pb_p[t,i]+slack_pb_n[t,i]) for s in 1:nSc,t in 1:nTP)
#                                                          )
#                                           cost_pen_pb=@expression(acopf,sum(cost_penalty_aux_pb))

# cost_penalty_aux_pb_c=@expression(acopf,     [c=1:nCont,i=1:nBus],
#                          # sum(penalty_cost*(slack_pb_p_c[c,s,t,i]+slack_pb_n_c[c,s,t,i]) for s in 1:nSc,t in 1:nTP)
#                          sum(penalty_cost*(slack_pb_n_c[c,s,t,i]) for s in 1:nSc,t in 1:nTP)
#              )
# cost_pen_pb_c=@expression(acopf,sum(cost_penalty_aux_pb_c))
#------penalties on reactive power balance ----------
# cost_penalty_aux_rb=@expression(acopf,
#                        [i=1:nBus ],
#                            sum(penalty_cost*(slack_rb_p[t,i]+slack_rb_n[t,i]) for s in 1:nSc,t in 1:nTP)
#                                                          )
#                                           cost_pen_rb=@expression(acopf,sum(cost_penalty_aux_rb))
# #
# cost_penalty_aux_rb_c=@expression(acopf,     [c=1:nCont,i=1:nBus],
#                          sum(penalty_cost*(slack_rb_p_c[c,s,t,i]+slack_rb_n_c[c,s,t,i]) for s in 1:nSc,t in 1:nTP)
#              )
# cost_pen_rb_c=@expression(acopf,sum(cost_penalty_aux_rb_c))

# cost_penalty=@expression(acopf,
#                                  [i=1:nBus ; ~isempty(node_data[i,1].node_num)],
#                                  sum(penalty_cost*(slack[t,i,node_data[i,1].node_cnode[j,1][1]]) for s in 1:nSc,t in 1:nTP, j in 1:size(node_data[i,1].node_num,1))
#                                            )
#                             cost_pen_c=@expression(acopf,sum(cost_penalty))
# # ------ Generation curtailment----
cost_pen_ws_aux_c=@expression(model_name,
                   [i=1:nBus; ~isempty(findall(x->x==i,RES_bus)) ],
                   sum(cost_mod_fac*penalty_cost*(pen_ws_c[c,s,t,findall(x->x==i,RES_bus)]) for c in 1:nCont, s in 1:nSc,t in 1:nTP)
                             )
              cost_pen_ws_c=@expression(model_name,if !isempty(prof_PRES) sum(cost_pen_ws_aux_c) end)

#
# # --------Flexible load cost normal state-------
cost_fl_aux=@expression(model_name,
                   [i=1:nBus, idx_flex=findall(x->x==i,nd_fl); ~isempty(findall(x->x==i,nd_fl)) ],
                   sum(
                   cost_mod_fac*cost_flex_load[idx_flex]*sbase
                   *
                   (p_fl_inc[t,findall(x->x==i,nd_fl)]+p_fl_dec[t,findall(x->x==i,nd_fl)]) for t in 1:nTP)
                   )
            cost_fl=@expression(model_name,if nFl!=0 sum(cost_fl_aux) end)
cost_fl_aux_q=@expression(model_name,
                               [i=1:nBus, idx_flex=findall(x->x==i,nd_fl); ~isempty(findall(x->x==i,nd_fl)) ],
                               sum(
                               cost_mod_fac*cost_flex_load[idx_flex]*sbase
                               *
                               (q_fl_inc[t,findall(x->x==i,nd_fl)]+q_fl_dec[t,findall(x->x==i,nd_fl)]) for t in 1:nTP)
                               )
                        cost_fl_q=@expression(model_name,if nFl!=0 sum(cost_fl_aux_q) end)





# # --------Flexible load cost post contingency state-------
cost_fl_aux_c=@expression(model_name,
                   [c=1:nCont, i=1:nBus, idx_flex=findall(x->x==i,nd_fl); ~isempty(findall(x->x==i,nd_fl)) ],
                   sum(
                   cost_mod_fac*cost_flex_load[idx_flex]*sbase
                   *
                   (p_fl_inc_c[c,s,t,findall(x->x==i,nd_fl)]+p_fl_dec_c[c,s,t,findall(x->x==i,nd_fl)]) for s in 1:nSc,t in 1:nTP)
                          )
             cost_fl_c  =@expression(model_name,if nFl!=0 sum(cost_fl_aux_c) end)

cost_fl_aux_c_q=@expression(model_name,
                                [c=1:nCont, i=1:nBus, idx_flex=findall(x->x==i,nd_fl); ~isempty(findall(x->x==i,nd_fl)) ],
                                sum(
                                cost_mod_fac*cost_flex_load[idx_flex]*sbase
                                *
                                (q_fl_inc_c[c,s,t,findall(x->x==i,nd_fl)]+q_fl_dec_c[c,s,t,findall(x->x==i,nd_fl)]) for s in 1:nSc,t in 1:nTP)
                                       )
                          cost_fl_c_q  =@expression(model_name,if nFl!=0 sum(cost_fl_aux_c_q) end)

#
# # ----------storage cost normal state-------
cost_str_aux=@expression(model_name,
                       [i=1:nBus, idx_str=findall(x->x==i,nd_Str_active); ~isempty(findall(x->x==i,nd_Str_active)) ],
                       sum(
                       cost_mod_fac*cost_b_str[idx_str]*(sbase)*( p_ch[t,idx_str]+p_dis[t,idx_str])
                       for t in 1:nTP)
                          )
             cost_str  =@expression(model_name,if nStr_active!=0 sum(cost_str_aux) end )
# # ----------storage cost post contingency state-----
cost_str_aux_c=@expression(model_name,
                       [c=1:nCont,i=1:nBus, idx_str=findall(x->x==i,nd_Str_active); ~isempty(findall(x->x==i,nd_Str_active)) ],
                       sum(
                       cost_mod_fac*cost_b_str[idx_str]*(sbase)*( p_ch_c[c,s,t,idx_str]+p_dis_c[c,s,t,idx_str])
                       for s in 1:nSc,t in 1:nTP)
                          )
             cost_str_c  =@expression(model_name,if nStr_active!=0 sum(cost_str_aux_c) end)
#
cost_gen_neg_aux=@expression(model_name, [ t in 1:nTP, b in 1:nBus],
reduce(+, (cost_mod_fac*Pg_neg[t,i]*new_data["negGen"][i][7]*sbase for i in findall(x->x==b,neg_gen_bus) if haskey(new_data, "negGen") && ~isempty(findall(x->x==b,neg_gen_bus))); init=0)
)

cost_gen_neg  =@expression(model_name,if haskey(new_data, "negGen") sum(cost_gen_neg_aux) end)

cost_gen_neg_aux_c=@expression(model_name, [c in 1:nCont, s in 1:nSc, t in 1:nTP, b in 1:nBus],
reduce(+, (cost_mod_fac*Pg_neg_c[c,s,t,i]*new_data["negGen"][i][7]*sbase for i in findall(x->x==b,neg_gen_bus) if haskey(new_data, "negGen") && ~isempty(findall(x->x==b,neg_gen_bus))); init=0)
                    )
                    cost_gen_neg_c  =@expression(model_name,if haskey(new_data, "negGen") sum(cost_gen_neg_aux_c) end)

# ------------------------------------------------
total_cost=@expression(model_name,
               # (
               0.95*
               (cost_gen
               +sum(cost_pen_lsh)
               # +cost_pen_pb
               # +cost_pen_rb
               # +cost_pen_c
               +sum((if !isnothing(cost_fl) cost_fl else 0 end))
               +sum((if !isnothing(cost_fl_q) cost_fl_q else 0 end))
               +sum((if !isnothing(cost_str) cost_str else 0 end))

               +sum((if !isnothing(cost_pen_ws) cost_pen_ws else 0 end))
               +sum((if !isnothing(cost_gen_neg) cost_gen_neg else 0 end))
               )
               +
               0.05*(
               sum(cost_pen_lsh_c)
               # +cost_pen_pb_c
               # +cost_pen_rb_c
               # +sum(cost_pen_ws_c)
               +sum((if !isnothing(cost_fl_c) cost_fl_c else 0 end))
               +sum((if !isnothing(cost_fl_c_q) cost_fl_c_q else 0 end))
               +sum((if !isnothing(cost_str_c) cost_str_c else 0 end))
              +sum((if !isnothing(cost_pen_ws_c) cost_pen_ws_c else 0 end))
              +sum((if !isnothing(cost_gen_neg_c) cost_gen_neg_c else 0 end))
               # )
                 )
                   )
@objective(model_name,Min,total_cost)
return total_cost,cost_gen,cost_pen_lsh,cost_fl,cost_str,cost_pen_ws,cost_pen_lsh_c,cost_pen_ws_c,cost_fl_c,cost_str_c
elseif OPF_opt==1
    cost_gen=@expression(model_name,
                sum(
                        Pg[t,i]*Pg[t,i]*cost_a_gen[i]*(sbase^2)
                        +
                        Pg[t,i]*cost_b_gen[i]*sbase
                        +
                        cost_c_gen[i] for t in 1:nTP,i in 1:nGens )
)
#
penalty_cost=1e3 *sbase # update penalty cost with *sbase
cost_pen_lsh_aux=@expression(model_name,
                [i=1:nBus ; ~isempty(findall(x->x==i,bus_data_lsheet)) ],
                sum(penalty_cost*(pen_lsh[t,findall(x->x==i,bus_data_lsheet)]) for t in 1:nTP)
                         )
           cost_pen_lsh=@expression(model_name,sum(cost_pen_lsh_aux)) # update penalty cost with *sbase
# # -----Generation curtailment----
cost_pen_ws_aux=@expression(model_name,
                [i=1:nBus; ~isempty(findall(x->x==i,RES_bus)) ],
                sum(penalty_cost*(pen_ws[t,findall(x->x==i,RES_bus)]) for t in 1:nTP)
                         )
           cost_pen_ws=@expression(model_name,if !isempty(prof_PRES) sum(cost_pen_ws_aux) end)
#
# # -------------penalty cost post contingency states------------
# # --------loadshedding cost-----
#
# cost_pen_lsh_aux_c=@expression(model_name,
#                [i=1:nBus ; ~isempty(findall(x->x==i,bus_data_lsheet)) ],
#                sum(penalty_cost*(pen_lsh_c[c,s,t,findall(x->x==i,bus_data_lsheet)]) for c in 1:nCont,s in 1:nSc,t in 1:nTP)
#                          )
# cost_pen_lsh_c=@expression(model_name,sum(cost_pen_lsh_aux_c))

#------penalties on active power balance ----------
# cost_penalty_aux_pb=@expression(acopf,
#                        [i=1:nBus ],
#                            sum(penalty_cost*(slack_pb_p[t,i]+slack_pb_n[t,i]) for s in 1:nSc,t in 1:nTP)
#                                                          )
#                                           cost_pen_pb=@expression(acopf,sum(cost_penalty_aux_pb))

# cost_penalty_aux_pb_c=@expression(acopf,     [c=1:nCont,i=1:nBus],
#                          # sum(penalty_cost*(slack_pb_p_c[c,s,t,i]+slack_pb_n_c[c,s,t,i]) for s in 1:nSc,t in 1:nTP)
#                          sum(penalty_cost*(slack_pb_n_c[c,s,t,i]) for s in 1:nSc,t in 1:nTP)
#              )
# cost_pen_pb_c=@expression(acopf,sum(cost_penalty_aux_pb_c))
#------penalties on reactive power balance ----------
# cost_penalty_aux_rb=@expression(acopf,
#                        [i=1:nBus ],
#                            sum(penalty_cost*(slack_rb_p[t,i]+slack_rb_n[t,i]) for s in 1:nSc,t in 1:nTP)
#                                                          )
#                                           cost_pen_rb=@expression(acopf,sum(cost_penalty_aux_rb))
# #
# cost_penalty_aux_rb_c=@expression(acopf,     [c=1:nCont,i=1:nBus],
#                          sum(penalty_cost*(slack_rb_p_c[c,s,t,i]+slack_rb_n_c[c,s,t,i]) for s in 1:nSc,t in 1:nTP)
#              )
# cost_pen_rb_c=@expression(acopf,sum(cost_penalty_aux_rb_c))

# cost_penalty=@expression(acopf,
#                                  [i=1:nBus ; ~isempty(node_data[i,1].node_num)],
#                                  sum(penalty_cost*(slack[t,i,node_data[i,1].node_cnode[j,1][1]]) for s in 1:nSc,t in 1:nTP, j in 1:size(node_data[i,1].node_num,1))
#                                            )
#                             cost_pen_c=@expression(acopf,sum(cost_penalty))
# # ------ Generation curtailment----
# cost_pen_ws_aux_c=@expression(model_name,
#                [i=1:nBus; ~isempty(findall(x->x==i,RES_bus)) ],
#                sum(penalty_cost*(pen_ws_c[c,s,t,findall(x->x==i,RES_bus)]) for c in 1:nCont, s in 1:nSc,t in 1:nTP)
#                          )
#           cost_pen_ws_c=@expression(model_name,if !isempty(prof_PRES) sum(cost_pen_ws_aux_c) end)

#
# # --------Flexible load cost normal state-------
cost_fl_aux=@expression(model_name,
               [i=1:nBus, idx_flex=findall(x->x==i,nd_fl); ~isempty(findall(x->x==i,nd_fl)) ],
               sum(
               cost_flex_load[idx_flex]*sbase
               *
               (p_fl_inc[t,findall(x->x==i,nd_fl)]+p_fl_dec[t,findall(x->x==i,nd_fl)]) for t in 1:nTP)
               )
        cost_fl=@expression(model_name,if nFl!=0 sum(cost_fl_aux) end)
cost_fl_aux_q=@expression(model_name,
                           [i=1:nBus, idx_flex=findall(x->x==i,nd_fl); ~isempty(findall(x->x==i,nd_fl)) ],
                           sum(
                           cost_flex_load[idx_flex]*sbase
                           *
                           (q_fl_inc[t,findall(x->x==i,nd_fl)]+q_fl_dec[t,findall(x->x==i,nd_fl)]) for t in 1:nTP)
                           )
                    cost_fl_q=@expression(model_name,if nFl!=0 sum(cost_fl_aux_q) end)





# # --------Flexible load cost post contingency state-------
# cost_fl_aux_c=@expression(model_name,
#                [c=1:nCont, i=1:nBus, idx_flex=findall(x->x==i,nd_fl); ~isempty(findall(x->x==i,nd_fl)) ],
#                sum(
#                cost_flex_load[idx_flex]*sbase
#                *
#                (p_fl_inc_c[c,s,t,findall(x->x==i,nd_fl)]+p_fl_dec_c[c,s,t,findall(x->x==i,nd_fl)]) for s in 1:nSc,t in 1:nTP)
#                       )
#          cost_fl_c  =@expression(model_name,if nFl!=0 sum(cost_fl_aux_c) end)
#
# cost_fl_aux_c_q=@expression(model_name,
#                             [c=1:nCont, i=1:nBus, idx_flex=findall(x->x==i,nd_fl); ~isempty(findall(x->x==i,nd_fl)) ],
#                             sum(
#                             cost_flex_load[idx_flex]*sbase
#                             *
#                             (q_fl_inc_c[c,s,t,findall(x->x==i,nd_fl)]+q_fl_dec_c[c,s,t,findall(x->x==i,nd_fl)]) for s in 1:nSc,t in 1:nTP)
#                                    )
#                       cost_fl_c_q  =@expression(model_name,if nFl!=0 sum(cost_fl_aux_c_q) end)

#
# # ----------storage cost normal state-------
cost_str_aux=@expression(model_name,
                   [i=1:nBus, idx_str=findall(x->x==i,nd_Str_active); ~isempty(findall(x->x==i,nd_Str_active)) ],
                   sum(
                   cost_b_str[idx_str]*(sbase)*( p_ch[t,idx_str]+p_dis[t,idx_str])
                   for t in 1:nTP)
                      )
         cost_str  =@expression(model_name,if nStr_active!=0 sum(cost_str_aux) end )
# # ----------storage cost post contingency state-----
# cost_str_aux_c=@expression(model_name,
#                    [c=1:nCont,i=1:nBus, idx_str=findall(x->x==i,nd_Str_active); ~isempty(findall(x->x==i,nd_Str_active)) ],
#                    sum(
#                    cost_b_str[idx_str]*(sbase)*( p_ch_c[c,s,t,idx_str]+p_dis_c[c,s,t,idx_str])
#                    for s in 1:nSc,t in 1:nTP)
#                       )
#          cost_str_c  =@expression(model_name,if nStr_active!=0 sum(cost_str_aux_c) end)
# #
cost_gen_neg_aux=@expression(model_name, [ t in 1:nTP, b in 1:nBus],
reduce(+, (Pg_neg[t,i]*new_data["negGen"][i][7]*sbase for i in findall(x->x==b,neg_gen_bus) if haskey(new_data, "negGen") && ~isempty(findall(x->x==b,neg_gen_bus))); init=0)
)

cost_gen_neg  =@expression(model_name,if haskey(new_data, "negGen") sum(cost_gen_neg_aux) end)

# cost_gen_neg_aux_c=@expression(model_name, [c in 1:nCont, s in 1:nSc, t in 1:nTP, b in 1:nBus],
# reduce(+, (Pg_neg_c[c,s,t,i]*new_data["negGen"][i][7]*sbase for i in findall(x->x==b,neg_gen_bus) if haskey(new_data, "negGen") && ~isempty(findall(x->x==b,neg_gen_bus))); init=0)
#                 )
#                 cost_gen_neg_c  =@expression(model_name,if haskey(new_data, "negGen") sum(cost_gen_neg_aux_c) end)

# ------------------------------------------------
total_cost=@expression(model_name,
           # (

           (cost_gen
           +sum(cost_pen_lsh)
           # +cost_pen_pb
           # +cost_pen_rb
           # +cost_pen_c
           +sum((if !isnothing(cost_fl) cost_fl else 0 end))
           +sum((if !isnothing(cost_fl_q) cost_fl_q else 0 end))
           +sum((if !isnothing(cost_str) cost_str else 0 end))

           +sum((if !isnothing(cost_pen_ws) cost_pen_ws else 0 end))
           +sum((if !isnothing(cost_gen_neg) cost_gen_neg else 0 end))
           )
          #  +
          #  0.05*(1/nSc)*(
          #  sum(cost_pen_lsh_c)
          #  # +cost_pen_pb_c
          #  # +cost_pen_rb_c
          #  # +sum(cost_pen_ws_c)
          #  +sum((if !isnothing(cost_fl_c) cost_fl_c else 0 end))
          #  +sum((if !isnothing(cost_fl_c_q) cost_fl_c_q else 0 end))
          #  +sum((if !isnothing(cost_str_c) cost_str_c else 0 end))
          # +sum((if !isnothing(cost_pen_ws_c) cost_pen_ws_c else 0 end))
          # +sum((if !isnothing(cost_gen_neg_c) cost_gen_neg_c else 0 end))
          #  # )
          #    )
               )
@objective(model_name,Min,total_cost)
return total_cost,cost_gen,cost_pen_lsh,cost_fl,cost_str,cost_pen_ws#,cost_pen_lsh_c,cost_pen_ws_c,cost_fl_c,cost_str_c

end

end


function objective_OPF(model_name)

        cost_gen=@expression(model_name,
                    sum(
                            Pg[t,i]*Pg[t,i]*cost_a_gen[i]*(sbase^2)
                            +
                            Pg[t,i]*cost_b_gen[i]*sbase
                            +
                            cost_c_gen[i] for t in 1:nTP,i in 1:nGens )
)
#
penalty_cost=1e3 *sbase
cost_pen_lsh_aux=@expression(model_name,
                    [i=1:nBus ; ~isempty(findall(x->x==i,bus_data_lsheet)) ],
                    sum(penalty_cost*(pen_lsh[t,findall(x->x==i,bus_data_lsheet)]) for t in 1:nTP)
                             )
               cost_pen_lsh=@expression(model_name,sum(cost_pen_lsh_aux))
# # -----Generation curtailment----
cost_pen_ws_aux=@expression(model_name,
                    [i=1:nBus; ~isempty(findall(x->x==i,RES_bus)) ],
                    sum(penalty_cost*(pen_ws[t,findall(x->x==i,RES_bus)]) for t in 1:nTP)
                             )
               cost_pen_ws=@expression(model_name,sum(cost_pen_ws_aux))
#
# # -------------penalty cost post contingency states------------
# # --------loadshedding cost-----
#
# cost_pen_lsh_aux_c=@expression(model_name,
#                    [i=1:nBus ; ~isempty(findall(x->x==i,bus_data_lsheet)) ],
#                    sum(penalty_cost*(pen_lsh_c[c,s,t,findall(x->x==i,bus_data_lsheet)]) for c in 1:nCont,s in 1:nSc,t in 1:nTP)
#                              )
# cost_pen_lsh_c=@expression(model_name,sum(cost_pen_lsh_aux_c))

#------penalties on active power balance ----------
# cost_penalty_aux_pb=@expression(acopf,
#                        [i=1:nBus ],
#                            sum(penalty_cost*(slack_pb_p[t,i]+slack_pb_n[t,i]) for s in 1:nSc,t in 1:nTP)
#                                                          )
#                                           cost_pen_pb=@expression(acopf,sum(cost_penalty_aux_pb))

# cost_penalty_aux_pb_c=@expression(acopf,     [c=1:nCont,i=1:nBus],
#                          # sum(penalty_cost*(slack_pb_p_c[c,s,t,i]+slack_pb_n_c[c,s,t,i]) for s in 1:nSc,t in 1:nTP)
#                          sum(penalty_cost*(slack_pb_n_c[c,s,t,i]) for s in 1:nSc,t in 1:nTP)
#              )
# cost_pen_pb_c=@expression(acopf,sum(cost_penalty_aux_pb_c))
#------penalties on reactive power balance ----------
# cost_penalty_aux_rb=@expression(acopf,
#                        [i=1:nBus ],
#                            sum(penalty_cost*(slack_rb_p[t,i]+slack_rb_n[t,i]) for s in 1:nSc,t in 1:nTP)
#                                                          )
#                                           cost_pen_rb=@expression(acopf,sum(cost_penalty_aux_rb))
# #
# cost_penalty_aux_rb_c=@expression(acopf,     [c=1:nCont,i=1:nBus],
#                          sum(penalty_cost*(slack_rb_p_c[c,s,t,i]+slack_rb_n_c[c,s,t,i]) for s in 1:nSc,t in 1:nTP)
#              )
# cost_pen_rb_c=@expression(acopf,sum(cost_penalty_aux_rb_c))

# cost_penalty=@expression(acopf,
#                                  [i=1:nBus ; ~isempty(node_data[i,1].node_num)],
#                                  sum(penalty_cost*(slack[t,i,node_data[i,1].node_cnode[j,1][1]]) for s in 1:nSc,t in 1:nTP, j in 1:size(node_data[i,1].node_num,1))
#                                            )
#                             cost_pen_c=@expression(acopf,sum(cost_penalty))
# # ------ Generation curtailment----
# cost_pen_ws_aux_c=@expression(model_name,
#                    [i=1:nBus; ~isempty(findall(x->x==i,RES_bus)) ],
#                    sum(penalty_cost*(pen_ws_c[c,s,t,findall(x->x==i,RES_bus)]) for c in 1:nCont, s in 1:nSc,t in 1:nTP)
#                              )
#               cost_pen_ws_c=@expression(model_name,sum(cost_pen_ws_aux_c))

#
# # --------Flexible load cost normal state-------
cost_fl_aux=@expression(model_name,
                   [i=1:nBus, idx_flex=findall(x->x==i,nd_fl); ~isempty(findall(x->x==i,nd_fl)) ],
                   sum(
                   cost_flex_load[idx_flex]*sbase
                   *
                   (p_fl_inc[t,findall(x->x==i,nd_fl)]+p_fl_dec[t,findall(x->x==i,nd_fl)]) for t in 1:nTP)
                   )
            cost_fl=@expression(model_name,if nFl!=0 sum(cost_fl_aux) end )
# # --------Flexible load cost post contingency state-------
# cost_fl_aux_c=@expression(acopf,
#                    [c=1:nCont, i=1:nBus, idx_flex=findall(x->x==i,nd_fl); ~isempty(findall(x->x==i,nd_fl)) ],
#                    sum(
#                    cost_flex_load[idx_flex]*sbase
#                    *
#                    (p_fl_inc_c[c,s,t,findall(x->x==i,nd_fl)]+p_fl_dec_c[c,s,t,findall(x->x==i,nd_fl)]) for s in 1:nSc,t in 1:nTP)
#                           )
#              cost_fl_c  =@expression(acopf,sum(cost_fl_aux_c))
#
# # ----------storage cost normal state-------
cost_str_aux=@expression(model_name,
                       [i=1:nBus, idx_str=findall(x->x==i,nd_Str_active); ~isempty(findall(x->x==i,nd_Str_active)) ],
                       sum(
                       cost_b_str[idx_str]*(sbase)*( p_ch[t,idx_str]+p_dis[t,idx_str])
                       for t in 1:nTP)
                          )
             cost_str  =@expression(model_name,if nStr_active!=0 sum(cost_str_aux) end )
# # ----------storage cost post contingency state-----
# cost_str_aux_c=@expression(acopf,
#                        [c=1:nCont,i=1:nBus, idx_str=findall(x->x==i,nd_Str_active); ~isempty(findall(x->x==i,nd_Str_active)) ],
#                        sum(
#                        cost_b_str[idx_str]*(sbase)*( p_ch_c[c,s,t,idx_str]+p_dis_c[c,s,t,idx_str])
#                        for s in 1:nSc,t in 1:nTP)
#                           )
#              cost_str_c  =@expression(acopf,sum(cost_str_aux_c))
#

# ------------------------------------------------
total_cost=@expression(model_name,
               # (

               (cost_gen
               +sum(cost_pen_lsh)
               # +cost_pen_pb
               # +cost_pen_rb
               # +cost_pen_c
               +sum((if !isnothing(cost_fl) cost_fl else 0 end))
               +sum((if !isnothing(cost_str) cost_str else 0 end))

               +sum(cost_pen_ws)
               )
               # +
               # 0.05*(
               # sum(cost_pen_lsh_c)
               # # +cost_pen_pb_c
               # # +cost_pen_rb_c
               # +sum(cost_pen_ws_c)
               # # +sum(cost_fl_c)
               # # +sum(cost_str_c)
               # # )
               #   )
                   )
@objective(model_name,Min,total_cost)
return total_cost,cost_gen,cost_pen_lsh,cost_fl,cost_str, cost_pen_ws
end

function dualizing_non_linear()
dual_normal=JuMP.dual.(line_flow_normal_s)
dual_normal=round.(dual_normal, digits=3)
bounded_line_flow_normal=findall(x->x!=0, dual_normal)
bounded_line_dual_val=Dict()
for i in bounded_line_flow_normal
    push!(bounded_line_dual_val, i=>dual_normal[i])
end

dual_contin=JuMP.dual.(line_flow_contin_s)
dual_contin=round.(dual_contin, digits=1)
# bounded_line_flow_normal=findall(x->x!=0, dual_contin)
bounded_line_dual_val_contin=Dict()
for i in eachindex(dual_contin)
    if dual_contin[i]!=0.0
    push!(bounded_line_dual_val_contin, i=>dual_contin[i])
end
end
return bounded_line_dual_val, bounded_line_dual_val_contin
end


function SP_SCOPF_or_MP_OPF(model_indicator)
    if model_indicator==0

    # nTP=1

    AC_SCOPF = Model(Ipopt.Optimizer, add_bridges=false)

    model_name=AC_SCOPF
    # set_optimizer_attributes(model_name,"mu_strategy"=>"adaptive")
    set_optimizer_attributes(model_name,"tol"=>1e-05)
    set_optimizer_attributes(model_name,"mumps_mem_percent"=>100)
    # set_optimizer_attributes(acopf,"barrier_tol_factor"=>1e-6)
    show(now() )
    println("")
    show("Model starts now")
    (e, f, Pg, Qg, pen_ws, pen_lsh, p_fl_inc, p_fl_dec,q_fl_inc,q_fl_dec, p_ch, p_dis, soc,Pg_neg,Qg_neg)                      =variables_n(model_name)
    (e_c, f_c, Pg_c, Qg_c, pen_ws_c, pen_lsh_c, p_fl_inc_c ,p_fl_dec_c, q_fl_inc_c ,q_fl_dec_c,p_ch_c, p_dis_c, soc_c,Pg_neg_c,Qg_neg_c)=variables_c(model_name)

   global e=e
   global f=f
   global Pg=Pg
   global Qg=Qg
   global pen_ws=pen_ws
   global pen_lsh=pen_lsh
   global p_fl_inc=p_fl_inc
   global p_fl_dec=p_fl_dec
   global q_fl_inc=q_fl_inc
   global q_fl_dec=q_fl_dec
   global p_ch=p_ch
   global p_dis=p_dis
   global soc=soc
   global Pg_neg=Pg_neg
   global Qg_neg=Qg_neg


   global  e_c=e_c
   global  f_c=f_c
   global  Pg_c=Pg_c
   global  Qg_c=Qg_c
   global  pen_ws_c=pen_ws_c
   global  pen_lsh_c=pen_lsh_c
   global  p_fl_inc_c=p_fl_inc_c
   global  p_fl_dec_c=p_fl_dec_c
   global  q_fl_inc_c=q_fl_inc_c
   global  q_fl_dec_c=q_fl_dec_c
   global  p_ch_c=p_ch_c
   global  p_dis_c=p_dis_c
   global  soc_c=soc_c
   global  Pg_neg_c=Pg_neg_c
   global  Qg_neg_c=Qg_neg_c

    show(now())
    println("")
    show("variables are generated")

    (vol_const_nr)=voltage_cons_n(model_name,"range")
    (vol_const_cn)=voltage_cons_c(model_name,"range")
    gen_limits_n(model_name,"range")
    gen_limits_c(model_name,"range")

    FL_cons_normal(model_name)
    FL_cons_contin(model_name)

    storage_cons_normal(model_name)
    storage_cons_contin(model_name)
    show(now())
    println("")
    show("volt+gnelim+fl+str are generated")
    (pinj_dict,qinj_dict)        =line_expression_n(model_name)
    show(now())
    println("")
    show("line expr normal")
    (pinj_dict_c,qinj_dict_c)=   line_expression_c(model_name)
    show(now())
    println("")
    show("line expr contin")
    (active_power_balance_normal)=active_power_bal_n(model_name,pinj_dict)
    show(now())
    println("")
    show("power bal norm")
    (active_power_balance_contin)=active_power_bal_c(model_name,pinj_dict_c)
    show(now())
    println("")
    show("power bal contin")
    (reactive_power_balance_normal)=reactive_power_bal_n(model_name,qinj_dict)
    show(now())
    println("")
    show("react power bal normal")
    (reactive_power_balance_contin)=reactive_power_bal_c(model_name,qinj_dict_c)
    show(now())
    println("")
    show("react power bal contin")
    (line_flow_normal_s,line_flow_normal_r,line_flow_normal_trans_s,line_flow_normal_trans_r)=line_flow_n(model_name,pinj_dict,qinj_dict,"full" )# "full"
    (line_flow_contin_s,line_flow_contin_r,line_flow_contin_trans_s,line_flow_contin_trans_r)=line_flow_c(model_name,pinj_dict_c,qinj_dict_c,"full" )# "full"
    show(now())
    println("")
    show("line flow all")
    # longitudinal_current_normal(model_name)
    # longitudinal_current_contin(model_name)

    coupling_constraint(model_name)

    (total_cost,cost_gen,cost_pen_lsh,cost_fl,cost_str,cost_pen_ws,cost_pen_lsh_c,cost_pen_ws_c,cost_fl_c,cost_str_c)=objective_SCOPF(model_name,model_indicator )

    show(now())
    println("")
    show("coupling+obj and Optimizer starts ")

    optimize!(model_name)
    show(now())
    println("")
    show("optimizer finished")
    println("Objective value", JuMP.objective_value(model_name))
    println("Solver Time ", JuMP.solve_time(model_name))

   output=Dict(
   :pinj_dict=>pinj_dict,
   :qinj_dict=>qinj_dict,
   :pinj_dict_c=>pinj_dict_c,
   :qinj_dict_c=>qinj_dict_c,
   :active_power_balance_normal=>active_power_balance_normal,
   :active_power_balance_contin=>active_power_balance_contin,
   :reactive_power_balance_normal=>reactive_power_balance_normal,
   :reactive_power_balance_contin=>reactive_power_balance_contin,
   :line_flow_normal_s=>line_flow_normal_s,
   :line_flow_normal_r=>line_flow_normal_r,
   :line_flow_normal_trans_s=>line_flow_normal_trans_s,
   :line_flow_normal_trans_r=>line_flow_normal_trans_r,
   :line_flow_contin_s=>line_flow_contin_s,
   :line_flow_contin_r=>line_flow_contin_r,
   :line_flow_contin_trans_s=>line_flow_contin_trans_s,
   :line_flow_contin_trans_r=>line_flow_contin_trans_r,
   :total_cost=>total_cost,
   :cost_gen=>cost_gen,
   :cost_pen_lsh=>cost_pen_lsh,
   :cost_fl=>cost_fl,
   :cost_str=>cost_str,
   :cost_pen_ws=>cost_pen_ws,
   :cost_pen_lsh_c=>cost_pen_lsh_c,
   :cost_pen_ws_c=>cost_pen_ws_c,
   :cost_fl_c=>cost_fl_c,
   :cost_str_c=>cost_str_c,
   )
return model_name, output
elseif  model_indicator==1

        # nTP=1

        AC_OPF = Model(Ipopt.Optimizer, add_bridges=false)

        model_name=AC_OPF
        # set_optimizer_attributes(model_name,"mu_strategy"=>"adaptive")
        set_optimizer_attributes(model_name,"tol"=>1e-05)
        set_optimizer_attributes(model_name,"mumps_mem_percent"=>100)
        # set_optimizer_attributes(acopf,"barrier_tol_factor"=>1e-6)
        show(now() )
        println("")
        show("Model starts now")
        (e, f, Pg, Qg, pen_ws, pen_lsh, p_fl_inc, p_fl_dec,q_fl_inc,q_fl_dec, p_ch, p_dis, soc,Pg_neg,Qg_neg)                      =variables_n(model_name)
        # (e_c, f_c, Pg_c, Qg_c, pen_ws_c, pen_lsh_c, p_fl_inc_c ,p_fl_dec_c, q_fl_inc_c ,q_fl_dec_c,p_ch_c, p_dis_c, soc_c,Pg_neg_c,Qg_neg_c)=variables_c(model_name)

       global e=e
       global f=f
       global Pg=Pg
       global Qg=Qg
       global pen_ws=pen_ws
       global pen_lsh=pen_lsh
       global p_fl_inc=p_fl_inc
       global p_fl_dec=p_fl_dec
       global q_fl_inc=q_fl_inc
       global q_fl_dec=q_fl_dec
       global p_ch=p_ch
       global p_dis=p_dis
       global soc=soc
       global Pg_neg=Pg_neg
       global Qg_neg=Qg_neg


       # global  e_c=e_c
       # global  f_c=f_c
       # global  Pg_c=Pg_c
       # global  Qg_c=Qg_c
       # global  pen_ws_c=pen_ws_c
       # global  pen_lsh_c=pen_lsh_c
       # global  p_fl_inc_c=p_fl_inc_c
       # global  p_fl_dec_c=p_fl_dec_c
       # global  q_fl_inc_c=q_fl_inc_c
       # global  q_fl_dec_c=q_fl_dec_c
       # global  p_ch_c=p_ch_c
       # global  p_dis_c=p_dis_c
       # global  soc_c=soc_c
       # global  Pg_neg_c=Pg_neg_c
       # global  Qg_neg_c=Qg_neg_c

        show(now())
        println("")
        show("variables are generated")

        (vol_const_nr)=voltage_cons_n(model_name,"range")
        # (vol_const_cn)=voltage_cons_c(model_name,"range")
        gen_limits_n(model_name,"range")
        # gen_limits_c(model_name,"range")

        FL_cons_normal(model_name)
        # FL_cons_contin(model_name)

        storage_cons_normal(model_name)
        # storage_cons_contin(model_name)
        show(now())
        println("")
        show("volt+gnelim+fl+str are generated")
        (pinj_dict,qinj_dict)        =line_expression_n(model_name)
        show(now())
        println("")
        show("line expr normal")
        # (pinj_dict_c,qinj_dict_c)=   line_expression_c(model_name)
        # show(now())
        # println("")
        # show("line expr contin")
        (active_power_balance_normal)=active_power_bal_n(model_name,pinj_dict)
        show(now())
        println("")
        show("power bal norm")
        # (active_power_balance_contin)=active_power_bal_c(model_name,pinj_dict_c)
        # show(now())
        # println("")
        # show("power bal contin")
        (reactive_power_balance_normal)=reactive_power_bal_n(model_name,qinj_dict)
        show(now())
        println("")
        show("react power bal normal")
        # (reactive_power_balance_contin)=reactive_power_bal_c(model_name,qinj_dict_c)
        # show(now())
        # println("")
        # show("react power bal contin")
        (line_flow_normal_s,line_flow_normal_r,line_flow_normal_trans_s,line_flow_normal_trans_r)=line_flow_n(model_name,pinj_dict,qinj_dict,"full" )# "full"
        # (line_flow_contin_s,line_flow_contin_r,line_flow_contin_trans_s,line_flow_contin_trans_r)=line_flow_c(model_name,pinj_dict_c,qinj_dict_c,"full" )# "full"
        show(now())
        println("")
        show("line flow all")
        # longitudinal_current_normal(model_name)
        # longitudinal_current_contin(model_name)

        # coupling_constraint(model_name)

        (total_cost,cost_gen,cost_pen_lsh,cost_fl,cost_str,cost_pen_ws)=objective_SCOPF(model_name,model_indicator)

        show(now())
        println("")
        show("coupling+obj and Optimizer starts ")

        optimize!(model_name)
        show(now())
        println("")
        show("optimizer finished")
        println("Objective value", JuMP.objective_value(model_name))
        println("Solver Time ", JuMP.solve_time(model_name))

       output=Dict(
       :pinj_dict=>pinj_dict,
       :qinj_dict=>qinj_dict,
       # :pinj_dict_c=>pinj_dict_c,
       # :qinj_dict_c=>qinj_dict_c,
       :active_power_balance_normal=>active_power_balance_normal,
       # :active_power_balance_contin=>active_power_balance_contin,
       :reactive_power_balance_normal=>reactive_power_balance_normal,
       # :reactive_power_balance_contin=>reactive_power_balance_contin,
       :line_flow_normal_s=>line_flow_normal_s,
       :line_flow_normal_r=>line_flow_normal_r,
       :line_flow_normal_trans_s=>line_flow_normal_trans_s,
       :line_flow_normal_trans_r=>line_flow_normal_trans_r,
       # :line_flow_contin_s=>line_flow_contin_s,
       # :line_flow_contin_r=>line_flow_contin_r,
       # :line_flow_contin_trans_s=>line_flow_contin_trans_s,
       # :line_flow_contin_trans_r=>line_flow_contin_trans_r,
       :total_cost=>total_cost,
       :cost_gen=>cost_gen,
       :cost_pen_lsh=>cost_pen_lsh,
       :cost_fl=>cost_fl,
       :cost_str=>cost_str,
       :cost_pen_ws=>cost_pen_ws,
       # :cost_pen_lsh_c=>cost_pen_lsh_c,
       # :cost_pen_ws_c=>cost_pen_ws_c,
       # :cost_fl_c=>cost_fl_c,
       # :cost_str_c=>cost_str_c,
       )
    return model_name, output

end
end

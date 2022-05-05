# -----------generation cost----------------------
if haskey(new_data, "gencost")
for i in 1:nGens
    cost_b_gen[i]=new_data["gencost"][1][i]
end
end
cost_gen=@expression(acopf,
                    sum(
                    # Pg[s,t,i]*Pg[s,t,i]*cost_a_gen[i]*(sbase^2)
                    # +
                    Pg[s,t,i]*cost_b_gen[i]*sbase
                    # +
                    # cost_c_gen[i]
                    for s in 1:nSc,t in 1:nTP,i in 1:nGens )
                    )

# -----------penalty cost normal state-----------
# -------load shedding cost-----
# for 5 bus
# penalty_cost=10e3
# for 60 bus
penalty_cost=1e4

cost_pen_lsh_aux=@expression(acopf,
                    [i=1:nBus ; ~isempty(findall(x->x==i,bus_data_lsheet)) ],
                    sum(penalty_cost*(pen_lsh[s,t,findall(x->x==i,bus_data_lsheet)]) for s in 1:nSc,t in 1:nTP)
                             )
               cost_pen_lsh=@expression(acopf,sum(cost_pen_lsh_aux))
# -----Generation curtailment----
cost_pen_ws_aux=@expression(acopf,
                    [i=1:nBus; ~isempty(findall(x->x==i,RES_bus)) ],
                    sum(penalty_cost*(pen_ws[s,t,findall(x->x==i,RES_bus)]) for s in 1:nSc,t in 1:nTP)
                             )
               cost_pen_ws=@expression(acopf,sum(cost_pen_ws_aux))

# -------------penalty cost post contingency states------------
# --------loadshedding cost-----
cost_pen_lsh_aux_c=@expression(acopf,
                   [i=1:nBus ; ~isempty(findall(x->x==i,bus_data_lsheet)) ],
                   sum(penalty_cost*(pen_lsh_c[c,s,t,findall(x->x==i,bus_data_lsheet)]) for c in 1:nCont,s in 1:nSc,t in 1:nTP)
                             )
              cost_pen_lsh_c=@expression(acopf,sum(cost_pen_lsh_aux_c))
# ------ Generation curtailment----
cost_pen_ws_aux_c=@expression(acopf,
                   [i=1:nBus; ~isempty(findall(x->x==i,RES_bus)) ],
                   sum(penalty_cost*(pen_ws_c[c,s,t,findall(x->x==i,RES_bus)]) for c in 1:nCont, s in 1:nSc,t in 1:nTP)
                             )
              cost_pen_ws_c=@expression(acopf,sum(cost_pen_ws_aux_c))


# --------Flexible load cost normal state-------
cost_fl_aux=@expression(acopf,
                   [i=1:nBus, idx_flex=findall(x->x==i,nd_fl); ~isempty(findall(x->x==i,nd_fl)) ],
                   sum(
                   cost_flex_load[idx_flex]*sbase
                   *
                   (p_fl_inc[s,t,findall(x->x==i,nd_fl)]+p_fl_dec[s,t,findall(x->x==i,nd_fl)]) for s in 1:nSc,t in 1:nTP)
                   )
            cost_fl=@expression(acopf,sum(cost_fl_aux))
# --------Flexible load cost post contingency state-------
cost_fl_aux_c=@expression(acopf,
                   [c=1:nCont, i=1:nBus, idx_flex=findall(x->x==i,nd_fl); ~isempty(findall(x->x==i,nd_fl)) ],
                   sum(
                   cost_flex_load[idx_flex]*sbase
                   *
                   (p_fl_inc_c[c,s,t,findall(x->x==i,nd_fl)]+p_fl_dec_c[c,s,t,findall(x->x==i,nd_fl)]) for s in 1:nSc,t in 1:nTP)
                          )
             cost_fl_c  =@expression(acopf,sum(cost_fl_aux_c))



cost_fl_aux_q=@expression(acopf,
                                [i=1:nBus, idx_flex=findall(x->x==i,nd_fl); ~isempty(findall(x->x==i,nd_fl)) ],
                                sum(
                                cost_flex_load_q[idx_flex]*sbase
                                *
                                (q_fl_inc[s,t,findall(x->x==i,nd_fl)]+q_fl_dec[s,t,findall(x->x==i,nd_fl)]) for s in 1:nSc,t in 1:nTP)
                                )
                         cost_fl_q=@expression(acopf,sum(cost_fl_aux_q))
             # --------Flexible load cost post contingency state-------
cost_fl_aux_c_q=@expression(acopf,
                                [c=1:nCont, i=1:nBus, idx_flex=findall(x->x==i,nd_fl); ~isempty(findall(x->x==i,nd_fl)) ],
                                sum(
                                cost_flex_load_q[idx_flex]*sbase
                                *
                                (q_fl_inc_c[c,s,t,findall(x->x==i,nd_fl)]+q_fl_dec_c[c,s,t,findall(x->x==i,nd_fl)]) for s in 1:nSc,t in 1:nTP)
                                       )
                          cost_fl_c_q  =@expression(acopf,sum(cost_fl_aux_c_q))

# haskey(new_data, "negGen")
cost_gen_neg_aux=@expression(acopf, [s in 1:nSc, t in 1:nTP, b in 1:nBus],
reduce(+, (Pg_neg[s,t,i]*new_data["negGen"][i][7]*sbase for i in findall(x->x==b,neg_gen_bus) if haskey(new_data, "negGen") && ~isempty(findall(x->x==b,neg_gen_bus))); init=0)
)

# cost_gen_neg  =@expression(acopf,sum(cost_gen_neg_aux))

cost_gen_neg_aux_c=@expression(acopf, [c in 1:nCont, s in 1:nSc, t in 1:nTP, b in 1:nBus],
reduce(+, (Pg_neg_c[c,s,t,i]*new_data["negGen"][i][7]*sbase for i in findall(x->x==b,neg_gen_bus) if haskey(new_data, "negGen") && ~isempty(findall(x->x==b,neg_gen_bus))); init=0)
                    )
# cost_gen_neg_c  =@expression(acopf,sum(cost_gen_neg_aux_c))

# ----------storage cost normal state-------
# cost_str_aux=@expression(acopf,
#                        [i=1:nBus, idx_str=findall(x->x==i,nd_Str_active); ~isempty(findall(x->x==i,nd_Str_active)) ],
#                        sum(
#                        cost_b_str[idx_str]*(sbase)*( p_ch[s,t,idx_str]+p_dis[s,t,idx_str])
#                        for s in 1:nSc,t in 1:nTP)
#                           )
#              cost_str  =@expression(acopf,sum(cost_str_aux))
# ----------storage cost post contingency state-----
# cost_str_aux_c=@expression(acopf,
#                        [c=1:nCont,i=1:nBus, idx_str=findall(x->x==i,nd_Str_active); ~isempty(findall(x->x==i,nd_Str_active)) ],
#                        sum(
#                        cost_b_str[idx_str]*(sbase)*( p_ch_c[c,s,t,idx_str]+p_dis_c[c,s,t,idx_str])
#                        for s in 1:nSc,t in 1:nTP)
#                           )
#              cost_str_c  =@expression(acopf,sum(cost_str_aux_c))

# -------------------------------------------------------------
# ---------total cost terms------------
total_cost=@expression(acopf, (
               (cost_gen
               +sum(cost_pen_lsh)
               +sum(cost_fl)
               +sum(cost_fl_q)
               # +sum(cost_str)
               +sum(cost_pen_ws)
               +sum(cost_gen_neg_aux)
               )
               +
               (sum(cost_pen_lsh_c)
               +sum(cost_pen_ws_c)
               +sum(cost_fl_c)
               +sum(cost_fl_c_q)
               +sum(cost_gen_neg_aux_c)
               # +sum(cost_str_c)
               )
                 )
                   )
# total_cost=@expression(acopf, (
#                (cost_gen
#                # +sum(cost_pen_lsh)
#                # +sum(cost_fl)
#                # +sum(cost_str)
#                # +sum(cost_pen_ws)
#                )
#                # +
#                # (
#                # sum(cost_pen_lsh_c)
#                # +sum(cost_pen_ws_c)
#                # +sum(cost_fl_c)
#                # +sum(cost_str_c)
#                # )
#                  )
#                    )


# #-------------------------------------------------------------------------------

@objective(acopf,Min,total_cost)

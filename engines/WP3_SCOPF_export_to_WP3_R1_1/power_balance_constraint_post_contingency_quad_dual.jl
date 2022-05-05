#---------------------Script for Power Balance Constraint-----------------------
#-------------------------------------------------------------------------------
# line_to_bus_topology_1_c= []
# line_to_bus_topology_send_c= []
# line_to_bus_topology_receive_c= []
# line_to_bus_topology_send_new_c= []
# line_to_bus_topology_receive_new_c= []
pinj_dict_c=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()
qinj_dict_c=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()
pinj_dict_c_sr=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()
qinj_dict_c_sr=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()


for c in 1:nCont
    for s in 1:nSc
        for t in 1:nTP
            for i in 1:nBus

            # nd      = node_data_contin[c][i].node_num_c                                    # Node num is independant of time period and scenario
            # nd_num  = unique(nd)
            # nd_num  = nd_num[1,1]

            idx_nd_nw_buses = findall(x->x==i,rdata_buses[:,1])
            idx_nd_nw_buses = idx_nd_nw_buses[1,1]
            idx_fr_trans =findall(x->x==i,idx_from_trans)
            idx_t_trans =findall(x->x==i,idx_to_trans)
            idx_bus_lsheet  = findall(x->x==i,bus_data_lsheet)              # Index of buses in load sheet
            idx_bus_gsheet  = findall(x->x==i,bus_data_gsheet)
            idx_bus_shunt   = findall(x->x==i,rdata_shunts[:,1])
            idx_RES         = findall(x->x==i,RES_bus)
            idx_fl = findall(x->x==i,nd_fl)
            idx_str         = findall(x->x==i,nd_Str_active)

            pg_c = Pg_c[c,s,t,idx_bus_gsheet]
            qg_c = Qg_c[c,s,t,idx_bus_gsheet]
            pd = prof_ploads[idx_bus_lsheet,t]                                      # Active power demand for scenario s in time period t
            qd = prof_qloads[idx_bus_lsheet,t]                                      # Reactive power demand for scenario s in time period t
            bsh= rdata_shunts[idx_bus_shunt,2]
            pg_RES=prof_PRES[s,t,idx_RES]
            load_shed_c=pen_lsh_c[c,s,t,idx_bus_lsheet]
            spill_c     =pen_ws_c[c,s,t,idx_RES]
            # p_chrg_c    =p_ch_c[c,s,t,idx_str]
            # p_dischrg_c =p_dis_c[c,s,t,idx_str]
            # p_flx_inc_c = p_fl_inc_c[c,s,t,idx_fl]
            # p_flx_dec_c = p_fl_dec_c[c,s,t,idx_fl]



            # p_flx_free_c = p_fl_free_c[c,s,t,idx_fl]
            # dn_c=Dn[c,s,t,idx_RES]
            # pd = p_generated_scenarios[s][idx_bus_lsheet,t]                                      # Active power demand for scenario s in time period t
            # qd = q_generated_scenarios[s][idx_bus_lsheet,t]                                      # Reactive power demand for scenario s in time period t
#
            # pd = p_load[s,t,idx_bus_lsheet]                                      # Active power demand for scenario s in time period t
            # qd = q_load[s,t,idx_bus_lsheet]                                      # Reactive power demand for scenario s in time period t
            # pd = prof_ploads[idx_bus_lsheet,t]                                      # Active power demand for scenario s in time period t
            # qd = prof_qloads[idx_bus_lsheet,t]                                      # Reactive power demand for scenario s in time period t
#
                # if isempty(pd) pd=0.0 end
                # if isempty(qd) qd=0.0 end
                # pinj_expr_c = []
                # qinj_expr_c = []
                # pinj_expr_1netw = []   # 1 means that for intersected buses of node_data_trans and node_data
                # qinj_expr_1netw = []
                # pinj_expr_1trans = []   # 1 means that for intersected buses of node_data_trans and node_data
                # qinj_expr_1trans = []
                # shunt_expr       = []
                # pinj_expr_2trans = []    # 2 means that for intersected buses of node_data_trans but not  node_data
                # qinj_expr_2trans = []
                if  ~isempty(node_data_contin[c][i].node_num_c)


                    for j in 1:size(node_data_contin[c][i].node_num_c,1)                                                # length of each node vector in 'node_data' variable

                        gij_line    = node_data_contin[c][i].node_gij_sr_c[j]
                        bij_line    = node_data_contin[c][i].node_bij_sr_c[j]
                        cnctd_nd    = node_data_contin[c][i].node_cnode_c[j]
                        idx_cnctd_nd = findall(x->x==cnctd_nd,rdata_buses[:,1])
                        idx_cnctd_nd = idx_cnctd_nd[1,1]
                        gij_line_sh = node_data_contin[c][i].node_gij_sh_c[j]
                        bij_line_sh = node_data_contin[c][i].node_bij_sh_c[j]
                        smax=         node_data_contin[c][i].node_smax_c[j]
                        pinj_ij_sh      = ((gij_line_sh/2)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )       # Line shunt conductance (Must be divided by 2)
                        pinj_ij_sr0      = ((gij_line)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )       # Line shunt conductance (Must be divided by 2)
                        pinj_ij_sr1     = (-bij_line*(f_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd]-e_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd]) )
                        pinj_ij_sr2     = (-gij_line*(e_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd]+f_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd]) )

                        qinj_ij_sh      = (-(bij_line_sh/2)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )      # Line shunt susceptance (Must be divided by 2)
                        qinj_ij_sr0      = (-(bij_line)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )      # Line shunt susceptance (Must be divided by 2)
                        qinj_ij_sr1     = (  bij_line*(e_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd]+f_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd]) )
                        qinj_ij_sr2     = ( -gij_line*(f_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd]-e_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd]) )

                                pij = (pinj_ij_sh+pinj_ij_sr0+pinj_ij_sr1+pinj_ij_sr2)
                                qij = (qinj_ij_sh+qinj_ij_sr0+qinj_ij_sr1+qinj_ij_sr2)
                                pij_sr = (pinj_ij_sr0+pinj_ij_sr1+pinj_ij_sr2)
                                qij_sr = (qinj_ij_sr0+qinj_ij_sr1+qinj_ij_sr2)

                        # end
                            # @NLconstraint(acopf,pij^2+qij^2<=smax^2)
                            push!(pinj_dict_c,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd] => pij)
                            push!(qinj_dict_c,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd] => qij)
                            push!(pinj_dict_c_sr,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd] => pij_sr)
                            push!(qinj_dict_c_sr,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd] => qij_sr)

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
                        idx_cnctd_nd_trans = findall(x->x==cnctd_nd,rdata_buses[:,1])
                        idx_cnctd_nd_trans = idx_cnctd_nd_trans[1,1]
                        gij_line_sh_transf = node_data_trans[i,1].node_gij_sh[j,1]
                        bij_line_sh_transf = node_data_trans[i,1].node_bij_sh[j,1]
                         if  ~isempty(idx_fr_trans)  && isempty(idx_t_trans)

                         #                Munammad transformer model
                        # pinj_ij_sh_trans  = @NLexpression(acopf,(tratio[s,t,idx_nd_nw_buses]^2)*(gij_line_sh_transf+gij_line_transf)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
                        # pinj_ij_sr1_trans = @NLexpression(acopf,tratio[s,t,idx_nd_nw_buses]*(-gij_line_transf)*(e[s,t,idx_nd_nw_buses]*e[s,t,idx_cnctd_nd_trans]+f[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )
                        # pinj_ij_sr2_trans = @NLexpression(acopf,tratio[s,t,idx_nd_nw_buses]*(-bij_line_transf)*(e[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]-e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )
                        #
                        # qinj_ij_sh_trans  = @NLexpression(acopf,tratio[s,t,idx_nd_nw_buses]^2*(-bij_line_sh_transf - bij_line_transf)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
                        # # qinj_ij_sr1_trans = @NLexpression(acopf,tratio[s,t,idx_nd_nw_buses]*(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]-e[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )
                        # qinj_ij_sr2_trans = @NLexpression(acopf,tratio[s,t,idx_nd_nw_buses]*bij_line_transf*(e[s,t,idx_nd_nw_buses]*e[s,t,idx_cnctd_nd_trans]+f[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )

                         # Florin transformer model
                         pinj_ij_sh_trans  = ((gij_line_transf)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
                         pinj_ij_sr1_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_nd_nw_buses]*e[s,t,idx_cnctd_nd_trans]+f[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )
                         pinj_ij_sr2_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*(-bij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]-e_c[c,s,t,idx_cnctd_nd_trans]*f_c[c,s,t,idx_nd_nw_buses]) )

                         qinj_ij_sh_trans  = ((- bij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )
                         qinj_ij_sr1_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]-e[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )
                         qinj_ij_sr2_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*bij_line_transf*(e_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd_trans]+f_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]) )
                                pijt1 = (-pinj_ij_sh_trans-pinj_ij_sr1_trans-pinj_ij_sr2_trans)
                                qijt1 = (+qinj_ij_sh_trans+qinj_ij_sr1_trans+qinj_ij_sr2_trans)
                                # pij = @NLexpression(acopf, -pinj_ij_sr2_trans)
                                # qij = @NLexpression(acopf, +qinj_ij_sh_trans+qinj_ij_sr2_trans)
                                push!(pinj_dict_c,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => pijt1)
                                push!(qinj_dict_c,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => qijt1)
                                # push!(pinj_expr_1trans,pijt1)
                                # push!(qinj_expr_1trans,qijt1)
                                # push!(line_to_bus_topology_send_c,[idx_nd_nw_buses,idx_cnctd_nd_trans])
                          # end

                      elseif  isempty(idx_fr_trans)  && ~isempty(idx_t_trans)
                                 # if   idx_cnctd_nd_trans==idx_from_trans[idx_t_trans[j,1]]                     # it means that we are in receiving bus for transformator
                             # idx_from_receiving = idx_from_receiving[1,1]
                             # Muhammd transforemr
                        pinj_ij_sh_trans  = ((tratio_c[c,s,t,idx_nd_nw_buses]^2)*(gij_line_transf)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
                        pinj_ij_sr1_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*e[s,t,idx_nd_nw_buses]+f[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )
                        pinj_ij_sr2_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*(-bij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]-e_c[c,s,t,idx_cnctd_nd_trans]*f_c[c,s,t,idx_nd_nw_buses]) )
                        #
                        qinj_ij_sh_trans  = ((tratio_c[c,s,t,idx_nd_nw_buses]^2)*(-bij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )
                        qinj_ij_sr1_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]-e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )
                        qinj_ij_sr2_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*( bij_line_transf)*(e_c[c,s,t,idx_cnctd_nd_trans]*e_c[c,s,t,idx_nd_nw_buses]+f_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]) )

                    # Florin trnasformer
                        # pinj_ij_sh_trans  = @NLexpression(acopf,(gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]^2+f[s,t,idx_cnctd_nd_trans]^2) )
                        # pinj_ij_sr1_trans = @NLexpression(acopf,(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*e[s,t,idx_nd_nw_buses]+f[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )
                        # pinj_ij_sr2_trans = @NLexpression(acopf,(-bij_line_transf)*(e[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]-e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )
                        # #
                        # qinj_ij_sh_trans  = @NLexpression(acopf,-bij_line_transf*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
                        # # qinj_ij_sr1_trans = @NLexpression(acopf,(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]-e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )
                        # qinj_ij_sr2_trans = @NLexpression(acopf,( bij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*e[s,t,idx_nd_nw_buses]+f[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )
                        #
                                pijt2 = ( -pinj_ij_sh_trans-pinj_ij_sr1_trans-pinj_ij_sr2_trans)
                                qijt2 = ( +qinj_ij_sh_trans+qinj_ij_sr1_trans+qinj_ij_sr2_trans)
                                # pij = @NLexpression(acopf,-pinj_ij_sr2_trans)
                                # qij = @NLexpression(acopf,+qinj_ij_sh_trans+qinj_ij_sr2_trans)
                        #
                        push!(pinj_dict_c,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => pijt2)
                        push!(qinj_dict_c,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => qijt2)
                                #
                                # push!(pinj_expr_1trans,pijt2)
                                # push!(qinj_expr_1trans,qijt2)
                                # push!(line_to_bus_topology_receive_c,[idx_nd_nw_buses,idx_cnctd_nd_trans])
                              # end
                      elseif  ~isempty(idx_fr_trans)  && ~isempty(idx_t_trans)
                              if idx_cnctd_nd_trans==idx_to_trans[idx_fr_trans[1,1]]
                                  pinj_ij_sh_trans  = ((gij_line_sh_transf+gij_line_transf)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
                                  pinj_ij_sr1_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_nd_nw_buses]*e[s,t,idx_cnctd_nd_trans]+f[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )
                                  pinj_ij_sr2_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*(-bij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]-e_c[c,s,t,idx_cnctd_nd_trans]*f_c[c,s,t,idx_nd_nw_buses]) )

                                  qinj_ij_sh_trans  = ((-bij_line_sh_transf - bij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )
                                  qinj_ij_sr1_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]-e[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )
                                  qinj_ij_sr2_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*bij_line_transf*(e_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd_trans]+f_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]) )
                                  pijt3 = ( -pinj_ij_sh_trans-pinj_ij_sr1_trans-pinj_ij_sr2_trans)
                                  qijt3 = ( +qinj_ij_sh_trans+qinj_ij_sr1_trans+qinj_ij_sr2_trans)

                                  # pij = @NLexpression(acopf,-pinj_ij_sr2_trans)
                                  # qij = @NLexpression(acopf,qinj_ij_sh_trans+qinj_ij_sr2_trans)
                                  push!(pinj_dict_c,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => pijt3)
                                  push!(qinj_dict_c,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => qijt3)

                                  # push!(pinj_expr_2trans,pijt3)
                                  # push!(qinj_expr_2trans,qijt3)
                                  # push!(line_to_bus_topology_send_new_c,[idx_nd_nw_buses,idx_cnctd_nd_trans])



                              else
                                  pinj_ij_sh_trans  = ((tratio_c[c,s,t,idx_nd_nw_buses]^2)*(gij_line_transf)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
                                  pinj_ij_sr1_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*e[s,t,idx_nd_nw_buses]+f[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )
                                  pinj_ij_sr2_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*(-bij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]-e_c[c,s,t,idx_cnctd_nd_trans]*f_c[c,s,t,idx_nd_nw_buses]) )

                                  qinj_ij_sh_trans  = ((tratio_c[c,s,t,idx_nd_nw_buses]^2)*(-bij_line_transf)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )
                                  qinj_ij_sr1_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]-e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )
                                  qinj_ij_sr2_trans = ((tratio_c[c,s,t,idx_nd_nw_buses])*( bij_line_transf)*(e_c[c,s,t,idx_cnctd_nd_trans]*e_c[c,s,t,idx_nd_nw_buses]+f_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd_trans]) )
                                  pijt4 = ( -pinj_ij_sh_trans-pinj_ij_sr1_trans-pinj_ij_sr2_trans)
                                  qijt4 = ( +qinj_ij_sh_trans+qinj_ij_sr1_trans+qinj_ij_sr2_trans)

                                  # pij = @NLexpression(acopf, -pinj_ij_sr2_trans)
                                  # qij = @NLexpression(acopf,  qinj_ij_sh_trans+qinj_ij_sr2_trans)
                                  push!(pinj_dict_c,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => pijt4)
                                  push!(qinj_dict_c,  [c,s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => qijt4)

                                  # push!(pinj_expr_2trans,pijt4)
                                  # push!(qinj_expr_2trans,qijt4)
                                  # push!(line_to_bus_topology_receive_new_c,[idx_nd_nw_buses,idx_cnctd_nd_trans])

                              end
                          end






                         end
                     end
                # end

                # if ~isempty(idx_bus_shunt)
                #     idx_bus_shunt=idx_bus_shunt[1,1]
                #     # shunt_expr_1 = ( shnt_c[c,s,t,idx_nd_nw_buses]*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )
                #     shunt_expr_1 = ( nw_shunts[idx_bus_shunt].shunt_bsh0*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2) )
                #     push!(shunt_expr,shunt_expr_1)
                # end
                #     # push!(shunt_expr,shunt_expr_1)
                #     shunt= (sum(shunt_expr[j,1] for j in 1:size(shunt_expr,1)) )
                #
                #     p_inj = (sum(pinj_expr_1netw[j,1] for j in 1:size(pinj_expr_1netw,1))+sum(pinj_expr_1trans[j,1] for j in 1:size(pinj_expr_1trans,1))+sum(pinj_expr_2trans[j,1] for j in 1:size(pinj_expr_2trans,1))  )
                #     q_inj = (sum(qinj_expr_1netw[j,1] for j in 1:size(qinj_expr_1netw,1))+sum(qinj_expr_1trans[j,1] for j in 1:size(qinj_expr_1trans,1))+sum(qinj_expr_2trans[j,1] for j in 1:size(qinj_expr_2trans,1)) )


        #         for j in 1:size(nd,1)                                                # length of each node vector in 'node_data' variable
        #             gij_line    = node_data_contin[c][i].node_gij_sr_c[j]
        #             bij_line    = node_data_contin[c][i].node_bij_sr_c[j]
        #             cnctd_nd    = node_data_contin[c][i].node_cnode_c[j]
        #             idx_cnctd_nd = findall(x->x==cnctd_nd,rdata_buses[:,1])
        #             idx_cnctd_nd = idx_cnctd_nd[1,1]
        #             gij_line_sh = node_data_contin[c][i].node_gij_sh_c[j]
        #             bij_line_sh = node_data_contin[c][i].node_bij_sh_c[j]
        #
        #             pinj_ij_sh      = @NLexpression(acopf,((gij_line_sh/2)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2)))       # Line shunt conductance (Must be divided by 2)
        #             # pinj_trsf_sh    = @NLexpression(acopf,(gij_line_sh*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2)))           # Full shunt conductance core losses is used at the sending node of a transformer
        #             pinj_ij_sr1     = @NLexpression(acopf,(gij_line*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2)))
        #             pinj_ij_sr2     = @NLexpression(acopf,((-gij_line*(e_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd]+f_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd]))+(-bij_line*(f_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd]-e_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd]))))
        #
        #             qinj_ij_sh      = @NLexpression(acopf,(-(bij_line_sh/2)*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2)))      # Line shunt susceptance (Must be divided by 2)
        #             # qinj_trsf_sh    = @NLexpression(acopf,(-bij_line_sh*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2)))           # Full shunt magnetization suspectance is used at the sending node of a transformer
        #             qinj_ij_sr1     = @NLexpression(acopf,(-bij_line*(e_c[c,s,t,idx_nd_nw_buses]^2+f_c[c,s,t,idx_nd_nw_buses]^2)))
        #             qinj_ij_sr2     = @NLexpression(acopf,((-gij_line*(f_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd]-e_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd]))+(bij_line*(e_c[c,s,t,idx_nd_nw_buses]*e_c[c,s,t,idx_cnctd_nd]+f_c[c,s,t,idx_nd_nw_buses]*f_c[c,s,t,idx_cnctd_nd]))))
        #             pij = @NLexpression(acopf,pinj_ij_sh+pinj_ij_sr1+pinj_ij_sr2)
        #             qij = @NLexpression(acopf,qinj_ij_sh+qinj_ij_sr1+qinj_ij_sr2)
        #     # end
        #     push!(pinj_expr_c,pij)
        #     push!(qinj_expr_c,qij)
        # end
        # p_inj = @NLexpression(acopf,sum(pinj_expr_c[j,1] for j in 1:size(pinj_expr_c,1)))
        # q_inj = @NLexpression(acopf,sum(qinj_expr_c[j,1] for j in 1:size(qinj_expr_c,1)))
        # @NLconstraint(acopf,sum(pg_c[j,1] for j in 1:size(pg_c,1))+sum(pg_RES[j,1] for j in 1:size(pg_RES,1))==p_inj+sum(pd[j,1] for j in 1:size(pd,1)))
#    The following power balance considers the penalty variable pen_c which is defined as pen in variables
        # @constraint(acopf,sum(pg_c[j,1] for j in 1:size(pg_c,1))
        # +sum(pg_RES[j,1] for j in 1:size(pg_RES,1))
        # +sum(load_shed_c[j,1] for j in 1:size(load_shed_c,1))
        # -sum(spill_c[j,1] for j in 1:size(spill_c,1))
        # # -sum(p_chrg_c[j,1] for j in 1:size(p_chrg_c,1))
        # # +sum(p_dischrg_c[j,1] for j in 1:size(p_dischrg_c,1))
        # ==p_inj+sum(pd[j,1] for j in 1:size(pd,1))
        # # +sum(p_flx_inc_c[j,1] for j in 1:size(p_flx_inc_c,1))
        # # -sum(p_flx_dec_c[j,1] for j in 1:size(p_flx_dec_c,1))
        # )

        # @NLconstraint(acopf,sum(pg_c[j,1] for j in 1:size(pg_c,1))+sum(pg_RES[j,1] for j in 1:size(pg_RES,1))==p_inj+sum(pd[j,1] for j in 1:size(pd,1)))
        # @constraint(acopf,sum(qg_c[j,1] for j in 1:size(qg_c,1))
        # +shunt
        # ==q_inj+sum(qd[j,1] for j in 1:size(qd,1)) )
        #
        #     exp = string("Contingency_$c-","Node_$i-","Sc_$s-","TP_$t")
        #     con_exp[:pb_p][exp] = p_inj
        #     con_exp[:pb_q][exp] = q_inj
        end
    end
 end
end


@constraint(acopf, active_poewr_balance_contin[c in 1:nCont, s in 1:nSc, t in 1:nTP, b in 1:nBus],

 reduce(+, (Pg_c[c,s,t,i] for i in findall(x->x==b,bus_data_gsheet) if ~isempty(findall(x->x==b,bus_data_gsheet))); init=0)
 +
 reduce(+, (prof_PRES[s,t,i] for i in findall(x->x==b,RES_bus) if ~isempty(findall(x->x==b,RES_bus))); init=0)
 +
 reduce(+, (pen_lsh_c[c,s,t,i] for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)
 -
 reduce(+, (pen_ws_c[c,s,t,i] for i in findall(x->x==b,RES_bus) if ~isempty(findall(x->x==b,RES_bus))); init=0)
 # -
 # reduce(+, (p_ch[s,t,i] for i in findall(x->x==b,nd_Str_active) if ~isempty(findall(x->x==b,nd_Str_active))); init=0)
 # +
 # reduce(+, (p_dis[s,t,i] for i in findall(x->x==b,nd_Str_active) if ~isempty(findall(x->x==b,nd_Str_active))); init=0)
 +
 reduce(+, (Pg_neg_c[c,s,t,i] for i in findall(x->x==b,neg_gen_bus) if haskey(new_data, "negGen") && ~isempty(findall(x->x==b,neg_gen_bus))); init=0)


  # ==reduce(+, (pinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]] for j in 1:size(node_data_contin[c][b].node_num_c,1) if ~isempty(node_data_contin[c][b].node_num_c)); init=0)
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


      @constraint(acopf, reactive_poewr_balance_contin[c in 1:nCont, s in 1:nSc, t in 1:nTP, b in 1:nBus],

       reduce(+, (Qg_c[c,s,t,i] for i in findall(x->x==b,bus_data_gsheet) if ~isempty(findall(x->x==b,bus_data_gsheet))); init=0)
       +
       reduce(+, (tan(acos(power_factor))*pen_lsh_c[c,s,t,i] for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)

        # ==reduce(+, (qinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]] for j in 1:size(node_data_contin[c][b].node_num_c,1) if ~isempty(node_data_contin[c][b].node_num_c)); init=0)
        +
        reduce(+, (Qg_neg_c[c,s,t,i] for i in findall(x->x==b,neg_gen_bus) if haskey(new_data, "negGen") && ~isempty(findall(x->x==b,neg_gen_bus))); init=0)

        ==reduce(+, (qinj_dict_c[[c,s,t,b,j]] for j in node_data_contin[c][b].node_cnode_c if ~isempty(node_data_contin[c][b].node_num_c)); init=0)
        +
        # reduce(+, (qinj_dict_c[[c,s,t,b,node_data_trans[b,1].node_cnode[j]]] for j in 1:size(node_data_trans[b,1].node_num,1) if ~isempty(node_data_trans[b,1].node_num)); init=0)
        reduce(+, (qinj_dict_c[[c,s,t,b,j]] for j in node_data_trans[b,1].node_cnode if ~isempty(node_data_trans[b,1].node_num)); init=0)
        # sum(qinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]] for j in 1:size(node_data_contin[c][b].node_num_c,1) )
        +
        reduce(+, (prof_qloads[i,t]  for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)

        -
        reduce(+, (nw_shunts[i].shunt_bsh0*(e_c[c,s,t,b]^2+f_c[c,s,t,b]^2)  for i in findall(x->x==b,rdata_shunts[:,1]) if ~isempty(findall(x->x==b,rdata_shunts[:,1]))); init=0)
        +
        reduce(+, (q_fl_inc_c[c,s,t,i] for i in findall(x->x==b,nd_fl) if ~isempty(findall(x->x==b,nd_fl))); init=0)
        -
        reduce(+, (q_fl_dec_c[c,s,t,i] for i in findall(x->x==b,nd_fl) if ~isempty(findall(x->x==b,nd_fl))); init=0)

            )



# # @NLconstraint(acopf, line_flow_contin[c in 1:nCont, s in 1:nSc, t in 1:nTP, b in 1:nBus, j in 1:size(node_data_contin[c][b].node_num_c,1); ~isempty(node_data_contin[c][b].node_num_c)],
# @NLconstraint(acopf, line_flow_contin[c in 1:nCont, s in 1:nSc, t in 1:nTP, b in 1:nBus, j in node_data_contin[c][b].node_cnode_c; ~isempty(node_data_contin[c][b].node_num_c)],
#
#             # (pinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]])^2+(qinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]])^2<=(node_data_contin[c][b].node_smax_c[j])^2
#             (pinj_dict_c[[c,s,t,b,j]])^2+(qinj_dict_c[[c,s,t,b,j]])^2<=(node_data_contin[c][b].node_smax_c[findall(x->x==j, node_data_contin[c][b].node_cnode_c)[1]])^2
#
#             )

# @NLconstraint(acopf, line_flow_contin[c in 1:nCont, s in 1:nSc, t in 1:nTP, b in 1:nBus, j in node_data_contin[c][b].node_cnode_c; ~isempty(node_data_contin[c][b].node_num_c)],
#
#                         # (pinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]])^2+(qinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]])^2<=(node_data_contin[c][b].node_smax_c[j])^2
#                         (pinj_dict_c[[c,s,t,b,j]])^2+(qinj_dict_c[[c,s,t,b,j]])^2<=(node_data_contin[c][b].node_smax_c[findall(x->x==j, node_data_contin[c][b].node_cnode_c)[1]])^2
#
#                         )

# line_smax_c

line_flow_contin_s=@NLconstraint(acopf, [c in 1:nCont, s in 1:nSc, t in 1:nTP, l in 1:length(idx_from_line_c[c])],

            # (pinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]])^2+(qinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]])^2<=(node_data_contin[c][b].node_smax_c[j])^2
            (pinj_dict_c_sr[[c,s,t,idx_from_line_c[c][l],idx_to_line_c[c][l]]])^2+(qinj_dict_c_sr[[c,s,t,idx_from_line_c[c][l],idx_to_line_c[c][l]]])^2<=(line_smax_c[c][l])^2

            )

line_flow_contin_r=@NLconstraint(acopf, [c in 1:nCont, s in 1:nSc, t in 1:nTP, l in 1:length(idx_from_line_c[c])],

                        # (pinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]])^2+(qinj_dict_c[[c,s,t,b,node_data_contin[c][b].node_cnode_c[j]]])^2<=(node_data_contin[c][b].node_smax_c[j])^2
                        (pinj_dict_c_sr[[c,s,t,idx_to_line_c[c][l],idx_from_line_c[c][l]]])^2+(qinj_dict_c_sr[[c,s,t,idx_to_line_c[c][l],idx_from_line_c[c][l]]])^2<=(line_smax_c[c][l])^2

                        )

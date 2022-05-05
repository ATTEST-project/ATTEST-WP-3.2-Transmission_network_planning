#---------------------Script for Power Balance Constraint-----------------------
#-------------------------------------------------------------------------------
# line_to_bus_topology_1= []
# line_to_bus_topology_send= []
# line_to_bus_topology_receive= []
# line_to_bus_topology_send_new= []
# line_to_bus_topology_receive_new= []
# p_injection=[]
# q_injection=[]
pinj_dict=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()
qinj_dict=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()
pinj_dict_sr=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()
qinj_dict_sr=Dict{Array{Int64,1}, GenericQuadExpr{Float64,VariableRef}}()

# br_viol_perc_c_dic=Dict{Array{Int64,1},Float64}()
#
# for c in 1:nCont, s in 1:nSc, t in 1:nTP
#     if ~isempty(br_viol_check_contin[c,s,t][3])
#         # for j in 1:size(br_viol_check_contin[c,s,t][3][1],1)
#             for k in br_viol_check_contin[c,s,t][2][1]
#                 j=findall(x->x==k ,br_viol_check_contin[c,s,t][2][1])
#
#  push!(br_viol_perc_c_dic, [c,s,t,idx_from_line_c[c][k],idx_to_line_c[c][k]] => 2*(br_viol_check_contin[c,s,t][3][j[1]]-1))
#  push!(br_viol_perc_c_dic, [c,s,t,idx_to_line_c[c][k],idx_from_line_c[c][k]] => 2*(br_viol_check_contin[c,s,t][3][j[1]]-1))
#
# end
# end
# end
#  to call a dict br_viol_perc_c_idx_dic[[20,2,23,2,24]]
# first_pf_contin_br_dic=Dict( first_pf_contin_br[i] => 1 for i in eachindex(first_pf_contin_br) )



for s in 1:nSc
    for t in 1:nTP
        for i in 1:nBus
            # for i in [47]
            idx_nd_nw_buses = findall(x->x==i,rdata_buses[:,1])
            idx_nd_nw_buses = idx_nd_nw_buses[1,1]
            idx_fr_trans =findall(x->x==i,idx_from_trans)
            idx_t_trans =findall(x->x==i,idx_to_trans)
            idx_bus_lsheet  = findall(x->x==i,bus_data_lsheet)              # Index of buses in load sheet
            idx_bus_gsheet  = findall(x->x==i,bus_data_gsheet)
            idx_bus_shunt   = findall(x->x==i,rdata_shunts[:,1])
            idx_fl = findall(x->x==i,nd_fl)
            idx_RES         = findall(x->x==i,RES_bus)
            idx_str         = findall(x->x==i,nd_Str_active)
            pg = Pg[s,t,idx_bus_gsheet]
            qg = Qg[s,t,idx_bus_gsheet]
            pg_RES=prof_PRES[s,t,idx_RES]
            # p_flx_inc=p_fl_inc[s,t,idx_fl]
            # p_flx_dec=p_fl_dec[s,t,idx_fl]
            # p_chrg   =p_ch[s,t,idx_str]
            # p_dischrg=p_dis[s,t,idx_str]
            spill=pen_ws[s,t,idx_RES]
            load_shed=pen_lsh[s,t,idx_bus_lsheet]
            pd = prof_ploads[idx_bus_lsheet,t]                                      # Active power demand for scenario s in time period t
            qd = prof_qloads[idx_bus_lsheet,t]                                      # Reactive power demand for scenario s in time period t
            bsh= rdata_shunts[idx_bus_shunt,2]
            # pinj_expr_1 = []   # 1 means that for intersected buses of node_data_trans and node_data
            # qinj_expr_1 = []
            pinj_expr_1netw = []   # 1 means that for intersected buses of node_data_trans and node_data
            qinj_expr_1netw = []
            pinj_expr_1trans = []   # 1 means that for intersected buses of node_data_trans and node_data
            qinj_expr_1trans = []
            shunt_expr       = []
            pinj_expr_2trans = []    # 2 means that for intersected buses of node_data_trans but not  node_data
            qinj_expr_2trans = []
        if  ~isempty(node_data[i,1].node_num)


            for j in 1:size(node_data[i,1].node_num,1)                                                # length of each node vector in 'node_data' variable

                gij_line    = node_data[i,1].node_gij_sr[j,1]
                bij_line    = node_data[i,1].node_bij_sr[j,1]
                cnctd_nd    = node_data[i,1].node_cnode[j,1]
                idx_cnctd_nd = findall(x->x==cnctd_nd,rdata_buses[:,1])
                idx_cnctd_nd = idx_cnctd_nd[1,1]
                gij_line_sh = node_data[i,1].node_gij_sh[j,1]
                bij_line_sh = node_data[i,1].node_bij_sh[j,1]
                smax        =node_data[i,1].node_smax[j,1]

                pinj_ij_sh      = ((gij_line_sh/2)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )       # Line shunt conductance (Must be divided by 2)
                pinj_ij_sr0      = ((gij_line)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )       # Line shunt conductance (Must be divided by 2)
                pinj_ij_sr1     = (-bij_line*(f[s,t,idx_nd_nw_buses]*e[s,t,idx_cnctd_nd]-e[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd]) )
                pinj_ij_sr2     = (-gij_line*(e[s,t,idx_nd_nw_buses]*e[s,t,idx_cnctd_nd]+f[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd]) )

                qinj_ij_sh      = (-(bij_line_sh/2)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )      # Line shunt susceptance (Must be divided by 2)
                qinj_ij_sr0      = (-(bij_line)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )      # Line shunt susceptance (Must be divided by 2)
                qinj_ij_sr1     = (  bij_line*(e[s,t,idx_nd_nw_buses]*e[s,t,idx_cnctd_nd]+f[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd]) )
                qinj_ij_sr2     = ( -gij_line*(f[s,t,idx_nd_nw_buses]*e[s,t,idx_cnctd_nd]-e[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd]) )

                        pij = (+pinj_ij_sh+pinj_ij_sr0+pinj_ij_sr1+pinj_ij_sr2)
                        qij = (+qinj_ij_sh+qinj_ij_sr0+qinj_ij_sr1+qinj_ij_sr2)
                        pij_sr = (pinj_ij_sr0+pinj_ij_sr1+pinj_ij_sr2)
                        qij_sr = (qinj_ij_sr0+qinj_ij_sr1+qinj_ij_sr2)


                        # @NLconstraint(acopf,pij^2+qij^2<=smax^2)
                # end
                push!(pinj_dict,  [s,t,idx_nd_nw_buses,idx_cnctd_nd] => pij)
                push!(qinj_dict,  [s,t,idx_nd_nw_buses,idx_cnctd_nd] => qij)
                push!(pinj_dict_sr,  [s,t,idx_nd_nw_buses,idx_cnctd_nd] => pij_sr)
                push!(qinj_dict_sr,  [s,t,idx_nd_nw_buses,idx_cnctd_nd] => qij_sr)

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
                 pinj_ij_sr1_trans = ((tratio[s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_nd_nw_buses]*e[s,t,idx_cnctd_nd_trans]+f[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )
                 pinj_ij_sr2_trans = ((tratio[s,t,idx_nd_nw_buses])*(-bij_line_transf)*(e[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]-e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )

                 qinj_ij_sh_trans  = ((- bij_line_transf)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
                 qinj_ij_sr1_trans = ((tratio[s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]-e[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )
                 qinj_ij_sr2_trans = ((tratio[s,t,idx_nd_nw_buses])*bij_line_transf*(e[s,t,idx_nd_nw_buses]*e[s,t,idx_cnctd_nd_trans]+f[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )
                        pijt1 = (-pinj_ij_sh_trans-pinj_ij_sr1_trans-pinj_ij_sr2_trans)
                        qijt1 = (+qinj_ij_sh_trans+qinj_ij_sr1_trans+qinj_ij_sr2_trans)
                        # pij = ( -pinj_ij_sr2_trans)
                        # qij = @NLexpression(acopf, +qinj_ij_sh_trans+qinj_ij_sr2_trans)
                        push!(pinj_dict,  [s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => pijt1)
                        push!(qinj_dict,  [s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => qijt1)
                        # push!(pinj_expr_1trans,pijt1)
                        # push!(qinj_expr_1trans,qijt1)
                        # push!(line_to_bus_topology_send,[idx_nd_nw_buses,idx_cnctd_nd_trans])
                  # end

              elseif  isempty(idx_fr_trans)  && ~isempty(idx_t_trans)
                         # if   idx_cnctd_nd_trans==idx_from_trans[idx_t_trans[j,1]]                     # it means that we are in receiving bus for transformator
                     # idx_from_receiving = idx_from_receiving[1,1]
                     # Muhammd transforemr
                pinj_ij_sh_trans  = ((tratio[s,t,idx_nd_nw_buses]^2)*(gij_line_transf)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
                pinj_ij_sr1_trans = ((tratio[s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*e[s,t,idx_nd_nw_buses]+f[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )
                pinj_ij_sr2_trans = ((tratio[s,t,idx_nd_nw_buses])*(-bij_line_transf)*(e[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]-e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )
                #
                qinj_ij_sh_trans  =((tratio[s,t,idx_nd_nw_buses]^2)*(-bij_line_transf)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
                qinj_ij_sr1_trans =((tratio[s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]-e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )
                qinj_ij_sr2_trans =((tratio[s,t,idx_nd_nw_buses])*( bij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*e[s,t,idx_nd_nw_buses]+f[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )

            # Florin trnasformer
                # pinj_ij_sh_trans  = @NLexpression(acopf,(gij_line_transf)*(e[s,t,idx_cnctd_nd_trans,idx_nd_nw_buses]^2+f[s,t,idx_cnctd_nd_trans]^2) )
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
                        push!(pinj_dict,  [s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => pijt2)
                        push!(qinj_dict,  [s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => qijt2)
                        # push!(pinj_expr_1trans,pijt2)
                        # push!(qinj_expr_1trans,qijt2)
                        # push!(line_to_bus_topology_receive,[idx_nd_nw_buses,idx_cnctd_nd_trans])
                      # end
              elseif  ~isempty(idx_fr_trans)  && ~isempty(idx_t_trans)
                      if idx_cnctd_nd_trans==idx_to_trans[idx_fr_trans[1,1]]
                          pinj_ij_sh_trans  = ((gij_line_sh_transf+gij_line_transf)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
                          pinj_ij_sr1_trans = ((tratio[s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_nd_nw_buses]*e[s,t,idx_cnctd_nd_trans]+f[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )
                          pinj_ij_sr2_trans = ((tratio[s,t,idx_nd_nw_buses])*(-bij_line_transf)*(e[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]-e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )

                          qinj_ij_sh_trans  = ((-bij_line_sh_transf - bij_line_transf)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
                          qinj_ij_sr1_trans = ((tratio[s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]-e[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )
                          qinj_ij_sr2_trans = ((tratio[s,t,idx_nd_nw_buses])*bij_line_transf*(e[s,t,idx_nd_nw_buses]*e[s,t,idx_cnctd_nd_trans]+f[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )
                          pijt3 = ( -pinj_ij_sh_trans-pinj_ij_sr1_trans-pinj_ij_sr2_trans)
                          qijt3 = ( +qinj_ij_sh_trans+qinj_ij_sr1_trans+qinj_ij_sr2_trans)

                          # pij = @NLexpression(acopf,-pinj_ij_sr2_trans)
                          # qij = @NLexpression(acopf,qinj_ij_sh_trans+qinj_ij_sr2_trans)
                          push!(pinj_dict,  [s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => pijt3)
                          push!(qinj_dict,  [s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => qijt3)
                          # push!(pinj_expr_2trans,pijt3)
                          # push!(qinj_expr_2trans,qijt3)
                          # push!(line_to_bus_topology_send_new,[idx_nd_nw_buses,idx_cnctd_nd_trans])



                      else
                          pinj_ij_sh_trans  = ((tratio[s,t,idx_nd_nw_buses]^2)*(gij_line_transf)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
                          pinj_ij_sr1_trans = ((tratio[s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*e[s,t,idx_nd_nw_buses]+f[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )
                          pinj_ij_sr2_trans = ((tratio[s,t,idx_nd_nw_buses])*(-bij_line_transf)*(e[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]-e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )

                          qinj_ij_sh_trans  = ((tratio[s,t,idx_nd_nw_buses]^2)*(-bij_line_transf)*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
                          qinj_ij_sr1_trans = ((tratio[s,t,idx_nd_nw_buses])*(-gij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]-e[s,t,idx_cnctd_nd_trans]*f[s,t,idx_nd_nw_buses]) )
                          qinj_ij_sr2_trans = ((tratio[s,t,idx_nd_nw_buses])*( bij_line_transf)*(e[s,t,idx_cnctd_nd_trans]*e[s,t,idx_nd_nw_buses]+f[s,t,idx_nd_nw_buses]*f[s,t,idx_cnctd_nd_trans]) )
                          pijt4 = ( -pinj_ij_sh_trans-pinj_ij_sr1_trans-pinj_ij_sr2_trans)
                          qijt4 = ( +qinj_ij_sh_trans+qinj_ij_sr1_trans+qinj_ij_sr2_trans)

                          # pij = @NLexpression(acopf, -pinj_ij_sr2_trans)
                          # qij = @NLexpression(acopf,  qinj_ij_sh_trans+qinj_ij_sr2_trans)
                          push!(pinj_dict,  [s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => pijt4)
                          push!(qinj_dict,  [s,t,idx_nd_nw_buses,idx_cnctd_nd_trans] => qijt4)
                          # push!(pinj_expr_2trans,pijt4)
                          # push!(qinj_expr_2trans,qijt4)
                          # push!(line_to_bus_topology_receive_new,[idx_nd_nw_buses,idx_cnctd_nd_trans])

                      end
                  end






                 end
             end
        # end

        # if ~isempty(idx_bus_shunt)
        #     idx_bus_shunt=idx_bus_shunt[1,1]
        #     shunt_expr_1 = ( nw_shunts[idx_bus_shunt].shunt_bsh0*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
        #     # shunt_expr_1 = @NLexpression(acopf, shnt[s,t,idx_nd_nw_buses]*(e[s,t,idx_nd_nw_buses]^2+f[s,t,idx_nd_nw_buses]^2) )
        #     push!(shunt_expr,shunt_expr_1)
        # end
            # push!(shunt_expr,shunt_expr_1)
            # shunt= (sum(shunt_expr[j,1] for j in 1:size(shunt_expr,1)) )

            # p_inj = (sum(pinj_expr_1netw[j,1] for j in 1:size(pinj_expr_1netw,1))+sum(pinj_expr_1trans[j,1] for j in 1:size(pinj_expr_1trans,1))+sum(pinj_expr_2trans[j,1] for j in 1:size(pinj_expr_2trans,1))  )
            # q_inj = (sum(qinj_expr_1netw[j,1] for j in 1:size(qinj_expr_1netw,1))+sum(qinj_expr_1trans[j,1] for j in 1:size(qinj_expr_1trans,1))+sum(qinj_expr_2trans[j,1] for j in 1:size(qinj_expr_2trans,1)) )
            # push!(p_injection,[p_inj])
            # push!(p_injection,q_inj)
            # q_inj = @NLexpression(acopf,sum(qinj_expr_nontrans[j,1] for j in 1:size(qinj_expr_trans,1))+sum(qinj_expr_trans[j,1] for j in 1:size(qinj_expr_trans,1)))

            # @constraint(acopf,sum(pg[j,1] for j in 1:size(pg,1))
            #     +sum(pg_RES[j,1] for j in 1:size(pg_RES,1))
            #     +sum(load_shed[j,1] for j in 1:size(load_shed,1))
            #     -sum(spill[j,1] for j in 1:size(spill,1))
            #     # -sum(p_chrg[j,1] for j in 1:size(p_chrg,1))
            #     # +sum(p_dischrg[j,1] for j in 1:size(p_dischrg,1))
            #     ==
            #     (sum(pinj_expr_1netw[j,1] for j in 1:size(pinj_expr_1netw,1))+sum(pinj_expr_1trans[j,1] for j in 1:size(pinj_expr_1trans,1))+sum(pinj_expr_2trans[j,1] for j in 1:size(pinj_expr_2trans,1))  )
            #     +sum(pd[j,1] for j in 1:size(pd,1))
            #       # +sum(p_flx_inc[j,1] for j in 1:size(p_flx_inc,1))
            #       # -sum(p_flx_dec[j,1] for j in 1:size(p_flx_dec,1))
            #     )
            #     @constraint(acopf,sum(qg[j,1] for j in 1:size(qg,1))
            #     +sum(shunt_expr[j,1] for j in 1:size(shunt_expr,1))
            #     ==
            #      (sum(qinj_expr_1netw[j,1] for j in 1:size(qinj_expr_1netw,1))+sum(qinj_expr_1trans[j,1] for j in 1:size(qinj_expr_1trans,1))+sum(qinj_expr_2trans[j,1] for j in 1:size(qinj_expr_2trans,1)) )
            #     +sum(qd[j,1] for j in 1:size(qd,1))   )
            #     # @NLconstraint(acopf,sum(qg[j,1] for j in 1:size(qg,1))==q_inj+sum(qd[j,1] for j in 1:size(qd,1))   )


            # end

            # @NLconstraint(acopf,sum(qg[j,1] for j in 1:size(qg,1))-(sum(qd[j,1] for j in 1:size(qd,1)))+(sum(bii_sh[j,1] for j in 1:size(bii_sh,1))*(e[s,t,nd_num]^2+f[s,t,nd_num]^2))==q_inj)

            exp = string("Node_$i-","Sc_$s-","TP_$t")
            # con_exp[:pb_p][exp] = p_inj
            # con_exp[:pb_q][exp] = q_inj
        end
    end
end

#

@constraint(acopf, active_poewr_balance_normal[s in 1:nSc, t in 1:nTP, b in 1:nBus],

 reduce(+, (Pg[s,t,i] for i in findall(x->x==b,bus_data_gsheet) if ~isempty(findall(x->x==b,bus_data_gsheet))); init=0)
 +
 reduce(+, (prof_PRES[s,t,i] for i in findall(x->x==b,RES_bus) if ~isempty(findall(x->x==b,RES_bus))); init=0)
 +
 reduce(+, (pen_lsh[s,t,i] for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)
 -
 reduce(+, (pen_ws[s,t,i] for i in findall(x->x==b,RES_bus) if ~isempty(findall(x->x==b,RES_bus))); init=0)
 # -
 # reduce(+, (p_ch[s,t,i] for i in findall(x->x==b,nd_Str_active) if ~isempty(findall(x->x==b,nd_Str_active))); init=0)
 # +
 # reduce(+, (p_dis[s,t,i] for i in findall(x->x==b,nd_Str_active) if ~isempty(findall(x->x==b,nd_Str_active))); init=0)
 +
 reduce(+, (Pg_neg[s,t,i] for i in findall(x->x==b,neg_gen_bus) if haskey(new_data, "negGen") && ~isempty(findall(x->x==b,neg_gen_bus))); init=0)


  # ==reduce(+, (pinj_dict[[s,t,b,node_data[b].node_cnode[j]]] for j in 1:size(node_data[b].node_num,1) if ~isempty(node_data[b].node_num)); init=0)
  ==reduce(+, (pinj_dict[[s,t,b,j]] for j in node_data[b].node_cnode if ~isempty(node_data[b].node_num)); init=0)

  +
  # reduce(+, (pinj_dict[[s,t,b,node_data_trans[b,1].node_cnode[j]]] for j in 1:size(node_data_trans[b,1].node_num,1) if ~isempty(node_data_trans[b,1].node_num)); init=0)
  reduce(+, (pinj_dict[[s,t,b,j]] for j in node_data_trans[b,1].node_cnode if ~isempty(node_data_trans[b,1].node_num)); init=0)

  # reduce(+, (pinj_dict[[s,t,b,node_data[b].node_cnode[j]]] for j in 1:size(node_data[b].node_num,1) if ~isempty(node_data[b].node_num); init=0)
  # sum(pinj_dict[[s,t,b,node_data[b].node_cnode[j]]] for j in 1:size(node_data[b].node_num,1) )
  +
  reduce(+, (prof_ploads[i,t]  for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)
  +
  reduce(+, (p_fl_inc[s,t,i] for i in findall(x->x==b,nd_fl) if ~isempty(findall(x->x==b,nd_fl))); init=0)
  -
  reduce(+, (p_fl_dec[s,t,i] for i in findall(x->x==b,nd_fl) if ~isempty(findall(x->x==b,nd_fl))); init=0)


      )


      @constraint(acopf, reactive_poewr_balance_normal[s in 1:nSc, t in 1:nTP, b in 1:nBus],

       reduce(+, (Qg[s,t,i] for i in findall(x->x==b,bus_data_gsheet) if ~isempty(findall(x->x==b,bus_data_gsheet))); init=0)
       +
       reduce(+, (tan(acos(power_factor))*pen_lsh[s,t,i] for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)
        # ==reduce(+, (qinj_dict[[s,t,b,node_data[b].node_cnode[j]]] for j in 1:size(node_data[b].node_num,1) if ~isempty(node_data[b].node_num)); init=0)
        +
        reduce(+, (Qg_neg[s,t,i] for i in findall(x->x==b,neg_gen_bus) if haskey(new_data, "negGen") && ~isempty(findall(x->x==b,neg_gen_bus))); init=0)


        ==reduce(+, (qinj_dict[[s,t,b,j]] for j in node_data[b].node_cnode if ~isempty(node_data[b].node_num)); init=0)

        +
        # reduce(+, (qinj_dict[[s,t,b,node_data_trans[b,1].node_cnode[j]]] for j in 1:size(node_data_trans[b,1].node_num,1) if ~isempty(node_data_trans[b,1].node_num)); init=0)
        reduce(+, (qinj_dict[[s,t,b,j]] for j in node_data_trans[b,1].node_cnode if ~isempty(node_data_trans[b,1].node_num)); init=0)

        # sum(qinj_dict[[s,t,b,node_data[b].node_cnode[j]]] for j in 1:size(node_data[b].node_num,1) )
        +
        reduce(+, (prof_qloads[i,t]  for i in findall(x->x==b,bus_data_lsheet) if ~isempty(findall(x->x==b,bus_data_lsheet))); init=0)

        -
        reduce(+, (nw_shunts[i].shunt_bsh0*(e[s,t,b]^2+f[s,t,b]^2)  for i in findall(x->x==b,rdata_shunts[:,1]) if ~isempty(findall(x->x==b,rdata_shunts[:,1]))); init=0)
        +
        reduce(+, (q_fl_inc[s,t,i] for i in findall(x->x==b,nd_fl) if ~isempty(findall(x->x==b,nd_fl))); init=0)
        -
        reduce(+, (q_fl_dec[s,t,i] for i in findall(x->x==b,nd_fl) if ~isempty(findall(x->x==b,nd_fl))); init=0)

            )


# @NLconstraint(acopf, line_flow_normal[s in 1:nSc, t in 1:nTP, b in 1:nBus, j in 1:size(node_data[b].node_num,1); ~isempty(node_data[b].node_num)],
# (pinj_dict[[s,t,b,node_data[b].node_cnode[j]]])^2+(qinj_dict[[s,t,b,node_data[b].node_cnode[j]]])^2<=(node_data[b,1].node_smax[j,1])^2
# )
# @NLconstraint(acopf, line_flow_normal[s in 1:nSc, t in 1:nTP, b in 1:nBus, j in node_data[b].node_cnode; ~isempty(node_data[b].node_num)],
# (pinj_dict[[s,t,b,j]])^2+(qinj_dict[[s,t,b,j]])^2<=(node_data[b,1].node_smax[findall(x->x==j, node_data[b].node_cnode)[1],1])^2
# )

line_flow_normal_s=@NLconstraint(acopf, [s in 1:nSc, t in 1:nTP, l in 1:nLines],
(pinj_dict_sr[[s,t,idx_from_line[l],idx_to_line[l]]])^2+(qinj_dict_sr[[s,t,idx_from_line[l],idx_to_line[l]]])^2<=(nw_lines[l].line_Smax_A)^2
)
line_flow_normal_r=@NLconstraint(acopf, [s in 1:nSc, t in 1:nTP, l in 1:nLines],
(pinj_dict_sr[[s,t,idx_to_line[l],idx_from_line[l]]])^2+(qinj_dict_sr[[s,t,idx_to_line[l],idx_from_line[l]]])^2<=(nw_lines[l].line_Smax_A)^2
)

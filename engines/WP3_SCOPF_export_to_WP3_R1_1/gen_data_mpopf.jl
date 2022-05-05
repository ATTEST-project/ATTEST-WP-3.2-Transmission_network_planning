# ------------------- Formatting of Gen Data------------------------------------
#-------------------------------------------------------------------------------
#--------------------------- Gen Data ------------------------------------------
dim_Gen    = (length(1:nGens),length(1:nTP))
Pg_max     = zeros(Float64,dim_Gen)
Pg_min     = zeros(Float64,dim_Gen)
Qg_max     = zeros(Float64,dim_Gen)
Qg_min     = zeros(Float64,dim_Gen)
cA_gen         = zeros(Float64,dim_Gen)
cB_gen         = zeros(Float64,dim_Gen)
cC_gen         = zeros(Float64,dim_Gen)
bus_data_gsheet = [nw_gens[j].gen_bus_num for j in 1:nGens]                      # Buses order in gen sheet
pg_max = [nw_gens[j].gen_P_max for j in 1:nGens]                                 # Maximum and minimum values are in SI units
pg_min = [nw_gens[j].gen_P_min for j in 1:nGens]
qg_max = [nw_gens[j].gen_Qg_max for j in 1:nGens]
qg_min = [nw_gens[j].gen_Qg_min for j in 1:nGens]

# bus_data_gcost = [nw_gens[j].gen_bus_num for j in 1:nGens]
cost_a_gen = [nw_gens[j].gcost_a for j in 1:nGens]                              # Cost of generation (quadratic and linear) is in SI units
cost_b_gen = [nw_gens[j].gcost_b for j in 1:nGens]
cost_c_gen = [nw_gens[j].gcost_c for j in 1:nGens]


# for i in 1:nGens
#     ngen  = bus_data_gsheet[i,1]                                                 # Node to which the gen is connected
#     Pg_max[i,:] = transpose(repeat([pg_max[i,1]],nTP))                           # In future, the value of pg_max has to be changed at this location
#     Pg_min[i,:] = transpose(repeat([pg_min[i,1]],nTP))
#     Qg_max[i,:] = transpose(repeat([qg_max[i,1]],nTP))
#     Qg_min[i,:] = transpose(repeat([qg_min[i,1]],nTP))
#     cA_gen[i,:]     = transpose(repeat([cost_a_gen[i,1]],nTP))
#     cB_gen[i,:]     = transpose(repeat([cost_b_gen[i,1]],nTP))
#     cC_gen[i,:]     = transpose(repeat([cost_c_gen[i,1]],nTP))
# end

#---------------- Active power curtailment of DGs ------------------------------
# i_slck = findall(x->x==3,rdata_buses[:,2])                                       # Index of bus which is considered as slack bus (strictly speaking, slack bus is considered in power flow algorithm!)
# nd_slck = convert.(Int64,rdata_buses[i_slck,1])                                  # Node of slack bus
# ncurt_gen = nGens-size(nd_slck,1)                                                # Number of generators whose power can be curtailed
# nd_curt_gen = convert.(Int64,setdiff(rdata_gens[:,1],nd_slck))                   # Nodes to which those DGs are connected whose power can be curtailed!

# idx_curt_status = findall(x->x=="status_curt",rheader_gens)
# i_ncurt_gens = findall(x->x==0,rdata_gens[:,idx_curt_status])                    # Index of generator whose power cannot be curtailed!
# i_curt_gens  = findall(x->x==1,rdata_gens[:,idx_curt_status])                    # Index of generator whose power can be curtailed!
# nNcurt_gen = size(i_ncurt_gens,1)
# nCurt_gen  = size(i_curt_gens,1)
# nd_ncurt_gen = convert.(Int64,rdata_gens[i_ncurt_gens,1])                        # Nodes to which those DGs are connected whose power cannot be curtailed!
# nd_curt_gen  = convert.(Int64,rdata_gens[i_curt_gens,1])                         # Nodes to which those DGs are connected whose power can be curtailed!

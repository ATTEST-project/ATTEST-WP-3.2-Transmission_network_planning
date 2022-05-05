#------------------- Formatting of Load Data------------------------------------
#-------------------------------------------------------------------------------
#--------------------------- Load Data -----------------------------------------
bus_data_lsheet  = [array_loads[j].load_bus_num for j in 1:nLoads]                  # Buses order in load sheet
cost_flex_load        = [array_loads[j].load_ShCost for j in 1:nLoads]
cost_flex_load_q        = [array_loads[j].load_ShCost_q for j in 1:nLoads] 
# idx_Gs_lsheet = findall(x->x=="Gs (MW)",rheader_loads)
# idx_Bs_lsheet = findall(x->x=="Bs (MVAr)",rheader_loads)
idx_St_lsheet = findall(x->x=="ShFrOK",rheader_loads)                            # Index of status in load sheet!

iFl     =  findall(x->x==1,rdata_loads[:,idx_St_lsheet])                           # Index of flexible loads
nFl     =  size(findall(x->x==1,rdata_loads[:,idx_St_lsheet]),1)                   # Number of flexible loads in a system
nd_fl   =  convert.(Int64,rdata_loads[findall(x->x==1,rdata_loads[:,idx_St_lsheet]),1]) # Nodes to which flexible loads are connected. Node data is taken from the power profile sheet.

# ------------------- Formatting of Load Cost Data---------------------------
#-------------------------------------------------------------------------------
# dim_Fl    = (length(1:nFl),length(1:nTP))
# cfl_inc   = zeros(Float64,dim_Fl)                                                # cfl = cost of flexible loads
# cfl_dec   = zeros(Float64,dim_Fl)
#
# cost_load_inc    = [nw_loads[iFl[j,1]].load_cost_inc*sbase for j in 1:nFl]       # Here, if the time step is not hour and cost is given in $/hr, then do we have to multiply with the step or not?
# cost_load_dec    = [nw_loads[iFl[j,1]].load_cost_dec*sbase for j in 1:nFl]

# for i in 1:nFl
#     nfl  = nd_fl[i,1]                                                             # Node to which the flexible load is connected
#     cfl_inc[i,:]     = transpose(repeat([cost_load_inc[i,1]],nTP))
#     cfl_dec[i,:]     = transpose(repeat([cost_load_dec[i,1]],nTP))
# end
# #-------------------------------------------------------------------------------
# # Assuming that flexible load cost will be different in each time period and for each scenario
# dim_Fl = (length(1:nSc),length(1:nTP),length(1:nFl))
# prof_cost_inc_fl    = zeros(Float64,dim_Fl)
# prof_cost_dec_fl    = zeros(Float64,dim_Fl)
#
# for i in 1:nFl
#     nd      = nd_fl[i,1]                                                         # Node num is independant of time period and scenario
#     ifl     = iFl[i,1]                                                           # Index of Active flexible load in a Load sheet
#     for s in 1:nSc
#         load_cost_inc = cfl_inc[i,1:end]
#         load_cost_dec = cfl_dec[i,1:end]
#
#         prof_cost_inc_fl[s,:,i]    = load_cost_inc
#         prof_cost_dec_fl[s,:,i]    = load_cost_dec
#     end
# end
# cost_load_inc = prof_cost_inc_fl
# cost_load_dec = prof_cost_dec_fl

# Status of energy storage device (status = 0, ESD is not present; status = 1, ESD is present)
idx_St_Strsheet = findall(x->x=="Status",rheader_storage)                        # Index of Status (St) in Storage (Str) Sheet
iStr_active     = findall(x->x==1,rdata_storage[:,idx_St_Strsheet])
nStr_active     = size(findall(x->x==1,rdata_storage[:,idx_St_Strsheet]),1)                   # Number of Active Storages in a system
nd_Str_active   = convert.(Int64,rdata_storage[findall(x->x==1,rdata_storage[:,idx_St_Strsheet]),1])
# ------------------- Formatting of Storage Cost Data---------------------------
#-------------------------------------------------------------------------------
dim_Str    = (length(1:nStr_active),length(1:nTP))
cA_str     = zeros(Float64,dim_Str)
cB_str     = zeros(Float64,dim_Str)
cC_str     = zeros(Float64,dim_Str)

bus_data_Ssheet  = [nw_storage[iStr_active[j,1]].storage_bus for j in 1:nStr_active]                   # Buses order in storage sheet
# bus_data_Strcost = [nw_Strcost[iStr_active[j,1]].str_cost_bus for j in 1:nStr_active]
cost_a_str = [nw_storage[iStr_active[j,1]].storage_cost_a for j in 1:nStr_active]                # Here, if the time step is not hour and cost is given in $/hr, then do we have to multiply with the step or not?
cost_b_str = [nw_storage[iStr_active[j,1]].storage_cost_b for j in 1:nStr_active]
cost_c_str = [nw_storage[iStr_active[j,1]].storage_cost_c for j in 1:nStr_active]

#-------------------------------------------------------------------------------
# Assuming that storage cost will be different in each time period and for each scenario
# To run the following code, first the file storage_data_mpopf has to be run
# for i in 1:nStr_active
#     nstr  = bus_data_Ssheet[i,1]      # Node to which the storage is connected
#     cA_str[i,:]     = transpose(repeat([cost_a_str[i,1]],nTP))
#     cB_str[i,:]     = transpose(repeat([cost_b_str[i,1]],nTP))
#     cC_str[i,:]     = transpose(repeat([cost_c_str[i,1]],nTP))
# end
#
#
# dim_Str = (length(1:nSc),length(1:nTP),length(1:nStr_active))
# prof_costA_str    = zeros(Float64,dim_Str)
# prof_costB_str    = zeros(Float64,dim_Str)
# prof_costC_str    = zeros(Float64,dim_Str)
# for i in 1:nStr_active
#     nd      = nw_storage[iStr_active[i,1]].storage_bus                                          # Node num is independant of time period and scenario
#     nd_num  = unique(nd)
#     nd_num  = nd_num[1,1]
#     iStr    = findall(x->x==nd_num,bus_data_Ssheet)                              # Index of storage in a Storage sheet
#     for s in 1:nSc
#         str_costA = cA_str[iStr,1:end]
#         str_costB = cB_str[iStr,1:end]
#         str_costC = cC_str[iStr,1:end]
#
#         prof_costA_str[s,:,i]    = str_costA
#         prof_costB_str[s,:,i]    = str_costB
#         prof_costC_str[s,:,i]    = str_costC
#     end
# end
# cost_a_str = prof_costA_str
# cost_b_str = prof_costB_str
# cost_c_str = prof_costC_str

#-------------------------------------------------------------------------------

sheetname  = "wind_scenarios";
# sheetname  = "wind_scenarios_20";
# sheetname  = "wind_scenario_8";
fields     = ["scenarios","t1","t2","t3","t4","t5","t6","t7","t8","t9","t10","t11","t12","t13","t14","t15","t16","t17","t18","t19","t20","t21","t22","t23","t24"];                                    # Fields that have to be read from the file
raw_data = ods_readall(filename_scenario;sheetsNames=[sheetname],innerType="Matrix")
raw_data = raw_data[sheetname]   # Conversion from Dict to Array
header    = raw_data[1,:]
data_scen     = raw_data[2:end,2:end]





# prof_PRES=[]
# for i in 1:size(RES_bus,1)
#     push!(prof_PRES,RES_cap[i].*data_scen[1:nSc,1:nTP])
# end
# RES_profile[:,:,size(RES_bus,1)]=prof_PRES[1:size(RES_bus,1)][1:nSc][1:nTP]
#     for s in 1:nSc
#         for i in 1:size(RES_bus,1)
#             for t in 1:nTP
#  prof_PRES[s,t,i] .= scen_data[s,t]
# end
# end
# end

# # prof_Qloads = zeros(Float64,dim_Load)
# for i in 1:nBus
#
#          nd      = bus_data_lsheet[i,1]                                               # Node num is independant of time period and scenario
#          nd_num  = unique(nd)
#          nd_num  = nd_num[1,1]
#          i_res   = findall(x->x==nd_num,RES_bus)
#          # for s in 1:nSc
#               prof_PRES[1:end,1:end,i] = scen_data[i_res,2:end]
#          #     prof_PRES[s,1:nTP,i] .= scen_data[s,2:end]
#          #
#          #
#          # end
#      end
# for i in 1:nLoads
#     nd      = bus_data_lsheet[i,1]                                               # Node num is independant of time period and scenario
#     nd_num  = unique(nd)
#     nd_num  = nd_num[1,1]
#     iload   = findall(x->x==nd_num,nw_pPrf_data_load[:,1])                       # Index of load in a Load sheet
#     for s in 1:nSc
#         # nd_pPrf = nw_pPrf[iload,2:end]./sbase                                  # Here, the data is being extracted from the profile sheet. However, later
#         #                                                                        # when the scenarios will be created, the data has to be extracted from scenario profiles
#         # nd_qPrf = nw_qPrf[iload,2:end]./sbase
#
#         if nTP == 1                                                              # For time period equal to 1, pick the data from Loads sheet
#             # nd_pPrf_load = nw_loads[i].load_P./sbase
#             # nd_qPrf_load = nw_loads[i].load_Q./sbase
#             nd_pPrf_load = nw_loads[iload[1,1]].load_P./sbase
#             nd_qPrf_load = nw_loads[iload[1,1]].load_Q./sbase
#             prof_Ploads[s,1:nTP,i] .= nd_pPrf_load
#             prof_Qloads[s,1:nTP,i] .= nd_qPrf_load
#
#         else                                                                     # For time period, greater than 1, pick the data from profile sheet
#             nd_pPrf_load = nw_pPrf_data_load[iload,2:nTP+1]./sbase                 # Here, the data is being extracted from the profile sheet. However, later
#                                                                                  # when the scenarios will be created, the data has to be extracted from scenario profiles
#             nd_qPrf_load = nw_qPrf_data_load[iload,2:nTP+1]./sbase
#             prof_Ploads[s,1:nTP,i] = nd_pPrf_load
#             prof_Qloads[s,1:nTP,i] = nd_qPrf_load
#         end
#     end
# end

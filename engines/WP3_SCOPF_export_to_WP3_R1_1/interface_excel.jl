# This code reads each individual sheet of an ODS file and then process the available
# data in order to save the inforamtion related to each bus, line, load, gen etc.

# For this program to work, the number as well type of enteries mentioned in the
# field variable and data_type struct variables MUST be the same.
#---------------------------Formatting the Buses Data---------------------------
sheetname  = "Buses";
fields  = ["Bus_N","Bus_Type","Area","V_Nom (kV)","V_max (pu)","V_min (pu)", "V_init_re (pu)","V_init_im (pu)" ]; # Fields that have to be read from the file
raw_data = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
raw_data = raw_data[sheetname]   # Conversion from Dict to Array
header    = raw_data[1,:]
data      = raw_data[2:end,1:size(header,1)]
data      = convert(Array{Float64}, data)
data_cont = zeros(size(fields,1))               # data_cont = Data Container
nBus      = Int64(size(data,1))
global array_bus = Array{Bus}(undef,nBus,1)

array_bus = data_reader(array_bus,nBus,fields,header,data,data_cont,Bus)
rheader_buses = header    # Exporting raw header of buses sheet
rdata_buses = data        # Exporting raw data of buses sheet
raw_data = nothing
header = nothing
data = nothing

#----------------------------Formatting the Lines Data--------------------------
sheetname  = "Lines";
fields  = ["From","To","g (pu)","b (pu)","g_sh (pu)","b_sh (pu)","RATE_A","br_status"]; # Fields that have to be read from the file
raw_data = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
raw_data = raw_data[sheetname]   # Conversion from Dict to Array

header    = raw_data[1,:]
data      = raw_data[2:end,:]
data      = convert(Array{Float64}, data)
#------------ Code for handling the lines whose status is zero -----------------
#------- This code will eliminate those lines whose status is set to zero-------
idx_br_status = findall(x->x=="br_status",header)
open_branches = findall(x->x==0,data[:,idx_br_status])
idx_open_branches = []
for i in 1:size(open_branches,1)
    push!(idx_open_branches,open_branches[i][1])
end
idx_closed_branches = setdiff(collect(1:size(data,1)),idx_open_branches)
# idx_closed_branches = setdiff(collect(1:size(data,1)),2)
data = data[idx_closed_branches,:]
data_line_prim=data
# data_cont = zeros(size(fields,1))               # data_cont = Data Container
# nLines_prim    = Int64(size(data_line_prim,1))
# global array_lines_prim = Array{Line}(undef,nLines_prim,1)
#
# array_lines_prim = data_reader(array_lines_prim,nLines_prim,fields,header,data_line_prim,data_cont,Line)

# rheader_lines = header    # Exporting raw header of lines sheet
# rdata_lines = data        # Exporting raw data of lines sheet
#

#------------------- Code for handling the parallel lines ----------------------
idx_plines = []                                                                  # Indices of parallel lines
for i in 1:size(data,1)
    line = transpose(data[i,1:2])
    plines = line.-data[:,1:2]
    i0_from = findall(x->x==0.0,plines[:,1])
    i0_to   = findall(x->x==0.0,plines[:,2])
    ilines  = intersect(i0_from,i0_to)
    # ilines  = findall(x->x==0.0,plines[:,1])
    if isempty(idx_plines)
        push!(idx_plines,ilines)
    elseif isempty(findall(x->x==ilines,idx_plines))
        push!(idx_plines,ilines)
    else
        # do nothing!
    end
end
new_line_data = []
for i in 1:size(idx_plines,1)
    ilines = idx_plines[i,1]
    y_line_eq = sum(data[ilines,3]+data[ilines,4]im,dims=1)
    y_eq = sum(data[ilines,5]+data[ilines,6]im,dims=1)
    amp_eq_A = sum(data[ilines,7],dims=1)
    # amp_eq_B = sum(data[ilines,8],dims=1)
    # amp_eq_C = sum(data[ilines,9],dims=1)
    nline_data = [transpose(data[ilines[1,1],1:2]) real(y_line_eq) imag(y_line_eq) real(y_eq) imag(y_eq) amp_eq_A transpose(data[ilines[1,1],8:end])]
    push!(new_line_data,nline_data)
end
data = vcat(new_line_data...)
##----------------------------------------------------------------------------##
data_cont = zeros(size(fields,1))               # data_cont = Data Container
nLines    = Int64(size(data,1))
global array_lines = Array{Line}(undef,nLines,1)

array_lines = data_reader(array_lines,nLines,fields,header,data,data_cont,Line)

rheader_lines = header    # Exporting raw header of lines sheet
rdata_lines = data        # Exporting raw data of lines sheet

raw_data = nothing
header = nothing
data = nothing
#------------------------ Formatting the Loads Data-----------------------------
sheetname  = "Loads";
fields  = ["Bus_N","Pd (pu)","Qd (pu)","ShFr","ShFrMin","ShFrMax","ShFrOK","ShCost","ShCost_q"]; # Fields that have to be read from the file
raw_data = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
raw_data = raw_data[sheetname]   # Conversion from Dict to Array

header    = raw_data[1,:]
data      = raw_data[2:end,:]
data      = convert(Array{Float64}, data)
data_cont = zeros(size(fields,1))               # data_cont = Data Container
nLoads    = Int64(size(data,1))
global array_loads = Array{Loads}(undef,nLoads,1)

array_loads = data_reader(array_loads,nLoads,fields,header,data,data_cont,Loads)
rheader_loads = header    # Exporting raw header of loads sheet
rdata_loads   = data        # Exporting raw data of loads sheet
raw_data = nothing
header   = nothing
data     = nothing

#------------------------- Formating the Transformers
sheetname  = "Transformers";
fields  = ["From","To","g","b","bsh","ratio","rmin","rmax","Snom","BStatus0"];
raw_data = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
raw_data = raw_data[sheetname]   # Conversion from Dict to Array
header    = raw_data[1,:]
data      = raw_data[2:end,1:size(header,1)]
data      = convert(Array{Float64}, data)
#---------------handling parallel Transformers----------
idx_ptranses = []                                                                  # Indices of parallel lines
for i in 1:size(data,1)
    trans = transpose(data[i,1:2])
    ptranses = trans.-data[:,1:2]
    i0_from = findall(x->x==0.0,ptranses[:,1])
    i0_to   = findall(x->x==0.0,ptranses[:,2])
    int_transes  = intersect(i0_from,i0_to)
    # ilines  = findall(x->x==0.0,plines[:,1])
    if isempty(idx_ptranses)
        push!(idx_ptranses,int_transes)
    elseif isempty(findall(x->x==int_transes,idx_ptranses))
        push!(idx_ptranses,int_transes)
    else
        # do nothing!
    end
end
new_trans_data = []
for i in 1:size(idx_ptranses,1)
    int_transes = idx_ptranses[i,1]
    y_trans_eq = sum(data[int_transes,3]+data[int_transes,4]im,dims=1)
    y_eq = sum(data[int_transes,5]im,dims=1)
    amp_eq_A = sum(data[int_transes,9],dims=1)
    # amp_eq_B = sum(data[ilines,8],dims=1)
    # amp_eq_C = sum(data[ilines,9],dims=1)
    ntrans_data = [transpose(data[int_transes[1,1],1:2]) real(y_trans_eq) imag(y_trans_eq) imag(y_eq) transpose(data[int_transes[1,1],6:8])  amp_eq_A transpose(data[int_transes[1,1],10])]
    push!(new_trans_data,ntrans_data)
end
data = vcat(new_trans_data...)

#------
data_cont = zeros(size(fields,1))               # data_cont = Data Container
nTrans      = Int64(size(data,1))
global array_transformer = Array{Transf}(undef,nTrans,1)

array_trans = data_reader(array_transformer,nTrans,fields,header,data,data_cont,Transf)
rheader_transformers = header    # Exporting raw header of buses sheet
rdata_transformers = data        # Exporting raw data of buses sheet
raw_data = nothing
header = nothing
data = nothing
#------------------------ Formatting the Gens Data------------------------------
sheetname  = "Gens";
# sheetname  = "Gens_new";

fields  = ["Bus","Pg (pu)","Qg (pu)","Q_max (pu)","Q_min (pu)","V_set (pu)","P_max (pu)","P_min (pu)"
           ,"cost_a","cost_b","cost_c"]; # Fields that have to be read from the file
raw_data = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
raw_data = raw_data[sheetname]   # Conversion from Dict to Array

header    = raw_data[1,:]
data      = raw_data[2:end,:]
data      = convert(Array{Float64}, data)
#---------------handling parallel Generators----------
idx_pgens = []                                                                  # Indices of parallel lines
for i in 1:size(data,1)
    # gens = data[i,1]
    pgens = data[:,1].-data[i,1]
    id_pgens = findall(x->x==0.0,pgens[:,1])
    # i0_to   = findall(x->x==0.0,ptranses[:,2])
    # int_transes  = intersect(i0_from,i0_to)
    # ilines  = findall(x->x==0.0,plines[:,1])
    if isempty(idx_pgens)
        push!(idx_pgens,id_pgens)
    elseif isempty(findall(x->x==id_pgens,idx_pgens))
        push!(idx_pgens,id_pgens)
    else
        # do nothing!
    end
end
new_gen_data = []
for i in 1:size(idx_pgens,1)
    igens = idx_pgens[i,1]
    qmax = sum(data[igens,4],dims=1)
    qmin = sum(data[igens,5],dims=1)
    pmax = sum(data[igens,7],dims=1)
    pmin = sum(data[igens,8],dims=1)

    # y_eq = sum(data[int_transes,6]im,dims=1)
    # amp_eq_A = sum(data[int_transes,9],dims=1)
    # amp_eq_B = sum(data[ilines,8],dims=1)
    # amp_eq_C = sum(data[ilines,9],dims=1)
    ngens_data = [data[igens[1,1],1] transpose(data[igens[1,1],2:3])  qmax qmin transpose(data[igens[1,1],6])  pmax pmin transpose(data[igens[1,1],9:11])]
    push!(new_gen_data,ngens_data)
end
data = vcat(new_gen_data...)
#-----
data_cont = zeros(size(fields,1))               # data_cont = Data Container
nGens    = Int64(size(data,1))
global array_gens = Array{Gens}(undef,nGens,1)

array_gens = data_reader(array_gens,nGens,fields,header,data,data_cont,Gens)
rheader_gens = header    # Exporting raw header of gens sheet
rdata_gens = data        # Exporting raw data of gens sheet
raw_data = nothing
header = nothing
data = nothing

#---------------------- Formatting the gen cost data ---------------------------
# sheetname  = "Gen_cost";
# sheetname  = "Gen_cost_new";
# fields  = ["Bus","cost_a","cost_b","cost_c"];                                    # Fields that have to be read from the file
# raw_data = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
# raw_data = raw_data[sheetname]   # Conversion from Dict to Array
#
# header    = raw_data[1,:]
# data      = raw_data[2:end,:]
# data      = convert(Array{Float64}, data)
# data_cont = zeros(size(fields,1))               # data_cont = Data Container
# nGens     = Int64(size(data,1))
# global array_gcost = Array{gen_cost}(undef,nGens,1)
#
# array_gcost   = data_reader(array_gcost,nGens,fields,header,data,data_cont,gen_cost)
# rheader_gcost = header      # Exporting raw header of gens sheet
# rdata_gcost   = data        # Exporting raw data of gens sheet
# raw_data = nothing
# header   = nothing
# data     = nothing

#------------------- Formatting the Active Profiles data -----------------------
sheetname  = "P_Profiles_Load";
# sheetname  = "P_Profiles_Load_new";
# sheetname  = "P_Profiles_Load_incr";
# fields     = ["Bus","t1","t2","t3","t4","t5","t6","t7","t8","t9","t10","t11","t12","t13","t14","t15","t16","t17","t18","t19","t20","t21","t22","t23","t24"];                                    # Fields that have to be read from the file
# fields     = ["Bus","t1"];                                    # Fields that have to be read from the file
raw_data   = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
raw_data   = raw_data[sheetname]   # Conversion from Dict to Array

header    = raw_data[1,:]
data      = raw_data[2:end,:]
data      = convert(Array{Float64}, data)
data_cont = zeros(size(fields,1))               # data_cont = Data Container
nPprf_load     = Int64(size(data,1))
# global array_pProfiles = Array{profile_P}(undef,nPprf,1)
#
# array_pProfiles  = data_reader(array_pProfiles,nPprf,fields,header,data,data_cont,profile_P)
rheader_pProfile_load = header      # Exporting raw header of gens sheet
rdata_pProfile_load   = data        # Exporting raw data of gens sheet
raw_data = nothing
header   = nothing
data     = nothing

#------------------- Formatting the Reactive Profiles data ---------------------
sheetname  = "Q_Profiles_Load";
# fields     = ["Bus","t1","t2","t3","t4","t5","t6","t7","t8","t9","t10","t11","t12","t13","t14","t15","t16","t17","t18","t19","t20","t21","t22","t23","t24"];                                    # Fields that have to be read from the file
# fields     = ["Bus","t1"];                                    # Fields that have to be read from the file
raw_data   = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
raw_data   = raw_data[sheetname]   # Conversion from Dict to Array

header    = raw_data[1,:]
data      = raw_data[2:end,:]
data      = convert(Array{Float64}, data)
data_cont = zeros(size(fields,1))               # data_cont = Data Container
nQprf_load     = Int64(size(data,1))
# global array_qProfiles = Array{profile_Q}(undef,nQprf,1)
#
# array_pProfiles  = data_reader(array_qProfiles,nQprf,fields,header,data,data_cont,profile_Q)
rheader_qProfile_load = header      # Exporting raw header of gens sheet
rdata_qProfile_load   = data        # Exporting raw data of gens sheet
raw_data = nothing
header   = nothing
data     = nothing

#--------------------Formatting the shunts data
sheetname  = "shunts";
fields  = ["Bus","bsh0","bshmin","bshmax"]
raw_data = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
raw_data = raw_data[sheetname]   # Conversion from Dict to Array
header    = raw_data[1,:]
data      = raw_data[2:end,1:size(header,1)]
data      = convert(Array{Float64}, data)
data_cont = zeros(size(fields,1))               # data_cont = Data Container
nShnt     = Int64(size(data,1))
global array_shunt = Array{shunts}(undef,nShnt,1)

array_shunt = data_reader(array_shunt,nShnt,fields,header,data,data_cont,shunts)
rheader_shunts = header    # Exporting raw header of buses sheet
rdata_shunts = data        # Exporting raw data of buses sheet
raw_data = nothing
header = nothing
data = nothing

#------------- Formatting the Active Generation Profiles data ------------------
# sheetname  = "P_Profiles_Gen_Min";
# fields     = ["Bus","t1","t2","t3","t4","t5","t6","t7","t8","t9","t10","t11","t12","t13","t14","t15","t16","t17","t18","t19","t20","t21","t22","t23","t24"];                                    # Fields that have to be read from the file
# raw_data   = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
# raw_data   = raw_data[sheetname]   # Conversion from Dict to Array
#
# header     = raw_data[1,:]
# data       = raw_data[2:end,:]
# data       = convert(Array{Float64}, data)
# data_cont  = zeros(size(fields,1))               # data_cont = Data Container
# nPprf_gen_min = Int64(size(data,1))
# # global array_qProfiles = Array{profile_Q}(undef,nQprf,1)
# #
# # array_pProfiles  = data_reader(array_qProfiles,nQprf,fields,header,data,data_cont,profile_Q)
# rheader_pProfile_gen_min = header      # Exporting raw header of gens sheet
# rdata_pProfile_gen_min   = data        # Exporting raw data of gens sheet
# raw_data = nothing
# header   = nothing
# data     = nothing
#------------- Formatting the Active Generation Profiles data ------------------
# sheetname  = "P_Profiles_Gen_Max";
# fields     = ["Bus","t1","t2","t3","t4","t5","t6","t7","t8","t9","t10","t11","t12","t13","t14","t15","t16","t17","t18","t19","t20","t21","t22","t23","t24"];                                    # Fields that have to be read from the file
# raw_data   = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
# raw_data   = raw_data[sheetname]   # Conversion from Dict to Array
#
# header     = raw_data[1,:]
# data       = raw_data[2:end,:]
# data       = convert(Array{Float64}, data)
# data_cont  = zeros(size(fields,1))               # data_cont = Data Container
# nPprf_gen_max = Int64(size(data,1))
# # global array_qProfiles = Array{profile_Q}(undef,nQprf,1)
# #
# # array_pProfiles  = data_reader(array_qProfiles,nQprf,fields,header,data,data_cont,profile_Q)
# rheader_pProfile_gen_max = header      # Exporting raw header of gens sheet
# rdata_pProfile_gen_max   = data        # Exporting raw data of gens sheet
# raw_data = nothing
# header   = nothing
# data     = nothing

#------------- Formatting the Active Generation Profiles data ------------------
# sheetname  = "Q_Profiles_Gen_Min";
# fields     = ["Bus","t1","t2","t3","t4","t5","t6","t7","t8","t9","t10","t11","t12","t13","t14","t15","t16","t17","t18","t19","t20","t21","t22","t23","t24"];                                    # Fields that have to be read from the file
# raw_data   = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
# raw_data   = raw_data[sheetname]   # Conversion from Dict to Array
#
# header     = raw_data[1,:]
# data       = raw_data[2:end,:]
# data       = convert(Array{Float64}, data)
# data_cont  = zeros(size(fields,1))               # data_cont = Data Container
# nQprf_gen_min = Int64(size(data,1))
# # global array_qProfiles = Array{profile_Q}(undef,nQprf,1)
# #
# # array_pProfiles  = data_reader(array_qProfiles,nQprf,fields,header,data,data_cont,profile_Q)
# rheader_qProfile_gen_min = header      # Exporting raw header of gens sheet
# rdata_qProfile_gen_min   = data        # Exporting raw data of gens sheet
# raw_data = nothing
# header   = nothing
# data     = nothing
#------------- Formatting the Active Generation Profiles data ------------------
# sheetname  = "Q_Profiles_Gen_Max";
# fields     = ["Bus","t1","t2","t3","t4","t5","t6","t7","t8","t9","t10","t11","t12","t13","t14","t15","t16","t17","t18","t19","t20","t21","t22","t23","t24"];                                    # Fields that have to be read from the file
# raw_data   = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
# raw_data   = raw_data[sheetname]   # Conversion from Dict to Array
#
# header     = raw_data[1,:]
# data       = raw_data[2:end,:]
# data       = convert(Array{Float64}, data)
# data_cont  = zeros(size(fields,1))               # data_cont = Data Container
# nQprf_gen_max = Int64(size(data,1))
# # global array_qProfiles = Array{profile_Q}(undef,nQprf,1)
# #
# # array_pProfiles  = data_reader(array_qProfiles,nQprf,fields,header,data,data_cont,profile_Q)
# rheader_qProfile_gen_max = header      # Exporting raw header of gens sheet
# rdata_qProfile_gen_max   = data        # Exporting raw data of gens sheet
# raw_data = nothing
# header   = nothing
# data     = nothing

#------------------- Formatting the Reactive Profiles data ---------------------
sheetname  = "Base_MVA";
fields     = ["base_MVA"];                                    # Fields that have to be read from the file
raw_data   = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
raw_data   = raw_data[sheetname]   # Conversion from Dict to Array

header    = raw_data[1,:]
data      = raw_data[2:end,:]
data      = convert(Array{Float64}, data)
data_cont = zeros(size(fields,1))               # data_cont = Data Container
nSbase    = Int64(size(data,1))
global array_sbase = Array{base_mva}(undef,nSbase,1)

array_sbase  = data_reader(array_sbase,nSbase,fields,header,data,data_cont,base_mva)
rheader_sbase = header      # Exporting raw header of gens sheet
rdata_sbase   = data        # Exporting raw data of gens sheet
raw_data = nothing
header   = nothing
data     = nothing
#----------------------- Formatting the Storage data ---------------------------
sheetname  = "Storage";
fields     = ["Bus","Ps","Qs","Energy (MWh)","E_rating (MWh)","Charge_rating (MW)"
               ,"Discharge_rating (MW)","Charge_efficiency","Discharge_efficiency"
               ,"Thermal_rating (MVA)","Qmin (MVAr)","Qmax (MVAr)","R","X","P_loss"
               ,"Q_loss","Status","soc_initial","soc_min","soc_max","E_rating_min (MWh)"
               , "E_initial (MWh)","cost_a","cost_b","cost_c"];                                    # Fields that have to be read from the file
raw_data   = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
raw_data   = raw_data[sheetname]   # Conversion from Dict to Array

header    = raw_data[1,:]
data      = raw_data[2:end,:]
data      = convert(Array{Float64}, data)
data_cont = zeros(size(fields,1))               # data_cont = Data Container
nStr     = Int64(size(data,1))
global array_storage = Array{energy_storage}(undef,nStr,1)
#
array_storage   = data_reader(array_storage,nStr,fields,header,data,data_cont,energy_storage)
rheader_storage = header      # Exporting raw header of gens sheet
rdata_storage   = data        # Exporting raw data of gens sheet
raw_data = nothing
header   = nothing
data     = nothing

#---------------------- Formatting the gen cost data ---------------------------
# sheetname  = "Storage_cost";
# fields  = ["Bus","cost_a","cost_b","cost_c"];                                    # Fields that have to be read from the file
# raw_data = ods_readall(filename;sheetsNames=[sheetname],innerType="Matrix")
# raw_data = raw_data[sheetname]   # Conversion from Dict to Array
#
# header    = raw_data[1,:]
# data      = raw_data[2:end,:]
# data      = convert(Array{Float64}, data)
# data_cont = zeros(size(fields,1))               # data_cont = Data Container
# nStr      = Int64(size(data,1))
# global array_Strcost = Array{str_cost}(undef,nStr,1)
#
# array_Strcost   = data_reader(array_Strcost,nStr,fields,header,data,data_cont,str_cost)
# rheader_Strcost = header      # Exporting raw header of gens sheet
# rdata_Strcost   = data        # Exporting raw data of gens sheet
# raw_data = nothing
# header   = nothing
# data     = nothing

#--------------------------------- End -----------------------------------------

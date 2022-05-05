using JuMP,Ipopt,OdsIO,MathOptInterface,Plots, Dates
using JLD,JSON
# using SCIP       # It is not useful for our purpose. Mianly deals with the feasibility problem.
# using AmplNLWriter
# using Cbc

#-------------------Accessing current folder directory--------------------------
println(pwd());
cd(dirname(@__FILE__))
println(pwd());

# files = cd(readdir, string(pwd(),"\\Network_Data"))
#--------------------Read Data from the Excel file------------------------------

filename = "case5_bus_python_test.ods"
# filename = "case5_bus_new.ods"
# filename = "case60_bus_new_wind.ods"
filename_scenario= "scenario_gen.ods"
# filename_scenario= "scenario_gen.ods"
# filename = "case_34_baran_modf.ods"
power_factor=0.98


include("data_types.jl")      # Reading the structure of network related fields

include("data_types_contingencies.jl")
# include("data_types_scenarios.jl")
include("data_reader.jl")     # Function setting the data corresponding to each network quantity

include("interface_excel.jl") # Program saving all the inforamtion related to each entity of a power system

include("interface_excel_contingencies.jl")
# prt="Data are extracted "
display("Data are extracted from excel files")


RES_bus=4
nTP   = 1
RES_cap=5
# nRES=size(RES_bus,1)

# include("interface_excel_scenarios.jl")
# RES_bus=[38,39,40,48,51]
# nTP   =24
#
# RES_cap=[7.2;5.4;6.3;5.7;6.3]
nRES=size(RES_bus,1)

include("interface_excel_scenarios.jl")
# nSc      = Int64(size(data_scen,1))
nSc=1
# include("scenario.jl")
dim_RES=(length(1:nSc),length(1:nTP),length(1:size(RES_bus,1)))
prof_PRES = zeros(Float64,dim_RES)


for i in 1:size(RES_bus,1)
prof_PRES[:,:,i]=0*RES_cap[i]*data_scen[1:nSc,1:nTP]
# prof_PRES[i]=1*RES_cap[i]
end

display("Scenarios are generated.")

sbase = array_sbase[1].sbase
include("load_data_mpopf.jl")

include("import_json.jl")
# new_data = Dict()


nw_buses = array_bus
nw_lines = array_lines
nw_loads = array_loads
nw_gens  = array_gens
nw_trans = array_transformer
# nw_gcost = array_gcost
nw_sbase = array_sbase
nw_shunts= array_shunt
#--------------- Active and reactive power load profiles -----------------------
nw_pPrf_header_load     = rheader_pProfile_load
nw_qPrf_header_load     = rheader_qProfile_load
nw_pPrf_data_load       = rdata_pProfile_load
nw_qPrf_data_load       = rdata_qProfile_load

# prof_ploads = 1.3*nw_pPrf_data_load[:,2:end]
prof_ploads = nw_pPrf_data_load[:,2:end]
# prof_qloads = nw_qPrf_data_load[:,2:end]
prof_qloads = tan(acos(power_factor))*nw_pPrf_data_load[:,2:end]
#------------ Active and reactive power generation profiles --------------------
# nw_pPrf_header_gen_min  = rheader_pProfile_gen_min
# nw_pPrf_header_gen_max  = rheader_pProfile_gen_max
# nw_qPrf_header_gen_min  = rheader_qProfile_gen_min
# nw_qPrf_header_gen_max  = rheader_qProfile_gen_max

# nw_pPrf_data_gen_min    = rdata_pProfile_gen_min
# nw_pPrf_data_gen_max    = rdata_pProfile_gen_max
# nw_qPrf_data_gen_min    = rdata_qProfile_gen_min
# nw_qPrf_data_gen_max    = rdata_qProfile_gen_max

nw_storage = array_storage
# nw_Strcost = array_Strcost

#------------------------- Network Constants -----------------------------------
     # sbase is in MVA
vbase = []                    # vbase is in kVA
for i in 1:size(rdata_buses,1)
    push!(vbase,nw_buses[i].bus_vnom)
end
Ibase = (sbase*1000)./(sqrt(3)*vbase)    # base_current = base kVA/base kV
# nTP   = size(nw_pPrf_data_load,2)-1      # No of time periods in  a horizon
# nTP   = 1

# nSc   = 1                     # No of scenarios
# time_step = 24/size(nw_pPrf_data_load[:,2:end],2)
load_inc_prct = 0.3 # %increase in the flexible load
load_dec_prct = 0.3 # %decrease in the flexible load
load_inc_prct_q = 0.3 # %increase in the flexible load
load_dec_prct_q = 0.3 # %decrease in the flexible load

pf = 0.98           # power factor of a load
# v_relax_factor=0.06
v_relax_factor_min=0.05
v_relax_factor_max=0.05
#------------------------Single-Phase ACOPF Model-------------------------------
##-------------------------------------------------------------------------------
idx_from_line  = []
idx_to_line    = []
idx_from_trans = []
idx_to_trans   = []
yij_line       = []
yij_line_sh    = []
yij_trans      = []
yij_trans_sh   = []
tap_ratio      = []
tap_ratio_max  = []
tap_ratio_min  = []
node_data      = []
node_data_trans= []
error_msg      = []
yii_sh         = []                                                              # Shunt elements connected to a node
#----------------------- Formatting of Network Data ----------------------------
include("lines_data.jl")

include("lines_data_contin.jl")

include("node_data.jl")
display("node_data is generated.")
include("node_data_contin.jl")
# include("trsf_data.jl")
display("node_data_contin is generated.")
# please activate different sets of scenarios here
# include("scenarios.jl")



include("gen_data_mpopf.jl")

include("storage_data_mpopf.jl")

# include("input_data.jl")


#------------------ Setting of Single-Phase ACOPF Data--------------------------
include("model_initialization_normal.jl")
include("model_initialization_contin.jl")

# include("initial_values.jl")

#------------------------------Objective----------------------------------------
# include("objective_mpopf.jl")
include("objective_mpopf_new.jl")
display("Objectives are set.")
#--------------------------Network constraints----------------------------------
include("network_constraints_mpopf_new.jl")
display("netrwork constraints are generated.")
# include("power_balance_constraint_mpopf_new.jl")
# include("power_balance_constraint_mpopf_new_quad.jl")
include("power_balance_constraint_mpopf_new_quad_dual.jl")
display("normal power balance constraints are generated.")
#
include("network_constraints_mpopf_post_contingency.jl")
display("post contingency network constraints are generated.")
# include("longitudinal_current_post_contingency.jl")
display("longitudinal curent constraint is generated.")
println(Dates.now())
#
# include("power_balance_constraint_post_contingency.jl")
# include("power_balance_constraint_post_contingency_quad.jl")
include("power_balance_constraint_post_contingency_quad_dual.jl")
display("post contingency power balance constraints are generated.")
println(Dates.now())
#
include("coupling_constraints.jl")
# #
# include("ramp_constraint.jl")

# include("storage_constraints_normal.jl")

# include("storage_constraints_contingency.jl")



optimize!(acopf)
# println("Objective value", JuMP.objective_value(acopf))
println("Objective value  ", JuMP.value(total_cost))
println("Solver Time ", JuMP.solve_time(acopf))



# include("02_save_jld_first.jl")

include("dualizing.jl")

include("m_file_export.jl")

using JuMP,OdsIO,Dates,LinearAlgebra
using Ipopt, JSON
# using BenchmarkTools,MathOptInterface,
# using CPLEX
# using SCIP       # It is not useful for our purpose. Mianly deals with the feasibility problem.
# using AmplNLWriter
# using CbcP

#-------------------Accessing current folder directory--------------------------
show(pwd());
cd(dirname(@__FILE__))
println("")
show(pwd());

# files = cd(readdir, string(pwd(),"\\Network_Data"))
#--------------------Read Data from the Excel file------------------------------
# @time begin

# filename = "input_data/case_template_port_modified_R1.ods"
# filename = "input_data/case60_bus_new_wind.ods"
# filename = "input_data/case5_bus_new.ods"
# filename = "input_data/case5_bus_python_test.ods"
# filename = "input_data/case_template_CR_L3.ods"
# filename = "input_data/HR_L3_new.ods"
# filename = "input_data/Transmission_Network_UK_v2_PROF_update.ods"


## read ods file name from json

filename = JSON.parsefile("data_preparation\\import_WP3.json")["filename"] # full path


##
filename_scenario= "input_data/scenario_gen.ods"
# filename_scenario= "scenario_gen.ods"
# filename = "case_34_baran_modf.ods"
include("data_preparation/data_types.jl")      # Reading the structure of network related fields

include("data_preparation/data_types_contingencies.jl")

include("data_preparation/data_reader.jl")     # Function setting the data corresponding to each network quantity

include("data_preparation/interface_excel.jl") # Program saving all the inforamtion related to each entity of a power system




#-----------functions---------------------
include("functions/network_topology_functions.jl")

include("functions/AC_SCOPF_functions.jl")


#----------------------- Formatting of Network Data ----------------------------
include("data_preparation/contin_scen_arrays.jl")

include("data_preparation/node_data_func.jl")

# include("data_preparation\\json_generator.jl")
include("data_preparation/json_interface_import.jl")


#------------re-include functions to add json inputs
include("functions/network_topology_functions.jl")
include("functions/AC_SCOPF_functions.jl")
include("data_preparation/contin_scen_arrays.jl")
include("data_preparation/node_data_func.jl")


#---------------- re-include load/gen multipliers
prof_ploads=load_multiplier*prof_ploads
prof_qloads=load_multiplier*prof_qloads


pg_max=gen_multiplier*pg_max
qg_max=gen_multiplier*qg_max

#------------
show("Initial functions are compiled. ")

# end
#--- this one solves an accurate OPF or SCOPF
# include("repos/AC_SC_OPF.jl")
# OPF_opt=1
(model_name,output)=SP_SCOPF_or_MP_OPF(OPF_opt)
if OPF_opt==0
      include("data_preparation/dualizing_SCOPF.jl")
      include("data_preparation/json_interface_export_SCOPF.jl")
elseif OPF_opt==1
      include("data_preparation/dualizing_MPOPF.jl")
      include("data_preparation/json_interface_export_MPOPF.jl")
end

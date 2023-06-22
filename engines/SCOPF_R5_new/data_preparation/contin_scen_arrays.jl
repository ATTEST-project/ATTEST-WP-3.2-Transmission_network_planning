
sheetname = "contingencies";
fields = ["cont", "From", "To"];
raw_data =
    ods_readall(filename; sheetsNames = [sheetname], innerType = "Matrix")
raw_data = raw_data[sheetname]
header = raw_data[1, :]
data = raw_data[2:end, :]
(nCont,
array_contin_lines,
idx_from_line,
idx_to_line,
idx_line,
idx_from_line_c,
idx_to_line_c,
list_of_contingency_lines,
idx_pll_aux,
idx_npll,
data_for_each_contingency)=interface_excel_contingencies(raw_data,header,data)


data_scen=interface_excel_scenario()
# include("data_preparation/interface_excel_scenarios.jl")
# display("Data are extracted from excel files")

(nTP,nSc,prof_PRES,RES_bus,nRES)=f_prof_PRES(nSc,nTP,RES_MAG)
# display("Scenarios are generated.")

(nw_buses,
nw_lines,
# nw_loads,
nw_gens,
nw_trans,
nw_sbase,
nw_shunts,
nw_pPrf_header_load,
nw_qPrf_header_load,
nw_pPrf_data_load,
nw_qPrf_data_load,
prof_ploads,
prof_qloads,
nw_storage,
sbase,
vbase,
Ibase,
load_inc_prct,
load_dec_prct,
pf,
v_relax_factor_min,
v_relax_factor_max,
bus_data_lsheet)=arrays(Load_MAG)

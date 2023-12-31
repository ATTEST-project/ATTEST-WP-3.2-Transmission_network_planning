# -*- coding: utf-8 -*-
"""

@author: Wangwei Kong

The investment model uses output from the screening model as input,
    Part 1 finds the optimal network reinforcement considering contingencies,
    Part 2 determines the trade-off between investment cost and normal operation cost to find the optimal investment decisions. 


The outputs are in json file, includes the investment decisions and costs
"""



from __future__ import (division, print_function)
from pyomo.core import ConcreteModel, Constraint, minimize, NonNegativeReals, \
 Objective, Var, RangeSet, Binary, Set, Reals
from pyomo.core import value as Val
import json
import os
from engines.input_output_function import read_input_data, output_data2Json ,get_time_series_data,read_screenModel_output
from engines.scenarios_multipliers import get_mult
from engines.process_data import recordValues, replaceGenCost,mult_for_bus,get_factors
from engines.investment_model_pt2 import InvPt2_function
from engines.investment_model_pt1 import InvPt1_function
from engines.model_preparation import prepare_invest_model
import cProfile
import pstats

import time


''' functions without cli '''

# #### inputs for the investment model
# print("Gather inputs for the investment model")



# ''' input file information'''
# # Select country for case study: "PT", "UK" or "HR"
# country = "PT"

# #"HR_Location1"#'Transmission_Network_UK3' #"Transmission_Network_PT_2020_ods" # 'case5' # "Location_3_ods"
# test_case = "Transmission_Network_PT_2020_ods"

# # test case in .ods format for the operation model
# ods_file_name = "case_template_port_modified_R1 "
# #"case_template_CR_L3"

# # input xlsx file for time-serires data
# xlsx_file_name = "Transmission_Network_PT_2020_24hGenerationLoadData "



# NoYear = 4 #input numbers between 1 and 4, indicate year 2020 - 2050

# # update peak demand values
# # get peak load for screening model
# peak_hour = 19
# # peak_Pd = []# get_peak_data(mpc, base_time_series_data, peak_hour)
# # peak_Qd = []



# # TODO: check meaning for flex_up and flex_dn from WP2
# # if None, means no flexibility
# # Pflex_up = [10]*mpc["NoBus"] # peak_Pflex_up
# # Pflex_dn = [0]*mpc["NoBus"] # peak_Pflex_up
# # Qflex_up = None
# # Qflex_dn = None


# # read input data outputs mpc and load infor
# mpc, base_time_series_data,  multiplier, NoCon,cont_list, ci_catalogue,intv_cost= read_input_data( ods_file_name, xlsx_file_name, country,test_case)


# # read input data
# base_Pd , base_Qd ,peak_Pd ,peak_Qd ,base_Pflex_up, base_Pflex_dn , Pflex_up, Pflex_dn,Qflex_up, Qflex_dn, load_bus = get_time_series_data(mpc,  base_time_series_data,peak_hour)

# ''' Define factors '''
# # required inputs of multipliers for each bus, if not specified, all buses have the same multiplier
# busMult_input = []
# # expande multiplier for each bus
# multiplier_bus = mult_for_bus(busMult_input, multiplier, mpc)


# # Information about year and scenarios
# NoSea = 1 #3 # Season sequence: 0:(summer)	 1:(spring)	2:(winter)
# NoDay = 1 #2
# NoCon = len(cont_list)-1
# # each next year has two possible scenarios, using this to generate a scenario tree
# NoSce = 2
# # Total number of pathways and nodes based on inputs
# NoNode = 2**NoYear-1
# NoPath = 2**(NoYear-1) 

# # Probabiity of each pathway, assumed equal
# prob = [1/NoPath] * NoPath


# # Discount factor
# d = 0.035 # discount rate <= 30 years: 3.5%
# DF, CRF = get_factors(d, NoYear)

# # scaling factor to translate representative days costs into yearly cost
# SF  =  24 * 365* 0.7

    
# ''' costs and interventions'''
# # define budget cost for each year
# Budget_cost = [1e20]*NoYear
# penalty_cost = 1e3

# # read screening model output, if not found, full intervention list is used
# S_ci, ci_cost = read_screenModel_output(country, mpc,test_case, ci_catalogue,intv_cost)

# # if not specified, assume flex data to be
# CPflex = 15  # flex: 50 £/MWh  £/MW
# CQflex = 0

# # Define gen and line status, Default to False
# # if True, consider status from .m file; 
# # if False, all gen and lines are on
# gen_status = False 
# line_status = False  

# # define output options, Default to False
# # if True, output all scenarios
# # if False, output only two boundary scenarios
# outputAll = False
    

# # OPF can be run by Julia model or Pandapower
# OPF_option = "jl" #   "pp" # 



# profiler = cProfile.Profile()
# profiler.enable()

# '''Main '''
# print("Form optimisation model")
# # prepare the optimisation model with input data
# mpc,model, no_ysce, tree_ysce,path_sce,noDiff, genCbus,braFbus,braTbus,Pd, Qd = prepare_invest_model(mpc, NoPath,prob, NoYear, NoSce,NoSea, NoDay,DF,CRF,SF,S_ci,ci_cost,Budget_cost,penalty_cost, peak_Pd,peak_Qd,multiplier_bus, CPflex,CQflex,Pflex_up, Pflex_dn,Qflex_up, Qflex_dn,gen_status,line_status)

# # record branch capacity and gen cost
# bra_cap, gen_cost = recordValues(mpc)

# #### Run part1
# # remove gen cost in mpc
# mpc = replaceGenCost(mpc, gen_cost, 0)
# # SCACOPF for 1 peak hour  (years*scenarios*typical days*1h)
# model, obj_pt1, ci_pt1, sum_ciCost_pt1, Cflex_pt1 , Pflex_pt1, Qflex_pt1 = InvPt1_function(OPF_option,test_case,ods_file_name,model,mpc, NoYear, NoSea, NoDay, penalty_cost, NoCon, NoSce,path_sce,cont_list, S_ci,bra_cap,CPflex, CQflex, noDiff, genCbus,braFbus,braTbus,Pd, Qd,multiplier_bus)

# # output results for part1, operation cost are zero
# output_data2Json(NoPath, NoYear, path_sce, 0, 0, ci_pt1, sum_ciCost_pt1, Cflex_pt1,Pflex_pt1,outputAll, country , test_case, "_pt1" )




# # profiler.disable()
# # # sort output with total time
# # stats = pstats.Stats(profiler).sort_stats('tottime')
# # stats.print_stats(10)


    
    
# #### Run part 2
# # ACOPF for 24h (years*scenarios*typical days*24h)
# # recover gen cost
# mpc = replaceGenCost(mpc, gen_cost, 1)

# # run part 2 of the investment model
# model,obj_pt2, sum_CO, yearly_CO, ci_pt2, sum_ciCost_pt2, yearly_ciCost, Cflex_pt2,Pflex_pt2 = InvPt2_function(OPF_option,test_case,model,mpc,ods_file_name, penalty_cost, NoCon, prob,DF, CRF, SF, NoSce,path_sce, S_ci,Cflex_pt1,Pflex_pt1,Qflex_pt1, ci_pt1,obj_pt1,multiplier_bus,)

# # output results for part2
# output_data2Json(NoPath, NoYear, path_sce, sum_CO, yearly_CO, ci_pt2, sum_ciCost_pt2, Cflex_pt2,Pflex_pt2,outputAll, country , test_case,"_pt2" )

# # #### print final restuls
# # print("Investment model finishes")
# # print("\n*********************************************")
# # print('Total min obj cost:', Val(model.obj)   )        
# # print("Total operation cost:", sum_CO )
# # print("Total branch investment coInvestmentst:",sum_ciCost_pt2)
# # print("Total flex investment cost:", Cflex_pt2)
# # print("*********************************************")     



# print("\n -------------------------")        
# print("Investment model finishes, results output to the folder as 'investment_result.json'.")



# # write cProfile results in .txt file
# from io import StringIO
# profiler.disable()
# # sort output with total time

# result = StringIO()
# stats = pstats.Stats(profiler, stream = result).sort_stats('tottime')
# stats.print_stats()

# file_name = "cProfileExport_investModel_" + country + "_" + test_case
# with open(file_name +'.txt', 'w+') as f:
#     f.write(result.getvalue())



''' functions for cli '''



def run_main_investment(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, NoYear, run_all, add_load_data,add_load_data_case_name):
    start = time.time()

    profiler = cProfile.Profile()
    profiler.enable()    
    
    #### inputs for the investment model
    print("Gather inputs for the investment model")  
    
    # read input data outputs mpc and load infor
    mpc, base_time_series_data,  multiplier, NoCon,cont_list, ci_catalogue,intv_cost= read_input_data(input_dir, ods_file_name, xlsx_file_name, country,test_case)
    
    
    # read input data
    base_Pd , base_Qd ,peak_Pd ,peak_Qd ,base_Pflex_up, base_Pflex_dn , Pflex_up, Pflex_dn,Qflex_up, Qflex_dn, load_bus = get_time_series_data(mpc,  base_time_series_data,peak_hour)
    
    ''' Define factors '''
    # required inputs of multipliers for each bus, if not specified, all buses have the same multiplier
    busMult_input = []
    # expande multiplier for each bus
    multiplier_bus = mult_for_bus(busMult_input, multiplier, mpc)
    
    
    # Information about year and scenarios
    NoSea = 1 #3 # Season sequence: 0:(summer)	 1:(spring)	2:(winter)
    NoDay = 1 #2
    NoCon = len(cont_list)-1
    # each next year has two possible scenarios, using this to generate a scenario tree
    NoSce = 2
    # Total number of pathways and nodes based on inputs
    # NoNode = 2**NoYear-1
    NoPath = 2**(NoYear-1) 
    
    # Probabiity of each pathway, assumed equal
    prob = [1/NoPath] * NoPath
    
    
    # Discount factor
    d = 0.035 # discount rate <= 30 years: 3.5%
    DF, CRF = get_factors(d, NoYear)
    
    # make all cost into the scale of million
    cost_base = 1e6
    
    # scaling factor to translate representative days costs into yearly cost
    SF_lc = 24 * 365* 0.7
    SF_flex = 1* 365 
    SF=[] 
    SF.append( SF_lc )      # SF[0]: scaling factor for load curtailment and operation
    SF.append( SF_flex )    # SF[1]: scaling factor for flexibility
    
    
   
    
        
    ''' costs and interventions'''
    # define budget cost for each year
    Budget_cost = [0]*NoYear # if set to 0, no constraint on budget cost
    penalty_cost = 1e3/cost_base
    
    # read screening model output, if not found, full intervention list is used
    S_ci, ci_cost = read_screenModel_output(output_dir,country, mpc,test_case, ci_catalogue,intv_cost,cost_base)

    # if not specified, assume flex data to be
    CPflex = 107.24/cost_base  # flex: 107.24 euro/MWh  
    CQflex = 0
    
    # Turn off flex in the investment model
    # Pflex_up = None
    # Pflex_dn = None
    
    # Define gen and line status, Default to False
    # if True, consider status from .m file; 
    # if False, all gen and lines are on
    gen_status = False 
    line_status = False  
    
    # define output options, Default to False
    # if True, output all scenarios
    # if False, output only two boundary scenarios
    outputAll = False
        
    
    # OPF can be run by Julia model or Pandapower
    OPF_option = "jl" #   "pp" # 
    
    

    '''Main '''
    print("Form optimisation model")
    # prepare the optimisation model with input data
    mpc,model, no_ysce, tree_ysce,path_sce,noDiff, genCbus,braFbus,braTbus,Pd, Qd = prepare_invest_model(mpc, NoPath,prob, NoYear, NoSce,NoSea, NoDay,DF,CRF,SF,S_ci,ci_cost,Budget_cost,penalty_cost, peak_Pd,peak_Qd,multiplier_bus, CPflex,CQflex,Pflex_up, Pflex_dn,Qflex_up, Qflex_dn,gen_status,line_status, add_load_data, add_load_data_case_name, input_dir)
    
    # record branch capacity and gen cost
    bra_cap, gen_cost = recordValues(mpc)
    
    #### Run part1
    # remove gen cost in mpc
    mpc = replaceGenCost(mpc, gen_cost, 0)
    # SCACOPF for 1 peak hour  (years*scenarios*typical days*1h)

    # print('Testing InvPt1 model 1 ....')

    model, obj_pt1, ci_pt1, ciCost_pt1, Cflex_pt1 , Pflex_pt1, Qflex_pt1 = InvPt1_function(input_dir,OPF_option,test_case,ods_file_name,model,mpc, NoYear, NoSea, NoDay, penalty_cost, NoCon, NoSce,path_sce,cont_list, S_ci,bra_cap,CPflex, CQflex, noDiff, genCbus,braFbus,braTbus,Pd, Qd,multiplier_bus,cost_base)
    
    # print('Testing InvPt1 model 2 ....')

    # output results for part1, operation cost are zero
    output_data2Json(output_dir,NoPath, NoYear, path_sce, 0, 0, ci_pt1, ciCost_pt1, Cflex_pt1,Pflex_pt1,outputAll, country , test_case, "_pt1" )
    
    
        
    if run_all:    
        #### Run part 2
        # ACOPF for 24h (years*scenarios*typical days*24h)
        # recover gen cost
        mpc = replaceGenCost(mpc, gen_cost, 1)
        
        # run part 2 of the investment model
        model,obj_pt2, sum_CO, yearly_CO, ci_pt2, ciCost_pt2, yearly_ciCost, Cflex_pt2,Pflex_pt2 = InvPt2_function(input_dir,OPF_option,test_case,model,mpc,ods_file_name, penalty_cost, NoCon, prob,DF, CRF, SF, NoSce,path_sce, S_ci,Cflex_pt1,Pflex_pt1,Qflex_pt1, ci_pt1,obj_pt1,multiplier_bus,cost_base)
        
        # output results for part2
        output_data2Json(output_dir,NoPath, NoYear, path_sce, sum_CO, yearly_CO, ci_pt2, ciCost_pt2, Cflex_pt2,Pflex_pt2,outputAll, country , test_case,"_pt2" )
        

    
    
    print("\n -------------------------")        
    print("Investment model finishes, results output to the folder as 'investment_result.json'.")
    
    # write cProfile results in .txt file
    from io import StringIO
    profiler.disable()
    # sort output with total time

    result = StringIO()
    stats = pstats.Stats(profiler, stream = result).sort_stats('tottime')
    stats.print_stats()

    file_name = "cProfileExport_investModel_" + country + "_" + test_case
    with open(file_name +'.txt', 'w+') as f:
        f.write(result.getvalue())

    end = time.time()
    print('Investment model execution time: ',end - start)
    
    
    




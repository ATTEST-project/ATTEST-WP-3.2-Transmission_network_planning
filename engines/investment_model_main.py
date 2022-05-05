# -*- coding: utf-8 -*-
"""
Created on Fri Feb 11 17:03:56 2022

@author: p96677wk

The investment model uses output from the screening model as input,
    Part 1 find the optimal network reinforcement considering contingencies,
    Part 2 determines the trade-off between investment cost and noral operation cost to find the optimal investment decisions. 


The outputs are in json file, includes the investment decisions and costs
"""



from __future__ import (division, print_function)
from pyomo.core import ConcreteModel, Constraint, minimize, NonNegativeReals, \
 Objective, Var, RangeSet, Binary, Set, Reals
from pyomo.core import value as Val
import json
import os
from input_output_function import read_input_data, output_data2Json ,get_time_series_data
from scenarios_multipliers import get_mult
from process_data import initial_value, recordValues, replaceGenCost
from investment_model_pt2 import InvPt2_function
from investment_model_pt1 import InvPt1_function
from model_preparation import prepare_invest_model



#### inputs for the investment model
print("Gather inputs for the investment model")
# Select country for case study: "PT", "UK" or "HR"
country = "UK" 

# Define the case name
#"HR_2020_Location_1"#'Transmission_Network_UK2' #"Transmission_Network_PT_2030_Active_Economy" # 
net_name = 'case5' 

# read input data
# mpc, base_time_series_data,  multiplier = read_input_data( net_name )
# base_Pd , base_Qd ,peak_Pd ,peak_Qd ,base_Pflex_up, base_Pflex_dn , peak_Pflex_up , peak_Pflex_dn, gen_sta, peak_gen_sta = get_time_series_data(mpc,  base_time_series_data)

''' Load json file''' 
# load json file from file directory
mpc = json.load(open(os.path.join(os.path.dirname(__file__), 
                                  'tests', 'json', net_name+'.json')))
  

#  multiplier = [xy][xsc] 
# multiplier = [] 
# for xy in range(NoYear):
#     xsc_temp = 2**xy
#     multiplier.append([1]*xsc_temp )

multiplier = get_mult(country) # default to HR


# Information about year and scenarios
NoYear = 1
NoSea = 1 #3 # Season sequence: 0:(summer)	 1:(spring)	2:(winter)
NoDay = 1 #2
NoCon = 1
# each next year has two possible scenarios, using this to generate a scenario tree
NoSce = 2
# Total number of pathways and nodes based on inputs
NoNode = 2**NoYear
NoPath = 2**(NoYear-1) 

# Probabiity of each pathway, assumed equal
prob = [1/NoPath] * NoPath

# define budget cost for each year
Budget_cost = [1e20]*NoYear
penalty_cost = 1e3

# Discount factor
d = 0.035 # discount rate <= 30 years: 3.5%
DF = [0]*NoYear
for y in range(NoYear):
    DF[y] = 1/ ((1-d)**y)

# capaital recovery factor
CRF = [1] * NoYear
xy = 1
while xy < NoYear:
    N_year = xy *10
    CRF[xy] = (d * ((1+d)**N_year) ) / ( (1+d)**N_year -1) # d = 0.035 # discount rate <= 30 years: 3.5%
    xy += 1

# scaling factor to translate representative days costs into yearly cost
SF  = 1

# Assume a power factor for initial run, values are updated based on OPF results

cos_pf_init = 0.98
sin_pf_init = (1-cos_pf_init**2)**0.5

cos_pf = initial_value(mpc,NoYear,NoSce, cos_pf_init)
sin_pf = initial_value(mpc,NoYear,NoSce, sin_pf_init)

    
# reading outputs from the screening model of the reduced intervention list
if os.path.exists('results/screen_result.json'):
   
    S_ci = json.load(open(os.path.join(os.path.dirname(__file__), 
                                      'results', 'screen_result.json')))
else:
    print("screen results not found. Please run screening model. ")
# S_ci =  [48, 58, 133] #[52, 131] #

# if not specified, using a linear cost
ci_cost = [5*i for i in S_ci]  # £/MW

# if not specified, assume flex data to be
CPflex = 1e3
CQflex = 1e3

# TODO: update the input_out_function to include flex profile inputs
Pflex_max = 1000
Qflex_max = 1000



# update peak demand values
# get peak load for screening model
peak_hour = 19
peak_Pd = []# get_peak_data(mpc, base_time_series_data, peak_hour)
peak_Qd = []

# Define gen and line status, Default to False
# if True, consider status from .m file; 
# if False, all gen and lines are on
gen_status = False 
line_status = False  

# define output options, Default to False
# if True, output all scenarios
# if False, output only two boundary scenarios
outputAll = False
    

'''Main '''
print("Form optimisation model")
# prepare the optimisation model with input data
mpc,model, no_ysce, tree_ysce,path_sce,noDiff, genCbus,braFbus,braTbus,Pd, Qd = prepare_invest_model(mpc, NoPath,prob, NoYear, NoSce,NoSea, NoDay,DF,CRF,SF,S_ci,ci_cost,Budget_cost,penalty_cost, peak_Pd,peak_Qd,multiplier,cos_pf,sin_pf,CPflex,CQflex,Pflex_max,Qflex_max,gen_status,line_status)

# record branch capacity and gen cost
bra_cap, gen_cost = recordValues(mpc)

#### Run part1
# remove gen cost in mpc
mpc = replaceGenCost(mpc, gen_cost, 0)
# SCACOPF for 1 peak hour  (years*scenarios*typical days*1h)
model, obj_pt1, ci_pt1 , Cflex_pt1 , Pflex_pt1, Qflex_pt1 = InvPt1_function(model,mpc, NoYear, NoSea, NoDay, penalty_cost, NoCon, NoSce,path_sce, S_ci,bra_cap,CPflex, CQflex, noDiff, genCbus,braFbus,braTbus,Pd, Qd)

        
#### Run part 2
# ACOPF for 24h (years*scenarios*typical days*24h)

# recover gen cost
mpc = replaceGenCost(mpc, gen_cost, 1)

# run part 2 of the investment model
model, sum_CO, yearly_CO, ci_pt2, sum_ciCost_pt2, yearly_ciCost, Cflex_pt2,Pflex_pt2 = InvPt2_function(model,mpc, penalty_cost, NoCon, prob,DF, CRF, SF, NoSce,path_sce, S_ci,Cflex_pt1,Pflex_pt1,Qflex_pt1, ci_pt1,obj_pt1)



output_data2Json(NoPath, NoYear, path_sce, sum_CO, yearly_CO, ci_pt2, sum_ciCost_pt2, Cflex_pt2,Pflex_pt2,outputAll, country , net_name )

# #### print final restuls
# print("Investment model finishes")
# print("\n*********************************************")
# print('Total min obj cost:', Val(model.obj)   )        
# print("Total operation cost:", sum_CO )
# print("Total branch investment cost:",sum_ciCost_pt2)
# print("Total flex investment cost:", Cflex_pt2)
# print("*********************************************")     

        
print("Screening model finishes, results output to the folder as 'investment_result.json'.")



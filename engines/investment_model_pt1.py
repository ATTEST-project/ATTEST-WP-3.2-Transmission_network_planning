# -*- coding: utf-8 -*-
"""

@author: Wangwei Kong

Part 1 of the investment model
"""

from __future__ import (division, print_function)
from pyomo.core import ConcreteModel, Constraint, minimize, NonNegativeReals, \
 Objective, Var, RangeSet, Binary, Set, Reals
from pyomo.environ import SolverFactory
from pyomo.core import value as Val
import json
import os
import math
import numpy as np
import copy
from scenarios_multipliers import get_mult
from SCACOPF import run_SCACOPF_jl
from SCACOPF import output2json
from process_data import record_bra_from_pyo_result, record_bus_from_pyo_result, record_invest_from_pyo_result
from invest_check import overInvstment_check





def InvPt1_function(model,mpc, NoYear, NoSea, NoDay, penalty_cost, NoCon, NoSce,path_sce, S_ci,bra_cap,CPflex, CQflex, noDiff, genCbus,braFbus,braTbus,Pd, Qd):
    

    # def duLine_rule(model,xb, xy,xsc, xse, xd, xt):
    #     # dual_bra_all = [bus][branch]
    #     # TODO: update the dual_all, Pbra_result
    #     if sum( (dual_Pbra_all[xb][xbr] / penalty_cost) for xbr in model.Set['Bra']  ) > 0:
    #         # print(plc_result[xb], "<=", sum( (dual_Pbra_all[xb][xbr] / penalty_cost) * (model.Pbra[xbr,xy,xsc, xse, xd,xt] - Pbra_result[xbr]) for xbr in model.Set['Bra']  ))
            
    #         return plc_result[xb] <= \
    #             sum( (dual_Pbra_all[xb][xbr] / penalty_cost) * (model.Pbra[xbr,xy,xsc, xse, xd,xt] - Pbra_result[xbr]) 
    #                   for xbr in model.Set['Bra']  )
            
    #     else:
    #         return model.Plc[xb,xy,xsc, xse, xd, xt] == 0
    
    
        
    # TODO: Double check the dual rules
    # dual rules including both line and flex duals
    def dualVar_rule(model,xb, xy,xsc, xse, xd, xt):
        # dual_bra_all = [bus][branch]
        # dual_bus_all = [bus]
     
        if sum( (dual_Pbra_all[xy][xsc][xb][xbr] / penalty_cost) for xbr in model.Set['Bra']  ) > 0 or  dual_Pbus_all[xy][xsc][xb] > 0 :
            print(plc_result[xy][xsc][xb], "<=", sum( (dual_Pbra_all[xy][xsc][xb][xbr] / penalty_cost) * (model.Pbra[xbr,xy,xsc, xse, xd,xt] - Pbra_result[xy][xsc][xbr]) for xbr in model.Set['Bra']  ),
                  "+", (dual_Pbus_all[xy][xsc][xb] / (penalty_cost + CPflex)) * (model.Pflex[xb,xy,xsc, xse, xd,xt] - Pflex_result[xy][xsc][xb]))
            
            return plc_result[xy][xsc][xb] <= \
                sum( (dual_Pbra_all[xy][xsc][xb][xbr] / penalty_cost) * (model.Pbra[xbr,xy,xsc, xse, xd,xt] - Pbra_result[xy][xsc][xbr]) 
                      for xbr in model.Set['Bra']  ) +\
                (dual_Pbus_all[xy][xsc][xb] / (penalty_cost + CPflex)) * (model.Pflex[xb,xy,xsc, xse, xd,xt] - Pflex_result[xy][xsc][xb])    # assume one flex for each bus
            
        else:
            return model.Plc[xb,xy,xsc, xse, xd,xt] == 0
    
    def dualVarQ_rule(model,xb, xy,xsc, xse, xd, xt):
        # dual_bra_all = [bus][branch]
        # dual_bus_all = [bus]
     
        if sum( (dual_Qbra_all[xy][xsc][xb][xbr] / penalty_cost) for xbr in model.Set['Bra']  ) > 0 or  dual_Qbus_all[xy][xsc][xb] > 0 :
            # print(qlc_result[xy][xsc][xb], "<=", sum( (dual_Qbra_all[xy][xsc][xb][xbr] / penalty_cost) * (model.Qbra[xbr,xt] - Qbra_result[xy][xsc][xbr]) for xbr in model.Set['Bra']  ),
            #       "+", (dual_Qbus_all[xy][xsc][xb] / (penalty_cost + CQflex)) * (model.Qflex[xb,xy,xsc, xse, xd,xt] - Qflex_result[xy][xsc][xb]))
            
            return qlc_result[xy][xsc][xb] <= \
                sum( (dual_Qbra_all[xy][xsc][xb][xbr] / penalty_cost) * (model.Qbra[xbr,xy,xsc, xse, xd,xt] - Qbra_result[xy][xsc][xbr]) 
                      for xbr in model.Set['Bra']  ) +\
                (dual_Qbus_all[xy][xsc][xb] / (penalty_cost + CQflex)) * (model.Qflex[xb,xy,xsc, xse, xd,xt] - Qflex_result[xy][xsc][xb])    # assume one flex for each bus
            
        else:
            return model.Qlc[xb,xy,xsc, xse, xd,xt] == 0
        
    
    # trace branches that have impacts on the load curtailment
    def trace_pf(plc_result, dual_bra, dual_bus,OPF_Pbra):
        # separate dual for each load curtailment
        # start tracing for each endnode
      
        def find_next_Fbus(bus_no,bra_no):   
            noDiff = 0
            # finding the other end of this branch
            bra_no += noDiff
            next_bus_no = -1
            i_bus_no = 0        
            while next_bus_no < 0:
                  if bra_no in braTbus[i_bus_no]:
                      next_bus_no = i_bus_no
                  else:
                      i_bus_no += 1
             
            return next_bus_no
        
        def find_next_Tbus(bus_no,bra_no):  
            noDiff = 0
            # finding the other end of this branch
            bra_no += noDiff 
            next_bus_no = -1
            i_bus_no = 0        
            while next_bus_no < 0:
                  if bra_no in braFbus[i_bus_no]:
                      next_bus_no = i_bus_no
                  else:
                      i_bus_no += 1
             
            return next_bus_no
        
        def recursive_tracing_Fbus(bus_no, no_braFbus, dual_update):  
            noDiff = 0
            if no_braFbus == 0: 
                # if only one branch connected to this bus
                temp_bra_no = braFbus[bus_no][no_braFbus] - noDiff # find branch name(number)
            
                if OPF_Pbra[temp_bra_no] < 0: # branch from the bus, if value is -ve, means it flows to the bus
                    dual_update[xb][temp_bra_no] = 1
                    return dual_update
               
                else: 
                    next_bus_no = find_next_Fbus(bus_no, temp_bra_no) # if value is +ve, find next bus
                    if next_bus_no == xb:    # if no more next bus (back to the starting point)
                       
                        return dual_update   # end recursive function
                    else:
                        # find number of branches connected to the next bus
                        next_no_braFbus = len(braFbus[next_bus_no]) -1 
                       
                        return recursive_tracing_Fbus(next_bus_no, next_no_braFbus, dual_update)              
       
            else:
                # if more than one branch connected to this bus, loop the branches
                for i_no_bra in range(no_braFbus+1):
                      temp_bra_no = braFbus[bus_no][i_no_bra] - noDiff
                                
                      if OPF_Pbra[temp_bra_no] < 0:
                          dual_update[xb][temp_bra_no] = 1
                          #return dual_update
                      else: 
                        next_bus_no = find_next_Fbus(xb, temp_bra_no)
                        if next_bus_no == xb:
                            return dual_update
                        else:
                            next_no_braFbus = len(braFbus[next_bus_no]) -1
                            return recursive_tracing_Fbus(next_bus_no, next_no_braFbus, dual_update)
            return dual_update                
                       
                    
    
        
        def recursive_tracing_Tbus(bus_no, no_braTbus, dual_update):
                   
            if no_braTbus == 0: 
                # if only one branch connected to this bus
                temp_bra_no = braTbus[bus_no][no_braTbus] - noDiff # find branch name(number)
            
                if OPF_Pbra[temp_bra_no] > 0: # branch to the bus, if value is +ve, means it flows to the bus
                    dual_update[xb][temp_bra_no] = 1
                
                    return dual_update
                   
               
                else: 
                    next_bus_no = find_next_Tbus(bus_no, temp_bra_no) # if value is -ve, find next bus
                    if next_bus_no == xb:    # if no more next bus (back to the starting point)
                       
                        return dual_update   # end recursive function
                    else:
                        # find number of branches connected to the next bus
                        next_no_braTbus = len(braTbus[next_bus_no]) -1 
                       
                        return recursive_tracing_Tbus(next_bus_no, next_no_braTbus, dual_update)              
       
            else:
                # if more than one branch connected to this bus, loop the branches
                for i_no_bra in range(no_braTbus+1):
                      temp_bra_no = braTbus[bus_no][i_no_bra] - noDiff
                                
                      if OPF_Pbra[temp_bra_no] > 0:
                          dual_update[xb][temp_bra_no] = 1
                          #return dual_update
                      else: 
                        next_bus_no = find_next_Tbus(xb, temp_bra_no)
                        if next_bus_no == xb:
                            return dual_update
                        else:
                            next_no_braTbus = len(braTbus[next_bus_no]) -1
                            return recursive_tracing_Tbus(next_bus_no, next_no_braTbus, dual_update)
                         
            return dual_update             
                         
    
    
        
        
        dual_bus_new = dual_bus.copy()
        
        dual_update = np.zeros(shape=(mpc["NoBus"],len(dual_bra))) #[[0] * len(dual_bra)] * mpc["NoBus"]
          # find load curtail bus
        for xb in range(len(plc_result)):
            
            
            if plc_result[xb] > 0:                     
              # print("plc at bus: ", xb)
                bus_no = xb
                no_braFbus = len(braFbus[xb]) -1 
                dual_update = recursive_tracing_Fbus(bus_no, no_braFbus, dual_update)
              # print("F_bus dual_update: ", dual_update)
               
                no_braTbus = len(braTbus[xb]) -1 
                dual_update = recursive_tracing_Tbus(bus_no, no_braTbus, dual_update)
                #print("T_bus dual_update: ", dual_update)
            else:
                dual_bus_new[xb] = 0
                
                    
        dual_update = dual_update.tolist()            
        dual_bra_new =[]
        
        # dual_bus_new = [0]*len(dual_bus)
        for i in range(len(dual_update)):
            dual_bra_new.append( [a*b for a,b in zip(dual_update[i], dual_bra)])
            
            if sum(dual_bra_new[i]) > 0:
                dual_bus_new[i] = dual_bus[i]
                
        
        # # [[0.0, 0.0, 0.0, 0.0, 0.0, 0.0], 
        # #  [0.0, 0.0, 0.0, 384.341637010676, 0.0, 0.0], 
        # #  [0.0, 0.0, 0.0, 0.0, 1056.93950177936, 0.0], 
        # #  [0.0, 3105.01012976742, 0.0, 0.0, 0.0, 0.0] 
        # #  [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]]
           
        
        return (dual_bra_new, dual_bus_new)
        
    
    # TODO: update these constraints
    def updateBinding_rule(model):
        # print(sum(model.ci[xintv,xbr,xy,xsc ]*S_ci[xintv] for xintv in model.Set["Intv"])+ bra_cap[xbr], ">=",  abs(  OPF_Pbra[xbr] ) )
        return sum(model.ci[xintv, xbr,xy,xsc]*S_ci[xintv] for xintv in model.Set["Intv"]) + bra_cap[xbr]>= \
              abs(  max_OPF_Pbra[xbr]/cos_pf[xbr] )
    
    def updateBindingQ_rule(model,xy,xsc):
        return sum(model.ci[xintv, xbr,xy,xsc]*S_ci[xintv] for xintv in model.Set["Intv"]) + bra_cap[xbr]>= \
              abs(  max_OPF_Qbra[xbr] /sin_pf[xbr]  ) 
    
        
    
    
    print("\n--> Part 1 of the investment model")
    # SCACOPF for the peak hour (years*scenarios*typical days*contingency*1h)
    # only run for the peak time 
    # NoTime = 1 # Number of time points
    
    
    sum_plc_result = 0
    sum_qlc_result = 0
    ite_z = 0
    # count_opf = 0
    
    # TODO: Change back
    while ite_z < 2 : #sum_plc_result > 0 or sum_qlc_result > 0 or ite_z <= 4 :
        
        print("\n---- iteration: ", ite_z)
        
        
         
        if ite_z == 0:                                  # initial run
            # solve pyomo model
            solver = SolverFactory('glpk')
            results = solver.solve(model)
            print ('solver termination condition: ', results.solver.termination_condition)
            # model.ciCost.pprint()
    
            # Remove node balance rule
            model.del_component(model.nodeBalance)
            model.del_component(model.nodeBalanceQ)
           
            # print('min obj cost:',Val(model.obj))
            print("Branch investment cost:",Val( sum( model.ciCost[xy,xsc] for xy,xsc in model.Set["YSce"] ) ))
            print("Flex investment cost:",Val( sum( model.CflexP[xb,xy,xsc,0,0,0]+model.CflexQ[xb,xy,xsc,0,0,0] for xb in model.Set["Bus"] for xy,xsc in model.Set["YSce"] ) ))
   
         
        else:                                           # iterations
            cos_pf  = 0.95
            # Add dual rules delta branch power
            print("add duLine_ite", ite_z)
            # model.add_component("duLine_ite"+str(ite_z), Constraint(model.Set['Bus'],model.Set['YSce'] ,model.Set['Sea'], model.Set['Day'], model.Set['Tim'],rule=duLine_rule ))
            # model.add_component("duLineQ_ite"+str(ite_z), Constraint(model.Set['Bus'],model.Set['YSce'] ,model.Set['Sea'], model.Set['Day'], model.Set['Tim'],rule=duLineQ_rule ))
            
            # TODO: change constraints to include Flex:
            model.add_component("dualVar_ite"+str(ite_z), Constraint(model.Set['Bus'],model.Set['YSce'] ,model.Set['Sea'], model.Set['Day'],model.Set['Tim'],rule=dualVar_rule ))
            model.add_component("dualVarQ_ite"+str(ite_z), Constraint(model.Set['Bus'],model.Set['YSce'] ,model.Set['Sea'], model.Set['Day'],model.Set['Tim'],rule=dualVarQ_rule ))
            
            # add one constraint for each contingency
            
            if NoCon >= 1:
                for xc in range(NoCon):
                    dual_Pbra_all = dual_Pbra_all_con[xc]
                    plc_result = plc_result_con[xc]
                    print("add duLine_ite_con", ite_z)
                    model.add_component("dualVar_ite"+str(ite_z)+"con"+str(xc), Constraint(model.Set['Bus'],model.Set['YSce'] ,model.Set['Sea'], model.Set['Day'],model.Set['Tim'],rule=dualVar_rule ))               
                    model.add_component("dualVarQ_ite"+str(ite_z)+"con"+str(xc), Constraint(model.Set['Bus'],model.Set['YSce'] ,model.Set['Sea'], model.Set['Day'],model.Set['Tim'],rule=dualVarQ_rule ))
                 
            
        
          
            
            # # Recover mpc using results from model.ci
            # for xbr in range(mpc['NoBranch']):
            #     mpc["branch"]["RATE_A"][xbr] =  bra_cap[xbr]
           
            # redo optimisation
            solver = SolverFactory('glpk')
            results = solver.solve(model)
            print ('solver termination condition: ', results.solver.termination_condition)
            print("Branch investment cost:",Val( sum( model.ciCost[xy,xsc] for xy,xsc in model.Set["YSce"] ) ))
            print("Flex investment cost:",Val( sum( model.CflexP[xb,xy,xsc,0,0,0]+model.CflexQ[xb,xy,xsc,0,0,0] for xb in model.Set["Bus"] for xy,xsc in model.Set["YSce"] ) ))
   
        # get branch power flow
        # TODO: UPDATE THE SEQUENCE
        # branch power flow result = ,[year],[scenario], [branch]  
        Pbra_result = record_bra_from_pyo_result(model,mpc,NoSce, model.Pbra,True)
        Qbra_result = record_bra_from_pyo_result(model,mpc,NoSce, model.Qbra,True)
        
        ci = record_invest_from_pyo_result(model,mpc,NoSce, model.ci)
        # record flex investment for each year each scenario, flex value is yearly peak, so seanson, day and time data are not required (set to 0)
        Pflex_result = record_bus_from_pyo_result(model,mpc,NoSce, model.Pflex,True)
        Qflex_result = record_bus_from_pyo_result(model,mpc,NoSce, model.Qflex,True)
  
        
    
     
        # Print investment decisions
        
        for xy,xsc in model.Set["YSce"]:
            for xbr in model.Set['Bra']:
               
                if xy == 0:
                    temp_ci = Val(sum( (model.ci[xintv,xbr,xy,xsc ])* S_ci[xintv]  for xintv in model.Set["Intv"] ) )
                else:
                    temp_ci = Val(sum( (model.ci[xintv,xbr,xy,xsc ] - model.ci[xintv,xbr,xy-1,math.floor(xsc/2) ])* S_ci[xintv]  for xintv in model.Set["Intv"] ) )
                if  temp_ci > 0:
                    
                    print('Year:',xy,', Scenario:', xsc,', Branch:', xbr, ', increase cap:',temp_ci)
    
            for xb in model.Set["Bus"]:
                temp_flex =  Val(model.Pflex[xb,xy,xsc,0,0,0])
                if temp_flex > 0 :
                    print('Year:',xy,', Scenario:', xsc,', Bus:', xb, ', increase flex:', temp_flex)
         
    
        # create empty lists for each year               
        # power factor, load curtailments P,Q in normal and contingency
        cos_pf ,sin_pf, plc_result ,plc_result_con ,qlc_result,qlc_result_con = ([[]for _ in range(NoYear)] for i in range(6))
        
        # OPF branch power flow
        OPF_Pbra , OPF_Pbra_con, OPF_Qbra, OPF_Qbra_con = ([[]for _ in range(NoYear)] for i in range(4))
        
        # dual variables for branch P,Q in normal and contingency
        dual_Pbra , dual_Pbra_con , dual_Qbra, dual_Qbra_con  = ([[]for _ in range(NoYear)] for i in range(4))
        
        # dual variables for bus P,Q in normal and contingency
        dual_Pbus ,dual_Pbus_con ,dual_Qbus ,dual_Qbus_con = ([[]for _ in range(NoYear)] for i in range(4))
        
        # dual variables after tracing algoritm for branch and bus P,Q in normal state
        dual_Pbra_all, dual_Qbra_all, dual_Pbus_all, dual_Qbus_all = ([[]for _ in range(NoYear)] for i in range(4))
        
        # dual variables after tracing algoritm for branch and bus P,Q in contingency
        dual_Pbra_all_con, dual_Qbra_all_con, dual_Pbus_all_con, dual_Qbus_all_con = ([[]for _ in range(NoYear)] for i in range(4))
        
     
        
        
        # run SCACOPF for each year each scenario, Get plc and duals
        for xy in model.Set["Year"]:
            
            for xsc in range(NoSce**xy):   
                
                # # ci for each year each scenario
                # ci = []
                # for xbr in range(mpc['NoBranch']):
                #    # mpc["branch"]["RATE_A"][xbr] = bra_cap[xbr]+ sum(S_ci[i]* Val(model.ci[i, xbr]) for i in model.Set["Intv"])
                #     if sum( Val(model.ci[i,xbr,xy,xsc ]) for i in model.Set["Intv"]) > 0: 
                        
                #         ci.append( sum(S_ci[i]* Val(model.ci[i, xbr,xy,xsc ]) for i in model.Set["Intv"]))
                #     else:
                #         ci.append(0)
                        
                # # record flex investment for each year each scenario, flex value is yearly peak, so seanson, day and time data are not required (set to 0)
                # Pflex_result = [0]*mpc['NoBus']
                # Qflex_result = [0]*mpc['NoBus']
                # for xb in range(mpc['NoBus']):
                #     Pflex_result[xb] = Val(model.Pflex[xb,xy,xsc ,0,0,0])
                #     Qflex_result[xb] = Val(model.Qflex[xb,xy,xsc ,0,0,0])
                
                # Todo: update outputs for opf model
                # output results to json file
                output2json(mpc,ci[0][0],Pflex_result[0][0], Qflex_result[0][0] )
                # run scac OPF, Get plc and duals
                
                SCACOPF_result = run_SCACOPF_jl(mpc, NoCon, penalty_cost)
                print("Process OPF results")
            
                # CO, cos_pf, sin_pf, plc_result,plc_result_con, qlc_result, \
                #     OPF_Pbra , OPF_Pbra_con ,OPF_Qbra, dual_Pbra,dual_Pbra_con, dual_Qbra, \
                #         dual_Pbus,dual_Pbus_con , dual_Qbus,dual_Qbus_con = run_SCACOPF_jl(mpc, NoCon, penalty_cost)
                
                cos_pf[xy].append(SCACOPF_result[1])
                sin_pf[xy].append(SCACOPF_result[2])
                
                plc_result[xy].append(SCACOPF_result[3])
                plc_result_con[xy].append(SCACOPF_result[4])
                qlc_result[xy].append(SCACOPF_result[5])
                
                OPF_Pbra[xy].append(SCACOPF_result[6])
                OPF_Pbra_con[xy].append(SCACOPF_result[7])
                OPF_Qbra[xy].append(SCACOPF_result[8])
                
                dual_Pbra[xy].append(SCACOPF_result[9])
                dual_Pbra_con[xy].append(SCACOPF_result[10])
                dual_Qbra[xy].append(SCACOPF_result[11])
                
                dual_Pbus[xy].append(SCACOPF_result[12])
                dual_Pbus_con[xy].append(SCACOPF_result[13])
                dual_Qbus[xy].append(SCACOPF_result[14])
                dual_Qbus_con[xy].append(SCACOPF_result[15])
                
    
                # get total plcs
                sum_plc_result += sum(plc_result[xy][xsc])
                sum_qlc_result += sum(qlc_result[xy][xsc])
                
                
                # get dual for each [bus, branch]
                temp_dual_Pbra_all, temp_dual_Pbus_all = trace_pf(plc_result[xy][xsc], dual_Pbra[xy][xsc], dual_Pbus[xy][xsc], OPF_Pbra[xy][xsc])
                temp_dual_Qbra_all, temp_dual_Qbus_all = trace_pf(qlc_result[xy][xsc], dual_Qbra[xy][xsc], dual_Qbus[xy][xsc], OPF_Qbra[xy][xsc])
                
                dual_Pbra_all[xy].append(temp_dual_Pbra_all)
                dual_Pbus_all[xy].append(temp_dual_Pbus_all)
                
                dual_Qbra_all[xy].append(temp_dual_Qbra_all)
                dual_Qbus_all[xy].append(temp_dual_Qbus_all)
    
                temp_dual_Pbra_all_con = []
                temp_dual_Pbus_all_con = []
                if NoCon >= 1:
                    for xc in range(NoCon):
                        temp_bra, temp_bus = trace_pf(plc_result_con[xy][xsc][xc], dual_Pbra_con[xy][xsc][xc], dual_Pbus_con[xy][xsc][xc], OPF_Pbra_con[xy][xsc][xc])
                        temp_dual_Pbra_all_con.append(temp_bra)
                        temp_dual_Pbus_all_con.append(temp_bus)
                    
                    dual_Pbra_all_con[xy].append(temp_dual_Pbra_all_con)
                    dual_Pbus_all_con[xy].append(temp_dual_Pbus_all_con)
                        
                       
                                
                # add nonbinding constraints            
                if ite_z >= 1 and sum_plc_result > 0: 
    
                    for xbr in range(mpc["NoBranch"]):
                        # get the maximum power flow for each branch each contingency
                        max_OPF_Pbra_con  = max([ abs(a[xbr]) for a in OPF_Pbra_con[xy][xsc]])
                        # max_OPF_Qbra_con  = max([ abs(a[xbr]) for a in OPF_Qbra_con[xy][xsc]])
        
                        # get the maximum power flow for each branch
                        max_OPF_Pbra = max(abs(OPF_Pbra[xy][xsc][xbr]), max_OPF_Pbra_con )
                        # max_OPF_Qbra = max(abs(OPF_Qbra[xy][xsc][xbr]), max_OPF_Qbra_con )
                       
                        
                        if sum(Val(model.ci[i, xbr,xy,xsc]) for i in model.Set["Intv"]) >= 1 and max_OPF_Pbra/0.98 < mpc["branch"]["RATE_A"][xbr]:
                            
                            print("branch is invested but not binding:  ", xbr)
                            model.add_component("updateBinding"+str(xy)+str(xsc)+str(ite_z)+str(xbr), rule=updateBinding_rule )
                            # model.add_component("updateBindingQ"+str(xy)+str(xsc)+str(ite_z)+str(xbr), rule=updateBinding_rule )
                       
        
        
        
        
        ite_z += 1
    
    
    
       
    
    
    
    def getFlexFromPT1(model):
        # flex is fixed for part 2
        # record part1 flex result
        Pflex_pt1=[]
        Qflex_pt1=[]
        CflexP_pt1 = []
        CflexQ_pt1 = []
        Cflex_pt1 = []
        for xy in model.Set["Year"]:
            Pflex_pt1.append([])
            Qflex_pt1.append([])
            CflexP_pt1.append([])
            CflexQ_pt1.append([])
            Cflex_pt1.append([])
            
            for xsc in range(NoSce**xy):  
                Pflex_pt1[xy].append([])
                Qflex_pt1[xy].append([])
                CflexP_pt1[xy].append(0)
                CflexQ_pt1[xy].append(0)
                Cflex_pt1[xy].append(0)
                
                for xb in range(mpc["NoBus"]):
                    temp = model.Pflex[xb,xy,xsc, 0,0,0].value
                    Pflex_pt1[xy][xsc].append(temp)
                    temp = model.Qflex[xb,xy,xsc, 0,0,0].value
                    Qflex_pt1[xy][xsc].append(temp)
                    
                    temp = model.CflexP[xb,xy,xsc, 0,0,0].value
                    CflexP_pt1[xy][xsc] += temp
                    temp = model.CflexQ[xb,xy,xsc, 0,0,0].value
                    CflexQ_pt1[xy][xsc] += temp
                    
                    Cflex_pt1[xy][xsc] += CflexP_pt1[xy][xsc] + CflexQ_pt1[xy][xsc]
    
        return (Cflex_pt1, Pflex_pt1, Qflex_pt1  )


    # total flex cost from part 1
    Cflex_pt1 , Pflex_pt1, Qflex_pt1 =  getFlexFromPT1(model)
    # branch investment in part 1
    ci_pt1 = overInvstment_check(NoYear, NoSce,S_ci, mpc,model, OPF_Pbra, bra_cap)
    # total investment cost
    obj_pt1 =  Val(model.obj)

    
    print("Part 1 finished")
    return (model, obj_pt1, ci_pt1 , Cflex_pt1 , Pflex_pt1, Qflex_pt1)

# model, obj_pt1, ci_pt1 , Cflex_pt1 , Pflex_pt1, Qflex_pt1 = InvPt1_function(model,mpc, NoYear, NoSea, NoDay, penalty_cost, NoCon, NoSce,path_sce, S_ci,bra_cap,CPflex, CQflex, noDiff, genCbus,braFbus,braTbus,Pd, Qd)
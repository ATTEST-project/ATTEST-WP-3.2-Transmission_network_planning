# -*- coding: utf-8 -*-
"""
@author: Wangwei Kong

Part 2 of the investment model
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
from engines.run_OPF_jl import run_ACOPF_jl, output2json, process_flex_result
from engines.run_OPF_pp import ACOPF_function
from engines.process_data import record_bra_from_pyo_result,record_bus_from_pyo_result, record_invest_from_pyo_result,record_investCost_from_pyo_result


def InvPt2_function(input_dir,OPF_option,test_case,model,mpc,ods_file_name, penalty_cost, NoCon, prob,DF, CRF, SF, NoSce,path_sce, S_ci, Cflex_pt1, Pflex_pt1,Qflex_pt1, ci_pt1,obj_pt1,multiplier_bus,cost_base):
    
    
    # run for the 24 h
    NoTime = 24 # Number of time points
    
    print("\n--> Part 2 of the investment model")


    def pt2_Pflex_rule(m,xb,xy,xsc,xse,xd,xt):
        return m.Pflex[xb,xy,xsc,xse,xd, xt] == Pflex_pt1[xy][xsc][xb]

    def pt2_Qflex_rule(m,xb,xy,xsc,xse,xd,xt):
        return m.Qflex[xb,xy,xsc,xse,xd,xt] == Qflex_pt1[xy][xsc][xb]
    
    def pt2_plc_rule(m,xb,xy,xsc,xse,xd,xt):
        return m.Plc[xb,xy,xsc,xse,xd,xt] == 0
    def pt2_qlc_rule(m,xb,xy,xsc,xse,xd,xt):
        return m.Qlc[xb,xy,xsc,xse,xd,xt] == 0




    # New Objective function 
    def OFrule2(m):
        
        print(daily_CO)
        print(daily_dual_Sbra)

        return (        # load curtailment cost is ignored as lc is set to == 0
                        # sum( DF[xy] * SF * 
                        #         sum( m.Plc[xb, xy,xsc, xse, xd,xt]*penalty_cost 
                        #              for xb in m.Set['Bus'] for xse in m.Set['Sea'] for xd in m.Set['Day'] for xt in m.Set['Tim'] )
                        #     for xy,xsc in m.Set['YSce'] ) +
                       
                        # sum( DF[xy] * SF * 
                        #         sum( m.Qlc[xb, xy,xsc, xse, xd,xt]*penalty_cost 
                        #              for xb in m.Set['Bus'] for xse in m.Set['Sea'] for xd in m.Set['Day'] for xt in m.Set['Tim'] )
                        #     for xy,xsc in m.Set['YSce'] ) +
                         
                        # pathway cost
                        sum(prob[xp] * m.Cpath[xp] for xp in m.Set['Path']) +
           
                        
                        # CO change
                        sum( DF[xy] * SF *
                                 (daily_CO[xy][xsc]  -
                                  
                                      sum( (daily_dual_Sbra[xy][xsc][xbr]/ penalty_cost )  *
                                            (
                                                sum( m.ci[xbr,xintv,xy, xsc]*S_ci[str(xbr)][xintv]  for xintv in model.Set["Intev"][xbr] ) 
                                                 - ci_pt1[xy][xsc][xbr]  ) 
                                          for xbr in m.Set['Bra']  )
                                    )
                              for xy,xsc in m.Set["YSce"] 
                              )
                        
                     
                )
    
                         
    def runACOPF(mpc, ci,Pflex,Qflex, multiplier_bus,penalty_cost,SF):
        # print("Run OPF ") 
        year_name = [2020, 2030, 2040, 2050]
       
        OPF_opt = 1 # run ACOPF for 24h
        
        daily_CO = [] #[xy][xsc] 
        yearly_CO = []
        daily_dual_Sbra= [] #[xy][xsc][xbr]  
        
        
        # run ACOPF to get obj value for part 1
        for xy in model.Set["Year"]:
                       
            daily_CO.append([])
            yearly_CO.append([])
            daily_dual_Sbra.append([])
            
            for xsc in range(NoSce**xy):   
                mult = multiplier_bus[xy][xsc][0]
                
                daily_CO[xy].append([])
                yearly_CO[xy].append([])
                daily_dual_Sbra[xy].append([])
                
                # output investment plans for each year each scnenaior
                
                output2json(input_dir,ods_file_name,mpc,ci[xy][xsc],Pflex[xy][xsc], Qflex[xy][xsc], mult,OPF_opt )
                Pflex_up , Pflex_dn , Qflex_up ,Qflex_dn = process_flex_result(Pflex[xy][xsc], Qflex[xy][xsc] )
                
                # run ACOPF, get CO and duals for each year each scnenaior
    
                if OPF_option == "jl":
                    # run julia model
                    sbase = 100
                    CO, dual_Sbra = run_ACOPF_jl(input_dir,mpc, penalty_cost, sbase)
                    
              
                    
                if OPF_option == "pp":
                    # run pandapower model
                    CO, dual_Sbra = ACOPF_function(test_case,mpc, ci[xy][xsc],Pflex_up , Pflex_dn, mult,penalty_cost)
                    

                
                print('Year:',year_name[xy],', Scenario:', xsc,', CO:', CO/ cost_base)
                
                # TODO: update the scaling factor
                
                daily_CO[xy][xsc] = CO/ cost_base
                daily_dual_Sbra[xy][xsc] = [i/cost_base  for i in dual_Sbra] 
                yearly_CO[xy][xsc] = SF * CO/ cost_base
                
        return (daily_CO, yearly_CO, daily_dual_Sbra)
    

    
    #### part2        
    
    # fix flex power for pt2
    model.add_component("pt2_Pflex", Constraint(model.Set['Bus'],model.Set['YSce'] ,model.Set['Sea'], model.Set['Day'],model.Set['Tim'],rule=pt2_Pflex_rule ))
    model.add_component("pt2_Qflex", Constraint(model.Set['Bus'],model.Set['YSce'] ,model.Set['Sea'], model.Set['Day'],model.Set['Tim'],rule=pt2_Qflex_rule ))
    
    model.add_component("pt2_plc_rule", Constraint(model.Set['Bus'],model.Set['YSce'] ,model.Set['Sea'], model.Set['Day'],model.Set['Tim'],rule=pt2_plc_rule ))
    model.add_component("pt2_qlc_rule", Constraint(model.Set['Bus'],model.Set['YSce'] ,model.Set['Sea'], model.Set['Day'],model.Set['Tim'],rule=pt2_qlc_rule ))
    
    
            
    daily_CO, yearly_CO, daily_dual_Sbra = runACOPF(mpc, ci_pt1,Pflex_pt1,Qflex_pt1, multiplier_bus, penalty_cost,SF)
    
    print(daily_CO, yearly_CO, daily_dual_Sbra)
     
      
    CO_pt2 = sum( DF[xy] * SF * daily_CO[xy][xsc] for xy, xsc in model.Set["YSce"])
    
    # update obj cost with operation cost
    obj_pt1 += CO_pt2
    print("Total operation and investment cost using Part 1 results: ", obj_pt1)
    
    ciCost_pt2 = Val( sum( model.ciCost[xy,xsc] for xy,xsc in model.Set["YSce"] ) )  

    print("ciCost_pt2: ", ciCost_pt2)     
    
    yearly_ciCost = record_investCost_from_pyo_result(model,mpc,NoSce, model.ciCost)
    ci_pt2_ref = record_invest_from_pyo_result(model, mpc,NoSce, model.ci, S_ci) 
    
    
    
    
    # iteration
    obj_ref = obj_pt1
    ite_z = 0
    obj_change = True
    
    while obj_change:
        print("\n---- iteration: ", ite_z)
           
        
        # Change Obj based on outputs from ACOPF
        model.del_component(model.obj)
        model.obj = Objective(rule=OFrule2, sense=minimize)
        
        # solve pyomo model
        solver = SolverFactory('glpk')
        results = solver.solve(model)
        
        print ('solver termination condition: ', results.solver.termination_condition)
             
        
        
        # new obj cost includes operation cost
        obj_pt2 =  Val(sum(prob[xp] * model.Cpath[xp] for xp in model.Set['Path']))
        
            
        # record new ci
        ci_pt2_update = record_invest_from_pyo_result(model, mpc,NoSce, model.ci, S_ci)   
        print("ci_pt2_update: ", ci_pt2_update)
        
        
        # re-run ACOPF with new investment plans  
        daily_CO_update, yearly_CO_update, daily_dual_Sbra_update= runACOPF(mpc, ci_pt2_update,Pflex_pt1,Qflex_pt1,multiplier_bus,penalty_cost,SF)
        
        # get operation cost
        CO_pt2_update = sum( DF[xy] * SF * daily_CO_update[xy][xsc] for xy, xsc in model.Set["YSce"])
        
        obj_pt2 += CO_pt2_update
        
        print('Total operation and investment cost of Part 2:',obj_pt2)
        
        ciCost_pt2_update = Val( sum( model.ciCost[xy,xsc] for xy,xsc in model.Set["YSce"] ) )  
        yearly_ciCost_update = record_investCost_from_pyo_result(model,mpc,NoSce, model.ciCost)
     
        # find the min obj cost
        if obj_pt2 >= obj_ref:
            
            obj_change = False
                        
            
            
        else:
            # update obj cost 
            obj_ref = obj_pt2
            
            daily_CO = daily_CO_update
            yearly_CO = yearly_CO_update
            daily_dual_Sbra = daily_dual_Sbra_update
            CO_pt2 = CO_pt2_update
            ciCost_pt2 = ciCost_pt2_update    
            yearly_ciCost = yearly_ciCost_update
            ci_pt2_ref = copy.deepcopy(ci_pt2_update) 
            
            
            ite_z += 1 
    

    Cflex_pt2 = Cflex_pt1
    Pflex_pt2 = Pflex_pt1
    
    print("Part 2 finished")
    # print('Final cost of Part 2:',obj_ref)



    return (model, obj_ref, CO_pt2, yearly_CO, ci_pt2_ref, ciCost_pt2, yearly_ciCost, Cflex_pt2,Pflex_pt2)




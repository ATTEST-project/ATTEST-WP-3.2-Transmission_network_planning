# -*- coding: utf-8 -*-
"""
Created on Fri Apr 29 18:21:30 2022

@author: p96677wk
"""
from __future__ import (division, print_function)
from pyomo.core import ConcreteModel, Constraint, minimize, NonNegativeReals, \
 Objective, Var, RangeSet, Binary, Set, Reals
from pyomo.core import value as Val


def record_bra_from_pyo_result(model,mpc,NoSce, pyo_var, year_peak):
    
    record_pyo_var = []
    # if yearly peak value only:
    if year_peak == True: 
        
      for xy in model.Set["Year"]:
            record_pyo_var.append([])  
            for xsc in range(NoSce**xy): 
                record_pyo_var[xy].append([])
                for xbr in range(mpc['NoBranch']):
                    record_pyo_var[xy][xsc].append(Val(pyo_var[xbr,xy,xsc,0,0,0]))
    else:
        
        for xy in model.Set["Year"]:
            record_pyo_var.append([])
            for xsc in range(NoSce**xy):
                record_pyo_var[xy].append([])               
                for xse in model.Set['Sea']:
                    record_pyo_var[xy][xsc].append([])
                    for xd in  model.Set['Day']:
                        record_pyo_var[xy][xsc][xse].append([])
                        for xt in  model.Set['Tim']:
                            record_pyo_var[xy][xsc][xse][xd].append([])
                            for xbr in range(mpc['NoBranch']):
                                record_pyo_var[xy][xsc][xse][xd][xt].append(Val(pyo_var[xbr,xy,xsc,xse,xd,xt]))
                
    return record_pyo_var

def record_bus_from_pyo_result(model,mpc,NoSce, pyo_var, year_peak):
    
    record_pyo_var = []
    # if yearly peak value only:
    if year_peak == True: 
        
      for xy in model.Set["Year"]:
            record_pyo_var.append([])  
            for xsc in range(NoSce**xy): 
                record_pyo_var[xy].append([])
                for xbr in range(mpc['NoBus']):
                    record_pyo_var[xy][xsc].append(Val(pyo_var[xbr,xy,xsc,0,0,0]))
    else:
        
        for xy in model.Set["Year"]:
            record_pyo_var.append([])
            for xsc in range(NoSce**xy):
                record_pyo_var[xy].append([])               
                for xse in model.Set['Sea']:
                    record_pyo_var[xy][xsc].append([])
                    for xd in  model.Set['Day']:
                        record_pyo_var[xy][xsc][xse].append([])
                        for xt in  model.Set['Tim']:
                            record_pyo_var[xy][xsc][xse][xd].append([])
                            for xbr in range(mpc['NoBus']):
                                record_pyo_var[xy][xsc][xse][xd][xt].append(Val(pyo_var[xbr,xy,xsc,xse,xd,xt]))
                
    return record_pyo_var

def record_invest_from_pyo_result(model,mpc,NoSce, ci_var):
    
    record_pyo_var = []

        
    for xy in model.Set["Year"]:
          record_pyo_var.append([])  
          for xsc in range(NoSce**xy): 
              record_pyo_var[xy].append([])
              for xbr in range(mpc['NoBranch']):
                  record_pyo_var[xy][xsc].append(Val(sum(ci_var[xint,xbr,xy,xsc] for xint in model.Set["Intv"])))
    
                
    return record_pyo_var


def record_investCost_from_pyo_result(model,mpc,NoSce, ci_var):
    
    record_pyo_var = []

        
    for xy in model.Set["Year"]:
          record_pyo_var.append([])  
          for xsc in range(NoSce**xy):
              record_pyo_var[xy].append(Val(ci_var[xy,xsc] ))
    
                
    return record_pyo_var


def initial_value(mpc,NoYear,NoSce, input_val):
    
    record_var = []

        
    for xy in range(NoYear):
          record_var.append([])  
          for xsc in range(NoSce**xy): 
              record_var[xy].append([])
              for xbr in range(mpc['NoBranch']):
                  record_var[xy][xsc].append(Val(input_val))

                
    return record_var

def recordValues(mpc):
    # record original branch capacity        
    bra_cap = []
    for xbr in range(mpc['NoBranch']):
        bra_cap.append( mpc["branch"]["RATE_A"][xbr] )
    
    
    gen_cost = []
    for xgc in range(mpc["NoGen"]):
        gen_cost.append(mpc["gencost"]["COST"][xgc][0] )
        
    return (bra_cap, gen_cost)


def replaceGenCost(mpc, gen_cost, action):
    # action  = 0, remove gen cost
    # action  = else, recover gen cost
    
    if action == 0:
        # remove gen cost in mpc
        for xgc in range(mpc["NoGen"]):
            mpc["gencost"]["COST"][xgc][0] = 0.1*(xgc + 1)
    else:
        # recover gen cost
        for xgc in range(mpc["NoGen"]):
            mpc["gencost"]["COST"][xgc][0] = gen_cost[xgc]
    
    return mpc
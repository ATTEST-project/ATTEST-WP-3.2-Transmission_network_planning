# -*- coding: utf-8 -*-
"""
Created on Tue May  3 13:02:05 2022

@author: p96677wk
"""

from __future__ import (division, print_function)
from pyomo.core import ConcreteModel, Constraint, minimize, NonNegativeReals, \
 Objective, Var, RangeSet, Binary, Set, Reals
from pyomo.core import value as Val

#### Over-investment check #################################

# TODO: Check OPF_Pbra[xy][xsc][xbr] list orders to suit OPF outputs
def overInvstment_check(NoYear, NoSce, S_ci, mpc,model, OPF_Pbra, bra_cap):
    print("\n--> over investment check")
    ci = []
    no_ci = len(S_ci)
    # check if over invested
    for xy in model.Set["Year"]:
        ci.append([])
        for xsc in range(NoSce**xy): 
            ci[xy].append([])
            for xbr in range(mpc['NoBranch']):     
                ci[xy][xsc].append([])
                
                if  sum( Val(model.ci[i, xbr,xy,xsc]) for i in model.Set["Intv"]) > 0 and abs(OPF_Pbra[xy][xsc][xbr]) <=  bra_cap[xbr]: 
                    # overInv_check = 0 
                    for xintv in model.Set["Intv"]:
                        model.ci[xintv, xbr,xy,xsc].value = 0                  
                    print("Remove capacity investment on Branch ", xbr)
                
                    
                for xintv in range(no_ci):
                    if Val(model.ci[no_ci-1-xintv, xbr,xy,xsc]) > 0 and abs(OPF_Pbra[xy][xsc][xbr]) <=  bra_cap[xbr]+S_ci[no_ci-1-xintv-1] and xintv < no_ci-1: # new line
                        model.ci[no_ci-1-xintv, xbr,xy,xsc].value = 0
                        model.ci[no_ci-1-xintv-1, xbr,xy,xsc].value = 1
                        print("Change capacity investment on Branch ", xbr,": from ",S_ci[no_ci-1-xintv], " to ", S_ci[no_ci-1-xintv-1])
                    
                    if Val(model.ci[0, xbr,xy,xsc]) > 0 and abs(OPF_Pbra[xy][xsc][xbr]) <=  bra_cap[xbr] and xintv == no_ci-1:
                        model.ci[0, xbr,xy,xsc].value = 0
                        print("Remove capacity investment on Branch ", xbr)
                
                # store investment decisions
                ci[xy][xsc][xbr] = sum(S_ci[i]* Val(model.ci[i, xbr,xy,xsc]) for i in model.Set["Intv"])
     
    print("Over-investment check pass")
    
    
    return ci

# ci = overInvstment_check(NoYear, NoSce, S_ci, mpc,model, OPF_Pbra, bra_cap):
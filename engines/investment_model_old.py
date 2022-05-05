# -*- coding: utf-8 -*-
"""

@author: Wangwei Kong
"""
# This is a VScode-Git test by Andrey

from __future__ import (division, print_function)
from pyomo.core import ConcreteModel, Constraint, minimize, NonNegativeReals, \
 Objective, Var, RangeSet, Binary, Set, Reals
from pyomo.environ import SolverFactory
from pyomo.core import value as Val
import networkx as nx
from dataclasses import dataclass
import json
import os
import math
import numpy as np
from engines.DCOPF import DCOPF_function

@dataclass
class network_variable:
    name                :   str     = None      # Name of the variable
    position_tree       :   dict    = None      # Position in the energy tree - representative days
    hour                :   int     = None      # Hour of the solution in case of multiple hours
    ID                  :   str     = None      # ID of element
    type                :   str     = None      # Type of element, e.g. bus, branch
    sub_type            :   str     = None      # Sub type of element, e.g. thermal, hydro
    value               :   float   = None      # Value of the solution for this specific variable

@dataclass
class network_parameter:
    name                :   str     = None      # Name of the parameter
    position_tree       :   dict    = None      # Position in the energy tree - representative days
                                                # in case of parameters changing in time
    hour                :   int     = None      # Hour of the parameter in case of parameters 
                                                # changing in time
    ID                  :   str     = None      # ID of element
    type                :   str     = None      # Type of element, e.g. bus, branch
    sub_type            :   str     = None      # Sub type of element, e.g. thermal, hydro
    bus                 :   int     = None      # Number of the bus (node) that the element is 
                                                # related
    ends                :   list    = None      # list of ends for branches in format [from, to]
    value               :   float   = None      # Value of specific parameter
 
@dataclass
class nodes_info_network:
    type                :   str     = None      # Type of element, e.g. bus, branch, generator
    sub_type            :   str     = None      # Sub type of element, e.g. thermal, hydro
    ID                  :   str     = None      # ID of element
    node                :   int     = None      # Number of node in graph
    parameters          :   list    = None      # Parameters associated to the node in the graph
    variables           :   list    = None      # Variables associated to the node in the graph
    bus                 :   int     = None      # Number of the bus related to the graph's node
    ends                :   list    = None      # list of ends for branches in format [from, to]

# ####################################################################
# ####################################################################
def main_investment(): 
    ''''read paras and vars from jason file'''
    def readVarPara():
    
        '''Input parameters for generator, bus and branch'''
        
        '''
            Recorded parameters are:
                     auxGen = ['PMAX', 'PMIN', 'QMAX', 'QMIN', 'VG']
                     auxBus = ['BASE_KV', 'PD', 'QD', 'VMAX', 'VMIN']
                     auxBranch = ['BR_B', 'BR_R', 'BR_X', 'RATE_A', 'BR_STATUS']
    
            Recorded variables are:
                     auxGen=['Pout','Qout']
                     auxBus=['Pin','Qin''Pout','Qout']
                     auxBranch=['P','Q','ANG']    
        '''
        
        # Input generator parameters   
        nw_parameters=[]
        auxGen = ['PMAX', 'PMIN', 'QMAX', 'QMIN', 'VG']
        # gen_para = []
        
        for NoGen in range(mpc['NoGen']):
            for gen_para_name in auxGen:
                gen_para_temp = network_parameter( 
                            name             = gen_para_name,      
                            position_tree    = None,      
                            hour             = None,      
                            ID               = 'Gen'+str(NoGen),    
                            type             = 'generator',      
                            sub_type         = None,      
                            bus              = mpc['gen']['GEN_BUS'][NoGen],      
                            ends             = None,      
                            value            = mpc['gen'][gen_para_name][NoGen]
                                              )
                
                
                # Add generator parameters  
                # gen_para.append(gen_para_temp)
                nw_parameters.append(gen_para_temp)
    
        del auxGen,gen_para_temp, gen_para_name
        
        # Input bus parameters   
        auxBus = ['BASE_KV', 'PD', 'QD', 'VMAX', 'VMIN']
        # bus_para = []
        
        for NoBus in range(mpc['NoBus']):
            
            for bus_para_name in auxBus:
                bus_para_temp = network_parameter( 
                            name             = bus_para_name,      
                            position_tree    = None,      
                            hour             = None,      
                            ID               = 'Bus'+str(NoBus),  
                            type             = 'bus',      
                            sub_type         = None,      
                            bus              = mpc['bus']['BUS_I'][NoBus],      
                            ends             = None,      
                            value            = mpc['bus'][bus_para_name][NoBus]
                                              )    
                             
                # bus_para.append(bus_para_temp)
                nw_parameters.append(bus_para_temp)
        
        del auxBus, bus_para_temp, bus_para_name
        
        
        # Input branch parameters   
        auxBranch = ['BR_B', 'BR_R', 'BR_X', 'RATE_A', 'BR_STATUS']
        # branch_para = []
        
        for NoBranch in range(mpc['NoBranch']):
            for branch_para_name in auxBranch:
                branch_para_temp = network_parameter( 
                            name             = branch_para_name,      
                            position_tree    = None,      
                            hour             = None,      
                            ID               = 'Branch'+str(NoBranch),
                            type             = 'branch',      
                            sub_type         = None,                            
                            ends             = [mpc['branch']['F_BUS'][NoBranch], mpc['branch']['T_BUS'][NoBranch]],     
                            value            = mpc['branch'][branch_para_name][NoBranch]
                                              )    
                # Add branch parameters  
                # branch_para.append(branch_para_temp)
                nw_parameters.append(branch_para_temp)
        del auxBranch, branch_para_temp, branch_para_name
        
        # ####################################################################
        # ####################################################################
        
        '''Input vars for generator, bus and branch'''
        # Input gen vars   
        nw_variables=[]
        auxGen=['Pout','Qout']
        for NoGen in range(mpc['NoGen']):
            for gen_var_name in auxGen:
                gen_var_temp = network_variable( 
                            name             = gen_var_name,      
                            position_tree    = None,      
                            hour             = None,      
                            ID               = 'Gen'+str(NoGen),    
                            type             = 'generator',      
                            sub_type         = None,        
                            value            = None
                                              )
                # Add generator vars  
               
                nw_variables.append(gen_var_temp)
        del auxGen, gen_var_temp, gen_var_name
        
        
        # Input bus vars   
        auxBus=['Pin','Qin','Pout','Qout']
        for NoBus in range(mpc['NoBus']):
            for bus_var_name in auxBus:
                bus_var_temp = network_variable( 
                            name             = bus_var_name,      
                            position_tree    = None,      
                            hour             = None,      
                            ID               = 'Bus'+str(NoBus),    
                            type             = 'bus',      
                            sub_type         = None,        
                            value            = None
                                              )
                # Add bus vars 
                nw_variables.append(bus_var_temp)
        del auxBus, bus_var_temp, bus_var_name
        
        
        # Input branch vars   
        auxBranch=['P','Q','ANG']
        for NoBranch in range(mpc['NoBranch']):
            for branch_var_name in auxBranch:
                branch_var_temp = network_variable( 
                            name             = branch_var_name,      
                            position_tree    = None,      
                            hour             = None,      
                            ID               = 'Branch'+str(NoBranch),    
                            type             = 'branch',      
                            sub_type         = None,        
                            value            = None
                                              )
                # Add bus vars 
                nw_variables.append(branch_var_temp)
        del auxBranch, branch_var_temp, branch_var_name
        
        
        # NoID is total number of elements  NoID = NoGen + NoBranch + NoBus
        NoID = mpc['NoGen'] + mpc['NoBranch'] + mpc['NoBus']
        
        return nw_parameters, nw_variables
    
    
    # ####################################################################
    # ####################################################################
    

    '''Network model to record var and para in graph and get values from node'''
    class NetworkModel():
        def __init__(self):
            self.readVarPara = readVarPara()
            self.network_parameters = self.readVarPara[0] # nw_parameters
            self.network_variables = self.readVarPara[1]  # nw_variables
            # self.create_graph = self._create_graph()
            self._create_graph()
            
            
        def _create_nodes_graph(self):
               nodes_graph = []
               exist = False
               counter = 0
               
               # Creating list of nodes  and adding parameters
               for parameter in self.network_parameters:
                     if nodes_graph:
                         for node_g in nodes_graph:
                             if node_g.ID == parameter.ID:
                                 exist = True
                                 node_g.parameters.append(parameter)
                                 break
                     if not exist:
                         node = nodes_info_network() 
                         node.node = counter
                         node.type = parameter.type
                         node.sub_type = parameter.sub_type
                         node.ID = parameter.ID
                         node.parameters = [parameter]
                         node.bus = parameter.bus
                         node.ends = parameter.ends
                         counter += 1
                         nodes_graph.append(node)
                     exist = False
    
               # Adding variables to nodes 
               for variable in self.network_variables:
                   for node_g in nodes_graph:
                       if node_g.ID == variable.ID:
                           if node_g.variables:
                               node_g.variables.append(variable)
                           else:
                               node_g.variables = [variable]
                           break
        
               # Adding nodes to graph
               for node_g in nodes_graph:
                   self.network.add_node(node_g.node, obj=node_g)
        
        
        def _create_edges_graph(self):
            # Creating branches of graph
            branches_graph = []
            for node_g in self.network.nodes(data=True):
                if node_g[1]['obj'].type == "generator":
                    for aux in self.network.nodes(data=True):
                        if aux[1]['obj'].type == "bus" and node_g[1]['obj'].bus == aux[1]['obj'].bus:
                            branches_graph.append([aux[1]['obj'].node, node_g[1]['obj'].node])
                            break
                elif node_g[1]['obj'].type == "branch":
                    flag = [False, False]
                    for aux in self.network.nodes(data=True):
                        if aux[1]['obj'].type == "bus" and node_g[1]['obj'].ends[0] == aux[1]['obj'].bus:
                            branches_graph.append([aux[1]['obj'].node, node_g[1]['obj'].node])
                            flag[0] = True
                        elif aux[1]['obj'].type == "bus" and node_g[1]['obj'].ends[1] == aux[1]['obj'].bus:
                            branches_graph.append([node_g[1]['obj'].node, aux[1]['obj'].node])
                            flag[1] = True
                        if flag[0] and flag[1]:
                            break
            self.branches_graph = branches_graph
            for branches in  branches_graph:
                self.network.add_edge(branches[0], branches[1])
        
        
        def _create_graph(self):
            self.network = nx.MultiGraph()
            self._create_nodes_graph()
            self._create_edges_graph()
            
            
        
    
    
        def get_value_network(self, ID=None, name=None, position_tree=None, hour=None, typ=None):
                ''' This function retrieves the values of variables and parameters
        
                    Parameters
                    ----------
                    Mandatory:\\
                    ID              :   Unique ID of the network element\\
                    name            :   Name of variable or parameter to be retrieved\\
                    position_tree   :   Dictionary containing information of the location of the information
                                        in relation with the energy tree. If the value does not vary with
                                        the energy tree then this value should be left in None\\
                    hour            :   integer that indicates the specific hour of the requested data. If
                                        the data does not change in time then this input must be left in
                                        None\\
                    typ             :   This refers to the type of element to be retrieved. This value
                                        can be either "variable" or "parameter". Other values will not
                                        be accepted
                '''
                if not position_tree:
                    for node in self.network.nodes(data=True):
                        if node[1]['obj'].ID == ID and typ == "parameter":
                            for parameter in node[1]['obj'].parameters:
                                if parameter.name == name and (not hour or hour == parameter.hour):
                                    return parameter.value
                        if node[1]['obj'].ID == ID and typ == "variable":
                            for variable in node[1]['obj'].variables:
                                if variable.name == name and (not hour or hour == variable.hour):
                                    return variable.value
                else:
                    number_node = self._get_initial_tree_node(position_tree)
                    return self._calculate_value_tree(number_node, ID, position_tree, hour, typ, False)
        
                return None
     
    
    
    # ####################################################################
    
    
    '''optimization (pyomo) model'''
    
    #  Sets 
    def addSet(m):
        m.Set={}
        ''' Add pyomo sets '''
        m.Set['Bra'] = range(mpc['NoBranch'])
        m.Set['Bus'] = range(mpc['NoBus'])
        m.Set['Gen'] = range(mpc['NoGen'])
        m.Set['Tim'] = range(NoTime)
        
        m.Set["Intv"] = range(len(P_ci))
       
        #m.ciset = range(2) # all intervension set
        
        # m.Set['Year'] = range(Year) 
        # m.Set['Sce'] = range(NoScenario)
    
        return m
    
    
    #   Parameters 
    def addPara(m):
        m.para={}
    
        for node in NetworkModel.network.nodes(data=True):
            for NoPar in range(len(node[1]['obj'].parameters)):  
                m.para [node[1]['obj'].ID + str('_') + node[1]['obj'].parameters[NoPar].name ] \
                    = node[1]['obj'].parameters[NoPar].value
       
    
        return m
    
    
    
     
    # Var          
    def addVar(m):
       
        # Gen
        m.Pgen = Var(m.Set['Gen'], m.Set['Tim'], domain=NonNegativeReals, initialize=10)
        m.Qgen = Var(m.Set['Gen'], m.Set['Tim'], domain=NonNegativeReals, initialize=10)
        m.Cgen = Var(m.Set['Gen'], m.Set['Tim'], domain=NonNegativeReals, initialize=10)
        
        # Flexibility service
        # TODO: change flex to each bus or load or gen?
        m.Pflex = Var(m.Set['Bus'], m.Set['Tim'], domain=Reals, initialize=0)
        m.Qflex = Var(m.Set['Bus'], m.Set['Tim'], domain=Reals, initialize=0)
        m.Sflex = Var(m.Set['Bus'], m.Set['Tim'], domain=Reals, initialize=0)
        
        # Branch
        m.Pbra = Var(m.Set['Bra'],m.Set['Tim'], domain=Reals, initialize=0)
        m.Qbra = Var(m.Set['Bra'],m.Set['Tim'], domain=Reals, initialize=0)
        
        # Investment decisions on upgrading line, addting new line
        m.ci = Var(m.Set["Intv"], m.Set['Bra'], initialize=0, domain=Binary, bounds=(0,1))
        
        # # Bus
        # m.Pin = Var(m.Set['Bus'], domain=Reals, initialize=0)
        # m.Pout = Var(m.Set['Bus'], domain=Reals, initialize=0)
        
        # Load curtailment
        m.Plc = Var(m.Set['Bus'],m.Set['Tim'], domain=NonNegativeReals, initialize=0)
        m.Qlc = Var(m.Set['Bus'],m.Set['Tim'], domain=NonNegativeReals, initialize=0)
        m.Slc = Var(m.Set['Bus'],m.Set['Tim'], domain=NonNegativeReals, initialize=0)   
        
        # Bus angle
        m.Ang = Var(m.Set['Bus'], m.Set['Tim'], bounds=(-2*math.pi, 2*math.pi), initialize=0) # from 0
    
        
       
        
       
        return m
         
    
    class rules:
        #TODO: check if slack gen max is inf
    
        # Gen output constraint rules
        def genMax_rule(m, xg, xt):
            pmax=[]
            for node in NetworkModel.network.nodes(data=True):
                if node[1]['obj'].type == "generator":
                    pmax.append( node[1]['obj'].parameters[0].value)
    
            return m.Pgen[xg, xt] <= pmax[xg]  # Gpout<=Pmax
            del pmax
        
        def genMin_rule(m,xg, xt):
            pmin=[]
            for node in NetworkModel.network.nodes(data=True):
                if node[1]['obj'].type == "generator":
                    pmin.append( node[1]['obj'].parameters[1].value)
            return m.Pgen[xg, xt] >= pmin[xg]  # Gpout>=Pmin
            del pmin
        
        def genQMax_rule(m,xg, xt):
            Qmax=[]
            for node in NetworkModel.network.nodes(data=True):
                if node[1]['obj'].type == "generator":
                    Qmax.append( node[1]['obj'].parameters[2].value)
         
            return  m.Qgen[xg, xt] <= Qmax[xg]  # GQout<=Qmax
            del Qmax
        
        def genQMin_rule(m,xg, xt):
            Qmin=[]
            for node in NetworkModel.network.nodes(data=True):
                if node[1]['obj'].type == "generator":
                    Qmin.append( node[1]['obj'].parameters[3].value)
         
            return  m.Qgen[xg, xt] >= Qmin[xg]  # GQout>=Qmin
            del Qmin
                   
    
             
        # Flexibility service output constraint rules
        # TODO: import data: Pflex_max, Qflex_max
       
            
        def flexPMax_rule(m, xb, xt):
            Pflex_max = None  # ??? mpc['flex_max'] or import from excel ???
            if Pflex_max == None:
                return m.Pflex[xb, xt] == 0
            else: 
                return  m.Pflex[xb, xt] <= Pflex_max[str(xt)][xb]  
        
        def flexQMax_rule(m, xb, xt):
            Qflex_max = None
            if Qflex_max == None:
                return m.Qflex[xb, xt] == 0
            else: 
                return  m.Qflex[xb, xt] <= Qflex_max[xb, xt] 
            
        def flexS_rule(m, xb, xt):
            return  m.Sflex[xb, xt]**2 == m.Pflex[xb, xt]**2 + m.Qflex[xb, xt]**2    
        
         
        # Load curtialment constraint 
        def Slc_rule(m, xb, xt):
            return  m.Slc[xb, xt]**2 == m.Plc[xb, xt]**2 + m.Qlc[xb, xt]**2
        
    
         # Branch constraint
         # Branch capacity is increased if the line is upgraded or new line is installed
        def braCapacity_rule(m, xbr, xt):
              noDiff = mpc['NoGen'] + mpc['NoBus'] # change node number to branch number
              if NetworkModel.network._node[xbr + noDiff]['obj'].parameters[3].value != 0:
                  return m.Pbra[xbr, xt] <= \
                      NetworkModel.network._node[xbr + noDiff]['obj'].parameters[3].value \
                          + sum(P_ci[i]* m.ci[i,xbr] for i in m.Set["Intv"])  # upg capacity or new capacity
              else:
                  return  m.Pbra[xbr, xt] <= float('inf')    
    
    
        # both flow directions
        def braCapacityN_rule(m,xbr, xt):
              # #TODO: update the line capacity
              noDiff = mpc['NoGen'] + mpc['NoBus'] # change node number to branch number
              if NetworkModel.network._node[xbr + noDiff]['obj'].parameters[3].value != 0:
                  return - m.Pbra[xbr, xt] <= \
                        NetworkModel.network._node[xbr + noDiff]['obj'].parameters[3].value \
                          + sum(P_ci[i]* m.ci[i,xbr] for i in m.Set["Intv"]) 
                          # upg capacity or new capacity    
              else:
                  return  -m.Pbra[xbr, xt] <=  float('inf')  
        
        
    
        
        def intervension_rule(m,xbr):
            # if a new line is added, it cannot be upgraded simutaneously
            return sum(m.ci[i,xbr]  for i in m.Set["Intv"]) <= 1
        
    
    
        # Nodal power balance
        def nodeBalance_rule(m, xb, xt):
                    
            return sum( m.Pgen[genCbus[xb][i],xt]  for i in range(len(genCbus[xb])) ) + m.Pflex[xb,xt]   \
                    + sum( m.Pbra[braTbus[xb][i]-noDiff,xt]  for i in range(len(braTbus[xb])) )  \
                    == sum( m.Pbra[braFbus[xb][i]-noDiff,xt]  for i in range(len(braFbus[xb])) ) \
                      + Pd[xb][xt] - m.Plc[xb,xt]
    
    
        # Nodal power balance Q
        def nodeBalanceQ_rule(m, xb, xt):
                   
            return sum( m.Qgen[genCbus[xb][i],xt]  for i in range(len(genCbus[xb])) ) + m.Qflex[xb,xt]   \
                    + sum( m.Qbra[braTbus[xb][i]-noDiff,xt]  for i in range(len(braTbus[xb])) )  \
                    == sum( m.Qbra[braFbus[xb][i]-noDiff,xt]  for i in range(len(braFbus[xb])) ) \
                      + Qd[xb][xt] - m.Qlc[xb,xt]
           # return sum( m.Pgen[genCbus[xb][i],xt]  for i in range(len(genCbus[xb])) )>=500
    
    
        # # Cost Constraints
        # Piece wise gen cost: Number of piece = 3
        def pwcost_rule(m,xg,xt):
            if Val(m.Pgen[xg,xt]) <= xval[1][xg]:
                return m.Cgen[xg,xt] == m.Pgen[xg,xt] * lcost[0][xg]
            else:
                if Val(m.Pgen[xg,xt]) <= xval[2][xg]:
                    return m.Cgen[xg,xt] == m.Pgen[xg,xt] * lcost[1][xg]
                else:
                    return m.Cgen[xg,xt] == m.Pgen[xg,xt] * lcost[2][xg]
                
        def budget_rule(m):
            return sum( m.ci[i,xbr]*P_ci[i]*ci_cost for xbr in m.Set['Bra'] for i in m.Set["Intv"]) <= Budget_cost
        
        
        
        # DC power flow
        def DCPF_rule(m, xbr,xt):
            br_X=[]
            fbus = []
            tbus = []
            pu2value = mpc['bus']['BASE_KV'][0]**2 / mpc['baseMVA']
            for node in NetworkModel.network.nodes(data=True):
                if node[1]['obj'].type == "branch":
                    fbus.append ( node[1]['obj'].ends[0] -1 )
                    tbus.append ( node[1]['obj'].ends[1] -1 )
                    br_X.append ( node[1]['obj'].parameters[2].value/100 )
            
            return  m.Pbra[xbr,xt] == ( m.Ang[fbus[xbr],xt] - m.Ang[tbus[xbr],xt]) / br_X[xbr]
        
        
        def slackBus_rule(m,xt):
            for i in range(mpc['NoBus']):
                if mpc['bus']['BUS_TYPE'][i] == 3:
                    slc_bus = i
            
            return m.Ang[slc_bus,xt] == 0    
        
        
        def testInvest_rule(m, xbr,xt):
            screen_results = [133, 58, 0, 0, 48,0]# [165, 83, 0,0, 83,0] #
            
            return sum(P_ci[i]* m.ci[i,xbr] for i in m.Set["Intv"])  == screen_results[xbr]
        
    
    
            
    
        
    
    def addConstraints(m):
            
        # Add nodal balance constraint rules
        m.nodeBalance = Constraint( m.Set['Bus'],m.Set['Tim'], rule=rules.nodeBalance_rule )  
        m.nodeBalanceQ = Constraint( m.Set['Bus'],m.Set['Tim'], rule=rules.nodeBalanceQ_rule ) 
        
        # TODO: Add branch capacity for Q and S
        # Add branch capacity constraints
        m.braCapacity = Constraint( m.Set['Bra'],m.Set['Tim'], rule=rules.braCapacity_rule )
        m.braCapacityN = Constraint( m.Set['Bra'], m.Set['Tim'], rule=rules.braCapacityN_rule )
        
        # intervension rule
        m.intervension = Constraint( m.Set['Bra'], rule=rules.intervension_rule )
        
        # Add Gen constraint rules
        m.genMax = Constraint( m.Set['Gen'], m.Set['Tim'], rule=rules.genMax_rule )
        m.genMin = Constraint( m.Set['Gen'],m.Set['Tim'], rule=rules.genMin_rule )
        # m.genQMax = Constraint( m.Set['Gen'], m.Set['Tim'], rule=rules.genQMax_rule )
        # m.genQMin = Constraint( m.Set['Gen'],m.Set['Tim'],  rule=rules.genQMin_rule )
        
        # piecve wise gen cost
        m.pwcost = Constraint(m.Set['Gen'],  m.Set['Tim'], rule=rules.pwcost_rule )
        
    
        # Add flex constraint rules
        m.flexPMax = Constraint( m.Set['Bus'],m.Set['Tim'], rule=rules.flexPMax_rule )
        m.flexQMax = Constraint( m.Set['Bus'],m.Set['Tim'], rule=rules.flexQMax_rule )
        
        
        # m.flexS = Constraint( m.Set['Bus'],m.Set['Tim'], rule=rules.flexS_rule )
      
        # Add curtailment rules
        # m.Slc = Constraint( m.Set['Bus'],m.Set['Tim'], rule=rules.Slc_rule )
            
        # budget rule
        m.budget = Constraint(  rule=rules.budget_rule )
    
           
        # Add branch flow DC OPF
        # m.DCPF = Constraint( m.Set['Bra'], m.Set['Tim'], rule=rules.DCPF_rule ) 
        
        # Set slack bus angle to 0
        # m.slackBus = Constraint( m.Set['Tim'], rule=rules.slackBus_rule )
        
        # test screen results
        #m.testInvest = Constraint( m.Set['Bus'],m.Set['Tim'], rule=rules.testInvest_rule )
    
        
    
        return m
        
    
    def genCost_rule(mpc, xLen=0):
            '''
            MODEL       1   cost model, 1 = piecewise linear, 2 = polynomial
            STARTUP     2   startup cost in US dollars*
            SHUTDOWN    3   shutdown cost in US dollars*
            NCOST       4   number N = n + 1 of data points defining an n-segment piecewise linear cost
                            function, or of coefficients defining an n-th order polynomial cost function
            COST        5   parameters defining total cost function f(p) begin in this column,
                            units of f and p are $/hr and MW (or MVAr), respectively
                            (MODEL = 1) ⇒ p1, f1, p2, f2, . . . , pN , fN
                                where p1 < p2 < · · · < pN and the cost f(p) is defined by
                                the coordinates (p1, f1), (p2, f2), . . . , (pN , fN )
                                of the end/break-points of the piecewise linear cost
                            (MODEL = 2) ⇒ cn, . . . , c1, c0
                                N coefficients of n-th order polynomial cost function, starting
                                with highest order, where cost is f(p) = cnp
                                n + · · · + c1p + c0
            '''
            # Define piece wise cost curve approximation 
            LGcost = []
            xval = np.zeros((4,mpc['NoGen']), dtype=float)
            yval = np.zeros((4,mpc['NoGen']), dtype=float)
            lcost = np.zeros((3, mpc['NoGen']), dtype=float)
            
            for NoGen in range(mpc['NoGen']):
                if mpc['gencost']['MODEL'][NoGen] == 1:          # Piece-wise model
                    NoPieces = mpc['gencost']['NCOST'][NoGen]
                    xval = np.zeros(NoPieces, dtype=float)
                    yval = np.zeros(NoPieces, dtype=float)
                    xp = 0
                    for x in range(NoPieces):
                        xval[x] = mpc['gencost']['COST'][xp]
                        yval[x] = mpc['gencost']['COST'][xp+1]
                        xp += 2
                    NoPieces -= 1
                
                else:                                                 # Polinomial model
                    # Select number of pieces for the approximation
                    if xLen == 0:  # Default case
                        Delta = mpc['gen']['PMAX'][NoGen] # gen max output limit
                        if Delta == 0:
                            LGcost.append(0)
                        else:
                            Delta /= 3
                       
                        # elif xLen == 1:  # Single value for all generators
                        #     Delta = sett['Pieces'][0]
                        # else:  # Predefined number of pieces
                        #     Delta = sett['Pieces'][xNo]
                
                            NoPieces = int(np.floor(mpc['gen']['PMAX'][NoGen]/Delta))
                            # xval = np.zeros((NoPieces+1,mpc['NoGen']), dtype=float)
                            # yval = np.zeros((NoPieces+1,mpc['NoGen']), dtype=float)
                            
                            
                            # TODO: check if min pgen can be -ve
                            aux = max(mpc['gen']['PMIN'][NoGen], 0)
                            
                            for xp in range(NoPieces+1):
                                xval[xp][NoGen] = aux
                                xc = mpc['gencost']['NCOST'][NoGen]-1 # xc=2
                                yval[xp][NoGen] = mpc['gencost']['COST'][NoGen][xc]
                                for x in range(1, mpc['gencost']['NCOST'][NoGen]):
                                    xc -= 1
                                    yval[xp][NoGen] += mpc['gencost']['COST'][NoGen][xc]*xval[xp][NoGen]**x
                                aux += Delta
            
                            # Convert to LP constraints 
                            # lcost = np.zeros((NoPieces, mpc['NoGen']), dtype=float)
                            for xv in range(NoPieces):
                                lcost[xv][NoGen] = (yval[xv+1][NoGen]-yval[xv][NoGen]) / (xval[xv+1][NoGen] - xval[xv][NoGen])
          
                            
                            # lcost = [ k1*base  y0-k1*x0
                            #           k1*base  y0-k1*x0
                            #           k1*base  y0-k1*x0  ]
                            
                            LGcost.append(lcost[1][0])  # Why ???
            
    
            
            return  (lcost, xval,yval)
    
    # find all connections
    def nodeConnections_rule(mpc,NetworkModel):
        # Node recorded: gen + bus + branch
        # Node numbers : mpc['NoGen'] + mpc['NoBus'] + mpc['NoBranch']
        # gen from node: 0
        #     to   node: (mpc['NoGen'] - 1)
        # bus from node: (mpc['NoGen'] )
        #     to   node: (mpc['NoGen'] + mpc['NoBus'] - 1)
        # bra from node: (mpc['NoGen'] + mpc['NoBus'])
        #     to   node: (mpc['NoGen'] + mpc['NoBus'] + mpc['NoBranch'] -1)
         
        noDiff = mpc['NoGen'] + mpc['NoBus'] # change node number to branch number
        
        genCbus = {} # all the generators connected to each bus
        braFbus = {} # all the branches from each bus
        braTbus = {} # all the branches to each bus
        for NoBus in range(mpc['NoBus']):
            genCbus[NoBus] = []
            braFbus[NoBus] = []
            braTbus[NoBus] = []
      
    
        for connect in range(len(NetworkModel.branches_graph)):
            for node in NetworkModel.network.nodes(data=True): 
                if node[1]['obj'].type == "generator" :
                    if node[1]['obj'].node == NetworkModel.branches_graph[connect][0] \
                        or node[1]['obj'].node == NetworkModel.branches_graph[connect][1]:
                        
                        NoBus = node[1]['obj'].bus - 1
                        genCbus[NoBus].append (node[1]['obj'].node)
                
                elif node[1]['obj'].type == "branch" :
                    if node[1]['obj'].node == NetworkModel.branches_graph[connect][1]:
                        NoBus = node[1]['obj'].ends[0] - 1
                        braFbus[NoBus].append (node[1]['obj'].node)
                    
                    elif node[1]['obj'].node == NetworkModel.branches_graph[connect][0]:
                        NoBus = node[1]['obj'].ends[1] - 1
                        braTbus[NoBus].append (node[1]['obj'].node)
    
        Pd={}
        Qd={}
        for xn in range(mpc['NoBus']):
            Pd[xn] = []
            Qd[xn] = []
            
            
        if NoTime == 1:
    
            for xn in range(mpc['NoBus']):
                Pd[xn].append( mpc['bus']['PD'][xn])
                Qd[xn].append( mpc['bus']['QD'][xn])
        
        else :
          
            demP = np.zeros(NoTime, dtype=float) 
            demQ = np.zeros(NoTime, dtype=float) 
            for xn in range(mpc['NoBus']):
                                 
                for xt in range(NoTime): 
                    demP[xt] = mpc['demandP'][str(xt)][xn]
                    Pd[xn].append(demP[xt])
                    
                    demQ[xt] = mpc['demandP'][str(xt)][xn]
                    Qd[xn].append(demQ[xt])
    
               
                # if mpc['bus']['PD'][xn] != 0:          
                #     for xt in range(NoTime): 
                #         demP[xt] = mpc['demandP'][str(xt)][xn]
                #         Pd[xn].append(demP[xt])
                # else:
                #     for xt in range(NoTime): 
                #         demP[xt] = 0
                #         Pd[xn].append(demP[xt])
       
        return (noDiff, genCbus, braFbus, braTbus, Pd, Qd)
    
      
    
    # Objective function 
    def OFrule(m):
    
        # TODO: change P to S in obj
        # m.ci[0:upgrade line, 1:new line]
        return (        # investment cost
                        sum( m.ci[xintv,xbr]*ci_cost*P_ci[xintv]  for xbr in m.Set['Bra'] for xintv in m.Set["Intv"]) +
                        # generation cost
                       # sum( m.Cgen[xg,xt] for xg in m.Set['Gen'] for xt in m.Set['Tim'] ) +
                        # flexbility service cost
                        sum( m.Pflex[xb,xt]*Cflex  for xb in m.Set['Bus'] for xt in m.Set['Tim']) +
                        # load curtailment cost
                        sum( m.Plc[xb,xt]*penalty_cost for xb in m.Set['Bus'] for xt in m.Set['Tim'])
                     
               )
            
    
    
    
    #####################################################################
    #####################################################################
    #####################################################################
    #####################################################################
    
    ######################## inputs
    
    # Inputs
    Budget_cost = 1e20
    penalty_cost = 1e3
    #TODO: update the line capacity 
    # How to link this with the screening model?
    
    P_ci = [48, 58, 133] #[52, 131] #
    
    ci_cost = 100 # £/MW
    
    Cflex = 1
    
    # Number of time points
    NoTime = 1
     
    ''' Load json file''' 
    # load json file from file directory
    mpc = json.load(open(os.path.join(os.path.dirname(__file__), 
                                      'tests', 'json', 
                                      #'Transmission_Network_UK2.json')))    # Transmission_Network_UK.jason
                                      'case5.json')))
        
        
    """  change load in mpc """
    # for tempi in range(mpc['NoBus']): #[21,22]: #
    
    #     mpc["bus"]["PD"][tempi] =  mpc["bus"]["PD"][tempi]*1
    #    # for i in range(NoTime):
    #         # mpc["demandP"][str(i)][tempi] = mpc["demandP"][str(i)][tempi]*100
            
           
    
    '''Main '''
    # build network model use graph
    NetworkModel = NetworkModel()
    # Plot network
    # nx.draw(NetworkModel.network)
    
    
    # read mpc file and find info
    noDiff, genCbus,braFbus,braTbus,Pd, Qd = nodeConnections_rule(mpc,NetworkModel)
    lcost, xval,yval = genCost_rule(mpc)
    
    
    
    ''' Prepare a pyomo model '''
    # Defining concrete optimisation model
    model = ConcreteModel()
    
    # Adding sets
    model = addSet(model)
    
    # Adding parameters
    model = addPara(model)
    
    # Adding variables
    model = addVar(model)
    
    # Adding constraints
    model = addConstraints(model)
    
    
    # Adding objective function
    model.obj = Objective(rule=OFrule, sense=minimize)
    solver = SolverFactory('glpk')
    
    # #######################################################
    
    """ using dual to update constraints"""
    
    
    
    def duLine_rule(model,xb, xt):
        # dual_bra_all = [bus][branch]
        if plc_result[xb] > 0:
            print(plc_result[xb], "<=", sum( (dual_bra_all[xb][xbr] / penalty_cost) * (model.Pbra[xbr,xt] - Pbra_result[xbr]) for xbr in model.Set['Bra']  ))
            
            return plc_result[xb] <= \
                sum( (dual_bra_all[xb][xbr] / penalty_cost) * (model.Pbra[xbr,xt] - Pbra_result[xbr]) 
                      for xbr in model.Set['Bra']  )
            
        else:
            return model.Plc[xb,xt] == 0
        
    
    # trace branches that have impacts on the load curtailment
    def trace_pf(plc_result, dual_bra, OPF_Pbra):
        # separate dual for each load curtailment
        # start tracing for each endnode
        # deltas: #  0        # [[0.0, 0, 0.0, 0.0, 0.0],  
                  # -3.105    # [0.0, -1.0818505337229922, 0.0, -2.0235690235600146, 0.0], 
                  # -0.215    # [0.0, 0, 0.0, -0.2154882154300708, 0.0], 
                  # -0.384    # [0.0, -1.3843416369410022, 1.0000000000000142, 0, 0.0], 
                  # -1.05     # [0.0, -1.0569395017359895, -1.0000000000000142, 0.9999999999999432, 0.0], 
                  # 0         # [0.0, 0.0, 0.0, 0.0, 0.0]]
    
        # dual: [0, 3105.01012976742, 215.00202020202, 384.341637010676, 1056.93950177936, 0]
        
        
        noDiff_Bus = mpc['NoGen']
        xt = 0 # TODO: update xt
        dual_bra_all = []
        dual_bra_new = []
        
        # # find load curtail bus
        # for xb in range(len(plc_result)):
           
        #     dual_update = [0] * len(dual_bra)
        #     if plc_result[xb] > 0:
        #         # find branch connected to the bus and pf direction of the branches
               
        #         for xbr in range(len(braFbus[xb])):
        #             # check all branches from the bus
        #             temp_bra_no = braFbus[xb][xbr] - noDiff
        #             if OPF_Pbra[temp_bra_no, xt].value < 0:
        #                 dual_update[temp_bra_no] = 1
    
        #             # check all branches to the bus
        #             temp_bra_no = braTbus[xb][xbr] - noDiff
        #             if OPF_Pbra[temp_bra_no, xt].value > 0:
        #                 dual_update[temp_bra_no] = 1   
            
        #     dual_bra_all = [a*b for a,b in zip(dual_update, dual_bra)]
        #     dual_bra_new.append(dual_bra_all)
            
    
        # #dual_bra_all result:   [[0, 0.0, 0.0, 0.0, 0.0, 0], 
        # #                        [0, 0.0, 0.0, 384.341637010676, 0.0, 0], 
        # #                        [0, 0.0, 0.0, 0.0, 1056.93950177936, 0], 
        # #                        [0, 3105.01012976742, 0.0, 0.0, 0.0, 0], 
        # #                        [0, 0.0, 0.0, 0.0, 0.0, 0]]
        
        def find_next_Fbus(bus_no,bra_no):        
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
            if no_braFbus == 0: 
                # if only one branch connected to this bus
                temp_bra_no = braFbus[bus_no][no_braFbus] - noDiff # find branch name(number)
            
                if OPF_Pbra[temp_bra_no, xt].value < 0: # branch from the bus, if value is -ve, means it flows to the bus
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
                                
                      if OPF_Pbra[temp_bra_no, xt].value < 0:
                          dual_update[xb][temp_bra_no] = 1
                          return dual_update
                      else: 
                        next_bus_no = find_next_Fbus(xb, temp_bra_no)
                        if next_bus_no == xb:
                            return dual_update
                        else:
                            next_no_braFbus = len(braFbus[next_bus_no]) -1
                            return recursive_tracing_Fbus(next_bus_no, next_no_braFbus, dual_update)
                            
                       
                    
    
        
        def recursive_tracing_Tbus(bus_no, no_braTbus, dual_update):
                   
            if no_braTbus == 0: 
                # if only one branch connected to this bus
                temp_bra_no = braTbus[bus_no][no_braTbus] - noDiff # find branch name(number)
            
                if OPF_Pbra[temp_bra_no, xt].value > 0: # branch to the bus, if value is +ve, means it flows to the bus
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
                                
                      if OPF_Pbra[temp_bra_no, xt].value > 0:
                          dual_update[xb][temp_bra_no] = 1
                          #return dual_update
                      else: 
                        next_bus_no = find_next_Tbus(xb, temp_bra_no)
                        if next_bus_no == xb:
                            return dual_update
                        else:
                            next_no_braTbus = len(braTbus[next_bus_no]) -1
                            return recursive_tracing_Tbus(next_bus_no, next_no_braTbus, dual_update)
                         
                         
                         
    
    
        
        
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
                    
        dual_update = dual_update.tolist()            
        dual_bra_new =[]
        for i in range(len(dual_update)):
            dual_bra_new.append( [a*b for a,b in zip(dual_update[i], dual_bra)])
        
        # # [[0.0, 0.0, 0.0, 0.0, 0.0, 0.0], 
        # #  [0.0, 0.0, 0.0, 384.341637010676, 0.0, 0.0], 
        # #  [0.0, 0.0, 0.0, 0.0, 1056.93950177936, 0.0], 
        # #  [0.0, 3105.01012976742, 0.0, 0.0, 0.0, 0.0] 
        # #  [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]]
           
        
        return dual_bra_new
    
    
    # updata not binding consraints
    def updateBinding_rule(model, xt):
        print(sum(model.ci[xintv,xbr]*P_ci[xintv] for xintv in model.Set["Intv"])+ bra_cap[xbr], ">=",  abs(  OPF_Pbra[xbr, xt].value ) )
        return sum(model.ci[xintv,xbr]*P_ci[xintv] for xintv in model.Set["Intv"]) + bra_cap[xbr]>= \
              abs(  OPF_Pbra[xbr, xt].value ) 
    
    
    
    
    # def updateBinding2_rule(model, xbr, xt):
        
    #     return sum(model.ci[xintv,xbr]*P_ci[xintv] for xintv in model.Set["Intv"]) - \
    #             sum(invest_deci[xintv][xbr]*P_ci[xintv] for xintv in model.Set["Intv"]) >=\
    #                 ( model.Pbra[xbr,xt]  - Pbra_result[xbr] ) 
                  
    
      #(dual_bra[xbr]/penalty_cost  ) #+ sum(plc_result)*penalty_cost 
                    #model.Pbra[xbr,xt]  - Pbra_result[xbr] + OPF_Pbra[xbr,xt].value
    
    # record original branch capacity        
    bra_cap = []
    for xbr in range(mpc['NoBranch']):
        bra_cap.append( mpc["branch"]["RATE_A"][xbr] )
    
    
    gen_cost = []
    for xgc in range(mpc["NoGen"]):
        gen_cost.append(mpc["gencost"]["COST"][xgc][0] )
    
    
    plc_result = []
    ite_z = 0
    count_opf = 0
    
    # plots
    
    p_ci = [] # investment cost
    p_lc = [] # load curtailment
    p_d1 = [] # dual_Bra1: without gen cost
    p_d2 = [] # dual_Bra2: with gen cost
    p_d = [] # dual_Bra updated
    
    
    
    ################################## stage 1 #################################
    print("\n--> Stage 1")
    
    # remove gen cost in mpc
    for xgc in range(mpc["NoGen"]):
        mpc["gencost"]["COST"][xgc][0] = 0.1*(xgc + 1)
    
    
    while sum(plc_result) > 0 or ite_z == 0 :
        
        print("\n---- iteration: ", ite_z)
        
        
         
        if ite_z == 0:                                  # initial run
            # solve pyomo model
            results = solver.solve(model)
            
            #print(results)
            # Remove node balance rule
            model.del_component(model.nodeBalance)
           
            
            print('min obj cost:',Val(model.obj))
            print("generation cost:", Val(sum( model.Cgen[xg,xt] for xg in model.Set['Gen'] for xt in model.Set['Tim'] )))
            print("investment cost:",Val( sum( model.ci[i,xbr]*P_ci[i]*ci_cost for xbr in model.Set['Bra'] for i in model.Set["Intv"]) ))
    
        else:                                           # iterations
            # Add dual rules delta branch power
            model.add_component("duLine_ite"+str(ite_z), Constraint(model.Set['Bus'],model.Set['Tim'],rule=duLine_rule ))
            
            
            # Recover mpc using results from model.ci
            for xbr in range(mpc['NoBranch']):
                mpc["branch"]["RATE_A"][xbr] =  bra_cap[xbr]
           
            # redo optimisation
            results = solver.solve(model)
            #print(results)
            print('min obj cost:',Val(model.obj))
            print("generation cost:", Val(sum( model.Cgen[xg,xt] for xg in model.Set['Gen'] for xt in model.Set['Tim'] )))
            print("investment cost:",Val( sum( model.ci[i,xbr]*P_ci[i]*ci_cost for xbr in model.Set['Bra'] for i in model.Set["Intv"]) ))
            
                
       
       
        
        # get branch power flow
        Pbra_result = []
        for xbr in range(mpc['NoBranch']):
            for xt in range(NoTime):
                #print(Val(model.Pbra[xbr,xt]))
                Pbra_result.append(Val(model.Pbra[xbr,xt]))
        #print("Total branch capacity (with investment):", sum(mpc["branch"]["RATE_A"]))
        
        # get investment decisions
        invest_deci = []
        for xi in range(len(P_ci)):    
            temp = []
            for xbr in range(mpc['NoBranch']):
                #print(Val(model.Pbra[xbr,xt]))
                temp.append(Val(model.ci[xi,xbr]))
            invest_deci.append(temp)
        
    
        
        
        # update mpc using results from model.ci
        for xbr in range(mpc['NoBranch']):
            mpc["branch"]["RATE_A"][xbr] = bra_cap[xbr]+ sum(P_ci[i]* Val(model.ci[i, xbr]) for i in model.Set["Intv"])
            if sum(P_ci[i]* Val(model.ci[i, xbr]) for i in model.Set["Intv"]) > 0: 
                print("   Increase ", sum(P_ci[i]* Val(model.ci[i, xbr]) for i in model.Set["Intv"]), " on Branch ", xbr,\
                      ", new Capacity: ", mpc["branch"]["RATE_A"][xbr] )
     
     
        # run DC OPF, Get plc and duals
        CO, plc_result, dual_bra, OPF_Pbra = DCOPF_function(mpc,NoTime)
        print("dual variables without gen cost",dual_bra)
        p_d1.append(dual_bra)
    
        # if ite_z == 0:
        #     model.add_component("updateBinding", Constraint(model.Set['Bra'], model.Set['Tim'],rule=updateBinding_rule ))
        OPF_Pbra.pprint()
        
        # print("pf from investment model: ")
        # model.Pbra.pprint()
        
        
        
        
               
        # get dual for each [bus, branch]
        dual_bra_all = trace_pf(plc_result, dual_bra, OPF_Pbra)
        print("new duals:", dual_bra_all)
        p_d2.append(dual_bra_all)
        
    
        print("model.Pbra:")
        model.Pbra.pprint()
       
        
        count_opf += 1
        print("run DCOPF_function",count_opf) 
        
        
        if ite_z >= 1: 
            xt = 0
            for xbr in range(mpc["NoBranch"]):
                if sum(Val(model.ci[i, xbr]) for i in model.Set["Intv"]) >= 1 and abs(Val(OPF_Pbra[xbr,xt])) < mpc["branch"]["RATE_A"][xbr]:
                    print("branch is invested but not binding:  ", xbr)
                    # for xb in range(mpc["NoBus"]):
                    #     dual_bra_all[xb][xbr] = 0 
                    
                    #model.del_component("duLine_ite"+str(ite_z))
                    
                    # model.add_component("updateBinding"+str(ite_z), Constraint(model.Set['Bra'], model.Set['Tim'],rule=updateBinding_rule ))
                    model.add_component("updateBinding"+str(ite_z)+str(xbr), Constraint(model.Set['Tim'],rule=updateBinding_rule ))
                    
    
    
        
        
        
        
        
        ite_z += 1
    
    
    
    
       
    # ################################## stage 2 #################################
    
    
    # print("\n--> Stage 2")
    # # New Objective function 
    # def OFrule2(m):
    
    #     return (        # investment cost
    #                     sum( m.ci[xintv,xbr]*ci_cost*P_ci[xintv]  for xbr in m.Set['Bra'] for xintv in m.Set["Intv"]) +
    #                     # flexbility service cost
    #                     sum( m.Pflex[xb,xt]*Cflex  for xb in m.Set['Bus'] for xt in m.Set['Tim']) +
    #                     # load curtailment cost
    #                     sum( m.Plc[xb,xt]*penalty_cost for xb in m.Set['Bus'] for xt in m.Set['Tim']) +
    #                     # CO change
    #                     ( CO - 
    #                       sum(dual_bra[xbr] * (m.ci[xintv,xbr]*P_ci[xintv] - Pbra_result[xbr] )  for xbr in m.Set['Bra'] for xintv in m.Set["Intv"])
    #                     )
                     
    #             )
            
    
    
    
    
    
    
    # # recover gen cost in mpc
    # for xgc in range(mpc["NoGen"]):
    #       mpc["gencost"]["COST"][xgc][0] = gen_cost[xgc]
    # # run DC OPF, Get plc and duals
    # CO, plc_result, dual_bra, OPF_Pbra = DCOPF_function(mpc,NoTime)
    
    # print(CO)
    # print(plc_result)
    # OPF_Pbra.pprint()
    
    # ite_z = 0
    # CO_change = CO
    
    # while  CO_change > 0 or ite_z == 0 :
     
    #     print("\n---- iteration: ", ite_z)
        
        
              
         
    #     if ite_z == 0:                                  # initial run 
    #         # Change OF
    #         model.obj = Objective(rule=OFrule, sense=minimize)
    #         # solve pyomo model
    #         results = solver.solve(model)
            
    #         print('min obj cost:',Val(model.obj))
    #         print("generation cost:", Val(sum( model.Cgen[xg,xt] for xg in model.Set['Gen'] for xt in model.Set['Tim'] )))
    #         print("investment cost:",Val( sum( model.ci[i,xbr]*P_ci[i]*ci_cost for xbr in model.Set['Bra'] for i in model.Set["Intv"]) ))
    
    #     else:                                           # iterations
                   
    #         # Recover mpc using results from model.ci
    #         for xbr in range(mpc['NoBranch']):
    #             mpc["branch"]["RATE_A"][xbr] =  bra_cap[xbr]
           
    #         # redo optimisation
    #         results = solver.solve(model)
    #         print('min obj cost:',Val(model.obj))
    #         print("generation cost:", Val(sum( model.Cgen[xg,xt] for xg in model.Set['Gen'] for xt in model.Set['Tim'] )))
    #         print("investment cost:",Val( sum( model.ci[i,xbr]*P_ci[i]*ci_cost for xbr in model.Set['Bra'] for i in model.Set["Intv"]) ))
    
    #     # get branch power flow
    #     Pbra_result = []
    #     for xbr in range(mpc['NoBranch']):
    #         for xt in range(NoTime):
    #             #print(Val(model.Pbra[xbr,xt]))
    #             Pbra_result.append(Val(model.Pbra[xbr,xt]))
    #     #print("Total branch capacity (with investment):", sum(mpc["branch"]["RATE_A"]))
         
        
    #     # update mpc using results from model.ci
    #     for xbr in range(mpc['NoBranch']):
    #         mpc["branch"]["RATE_A"][xbr] =  bra_cap[xbr]+ sum(P_ci[i]* Val(model.ci[i, xbr]) for i in model.Set["Intv"])
    #         if sum(P_ci[i]* Val(model.ci[i, xbr]) for i in model.Set["Intv"]) > 0: 
    #             print("   Increase ", sum(P_ci[i]* Val(model.ci[i, xbr]) for i in model.Set["Intv"]), " on Branch ", xbr,\
    #                   ", new Capacity: ", mpc["branch"]["RATE_A"][xbr] )
     
     
    #     # run DC OPF, Get plc and duals
    #     CO, plc_result, dual_bra, OPF_Pbra = DCOPF_function(mpc,NoTime)
    #     print("dual variables with gen cost",dual_bra)
    #     p_d1.append(dual_bra)
        
    #     # OPF_Pbra.pprint()
    #     count_opf += 1
    #     print("run DCOPF_function",count_opf) 
        
    #     # calculate change of CO
    #     CO_change = CO - CO_change
        
        
    #     ite_z += 1            
    
    
    
    
    
    
                
    
    
    print("\n*********************************************")
    print('Final min obj cost:',Val(model.obj) + CO )        
    print("Final generation cost:", CO )
    print("Final investment cost:",Val( sum( model.ci[i,xbr]*P_ci[i]*ci_cost for xbr in model.Set['Bra'] for i in model.Set["Intv"]) ))
    
    for xbr in range(mpc['NoBranch']):
            if Val( sum( model.ci[i,xbr]*P_ci[i] for i in model.Set["Intv"])) > 0: 
                print("   Increase ", Val( sum( model.ci[i,xbr]*P_ci[i] for i in model.Set["Intv"])) , " on Branch ", xbr)
    
    print("*********************************************")     
            








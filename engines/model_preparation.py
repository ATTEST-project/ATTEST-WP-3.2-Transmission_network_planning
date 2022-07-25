# -*- coding: utf-8 -*-
"""
@author: Wangwei Kong

Prepare pyomo model
"""


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
from process_data import initial_value
# import copy
# from input_output_function import read_input_data, output_data ,get_time_series_data
# from ACOPF import ACOPF_function
# from scenarios_multipliers import get_mult
# from SCACOPF import run_SCACOPF_jl
# from SCACOPF import output2json

# from investment_model_pt2 import InvPt2_function
# from investment_model_pt1 import InvPt1_function


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
def prepare_invest_model(mpc, NoPath, prob,NoYear, NoSce,NoSea, NoDay,DF,CRF,SF,S_ci,ci_cost,Budget_cost,penalty_cost, peak_Pd,peak_Qd, multiplier,CPflex,CQflex,Pflex_up, Pflex_dn,Qflex_up, Qflex_dn,gen_status,line_status):
    NoTime = 1
    
    # Assume a power factor for initial run, values are updated based on OPF results

    cos_pf_init = 0.98
    sin_pf_init = (1-cos_pf_init**2)**0.5

    cos_pf = initial_value(mpc,NoYear,NoSce, cos_pf_init)
    sin_pf = initial_value(mpc,NoYear,NoSce, sin_pf_init)
    
    ''''read paras and vars from jason file'''
    def readVarPara():
    
        '''Input parameters for generator, bus and branch'''
        
        '''
            Recorded parameters are:
                     auxGen = ['PMAX', 'PMIN', 'QMAX', 'QMIN', 'VG']
                     auxBus = ['BASE_KV', 'PD', 'QD', 'VMAX', 'VMIN']
                     auxBranch = ['BR_B', 'BR_R', 'BR_X', 'RATE_A', 'BR_STATUS']
    
           
        '''
        
        # Input generator parameters   
        nw_parameters=[]
        auxGen = ['PMAX', 'PMIN', 'QMAX', 'QMIN', 'VG','GEN_BUS']
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
        auxBranch = ['BR_B', 'BR_R', 'BR_X', 'RATE_A','RATE_B','RATE_C', 'BR_STATUS']
        # rateA (summer)	rateB (spring)	rateC (winter)
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
        
        
        
        return nw_parameters
    
    
    # ####################################################################
    # ####################################################################
        
        
    '''Network model to record var and para in graph and get values from node'''
    class NetworkModel():
        def __init__(self):
            self.readVarPara = readVarPara()
            self.network_parameters = self.readVarPara # nw_parameters
           
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
        m.Set['Day'] = range(NoDay)
        m.Set['Sea'] = range(NoSea)
        
        #m.Set['Intv'] = range(len(S_ci))
        
        m.Set['Intev'] = {}
        for xbr in m.Set["Bra"]:
            m.Set["Intev"][xbr] = range(len(S_ci[str(xbr)]))
        m.Set["braIntev"] = Set(initialize=list((i,j) for i in m.Set["Intev"].keys() for j in m.Set["Intev"][i]))
       
        #m.ciset = range(2) # all intervension set
        
        m.Set['Year'] = range(NoYear) 
        m.Set['Path'] = range(NoPath)#range(2**(NoYear-1) )
        
        # for y in m.Set['Year']:
        #     m.Set['Sce_'+str(y)] = range(2**y) # NoSce each next year has two possible scenarios
        m.Set['Sce'] = {}
        for y in m.Set['Year']:
            m.Set['Sce'][y] = range(NoSce**y)
        # Output for m.Set['Sce'] : {0: range(0, 1), 1: range(0, 2), 2: range(0, 4), 3: range(0, 8)}     
       
        m.Set['YSce']  = Set(initialize=list((i,j) for i in m.Set['Sce'].keys() for j in m.Set['Sce'][i]))
        
        # exmple:
        # h = {1:['a','b'], 2:['b','c'], 3:['c','d']}
        # m.hg = Set(initialize=list((i,j) for i in h.keys() for j in h[i]))
        
    
                   
    
    
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
       
    
    
        # Create a var for each year each scenarios    
        # Gen
        m.Pgen = Var(m.Set['Gen'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], domain=NonNegativeReals, initialize=10)
        m.Qgen = Var(m.Set['Gen'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], domain=NonNegativeReals, initialize=10)
        m.Cgen = Var(m.Set['Gen'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], domain=NonNegativeReals, initialize=10)
        
        # Flexibility service
        # TODO: check if flex_decrease is needed in investment planning
        m.Pflex = Var(m.Set['Bus'], m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],m.Set['Tim'], domain=NonNegativeReals, initialize=0)
        m.Qflex = Var(m.Set['Bus'], m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],m.Set['Tim'], domain=NonNegativeReals, initialize=0)
        # m.Sflex = Var(m.Set['Bus'], m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],m.Set['Tim'], domain=Reals, initialize=0)
        m.CflexP = Var(m.Set['Bus'], m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],m.Set['Tim'], domain=NonNegativeReals, initialize=0)
        m.CflexQ = Var(m.Set['Bus'], m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],m.Set['Tim'], domain=NonNegativeReals, initialize=0)
        
        # Branch
        m.Pbra = Var(m.Set['Bra'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],m.Set['Tim'], domain=Reals, initialize=0)
        m.Qbra = Var(m.Set['Bra'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],m.Set['Tim'], domain=Reals, initialize=0)
        m.Sbra = Var(m.Set['Bra'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],m.Set['Tim'], domain=Reals, initialize=0)
        
        # Investment decisions 
        #m.ci = Var(m.Set["Intv"], m.Set['Bra'],m.Set['YSce'] , initialize=0, domain=Binary, bounds=(0,1))
        m.ci = Var(m.Set["braIntev"],m.Set['YSce'] , initialize=0, domain=Binary, bounds=(0,1))
        
        m.ciCost = Var(m.Set['YSce'] , domain=NonNegativeReals, initialize=0)
        
        # cost for pathways
        m.Cpath = Var(m.Set["Path"],initialize=0, domain=NonNegativeReals)
        
        # Load curtailment
        m.Plc = Var(m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],m.Set['Tim'], domain=NonNegativeReals, initialize=0)
        m.Qlc = Var(m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],m.Set['Tim'], domain=NonNegativeReals, initialize=0)
        
        # Bus angle
        m.Ang = Var(m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], bounds=(-2*math.pi, 2*math.pi), initialize=0) # from 0
       
       
        return m
         
    
    class rules:
        #TODO: update input data for each node
    
        # Gen output constraint rules
        def genMax_rule(m, xg, xy,xsc, xse, xd, xt):
            if gen_status == True and mpc["gen"]["GEN"][xg] == 0 :
                return m.Pgen[xg,  xy,xsc, xse, xd, xt] == 0 
            else:
                gen_bus = m.para["Gen"+str(xg)+"_GEN_BUS"]
                bus_number = [i for i,x in enumerate(mpc["bus"]["BUS_I"]) if x==gen_bus]
                return m.Pgen[xg, xy,xsc, xse, xd, xt] <= m.para["Gen"+str(xg)+"_PMAX"] * multiplier[xy][xsc][bus_number[0]] 
       
            
        
        def genMin_rule(m, xg, xy,xsc, xse, xd, xt):
            if gen_status == True and mpc["gen"]["GEN"][xg] == 0 :
                return m.Pgen[xg,  xy,xsc, xse, xd, xt] == 0 
            else:
                return m.Pgen[xg, xy,xsc, xse, xd, xt] >= m.para["Gen"+str(xg)+"_PMIN"]
            
        
        def genQMax_rule(m, xg, xy,xsc, xse, xd, xt):
            if gen_status == True and mpc["gen"]["GEN"][xg] == 0 :
                return m.Qgen[xg, xy,xsc, xse, xd, xt] == 0 
            else:
                gen_bus = m.para["Gen"+str(xg)+"_GEN_BUS"] -1
                return m.Qgen[xg, xy,xsc, xse, xd, xt] <=  m.para["Gen"+str(xg)+"_QMAX"] * multiplier[xy][xsc][gen_bus] 
            
        
        def genQMin_rule(m, xg, xy,xsc, xse, xd, xt):
            if gen_status == True and mpc["gen"]["GEN"][xg] == 0 :
                return m.Qgen[xg, xy,xsc, xse, xd, xt] == 0 
            else:
                return m.Qgen[xg, xy,xsc, xse, xd, xt] >= m.para["Gen"+str(xg)+"_QMIN"]
            
    
             
        # Flexibility service output constraint rules
        def flexPup_rule(m, xb, xy,xsc, xse,xd, xt):
            if Pflex_up == None:
                return m.Pflex[xb, xy,xsc, xse, xd,  xt] == 0
            else: 
                return  m.Pflex[xb, xy,xsc, xse, xd, xt] <= Pflex_up[xb] * multiplier[xy][xsc][xb]
        
        def flexPdn_rule(m, xb, xy,xsc, xse,xd, xt):
            if Pflex_dn == None:
                return m.Pflex[xb,xy,xsc, xse, xd, xt] == 0
            else: 
                return  m.Pflex[xb,xy,xsc, xse, xd, xt] >= - Pflex_dn[xb]* multiplier[xy][xsc][xb]
        
        def flexQup_rule(m, xb, xy,xsc, xse, xd, xt):
            # Qflex_max = None
            if Qflex_up == None:
                return m.Qflex[xb, xy,xsc, xse, xd,  xt] == 0
            else: 
                return  m.Qflex[xb, xy,xsc, xse, xd,  xt] <= Qflex_up[xb] * multiplier[xy][xsc][xb]
        
        def flexQdn_rule(m, xb, xy,xsc, xse, xd, xt):
            # Qflex_max = None
            if Qflex_dn == None:
                return m.Qflex[xb,xy,xsc, xse, xd, xt] == 0
            else: 
                return m.Qflex[xb,xy,xsc, xse, xd, xt] >= -Qflex_dn[xb]* multiplier[xy][xsc][xb]
            
        # def flexS_rule(m, xb, xt):
        #     cos_pf  = 0.98 #TODO: update power factor
        #     return  m.Sflex[xb, xt] == m.Pflex[xb, xt] / cos_pf   
        
        def flexCost_rule(m,xb,xy,xsc, xse, xd,xt):
            return m.CflexP[xb,xy,xsc, xse, xd,xt] >= m.Pflex[xb,xy,xsc, xse, xd,xt] * CPflex
        
        def flexCostN_rule(m,xb,xy,xsc, xse, xd,xt):
            return m.CflexP[xb,xy,xsc, xse, xd,xt] >= - m.Pflex[xb,xy,xsc, xse, xd,xt] * CPflex
       
        def flexCostQ_rule(m,xb,xy,xsc, xse, xd,xt):
            return m.CflexQ[xb,xy,xsc, xse, xd,xt] >= m.Qflex[xb,xy,xsc, xse, xd,xt] * CQflex
        
        def flexCostQN_rule(m,xb,xy,xsc, xse, xd,xt):    
            return m.CflexQ[xb,xy,xsc, xse, xd,xt] >= - m.Qflex[xb,xy,xsc, xse, xd,xt] * CQflex
    
        # Branch constraint
        def braSCap_rule(m, xbr, xy,xsc, xse, xd, xt):
            if line_status == True and mpc["branch"]["BR_STATUS"][xbr] == 0:
                return Constraint.Skip
            else:
                if m.para["Branch"+str(xbr)+"_RATE_A"] != 0:
                    # return m.Sbra[xbr,xy,xsc, xse,  xd, xt] <= \
                    #     m.para["Branch"+str(xbr)+"_RATE_A"] + sum(S_ci[i]* m.ci[i,xbr, xy,xsc] for i in m.Set["Intv"]) 
                    return m.Sbra[xbr,xy,xsc, xse,  xd, xt] <= \
                        m.para["Branch"+str(xbr)+"_RATE_A"] + sum(S_ci[str(xbr)][i]* m.ci[xbr,i, xy,xsc] for i in m.Set["Intev"][xbr])  
                
                
                else:
                    return  m.Sbra[xbr, xy,xsc, xse, xd, xt]  <= float('inf') 
            

            
            # Scap_rate = []
            # # find Scap_rate for the season, # Season sequence: 0:RATE_A(summer)	 1:RATE_B(spring)	2:RATE_C(winter)
            # # If no season indicated for line cap, then only take RATE_A value
            # if xse == 1  and  m.para["Branch"+str(xbr)+"_RATE_B"] !=0 :
            #     Scap_rate  = m.para["Branch"+str(xbr)+"_RATE_B"]
            # elif xse == 2  and m.para["Branch"+str(xbr)+"_RATE_C"] != 0:
            #     Scap_rate  = m.para["Branch"+str(xbr)+"_RATE_C"]
            # else:
            #     Scap_rate  = m.para["Branch"+str(xbr)+"_RATE_A"]
            # Scap_rate  = m.para["Branch"+str(xbr)+"_RATE_A"]
            # if Scap_rate != 0:
            #     return m.Sbra[xbr,xy,xsc, xse,  xd, xt] <= Scap_rate * mpc["branch"]["BR_STATUS"][xbr] + sum(S_ci[i]* m.ci[i,xbr, xy,xsc] for i in m.Set["Intv"])
            # else:
            #     return m.Sbra[xbr, xy,xsc, xse, xd, xt]  <= float('inf') * mpc["branch"]["BR_STATUS"][xbr]
              
    
    
        # both flow directions
        def braSCapN_rule(m,xbr,xy,xsc, xse, xd, xt):
            if line_status == True and mpc["branch"]["BR_STATUS"][xbr] == 0:
                return Constraint.Skip
            else:
                if m.para["Branch"+str(xbr)+"_RATE_A"] != 0:
                    # return - m.Sbra[xbr, xy,xsc, xse,  xd, xt] <= \
                    #    m.para["Branch"+str(xbr)+"_RATE_A"] + sum(S_ci[i]* m.ci[i,xbr,xy,xsc] for i in m.Set["Intv"])  
                    return - m.Sbra[xbr, xy,xsc, xse,  xd, xt] <= \
                       m.para["Branch"+str(xbr)+"_RATE_A"] + sum(S_ci[str(xbr)][i]* m.ci[xbr,i, xy,xsc] for i in m.Set["Intev"][xbr])
                
                else:
                    return  - m.Sbra[xbr,xy,xsc, xse, xd,  xt]  <= float('inf') 
              
              # Scap_rate = []
              # if xse == 1  and  m.para["Branch"+str(xbr)+"_RATE_B"] !=0 :
              #     Scap_rate  = m.para["Branch"+str(xbr)+"_RATE_B"]
              # elif xse == 2  and m.para["Branch"+str(xbr)+"_RATE_C"] != 0:
              #     Scap_rate  = m.para["Branch"+str(xbr)+"_RATE_C"]
              # else:
              #     Scap_rate = m.para["Branch"+str(xbr)+"_RATE_A"]
              
              # if Scap_rate != 0:
              #     return  - m.Sbra[xbr,xy,xsc, xse,  xd, xt] <= Scap_rate * mpc["branch"]["BR_STATUS"][xbr]  + sum(S_ci[i]* m.ci[i,xbr, xy,xsc] for i in m.Set["Intv"])
              # else:
              #     return  - m.Sbra[xbr, xy,xsc, xse, xd, xt]  <= float('inf')* mpc["branch"]["BR_STATUS"][xbr]
              
              
        # TODO: Check cos_pf [xy][xsc][xbr] setting orders with OPF results
        def braP_rule(m, xbr,xy,xsc, xse,  xd, xt):
            if line_status == True and mpc["branch"]["BR_STATUS"][xbr] == 0:
                return Constraint.Skip
            else:
                if m.Pbra[xbr,xy,xsc, xse,  xd, xt].value >= 0:
                    return  m.Sbra[xbr, xy,xsc, xse, xd, xt] == m.Pbra[xbr, xy,xsc, xse, xd, xt] / cos_pf[xy][xsc][xbr] 
                else:
                    return  m.Sbra[xbr,xy,xsc, xse,  xd, xt] == - m.Pbra[xbr,xy,xsc, xse, xd,  xt] / cos_pf[xy][xsc][xbr]  
            
        def braQ_rule(m, xbr,xy,xsc, xse,  xd, xt):
            if line_status == True and mpc["branch"]["BR_STATUS"][xbr] == 0:
                return Constraint.Skip
            else:
                if m.Qbra[xbr,xy,xsc, xse,  xd, xt].value >= 0:
                    return  m.Sbra[xbr, xy,xsc, xse, xd, xt] == m.Qbra[xbr, xy,xsc, xse, xd, xt] / sin_pf[xy][xsc][xbr]  
                else:
                    return  m.Sbra[xbr, xy,xsc, xse, xd, xt] == -m.Qbra[xbr, xy,xsc, xse, xd, xt] / sin_pf[xy][xsc][xbr] 
    
        
        def interv_rule(m,xbr,xy,xsc):
            if line_status == True and mpc["branch"]["BR_STATUS"][xbr] == 0:
                return Constraint.Skip
            else:
                if m.Set["Intev"][xbr] == range(0, 0):
                    return Constraint.Skip
                else:    
                    # only one option from the list of intervesion can be adopted
                    return sum(m.ci[xbr,xintv,xy,xsc]  for xintv in m.Set["Intev"][xbr]) <= 1
                

                    
           
            
        
        def investCost_rule(m,xy,xsc):
           
            if xy== 0:    
                return m.ciCost[xy,xsc] == sum( ci_cost[xbr][xintv]*  m.ci[xbr,xintv,xy,xsc ]  for xbr, xintv in m.Set["braIntev"])
            
            else:
                return m.ciCost[xy,xsc] == sum( (m.ci[xbr,xintv,xy,xsc ] - m.ci[xbr,xintv,xy-1,math.floor(xsc/2) ])* ci_cost[xbr][xintv]  for xbr, xintv in m.Set["braIntev"])
                                               
           
         
        def pathwayCost_rule(m,xp):
            # path_sce =  path0 [ y0_sce, y1_sce, y2_sce, y3_sce ]
            #               ...
            #             path7 [ y0_sce, y1_sce, y2_sce, y3_sce ]
          
            return m.Cpath[xp] == \
                sum( DF[xy] * m.ciCost[xy,path_sce[xp][xy]] for xy in m.Set['Year']) \
                    +  sum( DF[xy] *  sum( m.CflexP[xb,xy,path_sce[xp][xy],xse,xd,xt] \
                            for xb in m.Set['Bus'] for xsc in path_sce[xp] for xse in m.Set['Sea'] for xd in m.Set['Day'] \
                                for xt in m.Set['Tim'] ) for xy in m.Set['Year'] ) \
                        +  sum( DF[xy] * sum( m.CflexQ[xb,xy,path_sce[xp][xy],xse,xd,xt] \
                            for xb in m.Set['Bus'] for xsc in path_sce[xp] for xse in m.Set['Sea'] for xd in m.Set['Day'] \
                                for xt in m.Set['Tim'])  for xy in m.Set['Year'] ) 
                    
    
        
        # each node has two nodes connections
        # investment of each node should include invests from previous nodes
        def nonAntipa_rule(m,xbr,xintv, xn):       
    
            return m.ci[xbr,xintv,tree_ysce[xn][0],tree_ysce[xn][1]] <= m.ci[xbr,xintv,tree_ysce[xn][2],tree_ysce[xn][3]] 
            
    
                        
        # Either using nodal balance or scdcopf
        # Nodal power balance
        def nodeBalance_rule(m, xb,xy,xsc, xse, xd, xt):
            # TODO: upadte PD to inclue xy,xsc, xse, xd        
            return sum( m.Pgen[genCbus[xb][i],xy,xsc, xse, xd, xt]  for i in range(len(genCbus[xb])) ) + m.Pflex[xb,xy,xsc, xse, xd,xt]   \
                    + sum( m.Pbra[braTbus[xb][i]- noDiff,xy,xsc, xse, xd,xt]  for i in range(len(braTbus[xb])) )  \
                    == sum( m.Pbra[braFbus[xb][i]- noDiff,xy,xsc, xse, xd,xt]  for i in range(len(braFbus[xb])) ) \
                      + Pd[xb]* multiplier[xy][xsc][xb] - m.Plc[xb,xy,xsc, xse, xd,xt]
    
    
        # Nodal power balance Q
        def nodeBalanceQ_rule(m, xb,xy,xsc, xse, xd, xt):
                   
            return sum( m.Qgen[genCbus[xb][i],xy,xsc, xse, xd,xt]  for i in range(len(genCbus[xb])) ) + m.Qflex[xb,xy,xsc, xse, xd,xt]   \
                    + sum( m.Qbra[braTbus[xb][i]-noDiff,xy,xsc, xse, xd,xt]  for i in range(len(braTbus[xb])) )  \
                    == sum( m.Qbra[braFbus[xb][i]-noDiff,xy,xsc, xse, xd,xt]  for i in range(len(braFbus[xb])) ) \
                      + Qd[xb]* multiplier[xy][xsc][xb] - m.Qlc[xb,xy,xsc, xse, xd,xt]
                      
        def DCPF_rule(m, xbr,xy,xsc, xse, xd,xt):
            
            br_X = mpc['branch']['BR_X'][xbr]/ mpc['baseMVA']
            fbus_name = mpc['branch']['F_BUS'][xbr]
            fbus = mpc['bus']['BUS_I'].index(fbus_name)
            tbus_name = mpc['branch']['T_BUS'][xbr]
            tbus = mpc['bus']['BUS_I'].index(tbus_name)
            
            if line_status == True and mpc["branch"]["BR_STATUS"][xbr] == 0:
                temp_line_stat = 0
            else:
                temp_line_stat = 1
            
            if  temp_line_stat == 0:
                return Constraint.Skip
            else:             
                return  m.Pbra[xbr,xy,xsc, xse, xd, xt] == ( m.Ang[fbus,xy,xsc, xse, xd, xt] - m.Ang[tbus,xy,xsc, xse, xd,xt]) / br_X              
        
        def slackBus_rule(m,xy,xsc, xse, xd, xt):
            for i in range(mpc['NoBus']):
                if mpc['bus']['BUS_TYPE'][i] == 3:
                    slc_bus = i
            
            return m.Ang[slc_bus,xy,xsc, xse, xd,xt] == 0              
          
        def loadcurtail_rule(m, xb,xy,xsc, xse, xd, xt):
            
            return  multiplier[xy][xsc][xb] *abs(Pd[xb]) >= m.Plc[xb,xy,xsc, xse, xd,xt]
        
        def loadcurtailQ_rule(m, xb, xy,xsc, xse, xd, xt):
            
            return  multiplier[xy][xsc][xb] *abs(Qd[xb]) >= m.Qlc[xb,xy,xsc, xse, xd,xt]
    
        # # Cost Constraints
        # Piece wise gen cost: Number of piece = 3
        def pwcost_rule(m,xg,xy,xsc, xse, xd,xp, xt):
            return m.Cgen[xg,xy,xsc, xse, xd,xt] >= m.Pgen[xg,xy,xsc, xse, xd,xt] * lcost[xp][xg] + min_y[xp][xg] 
                
        def budget_rule(m,xy,xsc):
            # TODO: Check budget rule
            # total branch investment cost for a year + # total flex cost for a year
            return Budget_cost[xy] >=  m.ciCost[xy,xsc]  \
                                    +  sum( m.Pflex[xb,xy,xsc,xse,xd,xt]*CPflex  \
                                       for xb in m.Set['Bus']  for xse in m.Set['Sea'] for xd in m.Set['Day'] for xt in m.Set['Tim'] ) \
                                        +  sum( m.Qflex[xb,xy,xsc,xse,xd,xt]*CQflex  \
                                       for xb in m.Set['Bus']  for xse in m.Set['Sea'] for xd in m.Set['Day'] for xt in m.Set['Tim'] ) 
                                
                
        
        # def test_rule(m,xintv,xbr):
        #     temp = [[0,0,0,0,0,0],[0,0,0,0,1,0],[1,0,0,0,0,0]]
        #     return m.ci[xintv,xbr,0,0] == temp[xintv][xbr]
        
    
    def addConstraints(m):
        
        #m.test = Constraint( m.Set['Intv'], m.Set['Bra'],  rule=rules.test_rule ) 
        
        # Add nodal balance constraint rules
        m.nodeBalance = Constraint( m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.nodeBalance_rule )  
        m.nodeBalanceQ = Constraint( m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.nodeBalanceQ_rule ) 
        
        # Add branch flow DC OPF
        #m.DCPF = Constraint( m.Set['Bra'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],  m.Set['Tim'], rule=rules.DCPF_rule ) 
        m.slackBus = Constraint( m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'],  rule=rules.slackBus_rule ) 
        
        
        # add load curtailment rules
        m.loadcurtail = Constraint( m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],m.Set['Tim'], rule=rules.loadcurtail_rule)  
        m.loadcurtailQ = Constraint( m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],m.Set['Tim'], rule=rules.loadcurtailQ_rule)  
    
        
        # Add branch capacity constraints
        m.braSCap = Constraint( m.Set['Bra'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.braSCap_rule )
        m.braSCapN = Constraint( m.Set['Bra'], m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.braSCapN_rule )
        m.braP = Constraint( m.Set['Bra'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.braP_rule )
        m.braQ = Constraint( m.Set['Bra'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.braQ_rule )
        
        # intervension rule
        m.interv = Constraint( m.Set['Bra'], m.Set['YSce'] , rule=rules.interv_rule )
        # investment Cost rule
        m.investCost = Constraint(  m.Set['YSce'],  rule=rules.investCost_rule )
    
        # pathway cost 
        m.pathwayCost = Constraint( m.Set['Path'], rule=rules.pathwayCost_rule )
        
        # nonAntipa_rule
        # m.nonAntipa = Constraint( m.Set['Intv'], m.Set['Bra'], range(no_ysce), rule=rules.nonAntipa_rule )
        m.nonAntipa = Constraint( m.Set['braIntev'],  range(no_ysce), rule=rules.nonAntipa_rule )

        
        # Add Gen constraint rules
        m.genMax = Constraint( m.Set['Gen'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],  m.Set['Tim'], rule=rules.genMax_rule )
        m.genMin = Constraint( m.Set['Gen'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.genMin_rule )
        m.genQMax = Constraint( m.Set['Gen'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],  m.Set['Tim'], rule=rules.genQMax_rule )
        m.genQMin = Constraint( m.Set['Gen'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'],  rule=rules.genQMin_rule )
        
        # piecve wise gen cost
        m.pwcost = Constraint(m.Set['Gen'], m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'],range(NoPieces),  m.Set['Tim'], rule=rules.pwcost_rule )
        
    
        # Add flex constraint rules
        m.flexPup = Constraint( m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.flexPup_rule )
        m.flexPdn = Constraint( m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.flexPdn_rule )
        
        m.flexQup = Constraint( m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.flexQup_rule )
        m.flexQdn = Constraint( m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.flexQdn_rule )
        
        #m.flexS = Constraint( m.Set['Bus'],m.Set['Tim'], rule=rules.flexS_rule )
        m.flexCost = Constraint( m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.flexCost_rule )
        m.flexCostN = Constraint( m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.flexCostN_rule )
        
        m.flexCostQ = Constraint( m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.flexCostQ_rule )
        m.flexCostQN = Constraint( m.Set['Bus'],m.Set['YSce'] ,m.Set['Sea'], m.Set['Day'], m.Set['Tim'], rule=rules.flexCostQN_rule )
      
            
        # budget rule
        m.budget = Constraint( m.Set['YSce'] ,rule=rules.budget_rule )
    
    
    
        
    
        return m
        
    
    # piece wise gen cost
    def genCost_rule(mpc):
        if mpc['gencost']['MODEL'] != []:
            # Define piece wise cost curve approximation 
            LGcost = np.zeros((3, mpc['NoGen']), dtype=float)
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
                    # Convert to LP constraints 
                    for xv in range(NoPieces):
                        lcost[xv][NoGen] = (yval[xv+1][NoGen]-yval[xv][NoGen]) / (xval[xv+1][NoGen] - xval[xv][NoGen])
         
                
                else:                                                 # Polinomial model
                    # Select number of pieces for the approximation
                   
                    Delta = mpc['gen']['PMAX'][NoGen]
                    
                    if Delta > 0 :
                 
                        Delta /= 3
                   
                        NoPieces = 3#int(np.floor(mpc['gen']['PMAX'][NoGen]/Delta))
    
                        aux = mpc['gen']['PMIN'][NoGen]
                        for xp in range(NoPieces+1):
                            xval[xp][NoGen] = aux
                            xc = mpc['gencost']['NCOST'][NoGen]-1 
                            yval[xp][NoGen] = mpc['gencost']['COST'][NoGen][xc]
                            for x in range(1, mpc['gencost']['NCOST'][NoGen]):
                                xc -= 1
                                yval[xp][NoGen] += mpc['gencost']['COST'][NoGen][xc]*xval[xp][NoGen]**x
                            aux += Delta
        
                        # Convert to LP constraints 
                        for xv in range(NoPieces):
                            lcost[xv][NoGen] = (yval[xv+1][NoGen]-yval[xv][NoGen]) / (xval[xv+1][NoGen] - xval[xv][NoGen])
                    
                   
                        
                        
                # LGcost =  y0-lcost*x0
                for xp in range(NoPieces):
                    LGcost[xp][NoGen] = yval[xp+1][NoGen] - xval[xp+1][NoGen] *  lcost[xp][NoGen]
          
                
                
                        
    
                            
        else:
            xval = np.random.uniform(low=10, high=50, size=(4,mpc['NoGen']))
            xval[1] = xval[1]*5 
            xval[2] = xval[2]*10
            xval[3] = xval[3]*15
            yval = np.ones((4,mpc['NoGen']), dtype=float)
            lcost = np.random.uniform(low=1, high=10, size=(3,mpc['NoGen']))
            lcost[1] = lcost[1]*3
            lcost[2] = lcost[2]*5
            
                
                    
        return  (NoPieces, lcost, LGcost)
    
         
            
    # find all connections
    def nodeConnections_rule():
    
        noDiff = 0
        
        # genCbus[bus][gen_number]
        genCbus = []
        braFbus = []
        braTbus = []
        # only 1 timepoint for Pd
        Pd = []
        Qd = []
        for xb in range(mpc["NoBus"]):
            bus_number = mpc["bus"]["BUS_I"][xb]
            # find generator connections
            gen_number = [i for i,x in enumerate(mpc["gen"]["GEN_BUS"]) if x==bus_number]
            genCbus.append(gen_number)
            
            # find branch from this bus
            braF_number = [i for i,x in enumerate(mpc["branch"]["F_BUS"]) if x==bus_number]
            braFbus.append(braF_number)
            # find branch to this bus
            braT_number = [i for i,x in enumerate(mpc["branch"]["T_BUS"]) if x==bus_number]
            braTbus.append(braT_number)
            
            #record demand value
            Pd.append( mpc['bus']['PD'][xb])
            Qd.append( mpc['bus']['QD'][xb])
    
        if peak_Pd !=[] :
            Pd = peak_Pd
        if peak_Qd !=[] :
            Qd = peak_Qd
       
        return (noDiff, genCbus, braFbus, braTbus, Pd, Qd)
    
    
    
    def form_tree(NoYear, NoSce):     
        # form a tree for the non-antipaticitivity constraints
        tree_ysce = []
        
        for xy in range(NoYear -1):
            sce = NoSce **xy # sceanrios for each year are 1, 2, 4, 8
            sce_next = -1
            for xsc in range(sce):
                for n in range(2):
                    sce_next += 1
                    # scenario tree info: [previous node year, scnenario, next node year, scenario]
                    tree_ysce.append([xy,xsc, xy+1, sce_next])
        no_ysce = len(tree_ysce)
        
        # tree_ysce ouput = 
                    # [[0, 0, 1, 0],
                    #  [0, 0, 1, 1],
                    #  [1, 0, 2, 0],
                    #  [1, 0, 2, 1],
                    #  [1, 1, 2, 2],
                    #  [1, 1, 2, 3],
                    #  [2, 0, 3, 0],
                    #  [2, 0, 3, 1],
                    #  [2, 1, 3, 2],
                    #  [2, 1, 3, 3],
                    #  [2, 2, 3, 4],
                    #  [2, 2, 3, 5],
                    #  [2, 3, 3, 6],
                    #  [2, 3, 3, 7]]
        return (no_ysce , tree_ysce) 
    
    def form_path_sce_tree(NoPath, NoYear, NoSce):
        # path_sce =  path0 [ y0_sce, y1_sce, y2_sce, y3_sce ]
        #               ...
        #             path7 [ y0_sce, y1_sce, y2_sce, y3_sce ]
        
        path_sce = np.zeros((NoPath, NoYear))
        
        for xy in range(NoYear):
            
            
            for xns in range(int(NoSce**xy)):
                temp = int(NoPath/NoSce**xy)
                xt = 0
           
                while xt*temp < NoPath:
                    lb = xt*temp
                    ub = (xt+1)*temp
        
                    for xp in range(lb, ub):
    
                        path_sce[xp][xy] = xt
                    
                    xt += 1
        path_sce = path_sce.astype(int)          
        path_sce = path_sce.tolist() 
    
          # path_sce = [
          #     [0,0,0,0],
          #     [0,0,0,1],
          #     [0,0,1,2],
          #     [0,0,1,3],
          #     [0,1,2,4],
          #     [0,1,2,5],
          #     [0,1,3,6],
          #     [0,1,3,7],
          #     ] 
          
          
        return path_sce 
          
    
    
    # Objective function 
    def OFrule(m):
        
    
        return (      
                        # load curtailment cost
                        sum(  m.Plc[xb, xy,xsc, xse, xd,xt]*penalty_cost 
                            for xb in m.Set['Bus'] for xy,xsc in m.Set['YSce'] 
                            for xse in m.Set['Sea'] for xd in m.Set['Day'] for xt in m.Set['Tim'] ) +
                       
                        sum( m.Qlc[xb, xy,xsc, xse, xd,xt]*penalty_cost 
                            for xb in m.Set['Bus'] for xy,xsc in m.Set['YSce'] 
                            for xse in m.Set['Sea'] for xd in m.Set['Day'] for xt in m.Set['Tim'] ) +
                         
                        # pathway cost
                        sum(prob[xp] * m.Cpath[xp] for xp in m.Set['Path'])
                        
               )
            
    
    # Prepare a pyomo model      
    def prepare_model(mpc,NetworkModel):
        
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
    
        return (model, solver)
    
    
    
    
    
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
    
    
    
    '''Main '''


    print("Investment model starts")
    print("Generate scenario tree based on input information")
    # get total number of nodes and edges of the scenario tree       
    no_ysce , tree_ysce = form_tree(NoYear, NoSce) 
    path_sce = form_path_sce_tree(NoPath, NoYear, NoSce)
    
    # build network model use graph
    NetworkModel = NetworkModel()
    
    # read mpc file and find info
    noDiff, genCbus,braFbus,braTbus,Pd, Qd = nodeConnections_rule()
    NoPieces, lcost, min_y = genCost_rule(mpc)
    
    # print("Form optimisation model")
    # build a pyomo model
    model, solver = prepare_model(mpc,NetworkModel)
    
    

    return (mpc,model, no_ysce , tree_ysce,path_sce,noDiff, genCbus,braFbus,braTbus,Pd, Qd )



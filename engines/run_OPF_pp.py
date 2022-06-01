# -*- coding: utf-8 -*-
"""
Created on Sat Aug  7 10:08:42 2021

@author: p96677wk
"""

import pandapower as pp
import pandapower.converter as pc
import pandapower.networks as pn 
import pandas as pd
import numpy as np
import pandapower.control as control
from pandapower.timeseries.run_time_series import run_timeseries
from pandapower.timeseries.data_sources.frame_data import DFData
from arrange_line_order_function import find_paraline, shift_line_position,  recover_line_position

# from pandapower.timeseries.output_writer import OutputWriter
# import os
# import json


def add_flex_profile(net, matGenNum,load_bus, max_Pflex , min_Pflex):

    # set as controllable
    net.ext_grid['controllable']=True
    # change ext_grid gencost
    # pp.create_poly_cost(net,0, 'ext_grid', cp1_eur_per_mw=10)

    # folder = "tests/excel/"
    # flex_file = "Transmission_Network_PT_2030_Active_Economy_24hGenerationLoadData.xlsx"
    
    
    flex_cost = 1e3

    
    ''' Add flex gen '''
    for xb in range(len(load_bus)):
    # Set a gen represent flexible power
        pp.create_gen(net,bus=load_bus[xb], p_mw=0, 
                            min_p_mw=0, #-abs(min_Pflex[xb]), 
                            max_p_mw=abs(max_Pflex[xb]), 
                            max_q_mvar= 100,
                            min_q_mvar= 0, #sn_mva=1,
                            controllable=True)
        # Set flex power cost £/MW
        pp.create_poly_cost(net,matGenNum+xb,'gen', cp1_eur_per_mw=flex_cost)
    
    
    # ''' Add flex gen '''
    # for xb in range(len(load_bus)):
    # # Set a gen represent flexible power
    #     pp.create_gen(net,bus=load_bus[xb], p_mw=0, min_p_mw=-0, 
    #                               max_p_mw=0, min_q_mvar=None, max_q_mvar=None, #sn_mva=1,
    #                               controllable=True)
    #     # Set flex power cost £/MW
    #     pp.create_poly_cost(net,len(net.gen)+xb,'gen', cp1_eur_per_mw=flex_cost[xb])
    
  

    # # add timeseries for flex gen 

    # const_flexGenUP = control.ConstControl(net, element='gen', element_index=net.gen.index,
    #                                   variable='max_p_mw', data_source=base_Pflex_up, profile_name=net.gen.index)    
    

    # const_flexGenDN = control.ConstControl(net, element='gen', element_index=net.gen.index,
    #                                   variable='min_p_mw', data_source=base_Pflex_dn*(-1), profile_name=net.gen.index)
    
    # # set flex q limits: set cos=0.98, then q~=0.2*p
  
    return net


def add_load_profile(net,base_Pd , base_Qd, mult):
      
    demandP = base_Pd * mult
    #ds = DFData(demandP)
    const_loadP = control.ConstControl(net, element='load', element_index=net.load.index,
                                      variable='p_m', data_source=demandP, profile_name=net.load.index)
    

    demandQ = base_Qd * mult
    #ds = DFData(demandQ)
    const_loadQ = control.ConstControl(net, element='load', element_index=net.load.index,
                                      variable='q_mvar', data_source=demandQ, profile_name=net.load.index)
    
    return net





def OPF_result(net,matSgenNum,time_steps):
    
    # Run AC OPF 
    run_timeseries(net,time_steps,verbose=False,continue_on_divergence=False, numba=False,run=pp.runopp)
    # run_timeseries(net,time_steps,verbose=True, run= pp.runpm_ac_opf)
    
    # get outputs
    pf_line = net.res_line["p_from_mw"].tolist()
    pt_line = net.res_line["p_to_mw"].tolist()
    qf_line = net.res_line["q_from_mvar"].tolist()
    qt_line = net.res_line["q_to_mvar"].tolist()
    
    p_line = [0]*len(pf_line)
    q_line = [0]*len(pf_line)
    
    for xl in range(len(pf_line)):
        if pf_line[xl] >= 0:
            p_line[xl] = pf_line[xl]
            q_line[xl] = qf_line[xl]
        else:
            p_line[xl] = pt_line[xl] * -1
            q_line[xl] = qt_line[xl] * -1
    
    CO = net.res_cost
    # translate dummy gen into load curtailment
    temp_plc_result = net.res_sgen["p_mw"].tolist()
    # get output from added dummy gens by removing previous sgens
    plc_result = temp_plc_result[int(matSgenNum) :]
    
    # temp_qlc_result = net.res_sgen["q_mvar"].tolist()
    # qlc_result = temp_qlc_result[int(matSgenNum) :]
    
    qlc_result = [i*0.2 for i in plc_result]
    # plc_result = [0]*len(plc_result)
    # qlc_result = [0]*len(qlc_result)
    
    
    for i in range(len(plc_result)):
        if plc_result[i] <= 1e-4:
            plc_result[i] = 0
        if qlc_result[i] <= 1e-4:
            qlc_result[i] = 0

    return (CO,plc_result,qlc_result,p_line,q_line)


def SCACOPF_function(net_name,cont_list, ci,Pflex_up , Pflex_dn, mult, delta_load, penalty_cost, n_timesteps=1):
    
    # load mpc file
    net = pc.from_mpc('tests/json/'+net_name+'.mat', f_hz=50) 
    # net = pc.from_mpc('tests/json/WP4_case5_t1.mat', f_hz=50) 
    # net = pc.from_mpc('tests/json/case5.mat', f_hz=50) 
    # net = pc.from_mpc("tests/json/Transmission_Network_UK3.mat", f_hz=50) 
    # net = pc.from_mpc("tests/json/HR_Location1.mat", f_hz=50) 
    # net = pn.case14()
    
    # remove gen cost
    for xg in range(len(net.poly_cost)):
        net.poly_cost["cp1_eur_per_mw"][xg] = 0
        net.poly_cost["cp2_eur_per_mw2"][xg] = 0
        net.poly_cost["cp0_eur"][xg] = 0
    
    #ci=[133, 58, 0, 0, 0, 0]
    # update line capacity with investments
    for xl in range(len(net.line)):
        net.line["max_i_ka"][xl] += ci[xl]/(net.bus["vn_kv"][0]*(3**0.5))


    # update loads by multiplier
    for xb in range(len(net.load)):
        net.load["p_mw"][xb] *= mult
        net.load["q_mvar"][xb] *= mult
        
        net.load["p_mw"][xb] += delta_load[xb]
        net.load["q_mvar"][xb] += delta_load[xb]

    
    # update gen by multiplier
    net.ext_grid["max_p_mw"][0] *= mult
    net.ext_grid["max_q_mvar"][0] *= mult
    
    for xg in range(len(net.gen)):
        net.gen["max_p_mw"][xg] *= mult
        net.gen["max_q_mvar"][xg] *= mult
        
        net.gen["min_p_mw"][xg] *= mult
        net.gen["min_q_mvar"][xg] *= mult
    
    
    # get the total number of gen from the input mat file
    matGenNum = len(net.gen) 
    
    # Add flex for contingencies
    # Add flex as gens
    # Pflex_up = 100
    # Pflex_dn = -100
    net = add_flex_profile(net,matGenNum,net.load['bus'], Pflex_up , Pflex_dn)
    
    # mult=1.51
    # penalty_cost=1e4
    # n_timesteps=1
    

    # get pre-existing sgens
    matSGenNum = len(net.sgen)

    
    # Add dummy gen to allow load curtailment for each load bus
    # dummy gens has the same cost as the penaltycost
    for xb in range(len(net.bus)):
        
        try:
           net.load['p_mw'][xb]
           
           dummy_p = net.load['p_mw'][xb] *100
           dummy_q = net.load['q_mvar'][xb] *100
           
        except KeyError:
            dummy_p = 1e10
            dummy_q = 1e10
         

        
        pp.create_sgen(net,bus=xb, p_mw=0, min_p_mw=0, 
                                  max_p_mw= dummy_p, 
                                  min_q_mvar=0, 
                                  max_q_mvar= dummy_q,
                                  #type="wye", sn_mva=1,
                                  controllable=True)
        # Set flex power cost £/MW
        temp_num = matSGenNum + xb
        pp.create_poly_cost(net,temp_num ,'sgen', cp1_eur_per_mw=penalty_cost)
    
        
    
    # Define number of time stpes
    # n_timesteps = 1
    time_steps = range(0, n_timesteps)
    
    # print("run normal state ACOPF")
    
    # run ACOPF
    CO, plc_result, qlc_result, p_line, q_line,  = OPF_result(net,matSGenNum,time_steps)
    
    # line loading percent
    line_loadPercent = net.res_line["loading_percent"].tolist()
    
    # define vars for contingencies    
    CO_con, plc_result_con, qlc_result_con, p_line_con, q_line_con  = ([] for i in range(5))
  
    # cont_list= [[1,1,1,1,1,1], [1,0,1,1,1,1]]

    
    if cont_list == []:
        # contingency state: N-1
        con_list = list(range(len(net.line)))
    else:
        con_list = []
        # the first list should be normal state
        for xc in range(len(cont_list)-1):
            temp = [i for i, e in enumerate(cont_list[xc+1]) if e == 0]
            con_list.append(temp[0])
    
    # print("run contingency state ACOPF")
    
    for xl in con_list:
        # print('Contingency at line: ', xl)
        # add contingency
        net.line['in_service'][xl] = False
        
        # run ACOPF with contigency
        CO_c, plc_result_c, qlc_result_c, p_line_c, q_line_c = OPF_result(net,matSGenNum,time_steps)
        # print("operation cost: ", CO_c)
        # print('load curtailment: ',sum(plc_result))
        
        # remove contingency
        net.line['in_service'][xl] = True
        
        # add contingency results
        CO_con.append(CO_c)
        
        plc_result_con.append(plc_result_c)
        qlc_result_con.append(qlc_result_c)
        
        p_line_con.append(p_line_c)
        q_line_con.append(q_line_c)
        
        


    
    return (CO, plc_result, qlc_result, p_line, q_line, 
            CO_con, plc_result_con, qlc_result_con, p_line_con, q_line_con,line_loadPercent)




def ACOPF_function(net_name,mpc, ci,Pflex_up , Pflex_dn, mult,penalty_cost):
    
    # load mpc file
    net = pc.from_mpc('tests/json/'+net_name+'.mat', f_hz=50) 
   

    # update line capacity with investments
    for xl in range(len(net.line)):
        net.line["max_i_ka"][xl] += ci[xl]/(net.bus["vn_kv"][0]*(3**0.5))


    # update loads by multiplier
    for xb in range(len(net.load)):
        net.load["p_mw"][xb] *= mult
        net.load["q_mvar"][xb] *= mult
        
    
    # update gen by multiplier
    net.ext_grid["max_p_mw"][0] *= mult
    net.ext_grid["max_q_mvar"][0] *= mult
    
    for xg in range(len(net.gen)):
        net.gen["max_p_mw"][xg] *= mult
        net.gen["max_q_mvar"][xg] *= mult
        
        net.gen["min_p_mw"][xg] *= mult
        net.gen["min_q_mvar"][xg] *= mult
    
    
    # get the total number of gen from the input mat file
    matGenNum = len(net.gen) 
    
    # Add flex for contingencies
    net = add_flex_profile(net,matGenNum,net.load['bus'], Pflex_up , Pflex_dn)
      

    # get pre-existing sgens
    matSGenNum = len(net.sgen)

    
    # Add dummy gen to allow load curtailment for each load bus
    # dummy gens has the same cost as the penaltycost
    for xb in range(len(net.bus)):
        
        try:
           net.load['p_mw'][xb]
           
           dummy_p = net.load['p_mw'][xb] *10
           dummy_q = net.load['q_mvar'][xb] *10
           
        except KeyError:
            dummy_p = 1e5
            dummy_q = 1e5
         

        
        pp.create_sgen(net,bus=xb, p_mw=0, min_p_mw=0, 
                                  max_p_mw= dummy_p, 
                                  min_q_mvar=0, 
                                  max_q_mvar= dummy_q,
                                  #type="wye", sn_mva=1,
                                  controllable=True)
        # Set flex power cost £/MW
        temp_num = matSGenNum + xb
        pp.create_poly_cost(net,temp_num ,'sgen', cp1_eur_per_mw=penalty_cost)
        
        
    
    # Define number of time stpes
    n_timesteps = 1
    time_steps = range(0, n_timesteps)
    
    # run ACOPF
    CO, plc_result, qlc_result, OPF_Pbra ,OPF_Qbra  = OPF_result(net,matSGenNum, time_steps)
   
    # line loading percent
    line_loadPercent = net.res_line["loading_percent"].tolist()
    
    print("get duals for branches")
    
    # get duals for branch
    delta_p = 0.1
    dual_p=[] 
    dual_q=[] 
    
    # Get duals for branches 
    for xbr in range(len( net.line)):
       
        # get delta change for branch
                    
        ci[xbr] += delta_p
                    
        CO2, plc_result2, qlc_result2, OPF_Pbra2 ,OPF_Qbra2 = OPF_result(net,matSGenNum, time_steps)
        
        # print('record values for branch: ', xbr)
        
        temp_p=[]
        temp_q=[]
        
        for xb in range(mpc['NoBus']):
            temp_p.append((plc_result2[xb] - plc_result[xb]) /delta_p )
            temp_q.append((qlc_result2[xb] - qlc_result[xb]) /delta_p )
       
            
        
        ci[xbr] -= delta_p
      
    
        dual_p.append(temp_p)  
        dual_q.append(temp_q)  


        
    
   
    dual_Pbra = []
    dual_Qbra = []
    dual_Pbra_con = []
    
    
    for xbr in range(len( OPF_Pbra)):
        dual_Pbra.append(sum(dual_p[xbr]) * penalty_cost * (-1))
        
        if sum(dual_q[xbr]) <= 0:
            dual_Qbra.append(sum(dual_q[xbr]) * penalty_cost * (-1))
        else:
            dual_Qbra.append(sum(dual_q[xbr]) * penalty_cost * 1)
    
    # print("dual_branches: ", dual_Pbra, dual_Qbra )
    
    new_bra_no = find_paraline(mpc)     

    dual_Pbra = recover_line_position(new_bra_no,  dual_Pbra)
    dual_Qbra = recover_line_position(new_bra_no,  dual_Qbra)
    
    
   
    return (CO, dual_Pbra )



def get_duals(net_name,mpc,con_list, ci, Pflex_up , Pflex_dn,penalty_cost,mult,NoTime):
    delta_p = 0.1
    delta_load = [0]*mpc["NoBus"]
    
    dual_p=[] 
    dual_q=[] 
    dual_p_con=[] 
    
    
    print(" first run of SCACOPF to get LC")
    # CO, plc_result, qlc_result, OPF_Pbra ,OPF_Qbra = ACOPF_function(net_name, ci,NoTime)
    CO, plc_result, qlc_result, OPF_Pbra ,OPF_Qbra,\
        CO_con, plc_result_con, qlc_result_con, OPF_Pbra_con ,OPF_Qbra_con,line_loadPercent = SCACOPF_function(net_name, con_list, ci,Pflex_up, Pflex_dn, mult, delta_load, penalty_cost, NoTime)
    
    # get power factors
    cos_pf =  [abs(a)/((a**2 + b**2)**0.5) for a,b in zip(OPF_Pbra, OPF_Qbra)]
    sin_pf = [(1-a**2)**0.5  for a in cos_pf]
   
    print("get duals for branches")
    # Get duals for branches 
    for xbr in range(len( OPF_Pbra)):
        # print('branch: ', xbr)
        # get delta change for branch
        # if OPF_Pbra[xbr]**2 + OPF_Qbra[xbr]**2 >= mpc["branch"]["RATE_A"][xbr]**2:
        if line_loadPercent[xbr] >= 99.99:    
            # print('need investment on branch: ', xbr)
            
            ci[xbr] += delta_p
                        
            # CO2, plc_result2, qlc_result2, OPF_Pbra2 ,OPF_Qbra2 = ACOPF_function(net_name, ci,NoTime)
            CO2, plc_result2, qlc_result2, OPF_Pbra2 ,OPF_Qbra2,\
                CO_con2, plc_result_con2, qlc_result_con2, OPF_Pbra_con2 ,OPF_Qbra_con2,line_loadPercent = SCACOPF_function(net_name, con_list, ci,Pflex_up, Pflex_dn, mult, delta_load, penalty_cost, NoTime)
            
            # print('record values for branch: ', xbr)
            
            temp_p=[]
            temp_q=[]
            temp_p_con=[]
            
            for xb in range(mpc['NoBus']):
                temp_p.append((plc_result2[xb] - plc_result[xb]) /delta_p )
                temp_q.append((qlc_result2[xb] - qlc_result[xb]) /delta_p )
                
            for xc in range(len(plc_result_con)):
                temp_p_con.append([])
                for xb in range(mpc['NoBus']):
                    temp_p_con[xc].append((plc_result_con2[xc][xb] - plc_result_con[xc][xb]) /delta_p )
                
            
            ci[xbr] -= delta_p
            
        else:
            temp_p = [0]*mpc['NoBus']
            temp_q = [0]*mpc['NoBus']
            temp_p_con = [0]*mpc['NoBus']
            
     
    
    
        dual_p.append(temp_p)  
        dual_q.append(temp_q)  

        dual_p_con.append(temp_p_con)
        
    
   
    dual_Pbra = []
    dual_Qbra = []
    dual_Pbra_con = []
    
    
    for xbr in range(len( OPF_Pbra)):
        dual_Pbra.append(sum(dual_p[xbr]) * penalty_cost * (-1))
        
        if sum(dual_q[xbr]) <= 0:
            dual_Qbra.append(sum(dual_q[xbr]) * penalty_cost * (-1))
        else:
            dual_Qbra.append(sum(dual_q[xbr]) * penalty_cost * 1)
    
    # print("dual_branches: ", dual_Pbra, dual_Qbra )
    
    new_bra_no = find_paraline(mpc)     
    
            
    
    
    for xc in range(len(plc_result_con)):
        dual_Pbra_con.append([])
        for xbr in range(len( OPF_Pbra)):
            if line_loadPercent[xbr] >= 99.99:   
                # temp = 
                dual_Pbra_con[xc].append(sum(dual_p_con[xbr][xc]) * penalty_cost * (-1))
                
            else:
                dual_Pbra_con[xc].append(0)
            
        dual_Pbra_con[xc] = recover_line_position(new_bra_no,  dual_Pbra_con[xc])

    OPF_Pbra = recover_line_position(new_bra_no, OPF_Pbra)
    OPF_Qbra = recover_line_position(new_bra_no, OPF_Qbra)
    dual_Pbra = recover_line_position(new_bra_no,  dual_Pbra)
    dual_Qbra = recover_line_position(new_bra_no,  dual_Qbra)
    
    # dual_Pbra_con = recover_line_position(new_bra_no,  dual_Pbra_con)
    
    # for xb in range(len(plc_result)):
    #     if plc_result[xb] <= 1e-4:
    #         plc_result[xb] = 0
    
    print("get duals for buses")
    # get dual_bus
    dual_Pbus = []
    dual_Qbus = []
    dual_Pbus_con = [ [] for _ in range(len(plc_result_con)) ]
    dual_Qbus_con = [ [] for _ in range(len(plc_result_con)) ]
    
    
    
    for xb in range(len(plc_result)):
        delta_load[xb] += delta_p 
       
        CO2, plc_result2, qlc_result2, OPF_Pbra2 ,OPF_Qbra2,\
             CO_con2, plc_result_con2, qlc_result_con2, OPF_Pbra_con2 ,OPF_Qbra_con2,line_loadPercent = SCACOPF_function(net_name, con_list, ci,Pflex_up, Pflex_dn, mult, delta_load, penalty_cost, NoTime)

        delta_load[xb] -= delta_p 


        dual_Pbus.append( (CO2-CO)/delta_p )
        dual_Qbus.append( (CO2-CO)/delta_p * 0.2 )
        
        
        for xc in range(len(plc_result_con)):
            dual_Pbus_con[xc].append( (CO_con2[xc]-CO_con[xc])/delta_p )
            dual_Qbus_con[xc].append( (CO_con2[xc]-CO_con[xc])/delta_p * 0.2 )
            

     
            
    
    return (CO, cos_pf, sin_pf, plc_result, plc_result_con, qlc_result,
            OPF_Pbra, OPF_Pbra_con ,OPF_Qbra, 
            dual_Pbra,dual_Pbra_con, 
            dual_Qbra, 
            dual_Pbus, dual_Pbus_con, dual_Qbus,dual_Qbus_con)



                                                              
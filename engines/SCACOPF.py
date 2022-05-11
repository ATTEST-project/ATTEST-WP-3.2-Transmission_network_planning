# -*- coding: utf-8 -*-
"""

@author: Wangwei Kong

Run SCACOPF in .jl
"""

# import julia
import os
import sys
import json

from julia import Julia
from julia import Main

from arrange_line_order_function import find_paraline, shift_line_position,  recover_line_position

import os.path



def remove_minimal_values(data):
    
    for i in range(len(data)):
        if abs(data[i]) <= 1e-4:
            data[i] = 0
    return data

def process_dual_variable(dual_data, penalty_cost):
    for i in range(len(dual_data)):
        
        if abs(dual_data[i]) <= 1e-4:
            dual_data[i] = 0
        else:
            dual_data[i] /= penalty_cost
            dual_data[i] = dual_data[i]**0.5
            dual_data[i] *= penalty_cost
            # dual_Pbra[i] *= 0.98
            
    return dual_data

def run_SCACOPF_jl(mpc, NoCon, penalty_cost = 1e4, sbase = 100):
    
    
    # os.chdir("WP3_SCOPF_export_to_WP3_R1_1")
    folder = "WP3_SCOPF_export_to_WP3_R1_1\\"

    if os.path.exists(folder+'export_WP3.json'):
        os.remove(folder+'export_WP3.json')
    
    print("Run SCACOPF")
    # run SC OPF in julia
    Main.include(folder+'00_mp_ac_scopf.jl')
    
    os.chdir(os.path.dirname(sys.argv[0]))
    
    
    # open output json file from acopf
    file = open(folder+'export_WP3.json')
    OPF_results = json.load(file)
    file.close()
    
    # delete json for each iteraion
    os.remove(folder+'export_WP3.json')
    
    # Translate PU data to python

    CO =  OPF_results["OPF_cost"][0]
    
    # load curtailment
    plc_result = [sbase * i for i in OPF_results["plc_result"][0]]
    qlc_result = [sbase * i for i in OPF_results["qlc_result"][0]]
    
    plc_result = remove_minimal_values(plc_result)
    qlc_result = remove_minimal_values(qlc_result)
    
    # OPF power flow results
    OPF_Pbra = [sbase * i for i in OPF_results["OPF_bra"]] 
    # TODO: update OPF_Qbra
    OPF_Qbra = [0]*6
    cos_pf =  [a/((a**2 + b**2)**0.5) for a,b in zip(OPF_Pbra, OPF_Qbra)]
    sin_pf = [(1-a**2)**0.5  for a in cos_pf]
    
    # OPF Flex results
    Pflex = [sbase *(i - d) for i, d in zip(OPF_results["OPF_Pflex_inc"][0], OPF_results["OPF_Pflex_dec"][0])]
    Qflex = [sbase *(i - d) for i, d in zip(OPF_results["OPF_Qflex_inc"][0], OPF_results["OPF_Qflex_dec"][0])]
    
    Pflex = remove_minimal_values(Pflex)
    Qflex = remove_minimal_values(Qflex)
    
    # dual variables for bus
    dual_Pbus = [ i for i in OPF_results["OPF_Pbal"]] 
    dual_Qbus = [ i for i in OPF_results["OPF_Qbal"]] 
    
    dual_Pbus = remove_minimal_values(dual_Pbus)
    dual_Qbus = remove_minimal_values(dual_Qbus)
    
    # dual variables for branch
    dual_bra = [-1 * i for i in OPF_results["dual_bra"]] 
    dual_Pbra = [a*b for a,b in zip(dual_bra, cos_pf)]
    dual_Qbra = [a*b for a,b in zip(dual_bra, sin_pf)] #[0]*6 #[100 * i for i in OPF_results["dual_Pbra"]] 
    
    dual_Pbra = process_dual_variable(dual_Pbra, penalty_cost)
    dual_Qbra = process_dual_variable(dual_Qbra, penalty_cost)
  
    plc_result_con = []      
    qlc_result_con = []
    OPF_Pbra_con = []
    Pflex_con = []
    Qflex_con = []
    dual_Pbus_con = []
    dual_Qbus_con = []
    dual_bra_con = []
    dual_Pbra_con = []
    dual_Qbra_con = []
    
    
    # Read contingency data
    for xc in range(NoCon):
     
        # load curtailment
        temp = [sbase * i for i in OPF_results["plc_result_con"][xc]]
        plc_result_con.append(temp)
        
        temp = [sbase * i for i in OPF_results["qlc_result_con"][xc]]
        qlc_result_con.append(temp)
        
        plc_result_con[xc] = remove_minimal_values(plc_result_con[xc])
        qlc_result_con[xc] = remove_minimal_values(qlc_result_con[xc])
        
        # OPF power flow results
        temp = [sbase * i for i in OPF_results["OPF_bra_con"][xc]]
        OPF_Pbra_con.append(temp) 
        
        # OPF Flex results
        temp = [sbase *(i - d) for i, d in zip(OPF_results["OPF_Pflex_inc_con"][xc], OPF_results["OPF_Pflex_dec_con"][xc])]
        Pflex_con.append(temp) 
        
        temp = [sbase *(i - d) for i, d in zip(OPF_results["OPF_Qflex_inc_con"][xc], OPF_results["OPF_Qflex_dec_con"][xc])]
        Qflex_con.append(temp)
        
        Pflex_con[xc] = remove_minimal_values(Pflex_con[xc])
        Qflex_con[xc] = remove_minimal_values(Qflex_con[xc])
        
        # dual variables for bus
        temp = [ i for i in OPF_results["OPF_Pbal_con"][xc]]
        dual_Pbus_con.append(temp)
        
        temp = [ i for i in OPF_results["OPF_Qbal_con"][xc]]
        dual_Qbus_con.append(temp)
        
        dual_Pbus_con[xc] = remove_minimal_values(dual_Pbus_con[xc])
        dual_Qbus_con[xc] = remove_minimal_values(dual_Qbus_con[xc])
        
        # dual variables for branch
        temp = [-1 * i for i in OPF_results["dual_bra_con"][xc]] 
        dual_bra_con.append(temp)
        temp_dual_Pbra_con = [a*b for a,b in zip(dual_bra_con[xc], cos_pf)]
        temp_dual_Qbra_con = [a*b for a,b in zip(dual_bra_con[xc], sin_pf)]
        
        dual_Pbra_con.append(process_dual_variable(temp_dual_Pbra_con, penalty_cost))
        dual_Qbra_con.append(process_dual_variable(temp_dual_Qbra_con, penalty_cost))
    
    
    
    # recover parallel lines
    new_bra_no = find_paraline(mpc)     
    OPF_Pbra_recov = recover_line_position(new_bra_no, OPF_Pbra)
    OPF_Qbra_recov = recover_line_position(new_bra_no, OPF_Qbra)
    
    dual_Pbra_recov = recover_line_position(new_bra_no, dual_Pbra)
    dual_Qbra_recov = recover_line_position(new_bra_no, dual_Qbra)
    
    
    OPF_Pbra_con_recov = []
    OPF_Qbra_con_recov = [] 
    dual_Pbra_con_recov = []
    dual_Qbra_con_recov = []
    
    for xc in range(NoCon):
        temp = recover_line_position(new_bra_no, OPF_Pbra_con[xc])
        OPF_Pbra_con_recov.append(temp) 
        
        # temp = recover_line_position(new_bra_no, OPF_Qbra_con[xc])
        # OPF_Qbra_con_recov.append(temp)
        
        temp = recover_line_position(new_bra_no, dual_Pbra_con[xc])
        dual_Pbra_con_recov.append(temp)
        
        temp = recover_line_position(new_bra_no, dual_Qbra_con[xc])
        dual_Qbra_con_recov.append(temp)

    
    # os.chdir("C:/Users/p96677wk/Dropbox (The University of Manchester)/My PC (E-10LPC1N2L4S)/Desktop/ATTEST/pyATTEST/pyene/engines")
    
    return ( CO,cos_pf, sin_pf, plc_result,plc_result_con, qlc_result, 
            OPF_Pbra_recov , OPF_Pbra_con_recov ,OPF_Qbra_recov, 
            dual_Pbra_recov,dual_Pbra_con_recov, dual_Qbra_recov, 
            dual_Pbus,dual_Pbus_con, dual_Qbus,dual_Qbus_con ) #OPF_results
    # return (
    #         CO, plc_result, plc_result_con, qlc_result, qlc_result_con, 
    #         OPF_Pbra ,OPF_Pbra_con ,OPF_Qbra ,
    #         Pflex, Pflex_con, Qflex, Qflex_con,
    #         dual_Pbra, dual_Pbra_con, dual_Qbra,
    #         dual_Pbus, dual_Pbus_con, dual_Qbus, dual_Qbus_con
    #     )



# TODO: Update output file for multiple scensrios and years
def output2json(mpc,ci, Pflex, Qflex ):
    
    # os.chdir("WP3_SCOPF_export_to_WP3_R1_1")
    folder = "WP3_SCOPF_export_to_WP3_R1_1\\"
    # combine parallel lines, shift positions
    new_bra_no = find_paraline(mpc)  
    ci_shifted = shift_line_position(mpc,new_bra_no, ci)   
    
    if os.path.exists(folder+'import_WP3.json'):
        os.remove(folder+'import_WP3.json')
    
    Pflex_inc = []
    Pflex_dec = []
    Qflex_inc = []
    Qflex_dec = []
    
    for i in range(len(Pflex)):
        if Pflex[i] > 0 :
            Pflex_inc.append(Pflex[i])
            Pflex_dec.append(0)
        elif Pflex[i] < 0 :
            Pflex_inc.append(0)
            Pflex_dec.append(-Pflex[i])
        else:
            Pflex_inc.append(0)
            Pflex_dec.append(0)
    
    for i in range(len(Qflex)):
        if Qflex[i] > 0 :
            Qflex_inc.append(Qflex[i])
            Qflex_dec.append(0)
        elif Pflex[i] < 0 :
            Qflex_inc.append(0)
            Qflex_dec.append(-Qflex[i])
        else:
            Qflex_inc.append(0)
            Qflex_dec.append(0)
    
    ouput = {
             "ci":ci_shifted,
             "Pflex_dec":Pflex_dec,
             "Pflex_inc":Pflex_inc,
             "Qflex_dec":Qflex_dec,
             "Qflex_inc": Qflex_inc
             }
    
    ''' Outpu json file''' 
    with open(folder+'import_WP3.json', 'w') as fp:
        json.dump(ouput, fp)
        
    # os.chdir("C:/Users/p96677wk/Dropbox (The University of Manchester)/My PC (E-10LPC1N2L4S)/Desktop/ATTEST/pyATTEST/pyene/engines")



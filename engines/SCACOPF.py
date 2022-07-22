# -*- coding: utf-8 -*-
"""

@author: Wangwei Kong

Run SCACOPF in .jl
"""

# import julia
import os
import sys
import json
# import julia
# julia.install()
from julia import Julia
from julia import Main

from arrange_line_order_function import find_paraline, shift_line_position,  recover_line_position

import os.path
import cProfile
import pstats



def remove_minimal_values(data):
    try:
        for i in range(len(data)):
            if abs(data[i]) <= 1e-3:
                data[i] = 0
    except TypeError:
        if abs(data) <= 1e-3:
            data = 0
    return data

# def process_dual_variable(dual_data, penalty_cost):
#     for i in range(len(dual_data)):
        
#         if abs(dual_data[i]) <= 1e-3:
#             dual_data[i] = 0
#         else:
#             dual_data[i] /= penalty_cost
#             dual_data[i] = dual_data[i]**0.5
#             dual_data[i] *= penalty_cost
#             # dual_Pbra[i] *= 0.98
            
#     return dual_data


def get_branch_pf(mpc, OPF_results, sbase ):
    # get branch power flow with directions for normal state
    
    OPF_Pbra = [0]*mpc["NoBranch"]
    OPF_Qbra = [0]*mpc["NoBranch"]
    
    for xbr in range(mpc["NoBranch"]):
        fbus = mpc["branch"]["F_BUS"][xbr]
        tbus = mpc["branch"]["T_BUS"][xbr]
        
        temp_key = str( (fbus, tbus) )
        
        OPF_Pbra[xbr] = OPF_results["OPF_bra_active_normal"][temp_key] * sbase 
        OPF_Qbra[xbr] = OPF_results["OPF_bra_reactive_normal"][temp_key] * sbase 
    
    return OPF_Pbra, OPF_Qbra

def get_branch_pf_cont(mpc, cont_list, OPF_results, sbase ):
    # get branch power flow with directions for contigency states
    NoCon = len( cont_list) -1
    
    OPF_Pbra_con = []
    OPF_Qbra_con = []
    
    for xc in range(NoCon):
        
        OPF_Pbra_con.append([0]*mpc["NoBranch"])
        OPF_Qbra_con.append([0]*mpc["NoBranch"])
        
        con_br = [i for i, e in enumerate(cont_list[xc+1]) if e == 0]
        
        
        for xbr in range(mpc["NoBranch"]):
            
            if xbr != con_br[0] :
                fbus = mpc["branch"]["F_BUS"][xbr]
                tbus = mpc["branch"]["T_BUS"][xbr]
                
                temp_key = str( (xc+1, fbus, tbus) )
           
                OPF_Pbra_con[xc][xbr] = OPF_results["OPF_bra_active_contin"][temp_key] * sbase 
                OPF_Qbra_con[xc][xbr] = OPF_results["OPF_bra_reactive_contin"][temp_key] * sbase 
                
                OPF_Pbra_con[xc][xbr] = remove_minimal_values(OPF_Pbra_con[xc][xbr])
                OPF_Qbra_con[xc][xbr] = remove_minimal_values(OPF_Qbra_con[xc][xbr])
                
            
    return OPF_Pbra_con, OPF_Qbra_con


def get_branch_dual_normal(mpc, OPF_results, time_point):
# get line duals for normal state
    dual_bra = [0]*mpc["NoBranch"]
    
    if time_point == 1:
                
        for xbr in range(mpc["NoBranch"]):
            
            fbus = mpc["branch"]["F_BUS"][xbr]
            tbus = mpc["branch"]["T_BUS"][xbr]
            
            temp_key = str( (fbus, tbus) )
            
            temp_dual_bra = remove_minimal_values(OPF_results["OPF_thermal_limit_max_dual_normal"][temp_key])
        
            # dual_bra[xbr] = OPF_results["OPF_thermal_limit_max_dual_normal"][temp_key] * (-1)
            # dual_bra[xbr] = (OPF_results["OPF_thermal_limit_max_dual_normal"][temp_key] * (-1))**0.5
            
            dual_bra[xbr] = (temp_dual_bra*(-1)) **0.5
    
    else:
        
        for xbr in range(mpc["NoBranch"]):
            
            fbus = mpc["branch"]["F_BUS"][xbr]
            tbus = mpc["branch"]["T_BUS"][xbr]
            
            for xt in range(time_point):
            
                temp_key = str( (xt+1, fbus, tbus) )
                
                temp_dual_bra = remove_minimal_values(OPF_results["OPF_thermal_limit_max_dual_normal"][temp_key])
                
                # dual_bra[xbr] += OPF_results["OPF_thermal_limit_max_dual_normal"][temp_key] * (-1)
 
                dual_bra[xbr] += (OPF_results["OPF_thermal_limit_max_dual_normal"][temp_key] * (-1))**0.5
                
                dual_bra[xbr] += (temp_dual_bra*(-1)) **0.5
        
    # dual_bra = remove_minimal_values(dual_bra)

    return dual_bra




def get_branch_dual_cont(mpc,cont_list, penalty_cost, OPF_results, OPF_Pbra_con, OPF_Qbra_con):
    # get line duals for normal state
    NoCon = len( cont_list) -1
    
    dual_bra_con = []
    dual_Pbra_con = []
    dual_Qbra_con = []
    
    
    
    
    for xc in range(NoCon):
        
        dual_bra_con.append([0]*mpc["NoBranch"])
        cos_pf_con = [0]*mpc["NoBranch"]
        
        
        con_br = [i for i, e in enumerate(cont_list[xc+1]) if e == 0]
    
        for xbr in range(mpc["NoBranch"]):
            if xbr != con_br[0]  :
                fbus = mpc["branch"]["F_BUS"][xbr]
                tbus = mpc["branch"]["T_BUS"][xbr]
                
                temp_key = str( (xc+1, fbus, tbus) )
                
                temp_dual_bra_con = remove_minimal_values(OPF_results["OPF_thermal_limit_max_dual_contin"][temp_key])
            
                # dual_bra_con[xc][xbr] = OPF_results["OPF_thermal_limit_max_dual_contin"][temp_key] * (-1)
                # dual_bra_con[xc][xbr] = (OPF_results["OPF_thermal_limit_max_dual_contin"][temp_key] * (-1))**0.5
                
                dual_bra_con[xc][xbr] = (temp_dual_bra_con * (-1))**0.5
                
                temp_p = OPF_Pbra_con[xc][xbr]
                temp_q = OPF_Qbra_con[xc][xbr]
        
                cos_pf_con[xbr] = abs(temp_p) /( temp_p**2 + temp_q**2+ 0.000001)**0.5
        
        sin_pf_con = [(1-a**2)**0.5  for a in cos_pf_con]
        
        temp_dual_Pbra_con = [a*b for a,b in zip(dual_bra_con[xc], cos_pf_con)]
        temp_dual_Qbra_con = [a*b for a,b in zip(dual_bra_con[xc], sin_pf_con)]
        
        
        # dual_Pbra_con.append(remove_minimal_values(temp_dual_Pbra_con))
        # dual_Qbra_con.append(remove_minimal_values(temp_dual_Qbra_con))
        
        dual_Pbra_con.append(temp_dual_Pbra_con)
        dual_Qbra_con.append(temp_dual_Qbra_con)
        
    return  dual_Pbra_con, dual_Qbra_con



def get_bus_dual_normal(mpc, OPF_results):
    # get bus dual values for normal state
    
    dual_Pbus = [0]*mpc["NoBus"]
    dual_Qbus = [0]*mpc["NoBus"]
    
    for xb in range(mpc["NoBus"]):
        temp_key = str( (xb+1, ) )
        
        dual_Pbus[xb] = OPF_results["active_power_balance_normal_dual"][temp_key] 
        dual_Qbus[xb] = OPF_results["reactive_power_balance_normal_dual"][temp_key] 
    
    dual_Pbus = remove_minimal_values(dual_Pbus)
    dual_Qbus = remove_minimal_values(dual_Qbus)

    return dual_Pbus, dual_Qbus


def get_bus_dual_cont(mpc, OPF_results):
    # get bus dual values for normal state
    NoCon = len( OPF_results['cont_list'] )
    
    dual_Pbus_con = []
    dual_Qbus_con = []
    
    for xc in range(NoCon):
        
        dual_Pbus_con.append([0]*mpc["NoBus"])
        dual_Qbus_con.append([0]*mpc["NoBus"])
        
        
        for xb in range(mpc["NoBus"]):
            temp_key = str( (xc+1, xb+1) )
            
            dual_Pbus_con[xc][xb] = OPF_results["active_power_balance_contin_dual"][temp_key] 
            dual_Qbus_con[xc][xb] = OPF_results["reactive_power_balance_contin_dual"][temp_key] 

        
        dual_Pbus_con[xc] = remove_minimal_values(dual_Pbus_con[xc])
        dual_Qbus_con[xc] = remove_minimal_values(dual_Qbus_con[xc])
        
    
   
    return dual_Pbus_con, dual_Qbus_con

def run_jl(folder):

    Main.include(folder+'main.jl')
    
    

def process_result_normal(mpc, OPF_results,sbase,penalty_cost):
    
    # load curtailment
    plc_result = [sbase * i for i in OPF_results["plc_result"][0][0]]
    qlc_result = [sbase * i for i in OPF_results["qlc_result"][0][0]]
    
    plc_result = remove_minimal_values(plc_result)
    qlc_result = remove_minimal_values(qlc_result)
    
    # OPF power flow results
    # OPF_Pbra = [sbase * i for i in OPF_results["OPF_bra"]] 
    # OPF_Qbra = [0]*6
    OPF_Pbra, OPF_Qbra = get_branch_pf(mpc, OPF_results, sbase )
    
    print("jl pf: ", OPF_Pbra)
    
    cos_pf = [abs(a)/((a**2 + b**2 +0.00001)**0.5) for a,b in zip(OPF_Pbra, OPF_Qbra)]
    sin_pf = [(1-a**2)**0.5  for a in cos_pf]
    
    # OPF Flex results
    Pflex = [sbase *(i - d) for i, d in zip(OPF_results["OPF_Pflex_dec"][0][0], OPF_results["OPF_Pflex_inc"][0][0])]
    Qflex = [sbase *(i - d) for i, d in zip(OPF_results["OPF_Qflex_dec"][0][0], OPF_results["OPF_Qflex_inc"][0][0])]
    
    Pflex = remove_minimal_values(Pflex)
    Qflex = remove_minimal_values(Qflex)
    
    # dual variables for bus
    # dual_Pbus = [ i for i in OPF_results["OPF_Pbal"]] 
    # dual_Qbus = [ i for i in OPF_results["OPF_Qbal"]] 
    dual_Pbus, dual_Qbus = get_bus_dual_normal(mpc, OPF_results)
    
    
    
    # dual variables for branch
    # dual_bra = [-1 * i for i in OPF_results["dual_bra"]] 
    dual_bra = get_branch_dual_normal(mpc, OPF_results, 1)
    
    
    
    dual_Pbra = [a*b for a,b in zip(dual_bra, cos_pf)]
    dual_Qbra = [a*b for a,b in zip(dual_bra, sin_pf)]  
    
    # dual_Pbra = remove_minimal_values(dual_Pbra)
    # dual_Qbra = remove_minimal_values(dual_Qbra)
    
    
    
    return (OPF_Pbra, OPF_Qbra, plc_result, qlc_result,cos_pf,sin_pf,Pflex,Qflex,
            dual_Pbus, dual_Qbus,dual_Pbra,dual_Qbra)




def process_result_con(mpc, cont_list, OPF_results, sbase,penalty_cost):
    # OPF power flow results
    OPF_Pbra_con, OPF_Qbra_con = get_branch_pf_cont(mpc,cont_list, OPF_results, sbase )
    
    
    # dual variables for branch
    dual_Pbra_con, dual_Qbra_con = get_branch_dual_cont(mpc, cont_list, penalty_cost, OPF_results,OPF_Pbra_con, OPF_Qbra_con)
    
    # dual variables for bus
    dual_Pbus_con, dual_Qbus_con = get_bus_dual_cont(mpc, OPF_results)
    

    plc_result_con = []      
    qlc_result_con = []
    # OPF_Pbra_con = []
    Pflex_con = []
    Qflex_con = []
    # dual_Pbus_con = []
    # dual_Qbus_con = []
    # dual_bra_con = []
    # dual_Pbra_con = []
    # dual_Qbra_con = []
    
    NoCon = len( cont_list ) -1
    # Read contingency data
    for xc in range(NoCon):
     
        # load curtailment
        temp = [sbase * i for i in OPF_results["plc_result_con"][xc][0]]
        plc_result_con.append(temp)
        
        temp = [sbase * i for i in OPF_results["qlc_result_con"][xc][0]]
        qlc_result_con.append(temp)
        
        plc_result_con[xc] = remove_minimal_values(plc_result_con[xc])
        qlc_result_con[xc] = remove_minimal_values(qlc_result_con[xc])
        
        # OPF power flow results
        # temp = [sbase * i for i in OPF_results["OPF_bra_con"][xc]]
        # OPF_Pbra_con.append(temp) 
        
        # OPF Flex results
        temp = [sbase *(i - d) for i, d in zip(OPF_results["OPF_Pflex_dec_con"][xc][0], OPF_results["OPF_Pflex_inc_con"][xc][0])]
        Pflex_con.append(temp) 
        
        temp = [sbase *(i - d) for i, d in zip(OPF_results["OPF_Qflex_dec_con"][xc][0], OPF_results["OPF_Qflex_inc_con"][xc][0])]
        Qflex_con.append(temp)
        
        Pflex_con[xc] = remove_minimal_values(Pflex_con[xc])
        Qflex_con[xc] = remove_minimal_values(Qflex_con[xc])
        
        # dual variables for bus
        # temp = [ i for i in OPF_results["OPF_Pbal_con"][xc]]
        # dual_Pbus_con.append(temp)
        
        # temp = [ i for i in OPF_results["OPF_Qbal_con"][xc]]
        # dual_Qbus_con.append(temp)
        
        # dual_Pbus_con[xc] = remove_minimal_values(dual_Pbus_con[xc])
        # dual_Qbus_con[xc] = remove_minimal_values(dual_Qbus_con[xc])
        
        # dual variables for branch
        # temp = [-1 * i for i in OPF_results["dual_bra_con"][xc]] 
        # dual_bra_con.append(temp)
        # temp_dual_Pbra_con = [a*b for a,b in zip(dual_bra_con[xc], cos_pf)]
        # temp_dual_Qbra_con = [a*b for a,b in zip(dual_bra_con[xc], sin_pf)]
        
        # dual_Pbra_con.append(process_dual_variable(temp_dual_Pbra_con, penalty_cost))
        # dual_Qbra_con.append(process_dual_variable(temp_dual_Qbra_con, penalty_cost))
    
    
    
    # recover parallel lines
    # new_bra_no = find_paraline(mpc)     
    # OPF_Pbra_recov = recover_line_position(new_bra_no, OPF_Pbra)
    # OPF_Qbra_recov = recover_line_position(new_bra_no, OPF_Qbra)
    
    # dual_Pbra_recov = recover_line_position(new_bra_no, dual_Pbra)
    # dual_Qbra_recov = recover_line_position(new_bra_no, dual_Qbra)
    
    
    # OPF_Pbra_con_recov = []
    # OPF_Qbra_con_recov = [] 
    # dual_Pbra_con_recov = []
    # dual_Qbra_con_recov = []
    
    # for xc in range(NoCon):
    #     temp = recover_line_position(new_bra_no, OPF_Pbra_con[xc])
    #     OPF_Pbra_con_recov.append(temp) 
        
    #     # temp = recover_line_position(new_bra_no, OPF_Qbra_con[xc])
    #     # OPF_Qbra_con_recov.append(temp)
        
    #     temp = recover_line_position(new_bra_no, dual_Pbra_con[xc])
    #     dual_Pbra_con_recov.append(temp)
        
    #     temp = recover_line_position(new_bra_no, dual_Qbra_con[xc])
    #     dual_Qbra_con_recov.append(temp)
    
    # # Not used
    # return ( CO,cos_pf, sin_pf, plc_result,plc_result_con, qlc_result, 
    #         OPF_Pbra_recov , OPF_Pbra_con_recov ,OPF_Qbra_recov, 
    #         dual_Pbra_recov,dual_Pbra_con_recov, dual_Qbra_recov, 
    #         dual_Pbus,dual_Pbus_con, dual_Qbus,dual_Qbus_con ) #OPF_results

    return (  OPF_Pbra_con, OPF_Qbra_con,dual_Pbra_con, dual_Qbra_con,
            dual_Pbus_con,dual_Qbus_con,plc_result_con,qlc_result_con, Pflex_con, Qflex_con)

def run_SCACOPF_jl(mpc, cont_list, penalty_cost, sbase = 100):
    
    # profiler = cProfile.Profile()
    # profiler.enable()
    
    # os.chdir("WP3_SCOPF_export_to_WP3_R1_1")
    # folder = "WP3_SCOPF_export_to_WP3_R1_1\\"
    folder = "SCOPF_R5\\"

    if os.path.exists(folder+'data_preparation\\export_WP3.json'):
        os.remove(folder+'data_preparation\\export_WP3.json')
    
    print("Run SCACOPF")
    # run SC OPF in julia
    # Main.include(folder+'00_mp_ac_scopf.jl')
    # Main.include(folder+'main.jl')
    
    # os.chdir(os.path.dirname(sys.argv[0]))
    run_jl(folder)
    os.chdir(os.path.dirname(sys.argv[0]))
        
    # open output json file from acopf
    file = open(folder+'data_preparation\\export_WP3.json')
    OPF_results = json.load(file)
    file.close()
    
    
    # Translate PU data to python
    # OPF_results["OPF_cost"] =[cost_gen, cost_fl, cost_fl_c, cost_pen_lsh, cost_pen_lsh_c, cost_pen_ws, cost_pen_ws_c ]   
    CO =  sum(OPF_results["OPF_cost"])
    
    ''' normal state '''        
    OPF_Pbra, OPF_Qbra, plc_result, qlc_result,cos_pf,sin_pf,Pflex,Qflex,\
        dual_Pbus, dual_Qbus,dual_Pbra,dual_Qbra = process_result_normal(mpc, OPF_results,sbase,penalty_cost)


    ''' contingency'''
    
    OPF_Pbra_con, OPF_Qbra_con,dual_Pbra_con, dual_Qbra_con,dual_Pbus_con,dual_Qbus_con,\
        plc_result_con,qlc_result_con, Pflex_con, Qflex_con = process_result_con(mpc,cont_list, OPF_results, sbase,penalty_cost)

    
    # os.chdir("C:/Users/p96677wk/Dropbox (The University of Manchester)/My PC (E-10LPC1N2L4S)/Desktop/ATTEST/pyATTEST/pyene/engines")
    
    # delete json for each iteraion
    os.remove(folder+'data_preparation\\export_WP3.json')
    
   

    # from io import StringIO
    # profiler.disable()
    # # sort output with total time

    
    # result = StringIO()
    # stats = pstats.Stats(profiler, stream = result).sort_stats('tottime')
    # stats.print_stats(5)
    # Save it into disk
    # with open('cProfileExport_SCACOPF.txt', 'w+') as f:
    #     f.write(result.getvalue())

    return (CO, cos_pf, sin_pf, plc_result, plc_result_con, qlc_result,
            OPF_Pbra, OPF_Pbra_con ,OPF_Qbra, 
            dual_Pbra,dual_Pbra_con, 
            dual_Qbra, 
            dual_Pbus, dual_Pbus_con, dual_Qbus,dual_Qbus_con)

def run_ACOPF_jl(mpc, penalty_cost, sbase = 100):
    
 
    folder = "SCOPF_R5\\"

    if os.path.exists(folder+'data_preparation\\export_WP3.json'):
        os.remove(folder+'data_preparation\\export_WP3.json')
    
    print("Run ACOPF")
    
    run_jl(folder)
    os.chdir(os.path.dirname(sys.argv[0]))
        
    # open output json file from acopf
    file = open(folder+'data_preparation\\export_WP3.json')
    OPF_results = json.load(file)
    file.close()
    
    
    # Translate PU data to python
    # OPF_results["OPF_cost"] =[cost_gen, cost_fl, cost_fl_c, cost_pen_lsh, cost_pen_lsh_c, cost_pen_ws, cost_pen_ws_c ]   
    CO =  sum(OPF_results["OPF_cost"])
    

    dual_bra = get_branch_dual_normal(mpc, OPF_results, 24)
    
    
    # os.chdir("C:/Users/p96677wk/Dropbox (The University of Manchester)/My PC (E-10LPC1N2L4S)/Desktop/ATTEST/pyATTEST/pyene/engines")
    
    # delete json for each iteraion
    os.remove(folder+'data_preparation\\export_WP3.json')
    
   

    return  CO, dual_bra

   


def process_flex_result(Pflex, Qflex):
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
            
    return Pflex_inc , Pflex_dec , Qflex_inc ,Qflex_dec 




def output2json(ods_file_name,mpc,ci, Pflex, Qflex, mult,OPF_opt ):
    
    '''
    Data exchange between operation model and investment model:
        
        
       flag_indicator  | OPF flag  + Time point flag	        |  Gen cost flag
            0          | SCACOPF	+ snapshot	                |  Minimal cost, e.g., 0.1, 0.2…
            1	        |  ACOPF	  +  multiple-period (24h)	   |  Original cost
            
       -----------------------------------------------------------------------------------------------
            
    
        Multiplier	  | Load profile multiplier	  |  Generation profile multiplier
    
    
    ''' 
    
    

    # os.chdir("WP3_SCOPF_export_to_WP3_R1_1")
    folder = "SCOPF_R5\\"
    
    
    filename = "input_data/"+ ods_file_name + ".ods"
    
    # combine parallel lines, shift positions
    # new_bra_no = find_paraline(mpc)  
    # ci_shifted = shift_line_position(mpc,new_bra_no, ci) 
    ci_shifted = ci # shifting position not required
    
 
    
    
    if os.path.exists(folder+'data_preparation\\import_WP3.json'):
        os.remove(folder+ 'data_preparation\\import_WP3.json')
    
    # Pflex_dec in invest model is the increase of output from flexible resource
    # it is the "Pflex_inc" in the operation model, which means the decrease of flexible load
    Pflex_inc , Pflex_dec , Qflex_inc ,Qflex_dec = process_flex_result(Pflex, Qflex)
    

    
    if OPF_opt == 0:
        gencost = 0.1
    else:
        gencost = 1
    
    
    ouput = {
             "ci":ci_shifted,
             "Pflex_dec":Pflex_inc,
             "Pflex_inc":Pflex_dec,
             "Qflex_dec":Qflex_inc,
             "Qflex_inc": Qflex_dec,
             "gencost":gencost,
             "gen_multiplier": mult,
             "load_multiplier": mult,
             "OPF_opt":OPF_opt,
             "filename": filename,
             }
    
    ''' Outpu json file''' 
    with open(folder+'data_preparation\\import_WP3.json', 'w') as fp:
        json.dump(ouput, fp)
        






# Read data outputs for ACOPF
# a.	the total operation cost, 
# b.	24h dual variables for branch power flow P (thermal limits)
# c.	24h dual variables for branch power flow Q (thermal limits)

def read_ACOPF_jl_output():
    
  
    
    hourly_dual_Pbra = [1]*24
    hourly_dual_Qbra = [1]*24
    
    daily_dual_Pbra = sum(hourly_dual_Pbra )
    daily_dual_Qbra = sum(hourly_dual_Qbra )
    
    
    daily_CO = 0
    
    

    
    return daily_CO, daily_dual_Pbra, daily_dual_Qbra 








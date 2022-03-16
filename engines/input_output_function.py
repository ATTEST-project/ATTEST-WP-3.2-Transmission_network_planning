# -*- coding: utf-8 -*-
"""
Work in progress
"""

from pyexcel_ods import get_data
from pyexcel_ods import save_data
import json
import os
from conversion_model_mat2json import any2json
from scenarios_multipliers import get_mult


def json_directory():
    ''' Directory contain JSON files for pytest '''
    return os.path.join(os.path.dirname(__file__), 'tests', 'json')




def read_input_data(test_case, country = "HR" ):
    
    
    file_name  = str(test_case) # 'case5'  # 'Transmission_Network_UK_2020'
    #NoTime = 1
    
    # todo: update json input to exclude dummy generators?
    '''load m file'''
    converter = any2json()
    converter.matpower2json(folder_path=json_directory(), \
                            name_matpower=file_name, name_json=file_name)
    print('m file converted to json')

    
    filepath = os.path.join(json_directory(), file_name+'.json')

    ''' Load json file''' 
    # load json file from file directory
    mpc = json.load(open(filepath))
    print('load json file')                             
    
    
    '''Load multipliers for different scnearios'''
    multiplier = get_mult(country) # default to HR
    
    
    ''' Load .ods file'''
    base_time_series_data = get_data("Transmission_Network_PT_2020_24hGenerationLoadData.ods")
    print('load ods file')  
    
   
    
    
    

    return (mpc,  base_time_series_data,  multiplier)




def output_data(output_data, Output_Data_Investment ):
    
    # read ods template
    ods_template = get_data("Output_Data_T3.2_CBA.ods")
    
    # add branch inveestment
    # year 2020
    ods_template["Option_1"][16][4] = 2020
    ods_template["Option_1"][16][14] = 2030
    ods_template["Option_1"][16][24] = 2040
    ods_template["Option_1"][16][34] = 2050
    
    
    # read xlsx template
    import pandas as pd
    xlsx_template = pd.read_excel (r'Output_Data_T3.2_CBA.xlsx',sheet_name="Option 1",header=None)
    # add branch inveestment
    # year 2020
    xlsx_template[4][17] = 2020
    xlsx_template[14][17] = 2030
    xlsx_template[24][17] = 2040
    xlsx_template[44][17] = 2050
    
    
    ''' Outpu ods file''' 
    save_data("WP3_CBA_output.ods", ods_template)
    
    
    ''' Outpu json file''' 
    with open('Output_Data_Investment.json', 'w') as fp:
        json.dump(Output_Data_Investment, fp)
    
    return print("Output files created")



# mpc, base_time_series_data,  multiplier = read_input_data("case5")


def get_time_series_data(mpc,  base_time_series_data):
    # prepare base and peak data for optimisation
    peak_hour = 19
    
    base_Pd = {} #24h data
    base_Qd = {}
    
    peak_Pd = []
    peak_Qd = []
    
    base_Pflex_up = {}
    base_Pflex_dn = {}
    
    peak_Pflex_up = []
    peak_Pflex_dn = []
    
    a = 1
    for ib in range(mpc["NoBus"]):
        peak_Pd.append(0)
        peak_Qd.append(0)
        peak_Pflex_up.append(0)
        peak_Pflex_dn.append(0)
        
        if base_time_series_data["Load_P_(MW)"][a][0] == ib+1:
            # Load P and Q
            base_Pd[ib] = base_time_series_data["Load_P_(MW)"][a].copy()
            base_Pd[ib].remove(ib+1)
            
            base_Qd[ib] = base_time_series_data["Load_Q_(Mvar)"][a].copy()
            base_Qd[ib].remove(ib+1)
            
            # Peak load P and Q
            peak_Pd[ib] = base_Pd[ib][peak_hour]
            peak_Qd[ib] = base_Pd[ib][peak_hour]
            
            # PFlex up and down ward
            base_Pflex_up[ib] = base_time_series_data["Upward_flexibility"][a].copy()
            base_Pflex_up[ib].remove(ib+1)
            
            base_Pflex_dn[ib] = base_time_series_data["Downward_flexibility"][a].copy()
            base_Pflex_dn[ib].remove(ib+1)
            
            # Peak Pflex up and down
            peak_Pflex_up[ib] = base_Pflex_up[ib][peak_hour]
            peak_Pflex_dn[ib] = base_Pflex_dn[ib][peak_hour]
            
            a+=1
        else:
            base_Pd[ib] = 0
            base_Qd[ib] = 0
            base_Pflex_up[ib] = 0
            base_Pflex_dn[ib] = 0
            
    
    # get gen status data
    gen_sta = {}
    peak_gen_sta = []
    for ig in range(mpc["NoGen"]):
        gen_sta[ig] = base_time_series_data["Gen_Status"][ig+1].copy()
        del gen_sta[ig][0]
        peak_gen_sta.append( gen_sta[ig][peak_hour])
            
            
    print('read ods data')         
    return (base_Pd , base_Qd ,peak_Pd ,peak_Qd ,base_Pflex_up, base_Pflex_dn , peak_Pflex_up , peak_Pflex_dn, gen_sta, peak_gen_sta)


# base_Pd , base_Qd ,peak_Pd ,peak_Qd ,base_Pflex_up, base_Pflex_dn , peak_Pflex_up , peak_Pflex_dn, gen_sta, peak_gen_sta = get_time_series_data(mpc,  base_time_series_data)
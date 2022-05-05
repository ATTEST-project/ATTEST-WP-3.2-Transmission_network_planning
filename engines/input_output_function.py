# -*- coding: utf-8 -*-
"""
@author: Wangwei Kong

Input and output functions

    Required inputs:
        contingency list
        country name
        test_case name
        time series data
        investment catalogue
        investment unit costs
        
        
    Outputs:
        mpc in json
        load data
        flex data
"""

# from pyexcel_ods import get_data
# from pyexcel_ods import save_data
import json
import os
import pandas as pd
from conversion_model_mat2json import any2json
from scenarios_multipliers import get_mult


def json_directory():
    ''' Directory contain JSON files for pytest '''
    return os.path.join(os.path.dirname(__file__), 'tests', 'json')




def read_input_data(cont_list, country = "HR", test_case = "HR_2020_Location_1",ci_catalogue = "Default", ci_cost ='Default' ):
    
    file_name  = test_case 
    
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
    
    ''' Load xlsx file'''
    # base_time_series_data = get_data("Transmission_Network_PT_2020_24hGenerationLoadData.ods")
    base_time_series_data  = pd.read_excel('tests/excel/Transmission_Network_PT_2020_24hGenerationLoadData.xlsx', sheet_name=None)
    print('load xlsx file')
   
    
    NoCon = len( cont_list)
    
    if ci_catalogue == "Default":
        ci_catalogue = [10,50,100,200,500,800,1000,2000,5000]
    
    if ci_cost == "Default":
        ci_cost = [5 * i for i in ci_catalogue]

    return (mpc,  base_time_series_data,  multiplier, NoCon,ci_catalogue,ci_cost)



                     
def output_data2Json(NoPath, NoYear, path_sce, sum_CO, yearly_CO, ci, sum_ciCost, Cflex, Pflex, outputAll=False,country = "HR", test_case = "HR_2020_Location_1" ):
    
    output_data = {}
    sce_data = {}
    year_num = [2020, 2030, 2040, 2050]
    output_data = { "Country": country, 
                    "Case name": test_case}
    
    # output all the pathways (scenarios)
    if outputAll == True:      
        for xp in range(NoPath):
            sce_data["Total investment cost (EUR)"] = sum_ciCost +  sum(Cflex[xy][path_sce[xp][xy]] for xy in range(NoYear) ),
            sce_data["Net Present Cost (EUR)"] =  sum_CO,
            
            for xy in range(NoYear):
                
                sce_data[str(year_num[xy])] = {
                                        "Operation cost (EUR/year)": yearly_CO[xy][path_sce[xp][xy]], 
                                        "Branch investment (MVA)":  ci[xy][path_sce[xp][xy]], 
                                        "Flexibility investment (MW)": Pflex[xy][path_sce[xp][xy]], 
                                     }
            
            output_data["Scenario " +str(xp+1)] = sce_data
            
    else:
        # only output two extreme scenarios
        temp_xp = 0
        for xp in [0,NoPath-1]:
            
            temp_xp += 1
            sce_data["Total investment cost (EUR)"] = sum_ciCost +  sum(Cflex[xy][path_sce[xp][xy]] for xy in range(NoYear) ),
            sce_data["Net Present Cost (EUR)"] =  sum_CO,
            
            for xy in range(NoYear):
                
                sce_data[str(year_num[xy])] = {
                                        "Operation cost (EUR/year)": yearly_CO[xy][path_sce[xp][xy]], 
                                        "Branch investment (MVA)":  ci[xy][path_sce[xp][xy]], 
                                        "Flexibility investment (MW)": Pflex[xy][path_sce[xp][xy]], 
                                     }
           
            output_data["Scenario " +str(temp_xp)] = sce_data
        
        
    
    # output_data_template = {
    #                             "Country": country, 
    #                             "Case name": test_case,
    #                             "Scenario 1": 
    #                                 {
    #                                     "Total investment cost (EUR)": 0, 
    #                                     "Net Present Cost (EUR)":0,
    #                                     "2020": {"Operation cost (EUR/year)": 0, 
    #                                               "Branch investment (MVA)": [], 
    #                                               "Flexibility investment (MW)": []}, 
    #                                     "2030": {"Operation cost (EUR/year)": 0, 
    #                                               "Branch investment (MVA)": [], 
    #                                               "Flexibility investment (MW)": []}, 
    #                                     "2040": {"Operation cost (EUR/year)": 0, 
    #                                               "Branch investment (MVA)": [], 
    #                                               "Flexibility investment (MW)": []}, 
    #                                     "2050": {"Operation cost (EUR/year)": 0, 
    #                                               "Branch investment (MVA)": [], 
    #                                               "Flexibility investment (MW)": []}, 
    #                                 },
    #                             "Scenario 2": 
    #                                 {
    #                                     "Total investment cost (EUR)": 0, 
    #                                     "Net Present Cost (EUR)":0,
    #                                     "2020": {"Operation cost (EUR/year)": 0, 
    #                                               "Branch investment (MVA)": [], 
    #                                               "Flexibility investment (MW)": []}, 
    #                                     "2030": {"Operation cost (EUR/year)": 0, 
    #                                               "Branch investment (MVA)": [], 
    #                                               "Flexibility investment (MW)": []}, 
    #                                     "2040": {"Operation cost (EUR/year)": 0, 
    #                                               "Branch investment (MVA)": [], 
    #                                               "Flexibility investment (MW)": []}, 
    #                                     "2050": {"Operation cost (EUR/year)": 0, 
    #                                               "Branch investment (MVA)": [], 
    #                                               "Flexibility investment (MW)": []}, 
    #                                 },
    #                         }
        
    # data into template
        
    ''' Output json file''' 
    with open('results/investment_result.json', 'w') as fp:
        json.dump(output_data, fp)
    
    return print("Investment result file created")



# mpc, base_time_series_data,  multiplier = read_input_data("case5")


def get_time_series_data(mpc,  base_time_series_data):
    # prepare base and peak data for optimisation
    peak_hour = 19
    

    load_bus = base_time_series_data["Load P (MW)"]["Bus \ Hour"].values.tolist()
    all_Pd = base_time_series_data["Load P (MW)"].values.tolist()
    all_Qd = base_time_series_data["Load Q (Mvar)"].values.tolist()
    
    base_Pd = [] #24h data
    base_Qd = []
    
    peak_Pd = []
    peak_Qd = []
    
    all_Pflex_up = base_time_series_data["Upward flexibility"].values.tolist()
    all_Pflex_dn = base_time_series_data["Downward flexibility"].values.tolist()

    base_Pflex_up = []
    base_Pflex_dn = []
    
    peak_Pflex_up = []
    peak_Pflex_dn = []
    
    for ib in range(mpc["NoBus"]):
        
        bus_i = mpc['bus']['BUS_I'][ib]
        # find if the bus has load
        load_bus_i = [i for i,x in enumerate(load_bus) if x == bus_i] 
        # record the load        
        if load_bus_i != []:
            # Load P and Q
            temp = all_Pd[load_bus_i[0]].copy()
            temp.pop(0)
            base_Pd.append(temp)
            
            temp = all_Qd[load_bus_i[0]].copy()
            temp.pop(0)
            base_Qd.append(temp)
            
            # Peak load P and Q
            peak_Pd.append(base_Pd[ib][peak_hour])
            peak_Qd.append(base_Pd[ib][peak_hour])
            
            # flex has the same connection of load
            # PFlex up and down ward
            temp = all_Pflex_up[load_bus_i[0]].copy()
            temp.pop(0)
            base_Pflex_up.append(temp)
            
            temp = all_Pflex_dn[load_bus_i[0]].copy()
            temp.pop(0)
            base_Pflex_dn.append(temp)
            
            # Peak Pflex up and down
            peak_Pflex_up.append(base_Pflex_up[ib][peak_hour])
            peak_Pflex_dn.append(base_Pflex_dn[ib][peak_hour])
                      
        # record 0 load
        else:
            temp = [0]*24
            base_Pd.append(temp)
            base_Qd.append(temp)
            base_Pflex_up.append(temp)
            base_Pflex_dn.append(temp)
            
            
            peak_Pd.append(0)
            peak_Qd.append(0)
            
            peak_Pflex_up.append(0)
            peak_Pflex_dn.append(0)
            
           
    print('read laod and flex data')         
    return (base_Pd , base_Qd ,peak_Pd ,peak_Qd ,base_Pflex_up, base_Pflex_dn , peak_Pflex_up , peak_Pflex_dn)





# peak load P for screening model
def get_peak_data(mpc,  base_time_series_data, peak_hour = 19):
       

    load_bus = base_time_series_data["Load P (MW)"]["Bus \ Hour"].values.tolist()
    all_Pd = base_time_series_data["Load P (MW)"].values.tolist()
    
    base_Pd = [] #24h data
    
    peak_Pd = []
    
   
    
    for ib in range(mpc["NoBus"]):
        
        bus_i = mpc['bus']['BUS_I'][ib]
        # find if the bus has load
        load_bus_i = [i for i,x in enumerate(load_bus) if x == bus_i] 
        # record the load        
        if load_bus_i != []:
            # Load P and Q
            temp = all_Pd[load_bus_i[0]].copy()
            temp.pop(0)
            base_Pd.append(temp)
            
           
            # Peak load P and Q
            peak_Pd.append(base_Pd[ib][peak_hour])
            
                      
        # record 0 load
        else:
            temp = [0]*24
            base_Pd.append(temp)
           
            peak_Pd.append(0)
            
        
        
    return peak_Pd



# ''' Main '''
# cont_list = []
# country = "PT" # Select country for case study: "PT", "UK" or "HR"
# test_case = 'Transmission_Network_PT_2020' 
# peak_hour = 19
# ci_catalogue = "Default"
# ci_cost = "Default"
# output_data = 0
# # read input data outputs mpc and load infor
# mpc, base_time_series_data,  multiplier, NoCon,ci_catalogue,ci_cost= read_input_data( cont_list, country,test_case,ci_catalogue,ci_cost)

# # get peak load for screening model
# peak_Pd = get_peak_data(mpc, base_time_series_data, peak_hour)

# # get all load, flex infor for investment model
# base_Pd , base_Qd ,peak_Pd ,peak_Qd ,base_Pflex_up, base_Pflex_dn , peak_Pflex_up , peak_Pflex_dn = get_time_series_data(mpc,  base_time_series_data)

# # save outputs
# output_data(output_data, country, test_case )
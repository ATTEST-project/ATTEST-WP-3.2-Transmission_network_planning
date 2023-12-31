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
from engines.conversion_model_mat2json import any2json
from engines.scenarios_multipliers import get_mult
import numpy as np


def json_directory():
    ''' Directory contain JSON files for pytest '''
    return os.path.join(os.path.dirname(__file__), 'tests', 'json')




def read_input_data(input_dir, ods_file_name, xlsx_file_name,country, test_case ):
    
    file_name  = test_case 
    
    # todo: update json input to exclude dummy generators?
    '''load m file'''
    converter = any2json()
    # # option 1: using file path
    # converter.matpower2json(folder_path=json_directory(), \
    #                         name_matpower=file_name, name_json=file_name)
   
    #  option 2: using abs input directory 
    input_file_folder = os.path.join(input_dir, 'tests','json') # 
    converter.matpower2json(folder_path= input_file_folder, \
                            name_matpower=file_name, name_json=file_name)
    print('.m file converted to json')

    
    # filepath = os.path.join(json_directory(), file_name+'.json')
    filepath = os.path.join(input_file_folder, file_name+'.json')

    ''' Load json file''' 
    # load json file from file directory
    mpc = json.load(open(filepath))
    print('load json file')                             
    
    
    '''Load multipliers for different scnearios'''
    multiplier = get_mult(country) # default to HR
    
    ''' Load xlsx file'''
    xlsx_file =  xlsx_file_name + ".xlsx"
    xlsx_file_path = os.path.join(input_dir, 'tests', 'excel',xlsx_file)
    
    if os.path.exists(xlsx_file_path):
        # Read .ods file
        # base_time_series_data = get_data("Transmission_Network_PT_2020_24hGenerationLoadData.ods")
        
        # read xlsx file
        base_time_series_data  = pd.read_excel(xlsx_file_path, sheet_name=None)
        print('load xlsx file')
    else:
        print(" * Time-series data in .xlsx file not found, using .m file data as peak load")
        base_time_series_data = []
        
   
    ''' Load ods for contingencies file''' 
    # ods_file_name = "case_template_CR_L3"
    ods_file = ods_file_name + ".ods"
    ods_file_path = os.path.join(input_dir, 'SCOPF_R5', 'input_data',ods_file)

    if os.path.exists(ods_file_path):
        cont_ods = pd.read_excel(ods_file_path,sheet_name = "contingencies")
    
        NoCon =  len(cont_ods)
        con_bra = []
        
        for xc in range(NoCon):
           
            fbus = cont_ods["From"][xc]
            tbus = cont_ods["To"][xc]
            
            # find all branch fron the bus
            con_bra_fbus = [index for (index, item) in enumerate(mpc["branch"]["F_BUS"]) if item == fbus]
            con_bra_tbus = [index for (index, item) in enumerate(mpc["branch"]["T_BUS"]) if item == tbus]

            con_bra.append( list(set(con_bra_fbus).intersection(set(con_bra_tbus)))[0] )
        
        
        # create contingecy list
        cont_list = [[1]*mpc["NoBranch"]]     
        
        for xc in range(NoCon):
            
            temp_list = [[1]*mpc["NoBranch"]]  
            
            temp_list[0][con_bra[xc]] = 0
            
            cont_list.extend(temp_list)
        
        
    else:
        print(" * Contingency data not found, using N-1 for simulation")
        # generate N-1 contingencies
        
        cont_list = [[1]*mpc["NoBranch"]] 
        temp_list = (cont_list[0]-np.diag(cont_list[0]) ).tolist()
        
        cont_list.extend(temp_list)
        NoCon =  len(cont_list)
    
    
    
    ''' Load intervention infor''' 
    # set default line investment data, linear cost of 20£/MVA
    default_line_list = [50,100,150,200,250,300,500,1000,1500,2000,3000,5000,100000, 150000,500000]
    default_line_cost = [1000*10 * i for i in default_line_list]

    # set default transformer investment data, linear cost of 30£/MVA
    default_trans_list = [140, 280, 450, 800,2000,5000,100000]
    default_trans_cost = [9903 * i for i in default_trans_list] 
    
    intv_file = "intervention.json.ods"
    ods_file_path = os.path.join(input_dir, 'tests', 'json',intv_file)
    if os.path.exists(ods_file_path):
        file = open(ods_file_path)
        intv = json.load(file)
        file.close()
        
        print("Reading intervention lists and costs data")
        ci_catalogue = []
        ci_catalogue.append( intv["line_list"] )
        ci_catalogue.append( intv["transformer_list"])
        
        ci_cost = []
        ci_cost.append( intv["line_cost"] )
        ci_cost.append( intv["transformer_cost"] )
        
        # TODO: update intervention inputs for different countries?
        # check input data
        if len(ci_catalogue[0]) != len(ci_cost[0]):
            print("Sizes of input line investment data don't match, default values are used")
            
            ci_catalogue[0] = default_line_list
            ci_cost[0] = default_line_cost
        
        if len(ci_catalogue[1]) != len(ci_cost[1]):
            print("Sizes of input transformer investment data don't match, default values are used")
            
            ci_catalogue[1] = default_trans_list
            ci_cost[1] = default_trans_cost
        
        
    else:
        print(" * Intervention data in .json file not found, using default data")


        ci_catalogue = []
        ci_cost = []
        # lines
        ci_catalogue.append(default_line_list)
        ci_cost.append( default_line_cost )
        # transformers
        ci_catalogue.append(default_trans_list)
        ci_cost.append( default_trans_cost)
        
        

    return (mpc,  base_time_series_data,  multiplier, NoCon,cont_list,ci_catalogue,ci_cost)




def read_screenModel_output(output_dir,country, mpc,test_case, ci_catalogue,intv_cost,cost_base):
    
    # reading outputs from the screening model of the reduced intervention list
    screen_file_name = "screen_result_" + country + "_" + test_case + ".json"
    
    screen_file_path = os.path.join(output_dir, screen_file_name)
    

    
    if os.path.exists(screen_file_path ):

               
        S_ci = json.load(open(screen_file_path))
        
        print("Load screening results")
    else:
        print(" * screening results not found. Using predefined intervetion lists, this will cause longer computing time. ")
        S_ci = ci_catalogue[0]
        # expand catalogue for each branch
        S_ci  = {str(k): ci_catalogue[0] for k in range(mpc["NoBranch"])}
        
        for xbr in range(mpc["NoBranch"]):
            if mpc["branch"]["TAP"][xbr] != 0:  # transformer
                S_ci[str(xbr)] = ci_catalogue[1]
        
        
        


    # if not specified, using a linear cost
    ci_cost = {k: [] for k in range(mpc["NoBranch"])}
    
    if mpc["branch"]["length(km)"] != []:
        line_len = mpc["branch"]["length(km)"].copy()
    else:
        # if no branch length data, igore length impacts on investment costs
        line_len = [1]*mpc["NoBranch"]
          
    for xbr in range(mpc["NoBranch"]):
        
        if S_ci[str(xbr)] != []:

            for xci in range(len(S_ci[str(xbr)])):
                
                if mpc["branch"]["TAP"][xbr] == 0:  # line
                    temp = [i for i,x in enumerate(ci_catalogue[0]) if x==S_ci[str(xbr)][xci]]
                    ci_cost[xbr].append( intv_cost[0][temp[0]] * line_len[xbr]/cost_base ) # record intervention cost over base cost value

                    
                else: # transformer
                    temp = [i for i,x in enumerate(ci_catalogue[1]) if x==S_ci[str(xbr)][xci]]
                    ci_cost[xbr].append( intv_cost[1][temp[0]] /cost_base)



    return S_ci, ci_cost


                     
def output_data2Json(output_dir, NoPath, NoYear, path_sce, sum_CO, yearly_CO, ci, ciCost, Cflex, Pflex, outputAll=False,country = "HR", test_case = "HR_2020_Location_1" , pt = "_pt1"):
    
    output_data = {}
    # sce_data = {}
    year_num = [2020, 2030, 2040, 2050]
    output_data = { "Country": country, 
                    "Case name": test_case}
    
    if sum_CO == 0: # part 1 output without operation cost
    
        # output all the pathways (scenarios)
        if outputAll == True:      
            for xp in range(NoPath):
                sce_data = {}
                sce_data["Total investment cost (EUR-million)"] = sum(ciCost[xy][path_sce[xp][xy]] + Cflex[xy][path_sce[xp][xy]] for xy in range(NoYear) )
                sce_data["Branch investment cost (EUR-million)"] = sum(ciCost[xy][path_sce[xp][xy]]  for xy in range(NoYear) )
                sce_data["Flexibility investment cost (EUR-million)"] =  sum(Cflex[xy][path_sce[xp][xy]] for xy in range(NoYear) )
                sce_data["Total Operation Cost (EUR-million)"] =  0
                
                for xy in range(NoYear):
                    
                    Pflex[xy][path_sce[xp][xy]] =  [0 if abs(x)<=1e-4 else x for x in Pflex[xy][path_sce[xp][xy]]]
                    
                    sce_data[str(year_num[xy])] = {
                                            "Operation cost (EUR-million/year)": 0, 
                                            "Branch investment (MVA)":  ci[xy][path_sce[xp][xy]], 
                                            "Flexibility investment (MW)": Pflex[xy][path_sce[xp][xy]], 
                                         }
                
                output_data["Scenario " +str(xp+1)] = sce_data
                
        else:
            # only output two extreme scenarios
            temp_xp = 0
            for xp in [0,NoPath-1]:
                
                temp_xp += 1
                sce_data = {}
                sce_data["Total investment cost (EUR-million)"] = sum(ciCost[xy][path_sce[xp][xy]] + Cflex[xy][path_sce[xp][xy]] for xy in range(NoYear) )
                sce_data["Branch investment cost (EUR-million)"] = sum(ciCost[xy][path_sce[xp][xy]]  for xy in range(NoYear) )
                sce_data["Flexibility investment cost (EUR-million)"] =  sum(Cflex[xy][path_sce[xp][xy]] for xy in range(NoYear) )
                sce_data["Net Present Operation Cost (EUR-million)"] =  0
                
                for xy in range(NoYear):
                    
                    Pflex[xy][path_sce[xp][xy]] =  [0 if abs(x)<=1e-4 else x for x in Pflex[xy][path_sce[xp][xy]]]
                        
                    sce_data[str(year_num[xy])] = {
                                            "Operation cost (EUR-million/year)": 0, 
                                            "Branch investment (MVA)":  ci[xy][path_sce[xp][xy]], 
                                            "Flexibility investment (MW)": Pflex[xy][path_sce[xp][xy]], 
                                         }
                    
                       
                    
             
                output_data["Scenario " +str(temp_xp)] = sce_data
    
            
    else: # part 2 output with operation cost
        
        # output all the pathways (scenarios)
        if outputAll == True:      
            for xp in range(NoPath):
                sce_data = {}
                sce_data["Total investment cost (EUR-million)"] = sum(ciCost[xy][path_sce[xp][xy]] + Cflex[xy][path_sce[xp][xy]] for xy in range(NoYear) )
                sce_data["Branch investment cost (EUR-million)"] = sum(ciCost[xy][path_sce[xp][xy]]  for xy in range(NoYear) )
                sce_data["Flexibility investment cost (EUR-million)"] =  sum(Cflex[xy][path_sce[xp][xy]] for xy in range(NoYear) )
                sce_data["Total Operation Cost (EUR-million)"] =  sum_CO
                
                for xy in range(NoYear):
                    
                    Pflex[xy][path_sce[xp][xy]] =  [0 if abs(x)<=1e-4 else x for x in Pflex[xy][path_sce[xp][xy]]]
                    
                    sce_data[str(year_num[xy])] = {
                                            "Operation cost (EUR-million/year)": yearly_CO[xy][path_sce[xp][xy]], 
                                            "Branch investment (MVA)":  ci[xy][path_sce[xp][xy]], 
                                            "Flexibility investment (MW)": Pflex[xy][path_sce[xp][xy]], 
                                         }
                
                output_data["Scenario " +str(xp+1)] = sce_data
                
        else:
            # only output two extreme scenarios
            temp_xp = 0
            for xp in [0,NoPath-1]:
                
                temp_xp += 1
                sce_data = {}
                sce_data["Total investment cost (EUR-million)"] = sum(ciCost[xy][path_sce[xp][xy]] + Cflex[xy][path_sce[xp][xy]] for xy in range(NoYear) )
                sce_data["Branch investment cost (EUR-million)"] = sum(ciCost[xy][path_sce[xp][xy]]  for xy in range(NoYear) )
                sce_data["Flexibility investment cost (EUR-million)"] =  sum(Cflex[xy][path_sce[xp][xy]] for xy in range(NoYear) )
                sce_data["Net Present Operation Cost (EUR-million)"] =  sum_CO
                
                for xy in range(NoYear):
                    
                    Pflex[xy][path_sce[xp][xy]] =  [0 if abs(x)<=1e-4 else x for x in Pflex[xy][path_sce[xp][xy]]]
                     
                    sce_data[str(year_num[xy])] = {
                                            "Operation cost (EUR-million/year)": yearly_CO[xy][path_sce[xp][xy]], 
                                            "Branch investment (MVA)":  ci[xy][path_sce[xp][xy]], 
                                            "Flexibility investment (MW)": Pflex[xy][path_sce[xp][xy]], 
                                         }
                    
                       
                    
             
                output_data["Scenario " +str(temp_xp)] = sce_data
           
        
        
    file_name = "investment_result_" + country + "_" + test_case + pt +'.json'
    file_path = os.path.join(output_dir, file_name)
        
    ''' Output json file''' 
    with open(file_path , 'w') as fp:
        json.dump(output_data, fp)
    
    return print("Investment result file created")






def get_time_series_data(mpc,  base_time_series_data, peak_hour = 19):
    # prepare base and peak data for optimisation
    # default_flex = 50
    
    # Define default flex percentage
    default_flex_percent = 0.1
    
    peak_hour -= 1 
    
    if base_time_series_data != []:

        load_bus = base_time_series_data["Load P (MW)"]["Bus \ Hour"].values.tolist()
        all_Pd = base_time_series_data["Load P (MW)"].values.tolist()
        all_Qd = base_time_series_data["Load Q (Mvar)"].values.tolist()
        
        base_Pd = [] #24h data
        base_Qd = []
        
        peak_Pd = []
        peak_Qd = []
        
        try:
            all_Pflex_up = base_time_series_data["Upward flexibility"].values.tolist()
            all_Pflex_dn = base_time_series_data["Downward flexibility"].values.tolist()
            
        except KeyError:
            print(" * flexibiltiy data not found in the input file, using default data: 10% of peak load as flexibility upwarad and 10% of peak load as donwward to each load bus")
            
            all_Pflex_up = []
            all_Pflex_dn = []
    
        base_Pflex_up = []
        base_Pflex_dn = []
        
        peak_Pflex_up = [] # Pflex_max in optimisation
        peak_Pflex_dn = [] # -Pflex_max in optimisation
        
        # No input data for Q flex from current data set
        peak_Qflex_up = None
        peak_Qflex_dn = None
        
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
                
                
                default_flex = peak_Pd[ib] * default_flex_percent
                
                # flex has the same connection of load
                # PFlex up and down ward
                if all_Pflex_up == [] or all_Pflex_dn == [] :
                   
                    # use default data 10MW to each load bus
                    base_Pflex_up.append(default_flex)
                    base_Pflex_dn.append(default_flex)
                    
                    peak_Pflex_up.append(default_flex)
                    peak_Pflex_dn.append(default_flex)
                    
                    
                else:
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
    
    else:
        # assume mpc data are peak data
        
        base_Pd, base_Qd ,peak_Pd ,peak_Qd, base_Pflex_up, base_Pflex_dn = ([] for i in range(6))

        load_bus = [i for i, e in enumerate(mpc["bus"]["PD"]) if e != 0]
        
        peak_Pflex_up = [] # Pflex_max in optimisation
        peak_Pflex_dn = [] # -Pflex_max in optimisation
        
        # No input data for Q flex from current data set
        peak_Qflex_up = None
        peak_Qflex_dn = None
        
        print(" * flexibiltiy data not found in the input file, using default data: 10% of peak load as flexibility upwarad and 10% of peak load as donwward to each load bus")
        
        for ib in range(mpc["NoBus"]):
            
        
            # record the load        
            if mpc["bus"]["PD"][ib] != 0:
                
                # Peak load P and Q
                peak_Pd.append(mpc["bus"]["PD"][ib])
                peak_Qd.append(mpc["bus"]["QD"][ib])
                
                default_flex = peak_Pd[ib] * 0.1
                                   
                peak_Pflex_up.append(default_flex)
                peak_Pflex_dn.append(default_flex)
                    
                          
            # record 0 load
            else:
                       
                peak_Pd.append(0)
                peak_Qd.append(0)
                
                peak_Pflex_up.append(0)
                peak_Pflex_dn.append(0)
            
           
    print('read load and flex data')         
    return (base_Pd , base_Qd ,peak_Pd ,peak_Qd ,base_Pflex_up, base_Pflex_dn , peak_Pflex_up , peak_Pflex_dn,peak_Qflex_up , peak_Qflex_dn,load_bus)





# peak load P for screening model
def get_peak_data(mpc,  base_time_series_data, peak_hour = 19):
    
    peak_hour -=1 # peak hour range in python = [0, 23], hour range in xlsx = [1-24]
    
    if base_time_series_data != []:
       

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
    
    else:
        
        peak_Pd = []

    # print('peak_Pd:')
    # print(peak_Pd)
        
    return peak_Pd






# # read WP5 outputs of useful life
# def read_asset_life():
#     useful_life = pd.read_csv('tests/csv/mpc_useful_life.csv')
    
    
#     return useful_life




    
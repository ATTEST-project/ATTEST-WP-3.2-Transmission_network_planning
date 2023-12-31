
# git synchronization check by Andrey

# git synchronization check by Andrey

import click
import json
import os

import time

# This can be removed if a setup file is created
# import julia
# julia.install()


from engines.screening_model import run_main_screening 
from engines.investment_model import run_main_investment

# start = time.time()

@click.group() # Create a group of commands that call different functions from the planning tools
def cli():
    pass


cli_file_path = os.path.abspath(os.path.dirname(__file__))
inputDir = os.path.join(cli_file_path, 'engines') 
outputDir = os.path.join(cli_file_path, 'engines', 'results')



@click.command(help='Run the screening model') 
@click.option('--input_dir',                 prompt='input directory:',   default=inputDir,                     help='Specify the directory for input data')
@click.option('--output_dir',                prompt='output directory:',   default=outputDir,                    help='Specify the directory for output data')
@click.option('--country',                   prompt='country name:',      default='HR',                         help='Specify the country:"PT", "HR", or "UK"')
@click.option('--test_case',                 prompt='test case name:',    default='HR_Location3',                      help='Specify the test_case without ".m". ')
@click.option('--xlsx_file_name',            prompt='time-series data:',  default='Location3_Zagreb',                           help='Specify the xlsx_file_name without ".xlsx". ')
@click.option('--ods_file_name',             prompt='contingency data:',  default='HR_Tx_03_2020_new_Zagreb_PROF_update',      help='Specify the ods_file_name without ".ods". ')
@click.option('--peak_hour',                 prompt='peak_hour:',         default= 19,                          help='Specify the number between 1 and 24, i.e., 19 for 7 p.m. ')
@click.option('--no_year',                   prompt='Number of years:',   default= 4,                           help='Specify the number of years: 1 - [2020], 2 - [2020,2030], 3 - [2020,2030,2040], 4 - [2020,2030,2040,2050]')
@click.option('--add_load_data',
              prompt='Include data from EV-PV-Storage_Data_for_Simulations.xlsx:',
              default=0,
              help='Use additional ATTEST data for EV, PV and storage (EV-PV-Storage_Data_for_Simulations.xlsx). ' +
              'By default: 0 (False). If 1 (True), additional EV data will be added for each bus per each year and scenario.')
@click.option('--add_load_data_case_name',
              prompt='Data sheet name in EV-PV-Storage_Data_for_Simulations.xlsx:',
              default='UK_Tx_',
              help='Name of the case for which the addiational load data should be included. ' +
              'This name must be in the Excel sheet format to navigate in the file EV-PV-Storage_Data_for_Simulations.xlsx. ' +
              'By default: UK_Tx_ ')

def run_screening(input_dir, output_dir,ods_file_name, xlsx_file_name, country, test_case, peak_hour,no_year,add_load_data,add_load_data_case_name): 
    print(" --------- Running the screening model --------- ")

    run_main_screening(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour,no_year,add_load_data,add_load_data_case_name)




@click.command(help='Run the investment model') 
@click.option('--input_dir',                 prompt='input directory:',   default=inputDir,                     help='Specify the directory for input data')
@click.option('--output_dir',                prompt='output directory:',   default=outputDir,                    help='Specify the directory for output data')
@click.option('--country',                   prompt='country name:',      default='HR',                         help='Specify the country:"PT", "HR", or "UK"')
@click.option('--test_case',                 prompt='test case name:',    default='HR_Location3',                      help='Specify the test_case without ".m". ')
@click.option('--xlsx_file_name',            prompt='time-series data:',  default='Location3_Zagreb',                           help='Specify the xlsx_file_name without ".xlsx". ')
@click.option('--ods_file_name',             prompt='contingency data:',  default='HR_Tx_03_2020_new_Zagreb_PROF_update',      help='Specify the ods_file_name without ".ods". ')
@click.option('--peak_hour',                 prompt='peak_hour:',         default= 19,                          help='Specify the number between 1 and 24, i.e., 19 for 7 p.m. ')
@click.option('--no_year',                   prompt='Number of years:',   default= 4,                           help='Specify the number of years: 1 - [2020], 2 - [2020,2030], 3 - [2020,2030,2040], 4 - [2020,2030,2040,2050]')
@click.option('--run_both',                   prompt='Run both parts:',    default= True,                        help='Define investment setting, True = [considering both investment cost and operation cost], False = [considering investment cost only]')
@click.option('--add_load_data',
              prompt='Include data from EV-PV-Storage_Data_for_Simulations.xlsx:',
              default=0,
              help='Use additional ATTEST data for EV, PV and storage (EV-PV-Storage_Data_for_Simulations.xlsx). ' +
              'By default: 0 (False). If 1 (True), additional EV data will be added for each bus per each year and scenario.')
@click.option('--add_load_data_case_name',
              prompt='Data sheet name in EV-PV-Storage_Data_for_Simulations.xlsx:',
              default='UK_Tx_',
              help='Name of the case for which the addiational load data should be included. ' +
              'This name must be in the Excel sheet format to navigate in the file EV-PV-Storage_Data_for_Simulations.xlsx. ' +
              'By default: UK_Tx_ ')

def run_investment(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year,run_both,add_load_data,add_load_data_case_name):
    print(" --------- Running the investment model --------- ")
    
    run_main_investment(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year,run_all) 




@click.command(help='Run all models') 
@click.option('--input_dir',                 prompt='input directory:',   default=inputDir,                     help='Specify the directory for input data')
@click.option('--output_dir',                prompt='output directory:',   default=outputDir,                    help='Specify the directory for output data')
@click.option('--country',                   prompt='country name:',      default='UK',                         help='Specify the country:"PT", "HR", or "UK"')
@click.option('--test_case',                 prompt='test case name:',    default='case5',                      help='Specify the test_case without ".m". ')
@click.option('--xlsx_file_name',            prompt='time-series data:',  default='',                           help='Specify the xlsx_file_name without ".xlsx". ')
@click.option('--ods_file_name',             prompt='contingency data:',  default='case5_bus_python_test',      help='Specify the ods_file_name without ".ods". ')
@click.option('--peak_hour',                 prompt='peak_hour:',         default= 19,                          help='Specify the number between 1 and 24, i.e., 19 for 7 p.m. ')
@click.option('--no_year',                   prompt='Number of years:',   default= 4,                           help='Specify the number of years: 1 - [2020], 2 - [2020,2030], 3 - [2020,2030,2040], 4 - [2020,2030,2040,2050]')
@click.option('--run_both',                   prompt='Run both parts:',    default= True,                        help='Define investment setting, True = [considering both investment cost and operation cost], False = [considering investment cost only]')
@click.option('--add_load_data',
              prompt='Include data from EV-PV-Storage_Data_for_Simulations.xlsx:',
              default=0,
              help='Use additional ATTEST data for EV, PV and storage (EV-PV-Storage_Data_for_Simulations.xlsx). ' +
              'By default: 0 (False). If 1 (True), additional EV data will be added for each bus per each year and scenario.')
@click.option('--add_load_data_case_name',
              prompt='Data sheet name in EV-PV-Storage_Data_for_Simulations.xlsx:',
              default='UK_Tx_',
              help='Name of the case for which the addiational load data should be included. ' +
              'This name must be in the Excel sheet format to navigate in the file EV-PV-Storage_Data_for_Simulations.xlsx. ' +
              'By default: UK_Tx_ ')

def run_all(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year, run_both, add_load_data, add_load_data_case_name):
    print(" --------- Running all models --------- ")
    
    print(" --------- Running the screening model --------- ")
    run_main_screening(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year, add_load_data, add_load_data_case_name)
    
    print(" --------- Running the investment model --------- ")
    run_main_investment(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year, run_all, add_load_data, add_load_data_case_name) 
    



@click.command(help='Run 5-bus test') 
@click.option('--input_dir',                 prompt='input directory:',   default=inputDir,                     help='Specify the directory for input data')
@click.option('--output_dir',                prompt='output directory:',   default=outputDir,                    help='Specify the directory for output data')
@click.option('--country',                   prompt='country name:',      default='UK',                         help='Specify the country:"PT", "HR", or "UK"')
@click.option('--test_case',                 prompt='test case name:',    default='case5',                      help='Specify the test_case without ".m". ')
@click.option('--xlsx_file_name',            prompt='time-series data:',  default='',                           help='Specify the xlsx_file_name without ".xlsx". ')
@click.option('--ods_file_name',             prompt='contingency data:',  default='case5_bus_python_test',      help='Specify the ods_file_name without ".ods". ')
@click.option('--peak_hour',                 prompt='peak_hour:',         default= 19,                          help='Specify the number between 1 and 24, i.e., 19 for 7 p.m. ')
@click.option('--no_year',                   prompt='Number of years:',   default= 4,                           help='Specify the number of years: 1 - [2020], 2 - [2020,2030], 3 - [2020,2030,2040], 4 - [2020,2030,2040,2050]')
@click.option('--run_both',                   prompt='Run both parts:',    default= True,                        help='Define investment setting, True = [considering both investment cost and operation cost], False = [considering investment cost only]')
@click.option('--add_load_data',
              prompt='Include data from EV-PV-Storage_Data_for_Simulations.xlsx:',
              default=0,
              help='Use additional ATTEST data for EV, PV and storage (EV-PV-Storage_Data_for_Simulations.xlsx). ' +
              'By default: 0 (False). If 1 (True), additional EV data will be added for each bus per each year and scenario.')
@click.option('--add_load_data_case_name',
              prompt='Data sheet name in EV-PV-Storage_Data_for_Simulations.xlsx:',
              default='UK_Tx_',
              help='Name of the case for which the addiational load data should be included. ' +
              'This name must be in the Excel sheet format to navigate in the file EV-PV-Storage_Data_for_Simulations.xlsx. ' +
              'By default: UK_Tx_ ')

def run_test(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year,run_both,add_load_data, add_load_data_case_name):
    
    print(" --------- Running the screening model --------- ")
    run_main_screening(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year,add_load_data, add_load_data_case_name)
    
    print(" --------- Running the investment model --------- ")
    
    run_main_investment(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year,run_all,add_load_data, add_load_data_case_name) 



# @click.command(help='Run PT-2020 test') 
# @click.option('--input_dir',                 prompt='input directory:',   default=inputDir,                     help='Specify the directory for input data')
# @click.option('--output_dir',                prompt='output directory:',   default=outputDir,                    help='Specify the directory for output data')
# @click.option('--country',                   prompt='country name:',      default='PT',                         help='Specify the country:"PT", "HR", or "UK"')
# @click.option('--test_case',                 prompt='test case name:',    default='Transmission_Network_PT_2020_ods',                      help='Specify the test_case without ".m". ')
# @click.option('--xlsx_file_name',            prompt='time-series data:',  default='Transmission_Network_PT_2020_24hGenerationLoadData',                           help='Specify the xlsx_file_name without ".xlsx". ')
# @click.option('--ods_file_name',             prompt='contingency data:',  default='case_template_port_modified_R1',      help='Specify the ods_file_name without ".ods". ')
# @click.option('--peak_hour',                 prompt='peak_hour:',         default= 19,                          help='Specify the number between 1 and 24, i.e., 19 for 7 p.m. ')
# @click.option('--no_year',                   prompt='Number of years:',   default= 4,                           help='Specify the number of years: 1 - [2020], 2 - [2020,2030], 3 - [2020,2030,2040], 4 - [2020,2030,2040,2050]')
# @click.option('--run_both',                   prompt='Run both parts:',    default= True,                        help='Define investment setting, True = [considering both investment cost and operation cost], False = [considering investment cost only]')

# def run_pt2020(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year,run_both):
    
#     print(" --------- Running the screening model --------- ")
#     run_main_screening(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year)
    
#     print(" --------- Running the investment model --------- ")
    
#     run_main_investment(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year,run_all) 


# @click.command(help='Run Old version HR test') 
# @click.option('--input_dir',                 prompt='input directory:',   default=inputDir,                     help='Specify the directory for input data')
# @click.option('--output_dir',                prompt='output directory:',   default=outputDir,                    help='Specify the directory for output data')
# @click.option('--country',                   prompt='country name:',      default='HR',                         help='Specify the country:"PT", "HR", or "UK"')
# @click.option('--test_case',                 prompt='test case name:',    default='HR_Location3',                      help='Specify the test_case without ".m". ')
# @click.option('--xlsx_file_name',            prompt='time-series data:',  default='',                           help='Specify the xlsx_file_name without ".xlsx". ')
# @click.option('--ods_file_name',             prompt='contingency data:',  default='HR_Tx_03_2020_new_Zagreb_PROF_update_v2',      help='Specify the ods_file_name without ".ods". ')
# @click.option('--peak_hour',                 prompt='peak_hour:',         default= 19,                          help='Specify the number between 1 and 24, i.e., 19 for 7 p.m. ')
# @click.option('--no_year',                   prompt='Number of years:',   default= 4,                           help='Specify the number of years: 1 - [2020], 2 - [2020,2030], 3 - [2020,2030,2040], 4 - [2020,2030,2040,2050]')
# @click.option('--run_both',                   prompt='Run both parts:',    default= True,                        help='Define investment setting, True = [considering both investment cost and operation cost], False = [considering investment cost only]')

# def run_hr3(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year,run_both):
    
#     print(" --------- Running the screening model --------- ")
#     run_main_screening(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year)
    
#     print(" --------- Running the investment model --------- ")
    
#     run_main_investment(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year,run_all) 



@click.command(help='Run UK test') 
@click.option('--input_dir',                 prompt='input directory:',   default=inputDir,                     help='Specify the directory for input data')
@click.option('--output_dir',                prompt='output directory:',   default=outputDir,                    help='Specify the directory for output data')
@click.option('--country',                   prompt='country name:',      default='UK',                         help='Specify the country:"PT", "HR", or "UK"')
@click.option('--test_case',                 prompt='test case name:',    default='Transmission_Network_UK_v3',                      help='Specify the test_case without ".m". ')
@click.option('--xlsx_file_name',            prompt='time-series data:',  default='',                           help='Specify the xlsx_file_name without ".xlsx". ')
@click.option('--ods_file_name',             prompt='contingency data:',  default='Transmission_Network_UK_v3_PROF_update',      help='Specify the ods_file_name without ".ods". ')
@click.option('--peak_hour',                 prompt='peak_hour:',         default= 19,                          help='Specify the number between 1 and 24, i.e., 19 for 7 p.m. ')
@click.option('--no_year',                   prompt='Number of years:',   default= 4,                           help='Specify the number of years: 1 - [2020], 2 - [2020,2030], 3 - [2020,2030,2040], 4 - [2020,2030,2040,2050]')
@click.option('--run_both',                   prompt='Run both parts:',    default= True,                        help='Define investment setting, True = [considering both investment cost and operation cost], False = [considering investment cost only]')
@click.option('--add_load_data',
              prompt='Include data from EV-PV-Storage_Data_for_Simulations.xlsx:',
              default=0,
              help='Use additional ATTEST data for EV, PV and storage (EV-PV-Storage_Data_for_Simulations.xlsx). ' +
              'By default: 0 (False). If 1 (True), additional EV data will be added for each bus per each year and scenario.')
@click.option('--add_load_data_case_name',
              prompt='Data sheet name in EV-PV-Storage_Data_for_Simulations.xlsx:',
              default='UK_Tx_',
              help='Name of the case for which the addiational load data should be included. ' +
              'This name must be in the Excel sheet format to navigate in the file EV-PV-Storage_Data_for_Simulations.xlsx. ' +
              'By default: UK_Tx_ ')

def run_uk_v3(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year,run_both,add_load_data, add_load_data_case_name):
    # uk_2020 is with dummy generators
    # uk_v2 is without dummy generators
    # print(" --------- Running the screening model --------- ")
    # run_main_screening(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year)
    
    print(" --------- Running the investment model --------- ")
    
    run_main_investment(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year,run_all,add_load_data, add_load_data_case_name) 

cli.add_command(run_all)
cli.add_command(run_screening)
cli.add_command(run_investment)

# Functions for different test cases, these can be removed for final submission
cli.add_command(run_test)
# cli.add_command(run_pt2020)
# cli.add_command(run_hr3)
cli.add_command(run_uk_v3)

if __name__ == '__main__':
    cli()



# end = time.time()

# print(end - start)

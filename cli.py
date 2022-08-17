# This is a preliminary version of the CLI for ATTEST transmission planning tools

import click
import json
import os


from engines.screening_model import run_main_screening 
from engines.investment_model import run_main_investment


@click.group() # Create a group of commands that call different functions from the planning tools
def cli():
    pass


cli_file_path = os.path.abspath(os.path.dirname(__file__))
inputDir = os.path.join(cli_file_path, 'engines') 
outputDir = os.path.join(cli_file_path, 'engines', 'results')


# TODO: Add default files names
@click.command(help='Run the screening model') 
@click.option('--input_dir',                 prompt='input directory:',   default=inputDir,                     help='Specify the directory for input data')
@click.option('--output_dir',                prompt='output directory:',   default=outputDir,                    help='Specify the directory for output data')
@click.option('--country',                   prompt='country name:',      default='HR',                         help='Specify the country:"PT", "HR", or "UK"')
@click.option('--test_case',                 prompt='test case name:',    default='HR_Location3',                      help='Specify the test_case without ".m". ')
@click.option('--xlsx_file_name',            prompt='time-series data:',  default='Location3_Zagreb',                           help='Specify the xlsx_file_name without ".xlsx". ')
@click.option('--ods_file_name',             prompt='contingency data:',  default='HR_L3_new',      help='Specify the ods_file_name without ".ods". ')
@click.option('--peak_hour',                 prompt='peak_hour:',         default= 19,                          help='Specify the number between 1 and 24, i.e., 19 for 7 p.m. ')
@click.option('--no_year',                   prompt='Number of years:',   default= 4,                           help='Specify the number of years: 1 - [2020], 2 - [2020,2030], 3 - [2020,2030,2040], 4 - [2020,2030,2040,2050]')

def run_screening(input_dir, output_dir,ods_file_name, xlsx_file_name, country, test_case, peak_hour,no_year): 
    print(" --------- Running the screening model --------- ")

    run_main_screening(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour,no_year)




@click.command(help='Run the investment model') 
@click.option('--input_dir',                 prompt='input directory:',   default=inputDir,                     help='Specify the directory for input data')
@click.option('--output_dir',                prompt='output directory:',   default=outputDir,                    help='Specify the directory for output data')
@click.option('--country',                   prompt='country name:',      default='HR',                         help='Specify the country:"PT", "HR", or "UK"')
@click.option('--test_case',                 prompt='test case name:',    default='HR_Location3',                      help='Specify the test_case without ".m". ')
@click.option('--xlsx_file_name',            prompt='time-series data:',  default='Location3_Zagreb',                           help='Specify the xlsx_file_name without ".xlsx". ')
@click.option('--ods_file_name',             prompt='contingency data:',  default='HR_L3_new',      help='Specify the ods_file_name without ".ods". ')
@click.option('--peak_hour',                 prompt='peak_hour:',         default= 19,                          help='Specify the number between 1 and 24, i.e., 19 for 7 p.m. ')
@click.option('--no_year',                   prompt='Number of years:',   default= 4,                           help='Specify the number of years: 1 - [2020], 2 - [2020,2030], 3 - [2020,2030,2040], 4 - [2020,2030,2040,2050]')
@click.option('--run_both',                   prompt='Run both parts:',    default= True,                        help='Define investment setting, True = [considering both investment cost and operation cost], False = [considering investment cost only]')

def run_investment(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year,run_both):
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

def run_all(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year,run_both):
    print(" --------- Running all models --------- ")
    
    print(" --------- Running the screening model --------- ")
    run_main_screening(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year)
    
    print(" --------- Running the investment model --------- ")
    run_main_investment(input_dir, output_dir, ods_file_name, xlsx_file_name, country, test_case, peak_hour, no_year,run_all) 
    








# # .... just the investment model...

cli.add_command(run_all)
cli.add_command(run_screening)
cli.add_command(run_investment)


if __name__ == '__main__':
    cli()



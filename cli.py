# This is a preliminary version of the CLI for ATTEST transmission planning tools

import click
import json


from engines.screening_model import main_screening # we need to revisit the scripts to define the required functions
from engines.investment_model import main_investment_pt1
from engines.investment_model import main_investment_all


@click.group() # Create a group of commands that call different functions from the planning tools
def cli():
    pass

inputDir = 
outputDir =
    

@click.command(help='Run the screening model') # i.e., read data --> run the screening model --> save the output
# TODO: Add default files names
@click.option('--ods_file_name',default=' ',help='Specify the ods_file_name witout ".ods". ')
@click.option('--xlsx_file_name',default=' ',help='Specify the xlsx_file_name witout ".xlsx". ')
@click.option('--test_case',default=' ',help='Specify the test_case witout ".m". ')
@click.option('--country',default='UK',help='Specify the country:"PT", "HR", or "UK"')
@click.option('--peak_hour',default='19',help='Specify the peak hour, i.e., 19 for 7 p.m. ')


def run_screening(ods_file_name, xlsx_file_name, country, test_case, peak_hour): 
    print("Running the screening model ...")
   

    run_main_screening(ods_file_name, xlsx_file_name, country, test_case, peak_hour)

    

@click.command(help='Run the investment model') # i.e., read data --> run the investment model --> save the output
@click.command(help='Run the screening model') # i.e., read data --> run the screening model --> save the output
# TODO: Add default files names
@click.option('--ods_file_name',default=' ',help='Specify the ods_file_name witout ".ods". ')
@click.option('--xlsx_file_name',default=' ',help='Specify the xlsx_file_name witout ".xlsx". ')
@click.option('--test_case',default=' ',help='Specify the test_case witout ".m". ')
@click.option('--country',default='UK',help='Specify the country:"PT", "HR", or "UK"')
@click.option('--peak_hour',default='19',help='Specify the peak hour, i.e., 19 for 7 p.m. ')
@click.option('--NoYear',default='4',help='Specify the number of years: 1 - [2020], 2 - [2020,2030], 3 - [2020,2030,2040], 4 - [2020,2030,2040,2050]')
def run_investment_pt1(country,years):
    print("Running the investment model ...")
    

    main_investment_pt1() 

    

@click.command(help='Run the investment model') # i.e., read data --> run the investment model --> save the output


def run_investment_all(country,years):
    print("Running the investment model ...")
    

    main_investment_all() 



@click.command(help='Run the entire TEP toolbox') # i.e., read data --> run the screening model --> iteratively run the investment and operation models --> save the output


def run_all(country,years):
    print("Running the entire TEP toolbox ...")

# .... just the investment model...

cli.add_command(run_all)
cli.add_command(run_screening)
cli.add_command(run_investment_pt1)
cli.add_command(run_investment_all)


if __name__ == '__main__':
    cli()



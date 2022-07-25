# This is a preliminary version of the CLI for ATTEST transmission planning tools

# git synchronization check by Andrey

import click
import json


from engines.screening_model import main_screening # we need to revisit the scripts to define the required functions
from engines.investment_model import main_investment

# A temporary output data of the planning tools. Will be replaced with real simulation results later
temp_export = {"Country": "PT", 
                "Scenario 1": 
                {"Total investment cost (EUR)": 1000, 
                    "Net Present Cost (EUR)":800,
                    "2020": {"Operation cost (EUR/year)": 200, "Branch investment (MVA):": [133, 58, 0, 0, 0, 0], "Flexibility investment (MW):": [0, 0, 0, 0, 0, 0]}, 
                    "2030": {"Operation cost (EUR/year)": 200, "Branch investment (MVA):": [133, 58, 0, 0, 0, 0], "Flexibility investment (MW):": [0, 0, 0, 0, 0, 0]}, 
                    "2040": {"Operation cost (EUR/year)": 200, "Branch investment (MVA):": [133, 58, 0, 0, 0, 0], "Flexibility investment (MW):": [0, 0, 0, 0, 0, 0]}, 
                    "2050": {"Operation cost (EUR/year)": 200, "Branch investment (MVA):": [133, 58, 0, 0, 0, 0], "Flexibility investment (MW):": [0, 0, 0, 0, 0, 0]}
                },
                "Scenario 2": 
                {"Total investment cost (EUR)": 1120, 
                    "Net Present Cost (EUR)":700,
                    "2020": {"Operation cost (EUR/year)": 220, "Branch investment (MVA):": [143, 58, 0, 0, 0, 0], "Flexibility investment (MW):": [0, 0, 0, 0, 0, 0]}, 
                    "2030": {"Operation cost (EUR/year)": 210, "Branch investment (MVA):": [143, 58, 0, 0, 0, 0], "Flexibility investment (MW):": [0, 0, 0, 0, 0, 0]}, 
                    "2040": {"Operation cost (EUR/year)": 220, "Branch investment (MVA):": [143, 58, 0, 0, 0, 0], "Flexibility investment (MW):": [0, 0, 0, 0, 0, 0]}, 
                    "2050": {"Operation cost (EUR/year)": 210, "Branch investment (MVA):": [143, 58, 0, 0, 0, 0], "Flexibility investment (MW):": [0, 0, 0, 0, 0, 0]}
                }
                }

@click.group() # Create a group of commands that call different functions from the planning tools
def cli():
    pass

@click.command(help='Run the entire TEP toolbox') # i.e., read data --> run the screening model --> iteratively run the investment and operation models --> save the output
@click.option('--country',default='UK',help='Specify the country:"PT", "HR", or "UK"')
@click.option('--years',default='4',help='Specify the number of years: 1 - [2020], 2 - [2020,2030], 3 - [2020,2030,2040], 4 - [2020,2030,2040,2050]')
def run_all(country,years):
    print("Running the entire TEP toolbox ...")
    print("...")
    print("... loading data ...") # to be updated... Several .m and .ods files have to be read depending on the case study.
    print("Country selected: ",country)
    print("Number of years selected: ",years)
    print("... the TEP toolbox is not complete yet. Please, try calling and testing the screening model or the investment model")
    # what else do we need to include? seasons?

    print("...")
    print("... saving outputs ...")
    with open('Output_Data_Investment.json', 'w') as f: 
        json.dump(temp_export, f)
    print("... a data template file 'Output_Data_Investment.json' saved")

@click.command(help='Run the screening model') # i.e., read data --> run the screening model --> save the output
@click.option('--country',default='UK',help='Specify the country:"PT", "HR", or "UK"')
@click.option('--years',default='4',help='Specify the number of years: 1 - [2020], 2 - [2020,2030], 3 - [2020,2030,2040], 4 - [2020,2030,2040,2050]')
def run_screening(country,years):
    print("Running the screening model ...")
    print("...")
    print("... loading data ...") # to be updated... Several .m and .ods files have to be read depending on the case study
    print("Country selected: ",country)
    print("Number of years selected: ",years)
    print("... running screening_model.py") # we need to define more functions instead of running the entire script
    # what else do we need to include? seasons?

    main_screening() # currently runs 'Transmission_Network_UK2.json'

    print("...")
    print("... saving outputs ...")
    with open('Output_Data_Investment.json', 'w') as f: 
        json.dump(temp_export, f)
    print("... a data template file 'Output_Data_Investment.json' saved")

@click.command(help='Run the investment model') # i.e., read data --> run the investment model --> save the output
@click.option('--country',default='UK',help='Specify the country:"PT", "HR", or "UK"')
@click.option('--years',default='4',help='Specify the number of years: 1 - [2020], 2 - [2020,2030], 3 - [2020,2030,2040], 4 - [2020,2030,2040,2050]')
def run_investment(country,years):
    print("Running the investment model ...")
    print("...")
    print("... loading data ...") # to be updated... Several .m and .ods files have to be read depending on the case study
    print("Country selected: ",country)
    print("Number of years selected: ",years)
    print("... running investment_model.py") # we need to define more functions instead of running the entire script
    # what else do we need to include? seasons?

    main_investment() # currently runs 'case5.json'

    print("...")
    print("... saving outputs ...")
    with open('Output_Data_Investment.json', 'w') as f: 
        json.dump(temp_export, f)
    print("... a data template file 'Output_Data_Investment.json' saved")


# .... just the investment model...

cli.add_command(run_all)
cli.add_command(run_screening)
cli.add_command(run_investment)


if __name__ == '__main__':
    cli()



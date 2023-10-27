# ATTEST WP 3.2 Optimization Tool for Transmission Network Planning

This repository contains the `Optimization Tool for Transmission Network Planning` developed by WP3 as part of the ATTEST project [1].
The tool incorporates a three-stage scenario-based stochastic optimization formulation to minimize network reinforcement costs and the cost of operation. 
To minimize the computational burden, the tool decomposes the planning problem into investment and operation models. 
It also utilizes a screening model to identify and pre-select potentially attractive candidate investments. 
To account for the flexibility services provided by distribution networks, the transmission network planning tool includes available flexible power support at the TSO-DSO interfaces. 
In view of uncertainties influencing the operation of transmission networks, a stochastic operational model is formulated to identify possible worst-case short-term conditions and related long-term scenarios. 
Finally, to meet the N-1 security of transmission network operation, the investment model is complemented with the SC AC OPF analysis that enables identifying network binding constraints with respect to possible contingencies [2].

## Inputs
The input data includes network data, contingency data, and cost assumptions.

Network information, including future energy scenarios and generation costs, is stored in “engines/tests/json”. Example: `Transmission_Network_PT_2030_Active_Economy.m`

Time-series data, including demand, generation, and flexibility, is stored in “engines/tests/excel”. 
Note if flexibility data are missing, the tool will by default use 10% of the peak load as the flexibility for each load bus, i.e., 
if the peak load is 100MW, then the upward flexibility is 10MW and the downward flexibility is 10MW. Example:
`Transmission_Network_PT_2030_Active_Economy_24hGenerationLoadData.xlsx`

Contingency data is stored in “engines\SCOPF_R5\input_data”. If contingency data is not found, the screening model will use all N-1 contingencies. 
However, this may cause load curtailments due to network islanding. Therefore, a list of contingencies is strongly recommended for input data. Example: `case_template_PT.ods`

Intervention lists and costs for branch and transformer investments are stored in “engines/tests/json”. Note if the intervention input data is missing, a set of default data will be used. Example: `Intervention.json`

## Outputs
The output data includes results from both the screening model and the investment model. 
Note that the investment model has two parts and two outputs. 
One investment model focuses on minimising investment costs (part 1), and another investment model, besides minimising investment costs, also aims to minimise operation costs (part 2).

Results from the screening model are stored in “engines/results”. Example: `screen_result_PT_Transmission_Network_PT.json`

Results from the investment model are stored in “engines/results”. Example: `investment_result_PT_Transmission_Network_PT _pt1.json`, `investment_result_PT_Transmission_Network_PT _pt2.json`


## Running the tool

Users can run the tool in Python by simply running the command `Python cli.py`. 
To access the help information of the tool, run the command `Python cli.py --help`. 
To run the screening model only, run the command `Python cli.py run-screening`.
To run the investment model only, run the command `Python cli.py run-investment`.
To run both screening model and investment model, run the command `Python cli.py run-all`.
When executing, the tool will ask users to type additional input data. 
Note that if the input information is empty, default data is used for the simulations.

## References:

[1] https://attest-project.eu/

[2] M. I. Alizadeh, M. Usman, and F. Capitanescu, “Envisioning security control in renewable dominated power systems through stochastic multiperiod AC security constrained optimal power flow,” International Journal of Electrical Power & Energy Systems, vol. 139, 2022

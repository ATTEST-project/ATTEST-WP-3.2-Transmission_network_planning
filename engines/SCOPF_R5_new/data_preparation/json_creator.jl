investment=zeros(size(rdata_lines[:,1],1),1)
# investment[6]=133
Pfl_inc=zeros(nBus,1)
Pfl_dec=zeros(nBus,1)
Qfl_inc=zeros(nBus,1)
Qfl_dec=zeros(nBus,1)

# Pfl_inc=ones(nBus,1)
# Pfl_dec=ones(nBus,1)
# Qfl_inc=ones(nBus,1)
# Qfl_dec=ones(nBus,1)

# negGen = [bus_number, MVAbase, Pmax, Pmin, Qmax, Qmin, Cost_linear]
negative_gen = [[1, 100, 0, -1000, 0, -1000, -1],
[2, 100, 0, -1000, 0, -1000, -1]]

new_gen_cost=0.1
OPF_opt=0
load_multiplier=1.0
gen_multiplier=1.0
s=Dict("ci" => investment,
       "Pflex_inc" => Pfl_inc,
       "Pflex_dec" => Pfl_dec,
       "Qflex_inc" => Qfl_inc,
       "Qflex_dec" => Qfl_dec,
       "negGen"    => negative_gen,
       "gencost"   => new_gen_cost,
       "OPF_opt"   => OPF_opt,
       "load_multiplier"=> load_multiplier,
       "gen_multiplier" => gen_multiplier,
       )
 stringdata = JSON.json(s)
#Please note that parallel lines are merged initially,
# io = open("export_WP3.json", "a");
 open("data_preparation\\import_WP3.json", "a") do f
write(f, stringdata)
end

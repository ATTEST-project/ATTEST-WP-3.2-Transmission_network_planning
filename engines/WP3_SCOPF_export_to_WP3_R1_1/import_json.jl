# investment=zeros(size(rdata_lines[:,1],1),1)
# investment[6]=133
# Pfl_inc=zeros(nBus,1)
# Pfl_dec=zeros(nBus,1)
# Qfl_inc=zeros(nBus,1)
# Qfl_dec=zeros(nBus,1)
#
# Pfl_inc=ones(nBus,1)
# Pfl_dec=ones(nBus,1)
# Qfl_inc=ones(nBus,1)
# Qfl_dec=ones(nBus,1)
#
# # negGen = [bus_number, MVAbase, Pmax, Pmin, Qmax, Qmin, Cost_linear]
# negative_gen = [[1, 100, 0, -1000, 0, -1000, -1],
# [2, 100, 0, -1000, 0, -1000, -1]]
#
# new_gen_cost=ones(nGens,1)
#
# s=Dict("ci" => investment,
#        "Pflex_inc" => Pfl_inc,
#        "Pflex_dec" => Pfl_dec,
#        "Qflex_inc" => Qfl_inc,
#        "Qflex_dec" => Qfl_dec,
#        "negGen"    => negative_gen,
#        "gencost"   => new_gen_cost
#        )
#  stringdata = JSON.json(s)
# #Please note that parallel lines are merged initially,
# # io = open("export_WP3.json", "a");
#  open("import_WP3.json", "a") do f
# write(f, stringdata)
# end

new_data = Dict()
open("import_WP3.json", "r") do g
        global new_data
    new_data=JSON.parse(g)

end

for l in 1:nLines
    if new_data["ci"][l]!=0
        array_lines[l].line_Smax_A=array_lines[l].line_Smax_A+new_data["ci"][l]/sbase
    end
end

upper_flex_p_inc=ones(nFl,1)
upper_flex_p_dec=ones(nFl,1)
upper_flex_q_inc=ones(nFl,1)
upper_flex_q_dec=ones(nFl,1)

for  i in 1:nFl
    upper_flex_p_inc[i]=new_data["Pflex_inc"][nd_fl[i]]/sbase
    upper_flex_p_dec[i]=new_data["Pflex_dec"][nd_fl[i]]/sbase
    upper_flex_q_inc[i]=new_data["Qflex_inc"][nd_fl[i]]/sbase
    upper_flex_q_dec[i]=new_data["Qflex_dec"][nd_fl[i]]/sbase
end
# for  i in 1:nFl
#     upper_flex_p_inc[i]=new_data["Pflex_inc"][1][nd_fl[i]]/sbase
#     upper_flex_p_dec[i]=new_data["Pflex_dec"][1][nd_fl[i]]/sbase
#     upper_flex_q_inc[i]=new_data["Qflex_inc"][1][nd_fl[i]]/sbase
#     upper_flex_q_dec[i]=new_data["Qflex_dec"][1][nd_fl[i]]/sbase
# end
neg_gen_bus=[]
if haskey(new_data, "negGen")
    idx_neg=size(new_data["negGen"],1)
      for i in 1:idx_neg
      push!(neg_gen_bus, new_data["negGen"][i][1])
  end
end

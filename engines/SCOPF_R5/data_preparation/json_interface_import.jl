#------read all data all at once from json file ---------------------------------
new_data = Dict()
open("data_preparation\\import_WP3.json", "r") do g
        global new_data
    new_data=JSON.parse(g)

end

#--------------upgrade the Smax of the lines as an output of EX plan----------
for l in 1:nLines
    if new_data["ci"][l]!=0
        array_lines[l].line_Smax_A=array_lines[l].line_Smax_A+new_data["ci"][l]/sbase
    end
end


#-------------set the limits for the flexible load separated for increase and decrease-------------


upper_flex_p_inc=ones(nFl,1)
upper_flex_p_dec=ones(nFl,1)
upper_flex_q_inc=ones(nFl,1)
upper_flex_q_dec=ones(nFl,1)
if nFl!=0
for  i in 1:nFl
    upper_flex_p_inc[i]=new_data["Pflex_inc"][nd_fl[i]]/sbase
    upper_flex_p_dec[i]=new_data["Pflex_dec"][nd_fl[i]]/sbase
    upper_flex_q_inc[i]=new_data["Qflex_inc"][nd_fl[i]]/sbase
    upper_flex_q_dec[i]=new_data["Qflex_dec"][nd_fl[i]]/sbase
end
end


#-----------look for any negative generators------------------
neg_gen_bus=[]
if haskey(new_data, "negGen")
    idx_neg=size(new_data["negGen"],1)
      for i in 1:idx_neg
      push!(neg_gen_bus, new_data["negGen"][i])
  end
end

new_gen_cost=new_data["gencost"]

OPF_opt=new_data["OPF_opt"]
# OPF_opt=1
nTP=[]
if OPF_opt==0
    nTP=1
elseif OPF_opt==1
    nTP=24
end

load_multiplier=new_data["load_multiplier"]
gen_multiplier =new_data["gen_multiplier"]


prof_ploads=load_multiplier*prof_ploads
prof_qloads=load_multiplier*prof_qloads


pg_max=gen_multiplier*pg_max
qg_max=gen_multiplier*qg_max

# pg_min=gen_multiplier*pg_min
# qg_min=gen_multiplier*qg_min
pg_min=1*pg_min
qg_min=1*qg_min

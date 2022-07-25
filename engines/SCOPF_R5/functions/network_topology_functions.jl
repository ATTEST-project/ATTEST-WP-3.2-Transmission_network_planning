function interface_excel_contingencies(raw_data,header,data)
sheetname = "contingencies";
fields = ["cont", "From", "To"]; # Fields that have to be read from the file
  # Conversion from Dict to Array


data = convert(Array{Float64}, data)
data_cont = zeros(size(fields, 1))               # data_cont = Data Container
nCont = Int64(size(data, 1))

global array_contin_lines = Array{contingencies}(undef, nLines)

array_contin_lines = data_reader( array_contin_lines, nCont, fields, header, data, data_cont, contingencies )

# ------
idx_from_line = []
idx_to_line = []
for i = 1:nLines                                                                # nLines = nTrsf + nTransmission lines
    push!(idx_from_line, rdata_lines[i,1])                                # Saving 'from' end of lines in a vector
    push!(idx_to_line,  rdata_lines[i,2])                                    # Saving 'to' end of lines in a vector
end
idx_line = [idx_from_line idx_to_line]

idx_from_line_c = []
idx_to_line_c = []
for i = 1:nCont                                                                # nLines = nTrsf + nTransmission lines
    push!(idx_from_line_c, array_contin_lines[i].from_contin)                                # Saving 'from' end of lines in a vector
    push!(idx_to_line_c, array_contin_lines[i].to_contin)                                    # Saving 'to' end of lines in a vector
end
idx_line_c = [idx_from_line_c idx_to_line_c]

# contin_ex=[findall3(x -> x == idx_line_c[c,:], idx_line) for c in 1:nCont]

list_of_contingency_lines = []
# list_of_contingency_lines_1 = []
# list_of_contingency_lines_new = []
for i = 1:nCont
    from_search_1 = findall3(x -> x == idx_line_c[i, 1], idx_line[:, 1])
    to_search_1 = findall3(x -> x == idx_line_c[i, 2], idx_line[:, 2])
    contingency_line_1 = intersect(from_search_1, to_search_1)
    from_search_2 = findall3(x -> x == idx_line_c[i, 2], idx_line[:, 1])
    to_search_2 = findall3(x -> x == idx_line_c[i, 1], idx_line[:, 2])
    contingency_line_2 = intersect(from_search_2, to_search_2)
    #  contin_total=union(contingency_line_1,contingency_line_2)
    if !isempty(contingency_line_1)
    push!(list_of_contingency_lines, contingency_line_1)
    # push!(list_of_contingency_lines_1, contingency_line_2)
end
if  !isempty(contingency_line_2)
    push!(list_of_contingency_lines, contingency_line_2)
#
end
# if  !isempty(contingency_line_1) && !isempty(contingency_line_2)
    # push!(list_of_contingency_lines_new, contin_total)
# end
    # push!(ss,ss1)
end
#
#

idx_parallel=[]
for i in 1:nLines
    if size(idx_plines[i],1)>1
        push!(idx_parallel,[i])
    else
        push!(idx_parallel,[])
    end
end


data_for_each_contingency = []
idx_contin_branches = []
idx_pll=[findall3(x -> x == list_of_contingency_lines[c], idx_parallel) for c in 1:nCont]
idx_pll_aux=findall3(x -> x != [], idx_pll)
idx_npll=findall3(x -> x ==[], idx_pll)
nCont_nprll=size(idx_npll,1)
nCont_prll =nCont-nCont_nprll

idx_sep_pll=[]
for  c in 1:nCont
    idx_separation=findall3(x -> x == list_of_contingency_lines[c], idx_parallel)
    if ~isempty(idx_separation)
    push!(idx_sep_pll,idx_separation)
end
end
idx_sep_npll=setdiff(list_of_contingency_lines,idx_sep_pll)
final_sep=[idx_sep_pll;idx_sep_npll]
final_sep=vcat(final_sep...)
# idx_sep_1=[]
# for  c in 1:nCont
#     idx_separation=findall3(x -> x != list_of_contingency_lines[c], idx_parallel)
#     if ~isempty(idx_separation)
#     push!(idx_sep_1,idx_separation)
# end
# end

# nCont_parallel    =

for c in 1:nCont
             if ~isempty(idx_pll[c])
                 push!(idx_contin_branches, collect(1:nLines))
                  # nline_data = [rdata_lines[idx_pll[1,1],1] rdata_lines[idx_pll[1,1],2]
                  #             0.5*data_for_each_contingency[c][idx_pll[c]].line_g
                  #             0.5*data_for_each_contingency[c][idx_pll[c]].line_b
                  #             0.5*data_for_each_contingency[c][idx_pll[c]].line_g_shunt
                  #             0.5*data_for_each_contingency[c][idx_pll[c]].line_b_shunt
                  #             0.5*data_for_each_contingency[c][idx_pll[c]].line_Smax_A
                  #           rdata_lines[idx_pll[1,1],8] ]
                 # push!( data_for_each_contingency, Line(nline_data) )

         else
             find_contingencies = setdiff(collect(1:nLines), list_of_contingency_lines[c][1])
             push!(idx_contin_branches, find_contingencies)

             # idx_pll=idx_pll[1,1]
            # push!( data_for_each_contingency, array_lines[idx_contin_branches[c], :], )

        end
    end

    for c in 1:nCont
      push!( data_for_each_contingency, array_lines[idx_contin_branches[c], :], )
    end
# idx_contin_branches = []
# idx_pll=[findall3(x -> x == list_of_contingency_lines[c], idx_parallel) for c in 1:nCont]
nline_data_c=[]
for c in 1:nCont
         if ~isempty(idx_pll[c])
             # idx_pll=

             idx_pll_a=idx_pll[c]
             idx_pll_a=idx_pll_a[1,1]

             # if size(idx_plines[idx_pll_a],1)==2
             #     # push!(idx_contin_branches, collect(1:nLines))
             #     c1=rdata_lines[idx_pll_a,1]
             #     c2=rdata_lines[idx_pll_a,2]
             #     c3=0.5*data_for_each_contingency[c][idx_pll_a].line_g
             #     c4=0.5*data_for_each_contingency[c][idx_pll_a].line_b
             #     c5=0.5*data_for_each_contingency[c][idx_pll_a].line_g_shunt
             #     c6=0.5*data_for_each_contingency[c][idx_pll_a].line_b_shunt
             #     c7=0.5*data_for_each_contingency[c][idx_pll_a].line_Smax_A
             #     c8=rdata_lines[idx_pll_a,8]
             #      c9 = [ c1 c2 c3 c4 c5 c6 c7 c8]
             #      push!(nline_data_c,Line(c1,c2,c3,c4,c5,c6,c7,c8))
              # elseif size(idx_plines[idx_pll_a],1)>2
                  coef=(size(idx_plines[idx_pll_a],1)-1)/(size(idx_plines[idx_pll_a],1))
                  c1=rdata_lines[idx_pll_a,1]
                  c2=rdata_lines[idx_pll_a,2]
                  c3=coef*data_for_each_contingency[c][idx_pll_a].line_g
                  c4=coef*data_for_each_contingency[c][idx_pll_a].line_b
                  c5=coef*data_for_each_contingency[c][idx_pll_a].line_g_shunt
                  c6=coef*data_for_each_contingency[c][idx_pll_a].line_b_shunt
                  c7=coef*data_for_each_contingency[c][idx_pll_a].line_Smax_A
                  c8=rdata_lines[idx_pll_a,8]
                   c9 = [ c1 c2 c3 c4 c5 c6 c7 c8]
                   push!(nline_data_c,Line(c1,c2,c3,c4,c5,c6,c7,c8))
                              # rdata_lines[idx_pll_aux,1]
                              # rdata_lines[idx_pll_aux,2]
                              # 0.5*data_for_each_contingency[c][idx_pll_aux].line_g
                              # 0.5*data_for_each_contingency[c][idx_pll_aux].line_b ]
                              # 0.5*data_for_each_contingency[c][idx_pll_aux].line_g_shunt
                              # 0.5*data_for_each_contingency[c][idx_pll_aux].line_b_shunt
                              # 0.5*data_for_each_contingency[c][idx_pll_aux].line_Smax_A
                            # rdata_lines[idx_pll_aux,8] ]
                 # push!( data_for_each_contingency, Line(nline_data) )

         # else
         #     find_contingencies = setdiff(collect(1:nLines), list_of_contingency_lines[c][1])
         #     push!(idx_contin_branches, find_contingencies)
         #
         #     # idx_pll=idx_pll[1,1]
         #    push!( data_for_each_contingency, array_lines[idx_contin_branches[c], :], )

        end
    end

# data_for_each_contingency[1]

for c in 1:nCont
  # for c in 26
         if ~isempty(idx_pll[c])
             # idx_pll=
             idx_pll_a=idx_pll[c]
             idx_pll_a=idx_pll_a[1,1]
             idx_pll_b=findall3(x -> x == idx_pll[c], idx_sep_pll)
             idx_pll_b=idx_pll_b[1,1]
    data_for_each_contingency[c][idx_pll_a]=nline_data_c[idx_pll_b]
      # push!( data_for_each_contingency, nline_data_c[c] )
    end
end

header=nothing
data=nothing
raw_data=nothing

return nCont,
array_contin_lines,
idx_from_line,
idx_to_line,
idx_line,
idx_from_line_c,
idx_to_line_c,
list_of_contingency_lines,
idx_pll_aux,
idx_npll,
data_for_each_contingency
end

function interface_excel_scenario()
    sheetname  = "wind_scenarios";
# sheetname  = "wind_scenarios_20";
# sheetname  = "wind_scenario_8";
fields     = ["scenarios","t1","t2","t3","t4","t5","t6","t7","t8","t9","t10","t11","t12","t13","t14","t15","t16","t17","t18","t19","t20","t21","t22","t23","t24"];                                    # Fields that have to be read from the file
raw_data = ods_readall(filename_scenario;sheetsNames=[sheetname],innerType="Matrix")
raw_data = raw_data[sheetname]   # Conversion from Dict to Array
header    = raw_data[1,:]
data_scen     = raw_data[2:end,2:end]


raw_data=nothing
return data_scen
end

function f_prof_PRES(nSc,nTP,RES_MAG)
# RES_bus=[]

# RES_bus=[108,128,138,149,250]
# nTP   =1
#
# RES_cap=[0.35,1.5,0.1,0.01,0.46]
nRES=size(RES_bus,1)


# nSc      = Int64(size(data_scen,1))
# nSc=1
# include("scenario.jl")
dim_RES=(length(1:nSc),length(1:nTP),length(1:size(RES_bus,1)))
prof_PRES = zeros(Float64,dim_RES)

for i in 1:size(RES_bus,1)
prof_PRES[:,:,i]=RES_MAG*RES_cap[i]*data_scen[1:nSc,1:nTP]
# prof_PRES[i]=1*RES_cap[i]
end

return nTP,nSc,prof_PRES,RES_bus,nRES
end
function arrays(Load_MAG)
nw_buses = deepcopy(array_bus)
nw_lines = array_lines
nw_loads = array_loads
nw_gens  = array_gens
nw_trans = array_transformer
# nw_gcost = array_gcost
nw_sbase = array_sbase
nw_shunts= array_shunt
#--------------- Active and reactive power load profiles -----------------------
nw_pPrf_header_load     = rheader_pProfile_load
nw_qPrf_header_load     = rheader_qProfile_load
nw_pPrf_data_load       = rdata_pProfile_load
nw_qPrf_data_load       = rdata_qProfile_load

prof_ploads = Load_MAG*nw_pPrf_data_load[:,2:end]
# prof_ploads = nw_pPrf_data_load[:,2:end]
prof_qloads = tan(acos(power_factor))*nw_qPrf_data_load[:,2:end]

#------------ Active and reactive power generation profiles --------------------
# nw_pPrf_header_gen_min  = rheader_pProfile_gen_min
# nw_pPrf_header_gen_max  = rheader_pProfile_gen_max
# nw_qPrf_header_gen_min  = rheader_qProfile_gen_min
# nw_qPrf_header_gen_max  = rheader_qProfile_gen_max

# nw_pPrf_data_gen_min    = rdata_pProfile_gen_min
# nw_pPrf_data_gen_max    = rdata_pProfile_gen_max
# nw_qPrf_data_gen_min    = rdata_qProfile_gen_min
# nw_qPrf_data_gen_max    = rdata_qProfile_gen_max

nw_storage = array_storage
# nw_Strcost = array_Strcost

#------------------------- Network Constants -----------------------------------
sbase = nw_sbase[1].sbase     # sbase is in MVA
vbase = []                    # vbase is in kVA
for i in 1:size(rdata_buses,1)
    push!(vbase,nw_buses[i].bus_vnom)
end
Ibase = (sbase*1000)./(sqrt(3)*vbase)    # base_current = base kVA/base kV
# nTP   = size(nw_pPrf_data_load,2)-1      # No of time periods in  a horizon
# nTP   = 1

# nSc   = 1                     # No of scenarios
# time_step = 24/size(nw_pPrf_data_load[:,2:end],2)
load_inc_prct = 0.3 # %increase in the flexible load
load_dec_prct = 0.3 # %decrease in the flexible load
pf = 0.95           # power factor of a load
# v_relax_factor=0.06
v_relax_factor_min=0.05
v_relax_factor_max=0.05

return nw_buses,
nw_lines,
nw_loads,
nw_gens,
nw_trans,
nw_sbase,
nw_shunts,
nw_pPrf_header_load,
nw_qPrf_header_load,
nw_pPrf_data_load,
nw_qPrf_data_load,
prof_ploads,
prof_qloads,
nw_storage,
sbase,
vbase,
Ibase,
load_inc_prct,
load_dec_prct,
pf,
v_relax_factor_min,
v_relax_factor_max

end



function f_line_data(array_lines,nw_trans)
    idx_from_line  = []
    idx_to_line    = []
    idx_from_trans = []
    idx_to_trans   = []
    yij_line       = []
    yij_line_sh    = []
    yij_trans      = []
    yij_trans_sh   = []
    tap_ratio      = []
    tap_ratio_max  = []
    tap_ratio_min  = []
for i in 1:nLines                                                                # nLines = nTrsf + nTransmission lines
    push!(idx_from_line,nw_lines[i].line_from)                                # Saving 'from' end of lines in a vector
    push!(idx_to_line,nw_lines[i].line_to)                                    # Saving 'to' end of lines in a vector
    push!(yij_line,nw_lines[i].line_g+(nw_lines[i].line_b)im)               # Line admittance calculated from the given r and x values
    push!(yij_line_sh,nw_lines[i].line_g_shunt+(nw_lines[i].line_b_shunt)im)     # Shunt line admittance
end
for i in 1:nTrans
    push!(idx_from_trans,nw_trans[i].trans_bus_from)
    push!(idx_to_trans,nw_trans[i].trans_bus_to)
    push!(yij_trans,nw_trans[i].trans_g+(nw_trans[i].trans_b)im)
    push!(yij_trans_sh,(nw_trans[i].trans_bsh)im)
    push!(tap_ratio,nw_trans[i].trans_ratio)
    push!(tap_ratio_min,nw_trans[i].trans_rmin)
    push!(tap_ratio_max,nw_trans[i].trans_rmax)
end


return idx_from_line,idx_to_line,yij_line,yij_line_sh,idx_from_trans,idx_to_trans,yij_trans,yij_trans_sh,tap_ratio,tap_ratio_min,tap_ratio_max
end


function f_lines_data_contin(data_for_each_contingency)
idx_from_line_c=[]
idx_to_line_c  =[]
yij_line_c     =[]
yij_line_sh_c  =[]
line_smax_c    =[]
for c in 1:nCont
    # for i in 1:size(data_for_each_contingency[c],1)
        idx_from_line_c_aux=[data_for_each_contingency[c][i].line_from for i in 1:size(data_for_each_contingency[c],1)]
        idx_to_line_c_aux=[data_for_each_contingency[c][i].line_to for i in 1:size(data_for_each_contingency[c],1)]
        yij_line_c_g=[data_for_each_contingency[c][i].line_g for i in 1:size(data_for_each_contingency[c],1)]
        yij_line_c_b=[data_for_each_contingency[c][i].line_b for i in 1:size(data_for_each_contingency[c],1)]
        yij_line_sh_c_g=[data_for_each_contingency[c][i].line_g_shunt for i in 1:size(data_for_each_contingency[c],1)]
        yij_line_sh_c_b=[data_for_each_contingency[c][i].line_b_shunt for i in 1:size(data_for_each_contingency[c],1)]
        line_smax_c_aux=[data_for_each_contingency[c][i].line_Smax_A for i in 1:size(data_for_each_contingency[c],1)]
        push!(idx_from_line_c,idx_from_line_c_aux)
        push!(idx_to_line_c,idx_to_line_c_aux)
        push!(yij_line_c,yij_line_c_g+(yij_line_c_b)im   )
        push!(yij_line_sh_c,yij_line_sh_c_g+(yij_line_sh_c_b)im  )
        push!(line_smax_c,line_smax_c_aux)

    # end
end
return idx_from_line_c,idx_to_line_c,yij_line_c,yij_line_sh_c,line_smax_c
end


function f_node_data(nBus,idx_from_line,idx_to_line,nw_lines,yij_line,yij_line_sh)
node_data     = []
for i in 1:nBus
    bus_num = nw_buses[i].bus_num
    bus_num = bus_num[1,1]
    ft_line = findall3(x->x==bus_num,idx_from_line)                               # index of all lines which are connected to bus i (bus i is present in 'from' column)
    tf_line = findall3(x->x==bus_num,idx_to_line)                                 # index of all lines which are connected to bus i (bus i is present in 'to' column)
    telem   = size(ft_line,1)+size(tf_line,1)

    ft_bus  = idx_to_line[ft_line]                                                # buses connected to bus i (bus i is present in 'from' column)
    tf_bus  = idx_from_line[tf_line]                                              # buses connected to bus i (bus i is present in 'to' column)

    b_lines  = union(ft_line,tf_line)                                            # indexes of all lines connected to bus (b) i
    b_cbuses = union(ft_bus,tf_bus)                                              # buses connected to bus i

    gij_line = real(yij_line[b_lines,1])
    bij_line = imag(yij_line[b_lines,1])

    gij_line_sh = real(yij_line_sh[b_lines,1])
    bij_line_sh = imag(yij_line_sh[b_lines,1])
    smax_line = [nw_lines[i].line_Smax_A for i in b_lines]
    # tp_rt     = vcat(tap_ratio[ft_line],tap_ratio[tf_line])
    # tp_rt_min = vcat(tap_ratio_min[ft_line],tap_ratio_min[tf_line])
    # tp_rt_max = vcat(tap_ratio_max[ft_line],tap_ratio_max[tf_line])
    # from_col  = idx_from_line[b_lines,1]
    # to_col    = idx_to_line[b_lines,1]
    bus       = repeat([bus_num],telem)
    idx_parallel_idx=[size(idx_plines[i],1) for i in b_lines]
    # iTap      = idx_tap[b_lines,end]
    # push!(node_data,node(bus,b_cbuses,b_lines,gij_line_sh,gij_line,bij_line_sh,bij_line,tp_rt,tp_rt_min,tp_rt_max,from_col,to_col,iTap))
    push!(node_data,node(bus,b_cbuses,b_lines,gij_line_sh,gij_line,bij_line_sh,bij_line,smax_line,idx_parallel_idx))

end

return node_data
end


function f_node_data_trans(nBus,nw_buses,idx_from_trans,idx_to_trans,yij_trans,yij_trans_sh,tap_ratio,tap_ratio_min,tap_ratio_max)
node_data_trans= []
for i in 1:nBus
    bus_num = nw_buses[i].bus_num
    bus_num = bus_num[1,1]
    ft_line = findall3(x->x==bus_num,idx_from_trans)                               # index of all lines which are connected to bus i (bus i is present in 'from' column)
    tf_line = findall3(x->x==bus_num,idx_to_trans)                                 # index of all lines which are connected to bus i (bus i is present in 'to' column)
    telem   = size(ft_line,1)+size(tf_line,1)

    ft_bus  = idx_to_trans[ft_line]                                                # buses connected to bus i (bus i is present in 'from' column)
    tf_bus  = idx_from_trans[tf_line]                                              # buses connected to bus i (bus i is present in 'to' column)

    b_lines  = union(ft_line,tf_line)                                            # indexes of all lines connected to bus (b) i
    b_cbuses = union(ft_bus,tf_bus)                                              # buses connected to bus i

    gij_trans = real(yij_trans[b_lines,1])
    bij_trans = imag(yij_trans[b_lines,1])

    gij_trans_sh = real(yij_trans_sh[b_lines,1])
    bij_trans_sh = imag(yij_trans_sh[b_lines,1])

    # tp_rt     = vcat(tap_ratio[ft_line],tap_ratio[tf_line])
    tp_rt = tap_ratio[b_lines,1]
    tp_rt_min = tap_ratio_min[b_lines,1]
    tp_rt_max = tap_ratio_max[b_lines,1]
    # from_col  = idx_from_line[b_lines,1]
    # to_col    = idx_to_line[b_lines,1]
    bus       = repeat([bus_num],telem)
    # iTap      = idx_tap[b_lines,end]
    # push!(node_data,node(bus,b_cbuses,b_lines,gij_line_sh,gij_line,bij_line_sh,bij_line,tp_rt,tp_rt_min,tp_rt_max,from_col,to_col,iTap))
    push!(node_data_trans,node_t(bus,b_cbuses,b_lines,gij_trans_sh,gij_trans,bij_trans_sh,bij_trans,tp_rt,tp_rt_min,tp_rt_max))

end
return node_data_trans

end
function f_node_data_new(nBus,idx_from_line,idx_to_line,nw_lines,yij_line,yij_line_sh,nw_buses,idx_from_trans,idx_to_trans,yij_trans,yij_trans_sh,tap_ratio,tap_ratio_min,tap_ratio_max)
    node_data_new  = []

    for i in 1:nBus
        bus_num = nw_buses[i].bus_num
        bus_num = bus_num[1,1]
        ft_line = findall3(x->x==bus_num,idx_from_line)                               # index of all lines which are connected to bus i (bus i is present in 'from' column)
        tf_line = findall3(x->x==bus_num,idx_to_line)                                 # index of all lines which are connected to bus i (bus i is present in 'to' column)
        telem   = size(ft_line,1)+size(tf_line,1)

        ft_bus  = idx_to_line[ft_line]                                                # buses connected to bus i (bus i is present in 'from' column)
        tf_bus  = idx_from_line[tf_line]                                              # buses connected to bus i (bus i is present in 'to' column)

        b_lines  = union(ft_line,tf_line)                                            # indexes of all lines connected to bus (b) i
        b_cbuses = union(ft_bus,tf_bus)                                              # buses connected to bus i

        gij_line = real(yij_line[b_lines,1])
        bij_line = imag(yij_line[b_lines,1])

        gij_line_sh = real(yij_line_sh[b_lines,1])
        bij_line_sh = imag(yij_line_sh[b_lines,1])
        smax_line = [nw_lines[i].line_Smax_A for i in b_lines]
        # tp_rt     = vcat(tap_ratio[ft_line],tap_ratio[tf_line])
        # tp_rt_min = vcat(tap_ratio_min[ft_line],tap_ratio_min[tf_line])
        # tp_rt_max = vcat(tap_ratio_max[ft_line],tap_ratio_max[tf_line])
        # from_col  = idx_from_line[b_lines,1]
        # to_col    = idx_to_line[b_lines,1]
        bus       = repeat([bus_num],telem)
        idx_parallel_idx=[size(idx_plines[i],1) for i in b_lines]
        # iTap      = idx_tap[b_lines,end]
        # push!(node_data,node(bus,b_cbuses,b_lines,gij_line_sh,gij_line,bij_line_sh,bij_line,tp_rt,tp_rt_min,tp_rt_max,from_col,to_col,iTap))


        ft_line_t = findall3(x->x==bus_num,idx_from_trans)                               # index of all lines which are connected to bus i (bus i is present in 'from' column)
        tf_line_t = findall3(x->x==bus_num,idx_to_trans)                                 # index of all lines which are connected to bus i (bus i is present in 'to' column)
        telem_t   = size(ft_line_t,1)+size(tf_line_t,1)

        ft_bus_t  = idx_to_trans[ft_line_t]                                                # buses connected to bus i (bus i is present in 'from' column)
        tf_bus_t  = idx_from_trans[tf_line_t]                                              # buses connected to bus i (bus i is present in 'to' column)

        b_lines_t  = union(ft_line_t,tf_line_t)                                            # indexes of all lines connected to bus (b) i
        b_cbuses_t = union(ft_bus_t,tf_bus_t)                                              # buses connected to bus i

        gij_trans = real(yij_trans[b_lines_t,1])
        bij_trans = imag(yij_trans[b_lines_t,1])

        gij_trans_sh = real(yij_trans_sh[b_lines_t,1])
        bij_trans_sh = imag(yij_trans_sh[b_lines_t,1])

        smax_line_t = [nw_trans[i].trans_Snom for i in b_lines_t]
        # tp_rt     = vcat(tap_ratio[ft_line],tap_ratio[tf_line])
        # tp_rt = tap_ratio[b_lines,1]
        # tp_rt_min = tap_ratio_min[b_lines,1]
        # tp_rt_max = tap_ratio_max[b_lines,1]
        # from_col  = idx_from_line[b_lines,1]
        # to_col    = idx_to_line[b_lines,1]
        bus_t       = repeat([bus_num],telem_t)
        idx_parallel_idx_t=[size(idx_ptranses[i],1) for i in b_lines_t]
        # idx_parallel_idx_t=[1]
        # iTap      = idx_tap[b_lines,end]
        # push!(node_data,node(bus,b_cbuses,b_lines,gij_line_sh,gij_line,bij_line_sh,bij_line,tp_rt,tp_rt_min,tp_rt_max,from_col,to_col,iTap))
        if ~isempty(bus) && isempty(bus_t)
         push!(node_data_new,node(bus,b_cbuses,b_lines,gij_line_sh,gij_line,bij_line_sh,bij_line,smax_line,idx_parallel_idx))

    elseif   isempty(bus) && ~isempty(bus_t)
        push!(node_data_new,node(bus_t,b_cbuses_t,b_lines_t,gij_trans_sh,gij_trans,bij_trans_sh,bij_trans,smax_line_t,idx_parallel_idx_t))
    elseif ~isempty(bus) && ~isempty(bus_t)
        push!(node_data_new,node(append!(bus,bus_t),append!(b_cbuses,b_cbuses_t),append!(b_lines,b_lines_t),append!(gij_line,gij_trans_sh),append!(gij_line,gij_trans),append!(bij_line_sh,bij_trans_sh),append!(bij_line,bij_trans),append!(smax_line,smax_line_t),append!(idx_parallel_idx,idx_parallel_idx_t)))
    end

    end
    return node_data_new
end

function radiality_filtering(node_data_new)

    node_data_updated=deepcopy(node_data_new)
    # isolated_nodes=[]
    # while ~isempty((1 for n=1:nBus if size(node_data_updated[n].node_num,1)==1) if node_data_updated[n]!=[] )
    # iter= 1
    # while ~isempty(findall3(x->x==1, [size(node_data_updated[n].node_num,1)==1 for n in 1:nBus if node_data_updated[n]!=[]]))
      for k in 1:5
        # local iter=0
    # for n in 1:nBus
    for n in 1:nBus
        if node_data_updated[n]!=[]
        if size(node_data_updated[n].node_num,1)==1
           if node_data_updated[node_data_updated[n].node_cnode[1]]!=[]
            deleteat!(node_data_updated[node_data_updated[n].node_cnode[1]].node_num, 1)
            deleteat!(node_data_updated[node_data_updated[n].node_cnode[1]].node_cnode,findall3(x->x==n, node_data_updated[node_data_updated[n].node_cnode[1]].node_cnode)[1])

        end
         node_data_updated[n]=[]
    end
    end
    end

    end


    islanded_lines=[]
    # =findall3(x->x==1, [size(node_data_updated[n].node_num,1)==1 for n in 1:nBus if node_data_updated[n]!=[]])
    for i in 1:nBus
        if node_data_updated[i]!=[]
        if size(node_data_updated[i].node_num,1)==1
    push!(islanded_lines, i)
    end
    end
    end

    # remove transformers
    for n in 1:nBus
        if node_data_updated[n]!=[]
          if node_data_trans[n]!=[]
              idx_trans=findall3(x->x in node_data_trans[n].node_cnode, node_data_updated[n].node_cnode  )
              deleteat!(node_data_updated[n].node_num, idx_trans)
              deleteat!(node_data_updated[n].node_cnode,idx_trans)
              if node_data_updated[n].node_num==[]
                  node_data_updated[n]=[]
              end
    # push!(include_lines, [n,node_data_updated[n].node_cnode[1] ])
    #       else
    # push!(include_lines, [n,node_data_updated[n].node_cnode[1] ])
    end
    end
    end

    include_lines=[]
    for n  in 1:nBus
        if node_data_updated[n]!=[]
            for j in 1:size(node_data_updated[n].node_cnode,1)
    push!(include_lines, [n,node_data_updated[n].node_cnode[j] ])
    end
    end
    end

    include_lines=unique!(include_lines)



    idx_line_contin=convert(Array{Int64,2},idx_line)
    in_line_set=[]
    for i in 1:length(include_lines)
        from_1=findall3(x->x==include_lines[i][1],idx_line_contin[:,1])
        to_1  =findall3(x->x==include_lines[i][2],idx_line_contin[:,2])
        from_2=findall3(x->x==include_lines[i][2],idx_line_contin[:,1])
        to_2  =findall3(x->x==include_lines[i][1],idx_line_contin[:,2])

        in_line_1=intersect(from_1, to_1)
        in_line_2=intersect(from_2, to_2)
        if ~isempty(in_line_1)
        push!(in_line_set, in_line_1)
    end
        if ~isempty(in_line_2)
        push!(in_line_set, in_line_2)
    end
    end



    in_line_set=unique!(in_line_set)

    line_from_to_idx=[idx_line[i[1],:] for i in in_line_set]

    include_lines_from=[line_from_to_idx[i][1] for i in 1:size(line_from_to_idx,1)]
    include_lines_to=[line_from_to_idx[i][2] for i in 1:size(line_from_to_idx,1)]
    include_new= [1:size(line_from_to_idx,1) include_lines_from include_lines_to ]

    # ods_write("input_data/included_lines_contingency.ods",Dict(("Lines_new_R5",2,1)=>include_new))
return    include_new

end

function f_node_data_contin(nCont,nBus,nw_buses,idx_from_line_c,idx_to_line_c,yij_line_c,yij_line_sh_c,line_smax_c)
node_data_c      = []
# for c in 1:nCont
for c in 1:nCont
  for i in 1:nBus
    bus_num = nw_buses[i].bus_num
    ft_line = findall3(x->x==bus_num,idx_from_line_c[c])                               # index of all lines which are connected to bus i (bus i is present in 'from' column)
    tf_line = findall3(x->x==bus_num,idx_to_line_c[c])                                 # index of all lines which are connected to bus i (bus i is present in 'to' column)
    telem   = size(ft_line,1)+size(tf_line,1)

    ft_bus  = idx_to_line_c[c][ft_line]                                                # buses connected to bus i (bus i is present in 'from' column)
    tf_bus  = idx_from_line_c[c][tf_line]                                              # buses connected to bus i (bus i is present in 'to' column)

    b_lines  = union(ft_line,tf_line)                                            # indexes of all lines connected to bus (b) i
    b_cbuses = union(ft_bus,tf_bus)                                              # buses connected to bus i

    gij_line = real(yij_line_c[c][b_lines,1])
    bij_line = imag(yij_line_c[c][b_lines,1])

    gij_line_sh = real(yij_line_sh_c[c][b_lines,1])
    bij_line_sh = imag(yij_line_sh_c[c][b_lines,1])
      smax_line = line_smax_c[c][b_lines,1]

    # tp_rt     = vcat(tap_ratio_c[c][ft_line],tap_ratio_c[c][tf_line])
    # tp_rt_min = vcat(tap_ratio_min_c[c][ft_line],tap_ratio_min_c[c][tf_line])
    # tp_rt_max = vcat(tap_ratio_max_c[c][ft_line],tap_ratio_max_c[c][tf_line])
    # from_col  = idx_from_line_c[c][b_lines,1]
    # to_col    = idx_to_line_c[c][b_lines,1]
    bus       = repeat([bus_num],telem)
    # iTap      = idx_tapp[b_lines,end]

    push!(node_data_c,node_c(bus,b_cbuses,b_lines,gij_line_sh,gij_line,bij_line_sh,bij_line,smax_line))

   end
end
node_data_contin =[]

for i in 1:nCont
    # push!(node_data_contin, node_data_c[i+(nLines-2)*(i-1):i+(nLines-2)*(i-1)+(nLines-2)])
    push!(node_data_contin, node_data_c[i+(nBus-1)*(i-1):nBus*i])
end


return node_data_contin
end


function load_data(nLoads,nw_loads,rheader_loads)
bus_data_lsheet  = [nw_loads[j].load_bus_num for j in 1:nLoads]                  # Buses order in load sheet
cost_flex_load        = [nw_loads[j].load_ShCost for j in 1:nLoads]
# idx_Gs_lsheet = findall3(x->x=="Gs (MW)",rheader_loads)
# idx_Bs_lsheet = findall3(x->x=="Bs (MVAr)",rheader_loads)
idx_St_lsheet = findall3(x->x=="ShFrOK",rheader_loads)                            # Index of status in load sheet!

iFl     =  findall3(x->x==1,rdata_loads[:,idx_St_lsheet])                           # Index of flexible loads
nFl     =  size(findall3(x->x==1,rdata_loads[:,idx_St_lsheet]),1)                   # Number of flexible loads in a system
nd_fl   =  convert.(Int64,rdata_loads[findall3(x->x==1,rdata_loads[:,idx_St_lsheet]),1]) # Nodes to which flexible loads are connected. Node data is taken from the power profile sheet.
rdata_loads_bus=convert.(Int64,rdata_loads[:,1])
nd_fl_bus   =  [indexin(nd_fl[i],rdata_loads_bus)[1] for i in 1:nFl if nFl!=0]
return bus_data_lsheet,cost_flex_load,idx_St_lsheet,iFl,nFl,nd_fl,nd_fl_bus
end


function gen_data(nGens,nTP,nw_gens)
dim_Gen    = (length(1:nGens),length(1:nTP))
Pg_max     = zeros(Float64,dim_Gen)
Pg_min     = zeros(Float64,dim_Gen)
Qg_max     = zeros(Float64,dim_Gen)
Qg_min     = zeros(Float64,dim_Gen)
cA_gen         = zeros(Float64,dim_Gen)
cB_gen         = zeros(Float64,dim_Gen)
cC_gen         = zeros(Float64,dim_Gen)
bus_data_gsheet = [nw_gens[j].gen_bus_num for j in 1:nGens]                      # Buses order in gen sheet
pg_max = [nw_gens[j].gen_P_max for j in 1:nGens]                                 # Maximum and minimum values are in SI units
pg_min = [nw_gens[j].gen_P_min for j in 1:nGens]
qg_max = [nw_gens[j].gen_Qg_max for j in 1:nGens]
qg_min = [nw_gens[j].gen_Qg_min for j in 1:nGens]

# bus_data_gcost = [nw_gens[j].gen_bus_num for j in 1:nGens]
cost_a_gen = [nw_gens[j].gcost_a for j in 1:nGens]                              # Cost of generation (quadratic and linear) is in SI units
cost_b_gen = [nw_gens[j].gcost_b for j in 1:nGens]
cost_c_gen = [nw_gens[j].gcost_c for j in 1:nGens]

return  Pg_max,Pg_min,Qg_max,Qg_min,cA_gen,cB_gen,cC_gen,bus_data_gsheet,pg_max,pg_min,qg_max,qg_min,cost_a_gen,cost_b_gen,cost_c_gen
end


function storage_data(rheader_storage,nTP,nw_storage)
idx_St_Strsheet = findall3(x->x=="Status",rheader_storage)                        # Index of Status (St) in Storage (Str) Sheet
iStr_active     = findall3(x->x==1,rdata_storage[:,idx_St_Strsheet])
nStr_active     = size(findall3(x->x==1,rdata_storage[:,idx_St_Strsheet]),1)                   # Number of Active Storages in a system
nd_Str_active   = convert.(Int64,rdata_storage[findall3(x->x==1,rdata_storage[:,idx_St_Strsheet]),1])
# ------------------- Formatting of Storage Cost Data---------------------------
#-------------------------------------------------------------------------------
dim_Str    = (length(1:nStr_active),length(1:nTP))
cA_str     = zeros(Float64,dim_Str)
cB_str     = zeros(Float64,dim_Str)
cC_str     = zeros(Float64,dim_Str)

bus_data_Ssheet  = [nw_storage[iStr_active[j,1]].storage_bus for j in 1:nStr_active]                   # Buses order in storage sheet
# bus_data_Strcost = [nw_Strcost[iStr_active[j,1]].str_cost_bus for j in 1:nStr_active]
cost_a_str = [nw_storage[iStr_active[j,1]].storage_cost_a for j in 1:nStr_active]                # Here, if the time step is not hour and cost is given in $/hr, then do we have to multiply with the step or not?
cost_b_str = [nw_storage[iStr_active[j,1]].storage_cost_b for j in 1:nStr_active]
cost_c_str = [nw_storage[iStr_active[j,1]].storage_cost_c for j in 1:nStr_active]

return idx_St_Strsheet,iStr_active,nStr_active,nd_Str_active,bus_data_Ssheet,cost_a_str,cost_b_str,cost_c_str
end

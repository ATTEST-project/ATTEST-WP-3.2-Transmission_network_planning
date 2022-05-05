#------------------- Formatting of Lines Data ----------------------------------
#-------------------------------------------------------------------------------
for i in 1:nLines                                                                # nLines = nTrsf + nTransmission lines
    push!(idx_from_line,array_lines[i].line_from)                                # Saving 'from' end of lines in a vector
    push!(idx_to_line,array_lines[i].line_to)                                    # Saving 'to' end of lines in a vector
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

# nTrsf = size(findall(x->x!=0.0,tap_ratio),1)
#---------------------- Saving the indices of transformer ----------------------
# dLines = [idx_from_trans idx_to_trans 1:nTrans tap_ratio]
#
#     global idx_tap = []
#     global ctr = 0
#     for i in 1:size(dLines,1)
#         tap = dLines[i,4]
#         if tap !=0.0                                                             # Transformer branch
#             global  ctr = ctr+1
#             push!(idx_tap,ctr)
#         elseif tap ==0.0                                                         # Transmission/Distribution line
#             push!(idx_tap,0)
#         end
#     end
# dLines = [dLines idx_tap]

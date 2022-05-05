# -*- coding: utf-8 -*-
"""
Created on Fri Mar 18 10:27:16 2022

@author: p96677wk

parallel lines
"""
from collections import defaultdict


def find_paraline(mpc):
    pre_busF_number = []
    branch = mpc["branch"]
    new_bra_no = [0]*mpc['NoBranch']
    for xbr in range(mpc['NoBranch']):
        new_bra_no[xbr] = xbr
        busF_number = branch["F_BUS"][xbr]
        
        # find all branch number from this bus
        braF_number = [i for i,x in enumerate(branch["F_BUS"]) if x==busF_number]

        
        # find the end bus number for each branch
        bra_end = []
        for xf in range(len(braF_number)):
            bra_no = braF_number[xf]
            bra_end.append( branch["T_BUS"][bra_no])


        para_line = defaultdict(list)
        # find parallel lines
        for i,item in enumerate(bra_end):
            # record values of end_bus_number and original branch number
            para_line[item].append(braF_number[i])
            
            if len(para_line[item]) > 1:
                
                for xi in range(len(para_line[item]) ):
                    new_bra_no[para_line[item][xi]] = para_line[item][0]
            
            
            
    # print("new_bra_no" ,new_bra_no)    
    
    return new_bra_no



def shift_line_position(mpc, new_bra_no, ci):
    
    if mpc["NoBranch"] == len(ci):
        ci_shifted = ci
    else:
        
        ci_shifted = []
        
        for xbr in range(len(ci)):
            if xbr == new_bra_no[xbr] :
               ci_shifted.append(ci[xbr]) 
               
            else:
                ci_shifted.append([])
    
                
                ci_shifted[new_bra_no[xbr]] += ci[xbr]
             
    
        ci_shifted = list(filter(None, ci_shifted))
    
    
    
    return ci_shifted



def recover_line_position(new_bra_no, ci_shifted):
    
    ci_recover = []
    for xbr in range(len(new_bra_no)):
        if xbr == new_bra_no[xbr]:
            ci_recover.append(ci_shifted[xbr])
            
        else:
            ci_shifted.insert(xbr,[])
            # get total number of parallel lines
            no_para_line = new_bra_no.count(new_bra_no[xbr])
            
            # average values for parallel lines
            temp = ci_shifted[new_bra_no[xbr]] / no_para_line
            
            ci_recover.append( temp )
            ci_recover[new_bra_no[xbr]] = temp
            
    
    return ci_recover
    
            
                
    
    

                

# new_bra_no = find_paraline(mpc)  
# ci_shifted = shift_line_position(new_bra_no, ci)    
# ci_recover = recover_line_position(new_bra_no, ci_shifted)
                           
            
            
            
            
            
        

            
       
        
    
    
    
    
    # return 
# ramp_rate=[array_gens[i].gen_ramp_30./sbase for i in 1:nGens]
ramp_rate=2
# for c in 1:nCont
#     for s in 1:nSc
#         for t in 1:nTP
#             for i in 1:nGens
#             # for i in 3:5
#             if t>1
#             @NLconstraint(acopf,-ramp_rate[i]<=(Pg[s,t-1,i]-Pg[s,t,i])<=ramp_rate[i])
#         end
#         end
#     end
# end
@constraint(acopf, [s=1:nSc,t=1:nTP,i=1:nGens;t>1],
-ramp_rate<=(Pg[s,t-1,i]-Pg[s,t,i])<=ramp_rate
)

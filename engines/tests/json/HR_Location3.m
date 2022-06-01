function mpc = Location3
%LOCATION3
%   PSS(R)E 33 RAW created by rawd33  FRI, MAR 26 2021   8:39
%   CREATED BY NETVISION RAW CONVERTER FROM FILES: NDC_2020-09-2
%   , BEGIN BUS DATA
%
%   Converted by MATPOWER 7.1 using PSSE2MPC on 04-May-2022
%   from 'Location3.raw' using PSS/E rev 33 format.
%
%   WARNINGS:
%       Conversion explicitly using PSS/E revision 33
%       Skipped 2 lines of zone data.
%
%   See CASEFORMAT for details on the MATPOWER case file format.

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	0	0	0	0	8	1.05185	0	400	1	1.1	0.9;
	2	1	-140.1	52.3	0	0	8	1.08856	0.4333	220	1	1.1	0.9;
	3	1	-3.2	18.7	0	0	8	1.09418	0.0635	220	1	1.1	0.9;
	4	1	53.9	9.7	0	0	8	1.06347	-1.7595	110	1	1.1	0.9;
	5	1	116.4	-14.8	0	0	8	1.06483	-1.7576	110	1	1.1	0.9;
	6	1	59.6	12	0	0	8	1.06424	-1.7901	110	1	1.1	0.9;
	7	1	22.2	4.8	0	0	8	1.06822	-1.7966	110	1	1.1	0.9;
	8	1	51.4	4.7	0	0	8	1.06365	-1.4249	110	1	1.1	0.9;
	9	1	0.4	-1.7	0	0	8	1.06413	-1.6129	110	1	1.1	0.9;
	10	2	32.3	6.6	0	0	8	1.07	-1.5764	110	1	1.1	0.9;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	95.224	44.966	9999	-9999	1.05185	100	1	9999	-9999	0	0	0	0	0	0	0	0	0	0	0;
	10	54.464	26.246	79	-27	1.07	86	1	72	30	0	0	0	0	0	0	0	0	0	0	0;
	10	32.085	15.461	50	-10	1.07	83	1	78	16	0	0	0	0	0	0	0	0	0	0	0;
	10	11.951	5.759	19	-34.4	1.07	47.6	1	40	12	0	0	0	0	0	0	0	0	0	0	0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	2	3	0.00436364	0.0223636	0.03552	311	0	0	0	0	1	-360	360;
	4	6	0.00338843	0.0114876	0.00111	123	0	0	0	0	1	-360	360;
	4	6	0.00338843	0.0118182	0.00112	123	0	0	0	0	1	-360	360;
	4	8	0.00300826	0.0218099	0.00396	300	0	0	0	0	1	-360	360;
	4	8	0.00300826	0.0218099	0.00396	300	0	0	0	0	1	-360	360;
	5	6	0.021124	0.0739339	0.00701	123	0	0	0	0	1	-360	360;
	5	6	0.021124	0.0739339	0.00701	123	0	0	0	0	1	-360	360;
	5	10	0.0137355	0.0686777	0.01213	230	0	0	0	0	1	-360	360;
	6	9	0.00644628	0.0220248	0.00216	123	0	0	0	0	1	-360	360;
	6	10	0.00872727	0.0298182	0.00289	123	0	0	0	0	1	-360	360;
	6	10	0.00872727	0.0298182	0.00289	123	0	0	0	0	1	-360	360;
	7	10	0.00413223	0.0206612	0.00151	140	0	0	0	0	1	-360	360;
	8	9	0.00644628	0.0220248	0.00216	123	0	0	0	0	1	-360	360;
	1	3	0.00036456	0.0317479	0	400	0	0	0.947619048	0.46	1	-360	360;
	1	8	0.00052633	0.0407299	0	300	0	0	0.99	0	1	-360	360;
	1	8	0.00054233	0.0407964	0	300	0	0	0.99	0	1	-360	360;
	2	5	0.00154622	0.070383	0	150	0	0	1.02826087	0	1	-360	360;
	2	5	0.00164444	0.0699807	0	150	0	0	1.02826087	0	1	-360	360;
];

%% bus names
mpc.bus_name = {
	'BUS1        ';
	'BUS2        ';
	'BUS3        ';
	'BUS4        ';
	'BUS5        ';
	'BUS6        ';
	'BUS7        ';
	'BUS8        ';
	'BUS9        ';
	'BUS10       ';
};
%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	0	0	2	31	0;
	2	0	0	2	52	0;
	2	0	0	2	23		0;
	2	0	0	2	44		0;
];
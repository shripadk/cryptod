// Written in the D programming language

/*	Copyright Andrey A Popov 2012
 * 
 *	Permission is hereby granted, free of charge, to any person or organization
 *	obtaining a copy of the software and accompanying documentation covered by
 *	this license (the "Software") to use, reproduce, display, distribute,
 *	execute, and transmit the Software, and to prepare derivative works of the
 *	Software, and to permit third-parties to whom the Software is furnished to
 *	do so, all subject to the following:
 *	
 *	The copyright notices in the Software and this entire statement, including
 *	the above license grant, this restriction and the following disclaimer,
 *	must be included in all copies of the Software, in whole or in part, and
 *	all derivative works of the Software, unless such copies or derivative
 *	works are solely in the form of machine-executable object code generated by
 *	a source language processor.
 *	
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
 *	SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
 *	FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 *	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *	DEALINGS IN THE SOFTWARE.
 */

/**
 * Authors: Andrey A. Popov, andrey.anat.popov@gmail.com
 */

module cryptod.prng.mersennetwister;

import cryptod.prng.prng;

class MersenneTwister : PRNG
{
	private:
	const upperbit  = 0b10000000000000000000000000000000;
	const lowerbits = 0b01111111111111111111111111111111;

	uint[624] MT;
	short index = 0;
	
	void generate()
	{
		for(uint i = 0; i < 624; i++)
		{
			uint y = (MT[i]&upperbit) + (MT[(i+1)%624]&lowerbits);
			MT[i] = MT[(i + 397)%624] ^ y>>1;
			if(y % 2 == 1)
			{
				MT[i] = MT[i] ^ 0x9908b0df;
			}
		}
	}
	
	void init(uint seed)
	{
		MT[0] = seed;
		for(uint i = 1; i < 624; i++)
		{ 
			MT[i] = 0x6c078965 * (MT[i-1] ^ (MT[i-1]>>30)) + i;
		}
	}
		
	void init(uint[] seeds)
	{
		uint i, j, k;
		init(19650218u);
		i=1; j=0;
		k = (624 > seeds.length ? 624 : seeds.length);
	    for (; k; k--) {
	        MT[i] = (MT[i] ^ ((MT[i-1] ^ (MT[i-1] >> 30)) * 1664525u)) + seeds[j] + j;
	        i++; j++;
	        if (i >= 624) { MT[0] = MT[623]; i=1; }
	        if (j >= seeds.length) j=0;
	    }
	    for (k = 623; k != 0; k--) {
	        MT[i] = (MT[i] ^ ((MT[i-1] ^ (MT[i-1] >> 30)) * 1566083941u)) - i;
	        i++;
	        if (i >= 624) { MT[0] = MT[623]; i=1; }
	    }
		
		MT[0] = upperbit;
	}
	
	public:
	
	this(uint seed) { init(seed); }
	
	this(uint[] seeds) { init(seeds); }
	
	this() { init(5489); }
	
	uint getNextInt()
	{
		if(index==0)
			generate();
			
		uint y = MT[index];
		y = y ^ (y>>11);
		y = y ^ ((y<<7)&0x9d2c5680);
		y = y ^ ((y<<15)&0xefc60000);
		y = y ^ (y>>18);
		
		index = (index + 1)%624;
		
		return y;
	}
}

unittest
{
	uint[] testVectors = [
	1067595299,  955945823,  477289528, 4107218783, 4228976476, 
	3344332714, 3355579695,  227628506,  810200273, 2591290167, 
	2560260675, 3242736208,  646746669, 1479517882, 4245472273, 
	1143372638, 3863670494, 3221021970, 1773610557, 1138697238, 
	1421897700, 1269916527, 2859934041, 1764463362, 3874892047, 
	3965319921,   72549643, 2383988930, 2600218693, 3237492380, 
	2792901476,  725331109,  605841842,  271258942,  715137098, 
	3297999536, 1322965544, 4229579109, 1395091102, 3735697720, 
	2101727825, 3730287744, 2950434330, 1661921839, 2895579582, 
	2370511479, 1004092106, 2247096681, 2111242379, 3237345263, 
	4082424759,  219785033, 2454039889, 3709582971,  835606218, 
	2411949883, 2735205030,  756421180, 2175209704, 1873865952, 
	2762534237, 4161807854, 3351099340,  181129879, 3269891896, 
	 776029799, 2218161979, 3001745796, 1866825872, 2133627728, 
	  34862734, 1191934573, 3102311354, 2916517763, 1012402762, 
	2184831317, 4257399449, 2899497138, 3818095062, 3030756734, 
	1282161629,  420003642, 2326421477, 2741455717, 1278020671, 
	3744179621,  271777016, 2626330018, 2560563991, 3055977700, 
	4233527566, 1228397661, 3595579322, 1077915006, 2395931898, 
	1851927286, 3013683506, 1999971931, 3006888962, 1049781534, 
	1488758959, 3491776230,  104418065, 2448267297, 3075614115, 
	3872332600,  891912190, 3936547759, 2269180963, 2633455084, 
	1047636807, 2604612377, 2709305729, 1952216715,  207593580, 
	2849898034,  670771757, 2210471108,  467711165,  263046873, 
	3569667915, 1042291111, 3863517079, 1464270005, 2758321352, 
	3790799816, 2301278724, 3106281430,    7974801, 2792461636, 
	 555991332,  621766759, 1322453093,  853629228,  686962251, 
	1455120532,  957753161, 1802033300, 1021534190, 3486047311, 
	1902128914, 3701138056, 4176424663, 1795608698,  560858864, 
	3737752754, 3141170998, 1553553385, 3367807274,  711546358, 
	2475125503,  262969859,  251416325, 2980076994, 1806565895, 
	 969527843, 3529327173, 2736343040, 2987196734, 1649016367, 
	2206175811, 3048174801, 3662503553, 3138851612, 2660143804, 
	1663017612, 1816683231,  411916003, 3887461314, 2347044079, 
	1015311755, 1203592432, 2170947766, 2569420716,  813872093, 
	1105387678, 1431142475,  220570551, 4243632715, 4179591855, 
	2607469131, 3090613241,  282341803, 1734241730, 1391822177, 
	1001254810,  827927915, 1886687171, 3935097347, 2631788714, 
	3905163266,  110554195, 2447955646, 3717202975, 3304793075, 
	3739614479, 3059127468,  953919171, 2590123714, 1132511021, 
	3795593679, 2788030429,  982155079, 3472349556,  859942552, 
	2681007391, 2299624053,  647443547,  233600422,  608168955, 
	3689327453, 1849778220, 1608438222, 3968158357, 2692977776, 
	2851872572,  246750393, 3582818628, 3329652309, 4036366910, 
	1012970930,  950780808, 3959768744, 2538550045,  191422718, 
	2658142375, 3276369011, 2927737484, 1234200027, 1920815603, 
	3536074689, 1535612501, 2184142071, 3276955054,  428488088, 
	2378411984, 4059769550, 3913744741, 2732139246,   64369859, 
	3755670074,  842839565, 2819894466, 2414718973, 1010060670, 
	1839715346, 2410311136,  152774329, 3485009480, 4102101512, 
	2852724304,  879944024, 1785007662, 2748284463, 1354768064, 
	3267784736, 2269127717, 3001240761, 3179796763,  895723219, 
	 865924942, 4291570937,   89355264, 1471026971, 4114180745, 
	3201939751, 2867476999, 2460866060, 3603874571, 2238880432, 
	3308416168, 2072246611, 2755653839, 3773737248, 1709066580, 
	4282731467, 2746170170, 2832568330,  433439009, 3175778732, 
	  26248366, 2551382801,  183214346, 3893339516, 1928168445, 
	1337157619, 3429096554, 3275170900, 1782047316, 4264403756, 
	1876594403, 4289659572, 3223834894, 1728705513, 4068244734, 
	2867840287, 1147798696,  302879820, 1730407747, 1923824407, 
	1180597908, 1569786639,  198796327,  560793173, 2107345620, 
	2705990316, 3448772106, 3678374155,  758635715,  884524671, 
	 486356516, 1774865603, 3881226226, 2635213607, 1181121587, 
	1508809820, 3178988241, 1594193633, 1235154121,  326117244, 
	2304031425,  937054774, 2687415945, 3192389340, 2003740439, 
	1823766188, 2759543402,   10067710, 1533252662, 4132494984, 
	  82378136,  420615890, 3467563163,  541562091, 3535949864, 
	2277319197, 3330822853, 3215654174, 4113831979, 4204996991, 
	2162248333, 3255093522, 2219088909, 2978279037,  255818579, 
	2859348628, 3097280311, 2569721123, 1861951120, 2907080079, 
	2719467166,  998319094, 2521935127, 2404125338,  259456032, 
	2086860995, 1839848496, 1893547357, 2527997525, 1489393124, 
	2860855349,   76448234, 2264934035,  744914583, 2586791259, 
	1385380501,   66529922, 1819103258, 1899300332, 2098173828, 
	1793831094,  276463159,  360132945, 4178212058,  595015228, 
	 177071838, 2800080290, 1573557746, 1548998935,  378454223, 
	1460534296, 1116274283, 3112385063, 3709761796,  827999348, 
	3580042847, 1913901014,  614021289, 4278528023, 1905177404, 
	  45407939, 3298183234, 1184848810, 3644926330, 3923635459, 
	1627046213, 3677876759,  969772772, 1160524753, 1522441192, 
	 452369933, 1527502551,  832490847, 1003299676, 1071381111, 
	2891255476,  973747308, 4086897108, 1847554542, 3895651598, 
	2227820339, 1621250941, 2881344691, 3583565821, 3510404498, 
	 849362119,  862871471,  797858058, 2867774932, 2821282612, 
	3272403146, 3997979905,  209178708, 1805135652,    6783381, 
	2823361423,  792580494, 4263749770,  776439581, 3798193823, 
	2853444094, 2729507474, 1071873341, 1329010206, 1289336450, 
	3327680758, 2011491779,   80157208,  922428856, 1158943220, 
	1667230961, 2461022820, 2608845159,  387516115, 3345351910, 
	1495629111, 4098154157, 3156649613, 3525698599, 4134908037, 
	 446713264, 2137537399, 3617403512,  813966752, 1157943946, 
	3734692965, 1680301658, 3180398473, 3509854711, 2228114612, 
	1008102291,  486805123,  863791847, 3189125290, 1050308116, 
	3777341526, 4291726501,  844061465, 1347461791, 2826481581, 
	 745465012, 2055805750, 4260209475, 2386693097, 2980646741, 
	 447229436, 2077782664, 1232942813, 4023002732, 1399011509, 
	3140569849, 2579909222, 3794857471,  900758066, 2887199683, 
	1720257997, 3367494931, 2668921229,  955539029, 3818726432, 
	1105704962, 3889207255, 2277369307, 2746484505, 1761846513, 
	2413916784, 2685127085, 4240257943, 1166726899, 4215215715, 
	3082092067, 3960461946, 1663304043, 2087473241, 4162589986, 
	2507310778, 1579665506,  767234210,  970676017,  492207530, 
	1441679602, 1314785090, 3262202570, 3417091742, 1561989210, 
	3011406780, 1146609202, 3262321040, 1374872171, 1634688712, 
	1280458888, 2230023982,  419323804, 3262899800,   39783310, 
	1641619040, 1700368658, 2207946628, 2571300939, 2424079766, 
	 780290914, 2715195096, 3390957695,  163151474, 2309534542, 
	1860018424,  555755123,  280320104, 1604831083, 2713022383, 
	1728987441, 3639955502,  623065489, 3828630947, 4275479050, 
	3516347383, 2343951195, 2430677756,  635534992, 3868699749, 
	 808442435, 3070644069, 4282166003, 2093181383, 2023555632, 
	1568662086, 3422372620, 4134522350, 3016979543, 3259320234, 
	2888030729, 3185253876, 4258779643, 1267304371, 1022517473, 
	 815943045,  929020012, 2995251018, 3371283296, 3608029049, 
	2018485115,  122123397, 2810669150, 1411365618, 1238391329, 
	1186786476, 3155969091, 2242941310, 1765554882,  279121160, 
	4279838515, 1641578514, 3796324015,   13351065,  103516986, 
	1609694427,  551411743, 2493771609, 1316337047, 3932650856, 
	4189700203,  463397996, 2937735066, 1855616529, 2626847990, 
	  55091862, 3823351211,  753448970, 4045045500, 1274127772, 
	1124182256,   92039808, 2126345552,  425973257,  386287896, 
	2589870191, 1987762798, 4084826973, 2172456685, 3366583455, 
	3602966653, 2378803535, 2901764433, 3716929006, 3710159000, 
	2653449155, 3469742630, 3096444476, 3932564653, 2595257433, 
	 318974657, 3146202484,  853571438,  144400272, 3768408841, 
	 782634401, 2161109003,  570039522, 1886241521,   14249488, 
	2230804228, 1604941699, 3928713335, 3921942509, 2155806892, 
	 134366254,  430507376, 1924011722,  276713377,  196481886, 
	3614810992, 1610021185, 1785757066,  851346168, 3761148643, 
	2918835642, 3364422385, 3012284466, 3735958851, 2643153892, 
	3778608231, 1164289832,  205853021, 2876112231, 3503398282, 
	3078397001, 3472037921, 1748894853, 2740861475,  316056182, 
	1660426908,  168885906,  956005527, 3984354789,  566521563, 
	1001109523, 1216710575, 2952284757, 3834433081, 3842608301, 
	2467352408, 3974441264, 3256601745, 1409353924, 1329904859, 
	2307560293, 3125217879, 3622920184, 3832785684, 3882365951, 
	2308537115, 2659155028, 1450441945, 3532257603, 3186324194, 
	1225603425, 1124246549,  175808705, 3009142319, 2796710159, 
	3651990107,  160762750, 1902254979, 1698648476, 1134980669, 
	 497144426, 3302689335, 4057485630, 3603530763, 4087252587, 
	 427812652,  286876201,  823134128, 1627554964, 3745564327, 
	2589226092, 4202024494,   62878473, 3275585894, 3987124064, 
	2791777159, 1916869511, 2585861905, 1375038919, 1403421920, 
	  60249114, 3811870450, 3021498009, 2612993202,  528933105, 
	2757361321, 3341402964, 2621861700,  273128190, 4015252178, 
	3094781002, 1621621288, 2337611177, 1796718448, 1258965619, 
	4241913140, 2138560392, 3022190223, 4174180924,  450094611, 
	3274724580,  617150026, 2704660665, 1469700689, 1341616587, 
	 356715071, 1188789960, 2278869135, 1766569160, 2795896635, 
	  57824704, 2893496380, 1235723989, 1630694347, 3927960522, 
	 428891364, 1814070806, 2287999787, 4125941184, 3968103889, 
	3548724050, 1025597707, 1404281500, 2002212197,   92429143, 
	2313943944, 2403086080, 3006180634, 3561981764, 1671860914, 
	1768520622, 1803542985,  844848113, 3006139921, 1410888995, 
	1157749833, 2125704913, 1789979528, 1799263423,  741157179, 
	2405862309,  767040434, 2655241390, 3663420179, 2172009096, 
	2511931187, 1680542666,  231857466, 1154981000,  157168255, 
	1454112128, 3505872099, 1929775046, 2309422350, 2143329496, 
	2960716902,  407610648, 2938108129, 2581749599,  538837155, 
	2342628867,  430543915,  740188568, 1937713272, 3315215132, 
	2085587024, 4030765687,  766054429, 3517641839,  689721775, 
	1294158986, 1753287754, 4202601348, 1974852792,   33459103, 
	3568087535, 3144677435, 1686130825, 4134943013, 3005738435, 
	3599293386,  426570142,  754104406, 3660892564, 1964545167, 
	 829466833,  821587464, 1746693036, 1006492428, 1595312919, 
	1256599985, 1024482560, 1897312280, 2902903201,  691790057, 
	1037515867, 3176831208, 1968401055, 2173506824, 1089055278, 
	1748401123, 2941380082,  968412354, 1818753861, 2973200866, 
	3875951774, 1119354008, 3988604139, 1647155589, 2232450826, 
	3486058011, 3655784043, 3759258462,  847163678, 1082052057, 
	 989516446, 2871541755, 3196311070, 3929963078,  658187585, 
	3664944641, 2175149170, 2203709147, 2756014689, 2456473919, 
	3890267390, 1293787864, 2830347984, 3059280931, 4158802520, 
	1561677400, 2586570938,  783570352, 1355506163,   31495586, 
	3789437343, 3340549429, 2092501630,  896419368,  671715824, 
	3530450081, 3603554138, 1055991716, 3442308219, 1499434728, 
	3130288473, 3639507000,   17769680, 2259741420,  487032199, 
	4227143402, 3693771256, 1880482820, 3924810796,  381462353, 
	4017855991, 2452034943, 2736680833, 2209866385, 2128986379, 
	 437874044,  595759426,  641721026, 1636065708, 3899136933, 
	 629879088, 3591174506,  351984326, 2638783544, 2348444281, 
	2341604660, 2123933692,  143443325, 1525942256,  364660499, 
	 599149312,  939093251, 1523003209,  106601097,  376589484, 
	1346282236, 1297387043,  764598052, 3741218111,  933457002, 
	1886424424, 3219631016,  525405256, 3014235619,  323149677, 
	2038881721, 4100129043, 2851715101, 2984028078, 1888574695, 
	2014194741, 3515193880, 4180573530, 3461824363, 2641995497, 
	3179230245, 2902294983, 2217320456, 4040852155, 1784656905, 
	3311906931,   87498458, 2752971818, 2635474297, 2831215366, 
	3682231106, 2920043893, 3772929704, 2816374944,  309949752, 
	2383758854,  154870719,  385111597, 1191604312, 1840700563, 
	 872191186, 2925548701, 1310412747, 2102066999, 1504727249, 
	3574298750, 1191230036, 3330575266, 3180292097, 3539347721, 
	 681369118, 3305125752, 3648233597,  950049240, 4173257693, 
	1760124957,  512151405,  681175196,  580563018, 1169662867, 
	4015033554, 2687781101,  699691603, 2673494188, 1137221356, 
	 123599888,  472658308, 1053598179, 1012713758, 3481064843, 
	3759461013, 3981457956, 3830587662, 1877191791, 3650996736, 
	 988064871, 3515461600, 4089077232, 2225147448, 1249609188, 
	2643151863, 3896204135, 2416995901, 1397735321, 3460025646];
	
	MersenneTwister mt = new MersenneTwister([0x123, 0x234, 0x345, 0x456]);
	for(uint i = 0; i < 1000; i++)
	{
		assert(testVectors[i] == mt.getNextInt());
	}
	import cryptod.tests.prngtest;
	import std.datetime;
	
	ulong t = Clock.currTime().stdTime();
	
	uint[] key = [(t&0xffff),(t>>1)&0xffff,(t>>2)&0xffff,(t>>3)&0xffff,(t>>4)&0xffff,(t>>5)&0xffff,(t>>6)&0xffff,(t>>7)&0xffff
	,(t>>8)&0xffff,(t>>9)&0xffff,(t>>10)&0xffff,(t>>11)&0xffff,(t>>12)&0xffff,(t>>13)&0xffff,(t>>14)&0xffff,(t>>15)&0xffff];
	
	MersenneTwister mt2 = new MersenneTwister(key);
	
	FrequencyTest ft = new FrequencyTest(mt2);
	
	assert(ft.run());
	
	RunsTest rt = new RunsTest(mt2);
	
	assert(rt.run());
	
	import std.stdio;
	writeln("Mersenne Twister unittest passed.");
}
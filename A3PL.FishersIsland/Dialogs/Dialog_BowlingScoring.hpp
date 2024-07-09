/* #Duvyma
$[
	1.063,
	["bowling_scores",[[0,0,1,1],0.025,0.04,"GUI_GRID"],0,0,0],
	[1200,"static_picture",[1,"\A3PL_Bowling\scoring.paa",["0.355625 * safezoneW + safezoneX","0.17 * safezoneH + safezoneY","0.268125 * safezoneW","0.671 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1500,"lb_scores",[1,"",["0.469062 * safezoneW + safezoneX","0.353 * safezoneH + safezoneY","0.13006 * safezoneW","0.409 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1000,"text_header",[1,"Bowling Scores",["0.438125 * safezoneW + safezoneX","0.357 * safezoneH + safezoneY","0.113437 * safezoneW","0.022 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","1.5"],[]],
	[1600,"button_lane1",[1,"",["0.402031 * safezoneW + safezoneX","0.357 * safezoneH + safezoneY","0.0464063 * safezoneW","0.066 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1601,"button_lane2",[1,"",["0.402031 * safezoneW + safezoneX","0.423 * safezoneH + safezoneY","0.0464063 * safezoneW","0.066 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1602,"button_lane3",[1,"",["0.402031 * safezoneW + safezoneX","0.489 * safezoneH + safezoneY","0.0464063 * safezoneW","0.066 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1603,"button_lane4",[1,"",["0.402031 * safezoneW + safezoneX","0.555 * safezoneH + safezoneY","0.0464063 * safezoneW","0.066 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1604,"button_lane5",[1,"",["0.402031 * safezoneW + safezoneX","0.621 * safezoneH + safezoneY","0.0464063 * safezoneW","0.066 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1605,"button_lane6",[1,"",["0.402031 * safezoneW + safezoneX","0.687 * safezoneH + safezoneY","0.0464063 * safezoneW","0.066 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]]
]
*/


class A3PL_BowlingScoring
{
	idd = 11;
	movingEnable = 0;
	enableSimulation = 1;
	onLoad = "";
	
	class Controls
	{
	////////////////////////////////////////////////////////
	// GUI EDITOR OUTPUT START (by Caiden, v1.063, #Dajyny)
	////////////////////////////////////////////////////////
		class static_picture: RscPicture
		{
			idc = 1200;
			text = "\A3PL_Bowling\scoring.paa";
			x = 0.355625 * safezoneW + safezoneX;
			y = 0.17 * safezoneH + safezoneY;
			w = 0.268125 * safezoneW;
			h = 0.671 * safezoneH;
		};
		class lb_scores: RscListbox
		{
			idc = 1500;
			x = 0.469062 * safezoneW + safezoneX;
			y = 0.353 * safezoneH + safezoneY;
			w = 0.13006 * safezoneW;
			h = 0.409 * safezoneH;
			color[] = {0,0,0,1};
		};
		class text_header: RscText
		{
			idc = 1000;
			text = "Bowling Scores"; //--- ToDo: Localize;
			x = 0.438125 * safezoneW + safezoneX;
			y = 0.357 * safezoneH + safezoneY;
			w = 0.113437 * safezoneW;
			h = 0.022 * safezoneH;
			sizeEx = 1.5 * GUI_GRID_H;
		};
		class button_lane1: RscButton
		{
			idc = 1600;
			x = 0.402031 * safezoneW + safezoneX;
			y = 0.357 * safezoneH + safezoneY;
			w = 0.0464063 * safezoneW;
			h = 0.066 * safezoneH;
			action = "0 call A3PL_Bowling_BScoreScript;";
		};
		class button_lane2: RscButton
		{
			idc = 1601;
			x = 0.402031 * safezoneW + safezoneX;
			y = 0.423 * safezoneH + safezoneY;
			w = 0.0464063 * safezoneW;
			h = 0.066 * safezoneH;
			action = "1 call A3PL_Bowling_BScoreScript;";
		};
		class button_lane3: RscButton
		{
			idc = 1602;
			x = 0.402031 * safezoneW + safezoneX;
			y = 0.489 * safezoneH + safezoneY;
			w = 0.0464063 * safezoneW;
			h = 0.066 * safezoneH;
			action = "2 call A3PL_Bowling_BScoreScript;";
		};
		class button_lane4: RscButton
		{
			idc = 1603;
			x = 0.402031 * safezoneW + safezoneX;
			y = 0.555 * safezoneH + safezoneY;
			w = 0.0464063 * safezoneW;
			h = 0.066 * safezoneH;
			action = "3 call A3PL_Bowling_BScoreScript;";
		};
		class button_lane5: RscButton
		{
			idc = 1604;
			x = 0.402031 * safezoneW + safezoneX;
			y = 0.621 * safezoneH + safezoneY;
			w = 0.0464063 * safezoneW;
			h = 0.066 * safezoneH;
			action = "4 call A3PL_Bowling_BScoreScript;";
		};
		class button_lane6: RscButton
		{
			idc = 1605;
			x = 0.402031 * safezoneW + safezoneX;
			y = 0.687 * safezoneH + safezoneY;
			w = 0.0464063 * safezoneW;
			h = 0.066 * safezoneH;
			action = "5 call A3PL_Bowling_BScoreScript;";
		};
	////////////////////////////////////////////////////////
	// GUI EDITOR OUTPUT END
	////////////////////////////////////////////////////////


	};
};
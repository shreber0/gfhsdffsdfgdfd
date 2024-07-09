class Dialog_NewPlayer
{
	idd = 111;
	movingEnable = 0;
	enableSimulation = 1;
	onLoad = "";
	onUnload = "";
	class controls
	{
		class static_background: IGUIBack
		{
			idc = 2200;
			x = 0.345312 * safezoneW + safezoneX;
			y = 0.335 * safezoneH + safezoneY;
			w = 0.309375 * safezoneW;
			h = 0.275 * safezoneH;
		};
		class struc_header: RscStructuredText
		{
			idc = 1100;
			text = "Welcome to A3PL!<br />Our system has detected you are a new player<br />Please enter the first and last name for your new character!";
			x = 0.365937 * safezoneW + safezoneX;
			y = 0.346 * safezoneH + safezoneY;
			w = 0.268125 * safezoneW;
			h = 0.066 * safezoneH;
		};
		class static_firstname: RscText
		{
			idc = 1001;
			text = "Firstname:";
			x = 0.407187 * safezoneW + safezoneX;
			y = 0.456 * safezoneH + safezoneY;
			w = 0.0515625 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class static_lastname: RscText
		{
			idc = 1002;
			text = "Lastname:";
			x = 0.407187 * safezoneW + safezoneX;
			y = 0.5 * safezoneH + safezoneY;
			w = 0.0515625 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class edit_firstname: RscEdit
		{
			idc = 1400;
			x = 0.489687 * safezoneW + safezoneX;
			y = 0.456 * safezoneH + safezoneY;
			w = 0.103125 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class edit_lastname: RscEdit
		{
			idc = 1401;
			x = 0.489687 * safezoneW + safezoneX;
			y = 0.5 * safezoneH + safezoneY;
			w = 0.103125 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class button_submit: RscButton
		{
			idc = 1600;
			text = "Submit"; //--- ToDo: Localize;
			x = 0.463906 * safezoneW + safezoneX;
			y = 0.555 * safezoneH + safezoneY;
			w = 0.0670312 * safezoneW;
			h = 0.033 * safezoneH;
			action = "[] call A3PL_Player_NewPlayerSubmit;";
		};
	};
};

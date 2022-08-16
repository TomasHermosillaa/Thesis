#pragma rtGlobals=3		// Use modern global access method and strict wave access.
// This program has been written by the collaboration of all the members of the lab but Andres (08/04/2017)
// Panel working, ploting working, and step size working (only in the panel)
// not working SS and MP in the table. Problem is that the assignments of the data file pathway is wrong Data instead Analysis. 
//If htis probleem is solved, Step_time, ss, extenson after, direction and MP will be include in the table



//******************************************************** TAB & MENU ***********************************************************************
Menu "MT"
	"-"
	"Trace_Analysis", Initialize()//InitializeTraceAnalysis()
End
//******************************************************** END TAB & MENU ********************************************************************



//******************************************************** Two Main Funtions ******************************************************************

Function Initialize()
	Initialize_Variables()
	Trace_Panel()
end
//******************************************************** END Main Funtions *******************************************************************




//******************************************************** Global Variables*********************************************************************
Function Initialize_Variables()
	
	String newname0 = "L_2"
	String newname1="Mag_2"
	String newname2="Time_2"
	NewDataFolder root:Data
	MoveWave root:wave0,root:Data:$newname0
	MoveWave root:wave1,root:Data:$newname1
	MoveWave root:wave2,root:Data:$newname2
	NewDataFolder root:Analysis
	SetDataFolder root:Analysis
	Variable/G root:Analysis:DisplayNumber, root:Analysis:SmoothingFactor
	Variable/G root:Analysis:step_size, root:Analysis:total_extension
	Variable/G root:Analysis:step_up_or_down, root:Analysis:time_of_step
	Variable/G root:Analysis:DisplayNumber, root:Analysis:BiningFactor//nuevo
	Variable/G root:Analysis:DisplayNumber, root:Analysis:TotalBin//nuevo
	Variable/G root:Analysis:DisplayNumber, root:Analysis:StartBin//nuevo
	Variable/G root:Analysis:mag_position, root:Analysis:step_up_or_down, root:Analysis:time_of_step
	Variable/G root:Analysis:DisplayNumber, root:Analysis:BiningFactor2//nuevo
	Variable/G root:Analysis:DisplayNumber, root:Analysis:TotalBin2//nuevo
	Variable/G root:Analysis:DisplayNumber, root:Analysis:StartBin2//nuevo
	WAVE storage_wave
	if(WAVEEXISTS(storage_wave)==1)
		DoAlert 1, "Your Waves already exist.  Do you want to overwrite them?"
		if(V_flag==2)
			return 0
		endif
	endif
	Make/O/N=0 storage_wave	//step_size
	Make/O/N=0 extension_after_step
	Make/O/N=0 bead_number
	Make/O/N=0 MagnetPosition
	Make/O/N=0 step_direction
	Make/O/N=0 step_time
	
		DoAlert 1, "Step Size Analysis?"
		if(V_flag==1)
			Edit bead_number, step_time, storage_wave, extension_after_step, step_direction, MagnetPosition
		endif
end
//******************************************************** END Global Variables***********************************************************************





//******************************************************** PANEL **************************************************************************************

Function Trace_Panel()
	
	
	DoWindow/F/K PanelTheAnalizer  // IonelNuevo
	
	NewPanel/N=PanelTheAnalizer	/K=1/W=(900,60,1200,770)  as "Trace_Analysis" // Nuevo from Ionel's advise 
	SetVariable setcurrentcurveMT,pos={19,23},size={75,16}, proc=Display_MT_Recordings,title="curve",  font="Arial",fSize=12,fstyle=1, limits={1,10000,1},value= root:Analysis:DisplayNumber
	SetVariable SetSmoothingFactor,pos={116,23},size={100,18}, proc=Smoothing,title="Smooth",  font="Arial",fSize=12,fstyle=1, limits={1,10000,1},value= root:Analysis:SmoothingFactor
	SetVariable SetBinSize,pos={19,64},size={100,18}, proc=Make_Histo, title="Bin size", font="Arial",fSize=12,fstyle=1, limits={0.01,10000,1},value= root:Analysis:BiningFactor
	SetVariable TotalBins,pos={32,84},size={100,18}, proc=Make_Histo,title="N Bin",font="Arial",fSize=12,fstyle=1, limits={1,10000,1},value= root:Analysis:TotalBin
	SetVariable StartBins,pos={15,108},size={100,18}, proc=Make_Histo,title="Start Bin",font="Arial",fSize=12,fstyle=1, limits={1,10000,1},value= root:Analysis:StartBin
	
	ValDisplay valdisp1 title="Steps(nm)",size={130,18}, pos={19,148}, font="Arial",fSize=12,fstyle=1, value= #"root:Analysis:step_size"  		//Result SSize
	ValDisplay valdisp2 title="MagPos(mm)",size={130,18}, pos={150,148}, font="Arial",fSize=12,fstyle=1, value= #"root:Analysis:mag_position"	//Result MP
	Button HistogramButton,pos={155,64},size={100,18},proc=Make_Histo_Button,title="Histogram", font="Arial",fSize=12	//boton1
	Button PrintDataButton,pos={155,91},size={100,38},proc=Print_Data_Button,title="PrintData", font="Arial",fSize=12	//boton2
	
	
	Button PrintAccHistoButton,pos={155,200},size={100,18},proc=Print_AccHisto_Button,title="PrintAccHisto", font="Arial",fSize=12	//boton3 not working yet
	SetVariable SetBinSize2,pos={19,200},size={100,18}, proc=Print_AccHisto, title="Bin2 size", font="Arial",fSize=12,fstyle=1, limits={0.01,10000,1},value= root:Analysis:BiningFactor2
	SetVariable TotalBins2,pos={32,220},size={100,18}, proc=Print_AccHisto,title="N Bin2",font="Arial",fSize=12,fstyle=1, limits={1,10000,1},value= root:Analysis:TotalBin2
	SetVariable StartBins2,pos={15,240},size={100,18}, proc=Print_AccHisto,title="Start Bin2",font="Arial",fSize=12,fstyle=1, limits={-10,10000,1},value= root:Analysis:StartBin2
	
	Button RevButton,pos={17,276},size={90,18},title="<<Rev", font="Arial",fSize=12//botonA not working
	Button ExpButton,pos={107,276},size={90,18},title="<Expand>", font="Arial",fSize=12//botonB not working
	Button FwdButton,pos={198,276},size={90,18},title="Fwd>>", font="Arial",fSize=12//botonC not working
	
	
	
	SetDataFolder root:Analysis//nuevo
	Make/N=300/O 'Step1_Hist', fit_Step1_Hist
	Make/N=300/O 'Step2_Hist', fit_Step2_Hist
	Display/HOST=PanelTheAnalizer/N=FigPanel/VERT /W=(20,300,280,700) Step1_Hist, Step2_Hist, fit_Step1_Hist, fit_Step2_Hist 
		Label/W=PanelTheAnalizer#FigPanel left "\\F'Arial Black'\\Z12 nm"
		Label/W=PanelTheAnalizer#FigPanel bottom "\\F'Arial Black'\\Z12 #events"
		SetAxis/W=PanelTheAnalizer#FigPanel bottom 0.1,*
		//Frame style text well
		ModifyGraph/W=PanelTheAnalizer#FigPanel mirror=2, mirror(left)=2
		ModifyGraph/W=PanelTheAnalizer#FigPanel grid=1, grid(left)=1
		ModifyGraph/W=PanelTheAnalizer#FigPanel axThick(left)=2, axThick=2
		ModifyGraph/W=PanelTheAnalizer#FigPanel fSize=12,font="Arial Black", fStyle(left)=1,fSize(left)=12,font(left)="Arial Black"
		ModifyGraph/W=PanelTheAnalizer#FigPanel rgb(Step1_Hist)=(32768,40704,65280)//, lsize(Step1_Hist)=1.5
		ModifyGraph/W=PanelTheAnalizer#FigPanel rgb(Step2_Hist)=(65280,32768,32768)
		SetDataFolder root:Analysis//nuevo
		ModifyGraph/W=PanelTheAnalizer#FigPanel lstyle(fit_Step1_Hist)=3,rgb(fit_Step1_Hist)=(0,0,0)
		ModifyGraph/W=PanelTheAnalizer#FigPanel lsize(fit_Step2_Hist)=1.5,rgb(fit_Step2_Hist)=(0,0,0)
		ModifyGraph/W=PanelTheAnalizer#FigPanel gbRGB=(56797,56797,56797),frameStyle=7
		SetActiveSubwindow PanelTheAnalizer
		
		//TitleBox title0 title="F-Analyzer",fSize=20,fstyle=1, pos={126,14} 
		
End
//******************************************************** END PANEL ***********************************************************************



//******************************************************** BROWSE TRACES *************************************************************************
Function Display_MT_Recordings(ctrlName,varNum,varStr,varName) : SetVariableControl	//browse though the traces
	String ctrlName
	Variable varNum
	String varStr, varName
	SetDataFolder root:Data:
	NVAR DisplayNumber = root:Analysis:DisplayNumber
	NVAR ManualTick=root:Analysis:ManualTick
	String LengthPrefix, LengthWList, Length_Wave, ForcePrefix, ForceWList, Force_Wave, TimePrefix, TimeWList, Time_Wave, TraceList, NameInterpWave, NameInterpWaveX,commandstring
	Variable N,j
	
	
	 LengthPrefix = "L_"
	 ForcePrefix="Mag_"
	 TimePrefix = "Time_"	
	 LengthWList = WaveList(LengthPrefix+"*", ";","")
	 ForceWList =  WaveList(ForcePrefix+"*", ";","")
	 TimeWList = WaveList(TimePrefix+"*", ";","")
	
	if(WinType("MTAnalysis")==1) 
		DoWindow/F MTAnalysis 
		SetDrawLayer/W=MTAnalysis/K  UserFront
		TraceList = TraceNameList("MTAnalysis", ";", 1 )
		N = ItemsInList(TraceList,";")
		for(j=0; j<N; j+=1)
			RemoveFromGraph/Z/W=MTAnalysis $(StringFromList(j, TraceList,";"))
		endfor
		TraceList = TraceNameList("MTAnalysis", ";", 1 )	// do twice to get rid of both StepStats waves
		N = ItemsInList(TraceList,";")
		for(j=0; j<N; j+=1)
			RemoveFromGraph/Z/W=MTAnalysis $(StringFromList(j, TraceList,";"))
		endfor
	else
		DoWindow/K MTAnalysis
		Display/W=(0,0,550,400)
		DoWindow/C MTAnalysis
		SetWindow MTAnalysis,hook(testhook)=KeyboardMTPanelHook
		//SetWindow MTAnalysis,hook(testhook)=KeyboardPanelHook//This one was commented
	endif

	if(DisplayNumber>ItemsInList(TimeWList,";"))
		DisplayNumber-=1
	endif
	Length_Wave = StringFromList(DisplayNumber-1,LengthWList,";")
	Force_Wave = StringFromList(DisplayNumber-1,ForceWList,";")
	Time_Wave = StringFromList(DisplayNumber-1,TimeWList,";")
	AppendToGraph/W=MTAnalysis $Length_Wave vs $Time_Wave
	ModifyGraph/W=MTAnalysis axisEnab(left)={0.4,1}
	AppendToGraph/W=MTAnalysis/L=ForceAxis $Force_Wave vs $Time_Wave
	ModifyGraph freePos(ForceAxis)={0,kwFraction}
	ModifyGraph/W=MTAnalysis lblPosMode(ForceAxis)=2
	ModifyGraph/W=MTAnalysis rgb($Force_Wave)=(0,0,0)//, offset($Force_Wave)={0,shiftby}
	ModifyGraph/W=MTAnalysis rgb($Length_Wave)=(65535,49151,49151)
	ModifyGraph/W=MTAnalysis grid(ForceAxis)=1, axisEnab(ForceAxis)={0,0.35}
	ModifyGraph/W=MTAnalysis freePos(ForceAxis)={0,bottom}, lblPos(ForceAxis)=50				
	Label/W=MTAnalysis ForceAxis "Magnet Position (mm)"
	Label/W=MTAnalysis left "Length (nm)"
	Label/W=MTAnalysis bottom "Time (s)"
	ModifyGraph/W=MTAnalysis manTick(left)={0,ManualTick,0,0},manMinor(left)={0,0}
	ModifyGraph/W=MTAnalysis grid(left)=1, lblPosMode(left)=2, lblPos(left)=50	
	NameInterpWave = ReplaceString("L_", Length_Wave, "Drift_")
	NameInterpWaveX = ReplaceString("L_", Length_Wave, "DriftX_")
	WAVE/Z DriftWave = $NameInterpWave
	if(WaveExists(DriftWave))
		Appendtograph/W=MTAnalysis $NameInterpWave vs $NameInterpWaveX
		ModifyGraph/W=MTAnalysis marker=19
		commandstring="ModifyGraph/W=MTAnalysis mode("+NameInterpWave+ ")=3,rgb("+NameInterpWave+")=(1,39321,19939)"
		Execute commandstring
	endif
	showinfo/CP={0,1}
	Wavestats/Q $Length_Wave
	if((V_max-V_min)>1000)
		SetAxis left -50,1500 // para cambiar y-axis 
	endif
	
	SetWindow MTAnalysis, hook(MyHook) = MyWindowHook// Install window hook
End
//******************************************************** END BROWSING TRACES ***********************************************************************




//******************************************************** SMOOTHING ***********************************************************************

Function Smoothing(ctrlName,varNum,varStr,varName) : SetVariableControl	//browse filter 
	String ctrlName
	Variable varNum
	String varStr, varName
	
	NVAR SmthFactor = root:Analysis:SmoothingFactor
	
	Active_traces()
	SetDataFolder root:Analysis
	WAVE L_Active, Mag_Active, Time_Active
	
	Duplicate/O L_Active,Length_Smooth
	Smooth/M=0 SmthFactor, Length_Smooth
	RemoveFromGraph/Z Length_Smooth
	AppendToGraph/W=MTAnalysis Length_Smooth vs Time_Active
	ModifyGraph rgb(Length_Smooth)=(0,0,0)	//26214
end
//******************************************************** END SMOOTHING***********************************************************************



function test2()
	String Folder = GetDataFolder(1)
		print GetDataFolder(1)
	SetDataFolder root:Data
		print GetDataFolder(1)
	SetDataFolder Folder 
		print GetDataFolder(1)
end


Function Active_traces()
	String Folder = GetDataFolder(1)

	SetDataFolder root:Data: 
	NVAR DisplayNumber = root:Analysis:DisplayNumber
	////NVAR ManualTick=root:Analysis:ManualTick// this one was commented
	String LengthPrefix, LengthWList, Length_Wave, ForcePrefix, ForceWList, Force_Wave, TimePrefix, TimeWList, Time_Wave, TraceList, NameInterpWave, NameInterpWaveX,commandstring
	Variable N,j
	
	 LengthPrefix = "L_"
	 ForcePrefix="Mag_"
	 TimePrefix = "Time_"	
	 LengthWList = WaveList(LengthPrefix+"*", ";","")
	 ForceWList =  WaveList(ForcePrefix+"*", ";","")
	 TimeWList = WaveList(TimePrefix+"*", ";","")

	if(DisplayNumber>ItemsInList(TimeWList,";"))
		DisplayNumber-=1
	endif
	
	Length_Wave = StringFromList(DisplayNumber-1,LengthWList,";")
	Force_Wave = StringFromList(DisplayNumber-1,ForceWList,";")
	Time_Wave = StringFromList(DisplayNumber-1,TimeWList,";")
	
	Duplicate/O $Length_Wave, root:Analysis:L_Active
	Duplicate/O $Force_Wave, root:Analysis:Mag_Active
	Duplicate/O $Time_Wave, root:Analysis:Time_Active
	
	SetDataFolder Folder 
end



//******************************************************** FOR BOTTONs *********************************************


//For Botton "Histogram"
Function Make_Histo(ctrlName,varNum,varStr,varName) : SetVariableControl	//ni idea?
	String ctrlName
	Variable varNum
	String varStr, varName
	
	histograming()
end

Function Make_Histo_Button(ctrlName) : ButtonControl	//function call by the botton
	String ctrlName
	histograming()
end
//end For Botton "Histogram"


//For Botton "PRINTDATA"
Function Print_Data(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr, varName
	
	DataInTable()
end

Function Print_Data_Button(ctrlName) : ButtonControl
	String ctrlName
	DataInTable()
End

	
Function DataInTable()	
	Print "Saving from panel"	
	NVAR step_size, total_extension, mag_position, step_up_or_down, time_of_step
	WAVE storage_wave, extension_after_step, bead_number, MagnetPosition, step_direction, step_time
	
	NVAR step_size=root:Analysis:step_size //the new one!
				variable len = numpnts(storage_wave)
				variable BeadNum_input=bead_number[len-1]			
				//SetDataFolder root:Analysis//nuevo
				Prompt BeadNum_input, "What is the NStep or Bead_Number?"
				DoPrompt "Please enter values", BeadNum_input
				if(V_flag==0)
					InsertPoints len, 1, storage_wave, extension_after_step, bead_number, MagnetPosition, step_direction, step_time
					bead_number[len]=BeadNum_input
					storage_wave[len]=step_size
					extension_after_step[len]=total_extension
					MagnetPosition[len]=mag_position
					step_direction[len]=step_up_or_down
					step_time[len]=time_of_step
				endif
end
//end For Botton "PRINTDATA"


//end For Botton "PRINTDATA"
Function Print_AccHisto(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr, varName
	
	AccHisto()
end


Function Print_AccHisto_Button(ctrlName) : ButtonControl
	String ctrlName
	AccHisto()
End

//Function Fwd_Button(ctrlName) : ButtonControl	
	//SetAxis bottom vcsr(A)+1000
//End

// ------ End For Bottons -------

// To learn about this function
function dummy123()
	String str="Length_Smooth"
	return strsearch(str,"Smooth",0)		// prints 10
end
// 

//******************************************************** HISTOGRAM ***********************************************************************
Function histograming()
		NVAR step_size=root:Analysis:step_size
		NVAR total_extension=root:Analysis:total_extension
		NVAR step_up_or_down=root:Analysis:step_up_or_down
		NVAR time_of_step=root:Analysis:time_of_step
		NVAR BinFactor = root:Analysis:BiningFactor//nuevo
		NVAR BinNumber = root:Analysis:TotalBin//nuevo
		NVAR BinStart = root:Analysis:StartBin//nuevo
		
		SetDataFolder root:Analysis
		Make/N=300/O Step1_Hist
		Make/N=300/O Step2_Hist
				
		Active_traces()
		WAVE L_Active, Mag_Active, Time_Active


		String Active=CsrWave(A)
		if (strsearch(CsrWave(A),"Smooth",0)!=-1)  // could also do  (...==7)  --or-- (...>0)   --or-- (...!<0)    --or-- (...>=1)
			Histogram/R=[pcsr(A),pcsr(B)]/B={(vcsr(A)-(BinStart)),(BinFactor),(BinNumber)} $Active,Step1_Hist // the value to start the histogram was 50
			Histogram/R=[pcsr(C),pcsr(D)]/B={(vcsr(C)-(BinStart)),(BinFactor),(BinNumber)} $Active,Step2_Hist // the value to start the histogram was 50
		else
			Histogram/R=[pcsr(A),pcsr(B)]/B={(vcsr(A)-(BinStart)),(BinFactor),(BinNumber)} L_Active,Step1_Hist // the value to start the histogram was 50
			Histogram/R=[pcsr(C),pcsr(D)]/B={(vcsr(C)-(BinStart)),(BinFactor),(BinNumber)} L_Active,Step2_Hist // the value to start the histogram was 50
		endif


		KillWindow/Z HistWin
		//Display /N=HistWin Step1_Hist // This line do a new panel with the histogram
		//ModifyGraph rgb(Step1_Hist)=(32768,40704,65280)//, lsize(Step1_Hist)=1.5 //as well, related to previous line
		//AppendToGraph Step2_Hist; ModifyGraph rgb(Step2_Hist)=(65280,32768,32768) // as well, related to previous line
		//MoveWindow/I/W=HistWin 6, 6, 14, 9
		CurveFit/Q/M=2/W=0 gauss, Step1_Hist/D
		WAVE W_coef
		variable Step1_x0 = W_coef[2]
		CurveFit/Q/M=2/W=0 gauss, Step2_Hist/D
		//ModifyGraph lstyle(fit_Step1_Hist)=3,rgb(fit_Step1_Hist)=(0,0,0)
		//ModifyGraph lsize(fit_Step2_Hist)=1.5,rgb(fit_Step2_Hist)=(0,0,0)
		variable Step2_x0 = W_coef[2]
			step_size = abs(Step1_x0 - Step2_x0)
			total_extension = max(Step1_x0, Step2_x0)
				print "a step of ", step_size, " nm was taken to a total extended length of ", total_extension, "nm"
				DoWindow/F MTAnalysis
				
				if(pcsr(D)>pcsr(A))				// if cursors go sequentially A-B then C-D
					if(Step2_x0>Step1_x0)		//and if the C-D step (Step2) is greater than the A-B step (Step1)
						step_up_or_down=1		//then the step is unfolding, and given a value of "+1"
					else
						step_up_or_down=-1		//otherwise it is refolding, and given a value of "-1"
					endif
					time_of_step=(hcsr(B)+hcsr(C))/2
				else
					if(Step1_x0>Step2_x0)
						step_up_or_down=1
					else
						step_up_or_down=-1
					endif	
					time_of_step=(hcsr(A)+hcsr(D))/2			
				endif
end
//******************************************************** END HISTROGRAM ***********************************************************************




//******************************************************** ACC_HISTOGRAM **********************************************************************

Function AccHisto()
		NVAR BinFactor2 = root:Analysis:BiningFactor2//nuevo
		NVAR BinNumber2 = root:Analysis:TotalBin2//nuevo
		NVAR BinStart2 = root:Analysis:StartBin2//nuevo
	SetDataFolder Root:Analysis
	Make/N=100/O storage_wave_Hist;DelayUpdate
	Histogram/C/B={(BinStart2),(BinFactor2),(BinNumber2)} root:Analysis:storage_wave,storage_wave_Hist;DelayUpdate
	Killwindow/Z AccHistogram
	Display/N=AccHistogram, storage_wave_Hist 
	ModifyGraph mode=5
End
//******************************************************** END ACC_HISTROGRAM *****************************************************************





//******************************************************** KEYBOARD HOOKS (DAN's lines)***********************************************************************
Function MyWindowHook(s)
	STRUCT WMWinHookStruct &s
	
	Variable hookResult = 0	// 0 if we do not handle event, 1 if we handle it.
	variable MousePoint
	
	NVAR step_size, total_extension, mag_position, step_up_or_down, time_of_step
	WAVE storage_wave, extension_after_step, bead_number, MagnetPosition, step_direction, step_time
	
	NVAR step_size=root:Analysis:step_size //the new one!

	switch(s.eventCode)
		case 11:					// Keyboard event
			switch (s.keycode)
				case 28:	//Left Arrow
					hookResult = 1
					break
				case 29:	//Right Arrow
					hookResult = 1
					histograming()
					break
				case 30:	//Up arrow
					hookResult = 1
					break
		//		case 31:	//Down arrow
			//		hookResult = 1
				//	break	
					
			case 49: 	//key "1"
				MousePoint = str2num(stringbykey("HITPOINT",Tracefrompixel(s.mouseLoc.h,s.mouseLoc.v,""),":",";"))	//variable
				String MouseString = stringbykey("TRACE",Tracefrompixel(s.mouseLoc.h,s.mouseLoc.v,""),":",";")		//string
				Cursor/P A, $MouseString, MousePoint	
				hookResult = 1
				break
			
			case 50:		//key "2"
				MousePoint = str2num(stringbykey("HITPOINT",Tracefrompixel(s.mouseLoc.h,s.mouseLoc.v,""),":",";"))	//variable
				MouseString = stringbykey("TRACE",Tracefrompixel(s.mouseLoc.h,s.mouseLoc.v,""),":",";")		//string
				Cursor/P B, $MouseString, MousePoint	
				hookResult = 1
				break	
			
			case 51:		//key "3"
				MousePoint = str2num(stringbykey("HITPOINT",Tracefrompixel(s.mouseLoc.h,s.mouseLoc.v,""),":",";"))	//variable
				MouseString = stringbykey("TRACE",Tracefrompixel(s.mouseLoc.h,s.mouseLoc.v,""),":",";")		//string
				Cursor/P C, $MouseString, MousePoint	
				hookResult = 1
				break	
			
			case 52:		//key "4"
				MousePoint = str2num(stringbykey("HITPOINT",Tracefrompixel(s.mouseLoc.h,s.mouseLoc.v,""),":",";"))	//variable
				MouseString = stringbykey("TRACE",Tracefrompixel(s.mouseLoc.h,s.mouseLoc.v,""),":",";")		//string
				Cursor/P D, $MouseString, MousePoint	
				hookResult = 1
				break	
		
			case 53: 		//key "5"
					if (check_MagPos(0) > 0.005)
						DoAlert 0, "Alert: Change in extension may be due to change in Magnet Position.  Please confirm Magnet Position constant through measurement before proceeding"
					endif		
				histograming()
				mag_position=check_MagPos(1)
				hookResult = 1
				break		
				
			case 54:		//key "6"
				//SetDataFolder root:Analysis//nuevo
				variable len = numpnts(storage_wave)
				variable BeadNum_input=bead_number[len-1]			
				//SetDataFolder root:Analysis//nuevo
				Prompt BeadNum_input, "What is the Step_Type or Bead_Number?"
				DoPrompt "Please enter values", BeadNum_input
				
				if(V_flag==0)
					InsertPoints len, 1, storage_wave, extension_after_step, bead_number, MagnetPosition, step_direction, step_time
					bead_number[len]=BeadNum_input
					storage_wave[len]=step_size
					extension_after_step[len]=total_extension
					MagnetPosition[len]=mag_position
					step_direction[len]=step_up_or_down
					step_time[len]=time_of_step
				endif
				hookResult = 1
				break				
							
				default:
					// The keyText field requires Igor Pro 7 or later. See Keyboard Events.
					Printf "Key pressed: %s\r", s.keyText
					break			
			endswitch
			break
	endswitch

	return hookResult	// If non-zero, we handled event and Igor will ignore it.
End
//******************************************************** END KEYBOARD HOOKS ***********************************************************************





// Get the magnet position and the standard deviation in the magnet position between the cursors
SetDataFolder root:Analysis
function check_MagPos(FLAG) 		//looks at standard deviation in Magnet Position between the two steps measure to see if change in Extension was due to change in Magnet
	variable FLAG
	Active_traces()
	WAVE L_Active, Mag_Active, Time_Active
	
	variable min_csr=min(pcsr(A),pcsr(B),pcsr(C),pcsr(D))
	variable max_csr=max(pcsr(A),pcsr(B),pcsr(C),pcsr(D))
	//print min_csr, max_csr
	Duplicate/O/R=[min_csr, max_csr] Mag_Active dummyMag_Active
	WaveStats/Q dummyMag_Active
	if (FLAG==0)
	//	print V_sdev
		return V_sdev			// this value seems to tend to be <0.005
	endif
	if (FLAG==1)
	//	print V_avg
		return V_avg	
	endif
end

//******************************************************** VERY END ***********************************************************************
//******************************************************** VERY END ***********************************************************************
//******************************************************** VERY END ***********************************************************************



// NewFunction
//DoWindow/K FCDisplay
//DoWindow/K FcDualDisplay
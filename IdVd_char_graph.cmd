File{
    Grid      = "doru_msh.tdr"
    Plot      = "IdVd4"
    Parameter = "S.par"
    Current   = "IdVd4"
    Output    = "IdVd4"

}
Electrode{
   { Name="source"    Voltage=0.0 }
   { Name="drain"     Voltage=0.0 }
   { Name="gate"      Voltage=0.0 }
   { Name="substrate" Voltage=0.0 }
   { Name="bodytie"   Voltage=0.0 }
}

Physics
{	
	 Fermi
	 Mobility( PhuMob Enormal ThinLayer (lombardi) hHighFieldSat(GradQuasiFermi) eHighFieldSat(GradQuasiFermi))
	 EffectiveIntrinsicDensity (BandGapNarrowing (OldSlotboom))
	 Recombination (SRH(DopingDep TempDependence ElectricField(Lifetime = Schenk)) Auger)
	 eQuantumPotential hQuantumPotential
}

Plot {
*--Density and current
	eDensity hDensity 
	eMobility hMobility 
	eVelocity hVelocity
	eCurrent hCurrent Band2Band ConductionCurrent
	TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
	Current TotalRecombination 
	ElectronAffinity NonLocal
	eTrappedCharge  hTrappedCharge
	eLifeTime hLifeTime
  	eEparallel hEparallel eENormal hENormal
	Potential SpaceCharge ElectricField/Vector
  

*--Doping profiles
	Doping DonorConcentration AcceptorConcentration

*--Generation/Recombinations
	eBand2BandGeneration
	hBand2BandGeneration
	SRHRecombination Auger
	eSRHRecombination hSRHRecombination tSRHRecombination
	eGapStatesRecombination hGapStatesRecombination

*--Tunneling
	eBarrierTunneling hBarrierTunneling
	eDirectTunnel hDirectTunnel
*--E-Field
	BuiltinPotential
	CurrentPotential
	eQuantumPotential hQuantumPotential

*--Heat quantity   
	Temperature TotalHeat eJouleHeat hJouleHeat

*--Energy
	ConductionBandEnergy ValenceBandEnergy
	eQuasiFermiEnergy hQuasiFermiEnergy
  
*--fermi Level
	eQuasiFermi hQuasiFermi
  	eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  	eEparallel hEparallel eENormal hENormal
  	BandGap xMoleFraction  BandGapNarrowing
	SemiconductorGradConductionBand SemiconductorGradValenceBand 
}


Math { 

	EnormalInterface(materialInterface=["SiO2/Silicon"])
	Digits= 6
	Iterations=20
	Extrapolate
	Derivatives
	CNormPrint
	NotDamped=200
	Wallclock
	Method=Blocked SubMethod=ParDiso
	NoSRHperPotential
	Number_Of_Threads = 8
}


Solve {
  
*- Build-up of initial solution:
     NewCurrentPrefix="init"
   Coupled(Iterations=100){ Poisson  eQuantumPotential}
   Coupled{ Poisson Electron Hole eQuantumPotential }

   *- Bias body to target bias
     	Quasistationary (InitialStep=1e-4 Minstep=1e-10 MaxStep=0.5 Increment=100 
      Goal{ Name="gate" Voltage= 1}
   ){ Coupled{ Poisson Electron Hole eQuantumPotential} }

     
   *-  gate voltage sweep
   NewCurrentPrefix=""
     	Quasistationary ( 
      Goal{ Name="drain" Voltage= -2 }
          
         ){ Coupled{ Poisson Electron Hole eQuantumPotential }
      CurrentPlot(Time=(Range=(0 1) Intervals=100))
   }
   Quasistationary (
      Goal { Name="drain" Voltage= 2 }
          
         ){ Coupled{ Poisson Electron Hole eQuantumPotential }
      CurrentPlot(Time=(Range=(0 1) Intervals=100))
   }

}

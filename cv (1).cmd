Device nsfet{
File{
    Grid      = "Soifet_NMOS_msh.tdr"
     Parameter = "Si_qnt.par"

}

Electrode{
    { Name="Source"    Voltage=0.0 }
    { Name="Drain"     Voltage=0.0 }
    { Name="Gate"      Voltage=0.0 }
  }

Physics
{	
	 Fermi
	 Mobility(PhuMob Enormal ThinLayer (lombardi) hHighFieldSat(GradQuasiFermi) eHighFieldSat(GradQuasiFermi))
	 EffectiveIntrinsicDensity (BandGapNarrowing (OldSlotboom))
	 Recombination (SRH(DopingDep TempDependence ElectricField(Lifetime = Schenk)) Auger)
}
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



File {
   *-Output  = "cv.log"
   ACExtract = "cv"
     }


System {
  	nsfet nsfetn (Gate=g Drain=d Source=s)
 	Vsource_pset vg ( g 0 ){ dc = 0 }  
  	Vsource_pset vd ( d 0 ){ dc = 0 }
  	Vsource_pset vs ( s 0 ){ dc = 0 }
       }

Solve {

#-a) zero solution
	Coupled { Poisson eQuantumPotential}
	Coupled { Poisson Electron Hole eQuantumPotential}


#-b) ramp drain to positive starting voltage
	Quasistationary ( InitialStep=1e-2 Increment=1.35 MinStep=1e-8 MaxStep=0.5
	Goal { Parameter=vd.dc Voltage=0.75 }
	){ Coupled { Poisson Electron Hole eQuantumPotential} }

#-c) ramp gate to negative starting voltage
	Quasistationary ( InitialStep=1e-3 Increment=1.35 MinStep=1e-15 MaxStep=0.5
	Goal { Parameter=vg.dc Voltage=-0.05 }
	){ Coupled { Poisson Electron Hole eQuantumPotential} }

#-d) ramp gate -2V..3V : AC analysis at each step.
	Quasistationary (NonlocalPath ( Derivative=1 Strategy=3	N=5 MinStep=1.0e-5 MaxStep=1.0e-2)
        InitialStep=1e-3 Increment=1.35 MinStep=1e-15 MaxStep=0.05
	Goal { Parameter=vg.dc Voltage=0.75 }
	){ ACCoupled ( StartFrequency=1e6 EndFrequency=1e6 NumberOfPoints=1 Decade Node(g d s) Exclude(vg vd vs) ACCompute (Time = (Range = (0 1)  Intervals = 60))
	){ Poisson Electron Hole eQuantumPotential }}

     }





Device NSFET {

File{
    Grid      = "doru_msh.tdr"
    Parameter = "S.par"

}

Electrode{
   { Name="source"    Voltage=0.0  }
   { Name="drain"     Voltage=0.0  }
   { Name="gate"      Voltage=0.0  }
   { Name="substrate" Voltage=0.0  }
   { Name="bodytie"   Voltage=0.0  }
}

Thermode{ 
	{ Name="drain"     Temperature=300 SurfaceResistance=7e-5 } 
	{ Name="source"    Temperature=300 SurfaceResistance=7e-5 } 
	{ Name="gate"      Temperature=300 SurfaceResistance=7e-5 } 
	{ Name="substrate" Temperature=300 SurfaceResistance=7e-5 } 
	{ Name="bodytie"   Temperature=300 SurfaceResistance=7e-5 } 
}

Physics
{	

	 AreaFactor =1
	 Fermi
	 Mobility (PhuMob 
     Enormal 
     ThinLayer (lombardi) 
     hHighFieldSat(GradQuasiFermi) 
     eHighFieldSat(GradQuasiFermi)
   )
   
	 EffectiveIntrinsicDensity (BandGapNarrowing (OldSlotboom))
	 Recombination (
     SRH(DopingDep TempDependence ElectricField(Lifetime = Schenk)) 
     Auger)
	 eQuantumPotential 
   hQuantumPotential
}




}

Device PSFET{
  
File{
    Grid      = "pmos_msh.tdr"
    Parameter = "S.par"
}


Electrode{
   { Name="source"    Voltage=0.0  }
   { Name="drain"     Voltage=0.0  }
   { Name="gate"      Voltage=0.0  }
   { Name="substrate" Voltage=0.0  }
   { Name="bodytie"   Voltage=0.0  }
}


Thermode{ 
	{ Name="drain"     Temperature=300 SurfaceResistance=7e-5 } 
	{ Name="source"    Temperature=300 SurfaceResistance=7e-5 } 
	{ Name="gate"      Temperature=300 SurfaceResistance=7e-5 } 
  { Name="substrate" Temperature=300 SurfaceResistance=7e-5 } 
	{ Name="bodytie"   Temperature=300 SurfaceResistance=7e-5 } 
}

Physics
{	

	 AreaFactor =2.5
	 Fermi
	 Mobility( 
      PhuMob 
      Enormal 
      ThinLayer (lombardi) 
      hHighFieldSat(GradQuasiFermi) 
     eHighFieldSat(GradQuasiFermi))
	 EffectiveIntrinsicDensity (BandGapNarrowing (OldSlotboom))
	 Recombination (
     SRH(DopingDep TempDependence ElectricField(Lifetime = Schenk)) 
     Auger)
	 eQuantumPotential 
   hQuantumPotential
}

}

File{
   Output = "VTC"
   Current = "VTC"
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


System{
  Vsource_pset vdd (dd 0) { dc = 0.0 }
  Vsource_pset vin (in 0) { dc = 0.0 }

  NSFET nsfet1 ( "source"=0  "drain"=out "gate"=in "substrate"=0 "bodytie"=0)
  PSFET psfet1 ( "source"=dd "drain"=out "gate"=in "substrate"=dd "bodytie"=dd)  
  Capacitor_pset cout ( out 0 ){ capacitance = 1e-18 }

  Plot "vtc_sys_des.plt" (time() v(in) v(out) i(nsfet1,out) i(psfet1,out) i(cout,out))
                              
}

Solve{  
  NewCurrentPrefix="init_"
  Coupled(Iterations=100){ Poisson *eQuantumPotential
  }
  Coupled{ Poisson Electron Hole Contact Circuit *eQuantumPotential
  }

  Quasistationary( 
     InitialStep=1e-4 Increment=1.5 MinStep=1e-10 MaxStep=0.02
     Goal{ Parameter=vdd.dc Voltage= 1.5} 
  ){ Coupled{ Poisson Electron Hole Contact Circuit *eQuantumPotential 
  }
  }

  NewCurrentPrefix=""
  Quasistationary( 
     InitialStep=1e-4 Increment=1.5 MinStep=1e-10 MaxStep=0.02
     Goal{ Parameter=vin.dc Voltage= 1.5} 
  ){ Coupled{ Poisson Electron Hole Contact Circuit *eQuantumPotential
  }
  }
}



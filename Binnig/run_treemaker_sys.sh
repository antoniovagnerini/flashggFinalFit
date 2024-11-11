#!bin/sh

# Record the start time
start=$(date +%s)

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


echo "Input the path directory of your work sapce"
read InputDirectory

if [ ! -d $InputDirectory ]; then
    mkdir $InputDirectory
    echo "$InputDirectory directory has been created"
fi

echo "Making Results folder"

if [ ! -d $InputDirectory/Results ]; then
mkdir -p $InputDirectory/Results
fi

if [ ! -d $InputDirectory/Results/Models ]; then
mkdir -p $InputDirectory/Results/Models
fi

if [ ! -d $InputDirectory/Results/Models/background ]; then
mkdir -p $InputDirectory/Results/Models/background
fi

if [ ! -d $InputDirectory/Results/Models/signal ]; then
mkdir -p $InputDirectory/Results/Models/signal
fi

echo "Making Output folder"

if [ ! -d $InputDirectory/Signal_Output ]; then
mkdir -p $InputDirectory/Signal_Output 
fi

if [ ! -d $InputDirectory/Signal_Output/outdir ]; then
mkdir -p $InputDirectory/Signal_Output/outdir
fi

if [ ! -d $InputDirectory/Signal_Output/outdir_pack ]; then
mkdir -p $InputDirectory/Signal_Output/outdir_pack
fi

if [ ! -d $InputDirectory/Background_Output/ ]; then
mkdir -p $InputDirectory/Background_Output/
fi

echo "##### Creating $InputDirectory/Bin directories #####"

cp TMVAClassification__BDT_Xgrad_multiclass_CPodd_threeclass_VBF.weights.xml $InputDirectory

cp TreeMakerForWorkspace_multiclassBDT_3D_SYS.C $InputDirectory

cd $InputDirectory

echo -n "YEAR : "
read year

Nbinx=5 #Dzero bins
Nbiny=3 #stxsMVA bins
Nbinz=2  #CPodd bdt bins 

vars=("Up" "Down")

# Check if year is 2018
if [ "$year" -eq 2018 ]; then
    systematics=( "FNUFEE" "FNUFEB" "JEC" "JER" "JetHEM" "MCScaleGain1EB" "MCScaleGain6EB" "MCScaleHighR9EB" "MCScaleHighR9EE" "MCScaleLowR9EB" "MCScaleLowR9EE" "MCSmearHighR9EBPhi" "MCSmearHighR9EBRho" "MCSmearHighR9EEPhi" "MCSmearHighR9EERho" "MCSmearLowR9EBPhi" "MCSmearLowR9EBRho" "MCSmearLowR9EEPhi" "MCSmearLowR9EERho" "MaterialCentralBarrel" "MaterialForward" "MaterialOuterBarrel" "MvaShift" "PUJIDShift" "ShowerShapeHighR9EB" "ShowerShapeHighR9EE" "ShowerShapeLowR9EB" "ShowerShapeLowR9EE" "SigmaEOverEShift" "ExtraSystFor2018" ) # 29 systematics for 2018
else
    systematics=( "FNUFEE" "FNUFEB" "JEC" "JER" "MCScaleGain1EB" "MCScaleGain6EB" "MCScaleHighR9EB" "MCScaleHighR9EE" "MCScaleLowR9EB" "MCScaleLowR9EE" "MCSmearHighR9EBPhi" "MCSmearHighR9EBRho" "MCSmearHighR9EEPhi" "MCSmearHighR9EERho" "MCSmearLowR9EBPhi" "MCSmearLowR9EBRho" "MCSmearLowR9EEPhi" "MCSmearLowR9EERho" "MaterialCentralBarrel" "MaterialForward" "MaterialOuterBarrel" "MvaShift" "PUJIDShift" "ShowerShapeHighR9EB" "ShowerShapeHighR9EE" "ShowerShapeLowR9EB" "ShowerShapeLowR9EE" "SigmaEOverEShift" ) # 28 systematics for other years
fi


echo -n "initial proc : "
read init_p

echo -n "Nproc : "
read Nproc #Processes

#init_p=0 #Initial Process
#Nproc=9 #Signal Prrocesses

bin_index=0

for ((k = 0; k < $Nbinz; k++)); do

  for ((j = 0; j < $Nbiny; j++)); do

    for ((i = 0; i < $Nbinx; i++)); do

    if [ ! -d Bin$bin_index ]; then
	mkdir -p Bin$bin_index
	echo "$InputDirectory/Bin$bin_index directory has been created"
    fi
	    
    cd Bin$bin_index || exit 1

    cp ../TreeMakerForWorkspace_multiclassBDT_3D_SYS.C .

    echo "##### Running Treemaker #####"

    #Process loop

    for ((p =$init_p; p < $Nproc; p++)); do

	#Systematic tree loop
	for var in "${vars[@]}"; do
	     for systematic in "${systematics[@]}"; do
		echo "Running" $systematic " " $var "variation" 

    		root -l -b -q TreeMakerForWorkspace_multiclassBDT_3D_SYS.C\($i,$j,$k,$p,$bin_index,\"$systematic\",\"$var\",\"$year\"\) &> run_higbkg$bin_index$p$systematic$var.log & #change to name of systematic tree maker

                echo "Processing TreeMakerForWorkspace_multiclassBDT_3D_SYS.C($i,$j,$k,$p,$bin_index,\"$systematic\",\"$var\",\"$year\")"
			
	     done #syst loop

	done #var loop

	done #process loop
	
	wait

	cd ..
       	((bin_index++))
       
    done   	  
  done
done

echo "All jobs completed"

cd .. #exit input directory



# Record the end time
end=$(date +%s)

# Calculate the runtime in mins
runtime=$((end - start))

# Convert the runtime from seconds to minutes
runtime_minutes=$((runtime / 60))

# Print the runtime in minutes
echo "Job runtime: $runtime_minutes minutes"
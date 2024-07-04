#!bin/sh


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

#echo "Number of Bin?"
#read bin

cp TMVAClassification__BDT_Xgrad_multiclass_CPodd_allbkg_newvarset.weights.xml $InputDirectory

cp TreeMakerForWorkspace_multiclassBDT_2D.C $InputDirectory

cd $InputDirectory

Nbinx=5 #Dzero bins
Nbiny=3 #stxsMVA bins

bin_index=0
for ((i = 0; i < $Nbinx; i++)); do

  for ((j = 0; j < $Nbiny; j++)); do

    if [ ! -d Bin$bin_index ]; then
	mkdir -p Bin$bin_index
	echo "$InputDirectory/Bin$bin_index directory has been created"
    fi
	    
    cd Bin$bin_index
    echo "##### Running Treemaker #####"
    echo "Bin $bin_index"
             
    root -l -b -q ../TreeMakerForWorkspace_multiclassBDT_2D.C\($i,$j,$bin_index\) &> run$bin_index.log &  # run in the background bin by bin
        
    echo "You can check the logs here : $(pwd)"

    cd ..
    ((bin_index++))

 done   	  
done
 
cd ..

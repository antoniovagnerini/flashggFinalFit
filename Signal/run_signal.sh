#!bin/sh

echo "Input the path directory of your workspace"
read InputWSDirPath

echo "Number of Bin?"
read bin

echo "Initial Bin"
read initial_bin

###################

j="_"


for ((i = $initial_bin; i < $bin; i++));
do

for k in GG2HbsmM GG2Hsm GG2HMf05ph0 VBFbsmM VBFsm VBFMf05ph0
do

touch config_sig_$k\_bin_$i.py
echo -e "# Config file: options for signal fitting 
_year = '2017' 

signalScriptCfg = {

  # Setup
  'inputWSDir':'$InputWSDirPath/Bin$i/ws_$k/',
  'procs':'auto', # if auto: inferred automatically from filenames
  'cats':'auto', # if auto: inferred automatically from (0) workspace
  'ext': 'Bin$i$j%s'%_year,
  'analysis':'STXS', # To specify which replacement dataset mapping (defined in ./python/replacementMap.py)
  'year':'%s'%_year, # Use 'combined' if merging all years: not recommended
  'massPoints':'125',

  #Photon shape systematics
  'scales':'HighR9EB,HighR9EE,LowR9EB,LowR9EE,Gain1EB,Gain6EB', # separate nuisance per year
  'scalesCorr':'MaterialCentralBarrel,MaterialOuterBarrel,MaterialForward,FNUFEE,FNUFEB,ShowerShapeHighR9EE,ShowerShapeHighR9EB,ShowerShapeLowR9EE,ShowerShapeLowR9EB', # correlated across years
  'scalesGlobal':'NonLinearity,Geant4', # affect all processes equally, correlated across years
  'smears':'HighR9EBPhi,HighR9EBRho,HighR9EEPhi,HighR9EERho,LowR9EBPhi,LowR9EBRho,LowR9EEPhi,LowR9EERho', # separate nuisance per year

  # Job submission options
  'batch':'local', # ['condor','SGE','IC','local']
  'queue':'hep.q'
  #'batch':'condor', # ['condor','SGE','IC','local']
  #'queue':'espresso',

}" > config_sig_$k\_bin_$i.py

python RunSignalScripts.py --inputConfig config_sig_$k\_bin_$i.py --mode fTest  --modeOpts "--nProcsToFTest 1 --threshold 5 --doPlots "
python RunSignalScripts.py --inputConfig config_sig_$k\_bin_$i.py --mode signalFit  --groupSignalFitJobsByCat --modeOpts "--skipSystematics --replacementThreshold 5 --doPlots" 


echo " ################## Finished the whole process for Bin$i $k  ################ "


if [ ! -d $InputWSDirPath/Signal_Output ]; then
mkdir -p $InputWSDirPath/Signal_Output
fi

mv -f config_sig_$k\_bin_$i.py $InputWSDirPath/Signal_Output/

echo " ############### Moved the output ############## "

done 

#python RunPackager.py --cats AC_Bin$i --exts Bin$i\_2017 --mergeYears FALSE --outputExt packaged_Bin$i
#python RunPlotter.py --procs all --cats AC_Bin$i --years 2017 --ext packaged_Bin$i
python RunPackager.py --cats AC_Bin$i --exts Bin$i\_2017 --mergeYears FALSE --outputExt packaged_Bin$i
python RunPlotter.py --procs all --cats AC_Bin$i --years 2017 --ext packaged_Bin$i

echo " @@@@@@@################## Finished the whole process for Bin$i @@@@@@@@@@@################ "

echo " ###########@@@@@@@@@  End Combine Signal Modelling @@@@@@@@@@@############## "

echo " ############### Renaming Output Root Files for the Datacard Maker & Storing the Results to the EOS WS Directory ############ "

cp outdir_packaged_Bin$i/CMS-HGG_sigfit_packaged_Bin$i\_AC_Bin$i.root $InputWSDirPath/Results/Models/signal/CMS-HGG_sigfit_packaged_AC_Bin$i\_2017.root


echo " ############### Moving output ############## "


if [ ! -d $InputWSDirPath/Signal_Output/outdir/outdir_Bin ]; then
mkdir -p $InputWSDirPath/Signal_Output/outdir/outdir_Bin
fi

mv -if outdir_Bin$i\_2017 $InputWSDirPath/Signal_Output/outdir/outdir_Bin/

if [ ! -d $InputWSDirPath/Signal_Output/outdir_pack/outdir_packaged_Bin ]; then
mkdir -p $InputWSDirPath/Signal_Output/outdir_pack/outdir_packaged_Bin
fi
mv -f outdir_packaged_Bin$i $InputWSDirPath/Signal_Output/outdir_pack/outdir_packaged_Bin/


done
echo " ########### End ############## "







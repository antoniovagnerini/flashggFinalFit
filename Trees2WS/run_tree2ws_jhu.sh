
#!bin/sh/                                                                                                                        

echo "Input the path directory of your ntuplese and No '/' at the end of the path directory" 
read InputTreePathdirectory

echo "Number of Bin?"
read bin

for ((i = 0; i < $bin; i++));
do


#########################################

touch config_bkg_bin$i.py
echo "# Input config file for running trees2ws                                                                                   
                                                                                                                                 
                                                                                                                                 
trees2wsCfg = {                                                                         
                                                                                                                                 
  # Name of RooDirectory storing input tree                                                                                      
                                                                                                                                 
  'inputTreeDir':'',                                                                                                             
                                                                                                                                 
  # Variables to be added to dataframe: use wildcard * for common strings                                                        
  'mainVars':[\"CMS_hgg_mass\",\"weight\",\"centralObjectWeight\",\"dZ\",\"*sigma\"], # Vars to add to nominal RooDatasets       
  'dataVars':[\"CMS_hgg_mass\",\"weight\"], # Vars for data workspace (trees2ws_data.py script)                                  
  'stxsVar':'stage1p2bin', # Var for STXS splitting: if using option doSTXSSplitting                                             
  'notagVars':[\"weight\",\"*sigma\"], # Vars to add to NOTAG RooDataset                                                        
  'systematicsVars':[\"CMS_hgg_mass\",\"weight\"], # Variables to add to sytematic RooDataHists                                
  'theoryWeightContainers':{'alphaSWeights':2,'scaleWeights':9,'pdfWeights':60}, # Theory weights to add to nominal + NOTAG RooDtasets, value corresponds to number of weights (0-N)                                                                              

  # List of systematics: use string YEAR for year-dependent systematics                                                          
                                                                                                                                 
  'systematics':['FNUFEB', 'FNUFEE', 'JECAbsoluteYEAR', 'JECAbsolute', 'JECBBEC1YEAR', 'JECBBEC1', 'JECEC2YEAR', 'JECEC2', 'JECFlavorQCD', 'JECHFYEAR', 'JECHF', 'JECRelativeBal', 'JECRelativeSampleYEAR', 'JEC', 'JER', 'MCScaleGain1EB', 'MCScaleGain6EB', 'MCScaleHighR9EB', 'MCScaleHighR9EE', 'MCScaleLowR9EB', 'MCScaleLowR9EE', 'MCSmearHighR9EBPhi', 'MCSmearHighR9EBRho', 'MCSmearHighR9EEPhi', 'MCSmearHighR9EERho', 'MCSmearLowR9EBPhi', 'MCSmearLowR9EBRho', 'MCSmearLowR9EEPhi', 'MCSmearLowR9EERho', 'MaterialCentralBarrel', 'MaterialForward', 'MaterialOuterBarrel', 'MvaShift', 'PUJIDShift', 'ShowerShapeHighR9EB', 'ShowerShapeHighR9EE', 'ShowerShapeLowR9EB', 'ShowerShapeLowR9EE', 'SigmaEOverEShift', 'metJecUncertainty', 'metJerUncertainty', 'metPhoUncertainty', 'metUncUncertainty'],                                                                                                                     
                                                                                                                                
  # Analysis categories: python list of cats or use 'auto' to extract from input tree                                            
                                                                                                                                 
  'cats':'auto'                                                                                                                  
                                                                                                                                 
}" > config_bkg_bin$i.py


#############################################


touch config_sig_bin$i.py
echo -e "# Input config file for running trees2ws                                                                               
                                                                                                                                 
trees2wsCfg = {                                                                                                                  
                                                                                                                                 
  # Name of RooDirectory storing input tree                                                                                      
                                                                                                                                 
  'inputTreeDir':'',                                                                                                             
                                                                                                                                 
  # Variables to be added to dataframe: use wildcard * for common strings                                                        
  'mainVars':[\"CMS_hgg_mass\",\"weight\",\"dZ\"], # Var for the nominal RooDataSets                                             
  'dataVars':[\"CMS_hgg_mass\",\"weight\"], # Vars to be added for data                                                          
  'stxsVar':'',                                                                                                                  
  'notagVars':[\"weight\"], # Vars to add to NOTAG RooDataset                                                                    
  'systematicsVars':[\"CMS_hgg_mass\",\"weight\"], # Variables to add to sytematic RooDataHists                                  
  'theoryWeightContainers':{},                                                                                                   
                                                                                                                                 
  # List of systematics: use string YEAR for year-dependent systematics                                                          
  'systematics':[],                                                                                                              
                                                                                                                                 
  # Analysis categories: python list of cats or use 'auto' to extract from input tree                                           
  'cats':'auto'                                                                                                                  
                                                                                                                                 
}" > config_sig_bin$i.py


###############################################################

echo " ###### Running T2WS for the Background ############ "

python trees2ws_data.py  --inputConfig config_bkg_bin$i.py --inputTreeFile $InputTreePathdirectory/Bin$i/output_Data.root --outputWSDir $InputTreePathdirectory/Bin$i

###############################################################

echo " ###### Renaming output_Data.root to allData.root in the ws directory  ############ "

mv -f $InputTreePathdirectory/Bin$i/ws/output_Data.root  $InputTreePathdirectory/Bin$i/ws/allData.root

echo " @@@@ output_Data.root was created & renamed to allData.root @@@@"

###############################################################

echo " ###### Running T2WS for the Signal ########## "

#python trees2ws.py  --inputConfig config_sig_bin$i.py  --inputTreeFile $InputTreePathdirectory/Bin$i/output_GluGluHToGGPlusTwoJets_SM_M125_TuneCP5_13TeV-amcatnlopowheg-minlo-pythia8.root --productionMode jjh0P --year 2017
#python trees2ws.py  --inputConfig config_sig_bin$i.py  --inputTreeFile $InputTreePathdirectory/Bin$i/output_GluGluHToGGPlusTwoJets_CPodd_M125_TuneCP5_13TeV-amcatnlopowheg-minlo-pythia8.root --productionMode jjh0M --year 2017
#python trees2ws.py  --inputConfig config_sig_bin$i.py  --inputTreeFile $InputTreePathdirectory/Bin$i/output_GluGluHToGGPlusTwoJets_MM_M125_TuneCP5_13TeV-amcatnlopowheg-minlo-pythia8.root --productionMode jjh0Mf05ph0  --year 2017

python trees2ws.py  --inputConfig config_sig_bin$i.py  --inputTreeFile $InputTreePathdirectory/Bin$i/output_JJHiggs0PMToGG_M125_TuneCP5_13TeV-JHUGenV7011-pythia8.root  --productionMode jjh0P --year 2017
python trees2ws.py  --inputConfig config_sig_bin$i.py  --inputTreeFile $InputTreePathdirectory/Bin$i/output_JJHiggs0MToGG_M125_TuneCP5_13TeV-JHUGenV7011-pythia8.root  --productionMode jjh0M --year 2017
python trees2ws.py  --inputConfig config_sig_bin$i.py  --inputTreeFile $InputTreePathdirectory/Bin$i/output_JJHiggs0Mf05ph0ToGG_M125_TuneCP5_13TeV-JHUGenV7011-pythia8.root --productionMode jjh0Mf05ph0  --year 2017
python trees2ws.py  --inputConfig config_sig_bin$i.py  --inputTreeFile $InputTreePathdirectory/Bin$i/output_VBFHiggs0PHToGG_M125_TuneCP5_13TeV-JHUGenV7011-pythia8.root --productionMode vbf0P  --year 2017
python trees2ws.py  --inputConfig config_sig_bin$i.py  --inputTreeFile $InputTreePathdirectory/Bin$i/output_VBFHiggs0MToGG_M125_TuneCP5_13TeV-JHUGenV7011-pythia8.root --productionMode vbf0M  --year 2017
python trees2ws.py  --inputConfig config_sig_bin$i.py  --inputTreeFile $InputTreePathdirectory/Bin$i/output_VBFHiggs0Mf05ph0ToGG_M125_TuneCP5_13TeV-JHUGenV7011-pythia8.root --productionMode vbf0Mf05ph0  --year 2017


echo " ########### End the operation for Bin$i  ############## "

done

################################################################

echo " ###### Moving the output t2ws config files ######## "

if [ ! -d $InputTreePathdirectory/config_files/ ] || [ ! -d $InputTreePathdirectory/config_files/config_tws_bkg_bin ] || [ ! -d $InputTreePathdirectory/config_files/config_tws_sig_bin ]; then
mkdir -p $InputTreePathdirectory/config_files && mkdir -p $InputTreePathdirectory/config_files/config_tws_bkg_bin && mkdir -p $InputTreePathdirectory/config_files/config_tws_sig_bin

fi

mv -f config_bkg_bin* $InputTreePathdirectory/config_files/config_tws_bkg_bin/.
mv -f config_sig_bin* $InputTreePathdirectory/config_files/config_tws_sig_bin/.


echo " ########### End ############## "





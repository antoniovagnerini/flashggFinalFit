#!/bin/sh/

cmsenv
#make clean
make 

echo "Input the path directory of your workspace : "
read InputWSDirPath

echo -n "Year : "
read year

echo -n "Initial Bin : " 
read init_bin

echo -n "Number of Bin : "
read bin

###################


for ((i = $init_bin; i < $bin; i++));
do
touch config_bkg_bin$i.py
echo -e "# Config file: options for signal fitting                


backgroundScriptCfg = {

  # Setup                                                                                                                         
  'inputWSDir':'$InputWSDirPath/Bin$i/ws', # location of 'allData.root' file 
  'ext':'bin$i', # extension to add to output directory                                                                         
  'cats':'auto', # auto: automatically inferred from input ws                                                                     
  'catOffset':0, # add offset to category numbers (useful for categories from different allData.root files)                       
  'year':'$year', # Use combined when merging all years in category (for plots)                                                

  # Job submission options                                                                                                        
  'batch':'local', # [condor,SGE,IC,local]
  'queue':'hep.q' # for condor e.g. microcentury

}" > config_bkg_bin$i.py


echo "####  Running backgournd #####"

python RunBackgroundScripts.py --inputConfig config_bkg_bin$i.py --mode fTestParallel
 
echo "############### Renaming Output Root Files for the Datacard Maker & Storing the Results to the EOS WS Directory #######"

cp outdir_bin$i/CMS-HGG_multipdf_AC_Bin$i.root  $InputWSDirPath/Results/Models/background/CMS-HGG_multipdf_AC_Bin$i\_$year.root

echo "###### Moving cofing & output fils to the WS directory #######"


mv -f config_bkg_bin$i.py $InputWSDirPath/Background_Output/ 


if [ -d $InputWSDirPath/Background_Output/outdir_bin$i ]; then
rm -rf  $InputWSDirPath/Background_Output/outdir_bin$i
fi

mv -f outdir_bin$i $InputWSDirPath/Background_Output/


echo "############### Renaming Output Root Files for the Datacard Maker & Storing the Results to the EOS WS Directory #######"

done

echo " ########### End ############## "

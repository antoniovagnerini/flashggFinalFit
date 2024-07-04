#!/bin/bash

text2workspace.py Datacard.txt  -m 125.0  -P HiggsAnalysis.CombinedLimit.FA3_Interference_JHU_ggHSyst_rw_MengsMuV_HeshyXsec_ggHInt_ggHphase:FA3_Interference_JHU_ggHSyst_rw_MengsMuV_HeshyXsec_ggHInt_ggHphase  -o Datacard.root

combine -M MultiDimFit Datacard.root -m 125 --freezeParameters MH -n .robustHesse_exp_fa3_ggH_from_AC_HGG_HPlus2Jets --cminDefaultMinimizerStrategy 0 --cminDefaultMinimizerTolerance 1 -P fa3_ggH -P mu_ggH --setParameterRanges muV=0,5:mu_ggH=0,5:fa3_ggH=-1,1:fa3=-1,1 --floatOtherPOIs=1 --setParameters muV=1,mu_ggH=1,fa3_ggH=0,fa3=0 --robustHesse 1 --robustHesseSave 1 --saveFitResult  

root robustHesse.robustHesse_exp_fa3_ggH_from_AC_HGG_HPlus2Jets.root 



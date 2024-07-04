text2workspace.py Datacard.txt  -m 125.0  -P HiggsAnalysis.CombinedLimit.FA3_Interference_JHU_ggHSyst_rw_MengsMuV_HeshyXsec_ggHInt_ggHphase:FA3_Interference_JHU_ggHSyst_rw_MengsMuV_HeshyXsec_ggHInt_ggHphase  -o Datacard.root

combine -M MultiDimFit Datacard.root -n _scan2D_exp_fa3_ggH_from_AC_HGG_HPlus2Jets -m 125 --algo=grid --alignEdges 1 --points=200  -P fa3_ggH -P muV --floatOtherPOIs=1 --setParameterRanges muV=0,5:mu_ggH=0,5:fa3_ggH=-1,1:fa3=-1,1 --setParameters muV=1,mu_ggH=1,fa3_ggH=0,fa3=0 --X-rtd MINIMIZER_analytic --cminDefaultMinimizerStrategy 0 --cminDefaultMinimizerTolerance 1 -t -1 -v 5

#python plot1DScan.py higgsCombine_scan_exp_fa3_ggH_from_AC_HGG_HPlus2Jets.MultiDimFit.mH125.root --POI fa3_ggH  --y-max 2 -o scan

python plot2DScan.py

display scan2D.png


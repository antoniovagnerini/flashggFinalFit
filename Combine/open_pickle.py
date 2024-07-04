import pandas as pd

# Specify the path to the .pkl file
file_path = '/afs/cern.ch/user/j/jhossain/public/Hgg_AC_Combine/2D_cat/Datacard_Output/yields_bin'

nbins = 12

lumi=41480

ggH_SM_yields = []
VBF_SM_yields = []

for i in range(nbins) :

    data = pd.read_pickle(file_path+str(i)+"/AC_Bin"+str(i)+".pkl")
    ggH_SM_yield = data.iloc[0, 11] #for GGH SM sample
    VBF_SM_yield = data.iloc[3, 11] #for VBF SM sample

    print("ggH yield",str(i),"=", ggH_SM_yield)
    print("VBF yield",str(i),"=", VBF_SM_yield)

    ggH_SM_yields.append(ggH_SM_yield)
    VBF_SM_yields.append(VBF_SM_yield)

    print(data)

total_ggH_SM_yield = sum(ggH_SM_yields)*lumi
total_VBF_SM_yield = sum(VBF_SM_yields)*lumi

print("total ggH SM yield =", total_ggH_SM_yield, "VBF SM yield =", total_VBF_SM_yield )

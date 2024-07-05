import ROOT
import os
import glob
import re
from optparse import OptionParser
import subprocess
import json


def rooiter(x):
  iter = x.iterator()
  ret = iter.Next()
  while ret:
    yield ret
    ret = iter.Next()

def get_options():
    parser = OptionParser()
    parser.add_option('--MH', dest='MH', default='125', help="MH")
    parser.add_option('--initial-fit-param', dest='initial_fit_param', default='lumi_13TeV_Correlated', help="Initial fit parameters")
    parser.add_option('--nToys', dest='nToys', default=100, type='int', help="Number of toys")
    parser.add_option('--nJobs', dest='nJobs', default=200, type='int', help="Number of jobs")
    parser.add_option('--mode', dest='mode', default="setup", help="[setup,generate,fixed,envelope,hadd]")
    parser.add_option('--batch', dest='batch', default='condor', help='Batch: [crab,condor/SGE/IC/lxbatch]')
    parser.add_option('--queue', dest='queue', default='tomorrow', help='Queue e.g. for condor=workday, for IC=hep.q')
    parser.add_option('--subOpts', dest='subOpts', default="", help="Submission options")
    parser.add_option('--year', dest='year', default="2017", help="Year e.g. 2016preVFP, 2016postVFP, 2017, 2018, Combine")
    return parser.parse_args()
(opt,args) = get_options()

# Options for job submission                                                                                                      
if opt.batch == 'condor':
  sub_opts = "--sub-opts=\'+JobFlavour = \"%s\""%opt.queue
  if opt.subOpts != "": sub_opts += "\n%s"%opt.subOpts
  sub_opts += "\'"
  job_opts = "--job-mode condor %s"%sub_opts
elif( opt.batch == 'SGE' )|( opt.batch == 'IC' )|( opt.batch == 'lxbatch' ):
  sub_opts = "--sub-opts=\'-q %s"%opt.queue
  if opt.subOpts != "": sub_opts += " %s"%opt.subOpts
  sub_opts += "\'"
  job_opts = "--job-mode %s %s"%(opt.batch,sub_opts)
elif opt.batch == "local":
  job_opts = ""
  print("--> Will print the commands to run combine without combineTool interactively\n\n")
else:
  print(" --> [ERROR] Batch mode (%s) not supported. Leaving"%opt.batch)
  leave()


if opt.mode == "setup":

    # Get list of pdfindeices
    f = ROOT.TFile("Datacard_%s.root"%(opt.year))
    w = f.Get("w")
    cats = w.allCats()
    pdf_index = []
    for cat in rooiter(cats):
        if "pdfindex" in cat.GetName(): pdf_index.append(cat.GetName()) 
    f.Close()
   
    # Initial fit fixing params to be zero
    cmd = "combine -m %s -d Datacard_%s.root -M MultiDimFit --cminDefaultMinimizerStrategy 0 --setParameters MH=%s,mu_ggH=1,muV=1,fa3_ggH=0,fa3=0 --setParameterRanges muV=0,5:mu_ggH=0,5:fa3_ggH=-1,1:fa3=-1,1 --freezeParameters MH,muV,mu_ggH,fa3,fa3_ggH --floatOtherPOIs 1 -P %s -n _initial_%s --saveWorkspace --saveSpecifiedIndex %s --X-rtd MINIMIZER_freezeDisassociatedParams --X-rtd MINIMIZER_multiMin_hideConstants --X-rtd MINIMIZER_multiMin_maskConstraints --X-rtd MINIMIZER_multiMin_maskChannels=2;"%(opt.MH,opt.year,opt.MH,opt.initial_fit_param,opt.year,",".join(pdf_index))
    print(cmd)
    os.system(cmd)

    # Save best fit pdf indices to json file
    f_res = ROOT.TFile("higgsCombine_initial_%s.MultiDimFit.mH%s.root"%(opt.year,opt.MH))
    t = f_res.Get("limit")
    t.GetEntry(0)
    pdf_index_bf = {}
    for index in pdf_index: pdf_index_bf[index] = getattr(t,index)
    f_res.Close()
    with open("pdfindex.json","w") as jf:
        json.dump(pdf_index_bf, jf)

if opt.mode == "generate":

    if not os.path.isdir("toys"):
        os.system("mkdir -p toys")

    if not os.path.isdir("jobs_toys"):
        os.system("mkdir -p jobs_toys")

    else:  
        os.system("rm jobs_toys/do_gen*")


    for i_job in range(opt.nJobs):

        cmd = "python3 combineTool.py --task-name do_gen_%g -m %s -d higgsCombine_initial_%s.MultiDimFit.mH%s.root -M GenerateOnly --setParameters MH=%s,mu_ggH=1,muV=1,fa3_ggH=0,fa3=0 --freezeParameters MH,muV,mu_ggH,fa3,fa3_ggH -n _toy_%g --saveToys --snapshotName MultiDimFit -t %s -s -1"%(i_job,opt.MH,opt.year,opt.MH,opt.MH,i_job,opt.nToys)
        
        cmd += " %s;"%job_opts
       
        print(cmd)
        os.system(cmd)

if opt.mode == "fixed":
  
    if not os.path.isdir("fits_fixed"):
        os.system("mkdir -p fits_fixed")

    if not os.path.isdir("jobs_fits_fixed"):
        os.system("mkdir -p jobs_fits_fixed")
    else:
        # Remove previous jobs                                                                                                   
        os.system("rm jobs_fits_fixed/do_fixed_*")

    # Get pdf index and the best fit values
    with open("pdfindex.json", "r") as jf:
        pdf_index_bf = json.load(jf)
 
    pdf_index_save = ",".join(pdf_index_bf.keys())
    pdf_index_freeze = ",".join(pdf_index_bf.keys())
    pdf_index_set = ""
    for k,v in pdf_index_bf.items(): pdf_index_set += "%s=%s,"%(k,v)
    pdf_index_set = pdf_index_set[:-1]

    for i_job in range( opt.nJobs ):

        cmd = "mv higgsCombine_toy_%g.* toys/toy_%g.root; \n"%(i_job,i_job)
        cmd = "mv do_gen_%g* jobs_toys/ ; mv condor_do_gen_%g* jobs_toys/ "%(i_job,i_job)
        os.system(cmd)
    
    for i_job in range( opt.nJobs ):

        cmd = "python3 combineTool.py --task-name do_fixed_%g -m %s -d higgsCombine_initial_%s.MultiDimFit.mH%s.root -M Significance --snapshotName MultiDimFit --cminDefaultMinimizerStrategy 0 --setParameters MH=%s,%s,mu_ggH=1,muV=1,fa3_ggH=0,fa3=0 --freezeParameters MH,%s,mu_ggH,muV,fa3_ggH,fa3 -n _fixed_%g --setParameterRanges muV=0,5:mu_ggH=0,5:fa3_ggH=-1,1:fa3=-1,1 -t %s --toysFile toys/toy_%g.root --X-rtd MINIMIZER_freezeDisassociatedParams --X-rtd MINIMIZER_multiMin_hideConstants --X-rtd MINIMIZER_multiMin_maskConstraints --X-rtd MINIMIZER_multiMin_maskChannels=2 --X-rtd ADDNLL_RECURSIVE=1"%(i_job,opt.MH,opt.year,opt.MH,opt.MH,pdf_index_set,pdf_index_freeze,i_job,opt.nToys,i_job)
        
        cmd += " %s;\n"%job_opts      
        print(cmd)
        os.system(cmd)

if opt.mode == "envelope":

    if not os.path.isdir("fits_envelope"):
        os.system("mkdir -p fits_envelope")

    if not os.path.isdir("jobs_fits_envelope"):
        os.system("mkdir -p jobs_fits_envelope")
    else:
        # Remove previous jobs
        os.system("rm jobs_fits_envelope/do_env*")

    # Get pdf index and the best fit values
    with open("pdfindex.json", "r") as jf:
        pdf_index_bf = json.load(jf)
 
    pdf_index_save = ",".join(pdf_index_bf.keys())
  
    for i_job in range( opt.nJobs ):

        cmd = "python3 combineTool.py --task-name do_env_%g -m %s -d higgsCombine_initial_%s.MultiDimFit.mH%s.root -M Significance --snapshotName MultiDimFit --cminDefaultMinimizerStrategy 0 --setParameters MH=%s,mu_ggH=1,muV=1,fa3_ggH=0,fa3=0 --freezeParameters MH,mu_ggH,muV,fa3_ggH,fa3 -n _envelope_%g --setParameterRanges muV=0,5:mu_ggH=0,5:fa3_ggH=-1,1:fa3=-1,1 -t %s --toysFile toys/toy_%g.root --X-rtd MINIMIZER_analytic"%(i_job,opt.MH,opt.year,opt.MH,opt.MH,i_job,opt.nToys,i_job)
        
        cmd += " %s;\n"%job_opts
        print(cmd)
        os.system(cmd)

if opt.mode == "hadd":

    for i_job in range( opt.nJobs ):

      cmd = "mv higgsCombine_fixed_%g.* fits_fixed/fit_fixed_%g.root ; \n"%(i_job,i_job)
      cmd += "mv do_fixed_%g* jobs_fits_fixed/ ; mv condor_do_fixed_%g* jobs_fits_fixed/ ; \n\n"%(i_job,i_job)
    
      cmd += "mv higgsCombine_envelope_%g.* fits_envelope/fit_envelope_%g.root ; \n"%(i_job,i_job)
      cmd += "mv do_env_%g.* jobs_fits_envelope/ ; mv condor_do_env_%g* jobs_fits_envelope/ ; \n"%(i_job,i_job)
  
      os.system(cmd)

    # Mergeing all the output

    cmd = "hadd -f fit_fixed.root fits_fixed/fit_fixed_*.root"
    print(cmd)
    os.system(cmd)

    cmd = "hadd -f fit_envelope.root fits_envelope/fit_envelope_*.root"
    print(cmd)
    os.system(cmd)

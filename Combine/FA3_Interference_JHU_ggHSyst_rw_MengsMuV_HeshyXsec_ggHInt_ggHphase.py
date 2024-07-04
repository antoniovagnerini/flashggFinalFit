from HiggsAnalysis.CombinedLimit.PhysicsModel import *
import re

# Constraints on Hgg couplings, individual fit on POI, see Section VI.A. in PHYS.REV.D104,052004(2021) for notation.
# Custodial symmetry assumed, ai_ZZ suffix dropped -> ai

class FA3_Interference_JHU_ggHSyst_rw_MengsMuV_HeshyXsec_ggHInt_ggHphase(PhysicsModel):
    def doParametersOfInterest(self):
        #Create POI and other parameters, and define the POI set.
        # Generator specific (JHUGen) values of inclusive xsec H->ZZ>4l taken from https://twiki.cern.ch/twiki/bin/view/CMS/Run2MCProductionforHiggsProperties#JHUGen_H_2jets_Production_JHUGen
        xsecs = {
            "sigma1_HZZ": 290.58626,  
            "sigma3_HZZ": 44.670158,

            "sigma1_VBF": 968.674,   
            "sigma3_VBF": 10909.54,
            "sigma1_ZH":  9022.36,
            "sigma3_ZH":  434763.7,
            "sigma1_WH":  30998.54,
            "sigma3_WH":  2028656,

            "sigmaa1a3int_VBF": 1937.15,
            "sigmaa1a3int_ZH": 18044.72,
            "sigmaa1a3int_WH": 61997.07,

            "sigma_SM_ggH": 15980,
            "sigma_BSM_ggH": 15981, # sigma_BSM_ggH:=sigma2_ggH =sigma3_ggH ( follows from a2_ggH = a3_ggH = 1; fa3_ggH = 0.5 )

            "categories": 30, # 500,300,200

        }

        # Individual fit with 2 POIs, fa3_ggH and mu_ggH, other params fa3 and muV profiled in fit, fai set to 0 for i !=3
        self.modelBuilder.doVar("fa3[0.0,-1.0,1.0]");            # := a3**2 *sigma3_HZZ / {a3**2 *sigma3_HZZ + a1**2 *sigma1_HZZ}     
        self.modelBuilder.doVar("fa3_ggH[0.0,-1.0,1.0]");        # := (a3_gg)**2 /{ (a3_gg)**2 + (a2_gg)**2 }
        self.modelBuilder.doVar("mu_ggH[1.0,0,10]");             # := sigma{ggH/ttH,obs}     /sigma_{SM,exp} applicable for both ggH and ttH production mode
        self.modelBuilder.doVar("muV[1.0,0.0,10.0]");            # := sigma{(VBF+VH),obs}/sigma_{SM,exp}
        self.modelBuilder.doSet("POI","fa3,fa3_ggH,muV,mu_ggH")

        # Derive couplings from fai using normalization sum(fai)=1, and ratio of couplings ai/aj = sqrt(fai/faj*sigmai/sigmaj) * phase
        # Since all couplings assumed to be real, phase = +/- 1
        self.modelBuilder.doVar('expr::a1("sqrt(1-abs(@0))", fa3)')
        self.modelBuilder.doVar('expr::a3("(@0>0 ? 1 : -1) * sqrt(abs(@0)*{sigma1_HZZ}/{sigma3_HZZ})", fa3)'.format(**xsecs))

        self.modelBuilder.doVar('expr::a2_ggH("sqrt(1-abs(@0))", fa3_ggH)')
        self.modelBuilder.doVar('expr::a3_ggH("(@0>0 ? -1 : 1) * sqrt(abs(@0))", fa3_ggH)'.format(**xsecs)) # sigma2_ggH/sigma3_ggH = 1

        # Convenience parameter muV_c = prefactor* muV. Prefactor reabsorbed in overall normalization, see from eq. 23, using Taylor expansion for fa1~1(SM case) and fa3~0
        self.modelBuilder.factory_('expr::muVc("@1/(1+30*abs(@0))", fa3,muV)'.format(**xsecs))  

        # Amplitude decomposition in SM, int, bsm terms such that all terms poistive definite (to avoid negative norms for pdf in combine)
        self.modelBuilder.factory_('expr::smCoupling_VBF("@0*@1**2 - @0*@1*@2*sqrt({sigma3_VBF}/{sigma1_VBF})", muVc,a1,a3)'.format(**xsecs))
        self.modelBuilder.factory_('expr::smCoupling_ZH("@0*@1**2 - @0*@1*@2*sqrt({sigma3_ZH}/{sigma1_ZH})", muVc,a1,a3)'.format(**xsecs))
        self.modelBuilder.factory_('expr::smCoupling_WH("@0*@1**2 - @0*@1*@2*sqrt({sigma3_WH}/{sigma1_WH})", muVc,a1,a3)'.format(**xsecs))

        self.modelBuilder.factory_('expr::smCoupling_ggH("@0*@1**2 -  @0*@1*@2*sqrt({sigma_BSM_ggH}/{sigma_SM_ggH})", mu_ggH,a2_ggH,a3_ggH)'.format(**xsecs))
        self.modelBuilder.factory_('expr::bsmCoupling_ggH("@0*@1**2*{sigma_BSM_ggH}/{sigma_SM_ggH} - @0*@1*@2*sqrt({sigma_BSM_ggH}/{sigma_SM_ggH})", mu_ggH,a3_ggH,a2_ggH)'.format(**xsecs))
        self.modelBuilder.factory_('expr::intCoupling_ggH("@0*@1*@2*sqrt({sigma_BSM_ggH}/{sigma_SM_ggH})*2.", mu_ggH,a2_ggH,a3_ggH)'.format(**xsecs))

        self.modelBuilder.factory_('expr::bsmCoupling_VBF("@0*@1**2*{sigma3_VBF}/{sigma1_VBF} - @0*@1*@2*sqrt({sigma3_VBF}/{sigma1_VBF})", muVc,a3,a1)'.format(**xsecs))
        self.modelBuilder.factory_('expr::bsmCoupling_ZH("@0*@1**2*{sigma3_ZH}/{sigma1_ZH} - @0*@1*@2*sqrt({sigma3_ZH}/{sigma1_ZH})", muVc,a3,a1)'.format(**xsecs))
        self.modelBuilder.factory_('expr::bsmCoupling_WH("@0*@1**2*{sigma3_WH}/{sigma1_WH} - @0*@1*@2*sqrt({sigma3_WH}/{sigma1_WH})", muVc,a3,a1)'.format(**xsecs))

        self.modelBuilder.factory_('expr::intCoupling_VBF("@0*@1*@2*sqrt({sigma3_VBF}/{sigma1_VBF})*{sigmaa1a3int_VBF}/{sigma1_VBF}", muVc,a1,a3)'.format(**xsecs))
        self.modelBuilder.factory_('expr::intCoupling_ZH("@0*@1*@2*sqrt({sigma3_ZH}/{sigma1_ZH})*{sigmaa1a3int_ZH}/{sigma1_ZH}", muVc,a1,a3)'.format(**xsecs))
        self.modelBuilder.factory_('expr::intCoupling_WH("@0*@1*@2*sqrt({sigma3_WH}/{sigma1_WH})*{sigmaa1a3int_WH}/{sigma1_WH}", muVc,a1,a3)'.format(**xsecs))


    def getYieldScale(self,bin,process):

        if process in ["GG2Hsm_2016preVFP_hgg",]:
            return 'smCoupling_ggH'
        if process in ["GG2HbsmM_2016preVFP_hgg",]:
            return 'bsmCoupling_ggH'
        if process in ["GG2HMf05ph0_2016preVFP_hgg"]:
            return 'intCoupling_ggH'
        if process in ["vbf0P_2016preVFP_hgg",]:
            return 'smCoupling_VBF'
        if process in ["vbf0M_2016preVFP_hgg",]:
            return 'bsmCoupling_VBF'
        if process in ["vbf0Mf05ph0_2016preVFP_hgg"]:
            return 'intCoupling_VBF'
        if process in ["wh0P_2016preVFP_hgg",]:
            return 'smCoupling_WH'
        if process in ["wh0M_2016preVFP_hgg",]:
            return 'bsmCoupling_WH'
        if process in ["wh0Mf05ph0_2016preVFP_hgg"]:
            return 'intCoupling_WH'
        if process in ["zh0P_2016preVFP_hgg",]:
            return 'smCoupling_ZH'
        if process in ["zh0M_2016preVFP_hgg",]:
            return 'bsmCoupling_ZH'
        if process in ["zh0Mf05ph0_2016preVFP_hgg"]:
            return 'intCoupling_ZH'

        if process in ["tth0P_2016preVFP_hgg",]:
            return 'mu_ggH'


        if process in ["GG2Hsm_2016postVFP_hgg",]:
            return 'smCoupling_ggH'
        if process in ["GG2HbsmM_2016postVFP_hgg",]:
            return 'bsmCoupling_ggH'
        if process in ["GG2HMf05ph0_2016postVFP_hgg"]:
            return 'intCoupling_ggH'
        if process in ["vbf0P_2016postVFP_hgg",]:
            return 'smCoupling_VBF'
        if process in ["vbf0M_2016postVFP_hgg",]:
            return 'bsmCoupling_VBF'
        if process in ["vbf0Mf05ph0_2016postVFP_hgg"]:
            return 'intCoupling_VBF'
        if process in ["wh0P_2016postVFP_hgg",]:
            return 'smCoupling_WH'
        if process in ["wh0M_2016postVFP_hgg",]:
            return 'bsmCoupling_WH'
        if process in ["wh0Mf05ph0_2016postVFP_hgg"]:
            return 'intCoupling_WH'
        if process in ["zh0P_2016postVFP_hgg",]:
            return 'smCoupling_ZH'
        if process in ["zh0M_2016postVFP_hgg",]:
            return 'bsmCoupling_ZH'
        if process in ["zh0Mf05ph0_2016postVFP_hgg"]:
            return 'intCoupling_ZH'

        if process in ["tth0P_2016postVFP_hgg",]:
            return 'mu_ggH'


        if process in ["GG2Hsm_2017_hgg",]:
            return 'smCoupling_ggH'
        if process in ["GG2HbsmM_2017_hgg",]:
            return 'bsmCoupling_ggH'
        if process in ["GG2HMf05ph0_2017_hgg"]:
            return 'intCoupling_ggH'
        if process in ["vbf0P_2017_hgg",]:
            return 'smCoupling_VBF'
        if process in ["vbf0M_2017_hgg",]:
            return 'bsmCoupling_VBF'
        if process in ["vbf0Mf05ph0_2017_hgg"]:
            return 'intCoupling_VBF'
        if process in ["wh0P_2017_hgg",]:
            return 'smCoupling_WH'
        if process in ["wh0M_2017_hgg",]:
            return 'bsmCoupling_WH'
        if process in ["wh0Mf05ph0_2017_hgg"]:
            return 'intCoupling_WH'
        if process in ["zh0P_2017_hgg",]:
            return 'smCoupling_ZH'
        if process in ["zh0M_2017_hgg",]:
            return 'bsmCoupling_ZH'
        if process in ["zh0Mf05ph0_2017_hgg"]:
            return 'intCoupling_ZH'

        if process in ["tth0P_2017_hgg",]:
            return 'mu_ggH'


        if process in ["GG2Hsm_2018_hgg",]:
            return 'smCoupling_ggH'
        if process in ["GG2HbsmM_2018_hgg",]:
            return 'bsmCoupling_ggH'
        if process in ["GG2HMf05ph0_2018_hgg"]:
            return 'intCoupling_ggH'
        if process in ["vbf0P_2018_hgg",]:
            return 'smCoupling_VBF'
        if process in ["vbf0M_2018_hgg",]:
            return 'bsmCoupling_VBF'
        if process in ["vbf0Mf05ph0_2018_hgg"]:
            return 'intCoupling_VBF'
        if process in ["wh0P_2018_hgg",]:
            return 'smCoupling_WH'
        if process in ["wh0M_2018_hgg",]:
            return 'bsmCoupling_WH'
        if process in ["wh0Mf05ph0_2018_hgg"]:
            return 'intCoupling_WH'
        if process in ["zh0P_2018_hgg",]:
            return 'smCoupling_ZH'
        if process in ["zh0M_2018_hgg",]:
            return 'bsmCoupling_ZH'
        if process in ["zh0Mf05ph0_2018_hgg"]:
            return 'intCoupling_ZH'

        if process in ["tth0P_2018_hgg",]:
            return 'mu_ggH'

        return 1


FA3_Interference_JHU_ggHSyst_rw_MengsMuV_HeshyXsec_ggHInt_ggHphase = FA3_Interference_JHU_ggHSyst_rw_MengsMuV_HeshyXsec_ggHInt_ggHphase()




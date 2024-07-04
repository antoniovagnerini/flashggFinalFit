outdate=`date +%F`

STEP=0
YEAR=0

usage(){
    echo "Script to run fits and plots of fit output. dryRun option is for the fitting only, that can be run in batch."
    echo "options:"

    echo "-y|--year <year> Specify the year"
    echo "-h|--help       Display this help message"
    echo "-s|--step <step> Specify the step"
 
}

# options may be followed by one colon to indicate they have a required argument                                                  
if ! options=$(getopt -u -o s:hd -l help,step:,year: -- "$@")
then
    # something went wrong, getopt will put out an error message for us                                                          
    exit 1
fi
set -- $options
while [ $# -gt 0 ]
do
    case $1 in
        -h|--help) usage; shift;;
        -y|--year) YEAR=$2; shift ;;
        -s|--step) STEP=$2; shift ;;
	(--) shift; break;;
	(-*) usage; echo "$0: error - unrecognized option $1" 1>&2; usage >> /dev/stderr; exit 1;;
	(*) break;;
    esac
    shift
done


if [[ $STEP == "t2w" ]]; then

	text2workspace.py Datacard_${YEAR}.txt -m 125.0  -P HiggsAnalysis.CombinedLimit.FA3_Interference_JHU_ggHSyst_rw_MengsMuV_HeshyXsec_ggHInt_ggHphase:FA3_Interference_JHU_ggHSyst_rw_MengsMuV_HeshyXsec_ggHInt_ggHphase  -o Datacard_${YEAR}.root


elif [[ $STEP == "bias-setup" ]]; then

	python RunBiasInSignificance_ggh_AC.py --MH 125 --year ${YEAR} --mode setup 

elif [[ $STEP == "bias-generate" ]]; then

	python RunBiasInSignificance_ggh_AC.py --MH 125 --year ${YEAR} --mode generate 

elif [[ $STEP == "bias-fixed" ]]; then

	python RunBiasInSignificance_ggh_AC.py --MH 125 --year ${YEAR} --mode fixed

elif [[ $STEP == "bias-envelope" ]]; then

	python RunBiasInSignificance_ggh_AC.py --MH 125 --year ${YEAR} --mode envelope

elif [[ $STEP == "bias-hadd" ]]; then

        python RunBiasInSignificance_ggh_AC.py --MH 125 --mode hadd

elif [[ $STEP == "bias-plot" ]]; then

	python SummaryBiasSignificance.py

else
    echo "Step $STEP is not one among t2w,bias-setup,bias-generate,bias-fixed,bias-envelope,bias-hadd,bias-plot. Exiting."
fi



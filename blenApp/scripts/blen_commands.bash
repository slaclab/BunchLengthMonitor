#BLEN commands for working with the system

source /usr/local/lcls/package/IPMC/env.sh
    
function blen_restart(){
    siocRestart sioc-htr-bl01
    siocRestart sioc-bc1b-bl01
    siocRestart sioc-bc2b-bl01
}

function blen_program_fpga(){
    loc=/usr/local/lcls/package/cpsw/utils/ProgramFPGA/current
    $loc/ProgramFPGA.bash -s shm-l0b-sp01-2 -n 4 -c cpu-l0b-sp01 -m $1
    $loc/ProgramFPGA.bash -s shm-bc1b-sp01-2 -n 5 -c cpu-bc1b-sp01 -m $1
    $loc/ProgramFPGA.bash -s shm-l2b-sp03-2  -n 4 -c cpu-l2b-sp03 -m $1
}

#This function fills the trigger name
#Argument 1 is the position GUNB/IN10/LI20 etc
#Argument 2 is the iocInstance IM01/BL02 etc
#Argument 3 is the INST arg ie 1,2,3 ect
function gen_name_trig() {
     caput TPR:$1:$2:$3:TPRTRIG00.DESC 'SMA of AMC0'
     caput TPR:$1:$2:$3:TPRTRIG01.DESC 'DOUT0 LEMO of AMC0'
     caput TPR:$1:$2:$3:TPRTRIG02.DESC 'DOUT1 LEMO of AMC0'
     caput TPR:$1:$2:$3:TPRTRIG03.DESC 'SMA of AMC1'
     caput TPR:$1:$2:$3:TPRTRIG04.DESC 'DOUT0 LEMO of AMC1'
     caput TPR:$1:$2:$3:TPRTRIG05.DESC 'DOUT1 LEMO of AMC1'
     caput TPR:$1:$2:$3:TPRTRIG06.DESC 'BSA stream from ATCA to CPU'
     caput TPR:$1:$2:$3:TPRTRIG07.DESC 'Playback of simulated output waveform'
     caput TPR:$1:$2:$3:TPRTRIG08.DESC 'Playback of trigger for DaqMux'
     caput TPR:$1:$2:$3:TPRTRIG09.DESC 'Playback of freeze trigger for DaqMux'
     caput TPR:$1:$2:$3:TPRTRIG10.DESC 'Acquisition for ADC0 on AMC0'
     caput TPR:$1:$2:$3:TPRTRIG11.DESC 'Acquisition for ADC1 on AMC0'
     caput TPR:$1:$2:$3:TPRTRIG12.DESC 'Acquisition for ADC2 on AMC0'
     caput TPR:$1:$2:$3:TPRTRIG13.DESC 'Acquisition for ADC0 on AMC1'
     caput TPR:$1:$2:$3:TPRTRIG14.DESC 'Acquisition for ADC1 on AMC1'
     caput TPR:$1:$2:$3:TPRTRIG15.DESC 'Acquisition for ADC2 on AMC1'
}

function blen_crate_firmware(){
    printf "HTR gap diode\n\n"
    amcc_dump_bsi --all shm-l0b-sp01-2/4
    printf  "BC1B Pyro\n\n"
    amcc_dump_bsi --all shm-bc1b-sp01-2/5
    printf  "BC2B Pyro\n\n"
    amcc_dump_bsi --all shm-l2b-sp03-2/4
}


#This function fills the trigger name
#Argument 1 is the position GUNB/IN10/LI20 etc
#Argument 2 is the iocInstance IM01/BL02 etc
#Argument 3 is the INST arg ie 1,2,3 ect
function blen_set_trig(){
    caput TPR:$1:$2:$3:TRG00_SYS2_TCTL 0
    caput TPR:$1:$2:$3:TRG01_SYS2_TCTL 1
    caput TPR:$1:$2:$3:TRG02_SYS2_TCTL 1
    caput TPR:$1:$2:$3:TRG03_SYS2_TCTL 1
    caput TPR:$1:$2:$3:TRG04_SYS2_TCTL 1
    caput TPR:$1:$2:$3:TRG05_SYS2_TCTL 1
    caput TPR:$1:$2:$3:TRG06_SYS2_TCTL 1
    caput TPR:$1:$2:$3:TRG07_SYS2_TCTL 1
    caput TPR:$1:$2:$3:TRG08_SYS2_TCTL 1
    caput TPR:$1:$2:$3:TRG09_SYS2_TCTL 0
    caput TPR:$1:$2:$3:TRG10_SYS2_TCTL 1
    caput TPR:$1:$2:$3:TRG11_SYS2_TCTL 0
    caput TPR:$1:$2:$3:TRG12_SYS2_TCTL 0
    caput TPR:$1:$2:$3:TRG13_SYS2_TCTL 1
    caput TPR:$1:$2:$3:TRG14_SYS2_TCTL 0
    caput TPR:$1:$2:$3:TRG15_SYS2_TCTL 0
    
    caput TPR:$1:$2:$3:CH00_FIXEDRATE 6
    caput TPR:$1:$2:$3:CH01_FIXEDRATE 6
    caput TPR:$1:$2:$3:CH02_FIXEDRATE 6
    caput TPR:$1:$2:$3:CH03_FIXEDRATE 6
    caput TPR:$1:$2:$3:CH04_FIXEDRATE 6
    caput TPR:$1:$2:$3:CH05_FIXEDRATE 6
    caput TPR:$1:$2:$3:CH06_FIXEDRATE 0
    caput TPR:$1:$2:$3:CH07_FIXEDRATE 6
    caput TPR:$1:$2:$3:CH08_FIXEDRATE 0
    caput TPR:$1:$2:$3:CH09_FIXEDRATE 6
    caput TPR:$1:$2:$3:CH10_FIXEDRATE 6
    caput TPR:$1:$2:$3:CH11_FIXEDRATE 6
    caput TPR:$1:$2:$3:CH12_FIXEDRATE 6
    caput TPR:$1:$2:$3:CH13_FIXEDRATE 6
    caput TPR:$1:$2:$3:CH14_FIXEDRATE 6
    caput TPR:$1:$2:$3:CH15_FIXEDRATE 6
    
    caput TPR:$1:$2:$3:CH00_SYS2_TCTL 1
    caput TPR:$1:$2:$3:CH01_SYS2_TCTL 1
    caput TPR:$1:$2:$3:CH02_SYS2_TCTL 1
    caput TPR:$1:$2:$3:CH03_SYS2_TCTL 1
    caput TPR:$1:$2:$3:CH04_SYS2_TCTL 1
    caput TPR:$1:$2:$3:CH05_SYS2_TCTL 1
    caput TPR:$1:$2:$3:CH06_SYS2_TCTL 1
    caput TPR:$1:$2:$3:CH07_SYS2_TCTL 1
    caput TPR:$1:$2:$3:CH08_SYS2_TCTL 1
    caput TPR:$1:$2:$3:CH09_SYS2_TCTL 0
    caput TPR:$1:$2:$3:CH10_SYS2_TCTL 1
    caput TPR:$1:$2:$3:CH11_SYS2_TCTL 1
    caput TPR:$1:$2:$3:CH12_SYS2_TCTL 1
    caput TPR:$1:$2:$3:CH13_SYS2_TCTL 1
    caput TPR:$1:$2:$3:CH14_SYS2_TCTL 1
    caput TPR:$1:$2:$3:CH15_SYS2_TCTL 1
    
    caput TPR:$1:$2:$3:CH00_ACRATE 5
    caput TPR:$1:$2:$3:CH01_ACRATE 5
    caput TPR:$1:$2:$3:CH02_ACRATE 5
    caput TPR:$1:$2:$3:CH03_ACRATE 5
    caput TPR:$1:$2:$3:CH04_ACRATE 5
    caput TPR:$1:$2:$3:CH05_ACRATE 5
    caput TPR:$1:$2:$3:CH06_ACRATE 5
    caput TPR:$1:$2:$3:CH07_ACRATE 5
    caput TPR:$1:$2:$3:CH08_ACRATE 5
    caput TPR:$1:$2:$3:CH08_ACRATE 5
    caput TPR:$1:$2:$3:CH10_ACRATE 5
    caput TPR:$1:$2:$3:CH11_ACRATE 5
    caput TPR:$1:$2:$3:CH12_ACRATE 5
    caput TPR:$1:$2:$3:CH13_ACRATE 5
    caput TPR:$1:$2:$3:CH14_ACRATE 5
    caput TPR:$1:$2:$3:CH15_ACRATE 5
    
    caput TPR:$1:$2:$3:CH00_DESTMODE 2
    caput TPR:$1:$2:$3:CH01_DESTMODE 2
    caput TPR:$1:$2:$3:CH02_DESTMODE 2
    caput TPR:$1:$2:$3:CH03_DESTMODE 2
    caput TPR:$1:$2:$3:CH04_DESTMODE 2
    caput TPR:$1:$2:$3:CH05_DESTMODE 2
    caput TPR:$1:$2:$3:CH06_DESTMODE 2
    caput TPR:$1:$2:$3:CH07_DESTMODE 2
    caput TPR:$1:$2:$3:CH08_DESTMODE 2
    caput TPR:$1:$2:$3:CH09_DESTMODE 2
    caput TPR:$1:$2:$3:CH10_DESTMODE 2
    caput TPR:$1:$2:$3:CH11_DESTMODE 2
    caput TPR:$1:$2:$3:CH12_DESTMODE 2
    caput TPR:$1:$2:$3:CH13_DESTMODE 2
    caput TPR:$1:$2:$3:CH14_DESTMODE 2
    caput TPR:$1:$2:$3:CH15_DESTMODE 2
}

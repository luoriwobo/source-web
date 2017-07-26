#!/bin/bash
#edit by leo at 20170629
#please write the parameter before use this script
echo "[1]add s6 configure"
echo "[2]delete s6 configure"
stty erase '^H'
read -p "num=" num
if [ "$num" == "1" ]
then
echo "------------begin add s6 configure parameter-------------------"
#################################################################################
    mme_IP=192.168.11.214
    mme_Realm=mme.com
    hss_Realm=hss.com
    hss_hostId=212.hss.com
    HSS1_ip=192.168.11.212
    mme_hostPre=214
##################################################################################	
	if [[ $mme_hostPre =~ ^[0-9]\{1,\}$ ]]; then
        echo "agw mme interfaces diameter s6 s6-instance add agwMmeS6 $mme_hostPre MmeS6a 3868 500"|cli
	else
        stty erase '^H'
	    read -p "please input correct mme_hostPre,it is the last number of mme ip:" mme_hostPre2
        mme_hostPre=$mme_hostPre2
        echo "agw mme interfaces diameter s6 s6-instance add agwMmeS6 $mme_hostPre MmeS6a 3868 500"|cli
	fi
    echo "agw mme interfaces diameter diameter-profile add s6aDm s6aSctp $mme_Realm $hss_Realm 5 30 2 30 true"|cli
    echo "agw mme interfaces diameter peer add $hss_hostId $HSS1_ip 3868 primary"|cli
    echo "agw mme interfaces diameter s6 s6-if add s6 s6aDm 5 2 1 false"|cli
    echo "agw mme interfaces diameter sub-realm add $hss_Realm s6 local agwMmeS6"|cli
    echo "agw mme interfaces diameter sub-realm-peer-map add $hss_Realm $hss_hostId"|cli
    echo "agw mme imsi-routing hsshlr-imsi-mask add * s6 $hss_Realm"|cli
    echo "aim service-group add agwMmeS6 agwMmeS6 1 0 0"|cli
    echo "aim service-unit add agwMmeS6 0 0 0 3 0"|cli
    echo "aim service-unit load agwMmeS6 0"|cli
    echo "aim service-unit unlock agwMmeS6 0"|cli
    echo "aim service-unit lock agwMmeSc 1 force"|cli
    echo "aim service-unit unload agwMmeSc 1"|cli
    echo "aim service-unit lock agwMmeSc 0 force"|cli
    echo "aim service-unit unload agwMmeSc 0"|cli
	tool=$(grep -rl S6IF_ROUTER=LOCAL /tftpboot/ppb/i686/opt/epc/agw/3.0.0/bin/)
	if [ "$tool" != "" ]
	then
        sed -i 's/S6IF_ROUTER=LOCAL/S6IF_ROUTER=HSS/g' `grep -rl S6IF_ROUTER=LOCAL /tftpboot/ppb/i686/opt/epc/agw/3.0.0/bin/agwMmeScAmf_env.sh`
	else
        echo "HSS connection is already configured"
        fi
    echo " aim service-unit load agwMmeSc 0  " | cli
    echo " aim service-unit unlock agwMmeSc 0 " | cli
    echo " aim service-unit load agwMmeSc 1 "| cli
    echo " aim service-unit unlock agwMmeSc 1 " | cli
	
elif [ "$num" == "2" ]
then
    echo "-------------------begin delete s6 configure----------------------------"
    echo " aim service-unit lock agwMmeS6 0 force " | cli
    echo " aim service-unit unload agwMmeS6 0 " | cli
    echo " aim service-unit delete agwMmeS6 0 " |cli
    echo " aim service-group delete agwMmeS6 " |cli
    echo "agw mme imsi-routing hsshlr-imsi-mask delete *"|cli
    hssRealm=`echo " agw mme interfaces diameter sub-realm-peer-map show all detailed "|cli_client|awk 'NR==4{print}'|awk '{print $3}'`
    hsshostId=`echo " agw mme interfaces diameter sub-realm-peer-map show all detailed "|cli_client|awk 'NR==5{print}'|awk '{print $3}'`
    hssRealm=${hssRealm%?}
    hsshostId=${hsshostId%?}
    echo " agw mme interfaces diameter sub-realm-peer-map delete $hssRealm $hsshostId "|cli
    echo " agw mme interfaces diameter sub-realm delete $hssRealm "|cli
    echo " agw mme interfaces diameter s6 s6-instance delete agwMmeS6 "|cli
    echo " agw mme interfaces diameter s6 s6-if delete s6 "|cli
    echo " agw mme interfaces diameter peer delete $hsshostId "|cli
    echo " agw mme interfaces diameter diameter-profile delete s6aDm "|cli
else [ "$num" != "1" ] || [ "$num" != "2" ]
    echo "please input correct number!!"
fi

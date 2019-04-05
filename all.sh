for (( i = 0; i < 4; i++ )); do
	./run.sh &
	
	sleep 30
	
	./report.sh
	
	docker ps -aq | xargs docker stop | xargs docker rm; docker volume rm -f ;
	
	sleep 30
done;

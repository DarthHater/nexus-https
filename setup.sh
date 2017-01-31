#!/bin/sh
# Wait for Nexus Repository to start
until [ $(curl -sf -o /dev/null -w "%{http_code}" 'http://localhost:8081/service/siesta/rest/v1/script') -eq "403" ];do echo "Waiting for nexus to start ...";sleep 7;done
# Welp
if [ $(curl -sf -o /dev/null -w "%{http_code}" -X GET -u admin:${NEXUS_PASSWORD} 'http://localhost:8081/service/siesta/rest/v1/script') -eq "200" ]; then
	curl -sf -X POST -u admin:${NEXUS_PASSWORD} --header "Content-Type: application/json" 'http://localhost:8081/service/siesta/rest/v1/script' -d "{\"name\":\"docker-hosted\",\"type\":\"groovy\",\"content\":\"repository.createDockerHosted('docker-hosted', null, 5000, 'default', true, false)\"}"
	curl -sf -X POST -u admin:${NEXUS_PASSWORD} --header "Content-Type: application/json" 'http://localhost:8081/service/siesta/rest/v1/script' -d "{\"name\":\"docker-proxy\",\"type\":\"groovy\",\"content\":\"repository.createDockerProxy('docker-proxy', 'https://registry-1.docker.io', 'HUB', 'https://index.docker.io/', null, 5001, 'default', true, false)\"}"
	curl -sf -X POST -u admin:${NEXUS_PASSWORD} --header "Content-Type: text/plain" "http://localhost:8081/service/siesta/rest/v1/script/docker-hosted/run"
	curl -sf -X POST -u admin:${NEXUS_PASSWORD} --header "Content-Type: text/plain" "http://localhost:8081/service/siesta/rest/v1/script/docker-proxy/run"
	curl -sf -X DELETE -u admin:${NEXUS_PASSWORD} 'http://localhost:8081/service/siesta/rest/v1/script/docker-hosted'
	curl -sf -X DELETE -u admin:${NEXUS_PASSWORD} 'http://localhost:8081/service/siesta/rest/v1/script/docker-proxy'
fi
#!/bin/bash

source_dashboards="${PWD}/grafana/dashboards/."
target_dashboards="/etc/grafana/provisioning/dashboards/"

sudo find "${target_dashboards}" -type f -name '*.json' -exec rm {} \+

if [ $? -ne 0 ]; then
    echo "Failed to remove old dashboards"
fi

sudo cp -r "${source_dashboards}" "${target_dashboards}"

if [ $? -eq 0 ]; then
    echo "Dashboards copied successfully."
else
    echo "Failed to copy dashboards"
    exit 1
fi

find "${target_dashboards}" -type f -name '*.json' -exec sudo sed -i 's/\${DS_PROMETHEUS_DOCKER}/Prometheus-docker/g' {} \+
find "${target_dashboards}" -type f -name '*.json' -exec sudo sed -i 's/\${DS_PROMETHEUS}/Prometheus/g' {} \+

source_datasources="${PWD}/grafana/datasources/"
target_datasources="/etc/grafana/provisioning/datasources/"

sudo find "${target_datasources}" -type f -name '*.yml' -exec rm {} \+
sudo cp -r "${source_datasources}" "${target_datasources}"

if [ $? -eq 0 ]; then
    echo "Datasources copied successfully."
else
    echo "Failed to copy Datasources"
    exit 1
fi
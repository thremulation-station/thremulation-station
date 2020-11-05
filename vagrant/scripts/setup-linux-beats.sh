#!/bin/bash -eux

echo "Running Filebeat Setup"
sleep 3

sudo filebeat setup

echo "Running Auditbeat Setup"
sleep 3

sudo auditbeat setup --dashboards
#!/bin/bash
echo "Run once per project to set up internal network"

gcloud compute firewall-rules create allow-https --allow tcp:443

gcloud compute firewall-rules create allow-http --allow tcp:80

gcloud compute firewall-rules create allow-ldap --allow tcp:636

gcloud compute firewall-rules create allow-django --allow tcp:8000

gcloud compute firewall-rules create allow-postgresql --allow tcp:5432

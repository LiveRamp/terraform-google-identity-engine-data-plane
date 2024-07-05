#!/bin/sh

project=$1
tenantSvc=$2
orchestrationSvc=$3

buckets=($4 $5 $6)
bqDataset=$7

projectRoles=(
	roles/iam.serviceAccountUser
	roles/dataproc.worker
	roles/dataproc.editor
	roles/compute.networkUser
	roles/bigquery.jobUser
	roles/bigquery.user
	roles/bigquery.readSessionUser
)

impersonationRole=roles/iam.serviceAccountTokenCreator

bucketRoles=(
	roles/storage.objectAdmin
	roles/storage.legacyBucketReader
)

bqDatasetRole=WRITER


# Project level permissions
echo ""
echo "Principal: $tenantSvc"
echo ""
echo "Resource: $project"
echo "========"

for i in ${projectRoles[@]}
do
   if gcloud beta asset search-all-iam-policies --query policy:$i --project $project | grep -q $tenantSvc
   then
      echo "$i OK"
   else
      echo "$i FAIL"
   fi
done


# Impersonation permissions
echo ""
echo "Resource: $orchestrationSvc"
echo "========"
if gcloud beta asset search-all-iam-policies --format=json --query policy:$impersonationRole --project $project | jq --arg tenantSvc $tenantSvc '.[] | select(.resource | contains($tenantSvc))' | grep -q $orchestrationSvc
then
   echo "$impersonationRole OK"
else
   echo "$impersonationRole FAIL"
fi


# Resource level permissions
# Buckets
for i in ${buckets[@]}
do
   echo ""
   echo "Resource: $i"
   echo "========"
   for j in ${bucketRoles[@]}
   do
      if gcloud storage buckets get-iam-policy gs://$i --format=json | jq --arg role $j '.bindings[] | select(.role==$role)' | grep -q $tenantSvc
      then
         echo "$j OK"
      else
         echo "$j FAIL"
      fi
   done
done


# BigQuery
echo ""
echo "Resource: $bqDataset"
echo "========"

if bq show --format=json id-graph-gl-dev-tenant-data:$bqDataset | jq --arg role $bqDatasetRole '.access[] | select(.role==$role)' | grep -q $tenantSvc
then
   echo "$bqDatasetRole OK"
else
   echo "$bqDatasetRole FAIL"
fi
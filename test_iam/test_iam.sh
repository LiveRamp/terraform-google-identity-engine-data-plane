#!/bin/sh

project=$1
member=$2

buckets=($3 $4 $5)
bqDataset=$6

projectRoles=(
	roles/iam.serviceAccountUser
	roles/dataproc.worker
	roles/dataproc.editor
	roles/compute.networkUser
	roles/bigquery.jobUser
	roles/bigquery.user
	roles/bigquery.readSessionUser
)

bucketRoles=(
	roles/storage.objectAdmin
	roles/storage.legacyBucketReader
)

bqDatasetRole=WRITER


# Project level permissions / roles

echo ""
echo "Principal: $member"
echo ""
echo "Resource: $project"
echo "========"

for i in ${projectRoles[@]}
do
   if gcloud beta asset search-all-iam-policies --query policy:$i --project $project | grep -q $member
   then
      echo "$i OK"
   else
      echo "$i FAIL"
   fi
done


# Resource level permissions

# Buckets
for i in ${buckets[@]}
do
   echo ""
   echo "Resource: $i"
   echo "========"
   for j in ${bucketRoles[@]}
   do
      if gcloud storage buckets get-iam-policy gs://$i --format=json | jq --arg role $j '.bindings[] | select(.role==$role)' | grep -q $member
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

if bq show --format=json id-graph-gl-dev-tenant-data:$bqDataset | jq --arg role $bqDatasetRole '.access[] | select(.role==$role)' | grep -q $member
then
   echo "$bqDatasetRole OK"
else
   echo "$bqDatasetRole FAIL"
fi
#!/bin/sh

projectId=$1
member=$2

buckets=($3 $4 $5)

bucketRoles=(
	roles/storage.objectAdmin
	roles/storage.legacyBucketReader
)

projectRoles=(
	roles/iam.serviceAccountUser
	roles/dataproc.worker
	roles/dataproc.editor
	roles/compute.networkUser
	roles/bigquery.jobUser
	roles/bigquery.user
	roles/bigquery.readSessionUser
)

# Project level roles for service account
echo ""
echo "Resource: $member"
echo "========"

for i in ${projectRoles[@]}
do 
   if gcloud beta asset search-all-iam-policies --query policy:$i --project $projectId | grep -q $member
   then
      echo "$i OK"
   else
      echo "$i FAIL"
   fi
done


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
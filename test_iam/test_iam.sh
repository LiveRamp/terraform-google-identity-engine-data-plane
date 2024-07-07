#!/bin/sh

project=$1
tenantSvc=$2
orchestrationSvc=$3

buckets=($4 $5 $6)
bqDatasets=($7)

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

bqDatasetRoles=(
	WRITER
)


printResource() {
	echo ""
	echo "Resource: $1"
	echo "========"
}

checkProjectPermissions() {
	echo ""
	echo "Principal: $tenantSvc"
	printResource $project
	for i in ${projectRoles[@]}
	do
	   if gcloud beta asset search-all-iam-policies --query policy:$i --project $project | grep -q $tenantSvc
	   then
		  echo "$i OK"
	   else
		  echo "$i FAIL"
	   fi
	done
}

checkImpersonationPermissions() {
	printResource $orchestrationSvc
	if gcloud beta asset search-all-iam-policies --format=json --query policy:$impersonationRole --project $project | jq --arg tenantSvc $tenantSvc '.[] | select(.resource | contains($tenantSvc))' | grep -q $orchestrationSvc
	then
	   echo "$impersonationRole OK"
	else
	   echo "$impersonationRole FAIL"
	fi
}

checkBucketPermissions() {
	for i in ${buckets[@]}
	do
	   printResource $i
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
}

checkBigQueryPermissions() {
for i in ${bqDatasets[@]}
do
	printResource $i
	for j in ${bqDatasetRoles[@]}
	do
		if bq show --format=json id-graph-gl-dev-tenant-data:$i | jq --arg $j $bqDatasetRole '.access[] | select(.role==$role)' | grep -q $tenantSvc
		then
			echo "$j OK"
		else
			echo "$j FAIL"
		fi
	done
done
}

checkProjectPermissions
checkImpersonationPermissions
checkBucketPermissions
checkBigQueryPermissions
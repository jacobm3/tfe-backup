tfe_hostname=ptfe-demo.jacobm.hashidemos.io


###############################################################################
# TFE BACKUP 
# 

date=`date +%Y.%m.%d-%H.%M.%S`
year=`date +%Y`
mon=`date +%m`

filename=backup.${tfe_hostname}.${date}.blob

echo -e "\e[1;32mTFE - Backing up from https://${tfe_hostname}/_backup/api/v1/backup \e[0m"
echo

curl \
  --header "Authorization: Bearer $TOKEN" \
  --request POST \
  --data @payload.json \
  --output $filename \
  --insecure \
  https://${tfe_hostname}/_backup/api/v1/backup


###############################################################################
# AZURE
#
# Copy to Azure blob. Requires these env vars:
# AZURE_STORAGE_ACCOUNT
# AZURE_STORAGE_KEY
# AZURE_STORAGE_CONNECTION_STRING
# 
# -c <container_name> must already exist 

container_name=tfe-backup

echo
echo -e "\e[1;32mAzure - Writing to blob ${AZURE_STORAGE_ACCOUNT}:${container_name}/${filename} \e[0m"

az storage blob upload -f $filename -c $container_name -n $filename



###############################################################################
# AWS
#
# Copy to S3 bucket. Requires these env vars:
# AWS_SECRET_ACCESS_KEY
# AWS_ACCESS_KEY_ID

bucket_name=jmartinson-tfe-backup

echo
echo -e "\e[1;32mAWS - Writing to S3 s3://${bucket_name}/${filename} \e[0m"

aws s3 cp $filename s3://${bucket_name}



###############################################################################
# GCP 
# 
# Save GCP JSON account file and activate it like this:
# $ gcloud auth activate-service-account --key-file=<svc-acct.json>

bucket_name=jmartinson-tfe-backup

echo
echo -e "\e[1;32mGCP - Writing to GCS gs://${bucket_name}/${filename} \e[0m"

gsutil cp $filename gs://${bucket_name}



###############################################################################
# Restore to warm standby TFE
#


# TODO finish this section
exit

echo "Restoring backup to standby TFE at https://${tfe_hostname}/_backup/api/v1/backup"
echo

curl \
  --header "Authorization: Bearer $TOKEN" \
  --request POST \
  --form config=@payload.json \
  --form snapshot=@${filename} \
  --insecure \
  https://${standby_hostname}/_backup/api/v1/restore




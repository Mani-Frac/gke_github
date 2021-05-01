#### Step 1 Setting up environment variable
###### Copy the contents of .env.example and create a new file called .env
```
cp .env.example .env
```
Update the values for the variables and run
```
source .env
```
#### Step 2 Set default Project to gcloud cli
```
gcloud config set project $PROJECT_ID
```
#### Step 3 Enable Necessary Service APIs
```
gcloud services enable storage-api.googleapis.com
```

#### Step 4 Create a bucket to store the Infra state for Terraform

###### Create GCS Bucket
```
gsutil mb gs://${PROJECT_ID}-gh-actions-gke-tfstate
```
###### Enable Object versioning
```
gsutil versioning set on gs://${PROJECT_ID}-gh-actions-gke-tfstate
```
######
Update the Terraform State Bucket in environments/dev/03_terraform_state_bucket.tf
```
TERRAFORM_STATE_BUCKET=${PROJECT_ID}-gh-actions-gke-tfstate

cp environments/dev/03_terraform_state_bucket_example environments/dev/03_terraform_state_bucket.tf


sed -i -e 's/$TERRAFORM_STATE_BUCKET/'$TERRAFORM_STATE_BUCKET'/g' environments/dev/03_terraform_state_bucket.tf

```
#### Step 5 Service Account & Custom Role for github Actions
###### Create a Service account for github Actions
```
gcloud iam service-accounts create github-actions-ser-acc \
    --description="This service account will be used by github actions to manage GKE resources via terraform"  \
    --display-name="Github actions service account"
```
###### Add Service account to environment variable
```
GITHUB_ACTIONS_SA="github-actions-ser-acc@$PROJECT_ID.iam.gserviceaccount.com"
```
###### Grant iam.serviceAccountUser role to the service account 
``` 
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$GITHUB_ACTIONS_SA" \
    --role="roles/iam.serviceAccountUser"
```
###### Create Custom role
```
gcloud iam roles create custom_terraform_role \
    --project=$PROJECT_ID \
    --file=role-definitions.yaml
```
###### Attach custom role to the service account
```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$GITHUB_ACTIONS_SA" \
    --role="projects/$PROJECT_ID/roles/custom_terraform_role"
```
###### Create Json Credential for service account
```
gcloud iam service-accounts keys create credential.json \
    --iam-account $GITHUB_ACTIONS_SA
```

#### Step 6 Add the credential to github secrets
###### Open github repository in the brower, click on settings and create new secret called GOOGLE_CREDENTIALS with the service account credential



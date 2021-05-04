#### Step 0 Clone the Repo
###### This setup needs a linux environment with gcloud cli to execute the commands. You cannot follow the below steps in a windows computer.

```
git clone repo-url
cd cloned-folder
```
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
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
```
#### Step 4 Service Account & Custom Role for github Actions
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

#### Step 5 Create a bucket to store the Infra state for Terraform

###### Create GCS Bucket
```
gsutil mb gs://${PROJECT_ID}-gh-actions-gke-tfstate
```
###### Enable Object versioning
```
gsutil versioning set on gs://${PROJECT_ID}-gh-actions-gke-tfstate
```
###### Give Bucket access to newly created service account
```
gsutil iam ch serviceAccount:$GITHUB_ACTIONS_SA:objectAdmin gs://${PROJECT_ID}-gh-actions-gke-tfstate/
```
###### Update the Terraform State Bucket in environments/dev/03_terraform_state_bucket.tf
```
TERRAFORM_STATE_BUCKET=${PROJECT_ID}-gh-actions-gke-tfstate

cp environments/dev/03_terraform_state_bucket_example environments/dev/03_terraform_state_bucket.tf


sed -i -e 's/$TERRAFORM_STATE_BUCKET/'$TERRAFORM_STATE_BUCKET'/g' environments/dev/03_terraform_state_bucket.tf

```

#### Step 6 Add the credential to github secrets
###### Create github Repo and add this as the remote
```
git remote add github github-url
git checkout dev
git push github dev
```
###### open the github repo in the brower, click on settings and create new secret called GOOGLE_CREDENTIALS with the service account credential

###### Also set PROJECT_ID & REGION in github secrets

## Initial Application Deployment
### Tech Stack
1. Frontend -> React static files serverd using nginx  
2. Backend -> Python Flask  

#### Frontend related Dockerfile, nginx config file and React static files are inside frontend folder   

#### Similarly Python Flask Backend app files & Dockerfile is inside the backend folder  

Lets start
#### Step 7: Create Frontend & Backend Container Images and push it to Container Registry
```
gcloud builds submit --config workflows/initial_deployment/cloudbuild-frontend.yaml .
gcloud builds submit --config workflows/initial_deployment/cloudbuild-backend.yaml . 
```
#### Step 8: Authorize kubectl:
```
gcloud container clusters get-credentials [YOUR-CLUSTER-NAME] 
Ex:-
gcloud container clusters get-credentials $PROJECT_ID-gke --region $REGION
```
#### Step 9: Backend Flask-app Deployment
```
kubectl apply -f workflows/initial_deployment/deployment-backend.yaml

Example:-(Linux -> This will replace the $PROJECT_ID from envronment variable)
envsubst < workflows/initial_deployment/deployment-backend.yaml | kubectl apply -f -
```
#### Step 10:(Optional) Create External Load Balancer for Flask-app  
```
kubectl apply -f workflows/initial_deployment/service-flask-app-elb.yaml
```  
#### Step 11: Create Internal Load Balancer for Flask-app
```
kubectl apply -f workflows/initial_deployment/service-flask-app-ilb.yaml
```
#### Step 12: Frontend React-Nginx Deployment
```
kubectl apply -f workflows/initial_deployment/deployment-frontend.yaml

Example:-(Linux -> This will replace the $PROJECT_ID from envronment variable)
envsubst < workflows/initial_deployment/deployment-frontend.yaml | kubectl apply -f -
```
#### Step 13:(Optional) Create External Load Balancer for React-Nginx
```
kubectl apply -f workflows/initial_deployment/service-react-nginx-app-elb.yaml
```
#### Step 14: Create Internal Load Balancer for React-Nginx
```
kubectl apply -f workflows/initial_deployment/service-react-app-ilb.yaml
```

#### Step 15: Check all deployments
###### Check deployment status:
```
kubectl get deployments
```
###### List the pods:
```
kubectl get pods
```
###### To list the Nodes:
```
kubectl get nodes
```
###### To get all services
```
kubectl get services
```
## Application CI/CD Setup
#### Create Application CI/CD Trigger

## Appendix
#### Add or remove permissions to the custom role we created earlier
gcloud iam roles update custom_terraform_role --project=$PROJECT_ID \
  --file=role-definitions.yaml

#### Github Container Registery
###### Enable the container registry
1. Profile/FeaturePreview/Enable
###### Create Personal Access token for authenticating Container Registry
Github/Profile/settings/developersettings/personalAccessToken/
packages:write
packages:read
packages:delete
###### Add the GITHUB_TOKEN to the github secrets
###### Add the USERNAME to the github secrets
# Building and Publishing Logstash Container to Azure Container Registry

Azure Container Registry is used as an example here but you can use container registry of your choice.

## 0. Set Variables

Set your variables for consistent naming:

```sh
export RESOURCE_GROUP="your-resource-group"
export LOCATION="westeurope"
export ACR_NAME="${RESOURCE_GROUP}acr"  # ACR names must be globally unique
export IMAGE_NAME="aviatrix-logstash-sentinel"
export IMAGE_TAG="latest"
```

## 1. Create a Resource Group (if needed)

If you don't already have a resource group, create one with:

```sh
az group create --name $RESOURCE_GROUP --location $LOCATION
```

## 2. Create an Azure Container Registry

```sh
az acr create --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku Basic
```

## 3. Log in to the Container Registry

```sh
az acr login --name $ACR_NAME
```

## 4. Build the Docker Image

```sh
az acr build --registry $ACR_NAME \
    --image ${IMAGE_NAME}:${IMAGE_TAG} .
```

*Alternatively, using Docker CLI:*

```sh
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}
docker push ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}
```

## 5. Verify the Image in ACR

```sh
az acr repository list --name $ACR_NAME --output table
```

## 6. Update Terraform Configuration

Update your `terraform.tfvars` file with the correct container image reference:

```hcl
container_image = "${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}"
```

For example:

```hcl
container_image = "logstash-aci-acr.azurecr.io/aviatrix-logstash-sentinel:latest"
```
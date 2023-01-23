terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.72.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "ws-devops"
    storage_account_name = "cgmsgtf"
    container_name       = "tfstateazdevops"
    key                  = "20230123mlintl.tfstate"
  }
}

provider "azurerm" {
  features {}
}

#Get resource group
data "azurerm_resource_group" "wsdevops" {
  name = var.rg_name
}

#Add App Service Plan
resource "azurerm_app_service_plan" "sp1" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.wsdevops.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

#Add App Service
resource "azurerm_app_service" "website" {
  name                = var.web_app_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.wsdevops.name
  app_service_plan_id = azurerm_app_service_plan.sp1.id

  site_config {
    linux_fx_version = "NODE|10-lts"
    scm_type         = "LocalGit"
  }
}

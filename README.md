# schematics-vpc-roks ☁
*IBM® Cloud Schematics* 

La presente guía esta enfocada en crear un despliegue de un cluster de openshift sobre un ambiente de nube privada virtual (VPC) en una cuenta de IBM Cloud.

<br />

## Índice  📰
1. [Pre-Requisitos](#Pre-Requisitos-pencil)
2. [Crear y configurar un espacio de trabajo en IBM Cloud Schematics]
3. [Configurar las variables de personalización de la plantilla de terraform]
<br />

## Pre Requisitos :pencil:
* Contar con una cuenta en <a href="https://cloud.ibm.com/"> IBM Cloud</a>.
* Contar con un grupo de recursos específico para la implementación de los recursos.
* Tener una VPC.
* Tener dos o mas subnets con su respectivo segmento de red sobre la VPC.
* API 

> Nota: `instructivo para la creacion de VPC y subnets` <a href="https://github.com/emeloibmco/VPC-Despliegue-VSIs-Schematics/tree/main">IBM Cloud Schematics</a>

## Crear y configurar un espacio de trabajo en IBM Cloud Schematics 
Lo primero que debe hacer es dirigirse al servicio de <a href="https://cloud.ibm.com/schematics/workspaces">IBM Cloud Schematics</a> y dar click en ```CREAR ESPACIO DE TRABAJO```, una vez hecho esto aparecera una ventana en la que debera diligenciar la siguiente información.


| Variable | Descripción |
| ------------- | ------------- |
| URL del repositorio de Gi  | https://github.com/emeloibmco/schematics-vpc-roks.git |
| Tocken de acceso  | "(Opcional) Este parametro solo es necesario para trabajar con repositorio privados"  |
| Version de Terraform | terraform_v0.14 |


Presione ```SIGUIENTE```  > Agregue un nombre para el espacio de trabajo > Seleccione el grupo de recursos al que tiene acceso > Seleccione una ubicacion para el espacio de trabajo y como opcional puede dar una descripción. 

Una vez completos todos los campos puede presionar la opcion ``` CREAR```.

<p align="center">
<img width="800" alt="img8" src=https://github.com/emeloibmco/VPC-Despliegue-VSIs-Schematics-IMG/blob/2bef55b7c51b55bd02f8eec81779d5ddaa2cb5c4/workspacecreate.gif>
</p>

### Configurar las variables de personalización de la plantilla de terraform
Una vez  creado el espacio de trabajo, podra ver el campo VARIABLES que permite personalizar el espacio de trabajo allí debe ingresar la siguiente información:

Variable                        | Type                                                                                 | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Default
------------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |--------
ibmcloud_api_key                | string                                                                               | The IBM Cloud platform API key needed to deploy IAM enabled resources                                                                                                                                                                                                                                                                                                                                                                                                                 | 
ibm_region                      | string                                                                               | IBM Cloud region where all resources will be deployed                                                                                                                                                                                                                                                                                                                                                                                                                                 | 
resource_group                  | string                                                                               | Name of resource group where all infrastructure will be provisioned                                                                                                                                                                                                                                                                                                                                                                                                                   | `"asset-development"`
unique_id                       | string                                                                               | A unique identifier need to provision resources. Must begin with a letter                                                                                                                                                                                                                                                                                                                                                                                                             | `"asset-roks"`
vpc_name                        | string                                                                               | Name of VPC where cluster is to be created                                                                                                                                                                                                                                                                                                                                                                                                                                            | 
subnet_names                    | list(string)                                                                         | List of subnet names                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `[ "asset-multizone-zone-1-subnet-1", "asset-multizone-zone-1-subnet-2", "asset-multizone-zone-1-subnet-3" ]`
machine_type                    | string                                                                               | The flavor of VPC worker node to use for your cluster. Use `ibmcloud ks flavors` to find flavors for a region.                                                                                                                                                                                                                                                                                                                                                                        | `"bx2.4x16"`
workers_per_zone                | number                                                                               | Number of workers to provision in each subnet                                                                                                                                                                                                                                                                                                                                                                                                                                         | `2`
kube_version                    | string                                                                               | Specify the Kubernetes version, including the major.minor version. To see available versions, run `ibmcloud ks versions`.                                                                                                                                                                                                                                                                                                                                                             | `"4.5.35_openshift"`
wait_till                       | string                                                                               | To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady`   | `"IngressReady"`
tags                            | list(string)                                                                         | A list of tags to add to the cluster                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `[]`
worker_pools                    | list(object({ pool_name = string machine_type = string workers_per_zone = number })) | List of maps describing worker pools                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `[]`
service_endpoints               | string                                                                               | Service endpoints for resource instances. Can be `public`, `private`, or `public-and-private`.                                                                                                                                                                                                                                                                                                                                                                                        | `"private"`

<p align="center">
<img width="800" alt="img8" src=https://github.com/emeloibmco/VPC-Despliegue-VSIs-Schematics-IMG/blob/437726a50acbb2e169b94edf423e8fa094c3b815/Var.gif>
</p>

### Generar y Aplicar el plan de despliegue del Cluster
Ya que estan todos los campos de personalización completos, debe ir hasta la parte superior de la ventana donde encontrara dos opciones, Generar plan y Aplicar plan. Para continuar con el despliegue de los recursos debera presionar ```Generar Plan``` y una vez termine de generarse el plan ```Aplicar Plan```.

* ```Generar plan```: Según su configuración, Terraform crea un plan de ejecución y describe las acciones que deben ejecutarse para llegar al estado que se describe en sus archivos de configuración de Terraform. Para determinar las acciones, Schematics analiza los recursos que ya están aprovisionados en su cuenta de IBM Cloud para brindarle una vista previa de si los recursos deben agregarse, modificarse o eliminarse. Puede revisar el plan de ejecución, cambiarlo o simplemente ejecutar el plan
* ```Aplicar plan```: Cuando esté listo para realizar cambios en su entorno de nube, puede aplicar sus archivos de configuración de Terraform. Para ejecutar las acciones que se especifican en sus archivos de configuración, Schematics utiliza el complemento IBM Cloud Provider para Terraform.

<p align="center">
<img width="800" alt="img8" src=https://github.com/emeloibmco/VPC-Despliegue-VSIs-Schematics-IMG/blob/2bef55b7c51b55bd02f8eec81779d5ddaa2cb5c4/Despliegue.gif>
</p>

# Azure VM Image Creation with Packer

This project provides templates and scripts for creating Azure VM images with Packer using HashiCorp Configuration Language (HCL).

## Directory Structure

The project directory structure is organized as follows:

/
├── packer/
│   ├── windows/
│   │   ├── windows.pkr.hcl
│   │   └── scripts/
│   │       └── install-software.ps1
│   ├── linux/
│   │   ├── ubuntu.pkr.hcl
│   │   └── scripts/
│   │       └── install-software.sh
└── README.md
The `windows` and `linux` directories contain specific configurations and scripts for building Windows Server 2019 and Ubuntu 20.04 images respectively.

## Prerequisites

- Packer v1.5.0 or later
- Azure subscription

## Usage

Set your Azure credentials as environment variables:
bash
export PKR_VAR_client_id="your_client_id"
export PKR_VAR_client_secret="your_client_secret"
export PKR_VAR_tenant_id="your_tenant_id"
export PKR_VAR_subscription_id="your_subscription_id"
Navigate to the directory containing the `.pkr.hcl` file for the image you wish to build (either `windows` or `linux`), then run:
bash
packer build .
## Secret Management

Secrets such as API keys and passwords are managed using environment variables. They are not hardcoded into the Packer templates. 

For additional layers of security, consider using Azure Key Vault or HashiCorp Vault for storing and managing your secrets.

## License

This project is licensed under the MIT License. See the [LICENSE.md](./LICENSE.md) file for details.
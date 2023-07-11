variable "subscription_id" {
  type    = string
}

variable "client_id" {
  type    = string
}

variable "client_secret" {
  type    = string
}

variable "tenant_id" {
  type    = string
}

variable "image_version" {
  type    = string
}

source "azure-arm" "windows" {
  # Service Principal Authentication
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id

  # Source Image
  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2022-datacenter-core-g2"

  # WinRM Communicator
  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "5m"
  winrm_username = "packer"

  # Destination Image
  shared_image_gallery_destination {
    resource_group  = "packer-acg-rg"
    gallery_name    = "packer_acg"
    image_name      = "windows-server-2022"
    image_version   = var.image_version
  }

  managed_image_name                = "windows-server-2022"
  managed_image_resource_group_name = "packer-acg-rg"

  # Packer Computing Resources
  location        = "UK South"
  vm_size         = "Standard_B2s"
}

build {
  sources = [
    "source.azure-arm.windows"
  ]

  # Install Chocolatey: https://chocolatey.org/install#individual
  provisioner "powershell" {
    inline = ["Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"]
  }

  # Install Chocolatey packages
  provisioner "file" {
    source      = "./windows/packages.config"
    destination = "D:/packages.config"
  }

  provisioner "powershell" {
    inline = ["choco install --confirm D:/packages.config"]
    # See https://docs.chocolatey.org/en-us/choco/commands/install#exit-codes
    valid_exit_codes = [0, 3010]
  }

  # Restart Windows
  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output 'successfully restarted.'}\""
  }

  # Generalize Image
  provisioner "powershell" {
    inline = [
      "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm",
      "while ($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }
}
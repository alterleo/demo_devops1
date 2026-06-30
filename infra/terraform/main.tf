terraform {
  required_providers {
    cloudru = {
      source  = "cloud.ru/cloudru/cloud"
      version = "2.0.0"
    }
  }
}

# =============================================================================
# Переменные — заполните своими значениями
# =============================================================================

variable "project_id" {
  type        = string
  description = "(экспорт) Идентификатор проекта из console.cloud.ru"
}

variable "auth_key_id" {
  type        = string
  description = "(экспорт) Идентификатор ключа доступа сервисного аккаунта"
  sensitive   = true
}

variable "auth_secret" {
  type        = string
  description = "(экспорт) Секрет ключа доступа сервисного аккаунта"
  sensitive   = true
}

variable "vpc_id" {
  type        = string
  description = "(экспорт) Идентификатор VPC"
}

variable "user_passwd" {
  type        = string
  description = "(экспорт) Секрет хеша пароля пользователя ubuntu ВМ"
}

variable "vm_name" {
  type        = string
  description = "Имя виртуальной машины"
  default     = "tf-evo-vm"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Путь к публичному SSH ключу"
  default     = "~/.ssh/id_rsa.pub"
}

variable "zone" {
  type        = string
  description = "Зона доступности"
  default     = "ru.AZ-2"
}

variable "subnet_address" {
  type        = string
  description = "CIDR подсети"
  default     = "10.0.0.0/24" # <-- ИЗМЕНИТЕ ПРИ НЕОБХОДИМОСТИ
}

variable "flavor" {
  type        = string
  description = "Flavor ВМ"
  default     = "gen-1-1"
}

variable "disk_size" {
  type        = number
  description = "Размер диска в ГБ"
  default     = 20
}

variable "disk_type" {
  type        = string
  description = "Тип диска"
  default     = "SSD"
}


# =============================================================================
# Провайдер
# =============================================================================

provider "cloudru" {
  project_id  = var.project_id
  auth_key_id = var.auth_key_id
  auth_secret = var.auth_secret

  endpoints = {
    iam_endpoint     = "iam.api.cloud.ru:443"
    compute_endpoint = "compute.api.cloud.ru:443"
  }
}

# =============================================================================
# Источники данных
# =============================================================================

data "cloudru_evolution_compute_image_collection" "ubuntu" {
  project_id = var.project_id
  page_size  = 100
}

# =============================================================================
# Конфигурация cloud-init
# =============================================================================

locals {
  cloud_config = templatefile("${path.module}/cloud-init.yaml.tpl", {
    ssh_public_key = file(var.ssh_public_key_path)
    vm_name        = var.vm_name
    user_passwd = var.user_passwd
  })
}

# =============================================================================
# Подсеть
# =============================================================================

resource "cloudru_evolution_compute_subnet" "example" {
  project_id = var.project_id

  name = "tf-evo-subnet"

  zone_identifier = {
    name = var.zone
  }

  description    = "Подсеть для ВМ"
  subnet_address = var.subnet_address
  routed_network = true
  default        = true
  vpc_id         = var.vpc_id

  dns_servers = {
    value = ["8.8.4.4", "8.8.8.8"]
  }
}

# =============================================================================
# Диск
# =============================================================================

resource "cloudru_evolution_compute_disk" "example" {
  project_id = var.project_id

  name = "tf-evo-disk"
  size = var.disk_size

  zone_identifier = {
    name = var.zone
  }

  disk_type_identifier = {
    name = var.disk_type
  }

  description = "Загрузочный диск для ВМ"
  bootable    = true
  image_id    = [for img in data.cloudru_evolution_compute_image_collection.ubuntu.images : img.id if img.name == "ubuntu-22.04"][0]
  encrypted   = false
  readonly    = false
  shared      = false
}

# =============================================================================
# Сетевой интерфейс
# =============================================================================

resource "cloudru_evolution_compute_interface" "example" {
  project_id = var.project_id

  name = "tf-evo-interface"

  zone_identifier = {
    name = var.zone
  }

  description                = "Сетевой интерфейс для ВМ"
  subnet_id                  = cloudru_evolution_compute_subnet.example.id
  interface_security_enabled = true

  external_ip_specs = {
    new_external_ip = true
  }

  type = "INTERFACE_TYPE_REGULAR"
}

# =============================================================================
# Виртуальная машина
# =============================================================================

resource "cloudru_evolution_compute_vm" "example" {
  project_id = var.project_id

  name = var.vm_name

  zone_identifier = {
    name = var.zone
  }

  flavor_identifier = {
    name = var.flavor
  }

  description = "ВМ, созданная через Terraform"

  disk_identifiers = [{
    disk_id = cloudru_evolution_compute_disk.example.id
  }]

  network_interfaces = [{
    interface_id = cloudru_evolution_compute_interface.example.id
  }]

  cloud_init_userdata = base64encode(local.cloud_config)

}

# =============================================================================
# Вывод значений
# =============================================================================

output "vm_id" {
  description = "ID виртуальной машины"
  value       = cloudru_evolution_compute_vm.example.id
}

output "vm_name" {
  description = "Имя виртуальной машины"
  value       = cloudru_evolution_compute_vm.example.name
}

output "vm_internal_ip" {
  description = "Внутренний IP адрес"
  value       = cloudru_evolution_compute_interface.example.ip_address
}

output "external_ip" {
  description = "Внешний IP адрес"
  value       = cloudru_evolution_compute_interface.example.external_ip.ip_address
}
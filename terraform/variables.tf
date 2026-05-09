variable "public_key_path" {
  description = "Ruta a la clave publica SSH que se subira a OpenStack."
  type        = string
}

variable "auth_url" {
  description = "URL de autenticacion de OpenStack. Opcional si se usan variables OS_* o clouds.yaml."
  type        = string
  default     = null
}

variable "application_credential_id" {
  description = "Application credential ID de OpenStack. Opcional si se usan variables OS_* o clouds.yaml."
  type        = string
  default     = null
  sensitive   = true
}

variable "application_credential_secret" {
  description = "Application credential secret de OpenStack. Opcional si se usan variables OS_* o clouds.yaml."
  type        = string
  default     = null
  sensitive   = true
}

variable "domain_name" {
  description = "Dominio de OpenStack."
  type        = string
  default     = null
}

variable "tenant_name" {
  description = "Proyecto o tenant de OpenStack."
  type        = string
  default     = null
}

variable "region" {
  description = "Region de OpenStack."
  type        = string
  default     = null
}

variable "private_key_path" {
  description = "Ruta a la clave privada SSH usada por Ansible."
  type        = string
}

variable "keypair_name" {
  description = "Nombre del keypair a registrar en OpenStack."
  type        = string
}

variable "deployment_name" {
  description = "Prefijo opcional para nombrar recursos compartidos del despliegue."
  type        = string
  default     = null
}

variable "image_name" {
  description = "Nombre de la imagen base de OpenStack."
  type        = string
  default     = "Ubuntu-24.04"
}

variable "network_name" {
  description = "Nombre de la red interna donde conectar las VMs."
  type        = string
}

variable "external_network_name" {
  description = "Pool/red externa desde la que reservar floating IPs."
  type        = string
  default     = null
}

variable "create_floating_ips" {
  description = "Si es true, Terraform reserva una floating IP nueva por VM. Si es false, solo reutiliza las IPs indicadas en instances[*].floating_ip."
  type        = bool
  default     = false
}

variable "ssh_allowed_cidr" {
  description = "CIDR autorizado a acceder por SSH."
  type        = string
  default     = "0.0.0.0/0"
}

variable "timezone" {
  description = "Zona horaria de las VMs."
  type        = string
  default     = "Europe/Madrid"
}

variable "admin_user" {
  description = "Usuario administrador inicial creado por cloud-init."
  type        = string
  default     = "admin"
}

variable "common_security_group_names" {
  description = "Grupos de seguridad adicionales a adjuntar a todas las VMs."
  type        = list(string)
  default     = ["default"]
}

variable "instances" {
  description = "Mapa de instancias a crear. La clave del mapa se usa como nombre de la VM."
  type = map(object({
    subject               = string
    flavor_name           = string
    floating_ip           = optional(string)
    student_user          = optional(string, "alumno")
    student_public_keys   = optional(list(string), [])
    extra_security_groups = optional(list(string), [])
    metadata              = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for instance in var.instances :
      contains(["data_science", "frontend", "databases", "backend", "fullstack"], instance.subject)
    ])
    error_message = "Cada instancia debe usar un subject valido: data_science, frontend, databases, backend o fullstack."
  }
}

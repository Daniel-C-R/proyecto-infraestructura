# Terraform + Ansible sobre OpenStack

Este repositorio separa la provision de infraestructura y la configuracion de software:

- `terraform/` crea las maquinas virtuales, red, keypair, grupos de seguridad y, opcionalmente, floating IPs.
- `ansible/` usa inventario dinamico de OpenStack para descubrir las instancias y aplicar los roles segun la asignatura.

## Requisitos

- Terraform >= 1.6
- Ansible
- Colecciones de Ansible declaradas en `ansible/requirements.yml`
- Credenciales de OpenStack cargadas en variables de entorno o en `clouds.yaml`
- Un par de claves SSH ya existente para la administracion

## Credenciales de OpenStack

No guardes secretos en Terraform ni en Ansible. Exporta las credenciales antes de ejecutar:

```bash
export OS_AUTH_URL="https://openstack.example/v3"
export OS_APPLICATION_CREDENTIAL_ID="..."
export OS_APPLICATION_CREDENTIAL_SECRET="..."
export OS_REGION_NAME="RegionOne"
export OS_INTERFACE="public"
export OS_IDENTITY_API_VERSION=3
```

Alternativamente, usa `clouds.yaml` si ya lo tienes estandarizado en la facultad.

Si prefieres trabajar con un `.tfvars` local fuera de Git, tambien puedes rellenar:

- `auth_url`
- `application_credential_id`
- `application_credential_secret`
- `domain_name`
- `tenant_name`
- `region`

## Inventario dinamico

El inventario de Ansible esta en `ansible/inventory/openstack.yml` y usa el plugin `openstack.cloud.openstack`.
Las VMs se agrupan automaticamente segun el metadato `subject` que Terraform escribe en OpenStack.

- `data_science`
- `frontend`
- `databases`

## Flujo de trabajo

1. Copia un fichero de ejemplo de `terraform/environments/*.tfvars.example` a un `.tfvars` real.
2. Ajusta red, imagen, flavor, rutas SSH y mapa `instances`.
3. Inicializa herramientas:

```bash
make init
```

4. Revisa el plan:

```bash
make plan TFVARS=environments/data_science_lab.tfvars
```

5. Crea las VMs:

```bash
make apply TFVARS=environments/data_science_lab.tfvars
```

6. Comprueba el inventario dinamico:

```bash
make inventory
```

7. Lanza la configuracion:

```bash
make configure PLAYBOOK=playbooks/data_science.yml
```

Tambien puedes configurar todas las asignaturas declaradas:

```bash
make configure PLAYBOOK=site.yml
```

## Estructura de asignacion de perfiles

Cada VM se define en `instances` y debe indicar al menos:

- `subject`: `data_science`, `frontend` o `databases`
- `flavor_name`

Terraform copia ese `subject` como metadato de OpenStack y Ansible lo usa para decidir en que grupo cae cada instancia.

## Red interna y floating IPs

El modo por defecto no crea floating IPs nuevas:

- `create_floating_ips = false`
- Las VMs quedan accesibles por su IP privada dentro de la red del proyecto
- Ansible intentara usar `public_v4` y, si no existe, caera a `private_v4`

Si ya tienes una floating IP publica reservada y quieres reutilizarla sin crear mas, puedes asignarla en la instancia:

```hcl
instances = {
  ds-01 = {
    subject     = "data_science"
    flavor_name = "m2_medium_2"
    floating_ip = "156.35.98.70"
  }
}
```

Si el administrador dispone de permisos para reservar nuevas IPs publicas, puede activar:

```hcl
create_floating_ips   = true
external_network_name = "public"
```

## Notas operativas

- El acceso SSH se hace con clave publica, no con contrasena.
- La clave privada no se genera con Terraform ni se guarda en el estado.
- `cloud-init` solo prepara conectividad, usuario admin, Python y `qemu-guest-agent`.
- Los secretos de MariaDB u otros servicios deberian pasar a `ansible-vault` si se necesitan en entornos reales.

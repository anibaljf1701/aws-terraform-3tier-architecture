# Arquitectura AWS de tres capas con Terraform

Este proyecto despliega en AWS una arquitectura de tres capas mediante Terraform. Incluye una red VPC, un balanceador de carga, un grupo de instancias EC2 con escalado automático y una base de datos MySQL administrada en Amazon RDS.

## Arquitectura desplegada

La configuración predeterminada utiliza la región `us-west-2` y dos zonas de disponibilidad (`us-west-2a` y `us-west-2b`):

- **Red:** VPC `10.0.0.0/16`, dos subredes públicas, dos subredes privadas para la aplicación y dos subredes privadas para la base de datos.
- **Entrada y salida:** un Internet Gateway, un Application Load Balancer (ALB) en las subredes públicas y un NAT Gateway para el tráfico saliente de las subredes privadas.
- **Aplicación:** un Auto Scaling Group en las subredes privadas, con capacidad deseada de dos instancias EC2 y límites de una a tres. Las instancias ejecutan Apache HTTP.
- **Datos:** una instancia Amazon RDS MySQL 8.0, no accesible públicamente. La configuración actual no habilita despliegue Multi-AZ.

El tráfico web sigue el recorrido `Internet → ALB → EC2 → RDS`. Las instancias EC2 utilizan el NAT Gateway para las conexiones salientes.

## Estructura del proyecto

```
aws-terraform-3tier-architecture/
├── main.tf                 # Configuración principal de módulos
├── variables.tf            # Variables de entrada
├── outputs.tf              # Salidas del proyecto
├── providers.tf            # Configuración de proveedores
├── backend.tf              # Configuración de backend (estado Terraform)
├── README.md               # Documentación del proyecto
├── docs/                   # Ejemplos y documentación adicional
└── modules/                # Módulos de infraestructura
    ├── vpc/                # Módulo de VPC y red
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2_cluster/        # Módulo de clúster EC2
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── rds_database/       # Módulo de base de datos RDS
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Requisitos

1. Una cuenta de AWS y credenciales disponibles para el proveedor de AWS (por perfil, variables de entorno o un rol).
2. Terraform `>= 1.5.0`.

## Variables de entrada

| Variable | Descripción | Tipo | Valor por Defecto |
|----------|-------------|------|-------------------|
| `aws_region` | Región de AWS | `string` | `us-west-2` |
| `private_app_subnet_cidr` | Rangos CIDR de las subredes privadas de aplicación | `list(string)` | `["10.0.11.0/24", "10.0.12.0/24"]` |
| `db_password` | Contraseña de la base de datos | `string` | Requerida, sensible |
| `db_name` | Nombre de la base de datos | `string` | `portfoliodb` |
| `db_username` | Usuario administrador de la base de datos | `string` | `admin` |

## Módulos

### 1. Módulo VPC (`modules/vpc`)
Crea la VPC, subredes públicas y privadas en dos zonas, gateways, tablas de rutas y el grupo de subredes de RDS.

### 2. Módulo EC2 Cluster (`modules/ec2_cluster`)
Implementa el ALB, sus reglas de acceso, un Auto Scaling Group con Launch Template y las instancias EC2 con Amazon Linux 2023 y Apache HTTP.

### 3. Módulo RDS Database (`modules/rds_database`)
Implementa una instancia RDS MySQL 8.0 no pública y un grupo de seguridad que permite conexiones desde los rangos CIDR de las subredes de aplicación.

## Uso

Antes de planificar o aplicar, define `TF_VAR_db_password` en el entorno. Evita incluir el valor literal en la línea de comandos.

### 1. Inicializar Terraform
```bash
terraform init
```

### 2. Planificar la Infraestructura
```bash
terraform plan
```

### 3. Aplicar la Infraestructura
```bash
terraform apply
```

### 4. Verificar Outputs
Después de aplicar, Terraform mostrará la URL del ALB:
```bash
application_url = http://app-portfolio-alb-123456789.us-west-2.elb.amazonaws.com
```

### 5. Destruir la Infraestructura
```bash
terraform destroy
```

## Acceso y conectividad

El ALB acepta tráfico HTTP por el puerto 80. Las instancias EC2 reciben tráfico HTTP desde el grupo de seguridad del ALB y la base de datos acepta conexiones MySQL desde los rangos de las subredes de aplicación. La contraseña de la base de datos se declara como variable sensible de Terraform.

## Costos

El coste depende de la región, el tiempo de ejecución, el tráfico y los precios vigentes de AWS. El NAT Gateway, el ALB, las instancias EC2 y RDS generan cargos; consulta AWS Pricing Calculator antes de desplegar.

## Personalización

Para cambiar la región, define `aws_region` en un archivo de variables local o mediante `TF_VAR_aws_region`.

Para ajustar los tipos de instancia EC2 o RDS, modifica `instance_type` en `modules/ec2_cluster/main.tf` o `instance_class` en `modules/rds_database/main.tf`.

Si agregas subredes de aplicación, actualiza también las zonas de disponibilidad en `modules/vpc/variables.tf` para que ambas listas tengan la misma longitud.

```hcl
variable "private_app_subnet_cidr" {
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}
```

## Solución de problemas

### Credenciales de AWS no configuradas
```bash
aws sts get-caller-identity
```

## Nota

Este repositorio es una demostración técnica. Antes de utilizarlo en un entorno real, revisa los requisitos de disponibilidad, cifrado, copias de seguridad, monitoreo y acceso de la aplicación. La configuración actual sirve HTTP, usa un único NAT Gateway y no habilita RDS Multi-AZ; los costes reales dependen del uso y de los precios vigentes de AWS.
# AWS Terraform 3-Tier Architecture

Este proyecto implementa una arquitectura de 3 niveles (3-tier) en AWS utilizando Terraform. La arquitectura está diseñada para ser altamente disponible, escalable y segura, siguiendo las mejores prácticas de AWS.

## 📋 Descripción de la Arquitectura

La arquitectura de 3 niveles incluye:

### 1. **Capa Web/Presentación (Web Tier)**
   - **Application Load Balancer (ALB)** - Distribuye el tráfico web entrante
   - **Subredes Públicas** - Ubicadas en múltiples zonas de disponibilidad
   - **Internet Gateway** - Conectividad a internet para la capa web

### 2. **Capa de Aplicación (Application Tier)**
   - **Auto Scaling Group (ASG)** - Escala automáticamente instancias EC2 basado en demanda
   - **Instancias EC2** - Ejecutan la aplicación web (servidor Apache HTTP)
   - **Subredes Privadas de Aplicación** - Aisladas del internet público
   - **NAT Gateway** - Permite tráfico saliente desde instancias EC2
   - **Security Groups** - Control de tráfico entre capas

### 3. **Capa de Datos (Data Tier)**
   - **RDS MySQL** - Base de datos gestionada con alta disponibilidad
   - **Subredes Privadas de Base de Datos** - Máximo aislamiento y seguridad
   - **DB Subnet Group** - Grupos de subredes para RDS
   - **Security Groups** - Control estricto de acceso a la base de datos

## 🏗️ Diagrama de la Arquestructura

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              VPC (10.0.0.0/16)                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐ │
│  │   Public Subnet │      │   Public Subnet │      │   Public Subnet │ │
│  │  (10.0.1.0/24)  │      │  (10.0.2.0/24)  │      │  (10.0.3.0/24)  │ │
│  │   AZ: us-west-2a│      │   AZ: us-west-2b│      │   AZ: us-west-2c│ │
│  │                 │      │                 │      │                 │ │
│  │ ┌─────────────┐ │      │ ┌─────────────┐ │      │ ┌─────────────┐ │ │
│  │ │ Internet    │ │      │ │    NAT      │ │      │ │  Bastion    │ │ │
│  │ │  Gateway    │◄├──────┼─┤   Gateway   │ │      │ │    Host     │ │ │
│  │ └─────────────┘ │      │ └─────────────┘ │      │ └─────────────┘ │ │
│  │        │        │      │        │        │      │        │        │ │
│  │ ┌─────────────┐ │      │ ┌─────────────┐ │      │ ┌─────────────┐ │ │
│  │ │ Application │ │      │ │ Application │ │      │ │ Application │ │ │
│  │ │ Load Balancer│ │      │ │ Load Balancer│ │      │ │ Load Balancer│ │ │
│  │ │   (ALB)     │ │      │ │   (ALB)     │ │      │ │   (ALB)     │ │ │
│  │ └─────────────┘ │      │ └─────────────┘ │      │ └─────────────┘ │ │
│  └─────────┬───────┘      └─────────┬───────┘      └─────────┬───────┘ │
│            │                        │                        │          │
└────────────┼────────────────────────┼────────────────────────┼──────────┘
             │                        │                        │
┌────────────┼────────────────────────┼────────────────────────┼──────────┐
│            ▼                        ▼                        ▼          │
│  ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐ │
│  │ Private App     │      │ Private App     │      │ Private App     │ │
│  │   Subnet        │      │   Subnet        │      │   Subnet        │ │
│  │ (10.0.11.0/24)  │      │ (10.0.12.0/24)  │      │ (10.0.13.0/24)  │ │
│  │  AZ: us-west-2a │      │  AZ: us-west-2b │      │  AZ: us-west-2c │ │
│  │                 │      │                 │      │                 │ │
│  │ ┌─────────────┐ │      │ ┌─────────────┐ │      │ ┌─────────────┐ │ │
│  │ │ EC2 Instance│ │      │ │ EC2 Instance│ │      │ │ EC2 Instance│ │ │
│  │ │   (t2.micro)│ │      │ │   (t2.micro)│ │      │ │   (t2.micro)│ │ │
│  │ │  Auto Scaling│◄┼──────┼─┤  Auto Scaling│◄┼──────┼─┤  Auto Scaling│ │
│  │ │    Group     │ │      │ │    Group     │ │      │ │    Group     │ │
│  │ └─────────────┘ │      │ └─────────────┘ │      │ └─────────────┘ │ │
│  └─────────┬───────┘      └─────────┬───────┘      └─────────┬───────┘ │
│            │                        │                        │          │
└────────────┼────────────────────────┼────────────────────────┼──────────┘
             │                        │                        │
┌────────────┼────────────────────────┼────────────────────────┼──────────┐
│            ▼                        ▼                        ▼          │
│  ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐ │
│  │ Private DB      │      │ Private DB      │      │ Private DB      │ │
│  │   Subnet        │      │   Subnet        │      │   Subnet        │ │
│  │ (10.0.21.0/24)  │      │ (10.0.22.0/24)  │      │ (10.0.23.0/24)  │ │
│  │  AZ: us-west-2a │      │  AZ: us-west-2b │      │  AZ: us-west-2c │ │
│  │                 │      │                 │      │                 │ │
│  │ ┌─────────────┐ │      │ ┌─────────────┐ │      │ ┌─────────────┐ │ │
│  │ │ RDS MySQL   │ │      │ │ RDS MySQL   │ │      │ │ RDS MySQL   │ │ │
│  │ │   (db.t3.   │ │      │ │   (db.t3.   │ │      │ │   (db.t3.   │ │ │
│  │ │   micro)    │◄┼──────┼─┤   micro)    │◄┼──────┼─┤   micro)    │ │ │
│  │ │ Multi-AZ    │ │      │ │ Multi-AZ    │ │      │ │ Multi-AZ    │ │ │
│  │ └─────────────┘ │      │ └─────────────┘ │      │ └─────────────┘ │ │
│  └─────────────────┘      └─────────────────┘      └─────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘

Flujo de Tráfico:
Internet → ALB → EC2 Instances → RDS Database
```

## 🗂️ Estructura del Proyecto

```
aws-terraform-3tier-architecture/
├── main.tf                 # Configuración principal de módulos
├── variables.tf            # Variables de entrada
├── outputs.tf              # Salidas del proyecto
├── providers.tf            # Configuración de proveedores
├── backend.tf              # Configuración de backend (estado Terraform)
├── README.md               # Este archivo
└── modules/                # Módulos reutilizables
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

## 🚀 Requisitos Previos

1. **AWS Account** con credenciales configuradas
2. **Terraform** >= 1.5.0 instalado
3. **AWS CLI** configurado con permisos adecuados
4. **Credenciales AWS** configuradas como variables de entorno o en `~/.aws/credentials`

## ⚙️ Variables de Entrada

| Variable | Descripción | Tipo | Valor por Defecto |
|----------|-------------|------|-------------------|
| `aws_region` | Región AWS para desplegar recursos | `string` | `us-west-2` |
| `private_app_subnet_cidr` | CIDR para subredes privadas de aplicación | `list(string)` | `["10.0.11.0/24", "10.0.12.0/24"]` |
| `db_password` | Contraseña para la base de datos RDS | `string` | (requerido, sensible) |
| `db_name` | Nombre de la base de datos | `string` | `portfoliodb` |
| `db_username` | Usuario administrador de la base de datos | `string` | `admin` |

## 📦 Módulos

### 1. Módulo VPC (`modules/vpc`)
Crea la red completa con:
- VPC con CIDR `10.0.0.0/16`
- Subredes públicas en múltiples AZs
- Subredes privadas para aplicación y base de datos
- Internet Gateway y NAT Gateway
- Tablas de rutas y asociaciones
- DB Subnet Group para RDS

### 2. Módulo EC2 Cluster (`modules/ec2_cluster`)
Implementa la capa de aplicación:
- Application Load Balancer (ALB)
- Auto Scaling Group con Launch Template
- Security Groups para ALB y EC2
- Instancias EC2 con Amazon Linux 2023
- Servidor web Apache HTTP

### 3. Módulo RDS Database (`modules/rds_database`)
Implementa la capa de datos:
- Instancia RDS MySQL 8.0
- Security Group para acceso controlado
- Configuración de alta disponibilidad
- Almacenamiento encriptado

## 🚀 Uso

### 1. Inicializar Terraform
```bash
terraform init
```

### 2. Planificar la Infraestructura
```bash
terraform plan -var="db_password=TuPasswordSeguro123!"
```

### 3. Aplicar la Infraestructura
```bash
terraform apply -var="db_password=TuPasswordSeguro123!"
```

### 4. Verificar Outputs
Después de aplicar, Terraform mostrará:
```bash
application_url = http://app-portfolio-alb-123456789.us-west-2.elb.amazonaws.com
```

### 5. Destruir la Infraestructura
```bash
terraform destroy -var="db_password=TuPasswordSeguro123!"
```

## 🔐 Consideraciones de Seguridad

1. **Credenciales de Base de Datos**: La contraseña de RDS se marca como `sensitive` en Terraform
2. **Acceso Público**: Solo el ALB tiene acceso público (puerto 80)
3. **Subredes Privadas**: Las instancias EC2 y RDS están en subredes privadas
4. **Security Groups**: Reglas de firewall específicas por capa
5. **NAT Gateway**: Acceso saliente controlado para instancias EC2

## 💰 Estimación de Costos (AWS us-west-2)

| Recurso | Tipo | Costo Mensual Aproximado |
|---------|------|--------------------------|
| VPC | Estándar | $0.00 |
| ALB | Application Load Balancer | ~$16.00 |
| EC2 | t2.micro (2 instancias) | ~$16.80 |
| RDS | db.t3.micro MySQL | ~$15.00 |
| NAT Gateway | Por hora + tráfico | ~$32.00 + tráfico |
| **Total** | | **~$79.80/mes** |

*Nota: Los costos pueden variar según el uso real*

## 🛠️ Mejores Prácticas Implementadas

1. **Modularidad**: Código organizado en módulos reutilizables
2. **Alta Disponibilidad**: Recursos distribuidos en múltiples AZs
3. **Seguridad por Capas**: Security Groups específicos por función
4. **Escalabilidad**: Auto Scaling Group para la capa de aplicación
5. **Infraestructura como Código**: Reproducible y versionada
6. **Separación de Responsabilidades**: Capas web, aplicación y datos separadas
7. **Backup y Recuperación**: Configuración para backups automáticos de RDS

## 🔧 Personalización

### Cambiar Región AWS
```hcl
variable "aws_region" {
  default = "us-east-1"
}
```

### Ajustar Tamaño de Instancias
Modificar en los módulos correspondientes:
- `modules/ec2_cluster/main.tf`: `instance_type`
- `modules/rds_database/main.tf`: `instance_class`

### Agregar Más Subredes
```hcl
variable "private_app_subnet_cidr" {
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}
```

## 🐛 Solución de Problemas

### Error: Credenciales AWS no configuradas
```bash
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
export AWS_REGION="us-west-2"
```

### Error: Bucket S3 no existe (para backend remoto)
Modificar `backend.tf` para usar backend local temporalmente.

### Error: Límites de servicio AWS
Verificar límites de servicio en la consola AWS:
- VPCs por región
- Instancias EC2
- Instancias RDS

## 📄 Licencia

Este proyecto está disponible bajo la licencia MIT.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el repositorio
2. Crear una rama para tu característica
3. Commit tus cambios
4. Push a la rama
5. Abrir un Pull Request

## 📞 Soporte

Para problemas o preguntas:
1. Revisar la documentación
2. Verificar logs de Terraform
3. Consultar la consola AWS
4. Abrir un issue en el repositorio

---
**Nota**: Este es un proyecto de demostración. Para entornos de producción, considere:
- Implementar WAF para el ALB
- Configurar CloudFront para CDN
- Habilitar encriptación en tránsito y en reposo
- Implementar monitoreo con CloudWatch
- Configurar alertas y notificaciones
- Establecer políticas de backup y retención


## 🎨 Diagrama Interactivo (Mermaid)

```mermaid
graph TB
    subgraph "Internet"
        Internet[Internet Users]
    end
    
    subgraph "VPC: 10.0.0.0/16"
        subgraph "Capa Web - Subredes Públicas"
            ALB[Application Load Balancer]
            IGW[Internet Gateway]
            NAT[NAT Gateway]
        end
        
        subgraph "Capa Aplicación - Subredes Privadas App"
            ASG[Auto Scaling Group]
            EC2_1[EC2 Instance AZ-a]
            EC2_2[EC2 Instance AZ-b]
        end
        
        subgraph "Capa Datos - Subredes Privadas DB"
            RDS_1[RDS Primary AZ-a]
            RDS_2[RDS Standby AZ-b]
        end
    end
    
    Internet --> IGW
    IGW --> ALB
    ALB --> ASG
    ASG --> EC2_1
    ASG --> EC2_2
    EC2_1 --> NAT
    EC2_2 --> NAT
    NAT --> IGW
    EC2_1 --> RDS_1
    EC2_2 --> RDS_2
    
    style ALB fill:#e1f5fe
    style EC2_1 fill:#f3e5f5
    style EC2_2 fill:#f3e5f5
    style RDS_1 fill:#e8f5e8
    style RDS_2 fill:#e8f5e8
    style IGW fill:#fff3e0
    style NAT fill:#fff3e0
```

### Flujo de Datos

1. **Usuario** → **Internet** → **Internet Gateway** → **ALB**
2. **ALB** → **Auto Scaling Group** → **Instancia EC2**
3. **Instancia EC2** → **NAT Gateway** → **Internet** (para actualizaciones)
4. **Instancia EC2** → **RDS Database** (acceso directo)
5. **RDS Primary** → **RDS Standby** (réplica sincronizada)

## 📊 Recursos Creados por Terraform

| Capa | Recurso | Cantidad | Propósito |
|------|---------|----------|-----------|
| **Red** | VPC | 1 | Red virtual aislada |
| | Subred Pública | 2 | Capa web accesible |
| | Subred Privada App | 2 | Capa de aplicación |
| | Subred Privada DB | 2 | Capa de datos |
| | Internet Gateway | 1 | Conexión a internet |
| | NAT Gateway | 1 | Salida internet para EC2 |
| | Tablas de Ruta | 2 | Enrutamiento VPC |
| **Web** | Application Load Balancer | 1 | Distribución de tráfico |
| | Security Group ALB | 1 | Firewall ALB |
| **App** | Auto Scaling Group | 1 | Escalado automático |
| | Launch Template | 1 | Configuración EC2 |
| | Security Group EC2 | 1 | Firewall EC2 |
| | EC2 Instances | 2-3 | Servidores aplicación |
| **Datos** | RDS MySQL | 1 | Base de datos |
| | Security Group RDS | 1 | Firewall base de datos |
| | DB Subnet Group | 1 | Subredes para RDS |
| **Total** | **Recursos** | **~28** | Infraestructura completa |

---

**✨ Características Clave Implementadas:**
- ✅ Arquitectura de 3 niveles completa
- ✅ Alta disponibilidad en múltiples AZs
- ✅ Seguridad por capas con Security Groups
- ✅ Escalabilidad automática con Auto Scaling
- ✅ Base de datos gestionada con RDS
- ✅ Documentación completa
- ✅ Código modular y reutilizable
- ✅ Mejores prácticas de AWS y Terraform

**🚀 Listo para producción con configuraciones adicionales de seguridad y monitoreo.**
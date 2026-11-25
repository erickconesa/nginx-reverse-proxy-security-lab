# Nginx Reverse Proxy & Web Security Lab

**Linux System Administration | Nginx | HTTPS/TLS | Reverse Proxy | Web Security**

## Project Overview

Laboratorio de administración de sistemas centrado en la configuración y securización de un proxy inverso Nginx sobre Ubuntu Server.

El objetivo fue establecer un punto de entrada HTTPS para servicios internos, aplicar controles de seguridad a nivel HTTP y validar el comportamiento de la infraestructura mediante pruebas funcionales y de carga controlada.

Proyecto desarrollado como parte de mi formación práctica del Ciclo Formativo de Grado Superior en Administración de Sistemas Informáticos en Red (ASIR).

## Technologies

- Ubuntu Server LTS
- Nginx
- Docker y Docker Compose
- Let's Encrypt
- TLS 1.2 / TLS 1.3
- Bash y herramientas de administración Linux
- curl
- ApacheBench
- HTTP Security Headers

## Architecture

```text
HTTPS Client
     |
     v
Nginx Reverse Proxy
  - TLS termination
  - HTTP security headers
  - Rate limiting
     |
     v
Internal Reverse Proxy
     |
     v
Private Backend Services
```

La arquitectura permite concentrar el tratamiento del tráfico HTTP/HTTPS en un proxy perimetral y mantener los servicios internos separados del acceso directo desde el exterior.

## Technical Implementation

### 1. Reverse Proxy Configuration

- Configuración de Nginx como proxy inverso.
- Enrutamiento de peticiones HTTP a servicios internos.
- Configuración de cabeceras de reenvío.
- Comprobación de sintaxis y recarga controlada del servicio.
- Validación de conectividad y disponibilidad.

### 2. HTTPS and TLS

- Utilización de certificados Let's Encrypt.
- Terminación TLS en Nginx.
- Compatibilidad comprobada con TLS 1.2 y TLS 1.3.
- Redirección HTTP 301 a HTTPS, validada localmente.
- Verificación del certificado mediante herramientas de línea de comandos.

### 3. HTTP Security Headers

Implementación y validación de las siguientes cabeceras:

| Header | Configuration |
|---|---|
| Strict-Transport-Security | max-age=300 |
| X-Frame-Options | DENY |
| X-Content-Type-Options | nosniff |
| Content-Security-Policy | Política restrictiva adaptada a los recursos utilizados |

La duración de HSTS se configuró de forma temporal para las pruebas de laboratorio.

### 4. Rate Limiting

Configuración de limitación de peticiones por dirección IP mediante Nginx:

- Tasa nominal: 5 solicitudes por segundo.
- Ráfaga permitida: 10 solicitudes adicionales.
- Respuesta HTTP 429 cuando se supera el límite.
- Comprobación mediante curl, ApacheBench y registros de Nginx.

Durante las pruebas se identificó un problema: el limitador afectaba también a recursos estáticos legítimos.

Se ajustó la configuración para mantener la limitación sobre las rutas de aplicación sin provocar falsos errores 429 en los recursos estáticos.

### 5. Validation and Testing

Prueba final controlada con ApacheBench:

| Metric | Result |
|---|---|
| Requests | 40 |
| Concurrency | 4 |
| HTTP 200 | 14 |
| HTTP 429 | 26 |
| Duration | 0.775 s |

Después de las pruebas se comprobó que Nginx continuaba activo y que el servicio de comprobación de salud respondía correctamente.

Estas mediciones corresponden a un entorno de laboratorio. No representan un ensayo de resistencia frente a ataques DDoS ni una estimación de capacidad sostenible en producción.

## Skills Demonstrated

- Administración y configuración de servidores Linux.
- Despliegue y mantenimiento de Nginx.
- Configuración de reverse proxies.
- Implementación y validación de HTTPS/TLS.
- Aplicación de medidas de seguridad HTTP.
- Análisis de errores mediante logs.
- Resolución de problemas de disponibilidad.
- Pruebas funcionales y de rendimiento controladas.

## Security and Privacy

Las configuraciones compartidas en este repositorio son ejemplos saneados para fines educativos.

No se publican claves privadas, certificados con material sensible, credenciales, direcciones reales de la infraestructura ni código de servicios internos.

## Author

**Erick Conesa Pérez**

Estudiante de segundo curso del CFGS en Administración de Sistemas Informáticos en Red (ASIR).

Intereses profesionales: Linux, infraestructura de sistemas, redes, seguridad y automatización.

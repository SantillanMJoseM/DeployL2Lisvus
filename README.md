# Deploy automático L2J Lisvus con Docker

Este proyecto permite desplegar un servidor completo de **Lineage 2 L2J Lisvus** de forma automatizada utilizando **Docker y Docker Compose**, sin necesidad de instalación manual de dependencias.

---

## 🚀 Características

- 🐳 Deploy automático con Docker  
- 🔄 Compilación automática del código fuente  
- 📦 Descarga directa desde L2J Lisvus repository  
- 🧠 Configuración guiada mediante script  
- 🗄️ Base de datos MariaDB integrada  
- ♻️ Opción de reutilizar o resetear la base de datos  
- ⚙️ Configuración dinámica mediante `.env`  
- 🧩 Compatible con entornos LXC / VPS / servidores dedicados  

---

## ⚠️ Importante

🔥 **El sistema SIEMPRE compila la última versión disponible del repositorio L2J Lisvus.**

Esto significa que:

- No usa builds precompilados  
- Siempre obtiene los últimos cambios del repositorio  
- Puede incluir nuevas funcionalidades o cambios recientes automáticamente  

---

## 📁 Estructura del proyecto

```bash
.
├── docker-compose.yml
├── init.sh
├── .env
└── l2j/
    ├── Dockerfile
    └── entrypoint.sh
```

---

## ⚙️ Requisitos

- Linux (Ubuntu recomendado)  
- Acceso root o sudo  
- Conexión a internet  

👉 No es necesario instalar Docker manualmente (el script lo hace automáticamente)

---

## 🚀 Instalación

```bash
apt update && apt upgrade -y

apt install -y git

git clone https://github.com/SantillanMJoseM/DeployL2Lisvus.git

cd DeployL2Lisvus

chmod +x init.sh

./init.sh

docker compose up -d --build

docker logs -f l2j_server
```

---

## 📜 Logs

```bash
docker logs -f l2j_server
```

---

## 💬 Futuras mejoras

- Backup automático  
- Healthchecks  
- Panel web  
- Auto creación de GM  
- Soporte multi-server  

---

# L2J Lisvus Auto Deploy with Docker

This project provides a fully automated deployment of a **Lineage 2 L2J Lisvus server** using **Docker and Docker Compose**, without manual dependency installation.

---

## 🚀 Features

- 🐳 Fully automated Docker deployment  
- 🔄 Automatic source compilation  
- 📦 Direct download from L2J Lisvus repository  
- 🧠 Interactive configuration script  
- 🗄️ Integrated MariaDB database  
- ♻️ Database reset or reuse options  
- ⚙️ Dynamic configuration via `.env`  
- 🧩 Compatible with LXC / VPS / dedicated servers  

---

## ⚠️ Important

🔥 **This system ALWAYS compiles the latest version available from the L2J Lisvus repository.**

This means:

- No precompiled builds are used  
- Always pulls the latest updates  
- May include new features or changes automatically  

---

## 📁 Project structure

```bash
.
├── docker-compose.yml
├── init.sh
├── .env
└── l2j/
    ├── Dockerfile
    └── entrypoint.sh
```

---

## ⚙️ Requirements

- Linux (Ubuntu recommended)  
- Root or sudo access  
- Internet connection  

👉 Docker is installed automatically if not present  

---

## 🚀 Installation

```bash
apt update && apt upgrade -y

apt install -y git

git clone https://github.com/SantillanMJoseM/DeployL2Lisvus.git

cd DeployL2Lisvus

chmod +x init.sh

./init.sh

docker compose up -d --build

docker logs -f l2j_server
```

---

## 📜 Logs

```bash
docker logs -f l2j_server
```
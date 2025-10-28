# 🌀 Blue/Green Deployment with Nginx (Auto-Failover + Manual Toggle)

## 📋 Overview.
This setup demonstrates Blue/Green deployment using **Nginx** as a load balancer and **Docker Compose** for orchestration.

- Blue = Active (default)
- Green = Backup (standby)
- Seamless failover when Blue fails
- Fully configurable via `.env`

---

## ⚙️ Project Structure.
blue-green-nginx/
│
├── .env
├── docker-compose.yml
├── nginx.template.conf
├── README.md
└── .github/
    └── workflows/
        ├── deploy.yml             
      
Copy code

---

## 🚀 How to Run

### 1️⃣ Set environment variables
Edit `.env`:
```bash
BLUE_IMAGE=<image-link-blue>
GREEN_IMAGE=<image-link-green>
ACTIVE_POOL=blue
RELEASE_ID_BLUE=v1.0.0
RELEASE_ID_GREEN=v1.0.1
2️⃣ Start the stack
bash
Copy code
docker-compose up -d
Access via:
👉 http://localhost:8080/version

3️⃣ Trigger Failover Test
Simulate Blue failure:

bash
Copy code
curl -X POST http://localhost:8081/chaos/start?mode=error
Then check:

bash
Copy code
curl -i http://localhost:8080/version
✅ Expect response from Green.

Stop chaos:

bash
Copy code
curl -X POST http://localhost:8081/chaos/stop
🔁 Manual Toggle
To switch manually:

bash
Copy code
# Edit .env
ACTIVE_POOL=green

# Reload config
docker exec nginx nginx -s reload
🧠 Key Features
Auto-failover within seconds

No downtime during failure

Retries handled at Nginx layer

Works seamlessly with CI/CD

yaml
Copy code

---

## 🧩 **To Get Started**

1. Create a folder:  
   ```bash
   mkdir blue-green-nginx && cd blue-green-nginx
Create the 3 files above (.env, docker-compose.yml, nginx.template.conf) and paste the code.

Run:

bash
Copy code
docker-compose up -d
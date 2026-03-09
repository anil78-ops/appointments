---

# 🏥 Appointment Service

A lightweight **Node.js microservice** for managing patient appointments.

This service provides REST APIs to create, retrieve, and manage appointments and is designed to run inside **Docker containers** and deploy automatically to **AWS EKS using GitHub Actions CI/CD**.

---

# 🚀 Tech Stack

| Technology        | Purpose                                      |
| ----------------- | -------------------------------------------- |
| 🟢 Node.js        | Backend runtime                              |
| ⚡ Express.js      | REST API framework                           |
| 🐳 Docker         | Containerization                             |
| ☁️ Amazon ECR     | Container registry                           |
| ☸️ Amazon EKS     | Kubernetes cluster                           |
| 🔁 GitHub Actions | CI/CD automation                             |
| 🔐 AWS OIDC       | Secure authentication between GitHub and AWS |

---

# 📂 Project Structure

```text
appointments/
│
├── .github/
│   └── workflows/
│       └── deploy.yml              # CI/CD pipeline
│
├── manifests/
│   └── appointments-dev.yaml       # Kubernetes deployment manifest
│
├── src/
│   └── index.js                    # Express application
│
├── Dockerfile                      # Docker build instructions
├── package.json
├── package-lock.json
├── .gitignore
└── README.md
```

---

# 🌐 API Endpoints

## 🩺 Health Check

```http
GET /health
```

Response

```json
{
  "status": "OK",
  "service": "Appointment Service"
}
```

---

## 📋 Get All Appointments

```http
GET /appointments
```

Response

```json
{
  "message": "Appointments retrieved successfully",
  "count": 2,
  "appointments": []
}
```

---

## 🔍 Get Appointment by ID

```http
GET /appointments/:id
```

Example

```http
GET /appointments/1
```

---

## ➕ Create Appointment

```http
POST /appointments
```

Request Body

```json
{
  "patientId": "1",
  "date": "2023-06-20",
  "time": "09:30",
  "doctor": "Dr. Smith"
}
```

---

## 👤 Get Appointments by Patient

```http
GET /appointments/patient/:patientId
```

Example

```http
GET /appointments/patient/1
```

---

# 🖥️ Running Locally

### Install Dependencies

```bash
npm install
```

### Start the Application

```bash
node src/index.js
```

Service runs at

```
http://localhost:3001
```

---

# 🐳 Docker

### Build Image

```bash
docker build -t appointments-service .
```

### Run Container

```bash
docker run -p 3001:3001 appointments-service
```

---

# ☸️ Kubernetes Deployment

The Kubernetes manifest is located at:

```
manifests/appointments-dev.yaml
```

Deploy manually using:

```bash
kubectl apply -f manifests/appointments-dev.yaml
```

Verify deployment:

```bash
kubectl get pods
kubectl get services
```

---

# 🔁 CI/CD Pipeline (GitHub Actions)

The project uses **GitHub Actions** to automatically build, push, and deploy the service.

Workflow file:

```
.github/workflows/deploy.yml
```

The pipeline triggers when:

* Code is **pushed to the `main` branch**
* The workflow is triggered manually using **workflow_dispatch**

---

# ⚙️ CI/CD Pipeline Steps Explained

## 1️⃣ Checkout Repository

```yaml
- name: Checkout
  uses: actions/checkout@v4
```

📥 This step pulls the repository code into the GitHub Actions runner so the pipeline can access the project files.

---

## 2️⃣ Configure AWS Credentials via OIDC

```yaml
- name: Configure AWS credentials via OIDC
  uses: aws-actions/configure-aws-credentials@v4
```

🔐 This step authenticates GitHub with AWS using **OIDC (OpenID Connect)**.

Instead of storing AWS access keys, GitHub assumes an **IAM role** using:

```
AWS_dev_OIDC_ARN
```

This provides **temporary secure credentials**.

---

## 3️⃣ Login to Amazon ECR

```yaml
- name: Login to Amazon ECR
  uses: aws-actions/amazon-ecr-login@v2
```

🐳 This logs the workflow into **Amazon Elastic Container Registry (ECR)** so it can push Docker images.

---

## 4️⃣ Generate Docker Image URI

```yaml
- name: Set Image URI
```

This creates the image path dynamically using:

* AWS account ID
* ECR repository
* Git commit SHA

Example:

```
123456789012.dkr.ecr.us-east-1.amazonaws.com/appointments:commitSHA
```

---

## 5️⃣ Build Docker Image

```bash
docker build -t $IMAGE_URI .
```

🐳 Builds the Docker image using the **Dockerfile** in the repository.

---

## 6️⃣ Push Image to ECR

```bash
docker push $IMAGE_URI
```

📦 Uploads the Docker image to **Amazon ECR**, making it available for Kubernetes deployments.

---

## 7️⃣ Update kubeconfig for EKS

```bash
aws eks update-kubeconfig
```

☸️ This command connects the GitHub Actions runner to the **Amazon EKS cluster** so it can execute `kubectl` commands.

---

## 8️⃣ Update Image in Kubernetes Manifest

```bash
sed -i "s|image:.*|image: $IMAGE_URI|g" manifests/appointments-dev.yaml
```

🔄 This replaces the container image in the Kubernetes manifest with the **newly built Docker image**.

Example:

Before

```
image: old-image
```

After

```
image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/appointments:commitSHA
```

---

## 9️⃣ Install kubectl

```yaml
uses: azure/setup-kubectl@v4
```

This installs **kubectl** in the runner so it can communicate with the Kubernetes cluster.

---

## 🔟 Deploy to EKS

```bash
kubectl apply -f manifests/appointments-dev.yaml
```

☸️ This applies the Kubernetes manifest and deploys the new version of the application to the **EKS cluster**.

The cluster will:

* Pull the image from **ECR**
* Create or update **pods**
* Run the new application version

---

# 🔐 Required GitHub Secrets

Configure the following secrets in your **GitHub repository settings**.

| Secret           | Description                                  |
| ---------------- | -------------------------------------------- |
| AWS_dev_OIDC_ARN | IAM Role used for GitHub OIDC authentication |
| AWS_dev_REGION   | AWS region where EKS and ECR are located     |
| AWS_ACCOUNT_ID   | AWS account ID                               |
| EKS_CLUSTER_NAME | Name of the EKS cluster                      |

---

# 🔄 CI/CD Flow Overview

```
Developer Push Code
        │
        ▼
GitHub Actions Trigger
        │
        ▼
Build Docker Image
        │
        ▼
Push Image → Amazon ECR
        │
        ▼
Update Kubernetes Manifest
        │
        ▼
Deploy to AWS EKS
        │
        ▼
Application Running in Kubernetes
```


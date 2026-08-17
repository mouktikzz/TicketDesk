# TicketDesk Frontend

A modern, responsive IT Support Ticket Management web application built with **HTML5**, **CSS3**, and **Vanilla JavaScript (ES Modules)**.

The frontend communicates with the **TicketDesk FastAPI backend**, currently deployed behind an **AWS Application Load Balancer (ALB)**. Ticket attachments use secure Amazon S3 presigned URLs for direct browser-to-S3 uploads.

---

## 🚀 Features

### 📊 Dashboard

- View overall ticket statistics
- Total ticket count
- Open tickets
- In-progress tickets
- Resolved tickets
- Activity and ticket breakdowns

### 🎫 Ticket Management

- Create new tickets
- View ticket list
- Search tickets by title and description
- Filter tickets by status, priority, and category
- View ticket details
- Update ticket status

Supported ticket statuses:

```text
OPEN
IN_PROGRESS
RESOLVED
CLOSED
```

### 💬 Comments

- View ticket discussions
- Add comments to tickets
- Display comments within ticket details

### 📎 File Attachments

- Upload attachments to tickets
- Direct browser-to-S3 uploads using presigned URLs
- Private Amazon S3 attachment bucket
- Secure temporary download URLs
- View/download ticket attachments
- Attachment metadata managed by the backend

The frontend never exposes AWS credentials.

### 🎨 User Interface

- Responsive design
- Modern dark theme
- Glassmorphism-inspired components
- CSS Grid and Flexbox
- Animated UI elements
- Toast notifications
- Loading states
- Error handling
- Form validation
- Interactive ticket details

---

# 📁 Project Structure

```text
TicketDeck_Frontend/
│
├── index.html
├── README.md
│
├── css/
│   └── styles.css
│
└── js/
    ├── api.js
    ├── app.js
    ├── dashboard.js
    ├── tickets.js
    └── ticket-detail.js
```

## JavaScript Modules

| File | Description |
|---|---|
| `api.js` | Centralized API client and HTTP request handling |
| `app.js` | Application initialization and navigation |
| `dashboard.js` | Dashboard statistics and activity rendering |
| `tickets.js` | Ticket listing, filtering, searching, and ticket creation |
| `ticket-detail.js` | Ticket details, status updates, comments, and attachments |

---

# ⚙️ Requirements

- Modern web browser
- Python 3.x **or** Node.js
- Access to the deployed TicketDesk backend API

---

# 🌐 Current Backend Deployment

The TicketDesk FastAPI backend is currently deployed behind an **AWS Application Load Balancer**.

### AWS ALB

```text
http://ticketdesk-alb-779410850.ap-south-1.elb.amazonaws.com
```

### API base path

```text
http://ticketdesk-alb-779410850.ap-south-1.elb.amazonaws.com/api
```

---

# 🔧 Configuration

The API configuration is in:

```text
js/api.js
```

### Current deployed configuration

```javascript
const BASE_URL = "http://ticketdesk-alb-779410850.ap-south-1.elb.amazonaws.com";
```

API requests use paths such as:

```text
/api/tickets
/api/tickets/{ticket_id}
/api/tickets/{ticket_id}/comments
/api/tickets/{ticket_id}/attachments/presigned-url
/api/tickets/{ticket_id}/attachments/complete
```

### Future CloudFront configuration

Once CloudFront is provisioned, the recommended production configuration is:

```javascript
const BASE_URL = "/api";
```

CloudFront will route `/api/*` requests to the ALB, so the ALB hostname does not need to be exposed in browser JavaScript.

---

# ▶️ Running the Frontend

Because the application uses native JavaScript ES Modules, serve it through HTTP rather than opening `index.html` directly with `file://`.

## Python HTTP Server

```bash
cd TicketDeck_Frontend
python -m http.server 8080
```

Open:

```text
http://localhost:8080
```

Current request flow:

```text
Browser
   │
   ▼
localhost:8080
   │
   │ API requests
   ▼
AWS ALB
   │
   ▼
ECS / FastAPI
```

## Node.js `serve`

```bash
cd TicketDeck_Frontend
npx serve . -p 8080
```

Open:

```text
http://localhost:8080
```

## VS Code Live Server

1. Open `TicketDeck_Frontend` in VS Code.
2. Open `index.html`.
3. Right-click `index.html`.
4. Select **Open with Live Server**.

The exact port depends on the Live Server configuration.

---

# 🔌 Backend Integration

Current request flow:

```text
Browser
   │
   │ HTTP API request
   ▼
AWS Application Load Balancer
   │
   ▼
ECS Fargate
   │
   ▼
FastAPI Backend
```

The API layer is centralized in:

```text
js/api.js
```

Typical operations:

```text
GET    /api/tickets
GET    /api/tickets/{ticket_id}
POST   /api/tickets
POST   /api/tickets/{ticket_id}/comments
POST   /api/tickets/{ticket_id}/attachments/presigned-url
POST   /api/tickets/{ticket_id}/attachments/complete
```

---

# 📎 Attachment Upload Architecture

TicketDesk uses Amazon S3 presigned URLs for direct browser uploads.

```text
Browser
   │
   │ 1. Request presigned URL
   ▼
AWS ALB
   │
   ▼
ECS / FastAPI
   │
   │ 2. Generate presigned PUT URL
   ▼
Browser
   │
   │ 3. Upload file directly
   ▼
Private Amazon S3
   │
   │ 4. Complete upload
   ▼
AWS ALB
   │
   ▼
ECS / FastAPI
   │
   ▼
PostgreSQL
   │
   └── Attachment metadata
```

The actual file bytes do not pass through FastAPI during the direct S3 upload.

---

# 📥 Attachment Download

Attachments are stored in a private S3 bucket.

```text
Browser
   │
   │ Request attachment
   ▼
AWS ALB
   │
   ▼
ECS / FastAPI
   │
   │ Generate presigned GET URL
   ▼
Browser
   │
   │ Temporary S3 URL
   ▼
Private S3 Object
```

The raw S3 object does not need to be publicly readable.

---

# 🔐 Security

- AWS credentials are never exposed to the browser.
- S3 attachment bucket remains private.
- Uploads use presigned URLs.
- Downloads use temporary presigned URLs.
- AWS access keys are not stored in frontend JavaScript.
- The backend manages presigned URL generation and attachment metadata.

---

# 🏗️ Current Application Architecture

```text
                         Internet
                            │
                            ▼
                    ┌─────────────────┐
                    │  AWS ALB        │
                    │ Public Subnets  │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  ECS Fargate    │
                    │  FastAPI API    │
                    └───────┬─────────┘
                            │
                   ┌────────┴────────┐
                   ▼                 ▼
            PostgreSQL RDS      Amazon S3
                               Attachments
```

During local frontend development:

```text
Browser
   │
   ▼
localhost:8080
   │
   │ HTTP API
   ▼
AWS ALB
   │
   ▼
ECS Fargate
   │
   ▼
FastAPI
```

---

# ☁️ Planned Production Frontend Architecture

The recommended final architecture uses Amazon CloudFront as the public entry point.

```text
                         Internet
                            │
                            ▼
                    ┌─────────────────┐
                    │   CloudFront    │
                    │  Distribution   │
                    └────────┬────────┘
                             │
                  ┌──────────┴──────────┐
                  │                     │
               Default                /api/*
                  │                     │
                  ▼                     ▼
          Private S3 Bucket            ALB
          Frontend Files                │
                                        ▼
                                  ECS Fargate
                                        │
                             ┌──────────┴──────────┐
                             ▼                     ▼
                       PostgreSQL RDS         S3 Attachments
```

The final frontend configuration should be:

```javascript
const BASE_URL = "/api";
```

CloudFront will route:

```text
https://<cloudfront-domain>/api/*
```

to the ALB.

This makes CloudFront the single public entry point and avoids exposing the ALB URL directly to browser JavaScript.

> **Current blocker:** CloudFront provisioning is temporarily blocked by an AWS account verification requirement. The Terraform CloudFront configuration is retained and can be enabled once the account is verified.

---

# 🛠️ Technology Stack

## Frontend

- HTML5
- CSS3
- Vanilla JavaScript
- ES6+
- ES Modules
- Fetch API
- Async/Await
- CSS Grid
- Flexbox

## Backend

- Python
- FastAPI
- PostgreSQL

## AWS / Infrastructure

- Docker
- Docker Compose
- Amazon VPC
- Amazon ECS Fargate
- Amazon ECR
- Application Load Balancer
- Amazon RDS PostgreSQL
- Amazon S3
- AWS IAM
- AWS Secrets Manager
- AWS Systems Manager Parameter Store
- Amazon CloudFront
- AWS Lambda
- Amazon CloudWatch
- Amazon SNS

---

# 🧪 Development Workflow

## Using the deployed backend

### 1. Verify the ALB API

```bash
curl http://ticketdesk-alb-779410850.ap-south-1.elb.amazonaws.com/api/tickets
```

A successful response should return ticket data as JSON.

### 2. Start the frontend

```bash
cd TicketDeck_Frontend
python -m http.server 8080
```

### 3. Open the application

```text
http://localhost:8080
```

### 4. Verify

- Dashboard loads
- Tickets are displayed
- Tickets can be created
- Ticket details load
- Comments can be added
- Status can be updated
- Attachments can be uploaded
- Attachments can be opened/downloaded

---

# 🐳 Docker Development

From the project root:

```bash
docker compose up --build
```

Check running containers:

```bash
docker compose ps
```

If the backend is running locally, temporarily change `BASE_URL` in `js/api.js` to the local backend URL.

For the current deployed setup:

```javascript
const BASE_URL = "http://ticketdesk-alb-779410850.ap-south-1.elb.amazonaws.com";
```

---

# 🐛 Troubleshooting

## Frontend does not load

Serve the application through HTTP:

```bash
python -m http.server 8080
```

Do not open:

```text
file:///.../index.html
```

## API connection fails

Verify the ALB directly:

```bash
curl http://ticketdesk-alb-779410850.ap-south-1.elb.amazonaws.com/api/tickets
```

If ticket data is returned, the ALB and backend are responding.

Then inspect:

```text
F12 → Console
F12 → Network
```

## Tickets are not loading

Test:

```bash
curl http://ticketdesk-alb-779410850.ap-south-1.elb.amazonaws.com/api/tickets
```

If the API returns data but the frontend does not display it, check:

- Incorrect `BASE_URL`
- CORS errors
- JavaScript errors
- Failed API requests
- Incorrect API paths

## S3 upload fails

Check:

- ALB backend is reachable
- Presigned URL endpoint is working
- S3 bucket exists
- S3 CORS configuration allows the frontend origin
- Correct `Content-Type` is used
- Presigned URL has not expired
- Backend has required S3 permissions

## Attachment cannot be opened

S3 objects are private. The frontend should use a presigned GET URL generated by the backend rather than accessing the raw S3 object URL.

---

# 📌 Current Project Status

The frontend currently supports:

```text
✅ Dashboard
✅ Ticket creation
✅ Ticket listing
✅ Ticket filtering
✅ Ticket search
✅ Ticket details
✅ Status updates
✅ Comments
✅ File attachments
✅ Direct S3 uploads
✅ Presigned attachment downloads
✅ Responsive UI
```

Current AWS deployment:

```text
✅ Amazon VPC
✅ ECS Fargate
✅ Amazon ECR
✅ Application Load Balancer
✅ PostgreSQL RDS
✅ Private S3 attachment storage
✅ S3 presigned uploads
```

Infrastructure/configuration:

```text
✅ Terraform infrastructure
✅ S3 frontend bucket
✅ Terraform frontend file upload
⏳ CloudFront
⏳ CloudFront /api/* → ALB routing
⏳ Lambda thumbnail generation
⏳ CloudWatch observability
⏳ SNS alarms
⏳ CI/CD
```

### CloudFront blocker

CloudFront distribution creation is currently blocked by an AWS account verification requirement:

```text
AccessDenied:
Your account must be verified before you can add new CloudFront resources.
```

The CloudFront Terraform configuration is retained in the project and can be enabled once the AWS account verification issue is resolved.

---

# 📄 License

This project is developed as part of the **TicketDesk POC**.

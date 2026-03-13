# OpenClaw Intro (Vue + Node)

A tiny full-stack app:
- **Frontend**: Vue 3 + Vite
- **Backend**: Node.js (Express) serves static frontend build + a small `/api/health` endpoint

## Local dev

### Frontend
```bash
cd frontend
npm i
npm run dev
```

### Backend
```bash
cd backend
npm i
npm run dev
# http://localhost:3000
```

## Production build
```bash
cd frontend && npm ci && npm run build
cd ../backend && npm ci
# copy frontend build into backend
rm -rf public
cp -R ../frontend/dist public
node server.js
```

## CI/CD
See `Jenkinsfile`.

> Deployment target (Windows) is implemented via SSH + PowerShell script `deploy/windows/deploy.ps1`.
> Put the server credentials into Jenkins **Credentials** (do NOT hardcode them in repo).

# Task Manager API

A RESTful API backend for Task Manager application built with Node.js, Express, and MongoDB.

## Tech Stack
- **Node.js** + **Express** - Web framework
- **MongoDB** + **Mongoose** - Database
- **JWT** - Authentication
- **Nodemailer** - Email sending
- **Bcryptjs** - Password hashing
- **Node-cron** - Scheduled tasks
- **Express-validator** - Input validation

## Setup

### 1. Clone & Install
```bash
cd api
npm install
```

### 2. Environment Variables
```bash
cp .env.example .env
```
Edit `.env` with your actual values.

### 3. Start MongoDB
Make sure MongoDB is running locally or update `MONGODB_URI` to your Atlas connection string.

### 4. Run the server
```bash
# Development
npm run dev

# Production
npm start
```

## API Endpoints

### Auth (`/api/auth`)
| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | /register | Register new account | No |
| POST | /login | Login, returns JWT | No |
| GET | /me | Get current user info | Yes |
| PUT | /me | Update profile | Yes |
| PUT | /change-password | Change password | Yes |

### Users (`/api/users`)
| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | /search?q= | Search users by name/email | Yes |
| GET | /:id | Get public user info | Yes |

### Tasks (`/api/tasks`)
| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | / | List tasks (scope, status, priority, q, sortBy, order) | Yes |
| POST | / | Create task | Yes |
| GET | /:id | Get task details | Yes |
| PUT | /:id | Update task (owner or editor) | Yes |
| DELETE | /:id | Delete task (owner only) | Yes |
| PATCH | /:id/status | Update task status | Yes |
| GET | /:id/activities | Task activity history | Yes |
| GET | /:id/email-logs | Task email logs | Yes |

### Assignees (`/api/tasks/:id/assignees`)
| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | / | List assignees | Yes |
| POST | / | Assign users (sends email + notification) | Yes |
| PATCH | /:userId | Update role/primary | Yes |
| DELETE | /:userId | Remove assignee | Yes |

### Shares (`/api/tasks/:id/shares`)
| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | / | List shares | Yes |
| POST | / | Share task (sends email + notification) | Yes |
| PATCH | /:shareId | Change permission | Yes |
| DELETE | /:shareId | Revoke share | Yes |

### Notifications (`/api/notifications`)
| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | / | List notifications | Yes |
| GET | /unread-count | Count unread | Yes |
| PATCH | /:id/read | Mark as read | Yes |
| PATCH | /read-all | Mark all as read | Yes |

### Statistics (`/api/statistics`)
| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | /tasks | Task status statistics | Yes |
| GET | /assignments | Assignment statistics | Yes |
| GET | /deadlines | Upcoming/overdue deadlines | Yes |

### Email Logs (`/api/email-logs`)
| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | /:id/retry | Retry failed email | Yes |

## Permissions
- **Owner**: Full access (create, read, update, delete, manage shares)
- **Editor**: Can read and update task content, cannot delete or manage shares
- **Viewer**: Read-only access

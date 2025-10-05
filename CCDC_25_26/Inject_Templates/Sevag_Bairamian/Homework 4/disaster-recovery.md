# TaskManager Pro Disaster Recovery Plan

## Overview
Brief description of recovery objectives and scope. 
  
## Critical Data Inventory
- MongoDB Database: Mongodump will be needed to implement a schedule for regular backups. Running mongodump will back up all databases on local MongoDB instance.

- Redis Sessions: Using redis-cli, we can use SAVE or BGSAVE to take a snap shot synchronously.  And save RDB file to a remote location.

- Uploaded Files: Files are stored in a Docker volume or bind mount. Backup using tar -xzf

## Recovery Procedures

### Step 1: Assessment
1. Verify that failure has occurred through hardware.

2. #Verify data volume integrity and then inspect volume:

3. Mount the volumes in a test container to confirm that there is data present.



### Step 2: Data Restoration
1. Stop Existing Services

2. Restore from MongoDB and Redis backup. Restore upload files through tar. 

#Restore MongoDB

mongorestore --host localhost --port 27017 /backup/mongodb

#Restore Redis

Copy RDB file back to Redis data directory and restart.

Restore uploaded files:

tar -xzf uploads-backup.tar.gz -C /srv/uploads

3. Verify data integrity

### Step 3: Service Deployment
1. Initialize Docker Swarm: `docker swarm init`

2. Deploy using docker-compose.yml with docker-compose.prod.yml

3. Verify service health.



### Step 4: Testing & Validation
1. Check if web is up and running us curl.

2. Use real time monitoring with watch

2. Verify all functionality

3. Document results

## Recovery Time Objectives

- **Data Restoration**: 30-40 minutes

- **Service Deployment**: [20-25 minutes

- **Total Recovery**: 50 – 65 minutes

## Testing Procedures

Run volume integrity checks using docker exec into containers

Use real-time monitoring with watch to see if containers are up and running or shutdown.

Test by shutting down all services using docker compose down and seeing if containers will come back up automatically.

## Lessons Learned
[TO BE COMPLETED AFTER IMPLEMENTATION]

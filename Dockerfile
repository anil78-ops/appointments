# Use Node.js base image
FROM node:20-alpine

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install express

# Copy application source
COPY . .

# Expose application port
EXPOSE 3000

# Start the application
CMD ["node", "src/index.js"]
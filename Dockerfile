# Use a lightweight official Node.js image
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first to cache layer efficiently
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the application code
COPY . .

# The application runs on this port
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]

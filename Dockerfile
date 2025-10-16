# Use Node.js base image
FROM node:lts-alpine

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json from the app folder
COPY app/package*.json ./

# Install dependencies
RUN npm install -g npm@11.6.2

# Copy the rest of the application code from the app folder
COPY app .

# Expose port 80
EXPOSE 80

# Start the Node.js app
CMD ["node", "app.js"]

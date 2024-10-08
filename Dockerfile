# Use Node.js base image
FROM node:14-alpine

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json from the app folder
COPY app/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code from the app folder
COPY app .

# Expose port 80
EXPOSE 80

# Start the Node.js app
CMD ["node", "app.js"]

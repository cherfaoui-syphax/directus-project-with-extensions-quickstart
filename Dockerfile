# Use the latest Node.js runtime as a parent image
FROM node:22.14.0

# Set the working directory inside the container
WORKDIR /app

# Copy the root package.json and package-lock.json first
COPY package*.json ./

# Update npm to the latest version
RUN npm install -g npm@latest

# Install root-level dependencies
RUN npm install --only=production

# Copy the package.json for the my-bundle extension
COPY src-extensions/my-bundle/package*.json ./src-extensions/my-bundle/

# Install my-bundle extension dependencies
WORKDIR /app/src-extensions/my-bundle
RUN npm install --only=production

# Return to main app directory
WORKDIR /app

# Copy the rest of the application
COPY . .

# Expose the port the app runs on
EXPOSE 8055

# Define the command to run the application
CMD ["bash", "script-quickstart.sh"]
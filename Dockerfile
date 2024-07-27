# Stage 1: Build React App
FROM node:lts-alpine3.20 AS build

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and yarn.lock to install dependencies efficiently and leverage layer caching
COPY package.json yarn.lock ./

# Set up Yarn cache in a designated directory to improve caching
RUN --mount=type=cache,target=/usr/src/app/.yarn \
  yarn config set cache-folder /usr/src/app/.yarn && \
  yarn install

# Copy the entire application source code
COPY . .

# Run the build command to generate production-ready artifacts
RUN yarn build

# Stage 2: Deployable Image
# Use a specific version of the official Nginx image as the base image for the deployable image
FROM nginx:1.27

# Expose the port that the Nginx server will listen on
EXPOSE 80

# Copy the built artifacts from the build stage to the Nginx HTML directory
COPY --from=build /usr/src/app/build /usr/share/nginx/html
COPY --from=build /usr/src/app/nginx.conf /etc/nginx/nginx.conf

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]

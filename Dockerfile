# Use the official Node.js image for installing Node.js and Yarn
FROM node:14 AS node

# Set the working directory
WORKDIR /app

# Copy only the package.json and yarn.lock files
COPY package.json yarn.lock ./

# Install Node.js dependencies using Yarn
RUN yarn install

# Now build the Rails application using the official Ruby image
FROM ruby:2.7.4

# Set environment variables
ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true

# Install dependencies
RUN apt-get update && \
    apt-get install -y nodejs && \
    gem install bundler

# Create and set the working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copy the rest of the application code
COPY . .

# Copy Node.js dependencies from the previous stage
COPY --from=node /app/node_modules /app/node_modules

# Expose port
EXPOSE 3000

# Start Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]

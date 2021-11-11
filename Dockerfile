FROM node

# Set application working directory
WORKDIR /usr/src/manage_contacts

COPY . .

# Install node dependencies
RUN npm install

# Install sequelize and db migration 
RUN npm install -g sequelize-cli

# Commented becasue db container not access with the container name while building image. This action will do it manually
# RUN sequelize db:migrate

EXPOSE 3000

# RUN chmod +x entrypoint.sh # Override the entrypoint.sh
CMD ["npm", "start"]


FROM node:8
WORKDIR /node
COPY package.json ./
RUN npm i
COPY . .
EXPOSE 8080
CMD ["npm", "start"]

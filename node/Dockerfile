FROM node:8
WORKDIR /node
COPY package.json /node
RUN npm i
COPY . .
EXPOSE 3000
CMD ["npm", "start"]

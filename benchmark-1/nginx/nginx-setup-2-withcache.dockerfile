FROM nginx:alpine

RUN mkdir /nginx-cache && chown -R nginx /nginx-cache && chmod 700 /nginx-cache

FROM nginx

RUN echo "Import oboe ontology folder... " && \
mkdir -p /usr/share/nginx/html/oboe/oboe.1.0/ 

COPY oboe-ontologies/* /usr/share/nginx/html/oboe/oboe.1.0/

EXPOSE 80


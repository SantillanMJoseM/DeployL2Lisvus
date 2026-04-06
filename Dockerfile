FROM eclipse-temurin:25-jdk

WORKDIR /opt

RUN apt update && apt install -y git ant unzip mariadb-client

# Clonar repo
RUN git clone https://gitlab.com/TheDnR/l2j-lisvus.git

WORKDIR /opt/l2j-lisvus

# Compilar
RUN cd core && ant clean && ant
RUN cd ../datapack && ant clean && ant

# Unir build
RUN mkdir /opt/server && \
    unzip core/build/core.zip -d /opt/server && \
    unzip datapack/build/datapack.zip -d /opt/server

WORKDIR /opt/server

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

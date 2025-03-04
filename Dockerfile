FROM mcr.microsoft.com/dotnet/sdk:6.0

RUN apt update \
    && apt -y upgrade \
    && apt -y install python3 python3-pip python3-dev ipython3 nano plantuml dos2unix \
    && cp /usr/share/plantuml/plantuml.jar /usr/local/bin/plantuml.jar

RUN pip3 install jupyterlab
RUN pip3 install iplantuml
RUN pip3 install graphviz
RUN pip3 install matplotlib
RUN pip install --upgrade ipykernel

RUN curl -sL https://deb.nodesource.com/setup_18.x  | bash

RUN apt install nodejs \
    && pip3 install --upgrade jupyterlab-git \
    && jupyter lab build

ARG NB_USER="jupyter"
ARG NB_UID="1000"
ARG NB_GID="100"

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER

USER $NB_USER

ENV HOME=/home/$NB_USER

WORKDIR $HOME

ENV PATH="${PATH}:$HOME/.dotnet/tools/"

RUN dotnet tool install --global Microsoft.dotnet-interactive

RUN dotnet-interactive jupyter install
RUN jupyter kernelspec list

RUN mkdir -p $HOME/.jupyter
COPY ./jupyter_lab_config.py $HOME/.jupyter/jupyter_lab_config.py

RUN mkdir -p $HOME/work
COPY ./examples $HOME/work/examples/

USER root

RUN apt-get install sudo && usermod -aG sudo $NB_USER

# prevent git init on this level
RUN mkdir -p $HOME/work/.git
COPY start.sh /start.sh
RUN dos2unix /start.sh
RUN chmod +x /start.sh
USER $NB_USER

CMD ["/start.sh"]

ARG BASE_IMAGE=${BASE_IMAGE:-null}
ARG PUBLIC_IMAGE=${PUBLIC_IMAGE:-null}
FROM ${BASE_IMAGE} as public
ARG PYTHON_VERSION=3.9

COPY ./asset /tmp/build
RUN apt update &&\
    xargs apt install -y < /tmp/build/apt_packages.txt
#RUN conda install rdkit openbabel tensorboard pyyaml easydict python-lmdb -c conda-forge
#RUN conda install pytorch-cluster -c pyg
## install heavy packages here, such as pytorch, graph-tool, rdkit
# RUN curl -fsSL -v -o ${HOME}/miniconda.sh -O  https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
#     chmod +x ${HOME}/miniconda.sh && \
#     ${HOME}/miniconda.sh -b -p /opt/conda && \
#     rm ${HOME}/miniconda.sh && \
#     /opt/conda/bin/conda install -y python=${PYTHON_VERSION} conda-build pyyaml numpy ipython && \
#     /opt/conda/bin/conda clean -ya
# ENV PATH /opt/conda/bin:$PATH
# RUN conda init zsh \
#     && conda init bash 
# RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple 
# RUN pip install -i https://download.pytorch.org/whl/cu116 torch torchvision torchaudio
#RUN pip install -r /tmp/build/requirements.txt \
#   && rm -rf /tmp/build
# For Vina Docking
#RUN pip install meeko==0.1.dev3 scipy pdb2pqr vina==1.2.2 
#RUN pip install git+https://github.com/Valdes-Tresanco-MS/AutoDockTools_py3
# RUN conda install -c conda-forge graph-tool=2.45 rdkit=2023.03.2 \
#     && conda clean -ya

##############################################
FROM ${PUBLIC_IMAGE} as private
ARG TORCH_HOME
ARG _USER
ARG _UID
ARG _GID
ARG PW
ARG _HOME=/sharefs/${_USER}

COPY ./asset /tmp/build
RUN xargs apt install -y < /tmp/build/apt_packages.txt

RUN pip install -r /tmp/build/requirements.txt

# Option1: Using unencrypted password/ specifying password
RUN usermod --password $(echo ${PW} | openssl passwd -1 -stdin) root
RUN useradd -m ${_USER} -d ${_HOME} --uid=${_UID} -s /usr/bin/zsh && echo "${_USER}:${PW}" | chpasswd

# make the color of zsh-autosuggestions right
ENV TERM xterm-256color

RUN cp -r /root/.oh-my-zsh ${_HOME} && chown ${_USER}:${_USER} -R ${_HOME}/.oh-my-zsh &&\
    cp /root/.zshrc ${_HOME} && chown ${_USER}:${_USER} -R ${_HOME}/.zshrc &&\
    cp /root/.tmux.conf ${_HOME} && chown ${_USER}:${_USER} -R ${_HOME}/.tmux.conf && \
    cp -r /root/.tmux ${_HOME} && chown ${_USER}:${_USER} -R ${_HOME}/.tmux


RUN chown ${_USER}:${_USER} -R /tmp/build
USER ${_UID}:${_GID}
WORKDIR ${_HOME}

ENV TORCH_HOME ${TORCH_HOME}

COPY --chown=${_USER}:${_USER} ./asset/ssh .ssh
RUN chmod 0700 .ssh && chmod 600 .ssh/id_rsa && chmod 644 .ssh/id_rsa.pub \
    &&ssh-keyscan github.com >> .ssh/known_hosts \
    && cp /tmp/build/gitconfig ${_HOME}/.gitconfig \
    && cp /tmp/build/download-vs-code-server.sh ${_HOME}/

RUN rm -rf /tmp/build

ENV PYTHONPATH=.:${PYTHONPATH}

CMD "zsh"



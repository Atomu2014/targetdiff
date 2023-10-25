SHELL=/bin/bash
PRIVATE_REGISTRY:=docker.jjgong.cloud
BASE_IMAGE:=${PRIVATE_REGISTRY}/jerrikeph/base-cuda1162-dev-ubuntu2004-py39-torch-rdkit2023.03.2-openbabel

PROJECT_NAME:=bfn4sbdd2
TEAM_NAME:=bfn
PUBLIC_IMAG:=${PRIVATE_REGISTRY}/${TEAM_NAME}/${PROJECT_NAME}

HTTPS_PROXY:=${https_proxy}
HTTP_PROXY:=${http_proxy}
_USER := $(shell whoami)
_UID := $(shell id -u)
_GID := $(shell id -g)
PW:=rootpass

LOCAL_NAME:=exp/${_USER}_${PROJECT_NAME}
PRIVATE_IMAGE:=${PRIVATE_REGISTRY}/${LOCAL_NAME}
CONTRAINER_NAME=$(subst /,_,$(LOCAL_NAME))

PROJ_DIR:=${HOME}/project
SHARE_DIR:=/sharefs/share
TORCH_HOME:=${SHARE_DIR}/torch_home

run: _pull _instantiate_container _exec

run_root: _pull _instantiate_container _exec_root

run_refresh: kill run

kill:
	if docker container ls | grep -w ${CONTRAINER_NAME}; then \
		echo "container ${CONTRAINER_NAME} exists, killing it first"; \
		docker container kill  ${CONTRAINER_NAME}; fi

build_private: _setup_sshkey _setup_gitconfig
	DOCKER_BUILDKIT=1 docker build --pull --target private \
		--build-arg PUBLIC_IMAGE=${PUBLIC_IMAG} \
		--build-arg TORCH_HOME=${TORCH_HOME} \
		--build-arg https_proxy=${HTTPS_PROXY} \
		--build-arg http_proxy=${HTTP_PROXY} \
		--build-arg _USER=${_USER}  \
		--build-arg _UID=${_UID} \
		--build-arg _GID=${_GID} \
		--build-arg PW=${PW} \
		-t ${PRIVATE_IMAGE} .; \
	docker push ${PRIVATE_IMAGE}

edit_public:
	$(eval EDIT_CONTRAINER_NAME=${CONTRAINER_NAME}_edit_public)
	docker run -it --gpus all --name ${EDIT_CONTRAINER_NAME} ${PUBLIC_IMAG} /bin/bash
	docker commit ${EDIT_CONTRAINER_NAME} ${PUBLIC_IMAG}
	docker push ${PUBLIC_IMAG}
	docker container rm ${EDIT_CONTRAINER_NAME}
	
build_public:
	DOCKER_BUILDKIT=1 docker build --pull --target public --build-arg BASE_IMAGE=${BASE_IMAGE} \
	--build-arg https_proxy=${HTTPS_PROXY} \
	--build-arg http_proxy=${HTTP_PROXY} \
	-t ${PUBLIC_IMAG} .
	docker push ${PUBLIC_IMAG}

_exec:
	docker exec -it ${CONTRAINER_NAME} zsh

_exec_root:
	docker exec -itu 0 ${CONTRAINER_NAME} zsh

_instantiate_container: 
	touch ${HOME}/.netrc
	touch ${HOME}/.zsh_history
	if [ ! -d ${HOME}/project ]; then \
		mkdir -p ${HOME}/project;fi 
	if [ ! -d ${HOME}/vscode/vscode-server ]; then \
		mkdir -p ${HOME}/vscode/vscode-server;fi 
	if [ ! -d ${HOME}/vscode/vscode-remote-containers ]; then \
		mkdir -p ${HOME}/vscode/vscode-remote-containers; fi 
	if ! docker container ls | grep -w ${CONTRAINER_NAME}; then \
		docker run -itd --rm --shm-size=100g \
			-v ${SHARE_DIR}:${SHARE_DIR} \
			-v ${HOME}/.netrc:${HOME}/.netrc \
			-v ${HOME}/.zsh_history:${HOME}/.zsh_history \
			-v ${PROJ_DIR}:${HOME}/project \
			-v ${HOME}/vscode/vscode-server:${HOME}/.vscode-server \
			-v ${HOME}/vscode/vscode-remote-containers:${HOME}/.vscode-remote-containers \
			--user ${_USER} \
			--name ${CONTRAINER_NAME} --gpus all $(PRIVATE_IMAGE); \
	fi; \

_pull:
	if ! docker pull ${PRIVATE_IMAGE}; then \
		echo "pull ${PRIVATE_IMAGE} failed, try building private image first"; \
		${MAKE} --no-print-directory build_private; \
	fi

# attach is dangerous, exit from attached shell will terminate the container
_attach:
	docker attach ${CONTRAINER_NAME}




_setup_sshkey:
	if [ -e asset/ssh/id_rsa ] && [ -e asset/ssh/id_rsa.pub ]; then \
		echo "sshkey exists, use default key";\
	else \
		if [ ! -e ~/.ssh/id_rsa ] || [ ! -e ~/.ssh/id_rsa.pub ]; then \
			echo "sshkey don't exist, try generating it"; \
			ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""; \
			echo new sshkey generated; \
		fi; \
		mkdir -p asset/ssh; \
		cp ~/.ssh/id_rsa asset/ssh/id_rsa; \
		cp ~/.ssh/id_rsa.pub asset/ssh/id_rsa.pub; \
		echo To grant access to your github account, make sure to copy the content in [~/.ssh/id_rsa.pub] to github:;\
		cat ~/.ssh/id_rsa.pub; \
	fi

_setup_gitconfig:
	if [ -e /asset/gitconfig ]; then \
		echo "gitconfig exists, use default gitconfig"; \
	else \
		if [ ! -e ~/.gitconfig ]; then \
			echo "gitconfig don't exist, try configure it"; \
			read -p "(no space and special character allowed) Enter github username: " GIT_NAME; \
			read -p "(must be your real github account) Enter github email: " GIT_EMAIL; \
			git config --global user.name $${GIT_NAME:-${PROJECT_NAME}}; \
			git config --global user.email $${GIT_EMAIL:-${PROJECT_NAME}@gmail.com}; \
		fi; \
		cp ~/.gitconfig asset/gitconfig; \
	fi
	

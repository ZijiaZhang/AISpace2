NODE_VERSION=8
PYTHON_VERIONS=3.7.4
IMAGE=node:$(NODE_VERSION)
WORK_DIR=/opt/AISpace2
CURRDIR = $(shell python -c "import os; print(os.path.abspath(os.getcwd()))")

clean:
	-docker rm -f AISpace2
	-docker rmi aispace2

docker-setup:
	docker pull $(IMAGE)
	docker run -it \
		--name AISpace2\
		-v $(CURRDIR):$(WORK_DIR) \
		-p 8080:80 \
		--workdir $(WORK_DIR) \
		$(IMAGE) \
		make install-dep
	docker commit AISpace2 aispace2
	docker rm AISpace2

docker-run:
	docker run --rm -it \
		-v $(CURRDIR):$(WORK_DIR) \
		-p 8080:80 \
		--workdir $(WORK_DIR) \
		aispace2 \
		make run

	

install-dep:
	apt-get update
	apt-get install python3
	curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
	python3 get-pip.py
	pip install -U pip
	pip install --upgrade pip-tools pip
	pip install jupyterlab==1.0.2
	pip install ipywidgets
	pip install -e .
	npm install --prefix js
	jupyter labextension install @jupyter-widgets/jupyterlab-manager@1.0 --no-build
	npm run update-lab-extension --prefix js
	jupyter labextension install js --no-build
	jupyter lab build
	#jupyter lab --no-browser --port 80 --ip 0.0.0.0 --allow-root --LabApp.token=''
	#bash

run:
	jupyter lab --no-browser --port 80 --ip 0.0.0.0 --allow-root --LabApp.token=''
	exit

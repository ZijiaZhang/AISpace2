NODE_VERSION=10
PYTHON_VERIONS=3.5
IMAGE=node
WORK_DIR=/app/AISpace2
CURRDIR = $(shell python -c "import os; print(os.path.abspath(os.getcwd()))")

.PHONY: clean
clean:
	docker rm -f AISpace2 || true
	docker rmi aispace2 || true
	rm -rf ./AISpace2 || true
.PHONY: clone
clone:
	git clone https://github.com/AISpace2/AISpace2.git
	cp ./Makefile ./AISpace2/Makefile
	cp ./forceInstall.sh ./AISpace2/installScripts/forceInstall.sh

.PHONY: docker-setup
docker-setup: clone
	docker pull $(IMAGE):$(NODE_VERSION)
	docker run -it \
		--name AISpace2\
		-v $(CURRDIR)/AISpace2:$(WORK_DIR) \
		-p 8888:8888 \
		--workdir $(WORK_DIR) \
		$(IMAGE):$(NODE_VERSION) \
		make install-dep
	docker commit AISpace2 aispace2
	docker rm AISpace2

.PHONY: docker-force-setup
docker-force-setup: clone
	docker pull $(IMAGE):$(NODE_VERSION)
	docker run -it \
                --name AISpace2\
                -v $(CURRDIR)/AISpace2:$(WORK_DIR) \
                -p 8888:8888 \
                --workdir $(WORK_DIR) \
                $(IMAGE):$(NODE_VERSION) \
                make install-force-dep
	docker commit AISpace2 aispace2
	docker rm AISpace2

.PHONY: docker-run
docker-run:
	docker run --rm -it \
		-v $(CURRDIR)/AISpace2:$(WORK_DIR) \
		-p 8080:80 \
		--workdir $(WORK_DIR) \
		aispace2 \
		jupyter lab --no-browser --port 80 --ip 0.0.0.0 --allow-root --LabApp.token='' && exit

.PHONY: install-dep
install-dep:
	apt-get update
	apt-get -y install python3.5-dev
	curl  https://bootstrap.pypa.io/pip/3.5/get-pip.py -o get-pip.py
	python3 get-pip.py
	pip install -U pip
	echo 'yyy' | sh $(WORK_DIR)/installScripts/installScripts.sh || echo "1"

.PHONY: install-force-dep
install-force-dep:
	apt-get update
	apt-get -y install python3.5-dev
	curl  https://bootstrap.pypa.io/pip/3.5/get-pip.py -o get-pip.py
	python3 get-pip.py
	pip install -U pip
	echo 'yyy' | sh $(WORK_DIR)/installScripts/forceInstall.sh || true

.PHONY: run
run:
	jupyter lab --no-browser --port 80 --ip 0.0.0.0 --allow-root --LabApp.token=''
	exit

NODE_VERSION=10
PYTHON_VERIONS=3.5
IMAGE=node:$(NODE_VERSION)
WORK_DIR=/app/AISpace2
CURRDIR = $(shell python -c "import os; print(os.path.abspath(os.getcwd()))")

clean:
	docker rm -f AISpace2
	docker rmi aispace2

clone:
	git clone https://github.com/AISpace2/AISpace2.git
	cp ./Makefile ./AISpace2/Makefile

docker-setup:
	docker pull $(IMAGE)
	docker run -it \
		--name AISpace2\
		-v $(CURRDIR)/AISpace2:$(WORK_DIR) \
		-p 8888:8888 \
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
		jupyter lab --no-browser --port 80 --ip 0.0.0.0 --allow-root --LabApp.token='' && exit

	

install-dep:
	apt-get update
	apt-get -y install python3.5-dev
	curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
	python3 get-pip.py
	pip install -U pip
	cd AISpace2 && 'yyy' | sh $(WORK_DIR)/installScripts/installScripts.sh || echo "1"

run:
	jupyter lab --no-browser --port 80 --ip 0.0.0.0 --allow-root --LabApp.token=''
	exit

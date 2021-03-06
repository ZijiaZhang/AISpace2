
cd "$(dirname "$0")"
read -n1 -r -p "Make sure you have installed pip and Node.js.`echo $'\nPress any key to continue ...'`"
cd ..
echo Installing jupyterlab ...
pip3 install jupyterlab==2.2.9
echo Installing ipywidgets ...
pip3 install ipywidgets==7.5.1
echo Installing AISpace2 library ...
cd js
npm install
cd ..
pip3 install -r requirements-dev.txt
pip3 install -e .
echo Installing Jupyter labextension ...
export NODE_OPTIONS=--max_old_space_size=3000
jupyter labextension install @jupyter-widgets/jupyterlab-manager@2
cd js
echo Building AISpace2 frontend ...
npm run update-lab-extension
jupyter labextension install
cd ..
jupyter lab

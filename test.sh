# Run as:
# docker run galpine sh -c "$(cat test.sh)"

CONDA_VERSION="4.7.12.1"
CONDA_DIR="/opt/conda"
PATH="$CONDA_DIR/bin:$PATH"
PYTHONDONTWRITEBYTECODE=1
apk add --no-cache bash ca-certificates wget
mkdir -p "$CONDA_DIR"
wget "http://repo.continuum.io/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh" -O miniconda.sh
bash miniconda.sh -f -b -p "$CONDA_DIR"
echo "export PATH=$CONDA_DIR/bin:\$PATH" > /etc/profile.d/conda.sh
conda update --all --yes
conda config --set auto_update_conda False
rm -f miniconda.sh
conda clean --all --force-pkgs-dirs --yes
find "$CONDA_DIR" -follow -type f \( -iname '*.a' -o -iname '*.pyc' -o -iname '*.js.map' \) -delete
mkdir -p "$CONDA_DIR/locks"
chmod 777 "$CONDA_DIR/locks"

conda config --add channels conda-forge
conda install -y numpy
python -c 'import numpy as np; print(np.array([0, 1, 2]).tolist())'

echo "¯\_(ツ)_/¯"

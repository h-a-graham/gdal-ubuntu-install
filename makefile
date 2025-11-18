.PHONY: all cleanup install apt-install

all: cleanup install

cleanup:
		bash gdal-cleanup.sh

install:
		bash gdal-install.sh

apt-install:
		bash gdal-apt-install.sh
# Contains functions that should work on all POSIX-compliant systems
function create_db_dir {
	mkdir -p $1
	chown electrumx-grs:electrumx-grs $1
}

function check_pyrocksdb {
    python3 -B -c "import rocksdb"
}

function install_electrumx {
	_DIR=$(pwd)
	rm -rf "/tmp/electrumx-grs/"
	git clone $ELECTRUMX_GIT_URL /tmp/electrumx-grs
	cd /tmp/electrumx-grs
        git checkout $ELECTRUMX_GIT_BRANCH
  if [ $USE_ROCKSDB == 1 ]; then
		# We don't necessarily want to install plyvel
		sed -i "s/'plyvel',//" setup.py
	fi
	python3 -m pip install . --upgrade > /dev/null 2>&1
	if ! python3 -m pip install . --upgrade; then
		_error "Unable to install electrumx-grs" 7
	fi
	cd $_DIR
}

function install_pip {
	wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
	python3 /tmp/get-pip.py
	rm /tmp/get-pip.py
}

function install_pyrocksdb {
	python3 -m pip install "Cython>=0.20"
	python3 -m pip install git+git://github.com/stephan-hof/pyrocksdb.git || _error "Could not install pyrocksdb" 1
}

function install_python_rocksdb {
        python3 -m pip install "Cython>=0.20"
	python3 -m pip install python-rocksdb || _error "Could not install python_rocksdb" 1
}

function add_user {
	useradd electrumx-grs
	id -u electrumx-grs || _error "Could not add user account" 1
}

function generate_cert {
	if ! which openssl > /dev/null 2>&1; then
		_info "OpenSSL not found. Skipping certificates.."
		return
	fi
	_DIR=$(pwd)
	mkdir -p /etc/electrumx-grs/
	cd /etc/electrumx-grs
	openssl genrsa -des3 -passout pass:xxxx -out server.pass.key 2048
	openssl rsa -passin pass:xxxx -in server.pass.key -out server.key
	rm server.pass.key
	openssl req -new -key server.key -batch -out server.csr
	openssl x509 -req -days 1825 -in server.csr -signkey server.key -out server.crt
	rm server.csr
	chown electrumx-grs:electrumx-grs /etc/electrumx-grs -R
	chmod 600 /etc/electrumx-grs/server*
	cd $_DIR
	echo -e "\nSSL_CERTFILE=/etc/electrumx-grs/server.crt" >> /etc/electrumx-grs.conf
	echo "SSL_KEYFILE=/etc/electrumx-grs/server.key" >> /etc/electrumx-grs.conf
        echo "TCP_PORT=50001" >> /etc/electrumx-grs.conf
        echo "SSL_PORT=50002" >> /etc/electrumx-grs.conf
        echo -e "# Listen on all interfaces:\nHOST=" >> /etc/electrumx-grs.conf
}

function ver { printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' '); }

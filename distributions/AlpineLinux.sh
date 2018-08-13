ERROR_EDGE="electrumX-grs can currently be installed only on the edge Version of Alpine Linux"
grep -q -F "/edge/main" /etc/apk/repositories > /dev/null || _error "${ERROR_EDGE}"
grep -q -F "/edge/community" /etc/apk/repositories > /dev/null || _error "${ERROR_EDGE}"

. distributions/base.sh

APK="apk --no-cache"

function install_script_dependencies {
	REPO="http://dl-cdn.alpinelinux.org/alpine/edge/testing"
	grep -q -F "${REPO}" /etc/apk/repositories || echo "${REPO}" >> /etc/apk/repositories
	apk update
	$APK add --virtual electrumX-dep openssl wget gcc g++
}

function add_user {
	adduser -D electrumx-grs
	id -u electrumx-grs || _error "Could not add user account" 1
}

function install_python37 {
	_error "Please install Python 3.7 manually"
}

function install_git {
	$APK add --virtual electrumX-grs-git git
}

function install_compiler {
	$APK add gcc
}

function install_rocksdb {
	$APK add rocksdb
	$APK add --virtual electrumX-grs-db rocksdb-dev
}

function install_leveldb {
	$APK add leveldb
}

function install_init {
	# init is not required. Alpine is used for containers running the program directly
	:
}

function generate_cert {
	if ! which openssl > /dev/null 2>&1; then
		_info "OpenSSL not found. Skipping certificates.."
		return
	fi
	_DIR=$(pwd)
	mkdir -p /etc/electrumx-grs/
	cd /etc/electrumx-grs
	# openssl default configuration is incomplet under alpine.
	# Hence adding this configruation from archlinux to allow certificat creation
	# https://www.archlinux.org/packages/core/x86_64/openssl/
	echo "[ req ]
distinguished_name	= req_distinguished_name

[ req_distinguished_name ]
countryName_default		= AU
stateOrProvinceName_default	= Some-State
0.organizationName_default	= Internet Widgits Pty Ltd" > openssl.cnf
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

function package_cleanup {
	$APK del electrumX-grs-dep electrumX-grs-python electrumX-grs-git electrumX-grs-db
}

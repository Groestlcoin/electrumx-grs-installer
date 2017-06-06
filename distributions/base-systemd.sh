function install_init {
	if [ ! -d /etc/systemd/system ]; then
		_error "/etc/systemd/system does not exist. Is systemd installed?" 8
	fi
	cp /tmp/electrumx-grs/contrib/systemd/electrumx-grs.service /etc/systemd/system/electrumx-grs.service
	cp /tmp/electrumx-grs/contrib/systemd/electrumx-grs.conf /etc/
	if [ $USE_ROCKSDB == 1 ]; then
		echo -e "\nDB_ENGINE=rocksdb" >> /etc/electrumx-grs.conf
	fi
	systemctl daemon-reload
	systemctl enable electrumx-grs
	systemctl status electrumx-grs
	_info "Use service electrumx-grs start to start electrumx-grs once it's configured"
}

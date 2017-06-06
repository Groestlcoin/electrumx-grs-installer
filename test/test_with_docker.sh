#!/bin/bash
echo "docker run -v $(pwd)/..:/root/electrumx-grs-installer $IMAGE /root/electrumx-grs-installer/test/test.sh"
docker run -v $(pwd)/..:/root/electrumx-grs-installer $IMAGE /root/electrumx-grs-installer/test/test.sh 2>&1 | tee /root/$$.log
if grep -q "ElectrumX-GRS server starting" /root/$$.log; then
    echo "Success"
    exit 0
fi
exit 1

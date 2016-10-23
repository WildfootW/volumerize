#!/bin/bash

set -o errexit

readonly VOLUMERIZE_SCRIPT_DIR=$VOLUMERIZE_HOME

source $CUR_DIR/base.sh

readonly PARAMETER_PROXY='$@'

cat > ${VOLUMERIZE_SCRIPT_DIR}/backup <<_EOF_
#!/bin/bash

set -o errexit

source ${VOLUMERIZE_SCRIPT_DIR}/stopContainers
${DUPLICITY_COMMAND} incremental ${PARAMETER_PROXY} ${DUPLICITY_OPTIONS} ${VOLUMERIZE_INCUDES} ${VOLUMERIZE_SOURCE} ${VOLUMERIZE_TARGET}
source ${VOLUMERIZE_SCRIPT_DIR}/startContainers
_EOF_

cat > ${VOLUMERIZE_SCRIPT_DIR}/backupFull <<_EOF_
#!/bin/bash

set -o errexit

source ${VOLUMERIZE_SCRIPT_DIR}/stopContainers
${DUPLICITY_COMMAND} full ${PARAMETER_PROXY} ${DUPLICITY_OPTIONS} ${VOLUMERIZE_INCUDES} ${VOLUMERIZE_SOURCE} ${VOLUMERIZE_TARGET}
source ${VOLUMERIZE_SCRIPT_DIR}/startContainers
_EOF_

cat > ${VOLUMERIZE_SCRIPT_DIR}/restore <<_EOF_
#!/bin/bash

set -o errexit

source ${VOLUMERIZE_SCRIPT_DIR}/stopContainers
${DUPLICITY_COMMAND} restore --force ${PARAMETER_PROXY} ${DUPLICITY_OPTIONS} ${VOLUMERIZE_INCUDES} ${VOLUMERIZE_TARGET} ${VOLUMERIZE_SOURCE}
source ${VOLUMERIZE_SCRIPT_DIR}/startContainers
_EOF_

cat > ${VOLUMERIZE_SCRIPT_DIR}/verify <<_EOF_
#!/bin/bash

set -o errexit

exec ${DUPLICITY_COMMAND} verify --compare-data ${PARAMETER_PROXY} ${DUPLICITY_OPTIONS} ${VOLUMERIZE_INCUDES} ${VOLUMERIZE_TARGET} ${VOLUMERIZE_SOURCE}
_EOF_

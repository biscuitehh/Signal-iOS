#!/bin/bash

# This allows us to pass in our configuration values from the environment instead of the command line (useful for CI)
DETECT_ARGUMENTS=""

# URL Endpoint
if [[ -z "${BD_URL}" ]]; then
  echo "You need to set an API endpoint in order to scan a project. Exiting ..."
  exit 1
else
  DETECT_ARGUMENTS="--blackduck.url=${BD_URL}"
fi

# API Token
if [[ -z "${BD_API_TOKEN}" ]]; then
  echo "You need to set an API token in order to scan a project. Exiting ..."
  exit 1
else
  DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --blackduck.api.token=${BD_API_TOKEN}"
fi

# Project Name
if [[ -z "${BD_PROJECT_NAME}" ]]; then
  echo "You need to set a project name in order to scan a project. Exiting ..."
  exit 1
else
  DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --detect.project.name=${BD_PROJECT_NAME}"
fi

# Project Version
if [[ -z "${BD_PROJECT_VERSION}" ]]; then
  echo "You need to set a project version in order to scan a project. Exiting ..."
  exit 1
else
  DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --detect.project.version.name=${BD_PROJECT_VERSION}"
fi

# Logging
if [[ -z "${BD_LOGGING}" ]]; then
  echo "Logging level not specified - defaulting to INFO!"
  DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --logging.level.com.synopsys.integration=INFO"
else
  DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --logging.level.com.synopsys.integration=${BD_LOGGING}"
fi

# Detector override
if [[ -z "${BD_DETECTORS}" ]]; then
  echo "Detectors not specified - this may result in a noisy scan!"
else
  DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --detect.included.detector.types=${BD_DETECTORS}"
fi

# Risk reporting
if [[ "${BD_RISK_REPORT}" != false ]]; then
  DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --detect.risk.report.pdf=true"

  # Risk report path
  # Detector override
  if [[ -z "${BD_DETECTORS}" ]]; then
    echo "Risk report not specified - using `.`!"
    DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --detect.risk.report.pdf.path=\".\""
  else
    DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --detect.risk.report.pdf.path=${BD_RISK_REPORT_PATH}"
  fi
fi

# Signature scanning
if [[ "${BD_USE_SIGNATURE_SCANNER}" != false ]]; then
  DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --detect.tools=DETECTOR,SIGNATURE_SCAN"
else
  DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --detect.tools=DETECTOR"
  DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --detect.tools.excluded=SIGNATURE_SCAN"
fi

# Detector override
if [[ -z "${BD_FAIL_ON_POLICY}" ]]; then
  echo "No policy failure check - this build will not fail because of library policy violations!"
else
  DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --detect.policy.check.fail.on.severities=${BD_FAIL_ON_POLICY}"
fi

# Fuse some naming properties together (these shouldn't change formatting)
BD_UNIQUE_NAME="${BD_PROJECT_NAME}_${BD_PROJECT_VERSION}"
DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --detect.code.location.name=${BD_UNIQUE_NAME}"
DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --detect.bom.aggregate.name=${BD_UNIQUE_NAME}_BOM"

# Other options to set
DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --blackduck.offline.mode=false"
DETECT_ARGUMENTS="${DETECT_ARGUMENTS} --detect.project.codelocation.delete.old.names=true"

# echo $DETECT_ARGUMENTS
# exit;
# Bitbake,Cocoapods,Conda,Cpan

# DETECT_LATEST_RELEASE_VERSION should be set in your
# environment if you wish to use a version different
# from LATEST.
DETECT_RELEASE_VERSION=${DETECT_LATEST_RELEASE_VERSION}

# To override the default version key, specify a
# different DETECT_VERSION_KEY in your environment and
# *that* key will be used to get the download url from
# artifactory. These DETECT_VERSION_KEY values are
# properties in Artifactory that resolve to download
# urls for the detect jar file. As of 2019-04-26, the
# available DETECT_VERSION_KEY values are:
# DETECT_LATEST, DETECT_LATEST_4, DETECT_LATEST_5
# Every new major version of detect will have its own
# DETECT_LATEST_X key.
DETECT_VERSION_KEY=${DETECT_VERSION_KEY:-DETECT_LATEST}

# You can specify your own download url from
# artifactory which can bypass using the property keys
# (this is mainly for QA purposes only)
DETECT_SOURCE=${DETECT_SOURCE:-}

# To override the default location of /tmp, specify
# your own DETECT_JAR_DOWNLOAD_DIR in your environment and
# *that* location will be used.
# *NOTE* We currently do not support spaces in the
# DETECT_JAR_DOWNLOAD_DIR.
DETECT_JAR_DOWNLOAD_DIR=${DETECT_JAR_DOWNLOAD_DIR:-/tmp}

# If you want to pass any java options to the
# invocation, specify DETECT_JAVA_OPTS in your
# environment. For example, to specify a 6 gigabyte
# heap size, you would set DETECT_JAVA_OPTS=-Xmx6G.
DETECT_JAVA_OPTS=${DETECT_JAVA_OPTS:-}

# If you want to pass any additional options to
# curl, specify DETECT_CURL_OPTS in your environment.
# For example, to specify a proxy, you would set
# DETECT_CURL_OPTS=--proxy http://myproxy:3128
DETECT_CURL_OPTS=${DETECT_CURL_OPTS:-}

# If you only want to download the appropriate jar file set
# this to 1 in your environment. This can be useful if you
# want to invoke the jar yourself but do not want to also
# get and update the jar file when a new version releases.
DETECT_DOWNLOAD_ONLY=${DETECT_DOWNLOAD_ONLY:-0}

# Pass our arguments into Hub Detect
SCRIPT_ARGS=$DETECT_ARGUMENTS
# SCRIPT_ARGS="$@"
LOGGABLE_SCRIPT_ARGS=""

echo "Detect Shell Script 2.1.0"

for i in $*; do
  if [[ $i == --blackduck.hub.password=* ]]; then
    LOGGABLE_SCRIPT_ARGS="$LOGGABLE_SCRIPT_ARGS --blackduck.hub.password=<redacted>"
  elif [[ $i == --blackduck.hub.proxy.password=* ]]; then
    LOGGABLE_SCRIPT_ARGS="$LOGGABLE_SCRIPT_ARGS --blackduck.hub.proxy.password=<redacted>"
  elif [[ $i == --blackduck.hub.api.token=* ]]; then
    LOGGABLE_SCRIPT_ARGS="$LOGGABLE_SCRIPT_ARGS --blackduck.hub.api.token=<redacted>"
  elif [[ $i == --blackduck.password=* ]]; then
    LOGGABLE_SCRIPT_ARGS="$LOGGABLE_SCRIPT_ARGS --blackduck.password=<redacted>"
  elif [[ $i == --blackduck.proxy.password=* ]]; then
    LOGGABLE_SCRIPT_ARGS="$LOGGABLE_SCRIPT_ARGS --blackduck.proxy.password=<redacted>"
  elif [[ $i == --blackduck.api.token=* ]]; then
    LOGGABLE_SCRIPT_ARGS="$LOGGABLE_SCRIPT_ARGS --blackduck.api.token=<redacted>"
  elif [[ $i == --polaris.access.token=* ]]; then
    LOGGABLE_SCRIPT_ARGS="$LOGGABLE_SCRIPT_ARGS --polaris.access.token=<redacted>"
  else
    LOGGABLE_SCRIPT_ARGS="$LOGGABLE_SCRIPT_ARGS $i"
  fi
done

run() {
  get_detect
  if [ $DETECT_DOWNLOAD_ONLY -eq 0 ]; then
    run_detect
  fi
}

get_detect() {
  if [ -z "${DETECT_SOURCE}" ]; then
    if [ -z "${DETECT_RELEASE_VERSION}" ]; then
      VERSION_CURL_CMD="curl ${DETECT_CURL_OPTS} --silent --header \"X-Result-Detail: info\" 'https://repo.blackducksoftware.com/artifactory/api/storage/bds-integrations-release/com/synopsys/integration/synopsys-detect?properties=${DETECT_VERSION_KEY}' | grep \"${DETECT_VERSION_KEY}\" | sed 's/[^[]*[^\"]*\"\([^\"]*\).*/\1/'"
      DETECT_SOURCE=$(eval $VERSION_CURL_CMD)
    else
      DETECT_SOURCE="https://repo.blackducksoftware.com/artifactory/bds-integrations-release/com/synopsys/integration/synopsys-detect/${DETECT_RELEASE_VERSION}/synopsys-detect-${DETECT_RELEASE_VERSION}.jar"
    fi
  fi

  if [ -z "${DETECT_SOURCE}" ]; then
    echo "DETECT_SOURCE was not set or computed correctly, please check your configuration and environment."
    exit -1
  fi

  echo "will look for : ${DETECT_SOURCE}"

  DETECT_FILENAME=${DETECT_FILENAME:-$(awk -F "/" '{print $NF}' <<< $DETECT_SOURCE)}
  DETECT_DESTINATION="${DETECT_JAR_DOWNLOAD_DIR}/${DETECT_FILENAME}"

  USE_REMOTE=1
  if [ ! -f $DETECT_DESTINATION ]; then
    echo "You don't have the current file, so it will be downloaded."
  else
    echo "You have already downloaded the latest file, so the local file will be used."
    USE_REMOTE=0
  fi

  if [ $USE_REMOTE -eq 1 ]; then
    echo "getting ${DETECT_SOURCE} from remote"
    curlReturn=$(curl $DETECT_CURL_OPTS --silent -w "%{http_code}" -L -o $DETECT_DESTINATION "${DETECT_SOURCE}")
    if [ 200 -eq $curlReturn ]; then
      echo "saved ${DETECT_SOURCE} to ${DETECT_DESTINATION}"
    else
      echo "The curl response was ${curlReturn}, which is not successful - please check your configuration and environment."
      exit -1
    fi
  fi
}

run_detect() {
  JAVACMD="java ${DETECT_JAVA_OPTS} -jar ${DETECT_DESTINATION}"
  echo "running Detect: ${JAVACMD} ${LOGGABLE_SCRIPT_ARGS}"

  # first, silently delete (-f ignores missing
  # files) any existing shell script, then create
  # the one we will run
  rm -f $DETECT_JAR_DOWNLOAD_DIR/hub-detect-java.sh
  echo "#!/bin/sh" > $DETECT_JAR_DOWNLOAD_DIR/hub-detect-java.sh
  echo "" >> $DETECT_JAR_DOWNLOAD_DIR/hub-detect-java.sh
  echo $JAVACMD $SCRIPT_ARGS >> $DETECT_JAR_DOWNLOAD_DIR/hub-detect-java.sh
  source $DETECT_JAR_DOWNLOAD_DIR/hub-detect-java.sh
  RESULT=$?
  echo "Result code of ${RESULT}, exiting"
  exit $RESULT
}

run

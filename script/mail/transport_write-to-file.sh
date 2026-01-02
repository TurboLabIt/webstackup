#!/bin/bash
FILENAME=/var/log/webstackup-email_transport_write-to-file.log
echo "--- START OF MESSAGE ---" >> "${FILENAME}"
cat >> "${FILENAME}"
echo "--- END OF MESSAGE ---" >> "${FILENAME}"
echo "" >> "${FILENAME}"

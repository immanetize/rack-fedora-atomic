#!/usr/bin/env bash

set -e

# See: https://bugzilla.redhat.com/show_bug.cgi?id=1051816
KEEPLANG=en_US
find /usr/share/locale -mindepth  1 -maxdepth 1 -type d -not -name "${KEEPLANG}" -exec rm -rf {} +
localedef --list-archive | grep -a -v ^"${KEEPLANG}" | xargs localedef --delete-from-archive
mv -f /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl
build-locale-archive

adduser \
  --system \
  --comment "Orchestration and Management Service User" \
  --groups wheel,systemd-journal \
  --shell /usr/bin/bash \
  --uid 427 \
  --gid 427 \
  philotic-agent

mkdir -p /home/philotic-agent/.ssh
cat > /home/philotic-agent/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDmRGqqn5VEucak30lhGVdQtXpLEaSZSkgzSU+XUVshgkMyz6/75XrVWCDjUnmHFV2B59g+eR3mgUjW73GwGxfCee//kawnoQynVcxGVcKPXLr80y9c3QK5CIVT3NT3UTIzmRUCer9ru6DjK4f6cL8t58GzfqyLtruRpsESJ6x92w4oyk1VJgFlbPL/L7mmGUr/1ZJuc+mPRFszYrPfPaOgPFyRgdJRKhjaTuO0965MQimtt5IbP6/DEUy7os+17HmuNhwHz8y09xDrmi4GklDqWrouZrsg7PmRNXf/VcWZN3yLq7an0GJFmr/Ob7sy+kJOQrxA2AghY8e2RDCD+V5sZQuwK3XuctVWq2UXEnzcGVZN2uRy3DZ9DHOr/WdOtD+YyQczdHqui4KARyVTLiW5tZab+BSbS3fBdpay1d210DOu0j/WEfTd2JDYDcWfDEqNbF+EMoNoLM5uLoPoJtp0r7a+PABqJplSCDrYR+mNflQCgSwADtAc9mNYvlI7T8mVnqq2QBCPu8Jh+1zCvXCe9BIw/bkUTdT5VF8jy0yLPjUrOY2D4MLLXDNDr0Yjf/KcSrdpdxpArRvJNiGD00A5NLARAw76gOysgW/dPA1zvf+O7dLRXn1HsmCu7k+Vf/z6Sqw4g6L1ZSw2n12Bsswe45AqQKgVF1WbR7k2WIxXqQ== pete@athena
EOF

sed -i -e 's/#?\(PasswordAuthentication\).*/\1 no' /etc/ssh/sshd_config
sed -i -e 's/#?\(PermitRootLogin\).*/\1 no' /etc/ssh/sshd_config

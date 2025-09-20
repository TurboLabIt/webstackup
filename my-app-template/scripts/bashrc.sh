## 🚨 WARNING 🚨
#
# This file is under version control!
# DO NOT EDIT DIRECTLY - If you do, you'll loose your changes!
#
# The original file is in `/var/www/my-app/scripts/`
#
# You MUST:
#
# 1. edit the original file on you PC
# 2. Git-commit+push the changes
# 3. run `sudo bash /var/www/my-app/scripts/deploy.sh`
#
# ⚠️ This file is SHARED among dev|staging|prod ⚠️
#
# 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/bashrc.sh

## this should be sourced from each user .bashrc

# background color per-host
if [[ $- == *i* && -n "$SSH_CONNECTION" ]]; then

    source "/usr/local/turbolab.it/bash-fx/scripts/colors.sh"

    case "$(hostname -s)" in
      my-app.com)
        # very dark red
        fxSetBackgroundColor "#F2F2F2" "#240000"
        ;;
      next.my-app.com)
        # very dark orange
        fxSetBackgroundColor "#F2F2F2" "#241600"
        ;;
    esac

  # Ensure colors go back to default when the shell exits
  trap fxResetBackgroundColor EXIT

fi

cd /var/www/my-app

## if the server hosts multiple projects, go with this 👇🏻 instead
#zzcd

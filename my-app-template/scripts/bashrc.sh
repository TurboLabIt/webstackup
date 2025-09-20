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

## if the server hosts multiple project, go with this 👇🏻
#zzcd

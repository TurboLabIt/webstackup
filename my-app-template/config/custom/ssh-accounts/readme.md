# 👥 ssh-accounts

Create here a sub-folder for each Linux user account you'd want to create every
time `deploy.sh` runs.

* The sub-folder name must be the username to create. Example: `my-new-user`
* Add the user SSH key(s) as `my-new-user/.ssh/authorized_keys` to enable SSH access

⚠️ The user will be a sudoer by default. To prevent this, create a `my-new-user/no-sudoer` file.

🚨 This function is project-specific. If you need to create the same user(s) across multiple projects,
please use `USERS_TEMPLATE_PATH=` and `USERS_TEMPLATE_PATH_STAGING=` (see
https://github.com/TurboLabIt/webstackup/blob/master/script/filesystem/deploy-common.sh )

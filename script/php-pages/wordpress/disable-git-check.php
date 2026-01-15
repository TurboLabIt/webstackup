<?php
/*
  Plugin Name: Enable updates even if .git folder is detected
  Description: Bypasses the VCS check to allow auto-updates even if .git exists.
*/
add_filter('automatic_updates_is_vcs_checkout', '__return_false', 99);

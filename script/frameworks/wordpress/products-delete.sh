#!/usr/bin/env bash
## Delete ALL products from WordPress/WooCommerce by WEBSTACKUP
#
# How to:
#
# 1. Copy the "starter" script to your project directory with:
#   curl -Lo scripts/wordpress-products-delete.sh https://raw.githubusercontent.com/TurboLabIt/webstackup/master/my-app-template/scripts/wordpress-products-delete.sh && sudo chmod u=rwx,go=rx scripts/*.sh
#
# 1. You should now git commit your copy
#
fxHeader "🚨 Delete ALL Woocommerce products"
devOnlyCheck
fxAskConfirmation

cd "${WEBROOT_DIR}"

WPCLI="sudo -u $EXPECTED_USER -H XDEBUG_MODE=off ${PHP_CLI} /usr/local/bin/wp-cli --allow-root"


fxTitle "Deleting products..."
${WPCLI} db query "DELETE relations, meta, posts FROM $(${WPCLI} db prefix)posts posts
  LEFT JOIN $(${WPCLI} db prefix)term_relationships relations ON (posts.ID = relations.object_id)
  LEFT JOIN $(${WPCLI} db prefix)postmeta meta ON (posts.ID = meta.post_id)
  WHERE posts.post_type IN ('product', 'product_variation')"


fxTitle "Deleting Tags..."
${WPCLI} db query "DELETE t, tt, tr
  FROM $(${WPCLI} db prefix)terms AS t
  INNER JOIN $(${WPCLI} db prefix)term_taxonomy AS tt ON t.term_id = tt.term_id
  LEFT JOIN $(${WPCLI} db prefix)term_relationships AS tr ON tr.term_taxonomy_id = tt.term_taxonomy_id
  WHERE tt.taxonomy IN ('product_tag', 'post_tag')"


fxTitle "Reindexing..."
${WPCLI} db query "TRUNCATE TABLE $(${WPCLI} db prefix)wc_product_meta_lookup"
${WPCLI} term recount product_cat product_tag

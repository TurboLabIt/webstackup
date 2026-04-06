#!/usr/bin/env bash
## Export PrestaShop categories to CSV by WEBSTACKUP
#

if [ -z "${PRESTASHOP_STORE_ID}" ]; then
  PRESTASHOP_STORE_ID=1
fi

mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "
SELECT 
    c.id_category AS 'Category ID',
    cl.name AS 'Name',
    c.active AS 'Enabled',
    CONCAT(
        IF(su.domain_ssl != '', CONCAT('https://', su.domain_ssl), CONCAT('http://', su.domain)),
        su.physical_uri,
        su.virtual_uri,
        c.id_category, '-', cl.link_rewrite
    ) AS 'URL',
    sg.name AS 'Shop Group',
    s.name AS 'Shop',
    c.id_parent AS 'Parent ID',
    c.level_depth AS 'Level',
    cs.position AS 'Position',
    (SELECT COUNT(id_category) FROM ps_category WHERE id_parent = c.id_category) AS 'Children Count',
    cl.link_rewrite AS 'URL Key (Slug)',
    CONCAT(
        IF(su.domain_ssl != '', CONCAT('https://', su.domain_ssl), CONCAT('http://', su.domain)),
        su.physical_uri,
        'img/c/', c.id_category, '.jpg'
    ) AS 'Image URL',
    REPLACE(REPLACE(cl.description, CHAR(13), ' '), CHAR(10), ' ') AS 'Description',
    cl.meta_title AS 'Meta Title',
    REPLACE(REPLACE(cl.meta_keywords, CHAR(13), ' '), CHAR(10), ' ') AS 'Meta Keywords',
    REPLACE(REPLACE(cl.meta_description, CHAR(13), ' '), CHAR(10), ' ') AS 'Meta Description',
    c.date_add AS 'Created At',
    c.date_upd AS 'Updated At'
FROM ps_category c
INNER JOIN ps_category_shop cs ON c.id_category = cs.id_category AND cs.id_shop = ${PRESTASHOP_STORE_ID}
INNER JOIN ps_category_lang cl ON c.id_category = cl.id_category AND cl.id_shop = ${PRESTASHOP_STORE_ID} AND cl.id_lang = 1
LEFT JOIN ps_shop s ON cs.id_shop = s.id_shop
LEFT JOIN ps_shop_group sg ON s.id_shop_group = sg.id_shop_group
LEFT JOIN ps_shop_url su ON s.id_shop = su.id_shop AND su.main = 1
WHERE c.level_depth > 0
ORDER BY c.id_category ASC;
" > prestashop_store${PRESTASHOP_STORE_ID}_categories_export.tsv

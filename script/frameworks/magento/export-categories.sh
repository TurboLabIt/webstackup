#!/usr/bin/env bash
## Export Magento 1.9 categories to CSV by WEBSTACKUP
#

if [ -z "${MAGENTO_STOREVIEW}" ]; then
  MAGENTO_STOREVIEW=1
fi

mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "
-- 1. Define target store dynamically using the Bash variable
SET @target_store = ${MAGENTO_STOREVIEW};

-- 2. Pre-calculate the exact Names and Domains ONCE
SET @root_cat = (SELECT csg.root_category_id FROM core_store cs JOIN core_store_group csg ON cs.group_id = csg.group_id WHERE cs.store_id = @target_store LIMIT 1);
SET @web_name = (SELECT cw.name FROM core_store cs JOIN core_website cw ON cs.website_id = cw.website_id WHERE cs.store_id = @target_store LIMIT 1);
SET @group_name = (SELECT csg.name FROM core_store cs JOIN core_store_group csg ON cs.group_id = csg.group_id WHERE cs.store_id = @target_store LIMIT 1);
SET @view_name = (SELECT name FROM core_store WHERE store_id = @target_store LIMIT 1);

SET @domain_web = (SELECT value FROM core_config_data ccd JOIN core_store cs ON ccd.scope_id = cs.website_id WHERE cs.store_id = @target_store AND ccd.scope = 'websites' AND ccd.path = 'web/unsecure/base_url' LIMIT 1);
SET @domain_def = (SELECT value FROM core_config_data WHERE path = 'web/unsecure/base_url' AND scope = 'default' LIMIT 1);
SET @final_domain = COALESCE(@domain_web, @domain_def, '');

-- 3. Run the lean export
SELECT 
    e.entity_id AS 'Category ID',
    COALESCE(
        MAX(IF(a.attribute_code = 'name' AND v.store_id = @target_store, v.value, NULL)), 
        MAX(IF(a.attribute_code = 'name' AND v.store_id = 0, v.value, NULL))
    ) AS 'Name',
    IFNULL(COALESCE(
        MAX(IF(a.attribute_code = 'is_active' AND i.store_id = @target_store, i.value, NULL)), 
        MAX(IF(a.attribute_code = 'is_active' AND i.store_id = 0, i.value, NULL))
    ), 0) AS 'Enabled',
    CONCAT(
        @final_domain, 
        COALESCE(
            MAX(IF(a.attribute_code = 'url_path' AND v.store_id = @target_store, v.value, NULL)), 
            MAX(IF(a.attribute_code = 'url_path' AND v.store_id = 0, v.value, NULL))
        )
    ) AS 'URL',
    @web_name AS 'Websites',
    @group_name AS 'Stores',
    @view_name AS 'Store Views',
    e.parent_id AS 'Parent ID',
    e.level AS 'Level',
    e.path AS 'Path',
    e.position AS 'Position',
    e.children_count AS 'Children Count',
    COALESCE(
        MAX(IF(a.attribute_code = 'include_in_menu' AND i.store_id = @target_store, i.value, NULL)), 
        MAX(IF(a.attribute_code = 'include_in_menu' AND i.store_id = 0, i.value, NULL))
    ) AS 'Include in Menu',
    COALESCE(
        MAX(IF(a.attribute_code = 'is_anchor' AND i.store_id = @target_store, i.value, NULL)), 
        MAX(IF(a.attribute_code = 'is_anchor' AND i.store_id = 0, i.value, NULL))
    ) AS 'Is Anchor',
    COALESCE(
        MAX(IF(a.attribute_code = 'url_key' AND v.store_id = @target_store, v.value, NULL)), 
        MAX(IF(a.attribute_code = 'url_key' AND v.store_id = 0, v.value, NULL))
    ) AS 'URL Key',
    CONCAT(
        @final_domain, 
        'media/catalog/category/', 
        COALESCE(
            MAX(IF(a.attribute_code = 'image' AND v.store_id = @target_store, v.value, NULL)), 
            MAX(IF(a.attribute_code = 'image' AND v.store_id = 0, v.value, NULL))
        )
    ) AS 'Image URL',
    REPLACE(REPLACE(
        COALESCE(
            MAX(IF(a.attribute_code = 'description' AND t.store_id = @target_store, t.value, NULL)), 
            MAX(IF(a.attribute_code = 'description' AND t.store_id = 0, t.value, NULL))
        ), CHAR(13), ' '), CHAR(10), ' ') AS 'Description',
    COALESCE(
        MAX(IF(a.attribute_code = 'meta_title' AND v.store_id = @target_store, v.value, NULL)), 
        MAX(IF(a.attribute_code = 'meta_title' AND v.store_id = 0, v.value, NULL))
    ) AS 'Meta Title',
    REPLACE(REPLACE(
        COALESCE(
            MAX(IF(a.attribute_code = 'meta_keywords' AND t.store_id = @target_store, t.value, NULL)), 
            MAX(IF(a.attribute_code = 'meta_keywords' AND t.store_id = 0, t.value, NULL))
        ), CHAR(13), ' '), CHAR(10), ' ') AS 'Meta Keywords',
    REPLACE(REPLACE(
        COALESCE(
            MAX(IF(a.attribute_code = 'meta_description' AND t.store_id = @target_store, t.value, NULL)), 
            MAX(IF(a.attribute_code = 'meta_description' AND t.store_id = 0, t.value, NULL))
        ), CHAR(13), ' '), CHAR(10), ' ') AS 'Meta Description',
    COALESCE(
        MAX(IF(a.attribute_code = 'display_mode' AND v.store_id = @target_store, v.value, NULL)), 
        MAX(IF(a.attribute_code = 'display_mode' AND v.store_id = 0, v.value, NULL))
    ) AS 'Display Mode',
    COALESCE(
        MAX(IF(a.attribute_code = 'landing_page' AND i.store_id = @target_store, i.value, NULL)), 
        MAX(IF(a.attribute_code = 'landing_page' AND i.store_id = 0, i.value, NULL))
    ) AS 'CMS Block ID',
    e.created_at AS 'Created At',
    e.updated_at AS 'Updated At'
FROM catalog_category_entity e
LEFT JOIN catalog_category_entity_varchar v ON e.entity_id = v.entity_id AND v.store_id IN (0, @target_store)
LEFT JOIN catalog_category_entity_int i ON e.entity_id = i.entity_id AND i.store_id IN (0, @target_store)
LEFT JOIN catalog_category_entity_text t ON e.entity_id = t.entity_id AND t.store_id IN (0, @target_store)
LEFT JOIN eav_attribute a ON a.attribute_id IN (v.attribute_id, i.attribute_id, t.attribute_id)
WHERE e.level > 0
AND (e.path LIKE CONCAT('1/', @root_cat, '/%') OR e.entity_id = @root_cat)
GROUP BY e.entity_id;
" > magento_storeview${MAGENTO_STOREVIEW}_categories_export.tsv

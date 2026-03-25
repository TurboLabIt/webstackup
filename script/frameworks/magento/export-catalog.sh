#!/usr/bin/env bash
## Export Magento 1.9 categories and products to CSVs by WEBSTACKUP
#

if [ -z "${MAGENTO_STOREVIEW}" ]; then
  MAGENTO_STOREVIEW=1
fi


## CATEGORIES
mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "
SET SESSION group_concat_max_len = 999999999;

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


## PRODUCTS
mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "
SET SESSION group_concat_max_len = 999999999;

-- 1. Define target store
SET @target_store = ${MAGENTO_STOREVIEW};

-- 2. Pre-calculate the exact Names, Domains, and Tax Settings ONCE
SET @web_id = (SELECT website_id FROM core_store WHERE store_id = @target_store LIMIT 1);
SET @web_name = (SELECT cw.name FROM core_store cs JOIN core_website cw ON cs.website_id = cw.website_id WHERE cs.store_id = @target_store LIMIT 1);
SET @group_name = (SELECT csg.name FROM core_store cs JOIN core_store_group csg ON cs.group_id = csg.group_id WHERE cs.store_id = @target_store LIMIT 1);
SET @view_name = (SELECT name FROM core_store WHERE store_id = @target_store LIMIT 1);

SET @domain_web = (SELECT value FROM core_config_data ccd JOIN core_store cs ON ccd.scope_id = cs.website_id WHERE cs.store_id = @target_store AND ccd.scope = 'websites' AND ccd.path = 'web/unsecure/base_url' LIMIT 1);
SET @domain_def = (SELECT value FROM core_config_data WHERE path = 'web/unsecure/base_url' AND scope = 'default' LIMIT 1);
SET @final_domain = COALESCE(@domain_web, @domain_def, '');

-- Fetch Tax Configuration (1 = Included, 0 = Excluded)
SET @tax_inc_web = (SELECT value FROM core_config_data WHERE path = 'tax/calculation/price_includes_tax' AND scope = 'websites' AND scope_id = @web_id LIMIT 1);
SET @tax_inc_def = (SELECT value FROM core_config_data WHERE path = 'tax/calculation/price_includes_tax' AND scope = 'default' LIMIT 1);
SET @tax_included = IFNULL(COALESCE(@tax_inc_web, @tax_inc_def), 0);

-- 3. PRE-FETCH EVERY ATTRIBUTE ID
SET @etype = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = 'catalog_product' LIMIT 1);
SET @a_name = (SELECT attribute_id FROM eav_attribute WHERE entity_type_id = @etype AND attribute_code = 'name' LIMIT 1);
SET @a_status = (SELECT attribute_id FROM eav_attribute WHERE entity_type_id = @etype AND attribute_code = 'status' LIMIT 1);
SET @a_vis = (SELECT attribute_id FROM eav_attribute WHERE entity_type_id = @etype AND attribute_code = 'visibility' LIMIT 1);
SET @a_price = (SELECT attribute_id FROM eav_attribute WHERE entity_type_id = @etype AND attribute_code = 'price' LIMIT 1);
SET @a_sprice = (SELECT attribute_id FROM eav_attribute WHERE entity_type_id = @etype AND attribute_code = 'special_price' LIMIT 1);
SET @a_urlp = (SELECT attribute_id FROM eav_attribute WHERE entity_type_id = @etype AND attribute_code = 'url_path' LIMIT 1);
SET @a_urlk = (SELECT attribute_id FROM eav_attribute WHERE entity_type_id = @etype AND attribute_code = 'url_key' LIMIT 1);
SET @a_img = (SELECT attribute_id FROM eav_attribute WHERE entity_type_id = @etype AND attribute_code = 'image' LIMIT 1);
SET @a_sdesc = (SELECT attribute_id FROM eav_attribute WHERE entity_type_id = @etype AND attribute_code = 'short_description' LIMIT 1);
SET @a_desc = (SELECT attribute_id FROM eav_attribute WHERE entity_type_id = @etype AND attribute_code = 'description' LIMIT 1);

-- 4. Run the lightning-fast correlated export
SELECT 
    e.entity_id AS 'Product ID',

    COALESCE(
        (SELECT value FROM catalog_product_entity_varchar WHERE entity_id = e.entity_id AND attribute_id = @a_name AND store_id = @target_store),
        (SELECT value FROM catalog_product_entity_varchar WHERE entity_id = e.entity_id AND attribute_id = @a_name AND store_id = 0)
    ) AS 'Name',

    IF(IFNULL(COALESCE(
        (SELECT value FROM catalog_product_entity_int WHERE entity_id = e.entity_id AND attribute_id = @a_status AND store_id = @target_store),
        (SELECT value FROM catalog_product_entity_int WHERE entity_id = e.entity_id AND attribute_id = @a_status AND store_id = 0)
    ), 2) = 1, 1, 0) AS 'Enabled',

    CONCAT(@final_domain, 
        COALESCE(
            (SELECT value FROM catalog_product_entity_varchar WHERE entity_id = e.entity_id AND attribute_id = @a_urlp AND store_id = @target_store),
            (SELECT value FROM catalog_product_entity_varchar WHERE entity_id = e.entity_id AND attribute_id = @a_urlp AND store_id = 0),
            CONCAT(COALESCE(
                (SELECT value FROM catalog_product_entity_varchar WHERE entity_id = e.entity_id AND attribute_id = @a_urlk AND store_id = @target_store),
                (SELECT value FROM catalog_product_entity_varchar WHERE entity_id = e.entity_id AND attribute_id = @a_urlk AND store_id = 0)
            ), '.html')
        )
    ) AS 'URL',

    (SELECT GROUP_CONCAT(category_id SEPARATOR ', ') FROM catalog_category_product WHERE product_id = e.entity_id) AS 'Category IDs',

    @web_name AS 'Websites',
    @group_name AS 'Stores',
    @view_name AS 'Store Views',
    
    GROUP_CONCAT(DISTINCT cpsl.parent_id SEPARATOR ', ') AS 'Parent ID',
    
    e.sku AS 'SKU',
    GROUP_CONCAT(DISTINCT parent_e.sku SEPARATOR ', ') AS 'Parent SKU(s)',
    e.type_id AS 'Type',

    COALESCE(
        (SELECT value FROM catalog_product_entity_int WHERE entity_id = e.entity_id AND attribute_id = @a_vis AND store_id = @target_store),
        (SELECT value FROM catalog_product_entity_int WHERE entity_id = e.entity_id AND attribute_id = @a_vis AND store_id = 0)
    ) AS 'Visibility',

    @tax_included AS 'Prices are tax-included',

    COALESCE(
        (SELECT value FROM catalog_product_entity_decimal WHERE entity_id = e.entity_id AND attribute_id = @a_price AND store_id = @target_store),
        (SELECT value FROM catalog_product_entity_decimal WHERE entity_id = e.entity_id AND attribute_id = @a_price AND store_id = 0)
    ) AS 'Price',

    COALESCE(
        (SELECT value FROM catalog_product_entity_decimal WHERE entity_id = e.entity_id AND attribute_id = @a_sprice AND store_id = @target_store),
        (SELECT value FROM catalog_product_entity_decimal WHERE entity_id = e.entity_id AND attribute_id = @a_sprice AND store_id = 0)
    ) AS 'Special Price',

    CONCAT(@final_domain, 'media/catalog/product', 
        COALESCE(
            (SELECT value FROM catalog_product_entity_varchar WHERE entity_id = e.entity_id AND attribute_id = @a_img AND store_id = @target_store),
            (SELECT value FROM catalog_product_entity_varchar WHERE entity_id = e.entity_id AND attribute_id = @a_img AND store_id = 0)
        )
    ) AS 'Main Image URL',

    (SELECT GROUP_CONCAT(DISTINCT CONCAT(@final_domain, 'media/catalog/product', mg.value) SEPARATOR ', ') 
     FROM catalog_product_entity_media_gallery mg 
     WHERE mg.entity_id = e.entity_id) AS 'All Image URLs',

    REPLACE(REPLACE(COALESCE(
        (SELECT value FROM catalog_product_entity_text WHERE entity_id = e.entity_id AND attribute_id = @a_sdesc AND store_id = @target_store),
        (SELECT value FROM catalog_product_entity_text WHERE entity_id = e.entity_id AND attribute_id = @a_sdesc AND store_id = 0)
    ), CHAR(13), ' '), CHAR(10), ' ') AS 'Short Description',

    REPLACE(REPLACE(COALESCE(
        (SELECT value FROM catalog_product_entity_text WHERE entity_id = e.entity_id AND attribute_id = @a_desc AND store_id = @target_store),
        (SELECT value FROM catalog_product_entity_text WHERE entity_id = e.entity_id AND attribute_id = @a_desc AND store_id = 0)
    ), CHAR(13), ' '), CHAR(10), ' ') AS 'Description',

    e.created_at AS 'Created At',
    e.updated_at AS 'Updated At'

FROM catalog_product_entity e
JOIN catalog_product_website cpw ON e.entity_id = cpw.product_id AND cpw.website_id = @web_id
LEFT JOIN catalog_product_super_link cpsl ON e.entity_id = cpsl.product_id
LEFT JOIN catalog_product_entity parent_e ON cpsl.parent_id = parent_e.entity_id
GROUP BY e.entity_id;
" > magento_storeview${MAGENTO_STOREVIEW}_products_export.tsv

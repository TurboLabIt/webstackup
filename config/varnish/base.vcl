## VARNISH DEFAULTS BY WEBSTACKUP
# https://github.com/TurboLabIt/webstackup/blob/master/config/varnish/base.vcl
#
# Based on https://www.varnish-software.com/developers/tutorials/configuring-varnish-wordpress/#4-custom-wordpress-vcl
#
# Usage example: https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/config/custom/varnish.vcl
# include "/usr/local/turbolab.it/webstackup/config/varnish/base.vcl";
# sub vcl_recv { wsu_base(); }

vcl 4.1;

import std;


acl wsu_whitelist {

  "localhost";
  "127.0.0.1";
  "::1";
  "10.0.0.0"/8;           # 10.0.0.0 - 10.255.255.255
  "172.16.0.0"/12;        # 172.16.0.0 - 172.31.255.255
  "192.168.0.0"/16;       # 192.168.0.0 - 192.168.255.255
  "fc00::/7";             # Unique local addresses (IPv6)
}


sub wsu_httpoxy {

  # Remove the proxy header to mitigate the httpoxy vulnerability
  # See https://httpoxy.org/
  unset req.http.proxy;
}


sub wsu_set_protocol {

  # Add X-Forwarded-Proto header when using https
  if (!req.http.X-Forwarded-Proto) {
    if( std.port(server.ip) == 443 || std.port(server.ip) == 8443 ) {
      set req.http.X-Forwarded-Proto = "https";
    } else {
      set req.http.X-Forwarded-Proto = "http";
    }
  }
}


sub wsu_http_methods {

  # Only handle relevant HTTP request methods
  if (
    req.method != "GET" &&
    req.method != "HEAD" &&
    req.method != "PUT" &&
    req.method != "POST" &&
    req.method != "PATCH" &&
    req.method != "TRACE" &&
    req.method != "OPTIONS" &&
    req.method != "DELETE"
  ) {
    return (pipe);
  }

  # Only cache GET and HEAD requests
  if (req.method != "GET" && req.method != "HEAD") {
    set req.http.X-Cacheable = "NO:REQUEST-METHOD";
    return(pass);
  }
}


sub wsu_normalize_url {
  
  # Remove empty query string parameters
  # e.g.: www.example.com/index.html?
  if (req.url ~ "\?$") {
    set req.url = regsub(req.url, "\?$", "");
  }

  # Remove port number from host header
  set req.http.Host = regsub(req.http.Host, ":[0-9]+", "");

  # Remove tracking query string parameters used by analytics tools
  if (req.url ~ "(\?|&)(_branch_match_id|_bta_[a-z]+|_bta_c|_bta_tid|_ga|_gl|_ke|_kx|campid|cof|customid|cx|dclid|dm_i|ef_id|epik|fbclid|gad_source|gbraid|gclid|gclsrc|gdffi|gdfms|gdftrk|hsa_acc|hsa_ad|hsa_cam|hsa_grp|hsa_kw|hsa_mt|hsa_net|hsa_src|hsa_tgt|hsa_ver|ie|igshid|irclickid|matomo_campaign|matomo_cid|matomo_content|matomo_group|matomo_keyword|matomo_medium|matomo_placement|matomo_source|mc_[a-z]+|mc_cid|mc_eid|mkcid|mkevt|mkrid|mkwid|msclkid|mtm_campaign|mtm_cid|mtm_content|mtm_group|mtm_keyword|mtm_medium|mtm_placement|mtm_source|nb_klid|ndclid|origin|pcrid|piwik_campaign|piwik_keyword|piwik_kwd|pk_campaign|pk_keyword|pk_kwd|redirect_log_mongo_id|redirect_mongo_id|rtid|s_kwcid|sb_referer_host|sccid|si|siteurl|sms_click|sms_source|sms_uph|srsltid|toolid|trk_contact|trk_module|trk_msg|trk_sid|ttclid|twclid|utm_[a-z]+|utm_campaign|utm_content|utm_creative_format|utm_id|utm_marketing_tactic|utm_medium|utm_source|utm_source_platform|utm_term|vmcid|wbraid|yclid|zanpid)=") {
    set req.url = regsuball(req.url, "(_branch_match_id|_bta_[a-z]+|_bta_c|_bta_tid|_ga|_gl|_ke|_kx|campid|cof|customid|cx|dclid|dm_i|ef_id|epik|fbclid|gad_source|gbraid|gclid|gclsrc|gdffi|gdfms|gdftrk|hsa_acc|hsa_ad|hsa_cam|hsa_grp|hsa_kw|hsa_mt|hsa_net|hsa_src|hsa_tgt|hsa_ver|ie|igshid|irclickid|matomo_campaign|matomo_cid|matomo_content|matomo_group|matomo_keyword|matomo_medium|matomo_placement|matomo_source|mc_[a-z]+|mc_cid|mc_eid|mkcid|mkevt|mkrid|mkwid|msclkid|mtm_campaign|mtm_cid|mtm_content|mtm_group|mtm_keyword|mtm_medium|mtm_placement|mtm_source|nb_klid|ndclid|origin|pcrid|piwik_campaign|piwik_keyword|piwik_kwd|pk_campaign|pk_keyword|pk_kwd|redirect_log_mongo_id|redirect_mongo_id|rtid|s_kwcid|sb_referer_host|sccid|si|siteurl|sms_click|sms_source|sms_uph|srsltid|toolid|trk_contact|trk_module|trk_msg|trk_sid|ttclid|twclid|utm_[a-z]+|utm_campaign|utm_content|utm_creative_format|utm_id|utm_marketing_tactic|utm_medium|utm_source|utm_source_platform|utm_term|vmcid|wbraid|yclid|zanpid)=[-_A-z0-9+(){}%.*]+&?", "");
    set req.url = regsub(req.url, "[?|&]+$", "");
  }

  # Sorts query string parameters alphabetically for cache normalization purposes
  set req.url = std.querysort(req.url);
}


sub wsu_wp_purge_from_whitelist {

  # Purge logic to remove objects from the cache.
  # Tailored to the Proxy Cache Purge WordPress plugin
  # See https://wordpress.org/plugins/varnish-http-purge/
  if(req.method == "PURGE") {
    if(!client.ip ~ wsu_whitelist) {
      return(synth(405,"PURGE not allowed for this IP address"));
    }
    if (req.http.X-Purge-Method == "regex") {
      ban("obj.http.x-url ~ " + req.url + " && obj.http.x-host == " + req.http.host);
      return(synth(200, "Purged"));
    }
    ban("obj.http.x-url == " + req.url + " && obj.http.x-host == " + req.http.host);
    return(synth(200, "Purged"));
  }
}


sub wsu_base {

  wsu_httpoxy();
  wsu_set_protocol();
  wsu_http_methods();
  wsu_normalize_url();
  wsu_wp_purge_from_whitelist();
}

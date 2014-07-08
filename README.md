stormagent
==========

A base class for all stormstack agents


*List of stormagent APIs*
=========================

<table>
  <tr>
    <th>Verb</th><th>URI</th><th>Description</th>
  </tr>
 <tr>
    <td>POST</td><td>/personality</td><td>Upload a file with given content to VCG/CPE</td>
  </tr> 
  <tr>
    <td>GET</td><td>/status</td><td>Get environment, packages, services, instances details.</td>
  </tr>
  <tr>
    <td>GET</td><td>/environment</td><td>Get environment details</td>
  </tr> 
</table>


**POST personality API**

    Verb      URI                       Description
    POST      /personality              Upload a file with given content in VCG/CPE.


**Example Request and Response**

### Request JSON

    {
        "personality": [
            {
                "path": "/etc/kav_repo",
                "contents": "aHR0cDovL3JlcG8yLmNzaC5lbXMtdGVsZWtvbS5kZS9rYXY=",
                "postxfer": "/usr/sbin/kav_update"
            }
        ]
    }

### Response JSON
    {
        result: 'success'
    }


**GET status API**

    Verb      URI                       Description
    GET      /status                    Get environment, packages, services, instances details.


**Example Request and Response**

### Response JSON
    {
    "id": "a0468c1c-e3f9-402f-8db7-43ad274c8563",
    "instance": "98a52ed9-6023-41a8-99b0-9ddcc65900e9",
    "activated": true,
    "running": true,
    "env": {
        "provider": "openstack",
        "skey": "4d7aa9d9-1963-4b7b-9f32-8bd9471af520",
        "tracker": "https://stormtracker.csh.ems-telekom.de/",
        "token": "9a73f7e2-0587-477d-83fd-bd3e117bb6cc",
        "id": "a0468c1c-e3f9-402f-8db7-43ad274c8563",
        "bolt": {
            "beaconValidity": 45,
            "beaconRetry": 3,
            "beaconInterval": 10,
            "listenPort": 0,
            "allowedPorts": [
                5000
            ],
            "relayPort": 0,
            "allowRelay": false,
            "uplinkStrategy": "round-robin",
            "uplinks": [
                "stormtower.csh.ems-telekom.de"
            ]
        },
        "csr": "-----BEGIN CERTIFICATE REQUEST-----\nMIIDEzCCAfsCAQAwgc0xCzAJBgNVBAYTAlVTMQswCQYDVQQIDAJDQTETMBEGA1UE\nBwwKRWwgU2VndW5kbzEbMBkGA1UECgwSQ2xlYXJQYXRoIE5ldHdvcmtzMQwwCgYD\nVQQLDANDUE4xLTArBgNVBAMMJGEwNDY4YzFjLWUzZjktNDAyZi04ZGI3LTQzYWQy\nNzRjODU2MzFCMEAGCSqGSIb3DQEJARYzYTA0NjhjMWMtZTNmOS00MDJmLThkYjct\nNDNhZDI3NGM4NTYzQGludGVyY2xvdWQubmV0MIIBIjANBgkqhkiG9w0BAQEFAAOC\nAQ8AMIIBCgKCAQEAupXvybX75Vakf62UCFfFTPxKJX+MePBgoJa2V2eoO8yHxAdL\nV0zOhmM8wvkZ4yomtOotq+eqUPubDgvaojaP64phtw1eTxOC9lCsjwqJitjONAbh\n7D5O04v+kHthw5A2CFNiiXUuZvfo1Q3sLSmgUumlJ1ZT59inwaOv6Ixc/G4udKjM\nlIQdPlJ+LjDRfSNUImYl1fFu4sSrSy0PsRbyIMIXMH1aug5bBZcjU3UAqViUZkWL\nmilZaz7pko0ojtDhCod+S9XRY4bKYOpt71BsqZck8JFTEZJBTgm8s8wIXNIfWWr5\nGPh8Rdj54E+kKDoI/Zmf4BTx8WqWSyBZT93cYQIDAQABoAAwDQYJKoZIhvcNAQEL\nBQADggEBACM4q3uZpth65oxjSAAhcTD6K2mD/+DhiaEhwvp7mjsOAkCP2glMxngh\nUKUDZvfUOmH8x4qus2DKIQ6cltxC9Vtva588sUE0QXjiQpjn1W8FAwOWuf2l5MkF\nbfxPvTkhkxUJuy0tZBvq7Slu0rClJXjKGWwTufEbWFEBfu0NS/wELDXGq26Aslv3\nOENXe2ZItTC2E8I7xfbP3lmkMrfTiFP1fhOVvxWhmAHRH4lu4vKteWjp2D13mgpy\nMsVwgzfqXsNI20gnq653NllCvZCmWZoORlw2mc9AGTOl/aelioH8tSmkkMYpK5YW\nxdZ0SA/y9+D/2LrlRTHlMjbMJ0oCu3w=\n-----END CERTIFICATE REQUEST-----"
    },
    "haveCredentials": true,
    "config": {
        "repeatInterval": 25000,
        "insecure": true,
        "uplinks": [
            "stormtower.csh.ems-telekom.de"
        ],
        "uplinkStrategy": "round-robin",
        "allowRelay": false,
        "relayPort": 0,
        "allowedPorts": [
            5000
        ],
        "listenPort": 0,
        "beaconInterval": 10,
        "beaconRetry": 3,
        "beaconValidity": 45,
        "port": 5000,
        "logfile": "/var/log/stormflash.log",
        "datadir": "/var/stormflash",
        "repeatdelay": 5000
    },
    "os": {
        "tmpdir": "/lib/node_modules/stormflash",
        "endianness": "LE",
        "hostname": "kvm570",
        "type": "Linux",
        "platform": "linux",
        "release": "2.6.34.7",
        "arch": "ia32",
        "uptime": 449897.537468143,
        "loadavg": [
            0,
            0,
            0
        ],
        "totalmem": 18446744073709548000,
        "freemem": 18446744073709548000,
        "cpus": [
            {
                "model": "Intel(R) Core(TM)2 Duo CPU     T7700  @ 2.40GHz",
                "speed": 1999,
                "times": {
                    "user": 87217200,
                    "nice": 0,
                    "sys": 22701000,
                    "idle": 93244104,
                    "irq": 0
                }
            }
        ],
        "networkInterfaces": {
            "lo": [
                {
                    "address": "127.0.0.1",
                    "family": "IPv4",
                    "internal": true
                }
            ],
            "wan0": [
                {
                    "address": "10.1.0.17",
                    "family": "IPv4",
                    "internal": false
                }
            ],
            "tun1": [
                {
                    "address": "172.17.0.1",
                    "family": "IPv4",
                    "internal": false
                }
            ]
        }
    },
    "uplink": {
        "host": "stormtower.csh.ems-telekom.de",
        "port": 443
    },
    "clients": [],
    "packages": [
        {
            "name": "commtouch-storm",
            "version": "*",
            "source": "npm://",
            "type": "npm",
            "status": {
                "installed": true,
                "imported": true
            },
            "id": "e3db8f5c-00f3-4199-9ae2-2bf423774a17"
        },
        {
            "name": "openvpn-storm",
            "version": "*",
            "source": "npm://",
            "type": "npm",
            "status": {
                "installed": true,
                "imported": true
            },
            "id": "5d709bbc-4f23-4ae6-9f47-f20f3f0a1add"
        },
        {
            "name": "corenova-storm",
            "version": "*",
            "source": "npm://",
            "type": "npm",
            "status": {
                "installed": true,
                "imported": true
            },
            "id": "f30571f3-7c11-4c6f-ac0b-3dcf162ccedf"
        }
    ],
    "services": [
        {
            "invocation": {
                "name": "universal",
                "path": "/usr/bin",
                "monitor": true,
                "args": [
                    "--config_file=/var/stormflash/plugins/corenova/91ba135d-1ffe-450a-a30a-587adee976cc/engine.ini"
                ],
                "options": {
                    "env": {
                        "NOVAMODULE_PATH": "/usr/lib:/usr/local/lib",
                        "LD_LIBRARY_PATH": "/lib:/usr/lib:/usr/local/lib"
                    },
                    "detached": true,
                    "stdio": [
                        "ignore",
                        24,
                        29
                    ]
                }
            },
            "running": false,
            "id": "91ba135d-1ffe-450a-a30a-587adee976cc",
            "saved": false
        }
    ],
    "instances": [
        {
            "name": "openvpn",
            "path": "/usr/sbin",
            "monitor": false,
            "args": [
                "--config",
                "/var/stormflash/meta/d264f542-301d-4cc9-8a50-37a0f462bf7c.conf"
            ],
            "options": {
                "env": {
                    "npm_config_cache_lock_stale": "60000",
                    "npm_package_devDependencies_coffee_script": ">=1.7.1",
                    "npm_config_sign_git_tag": "",
                    "npm_config_pre": "",
                    "npm_package_scripts_prepublish": "mkdir -p lib; coffee -o lib -c src",
                    "npm_config_user_agent": "node/v0.10.13 linux ia32",
                    "npm_config_always_auth": "",
                    "npm_package_dependencies_stormbolt": ">=0.3.9",
                    "USER": "root",
                    "npm_config_bin_links": "true",
                    "npm_package_bugs_url": "https://github.com/stormstack/stormflash/issues",
                    "npm_node_execpath": "/bin/node",
                    "npm_config_user": "nobody",
                    "npm_config_init_version": "0.0.0",
                    "npm_config_fetch_retries": "2",
                    "npm_config_description": "true",
                    "npm_package_config_datadir": "/var/stormflash",
                    "LD_LIBRARY_PATH": "/",
                    "npm_config_ignore": "",
                    "npm_config_force": "",
                    "HOME": "/",
                    "npm_config_cache_min": "10",
                    "npm_package_engines_node": ">=0.6.x",
                    "npm_config_rollback": "true",
                    "npm_config_editor": "vi",
                    "npm_config_userconfig": "/.npmrc",
                    "npm_config_cache_max": "null",
                    "npm_package_dependencies_json_schema": "0.2.0",
                    "npm_config_yes": "",
                    "npm_config_userignorefile": "/.npmignore",
                    "npm_config_tmp": "/tmp",
                    "npm_config_init_author_url": "",
                    "npm_config_init_author_name": "",
                    "npm_config_engine_strict": "",
                    "npm_config_coverage": "",
                    "npm_package_config_storm_functions_0": "agent.install",
                    "npm_config_usage": "",
                    "npm_config_save_dev": "",
                    "npm_config_depth": "null",
                    "npm_package_dist_shasum": "b785c01fcc4ede77df4cd18795849fe5027c9dda",
                    "npm_package_config_storm_functions_1": "agent.remove",
                    "npm_package_description": "stormflash provides remote application lifecycle management on any arbitrary endpoint",
                    "npm_config_https_proxy": "",
                    "npm_package_readmeFilename": "README.md",
                    "npm_package_config_storm_functions_2": "agent.upgrade",
                    "npm_package_config_repeatInterval": "25000",
                    "npm_package_homepage": "http://stormstack.org",
                    "TMPDIR": "/lib/node_modules/stormflash",
                    "npm_config_onload_script": "",
                    "npm_package_config_storm_functions_3": "agent.list",
                    "npm_package_config_logfile": "/var/log/stormflash.log",
                    "npm_package_dependencies_async": "0.8.x",
                    "npm_config_shell": "/bin/sh",
                    "npm_config_save_bundle": "",
                    "npm_config_rebuild_bundle": "true",
                    "npm_package_config_storm_functions_4": "agent.start",
                    "npm_package_dependencies_request": "2.34.x",
                    "npm_config_prefix": "/",
                    "npm_package_config_storm_functions_5": "agent.stop",
                    "npm_config_versions": "",
                    "npm_config_searchopts": "",
                    "npm_config_save_optional": "",
                    "npm_config_cache_lock_wait": "10000",
                    "npm_config_browser": "",
                    "npm_config_registry": "http://npm3.intercloud.net:4873/",
                    "npm_package_config_storm_functions_6": "agent.reload",
                    "npm_config_proxy": "",
                    "npm_config_cache": "/.npm",
                    "npm_package_config_storm_functions_7": "agent.invoke",
                    "npm_package_dependencies_stormagent": ">=0.2.11",
                    "TERM": "linux",
                    "npm_config_version": "",
                    "npm_config_searchsort": "name",
                    "npm_config_npaturl": "http://npat.npmjs.org/",
                    "npm_package_scripts_start": "node lib/stormflash",
                    "npm_config_viewer": "man",
                    "BOOT_IMAGE": "/boot/bzImage.runtime",
                    "NODE": "/bin/node",
                    "npm_package_dependencies_find_in_path": "0.0.x",
                    "npm_package_repository_type": "git",
                    "npm_package_name": "stormflash",
                    "PATH": "/bin:/sbin:/usr/bin:/usr/sbin",
                    "npm_config_color": "true",
                    "npm_config_fetch_retry_mintimeout": "10000",
                    "npm_config_umask": "18",
                    "npm_lifecycle_script": "node lib/stormflash",
                    "npm_config_message": "%s",
                    "npm_config_loglevel": "http",
                    "npm_config_fetch_retry_maxtimeout": "60000",
                    "npm_package_contributors_0_name": "Ravi Chunduru",
                    "npm_package_main": "./lib/stormflash",
                    "npm_config_link": "",
                    "npm_config_global": "true",
                    "npm_package_contributors_1_name": "Suresh Kumar",
                    "npm_package_dependencies_dirty_query": "0.1.x",
                    "npm_lifecycle_event": "start",
                    "npm_config_unicode": "true",
                    "npm_config_save": "",
                    "npm_package_contributors_2_name": "Geetha Rani",
                    "npm_package_repository_url": "git://github.com/stormstack/stormflash.git",
                    "npm_package_version": "1.2.5",
                    "NODE_PATH": "/lib/node_modules",
                    "SHELL": "/bin/sh",
                    "npm_config_unsafe_perm": "",
                    "npm_config_production": "",
                    "npm_config_long": "",
                    "npm_config_argv": "{\"remain\":[\"stormflash\"],\"cooked\":[\"start\",\"--global\",\"stormflash\"],\"original\":[\"start\",\"-g\",\"stormflash\"]}",
                    "npm_package_contributors_3_name": "Sivaprasath Busa",
                    "npm_config_tag": "latest",
                    "npm_config_node_version": "v0.10.13",
                    "npm_config_shrinkwrap": "true",
                    "npm_package_config_storm_plugins_0": "lib/plugin",
                    "npm_config_username": "",
                    "npm_config_strict_ssl": "true",
                    "npm_config_proprietary_attribs": "true",
                    "npm_config_npat": "",
                    "npm_config_fetch_retry_factor": "10",
                    "npm_package_license": "MIT",
                    "npm_config_parseable": "",
                    "npm_config_init_module": "/.npm-init.js",
                    "npm_config_globalconfig": "/etc/npmrc",
                    "npm_config_dev": "",
                    "npm_execpath": "/lib/node_modules/npm/bin/npm-cli.js",
                    "npm_config_globalignorefile": "/etc/npmignore",
                    "PWD": "/lib/node_modules/stormflash",
                    "npm_config_cache_lock_retries": "10",
                    "npm_package_dependencies_minimist": "0.1.0",
                    "npm_package_author_name": "Peter K. Lee",
                    "npm_config_searchexclude": "",
                    "npm_config_init_author_email": "",
                    "npm_config_group": "",
                    "npm_config_optional": "true",
                    "npm_config_git": "git",
                    "npm_package_dependencies_lazy": "1.0.x",
                    "npm_config_json": "",
                    "npm_package_dependencies_node_uuid": "1.3.x",
                    "NODE_TLS_REJECT_UNAUTHORIZED": "0"
                },
                "detached": true,
                "stdio": [
                    "ignore",
                    25,
                    27
                ]
            },
            "pid": 5085,
            "id": "929e97d3-4c92-4f5d-8dd8-c2ade740c73c"
        },
        {
            "name": "ctwsd",
            "path": "/bin",
            "monitor": false,
            "options": {
                "env": {
                    "npm_config_cache_lock_stale": "60000",
                    "npm_package_devDependencies_coffee_script": ">=1.7.1",
                    "npm_config_sign_git_tag": "",
                    "npm_config_pre": "",
                    "npm_package_scripts_prepublish": "mkdir -p lib; coffee -o lib -c src",
                    "npm_config_user_agent": "node/v0.10.13 linux ia32",
                    "npm_config_always_auth": "",
                    "npm_package_dependencies_stormbolt": ">=0.3.9",
                    "USER": "root",
                    "npm_config_bin_links": "true",
                    "npm_package_bugs_url": "https://github.com/stormstack/stormflash/issues",
                    "npm_node_execpath": "/bin/node",
                    "npm_config_user": "nobody",
                    "npm_config_init_version": "0.0.0",
                    "npm_config_fetch_retries": "2",
                    "npm_config_description": "true",
                    "npm_package_config_datadir": "/var/stormflash",
                    "LD_LIBRARY_PATH": "/",
                    "npm_config_ignore": "",
                    "npm_config_force": "",
                    "HOME": "/",
                    "npm_config_cache_min": "10",
                    "npm_package_engines_node": ">=0.6.x",
                    "npm_config_rollback": "true",
                    "npm_config_editor": "vi",
                    "npm_config_userconfig": "/.npmrc",
                    "npm_config_cache_max": "null",
                    "npm_package_dependencies_json_schema": "0.2.0",
                    "npm_config_yes": "",
                    "npm_config_userignorefile": "/.npmignore",
                    "npm_config_tmp": "/tmp",
                    "npm_config_init_author_url": "",
                    "npm_config_init_author_name": "",
                    "npm_config_engine_strict": "",
                    "npm_config_coverage": "",
                    "npm_package_config_storm_functions_0": "agent.install",
                    "npm_config_usage": "",
                    "npm_config_save_dev": "",
                    "npm_config_depth": "null",
                    "npm_package_dist_shasum": "b785c01fcc4ede77df4cd18795849fe5027c9dda",
                    "npm_package_config_storm_functions_1": "agent.remove",
                    "npm_package_description": "stormflash provides remote application lifecycle management on any arbitrary endpoint",
                    "npm_config_https_proxy": "",
                    "npm_package_readmeFilename": "README.md",
                    "npm_package_config_storm_functions_2": "agent.upgrade",
                    "npm_package_config_repeatInterval": "25000",
                    "npm_package_homepage": "http://stormstack.org",
                    "TMPDIR": "/lib/node_modules/stormflash",
                    "npm_config_onload_script": "",
                    "npm_package_config_storm_functions_3": "agent.list",
                    "npm_package_config_logfile": "/var/log/stormflash.log",
                    "npm_package_dependencies_async": "0.8.x",
                    "npm_config_shell": "/bin/sh",
                    "npm_config_save_bundle": "",
                    "npm_config_rebuild_bundle": "true",
                    "npm_package_config_storm_functions_4": "agent.start",
                    "npm_package_dependencies_request": "2.34.x",
                    "npm_config_prefix": "/",
                    "npm_package_config_storm_functions_5": "agent.stop",
                    "npm_config_versions": "",
                    "npm_config_searchopts": "",
                    "npm_config_save_optional": "",
                    "npm_config_cache_lock_wait": "10000",
                    "npm_config_browser": "",
                    "npm_config_registry": "http://npm3.intercloud.net:4873/",
                    "npm_package_config_storm_functions_6": "agent.reload",
                    "npm_config_proxy": "",
                    "npm_config_cache": "/.npm",
                    "npm_package_config_storm_functions_7": "agent.invoke",
                    "npm_package_dependencies_stormagent": ">=0.2.11",
                    "TERM": "linux",
                    "npm_config_version": "",
                    "npm_config_searchsort": "name",
                    "npm_config_npaturl": "http://npat.npmjs.org/",
                    "npm_package_scripts_start": "node lib/stormflash",
                    "npm_config_viewer": "man",
                    "BOOT_IMAGE": "/boot/bzImage.runtime",
                    "NODE": "/bin/node",
                    "npm_package_dependencies_find_in_path": "0.0.x",
                    "npm_package_repository_type": "git",
                    "npm_package_name": "stormflash",
                    "PATH": "/bin:/sbin:/usr/bin:/usr/sbin",
                    "npm_config_color": "true",
                    "npm_config_fetch_retry_mintimeout": "10000",
                    "npm_config_umask": "18",
                    "npm_lifecycle_script": "node lib/stormflash",
                    "npm_config_message": "%s",
                    "npm_config_loglevel": "http",
                    "npm_config_fetch_retry_maxtimeout": "60000",
                    "npm_package_contributors_0_name": "Ravi Chunduru",
                    "npm_package_main": "./lib/stormflash",
                    "npm_config_link": "",
                    "npm_config_global": "true",
                    "npm_package_contributors_1_name": "Suresh Kumar",
                    "npm_package_dependencies_dirty_query": "0.1.x",
                    "npm_lifecycle_event": "start",
                    "npm_config_unicode": "true",
                    "npm_config_save": "",
                    "npm_package_contributors_2_name": "Geetha Rani",
                    "npm_package_repository_url": "git://github.com/stormstack/stormflash.git",
                    "npm_package_version": "1.2.5",
                    "NODE_PATH": "/lib/node_modules",
                    "SHELL": "/bin/sh",
                    "npm_config_unsafe_perm": "",
                    "npm_config_production": "",
                    "npm_config_long": "",
                    "npm_config_argv": "{\"remain\":[\"stormflash\"],\"cooked\":[\"start\",\"--global\",\"stormflash\"],\"original\":[\"start\",\"-g\",\"stormflash\"]}",
                    "npm_package_contributors_3_name": "Sivaprasath Busa",
                    "npm_config_tag": "latest",
                    "npm_config_node_version": "v0.10.13",
                    "npm_config_shrinkwrap": "true",
                    "npm_package_config_storm_plugins_0": "lib/plugin",
                    "npm_config_username": "",
                    "npm_config_strict_ssl": "true",
                    "npm_config_proprietary_attribs": "true",
                    "npm_config_npat": "",
                    "npm_config_fetch_retry_factor": "10",
                    "npm_package_license": "MIT",
                    "npm_config_parseable": "",
                    "npm_config_init_module": "/.npm-init.js",
                    "npm_config_globalconfig": "/etc/npmrc",
                    "npm_config_dev": "",
                    "npm_execpath": "/lib/node_modules/npm/bin/npm-cli.js",
                    "npm_config_globalignorefile": "/etc/npmignore",
                    "PWD": "/lib/node_modules/stormflash",
                    "npm_config_cache_lock_retries": "10",
                    "npm_package_dependencies_minimist": "0.1.0",
                    "npm_package_author_name": "Peter K. Lee",
                    "npm_config_searchexclude": "",
                    "npm_config_init_author_email": "",
                    "npm_config_group": "",
                    "npm_config_optional": "true",
                    "npm_config_git": "git",
                    "npm_package_dependencies_lazy": "1.0.x",
                    "npm_config_json": "",
                    "npm_package_dependencies_node_uuid": "1.3.x",
                    "NODE_TLS_REJECT_UNAUTHORIZED": "0"
                },
                "detached": true,
                "stdio": [
                    "ignore",
                    28,
                    30
                ]
            },
            "pid": 5114,
            "id": "98f19fbc-4498-4ab6-993a-23d65f0bfc28"
        }
    ]
    }


**GET environment API**

    Verb      URI                       Description
    GET      /environment               Get environment details.


**Example Request and Response**

### Response JSON
    {
    "tmpdir": "/lib/node_modules/stormflash",
    "endianness": "LE",
    "hostname": "kvm570",
    "type": "Linux",
    "platform": "linux",
    "release": "2.6.34.7",
    "arch": "ia32",
    "uptime": 449982.527100548,
    "loadavg": [
        0,
        0,
        0
    ],
    "totalmem": 18446744073709548000,
    "freemem": 18446744073709548000,
    "cpus": [
        {
            "model": "Intel(R) Core(TM)2 Duo CPU     T7700  @ 2.40GHz",
            "speed": 1999,
            "times": {
                "user": 87231600,
                "nice": 0,
                "sys": 22705700,
                "idle": 94074804,
                "irq": 0
            }
        }
    ],
    "networkInterfaces": {
        "lo": [
            {
                "address": "127.0.0.1",
                "family": "IPv4",
                "internal": true
            }
        ],
        "wan0": [
            {
                "address": "10.1.0.17",
                "family": "IPv4",
                "internal": false
            }
        ],
        "tun1": [
            {
                "address": "172.17.0.1",
                "family": "IPv4",
                "internal": false
            }
        ]
    }
    }

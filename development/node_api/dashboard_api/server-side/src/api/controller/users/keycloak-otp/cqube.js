var axios = require('axios');
var qs = require('qs');
const config = require('./config')
const { logger } = require('../../../lib/logger');





const keycloakHost = config.KEYCLOAK_HOST;
const realmName = config.KEYCLOAK_REALM;
const keycloakClient = config.KEYCLOAK_CLIENT;
let username = config.KEYCLOAK_ADM_USER;
let password = config.KEYCLOAK_ADM_PASSWD;


const getDetails = async () => {

    let data = qs.stringify({
        'client_id': keycloakClient,
        'username': username,
        'password': password,
        'grant_type': 'password'
    });


    let url = `${keycloakHost}/auth/realms/${realmName}/protocol/openid-connect/token`;

    let config = {
        method: 'post',
        url: url,
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        data: data
    };

    await axios(config)
        .then(function (response) {
            logger.info('---token received ---');
            if (JSON.stringify(response.data['access_token'])) {
                let res = JSON.stringify(response.data)
                let token = response.data['access_token']
                let innerHeader = {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${token}`
                }

                axios.get(`${keycloakHost}/auth/admin/realms/${realmName}/users`, { headers: innerHeader }).then(res => {

                    if (res.status === 200) {
                        let userList = res['data']
                        logger.info('---userlist received ---');
                        userList.forEach(data => {
                            if (data['username'] !== username) {
                                
                                axios.get(`${keycloakHost}/auth/admin/realms/${realmName}/users/${data['id']}/role-mappings`, { headers: innerHeader }).then(res => {
                                    if (res.status === 200) {
                                        let userRole = res['data'];
                                        logger.info('---role mapping done ---');
                                        userRole.realmMappings.forEach(roles => {
                                            if (roles['name'] === 'admin') {

                                                let role = roles
                                                let roleId = roles['id']
                                                if (data['totp'] !== true) {
                                                    // api to update the user
                                                    var updateUser = `${keycloakHost}/auth/admin/realms/${realmName}/users/${data['id']}`
                                                    var actionsRequired = {
                                                        requiredActions: [
                                                            'CONFIGURE_TOTP'
                                                        ],
                                                    }
                                                    
                                                    // updating user api call
                                                    axios.put(updateUser, actionsRequired, { headers: innerHeader }).then(async resp1 => {

                                                        logger.info('---updated admin with totp ---');

                                                    }).catch(error => {
                                                        logger.info('---update admin totp  fail ---');

                                                    })
                                                }

                                            }
                                        })
                                    }
                                }).catch(err => {
                                    logger.info('---role mapping  fail ---');
                                })
                            }
                        })
                    }
                }).catch(err => {
                    logger.info('---user list  received fail ---');
                })

            }
        })
        .catch(function (error) {

            logger.info('---token received fail ---');
        });
}


getDetails()
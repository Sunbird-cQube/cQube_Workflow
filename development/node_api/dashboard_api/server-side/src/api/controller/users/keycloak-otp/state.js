
var axios = require('axios');
const { logger } = require('../../../lib/logger');
var qs = require('qs');
const config = require('./config')



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

            if (JSON.stringify(response.data['access_token'])) {
                let res = JSON.stringify(response.data)
                logger.info('---token received ---');
                let token = response.data['access_token']

                axios.get(`${keycloakHost}/auth/admin/realms/${realmName}/users`, { headers: { "Authorization": `Bearer ${token}` } }).then(res => {

                    if (res.status === 200) {
                        let userList = res['data']
                        logger.info('---users list  received ---');
                        userList.forEach(data => {
                            
                            if (data['totp'] === true) {


                                axios.get(`${keycloakHost}/auth/admin/realms/${realmName}/users/${data['id']}/credentials`, { headers: { "Authorization": `Bearer ${token}` } }).then(res => {
                                    if (res.status === 200) {
                                        let userCredentials = res['data'];
                                        logger.info('---credentials api success ---');
                                        userCredentials.forEach(Credentials => {
                                            if (Credentials['type'] === 'otp') {

                                                axios.delete(`${keycloakHost}/auth/admin/realms/${realmName}/users/${data['id']}/credentials/${Credentials['id']}`, { headers: { "Authorization": `Bearer ${token}` } }).then(res => {

                                                    logger.info('---credentials type totp removed ---');
                                                }).catch(err => {
                                                    logger.info('---credentials type totp removing failed ---');
                                                })
                                            }
                                        })
                                    }
                                }).catch(err => {
                                    logger.info('---credentials api failed ---');
                                })
                            }
                            if (data['requiredActions'].length) {

                                var updateUser = `${keycloakHost}/auth/admin/realms/${realmName}/users/${data['id']}`
                                logger.info('---required actions success ---');
                                var actionsRequired = {
                                    requiredActions: [],
                                }
                                axios.put(updateUser, actionsRequired, { headers: { "Authorization": `Bearer ${token}` } }).then(async resp1 => {
                                    logger.info('---removing of required action fail ---');
                                }).catch(error => {

                                    logger.info('---user info fail ---');
                                })

                            }
                        })
                    }
                }).catch(err => {
                    logger.info('---user list fail ---');

                })

            }
        })
        .catch(function (error) {

            logger.info('---token received fail ---');
        });
}


getDetails()

var axios = require('axios');
var qs = require('qs');
const dotenv = require('dotenv');
const config = require('./config')
dotenv.config();



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
                let token = response.data['access_token']

                axios.get(`${keycloakHost}/auth/admin/realms/${realmName}/users`, { headers: { "Authorization": `Bearer ${token}` } }).then(res => {

                    if (res.status === 200) {
                        let userList = res['data']

                        userList.forEach(data => {

                            if (data['totp'] === true) {


                                axios.get(`${keycloakHost}/auth/admin/realms/${realmName}/users/${data['id']}/credentials`, { headers: { "Authorization": `Bearer ${token}` } }).then(res => {
                                    if (res.status === 200) {
                                        let userCredentials = res['data'];

                                        userCredentials.forEach(Credentials => {
                                            if (Credentials['type'] === 'otp') {

                                                axios.delete(`${keycloakHost}/auth/admin/realms/${realmName}/users/${data['id']}/credentials/${Credentials['id']}`, { headers: { "Authorization": `Bearer ${token}` } }).then(res => {
                                                    let response = resp1
                                                }).catch(err => {
                                                    console.log(err)
                                                })
                                            }
                                        })
                                    }
                                }).catch(err => {
                                    console.log(err)
                                })
                            }
                            if (data['requiredActions'].length) {

                                var updateUser = `${keycloakHost}/auth/admin/realms/${realmName}/users/${data['id']}`
                                var actionsRequired = {
                                    requiredActions: [],
                                }
                                axios.put(updateUser, actionsRequired, { headers: { "Authorization": `Bearer ${token}` } }).then(async resp1 => {

                                }).catch(error => {
                                    console.log(error)

                                })

                            }
                        })
                    }
                }).catch(err => {
                    console.log(err)
                })

            }
        })
        .catch(function (error) {
            console.log(error);
        });
}


getDetails()
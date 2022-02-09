var axios = require('axios');
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
                let token = response.data['access_token']
                let innerHeader = {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${token}`
                }

                axios.get(`${keycloakHost}/auth/admin/realms/${realmName}/users`, { headers: innerHeader }).then(res => {

                    if (res.status === 200) {
                        let userList = res['data']

                        userList.forEach(data => {


                            axios.get(`${keycloakHost}/auth/admin/realms/${realmName}/users/${data['id']}/role-mappings`, { headers: innerHeader }).then(res => {
                                if (res.status === 200) {
                                    let userRole = res['data'];

                                    userRole.realmMappings.forEach(roles => {
                                        if (roles['name'] === 'admin') {

                                            let role = roles
                                            let roleId = roles['id']


                                            let actionsUrl = `${keycloakHost}/auth/admin/realms/${realmName}/authentication/required-actions`;

                                            axios.get(actionsUrl, { headers: innerHeader }).then(async actions => {
                                                // take only CONFIGURE_TOTP to check for two factor auth enable for the application

                                                let requiredActions = actions.data.filter(data => {
                                                    return data.alias == 'CONFIGURE_TOTP'

                                                })

                                                // api to update the user
                                                var updateUser = `${keycloakHost}/auth/admin/realms/${realmName}/users/${data['id']}`
                                                var actionsRequired = {
                                                    requiredActions: [
                                                        'CONFIGURE_TOTP'
                                                    ],
                                                }

                                                // check for required actions configured -- CONFIGURE_TOTP and update the user for two factor auth


                                                // updating user api call
                                                axios.put(updateUser, actionsRequired, { headers: innerHeader }).then(async resp1 => {



                                                }).catch(error => {
                                                    console.log(error)

                                                })

                                            }).catch(error => {
                                                res.status(409).json({ errMsg: error.response });
                                            })
                                        }
                                    })
                                }
                            }).catch(err => {
                                console.log(err)
                            })

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
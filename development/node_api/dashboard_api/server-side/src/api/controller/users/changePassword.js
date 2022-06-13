const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const axios = require('axios');
const dotenv = require('dotenv');
const db = require('../keycloakDB/db')
const Querystring = require('querystring');
dotenv.config();

var host = process.env.KEYCLOAK_HOST;
var realm = process.env.KEYCLOAK_REALM;
var authType = process.env.AUTH_API;
var client_id = process.env.KEYCLOAK_CLIENT

router.post('/:id', auth.authController, async (req, res) => {
    try {
        logger.info('---change password api ---');
        var userId = req.params.id;

         if (authType === 'cqube') {
            let loginUrl = `${host}/auth/realms/${realm}/protocol/openid-connect/token`
            let body
            if (req.body.otp) {
                body = Querystring['stringify']({
                    "grant_type": "password",
                    "client_id": client_id,
                    "username": req.body.userName,
                    "password": req.body.currentPasswd,
                    "totp": req.body.otp
                })
            } else {
                body = Querystring['stringify']({
                    "grant_type": "password",
                    "client_id": client_id,
                    "username": req.body.userName,
                    "password": req.body.currentPasswd,
                })
            }


            const config = {
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            }


            axios.post(loginUrl, body, config).then(resp => {

                let usersUrl = `${host}/auth/admin/realms/${realm}/users/${userId}/reset-password`;
                let headers = {
                    "Content-Type": "application/json",
                    "Authorization": req.headers.token
                }
                let newPass = {
                    type: "password",
                    value: req.body.cnfpass,
                    temporary: false
                };
                axios.put(usersUrl, newPass, { headers: headers }).then(resp => {
                    logger.info('---change password api response sent---');
                    res.status(201).json({ msg: "Password changed" });
                }).catch(error => {
                    res.status(error.response.status).json({ errMsg: error.response.data.errorMessage });
                })
            }).catch(error => {
                console.log(error)
                res.status(404).json({ errMsg: error.response.data.errorMessage });
            })

        } else {
            let usersUrl = `${host}/auth/admin/realms/${realm}/users/${userId}/reset-password`;
            let newPass = {
                type: "password",
                temporary: false,
                value: req.body.cnfpass
            };
             let headers = {
                 "Content-Type": "application/json",
                 "Authorization": req.headers.token
             }
            axios.put(usersUrl, newPass, { headers: headers }).then(resp => {
                logger.info('---change password api response sent---');
                db.query('UPDATE keycloak_users set status= $2 where keycloak_username=$1;', [req.body.username, 'false'], (error, results) => {
                    if (error) {
                        throw error
                    }
                    res.status(201).json({ msg: "Password changed" });

                })

            }).catch(error => {
                res.status(error.response.status).json({ errMsg: error.response.data.errorMessage });
            })
        }



    } catch (e) {

        res.status(500).json({ errMsg: "Internal error. Please try again!!" });
    }
});


router.post('/setRoles', auth.authController, async (req, res) => {
    try {
        logger.info('---set roles api ---');
        var userId = req.body.userId;
        var headers = {
            "Content-Type": "application/json",
            "Authorization": req.headers.token
        }
        // check the default required actions enable for keycloak
        var actionsUrl = `${host}/auth/admin/realms/${realm}/authentication/required-actions`;

        await axios.get(actionsUrl, { headers: headers }).then(async actions => {
            // take only CONFIGURE_TOTP to check for two factor auth enable for the application
            let requiredActions = actions.data.filter(data => {
                return data.alias == 'CONFIGURE_TOTP'
            })
            // api to update the user 
            var updateUser = `${host}/auth/admin/realms/${realm}/users/${userId}`
            var actionsRequired = {
                requiredActions: [''],
            }
            // api to assign the role to user
            var usersUrl = `${host}/auth/admin/realms/${realm}/users/${userId}/role-mappings/realm`;

            var roleDetails = [
                {
                    id: req.body.role.id,
                    name: req.body.role.name
                }
            ];
            let otpConfig = req.body.otpConfig;
            // check for required actions configured -- CONFIGURE_TOTP and update the user for two factor auth
            if (otpConfig && req.body.role.name == 'report_viewer' && requiredActions[0].alias == 'CONFIGURE_TOTP' && requiredActions[0].enabled == true
                || req.body.role.name == 'admin' && requiredActions[0].alias == 'CONFIGURE_TOTP' && requiredActions[0].enabled == true) {
                // assign two factor auth only for admin and report_viewer roles not for emission user
                if (req.body.role.name != 'emission') {
                    actionsRequired.requiredActions.push('CONFIGURE_TOTP')
                }
                // updating user api call
                axios.put(updateUser, actionsRequired, { headers: headers }).then(async resp1 => {
                    // assigning roles to user api call                    
                    await axios.post(usersUrl, roleDetails, { headers: headers }).then(async resp => {
                        res.status(200).json({ msg: "Role assigned & configured otp" });
                    }).catch(error => {
                        res.status(409).json({ errMsg: error.response.data.errorMessage });
                    })
                }).catch(error => {
                    res.status(409).json({ errMsg: error.response.data.errorMessage });
                })
            } else {
                // default if required actions not configured
                await axios.post(usersUrl, roleDetails, { headers: headers }).then(resp => {
                    res.status(200).json({ msg: "Role assigned" });
                }).catch(error => {
                    res.status(409).json({ errMsg: error.response.data.errorMessage });
                })
            }
        }).catch(error => {
            res.status(409).json({ errMsg: error.response });
        })
    } catch (e) {
        logger.error(`Error :: ${e}`);
        res.status(500).json({ errMsg: "Internal error. Please try again!!" });
    }
});

router.get('/roles', auth.authController, async (req, res) => {
    try {
        logger.info('---get roles api ---');
        var usersUrl = `${host}/auth/admin/realms/${realm}/roles`;
        var headers = {
            "Content-Type": "application/json",
            "Authorization": req.headers.token
        }

        axios.get(usersUrl, { headers: headers }).then(resp => {
            var roles = resp.data.filter(role => {
                return role.name != 'uma_authorization' && role.name != 'offline_access'
            })
            logger.info('---get roles api response sent ---');
            res.status(201).json({ roles: roles });
        }).catch(error => {
            res.status(409).json({ errMsg: error.response.data.errorMessage });
        })
    } catch (e) {
        logger.error(`Error :: ${e}`);
        res.status(500).json({ errMsg: "Internal error. Please try again!!" });
    }
});

module.exports = router;
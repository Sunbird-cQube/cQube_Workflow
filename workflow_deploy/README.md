# Upgradation from 3.0 to 3.1
###  Prerequisites to install cQube:
- ubuntu 18.04 (supported)
- 32GB of System RAM (minimum requirement)
- 8 core CPU (minimum requirement)
- Domain name (with SSL)
- 1 TB Storage
### Reverse proxy rules The following ports have to be configured in the nginix # server with reverse proxy:

- Port 4200 should be proxied to the '/'
- Port 8080 should be proxied to the '/auth'
- Port 3000 should be proxied to the '/api'
- Port 8000 should be proxied to the '/data'
### Nginx - cQube server firewall configuration

- Port 4200 should be open from nginx to the cQube server
- Port 8080 should be open from nginx to the cQube server
- Port 3000 should be open from nginx to the cQube server
- Port 8000 should be open from nginx to the cQube server
### Openvpn - cQube server firewall configuration

- Port 9000 should be open from openvpn to the cQube server
- Port 4201 should be open from openvpn to the cQube server
- Port 3001 should be open from openvpn to the cQube server
Note: For Installation: follow the below steps directly, for upgradation follow the Upgradation: steps mentioned in the last section.


# cQube_Base Installation:
- open Terminal
- Navigate to the directory where cQube_Base has been downloaded or cloned 
- cd cQube_Base/
- git checkout release-3.1
- Copy the config.yml.template to config.yml cp config.yml.template config.yml
- Edit using nano config.yml
- If you are opting for storage_type as s3. Copy the aws_s3_config.yml.template to aws_s3_config.yml cp aws_s3_config.yml.template aws_s3_config.yml
- Edit using nano aws_s3_config.yml
- If you are opting for storage_type as local. Copy the local_storage_config.yml.template to local_storage_config.yml cp local_storage_config.yml.template local_storage_config.yml
- Fill the configuration details for the below mentioned list in config.yml (* all the values are mandatory)
- cQube_Base installation process installs the components in a sequence as mentioned below:
  - Installs Ansible
  - Installs Openjdk
  - Installs Python, pip and flask
  - Installs Postgresql
  - Installs NodeJS
  - Installs Angular and Chart JS
  - Installs Apache Nifi
  - Installs Keycloak
  - Installs Grafana
  - Installs Prometheus and node exporter
- Save and Close the file

### Configuration of infrastructure attributes and udise data indices, metrics:

- Based on the number of infrastructure attributes required by the state, configure the infrastructure report by filling the required fields in the file infrastructure_master.csv:

- To edit below mentioned infrastructure details nano infrastructure_master.csv

- Save and Close the file

- Based on the number of udise attributes required by the state, configure the udise_config.csv file by filling the required fields in the file udise_config.csv:

- To edit below mentioned UDISE details nano udise_config.csv

- Save and Close the file

- For more information to configure the weights & columns for udise/infrastucture, please refer operational document.

- Update the diksha parameters(api_url,token,encryption key,dataset name channel_id,org_id) in the development/python/cQube-raw-data-fetch-parameters.txt

- Give the following permission to the install.sh file

  chmod u+x install.sh

- Install cQube using the non-root user with sudo privilege

- Configuration filled in config.yml will be validated first. If there is any error during validation, you will be prompted with the appropriate error message and the installation will be aborted. Refer the error message and solve the errors appropriately, then re-run the installation script sudo ./install.sh

- Start the installation by running install.sh shell script file as mentioned below:

  sudo ./install.sh

Once installation is completed without any errors, you will be prompted the following message. CQube installed successfully!!

# Steps cQube_Workflow Installation:

- Open Terminal

- Navigate to the directory where cQube_Workflow has been downloaded or cloned

  cd cQube_Workflow/work_deploy/

  git checkout release-3.1
## Usecases folder structure
  - education_usecase
  - test_usecase
### if user opting for education_usecase open the education_uasecase folder 
- Copy the config.yml.template to config.yml cp config.yml.template config.yml
- Edit using nano config.yml
- enable datasources as true or false in datasource_config.yml and datasource_validation.sh, in datasource_validation.sh  An array of mandatory values should be same as datasource_config.yml file values. 
### if user opting for test_usecase open the test_uasecase folder
- Copy the config.yml.template to config.yml cp config.yml.template config.yml
- Edit using nano config.yml
- enable datasources as true or false in datasource_config.yml and datasource_validation.sh, in datasource_validation.sh  An array of mandatory values should be same as datasource_config.yml file values.
- if the user opting for new datasource.  should add new datasource name inside the datasource.yml file and datasource_validation.sh array list.
- Fill the configuration details for the below mentioned list in config.yml (* all the values are mandatory)

- cQube_Workflow installation process configuring the components in a sequence as mentioned below:

  - Configures Ansible
  - Configures Openjdk
  - Configures Python, pip and flask
  - Configures Postgresql
  - Configures NodeJS
  - Configures Angular and Chart JS
  - Configures Apache Nifi
  - Configures Keycloak
  - Configures Grafana
  - Configures Prometheus and node exporter


- Give the following permission to the install.sh file

  chmod u+x install.sh

- Install cQube using the non-root user with sudo privilege

- Configuration filled in config.yml will be validated first. If there is any error during validation, you will be prompted with the appropriate error message and the installation will be aborted. Refer the error message and solve the errors appropriately, then re-run the installation script sudo ./install.sh

- Start the installation by running install.sh shell script file as mentioned below:

  sudo ./install.sh

- Once installation is completed without any errors, you will be prompted the following message. CQube installed successfully!!

## Steps Post Installation:

### Steps to import Grafana dashboard

- Connect the VPN from local machine
Open https://<domain_name> from the browser and login with admin credentials
- Click on Admin Console
- Click on Monitoring details icon
- New tab will be loaded with grafana login page on http://<private_ip_of_cqube_server>:9000
- Default username is admin and password is admin
- Once your logged in change the password as per the need
- After logged in. Click on Settings icon from the left side menu.
- Click Data Sources
- Click on Add data source and select Prometheus
- In URL field, fill http://<private_ip_of_cqube_server>:9090 Optionally configure the other settings.
- Click on Save
- On home page, click on '+' symbol and select Import
- Click on Upload JSON file and select the json file which is located in git repository cQube/development/grafana/cQube_Monitoring_Dashboard.json and click Import
- Dashboard is succesfully imported to grafana with the name of cQube_Monitoring_Dashboard

## Uploading data to S3 Emission bucket:
- Create cqube_emission directory and place the data files as shown in file structure below inside the cqube_emission folder.
Master Files:

cqube_emission
|
├── block_master
│   └── block_mst.zip
│       └── block_mst.csv
├── cluster_master
│   └── cluster_mst.zip
│       └── cluster_mst.csv
├── district_master
│   └── district_mst.zip
│       └── district_mst.csv
├── school_master
│   └── school_mst.zip
│       └── school_mst.csv
├── pat
│   └── periodic_exam_mst.zip
│       └── periodic_exam_mst.csv
├── pat
│   └── periodic_exam_qst_mst.zip
│       └── periodic_exam_qst_mst.csv
├── diksha
│   └── diksha_tpd_mapping.zip
│       └── diksha_tpd_mapping.csv
├── diksha
│   └── diksha_api_progress_exhaust_batch_ids.zip
│       └── diksha_api_progress_exhaust_batch_ids.csv
├── sat
│   └── semester_exam_mst.zip
│       └── semester_exam_mst.csv
├── sat
│   └── semester_exam_qst_mst.zip
│       └── semester_exam_qst_mst.csv
├── sat
│   └── semester_exam_subject_details.zip
│       └── semester_exam_subject_details.csv
├── school_category
│   └── school_category_master.zip
│       └── school_category_master.csv
├── school_management
│   └── school_management_master.zip
│       └── school_management_master.csv
├── sat
│   └── semester_exam_subject_details.zip
│       └── semester_exam_subject_details.csv
├── sat
│   └── semester_exam_grade_details.zip
│       └── semester_exam_grade_details.csv
├── pat
│   └── periodic_exam_subject_details.zip
│       └── periodic_exam_subject_details.csv
├── pat
│   └── periodic_exam_grade_details.zip
│       └── periodic_exam_grade_details.csv
Transactional Files:

cqube_emission
|
├── student_attendance
│   └── student_attendance.zip
│       └── student_attendance.csv
├── teacher_attendance
│   └── teacher_attendance.zip
│       └── teacher_attendance.csv
├── user_location_master
│   └── user_location_master.zip
│       └── user_location_master.csv
├── inspection_master
│   └── inspection_master.zip
│       └── inspection_master.csv
├── infra_trans
│   └── infra_trans.zip
│       └── infra_trans.csv
├── diksha
│   └── diksha.zip
│       └── diksha.csv
├── pat
│   └── periodic_exam_result_trans.zip
│       └── periodic_exam_result_trans.csv
├── sat
│   └── semester_exam_result_trans.zip
│       └── semester_exam_result_trans.csv
- For udise data file structure, please refer the operational document.

- After creating the emission user, Update the emission user details mentioned below in cQube/development/python/client/config.py.

  - emission username
  - emission password
  - location of the cqube_emission directory where the files are placed as below. Example: /home/ubuntu/cqube_emission/
  - emission_url ( https://<domain_name>/data Note: URL depends upon the server configured in firewall which includes SSL and reverse proxy location)
- After completing the configuration. Save and close the file.

- Execute the client.py file located in cQube/development/python/client/ directory, as mentioned below to emit the data files to s3_emission bucket.

  python3 client.py
- Finally see the output in https://<domain_name>

# Upgradation:
### cQube_Base Upgradation:

- Open Terminal
- Navigate to the directory where cQube has been downloaded or cloned
cd cQube_Base/
 git checkout release-3.1
- Copy the upgradation_config.yml.template to upgradation_config.yml cp upgradation_config.yml.template upgradation_config.yml
- If you are opting for storage_type as s3. Copy the aws_s3_upgradation_config.yml.template to aws_s3_upgradationconfig.yml cp aws_s3_upgradation_config.yml.template aws_s3_upgradation_config.yml
- If you are opting for storage_type as local. Copy the local_storage_upgradation_config.yml.template to local_storage_upgradation_config.yml cp local_storageupgradation_upgradation_config.yml.template local_storage_upgradation_config.yml
- This script will update the below cQube components:

  - Creates & Updates table,sequence,index in postgresql database
  - Updates NodeJS server side code
  - Updates Angular and Chart JS client side code
  - Updates & configure Apache Nifi template
  - Updates & configure Keycloak
- Fill the configuration details in upgradation_config.yml (* all the values are mandatory, make sure to fill the same configuration details which were used during installation)

- Edit using nano upgradation_config.yml

- Save and Close the file

- Give the following permission to the upgrade.sh file

  chmod u+x upgrade.sh
- Run the script to update cQube using the non-root user with sudo privilege
Start the upgradation by running upgrade.sh shell script file as mentioned below:
  sudo ./upgrade.sh

Configuration filled in upgradation_config.yml will be validated first. If there is any error during validation, you will be prompted with the appropriate error message and the upgradation will be aborted. Refer the error message and solve the errors appropriately. Restart the upgradation processsudo ./upgrade.sh

Once upgradation is completed without any errors, you will be prompted the following message. CQube upgraded successfully!!

### cQube_Workflow Upgradation:

- Open Terminal
- Navigate to the directory where cQube has been downloaded or cloned
cd cQube_Workflow/work_deploy
 git checkout release-3.0
## Usecases folder structure
  - education_usecase
  - test_usecase
### if user opting for education_usecase open the education_uasecase folder 
- Copy the upgradation_config.yml.template to upgradation_config.yml cp upgradation_config.yml.template upgradation_config.yml
- Edit using nano config.yml
- enable datasources as true or false in datasource_config.yml and datasource_validation.sh, in datasource_validation.sh  An array of mandatory values should be same as datasource_config.yml file values. 
### if user opting for test_usecase open the test_uasecase folder
- Copy the upgradation_config.yml.template to upgradation_config.yml cp upgradation_config.yml.template upgradation_config.yml
- Edit using nano config.yml
- enable datasources as true or false in datasource_config.yml and datasource_validation.sh, in datasource_validation.sh  An array of mandatory values should be same as datasource_config.yml file values.
- if the user opting for new datasource.  should add new datasource name inside the datasource_config.yml file and datasource_validation.sh array list.
- Fill the configuration details for the below mentioned list in config.yml (* all the values are mandatory)

- This script will update the below cQube components:
  - Creates & Updates table,sequence,index in postgresql database
  - Updates NodeJS server side code
  - Updates Angular and Chart JS client side code
  - Updates & configure Apache Nifi template
  - Updates & configure Keycloak
- Fill the configuration details in upgradation_config.yml (* all the values are mandatory, make sure to fill the same configuration details which were used during installation)

- Edit using nano upgradation_config.yml

- Save and Close the file

- Give the following permission to the upgrade.sh file

  chmod u+x upgrade.sh
- Run the script to update cQube using the non-root user with sudo privilege
Start the upgradation by running upgrade.sh shell script file as mentioned below:
  sudo ./upgrade.sh

Configuration filled in upgradation_config.yml will be validated first. If there is any error during validation, you will be prompted with the appropriate error message and the upgradation will be aborted. Refer the error message and solve the errors appropriately. Restart the upgradation processsudo ./upgrade.sh

Once upgradation is completed without any errors, you will be prompted the following message. CQube upgraded successfully!!

[![N|Solid](https://cldup.com/dTxpPi9lDf.thumb.png)](https://nodesource.com/products/nsolid)

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

Dillinger is a cloud-enabled, mobile-ready, offline-storage compatible,
AngularJS-powered HTML5 Markdown editor.

- Type some Markdown on the left
- See HTML in the right
- ✨Magic ✨

## Features

- Import a HTML file and watch it magically convert to Markdown
- Drag and drop images (requires your Dropbox account be linked)
- Import and save files from GitHub, Dropbox, Google Drive and One Drive
- Drag and drop markdown and HTML files into Dillinger
- Export documents as Markdown, HTML and PDF

Markdown is a lightweight markup language based on the formatting conventions
that people naturally use in email.
As [John Gruber] writes on the [Markdown site][df1]

> The overriding design goal for Markdown's
> formatting syntax is to make it as readable
> as possible. The idea is that a
> Markdown-formatted document should be
> publishable as-is, as plain text, without
> looking like it's been marked up with tags
> or formatting instructions.

This text you see here is *actually- written in Markdown! To get a feel
for Markdown's syntax, type some text into the left window and
watch the results in the right.

## Tech

Dillinger uses a number of open source projects to work properly:

- [AngularJS] - HTML enhanced for web apps!
- [Ace Editor] - awesome web-based text editor
- [markdown-it] - Markdown parser done right. Fast and easy to extend.
- [Twitter Bootstrap] - great UI boilerplate for modern web apps
- [node.js] - evented I/O for the backend
- [Express] - fast node.js network app framework [@tjholowaychuk]
- [Gulp] - the streaming build system
- [Breakdance](https://breakdance.github.io/breakdance/) - HTML
to Markdown converter
- [jQuery] - duh

And of course Dillinger itself is open source with a [public repository][dill]
 on GitHub.

## Installation

Dillinger requires [Node.js](https://nodejs.org/) v10+ to run.

Install the dependencies and devDependencies and start the server.

```sh
cd dillinger
npm i
node app
```

For production environments...

```sh
npm install --production
NODE_ENV=production node app
```

## Plugins

Dillinger is currently extended with the following plugins.
Instructions on how to use them in your own application are linked below.

| Plugin | README |
| ------ | ------ |
| Dropbox | [plugins/dropbox/README.md][PlDb] |
| GitHub | [plugins/github/README.md][PlGh] |
| Google Drive | [plugins/googledrive/README.md][PlGd] |
| OneDrive | [plugins/onedrive/README.md][PlOd] |
| Medium | [plugins/medium/README.md][PlMe] |
| Google Analytics | [plugins/googleanalytics/README.md][PlGa] |

## Development

Want to contribute? Great!

Dillinger uses Gulp + Webpack for fast developing.
Make a change in your file and instantaneously see your updates!

Open your favorite Terminal and run these commands.

First Tab:

```sh
node app
```

Second Tab:

```sh
gulp watch
```

(optional) Third:

```sh
karma test
```

#### Building for source

For production release:

```sh
gulp build --prod
```

Generating pre-built zip archives for distribution:

```sh
gulp build dist --prod
```

## Docker

Dillinger is very easy to install and deploy in a Docker container.

By default, the Docker will expose port 8080, so change this within the
Dockerfile if necessary. When ready, simply use the Dockerfile to
build the image.

```sh
cd dillinger
docker build -t <youruser>/dillinger:${package.json.version} .
```

This will create the dillinger image and pull in the necessary dependencies.
Be sure to swap out `${package.json.version}` with the actual
version of Dillinger.

Once done, run the Docker image and map the port to whatever you wish on
your host. In this example, we simply map port 8000 of the host to
port 8080 of the Docker (or whatever port was exposed in the Dockerfile):

```sh
docker run -d -p 8000:8080 --restart=always --cap-add=SYS_ADMIN --name=dillinger <youruser>/dillinger:${package.json.version}
```

> Note: `--capt-add=SYS-ADMIN` is required for PDF rendering.

Verify the deployment by navigating to your server address in
your preferred browser.

```sh
127.0.0.1:8000
```

## License

MIT

**Free Software, Hell Yeah!**

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [dill]: <https://github.com/joemccann/dillinger>
   [git-repo-url]: <https://github.com/joemccann/dillinger.git>
   [john gruber]: <http://daringfireball.net>
   [df1]: <http://daringfireball.net/projects/markdown/>
   [markdown-it]: <https://github.com/markdown-it/markdown-it>
   [Ace Editor]: <http://ace.ajax.org>
   [node.js]: <http://nodejs.org>
   [Twitter Bootstrap]: <http://twitter.github.com/bootstrap/>
   [jQuery]: <http://jquery.com>
   [@tjholowaychuk]: <http://twitter.com/tjholowaychuk>
   [express]: <http://expressjs.com>
   [AngularJS]: <http://angularjs.org>
   [Gulp]: <http://gulpjs.com>

   [PlDb]: <https://github.com/joemccann/dillinger/tree/master/plugins/dropbox/README.md>
   [PlGh]: <https://github.com/joemccann/dillinger/tree/master/plugins/github/README.md>
   [PlGd]: <https://github.com/joemccann/dillinger/tree/master/plugins/googledrive/README.md>
   [PlOd]: <https://github.com/joemccann/dillinger/tree/master/plugins/onedrive/README.md>
   [PlMe]: <https://github.com/joemccann/dillinger/tree/master/plugins/medium/README.md>
   [PlGa]: <https://github.com/RahulHP/dillinger/blob/master/plugins/googleanalytics/README.md>


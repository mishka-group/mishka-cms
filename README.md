## Mishka CMS developed by Elixir language and Phoenix framework
Mishka project is a real-time and also API-based CMS which is developed using [Elixir](https://elixir-lang.org/) programming language; powered by [Phoenix framework](https://phoenixframework.org/). In this project it is tried to place all the dependencies in the Elixir language and avoid using external systems, and it has been this way so far except for the database section which we used [PostgreSQL](https://www.postgresql.org/).

> This is a free and open-source CMS and now is in the development and testing phase. Please use it with caution in your actual projects. If you are not familiar with Elixir and its deployment, do not worry! You can use the ready-made docker packages for the project that carry out all the actions needed for implementation on your system in the product development phase.

## Project Sub-systems:

Mishka CMS is made in form of Domain-driven design (DDD) which has got 6 sub-systems so far; some of which are not fully developed now. The following are the sub-systems:

#### 1. API sub-system: 


This section is to provide `API` for external software and includes almost all the developed sections. This section uses Token in most “endpoints” to connect, and data send and receive are based on JSON. Soon, the APIs related to real-time connection will be added.

#### 2. HTML sub-system: 

In this section similar to API sub-system the connection includes the user phase and for summary the graphical form of the site and admin panel and also sample template in the user section. It is fully built with `Phoenix LiveView` and one-page without refresh, and it is a real-time application. In this section, many connections are made using `GenServer` and equipped with caching system. It needs to be pointed out that some great parts of this project are stateful, and soon they grow bigger. 


####  3. File manager sub-system: 

This section is not gone to development but the goal behind it was to back up files and also file management which is in fact a media manager; with `real-time` upload and also user files management. This part of the panel is related to upload and is also active for the user panel that completely removes the need for `FTP`.

####  4. Content Management Sub-system: 

The main purpose of this system is also managing contents, so this section is independent and works as a tool for edit, and send contents to the site. We have to add that this system in the near future can link to many great other sections that will be added in form of independent projects. Because the bookmark section and also sharing and posting comments and reviewing comments publicly are made so that cover many sections of the system and there will not be any need for making new extensions. The goal in the next phases is to provide the users the ability to edit and send contents in forms of microblog and controllable.

####  5. User Management Sub-System: 

As the name says itself, this section manages users from registration to creating profile and also access to other parts of the project are defined in this section.

####  6. Database Management Sub-System: 

There are multiple types of temporary and permanent data saving and also is responsible for data back-up which is very important. All the sections that are created in this project or implemented as sub-systems, should be defined and tested in this section. This section can be used as a `micro-proxy` in the future. This section uses `PostgreSQL` as default and GenServer for caching.

---

It needs to be said that you can check our future plan and also the features that are going to be added in each version here: https://github.com/mishka-group/mishka-cms/projects

To test the CMS, seeds file is created that will be place at your database using package when running the project which includes test and also user test articles.

In case any error came up in the program, or you need any feature, please post your ideas in the project's issues and inform us; your cooperation in this free open-source project is very effective. 

https://github.com/mishka-group/mishka-cms/issues

---

After releasing 1.0.0 package version, the production state for the docker will also be place in the packages sections which will be ready to be used for your projects. In case you want to cooperate in our project and have no idea where to start, you can contact us through the following profile address: 

https://github.com/shahryarjb

---

In the near future the features related to the CMS will be explained in forms of video and text articles and if you want to test in projects, you just have to hit `mix test` command in the Elixir console and then this section will be connected to the “action” part in GitHub automatically.

### Required versions:

- Elixir 1.13.0 (compiled with Erlang/OTP 24)
- PostgreSQL v13

### Implementation:

After installing the dependencies above, now you can run the project using the following commands:

```elixir
mix ecto.create # (first you have to define your database information in the config file)
mix ecto.migrate
mix deps.get
mix deps.compile
mix assets.deploy
mix test
mix run apps/mishka_database/priv/repo/seeds.exs # in case you want content and test user to be made, run one time only
iex -S mix phx.server # every time you want to run the server
```

---

### Install and run in a few clicks:

-	Download the 1st stage of the project or clone from Git
-	in the next step, please go to the `cd mishka-cms/deployment/docker` directory
-	now run `chmod +x mishka.sh` command
-	and in this stage you can start setup using the ` ./mishka.sh –build` command

You install and run the program in two environments. First is `dev` and all the settings will be set automatically in the program; in this form the Mishka program will be accessible on the `127.0.0.1` local address.

> In case you do not enter anything and hit Enter key, as default the `Dev` will run.  
> Note: when the program is run in this state, it will not ask for any input while installing.

```elixir
Choose Environment Type ['prod or dev, defualt is dev']
```

After choosing the installation type, the Image starts to be made. When the operation is done successfully, the following message appears:

-	the green part addresses related to the program
-	the yellow part username and password for the database
-	the red part the keys related to the program
-	to run the Mishka `CMS` you can enter the following address in your browser:
`127.0.0.1:000` and also `API` with `4001` port.

The 2nd method is `prod`. The setting will be asked step by step. In case you do not enter any values and hit `enter` the default values will be added to the settings. 
In the terminal in multiple steps, the username, password, and database name of the program that you are going to connect will be asked from you and also the username, password for the PostgreSQL database which will be used as the `root` user in the database.

> **Note**: in this method, it is recommended to enter values in each required step so that avoid further security problems for the program. In this stage you have to enter your preferred IP address, domain name or subdomain. The `IP` address can be related to the internal or external network, such as a server.

### Example:
```elixir
127.0.0.1
192.168.1.10
172.16.16.10
10.0.5.150
94.94.94.94
86.86.86.86
.
.
.
example.com
test.example.com
```

> **Note**: in case you entered IP address and at the end of the operation, the program will be accessible in the port `4000` for the `CMS` and `4001` to the `API.` If not, the next step will be shown to get the address for the API service. 


> Note: the name for the API domain or subdomain should be different from the previous `CMS` related stages. 

```elixir
api.example.com
test2.example.com
```

---

After finishing the operation, you enter the shown addresses in the browser. We have to mention that after installation process being successful you see the admin panel images which is at the end of this article and also if you enter `API` section address, the following error appears:

```
 {"errors":{detail":"Not Found"}}
```

---

### Activating SSL for the production environment
In case you activated a domain or subdomain for the CMS and API address, you will be sent to the next stage, in which you will be asked a question related to SSL activation.

```elixir
Message: Do You Want to Enable SSL? (YES/NO) [default is Yes]:
```

In case the answer to the question above is `YES"`, in the next step you will be asked an email address so when the SSL certificate was about to expire, you will receive an email from `Let'secrypt`.

#### Enter Your Email Address:
In case the answer of the question above is anything but `YES`, the SSL certificate will not be generated for your domains.


### Images of the Admin Panel

![mishka-cms-admin](https://user-images.githubusercontent.com/8413604/129250846-35abcf82-bb65-432b-98be-e7a025607415.png)

### Images of the Site sample template

![mishka-cms-home-page](https://user-images.githubusercontent.com/8413604/129250980-ce45c35e-389a-435a-bf95-2829c7323862.png)

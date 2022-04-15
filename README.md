## Mishka CMS developed by Elixir language and Phoenix framework
Mishka project is a real-time and also API-based CMS which is developed using [Elixir](https://elixir-lang.org/) programming language; powered by [Phoenix framework](https://phoenixframework.org/). In this project it is tried to place all the dependencies in the Elixir language and avoid using external systems, and it has been this way so far except for the database section which we used [PostgreSQL](https://www.postgresql.org/).

> This is a free and open-source CMS and now is in the development and testing phase. Please use it with caution in your actual projects. If you are not familiar with Elixir and its deployment, do not worry! You can use the ready-made docker packages for the project that carry out all the actions needed for implementation on your system in the product development phase.


![mishka-cms-admin](https://user-images.githubusercontent.com/8413604/129250846-35abcf82-bb65-432b-98be-e7a025607415.png)



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

In the near future the features related to the CMS will be explained in forms of video and text articles and if you want to test in projects, you just have to hit `mix test` command in the Elixir console and then this section will be connected to the “action” part in GitHub automatically.

### Required versions:

- Elixir 1.13.3+ (compiled with Erlang/OTP 24)
- PostgreSQL v13

### Install and run in a few clicks:
We have prepared multiple ways to install and run the CMS in a few clicks to support different environments. Please see [the MsihkaCms installation wiki](https://github.com/mishka-group/mishka-cms/wiki/Installation).


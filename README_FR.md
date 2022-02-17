## Le système de gestion de contenu Mishka construit avec le langage de programmation Elixir et le framework Phoenix

Le projet Mishka est un système de gestion de contenu (SGC) en temps-réel et également un système basé sur API développé dans le langage [Elixir](https://elixir-lang.org/) et fonctionnant avec le [framework Phoenix](https://phoenixframework.org/). 
La plupart des dépendances ont été essayées pour être dans le langage d’Elixir et peu de systèmes externes ont été utilisés, et maintenant il en a été de même, sauf dans le cas d’une base de données qui utilise [PostgreSQL](https://www.postgresql.org/).

> Présentement, le système en question est un SGC gratuit et libre et est en phase de développement et de test. Veuillez l’utiliser avec précaution dans vos projets réels. 
Si vous n’êtes pas familier avec Elixir et son déploiement, vous pouvez utiliser des paquetages Docker prêts à l’emploi qui effectue tout le travail de mise en œuvre sur votre système dans la phase de développement et de produit.

## Les sous-systèmes du projet :

Mishka avec le nom français mishka-SGC a été créé comme une conception dirigée par le domaine (DDD) qui a six sous-systèmes jusqu’à présent, dont certains n’ont pas encore été entièrement développés. Pour plus d’informations, les sous-systèmes sont les suivants :

### 1. Sous-système API : 

Cette section est destinée à offrir des `API` aux logiciels externes et couvre presque toutes les sections intégrées. Cette section communique avec des jetons dans la plupart des extrémités et envoie et reçoit des données au format `JSON`. Des API de communication en temps réel seront bientôt ajoutées.

### 2. Sous-système HTML : 

Cette section, comme le sous-système API, comprend la connexion dans la section utilisateur et sous la forme d’un site graphique, et dispose d’un panel d’administration ainsi que d’un modèle type pour la section utilisateur. 
Il est entièrement construit avec `Phoenix LiveView` et est une page unique sans rafraîchissement et en temps réel. Dans cette section, de nombreuses connexions ont été effectuées par `GenServer` et il dispose d’un système de cache. Il faut noter que de grandes parties de ce projet sont en cours de réalisation et que bientôt ces parties seront plus grandes.


### 3. Sous-système de management de fichiers : 

Cette section n’est pas encore entrée dans la phase de développement, mais le but de sa construction est de sauvegarder les fichiers ainsi que la gestion des fichiers est en fait un gestionnaire de médias ; En téléchargeant en temps réel ainsi que la gestion des fichiers des utilisateurs. Cette section fournit également le panel de téléchargement à la section utilisateur, ce qui élimine complètement le besoin de `FTP`.

### 4. Sous SGC : 

L’objectif principal de ce système est de gérer le contenu. Par conséquent, cette section est indépendante et est responsable de l’édition et de l’envoi de contenu sur le site. Il convient de noter que ce système peut être connecté à de nombreuses autres parties qui seront ajoutées en tant que projet autonome à l’avenir. 
La section des signets et le partage et la publication et la visualisation des commentaires en public ont été créés pour couvrir de nombreuses parties de ce système, alors il n’est pas nécessaire de construire un plugin à nouveau. 
L’objectif des prochaines phases est que ce système donne aux utilisateurs le pouvoir de modifier et de publier du contenu sous forme de micro blogs et qu’il soit très contrôlable.


### 5. Sous-système de management des utilisateurs : 

Comme le nom de cette section l’indique clairement, elle gère les utilisateurs de l’inscription à la création du profil, et l’accès aux sections du projet est également défini et attribué dans cette section.


### 6. Sous-système de management des bases de données : 

Dans ce système, il existe plusieurs types de stockage temporaire et permanent de l’information, et la responsabilité de la sauvegarde est très importante dans cette section. 
Toutes les parties qui sont créées dans ce projet ou qui sont mises en œuvre en tant que sous-système doivent également être introduites et testées dans cette partie. Cette section peut être utilisée plus tard comme un micro service. Cette section utilise PostgreSQL par défaut et utilise GenServer pour la mise en cache.

---

Il convient de noter que vous pouvez voir le programme futur dans notre section plan, ainsi que les fonctionnalités qui seront ajoutées dans chaque version.
https://github.com/mishka-group/mishka-cms/projects

Pour expérimenter ce SGC, le fichier `Seeds` sera placé dans votre base de données au moment de la mise en œuvre du projet par le biais du paquetage, qui comprend le contenu de test ainsi que l’utilisateur de test.

Si vous voyez une erreur dans le programme ou si vous avez des fonctionnalités en tête, veuillez nous le faire savoir dans la section des problèmes de votre projet. Votre coopération dans ce projet open source gratuit peut être très efficace.

https://github.com/mishka-group/mishka-cms/issues

**Attention : Pour communiquer avec le service d’assistance, veuillez utiliser uniquement la langue anglaise.**

---

Après la publication de la version 0.0.1 du paquetage, le mode de production pour Docker sera inclus dans la section des paquetages, qui est prêt à être utilisé dans vos projets. Si vous souhaitez collaborer au projet et ne savez pas par où commencer, vous pouvez contacter le profil suivant.
https://github.com/shahryarjb

---

À l’avenir, les fonctionnalités de ce SGC seront expliquées dans plus de contenus et de vidéos. Si vous souhaitez tester dans le projet, il vous suffit de taper mix test dans la console Elixir. Plus tard, cette section sera connectée à la section action de GitHub pour que le travail soit automatisé pour vous.


### Les versions utilisées :

- Elixir 1.12.0 (compiled with Erlang/OTP 24)
- Postgres v13

### Configuration :

Vous pouvez maintenant établir le projet avec ces quelques commandes après avoir installé les dépendances mentionnées.


```elixir
mix deps.get
mix deps.compile
mix ecto.create # Vous devez d’abord entrer les informations relatives à votre base de données dans le fichier de configuration
mix ecto.migrate
mix assets.deploy
mix test
mix run apps/mishka_database/priv/repo/seeds.exs # N’exécutez qu’une seule fois si vous voulez que le contenu et l’utilisateur de test soient corrects.
iex -S mix phx.server # Exécuter le serveur quand vous le voulez.
```

### Exécuter et installer en quelques clics avec l’aide de Docker :     

* Téléchargez la première étape du projet ou clonez-la du Git.
* Dans l’étape suivante, veuillez aller dans le chemin d’accès cd et le répertoire `cd mishka-cms/deployment/docker`
* Maintenant exécutez la commande `chmod + x mishka.sh`
* Vous pouvez commencer l’installation avec la commande `mishka.sh --build` dans cette étape

Vous pouvez installer et exécuter le logiciel dans deux environnements. Le premier mode est `dev` et tous les paramètres seront inclus dans le programme par défaut. Dans ce mode, le programme Mishka sera disponible à l’adresse locale `127.0.0.1`

> Si vous n’entrez rien, mais appuyez sur le bouton Enter, le mode dev sera exécuté par défaut.
> Attention : Quand le programme s’exécute dans ce mode, il ne prend aucune donnée de votre part pendant l’installation.

```elixir
Choose Environment Type ['prod or dev, defualt is dev']
```

L’image commence à être créée après avoir choisi le genre d’installation. Quand l’opération est terminée avec succès, le message suivant vous sera affiché.

- La section verte correspond aux adresses associées au programme
- La section jaune correspond au nom d’utilisateur et au mot de passe de la base de données
- La section rouge correspond aux clés de l’application
- Pour établir Mishka SGC vous pouvez entrer l’adresse suivante dans votre navigateur : `127.0.0.1:4000` ainsi que l’API avec le port `4001`


Le second mode est le mode `prod`. Si vous n’entrez pas de valeur, il vous sera demandé de procéder aux réglages étape par étape, et si vous appuyez sur le bouton Enter, les valeurs par défaut seront définies dans les réglages.
Dans votre terminal, en quelques étapes, il vous sera demandé le nom d’utilisateur, le mot de passe et le nom de la base de données à laquelle le programme se connecte. En plus, il vous sera demandé le nom d’utilisateur et le mot de passe de la base de données PostgreSQL, qui est utilisée comme utilisateur `root` dans la base de données.

> Attention : Dans le cas présent, il est recommandé d’entrer les valeurs demandées à chaque étape afin d’éviter des problèmes de sécurité pour votre application. Dans cette étape, vous devez saisir l’adresse `IP`, le nom de domaine ou le sous-domaine que vous voulez. Une adresse `IP` peut être associée à un réseau interne ou externe, comme un serveur.

### Exemple :

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

> Attention : Si vous entrez une adresse IP à la fin de l’installation, le programme sera disponible sur deux ports, 4000 pour SGC et 4001 pour API. Sinon, l’étape suivante pour obtenir l’adresse pour le service API sera également affichée.
> Attention : Le nom de domaine ou le sous-domaine API doit être différent de l’étape précédente dans le SGC.

```
api.example.com
test2.example.com
```

---


Après l’opération, vous pouvez entrer les adresses affichées dans le navigateur. Il convient de noter qu’une fois les étapes réussies, vous pouvez voir les images du panel d’administration qui sont placées à la fin du contenu. Si vous cliquez sur l’adresse de la section `API`, vous pouvez voir l’erreur suivante.

```elixir
{"errors":{detail":"Not Found"}}
```

### Activation de SSL pour l’environnement de production :

Si vous avez activé un domaine ou un sous-domaine pour le SGC et l’adresse API, vous passerez à l’étape suivante, où vous serez interrogé sur l’activation de SSL.

### Le message :

```elixir 
Do You Want to Enable SSL? (YES/NO) [default is Yes]:.
```

Si la réponse à la question précédente est Yes, une adresse électronique vous sera demandée à l’étape suivante jusqu’à ce qu’un courriel soit émis par `Let’sEncrypt` pendant l’expiration des certificats `SSL`.

```elixir
Enter Your Email Address:
```

Si la réponse à la question sur l’activation SSL est autre que Yes, un certificat SSL ne sera pas généré pour vos domaines.


### Une image du panel d’administration

![mishka-cms-admin](https://user-images.githubusercontent.com/8413604/129250846-35abcf82-bb65-432b-98be-e7a025607415.png)

### Une image du modèle de site

![mishka-cms-home-page](https://user-images.githubusercontent.com/8413604/129250980-ce45c35e-389a-435a-bf95-2829c7323862.png)
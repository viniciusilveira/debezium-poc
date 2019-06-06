# DebeziumConsumer

Exemplo de utilização do `Debezium` + a lib `Kaffee` para stream de dados de um banco mysql.

# Como Rodar

Para iniciar o `debezium`, o `mysql`, `Apache kafka` e `Apache Zookeeper`:

```console
$ docker-compose up --build
```

Este comando irá iniciar os 4 contaners em uma rede para se comunicarem, após todos iniciarem, é necessário restaurar o banco de dados que será utilizado no container do mysql. Este container possui um volume localmente, então só a necessidade de restauar o banco uma única vez, a não ser que o volume local seja deletado.

```console
$ mysql -h 0.0.0.0 -P 3306 -u crm_digital_user -pdbpasswd
```

Após isso podemos criar nossos conectores atráves de requests HTTP disponiveis [Kafka Connect REST Interface](https://docs.confluent.io/current/connect/references/restapi.html):

```console
$ curl -X POST \
  http://localhost:8083/connectors \
  -H 'Accept: */*' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/json' \
  -H 'Host: localhost:8083' \
  -H 'Postman-Token: 781b063c-6f2f-4888-8071-0406b4a1822c,14321c9c-cc3d-4d00-8341-2921290acfa0' \
  -H 'User-Agent: PostmanRuntime/7.13.0' \
  -H 'accept-encoding: gzip, deflate' \
  -H 'cache-control: no-cache' \
  -H 'content-length: 584' \
  -d '{
	"name": "elastic-search",
	"config": {
		"connector.class": "io.debezium.connector.mysql.MySqlConnector",
		"tasks.max": "1",
		"database.hostname": "mysql",
		"database.port": "3306",
		"database.user": "crm_digital_user",
		"database.password": "crmpasswd",
		"database.server.id": "223344",
		"database.server.name": "crm",
		"database.whitelist": "crm_digital",
		"table.whitelist": "crm_digital.vtiger_products,crm_digital.vtiger_productscf",
		"database.history.kafka.bootstrap.servers": "kafka:9092",
		"database.history.kafka.topic": "dbhistory.db_name"
	}
}'
```
Nos campos `database.hostname`, `database.port`, `database.user` e `database.password` devem ser passados os dados de conexão com o banco de dados e nos campos `database.whitelist` e `table.whitelist` devem ser passados os dados do banco e das tabelas que irão ser monitorados.

E para visualizar o status do connector:

```console
$ curl -X GET \
  http://localhost:8083/connectors/elastic-search/status \
  -H 'Accept: */*' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Host: localhost:8083' \
  -H 'Postman-Token: 268b8fc6-8ec2-46c8-b7a2-4f403cca44a1,f22ea413-9bfa-42f0-8c01-80e5b79e01e6' \
  -H 'User-Agent: PostmanRuntime/7.13.0' \
  -H 'accept-encoding: gzip, deflate' \
  -H 'cache-control: no-cache'
```
Para visualizar o log de atualizações no kafka:

```console
# connectar no container do kafka
$ docker exec -it poc-debezium_connect_1 bash

# listar todos os tópicos
$ bin/kafka-topics.sh --zookeeper zookeeper:2181 --list

# monitorar um tópico específico
$ bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic topic.name
```

No exemplo acima, qualquer alteração efetuada no banco de dados ou tabelas no whitelist do connector irá gerar uma saída na tela.

Para inicializar o consumidor utilizando a aplicação elixir, primeiro é necessário fazer as configurações do connector no arquivo `config/config.exs`

```elixir
# Alterar `example-consumer` para um nome que irá identificar seu `consumer_group` no kafka.
# Alterar `topic.name` para o nome do(s) tópico(s) que deseja monitorar

config :kaffe,
  consumer: [
    endpoints: [localhost: 9092],
    topics: ["topic.name"],
    consumer_group: "example-consumer",
    message_handler: DebeziumConsumer,
    async_message_ack: true,
    start_with_earliest_message: true,
    max_bytes: 500_000
  ]
```

Após configurar sua conexão inicie a aplicação elixir:

```console
iex -S mix run
```


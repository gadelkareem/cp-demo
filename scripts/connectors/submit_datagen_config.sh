#!/bin/bash

HEADER="Content-Type: application/json"
DATA=$( cat << EOF
{
  "name": "datagen-orders-avro2",
  "config": {
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "kafka.topic": "orders",
    "schema.string": "{ \"connect.name\": \"ksql.orders\", \"fields\": [ { \"name\": \"ordertime\", \"type\": \"long\" }, { \"name\": \"orderid\", \"type\": \"int\" }, { \"name\": \"itemid\", \"type\": \"string\" }, { \"name\": \"orderunits\", \"type\": \"double\" }, { \"name\": \"address\", \"type\": { \"connect.name\": \"ksql.address\", \"fields\": [ { \"name\": \"city\", \"type\": \"string\" }, { \"name\": \"state\", \"type\": \"string\" }, { \"name\": \"zipcode\", \"type\": \"long\" } ], \"name\": \"address\", \"type\": \"record\" } } ], \"name\": \"orders\", \"namespace\": \"ksql\", \"type\": \"record\" }",
    "key.ignore": true,
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schema.registry.url": "https://schemaregistry:8085",
    "value.converter.schema.registry.ssl.truststore.location": "/etc/kafka/secrets/kafka.client.truststore.jks",
    "value.converter.schema.registry.ssl.truststore.password": "confluent",
    "value.converter.basic.auth.credentials.source": "USER_INFO",
    "value.converter.basic.auth.user.info": "connectorSA:connectorSA",
    "producer.override.sasl.jaas.config": "org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required username=\"connectorSA\" password=\"connectorSA\" metadataServerUrls=\"https://kafka1:8091,https://kafka2:8092\";",
    "tasks.max": "1"
  }
}
EOF
)

docker-compose exec connect curl -X POST -H "${HEADER}" --data "${DATA}" --cert /etc/kafka/secrets/connect.certificate.pem --key /etc/kafka/secrets/connect.key --tlsv1.2 --cacert /etc/kafka/secrets/snakeoil-ca-1.crt -u connectorSubmitter:connectorSubmitter https://connect:8083/connectors || exit 1



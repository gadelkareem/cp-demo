#!/bin/bash

HEADER="Content-Type: application/json"
DATA=$( cat << EOF
{
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "kafka.topic": "orders",
    "quickstart": "orders",
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url": "https://schemaregistry:8085",
    "value.converter.schema.registry.ssl.truststore.location": "/etc/kafka/secrets/kafka.client.truststore.jks",
    "value.converter.schema.registry.ssl.truststore.password": "confluent",
    "value.converter.basic.auth.credentials.source": "USER_INFO",
    "value.converter.basic.auth.user.info": "connectorSA:connectorSA",
    "producer.override.sasl.jaas.config": "org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required username=\"connectorSA\" password=\"connectorSA\" metadataServerUrls=\"https://kafka1:8091,https://kafka2:8092\";",
    "tasks.max": "1"
}
EOF
)

docker-compose exec connect curl -X PUT -H "${HEADER}" --data "${DATA}" --cert /etc/kafka/secrets/connect.certificate.pem --key /etc/kafka/secrets/connect.key --tlsv1.2 --cacert /etc/kafka/secrets/snakeoil-ca-1.crt -u connectorSubmitter:connectorSubmitter https://connect:8083/connectors/datagen-orders/config || exit 1



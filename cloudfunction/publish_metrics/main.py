import base64
import functions_framework
import os

from cloudevents.http import CloudEvent
from google.cloud import pubsub_v1


@functions_framework.cloud_event
def publish_metrics(cloud_event: CloudEvent) -> None:
    destination_project_id = os.getenv('TARGET_GOOGLE_CLOUD_PROJECT')
    destination_topic_name = os.getenv('TARGET_TOPIC_NAME')

    pubsub_message = base64.b64decode(cloud_event.data["message"]["data"]).decode()

    publisher = pubsub_v1.PublisherClient()
    destination_topic_path = f'projects/{destination_project_id}/topics/{destination_topic_name}'
    future = publisher.publish(destination_topic_path, data=pubsub_message.encode('utf-8'))
    future.result()

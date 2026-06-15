import json
import threading
from typing import Any, Callable

import zmq

from globals.consts.const_strings import ConstStrings
from globals.consts.consts import Consts
from globals.consts.logger_messages import LoggerMessages
from infrastructure.factories.logger_factory import LoggerFactory
from infrastructure.interfaces.izmq_pub_sub_manager import IZmqPubSubManager


class ZmqPubSubManager(IZmqPubSubManager):
    def __init__(self, pub_host: str, pub_port: int, sub_host: str, sub_port: int):
        self._context = zmq.Context()

        self._pub_socket = self._context.socket(zmq.PUB)
        self._pub_address = f"{ConstStrings.BASE_TCP_CONNECTION_STRINGS}{pub_host}:{pub_port}"

        self._sub_socket = self._context.socket(zmq.SUB)
        self._sub_address = f"{ConstStrings.BASE_TCP_CONNECTION_STRINGS}{sub_host}:{sub_port}"

        self._is_running = False
        self._subscriber_thread: threading.Thread | None = None
        self._subscriptions: dict[str,
                                  list[Callable[[dict[str, Any]], None]]] = {}
        self._logger = LoggerFactory.get_logger_manager()
        self._lock = threading.Lock()

    def start(self) -> None:
        self._pub_socket.bind(self._pub_address)
        self._logger.log(ConstStrings.LOG_NAME_DEBUG,
                         LoggerMessages.ZMQ_PUB_SOCKET_BOUND.format(self._pub_address))

        self._sub_socket.connect(self._sub_address)
        self._logger.log(ConstStrings.LOG_NAME_DEBUG,
                         LoggerMessages.ZMQ_SUB_SOCKET_CONNECTED.format(self._sub_address))

        self._is_running = True
        self._subscriber_thread = threading.Thread(
            target=self._subscriber_handle, daemon=True)
        self._subscriber_thread.start()
        self._logger.log(ConstStrings.LOG_NAME_DEBUG,
                         LoggerMessages.ZMQ_PUB_SUB_MANAGER_STARTED)

    def stop(self) -> None:
        if not self._is_running:
            return
        self._is_running = False
        if self._subscriber_thread:
            self._subscriber_thread.join()
        self._context.term()

        self._logger.log(ConstStrings.LOG_NAME_DEBUG,
                         LoggerMessages.ZMQ_PUB_SUB_MANAGER_STOPPED)

    def publish(self, topic: str, data: dict[str, Any]) -> None:
        if not self._is_running:
            self._logger.log(ConstStrings.LOG_NAME_DEBUG,
                             LoggerMessages.ZMQ_MANAGER_NOT_RUNNING)
            return

        try:
            json_data = json.dumps(data)
            self._pub_socket.send_string(topic, flags=zmq.SNDMORE)
            self._pub_socket.send_string(json_data)
        except Exception as e:
            self._logger.log(ConstStrings.LOG_NAME_DEBUG,
                             LoggerMessages.ZMQ_PUBLISH_ERROR.format(e))

    def subscribe(self, topic: str, callback: Callable[[dict[str, Any]], None]) -> None:
        with self._lock:
            if topic not in self._subscriptions:
                self._sub_socket.setsockopt_string(zmq.SUBSCRIBE, topic)
                self._subscriptions[topic] = []
            self._subscriptions[topic].append(callback)
        self._logger.log(ConstStrings.LOG_NAME_DEBUG,
                         LoggerMessages.ZMQ_SUBSCRIBED_TO_TOPIC.format(topic))

    def _subscriber_handle(self) -> None:
        poller = zmq.Poller()
        poller.register(self._sub_socket, zmq.POLLIN)

        while self._is_running:
            try:
                socks = dict(poller.poll(timeout=Consts.ZMQ_SUB_POLL_TIMEOUT))
                if self._sub_socket in socks and socks[self._sub_socket] == zmq.POLLIN:
                    topic_bytes, message_bytes = self._sub_socket.recv_multipart()
                    topic = topic_bytes.decode(ConstStrings.DECODE_FORMAT)
                    message_str = message_bytes.decode(
                        ConstStrings.DECODE_FORMAT)

                    with self._lock:
                        for sub_topic, callbacks in self._subscriptions.items():
                            if topic.startswith(sub_topic):
                                try:
                                    data = json.loads(message_str)
                                    for callback in callbacks:
                                        try:
                                            callback(data)
                                        except Exception as e:
                                            self._logger.log(ConstStrings.LOG_NAME_DEBUG,
                                                             LoggerMessages.ZMQ_CALLBACK_ERROR.format(sub_topic, e))
                                except json.JSONDecodeError:
                                    self._logger.log(ConstStrings.LOG_NAME_DEBUG,
                                                     LoggerMessages.ZMQ_JSON_DECODE_ERROR.format(topic, message_str))
                                break
            except zmq.ZMQError as e:
                if e.errno == zmq.ETERM:
                    break
                self._logger.log(ConstStrings.LOG_NAME_DEBUG,
                                 LoggerMessages.ZMQ_SUBSCRIBER_THREAD_ERROR.format(e))
                break

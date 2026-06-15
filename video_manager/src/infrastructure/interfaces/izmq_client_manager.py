from abc import ABC, abstractmethod

from model.data_classes.zmq_request import ZmqRequest
from model.data_classes.zmq_response import ZmqResponse


class IZmqClientManager(ABC):
    @abstractmethod
    def start(self) -> None:
        pass

    @abstractmethod
    def stop(self) -> None:
        pass

    @abstractmethod
    def send_request(self, request: ZmqRequest) -> ZmqResponse:
        pass

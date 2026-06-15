from abc import ABC, abstractmethod
from typing import Dict

from model.data_classes.zmq_response import ZmqResponse


class IApiRouter(ABC):

    @property
    @abstractmethod
    def resource(self) -> str:
        pass

    @abstractmethod
    def handle_operation(self, operation: str, data: Dict | None) -> ZmqResponse:
        pass

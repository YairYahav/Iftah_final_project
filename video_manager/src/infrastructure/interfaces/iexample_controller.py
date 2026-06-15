from abc import ABC, abstractmethod
from typing import Dict

from model.data_classes.zmq_response import ZmqResponse


class IExampleController(ABC):
    @abstractmethod
    def example_function(self, data: Dict | None = None) -> ZmqResponse:
        pass

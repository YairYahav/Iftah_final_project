from abc import ABC, abstractmethod
from typing import Any


class ILoggerManager(ABC):

    @abstractmethod
    def log(self, log_name: str, msg: str, level: Any) -> None:
        pass

    @abstractmethod
    def set_level(self, log_name: str, level: Any) -> None:
        pass

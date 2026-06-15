from abc import ABC, abstractmethod
from typing import Any, Callable


class IZmqPubSubManager(ABC):
    @abstractmethod
    def start(self) -> None:
        pass

    @abstractmethod
    def stop(self) -> None:
        pass

    @abstractmethod
    def publish(self, topic: str, data: dict[str, Any]) -> None:
        pass

    @abstractmethod
    def subscribe(self, topic: str, callback: Callable[[dict[str, Any]], None]) -> None:
        pass

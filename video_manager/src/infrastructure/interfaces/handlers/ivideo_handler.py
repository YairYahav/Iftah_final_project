from abc import ABC, abstractmethod
import numpy as np


class IVideoHandler(ABC):

    @abstractmethod
    def start(self) -> None:
        pass

    @abstractmethod
    def read_frame(self) -> np.ndarray:
        pass
    
    @abstractmethod
    def write_frame(self, frame: np.ndarray) -> None:
        pass

    @abstractmethod
    def stop(self) -> None:
        pass

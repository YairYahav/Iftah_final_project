from abc import ABC, abstractmethod


class IAlgorithmManager(ABC):

    @abstractmethod
    def start_algorithm(self):
        pass

    @abstractmethod
    def stop_algorithm(self):
        pass
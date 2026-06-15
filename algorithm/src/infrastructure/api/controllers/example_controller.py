from typing import Dict
from model.data_classes.zmq_response import ZmqResponse
from globals.enums.response_status import ResponseStatus
from globals.consts.const_strings import ConstStrings

from infrastructure.interfaces.iexample_controller import IExampleController
from infrastructure.factories.logger_factory import LoggerFactory
from globals.consts.logger_messages import LoggerMessages


class ExampleController(IExampleController):
    def __init__(self) -> None:
        pass

    def example_function(self, data: Dict | None = None) -> ZmqResponse:
        try:
            LoggerFactory.get_logger_manager().log(ConstStrings.LOG_NAME_DEBUG,
                                                   LoggerMessages.EXAMPLE_DATA_RECEIVED.format(data))
            return ZmqResponse(
                status=ResponseStatus.SUCCESS,

            )
        except Exception as e:
            return ZmqResponse(
                status=ResponseStatus.ERROR,
                data={ConstStrings.ERROR_MESSAGE: ConstStrings.ERROR_EXAMPLE_FUNCTION}
            )

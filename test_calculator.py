import calculator as cal
import pytest


def test_lambda_handler():
    assert cal.lambda_handler({"op":"+", "num1":12, "num2": 5}, {}) == {"statusCode": 200,"result": 17}



@pytest.mark.parametrize("test_input, expected", [
    ({"op":"+", "num1":12, "num2": 5}, (200,17)),
    ({"op":"+", "num1":12}, (400, "Insufficient input parameters")),
    ({"op":"+", "num2": 5}, (400, "Insufficient input parameters")),
    ({"num1":12, "num2": 5}, (400, "Insufficient input parameters")),
])
def test_calculator(test_input, expected):
    assert cal.calculator(test_input) == expected




@pytest.mark.parametrize("test_op, test_num1, test_num2, expected", [
    ("+", "12", "5", (200, 17)),
    ("-", "12", "5", (200, 7)),
    ("*", "12", "5", (200, 60)),
    ("/", "12", "5", (200, 2.4)),
    ("/", "12", "0", (400, "Denominator can't be zero")),
    ("^", "12", "5", (400, "Can't understand what you are trying to do")),
    ("/", "12fA", "5", (400, "Bad Request")),
])
def test_calc(test_op, test_num1, test_num2, expected):
    assert cal.calc(test_op, test_num1, test_num2) == expected





@pytest.mark.parametrize("test_op, test_num1, test_num2, expected", [
    ("+", "12", "5", True),
    ("+", "12", "5EF", False),
])
def test_validate_input(test_op, test_num1, test_num2, expected):
    assert cal.validate_input(test_op, test_num1, test_num2) == expected



@pytest.mark.parametrize("test_text, expected", [
    ("123", True),
    ("NAN", False),
    ("5EF", False),
])
def test_to_float(test_text, expected):
    assert cal.to_float(test_text) == expected

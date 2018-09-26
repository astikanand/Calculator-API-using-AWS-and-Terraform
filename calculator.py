import json

def lambda_handler(event, context):
    print("Entered into Lambda")
    print("Received event: " + json.dumps(event, indent=4))

    statusCode, result = calculator(event)

    return {
        "statusCode": statusCode,
        "result": result
    }



def calculator(input):
    if('op' in input and 'num1' in input and 'num2' in input):
        op = input['op']
        num1 = input['num1']
        num2 = input['num2']
        statusCode, result = calc(op, num1, num2)
    else:
        statusCode = 400
        result = "Insufficient input parameters"

    return statusCode, result



def calc(op, num1, num2):
    valid_input = validate_input(op, num1, num2)
    if valid_input:
        statusCode = 200
        print("Start Calculating")
        num1 = float(num1)
        num2 = float(num2)
        if (op=="+"):
            result = num1 + num2
        elif (op=='-'):
            result = num1 - num2
        elif (op=='*'):
            result = num1 * num2
        elif (op=="/"):
            if(int(num2) == 0):
                statusCode = 400
                result = "Denominator can't be zero"
            else:
                result = num1 / num2
        else:
            statusCode = 400
            result = "Can't understand what you are trying to do"

        print("End Calculating")
    else:
        statusCode = 400
        result = "Bad Request"

    return statusCode, result


def validate_input(op, num1, num2):
    if(op and to_float(num1) and to_float(num2)):
        print("Valid input parameters")
        return True
    else:
        print("Inalid input parameters")
        return False


def to_float(text):
    text = str(text)
    try:
        float(text)
        if text.isalpha():
            return False
        return True
    except ValueError:
        return False

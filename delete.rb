require 'json'
require 'aws-sdk'


def ret(status, body)
    { statusCode: status, body: body, headers: {
        "Access-Control-Allow-Origin" => '*', "Access-Control-Allow-Headers" => "*" }}
end

def lambda_handler(event:, context:)
    if event["httpMethod"] == "OPTIONS"
        return ret(200, "thanks cors xoxo")
    end
    puts event.inspect
    begin
        if event["body"] == nil
            return ret(400, "empty request")
        end
        body = JSON.parse(event["body"])
    rescue JSON::ParserError
        return ret(400, "invalid json")
    end
    unless body.include?("Key") and body["Key"].is_a?(String) and
           body.include?("User") and body["User"].is_a?(String)
        return ret(400, "invalid request")
    end

    params = {
        table_name: "notes",
        key: {
            Key: body["Key"],
  #          User: body["User"]
        }
    }
    dynamodb = Aws::DynamoDB::Client.new
    result = dynamodb.get_item(params)
    if ! result.empty? and result.item.include?("Data")
        dynamodb.delete_item(params)
        return ret(200, JSON.generate("succesfully deleted information"))
    else
        return ret(404, JSON.generate("key does not existing"))
    end
end

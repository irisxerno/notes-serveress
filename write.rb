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
    begin
        if event["body"] == nil
            return ret(200, "empty request")
        end

        body = JSON.parse(event["body"].to_s)
    rescue JSON::ParserError
        return ret(400, event["body"])
    end
    unless body.include?("Key")  and body["Key"].is_a?(String)  and
           body.include?("Data") and body["Data"].is_a?(String) and
           body.include?("User") and body["User"].is_a?(String)
        return ret(400, "invalid request")
    end
    item = {
        Key: body["Key"],
        User: body["User"],
        Data: body["Data"]
    }
    params = {
        table_name: "notes",
        item: item
    }
    dynamodb = Aws::DynamoDB::Client.new
    dynamodb.put_item(params)

    return ret(200, "successfull request")

end

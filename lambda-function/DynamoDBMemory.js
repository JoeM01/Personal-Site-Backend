const { DynamoDBClient, PutItemCommand, QueryCommand } = require("@aws-sdk/client-dynamodb");
const { marshall, unmarshall } = require("@aws-sdk/util-dynamodb");

const { BaseListChatMessageHistory } = require("@langchain/core/chat_history");
const { mapChatMessagesToStoredMessages, mapStoredMessagesToChatMessages,   BaseMessage, StoredMessage, } = require("@langchain/core/messages");


class DynamoDBMemory extends BaseListChatMessageHistory {
    constructor({ tableName, sessionId, region }) {
        super({ sessionId });
        this.tableName = tableName;
        this.sessionId = sessionId;
        this.client = new DynamoDBClient({ region });
    }


    async addMessage(message) {            
        const serializedMessage = mapChatMessagesToStoredMessages([message])[0];
        const params = {
            TableName: this.tableName,
            Item: marshall({
                sessionId: this.sessionId,
                timeStamp: new Date().toISOString(),
                message: serializedMessage,
            }),
        };
        try {
            await this.client.send(new PutItemCommand(params));
        } catch (error) {
            console.error("Error saving message to DynamoDB:", error);
        }
    }

    async getMessages() {
        const params = {
            TableName: this.tableName,
            KeyConditionExpression: "sessionId = :sessionId",
            ExpressionAttributeValues: {
                ":sessionId": { S: this.sessionId },
            },
            ScanIndexForward: true, // Sort by Timestamp ascending
        };

        try {
            const data = await this.client.send(new QueryCommand(params));
            const messages = data.Items.map(item => unmarshall(item).message);
            return mapStoredMessagesToChatMessages(messages);
        } catch (error) {
            console.error("Error retrieving messages from DynamoDB:", error);
            return [];
        }
    }
}

module.exports = DynamoDBMemory;

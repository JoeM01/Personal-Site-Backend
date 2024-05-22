const { ChatOpenAI } = require('@langchain/openai');
const { HumanMessage, SystemMessage, AIMessage } = require('@langchain/core/messages');
const { StringOutputParser } = require('@langchain/core/output_parsers');
const { ChatPromptTemplate } = require('@langchain/core/prompts');
const DynamoDBMemory = require('./DynamoDBMemory'); // Import the custom memory class


const parser = new StringOutputParser();
const apiKey = process.env.OPENAI_API_KEY;



const model = new ChatOpenAI({
        apiKey,
        modelName: 'gpt-4o',
    });
    
const systemTemplate = "You are a helpful assistant who remembers all details the user shares with you.";    

const promptTemplate = ChatPromptTemplate.fromMessages([
    ["system", systemTemplate],
    ["placeholder", "{chat_history}"],
    ["user", "{text}"],
]);

const chain = promptTemplate.pipe(model).pipe(parser);



exports.handler = async (event) => {
    try {
        const body = JSON.parse(event.body); // Parse the incoming JSON payload
        console.log('Received payload:', body); // Log the received payload
        
        const memory = new DynamoDBMemory({
            tableName: "langchain-memory",
            sessionId: event.key1, // Or some other unique identifier for the conversation
            region: "us-east-1",
            
        });
        
        const chat_memory = await memory.getMessages();
        console.log("Chat History:", chat_memory);

        const response = await chain.invoke({chat_history: chat_memory  , text: event.key2 });
        await memory.addMessage(new HumanMessage(event.key2));
        await memory.addMessage(new AIMessage(response));

        return {
            statusCode: 200,
            body: JSON.stringify({ response }),
        };
    } catch (error) {
        console.error('Error generating response:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Error generating response' }),
        };
    } 
};

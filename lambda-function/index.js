const fs = require('fs');
const path = require('path');
const { ChatOpenAI } = require('@langchain/openai');
const { HumanMessage, AIMessage } = require('@langchain/core/messages');
const { StringOutputParser } = require('@langchain/core/output_parsers');
const { ChatPromptTemplate, FewShotChatMessagePromptTemplate } = require('@langchain/core/prompts');
const DynamoDBMemory = require('./DynamoDBMemory'); // Import the custom memory class
const examples = require('./examples'); // Import examples from the separate file

const parser = new StringOutputParser();
const apiKey = process.env.OPENAI_API_KEY;

const model = new ChatOpenAI({
    apiKey,
    modelName: 'gpt-4o',
});

// Read the system template from the file
const systemTemplate = fs.readFileSync(path.join(__dirname, 'systemTemplate.txt'), 'utf8');

// This is a prompt template used to format each individual example.
const examplePrompt = ChatPromptTemplate.fromMessages([
  ["human", "{input}"],
  ["ai", "{output}"],
]);

const fewShotPrompt = new FewShotChatMessagePromptTemplate({
  examplePrompt,
  examples,
  inputVariables: [], 
});

const finalPrompt  = ChatPromptTemplate.fromMessages([
    ["system", systemTemplate],
    fewShotPrompt,
    ["placeholder", "{chat_history}"],
    ["user", "{text}"],
]);

const chain = finalPrompt .pipe(model).pipe(parser);

exports.handler = async (event) => {
    try {
        const body = JSON.parse(event.body); // Parse the incoming JSON payload
        console.log('Received payload:', body); // Log the received payload
        
        console.log('Key1:', body.key1);
        console.log('Key2:', body.key2);

        const memory = new DynamoDBMemory({
            tableName: "langchain-memory",
            sessionId: body.key1, // Or some other unique identifier for the conversation
            region: "us-east-1",
        });
        
        const chat_memory = await memory.getMessages();
        console.log("Chat History:", chat_memory);

        const response = await chain.invoke({ chat_history: chat_memory, text: body.key2 });
        await memory.addMessage(new HumanMessage(body.key2));
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

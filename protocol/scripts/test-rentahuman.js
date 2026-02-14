const https = require('https');

// RentAHuman API Mock
// Real endpoint: https://api.rentahuman.ai/v1 (Requires API Key)
const API_BASE = "https://mock-api.rentahuman.ai/v1"; 
const API_KEY = process.env.RENTAHUMAN_API_KEY || "mock_key";

async function listHumans() {
    console.log(`[GET] ${API_BASE}/humans`);
    console.log("Headers:", { Authorization: `Bearer ${API_KEY}` });
    
    // Simulating Response
    const mockResponse = [
        { id: "h_123", location: "Arizona", skills: ["photography", "driving"], rate: 25 },
        { id: "h_456", location: "New York", skills: ["notary"], rate: 50 }
    ];
    console.log("Response:", JSON.stringify(mockResponse, null, 2));
    return mockResponse;
}

async function createTask(humanId, instructions) {
    console.log(`[POST] ${API_BASE}/tasks`);
    const payload = {
        human_id: humanId,
        instructions: instructions, 
        payout_usdc: 50
    };
    console.log("Payload:", JSON.stringify(payload, null, 2));

    // Simulating Response
    const mockResponse = {
        task_id: "t_789",
        status: "pending_acceptance",
        human_id: humanId
    };
    console.log("Response:", JSON.stringify(mockResponse, null, 2));
    return mockResponse;
}

// Execution Flow
(async () => {
    console.log("--- RentAHuman API Implementation Mock ---");
    const humans = await listHumans();
    if (humans.length > 0) {
        const target = humans[0];
        console.log(`Selecting human: ${target.id} in ${target.location}`);
        await createTask(target.id, "Go to 123 Main St and take a photo of the mailbox.");
    }
})();

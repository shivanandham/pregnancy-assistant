// Postman Test Scripts for Luma Pregnancy Assistant API
// Add these scripts to the "Tests" tab of each request

// Common test for all requests
pm.test("Response time is less than 2000ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(2000);
});

pm.test("Response has success field", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('success');
});

// Health Check Tests
if (pm.info.requestName === "Health Check") {
    pm.test("Status code is 200", function () {
        pm.response.to.have.status(200);
    });
    
    pm.test("Response contains database info", function () {
        const jsonData = pm.response.json();
        pm.expect(jsonData).to.have.property('database');
        pm.expect(jsonData).to.have.property('environment');
    });
}

// User Profile Tests
if (pm.info.requestName === "Create User Profile") {
    pm.test("Status code is 201", function () {
        pm.response.to.have.status(201);
    });
    
    pm.test("Response contains user profile data", function () {
        const jsonData = pm.response.json();
        pm.expect(jsonData.data).to.have.property('id');
        pm.expect(jsonData.data).to.have.property('height');
        pm.expect(jsonData.data).to.have.property('weight');
        
        // Store user ID for later use
        pm.environment.set("userId", jsonData.data.id);
    });
}

if (pm.info.requestName === "Get User Profile") {
    pm.test("Status code is 200", function () {
        pm.response.to.have.status(200);
    });
    
    pm.test("Response contains profile data", function () {
        const jsonData = pm.response.json();
        if (jsonData.data) {
            pm.expect(jsonData.data).to.have.property('id');
            pm.expect(jsonData.data).to.have.property('bmi');
        }
    });
}

// Pregnancy Data Tests
if (pm.info.requestName === "Create Pregnancy Data") {
    pm.test("Status code is 201", function () {
        pm.response.to.have.status(201);
    });
    
    pm.test("Response contains pregnancy data", function () {
        const jsonData = pm.response.json();
        pm.expect(jsonData.data).to.have.property('id');
        pm.expect(jsonData.data).to.have.property('currentWeek');
        pm.expect(jsonData.data).to.have.property('progressPercentage');
        
        // Store pregnancy ID for later use
        pm.environment.set("pregnancyId", jsonData.data.id);
    });
}

// Symptom Tests
if (pm.info.requestName === "Create Symptom") {
    pm.test("Status code is 201", function () {
        pm.response.to.have.status(201);
    });
    
    pm.test("Response contains symptom data", function () {
        const jsonData = pm.response.json();
        pm.expect(jsonData.data).to.have.property('id');
        pm.expect(jsonData.data).to.have.property('type');
        pm.expect(jsonData.data).to.have.property('severity');
        
        // Store symptom ID for later use
        pm.environment.set("symptomId", jsonData.data.id);
    });
}

if (pm.info.requestName === "Get All Symptoms") {
    pm.test("Status code is 200", function () {
        pm.response.to.have.status(200);
    });
    
    pm.test("Response is an array", function () {
        const jsonData = pm.response.json();
        pm.expect(jsonData.data).to.be.an('array');
    });
}

// Appointment Tests
if (pm.info.requestName === "Create Appointment") {
    pm.test("Status code is 201", function () {
        pm.response.to.have.status(201);
    });
    
    pm.test("Response contains appointment data", function () {
        const jsonData = pm.response.json();
        pm.expect(jsonData.data).to.have.property('id');
        pm.expect(jsonData.data).to.have.property('title');
        pm.expect(jsonData.data).to.have.property('isUpcoming');
        
        // Store appointment ID for later use
        pm.environment.set("appointmentId", jsonData.data.id);
    });
}

// Weight Entry Tests
if (pm.info.requestName === "Create Weight Entry") {
    pm.test("Status code is 201", function () {
        pm.response.to.have.status(201);
    });
    
    pm.test("Response contains weight data", function () {
        const jsonData = pm.response.json();
        pm.expect(jsonData.data).to.have.property('id');
        pm.expect(jsonData.data).to.have.property('weight');
        pm.expect(jsonData.data).to.have.property('weightInPounds');
        
        // Store weight ID for later use
        pm.environment.set("weightId", jsonData.data.id);
    });
}

// Chat Tests
if (pm.info.requestName === "Send Chat Message") {
    pm.test("Status code is 200", function () {
        pm.response.to.have.status(200);
    });
    
    pm.test("Response contains chat data", function () {
        const jsonData = pm.response.json();
        pm.expect(jsonData.data).to.have.property('id');
        pm.expect(jsonData.data).to.have.property('content');
        pm.expect(jsonData.data).to.have.property('type');
        
        // Store chat message ID for later use
        pm.environment.set("chatMessageId", jsonData.data.id);
    });
}

if (pm.info.requestName === "Get Chat History") {
    pm.test("Status code is 200", function () {
        pm.response.to.have.status(200);
    });
    
    pm.test("Response is an array", function () {
        const jsonData = pm.response.json();
        pm.expect(jsonData.data).to.be.an('array');
    });
}

// Knowledge Base Tests
if (pm.info.requestName === "Get Knowledge Facts") {
    pm.test("Status code is 200", function () {
        pm.response.to.have.status(200);
    });
    
    pm.test("Response is an array", function () {
        const jsonData = pm.response.json();
        pm.expect(jsonData.data).to.be.an('array');
    });
}

if (pm.info.requestName === "Search Knowledge") {
    pm.test("Status code is 200", function () {
        pm.response.to.have.status(200);
    });
    
    pm.test("Response contains search results", function () {
        const jsonData = pm.response.json();
        pm.expect(jsonData.data).to.be.an('array');
    });
}

// Error handling tests
pm.test("Response has proper error handling", function () {
    if (pm.response.code >= 400) {
        const jsonData = pm.response.json();
        pm.expect(jsonData).to.have.property('success');
        pm.expect(jsonData).to.have.property('message');
    }
});

// Performance tests
pm.test("Response time is acceptable", function () {
    pm.expect(pm.response.responseTime).to.be.below(5000);
});

// Content type tests
pm.test("Content-Type is application/json", function () {
    pm.expect(pm.response.headers.get("Content-Type")).to.include("application/json");
});

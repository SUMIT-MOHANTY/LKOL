document.addEventListener('DOMContentLoaded', function() {
    // Check system health
    checkHealth();
});

async function checkHealth() {
    const healthDiv = document.getElementById('health-info');

    try {
        // Simulate health check
        const mockHealth = {
            status: "running",
            uptime: "0:05:32",
            timestamp: new Date().toISOString()
        };

        healthDiv.innerHTML = `
            <p><strong>Status:</strong> ${mockHealth.status}</p>
            <p><strong>Uptime:</strong> ${mockHealth.uptime}</p>
            <p><strong>Last Update:</strong> ${new Date(mockHealth.timestamp).toLocaleString()}</p>
        `;

        // Add visual indicator
        healthDiv.className = 'health-ok';
    } catch (error) {
        healthDiv.innerHTML = '<p class="error">Health check failed - static mode</p>';
        healthDiv.className = 'health-error';
    }
}

// Add CSS for health indicators
const style = document.createElement('style');
style.textContent = `
    .health-ok {
        border-left: 4px solid #22c55e;
        background: #f0fdf4;
    }

    .health-error {
        border-left: 4px solid #ef4444;
        background: #fef2f2;
    }
`;
document.head.appendChild(style);

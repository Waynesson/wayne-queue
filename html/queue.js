window.addEventListener('message', function(event) {
    const container = document.getElementById('queue-container');
    
    if (event.data.type === "showQueue") {
        if (event.data.display) {
            const position = document.getElementById('position');
            const total = document.getElementById('total');
            const progress = document.getElementById('progress');
            const message = document.getElementById('message');
            const errorContainer = document.getElementById('error-container');

            container.classList.remove('hidden');
            position.textContent = event.data.position;
            total.textContent = event.data.total;
            message.textContent = event.data.message;

            // Show Discord button if it's the community role error message
            if (event.data.message === "You must have the Community Role to join the server!") {
                errorContainer.classList.remove('hidden');
            } else {
                errorContainer.classList.add('hidden');
            }

            // Calculate progress percentage
            const progressWidth = ((event.data.total - event.data.position + 1) / event.data.total) * 100;
            progress.style.width = `${progressWidth}%`;

            // Add connecting animation if connecting
            if (event.data.message.includes("Connecting")) {
                message.classList.add('connecting');
            } else {
                message.classList.remove('connecting');
            }
        } else {
            container.classList.add('hidden');
        }
    }
});
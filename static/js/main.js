// Main JavaScript file
document.addEventListener('DOMContentLoaded', function() {
    console.log('Flask application loaded successfully!');

    // Example: Add event listeners or other interactive elements
    const headings = document.querySelectorAll('h1, h2');

    headings.forEach(heading => {
        heading.addEventListener('click', function() {
            this.style.color = '#' + Math.floor(Math.random()*16777215).toString(16);
        });
    });
});

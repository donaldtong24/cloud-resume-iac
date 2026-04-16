const counter = document.getElementById("count")
async function updateCounter() {
    try {
        let response = await fetch("https://qtm3ke6mfmgbqgzuvnx7gndn7e0ezeul.lambda-url.us-east-1.on.aws/");
        let data = await response.json();
        counter.innerHTML = `Views: ${data.count}`;
    } catch (error) {
        console.error("Error fetching counter:", error);
        counter.innerHTML = "Couldn't read views";
    }
}
updateCounter();
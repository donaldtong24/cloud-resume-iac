const counter = document.getElementById("count")
async function updateCounter() {
    try {
        let response = await fetch("LAMBDA_URL_PLACEHOLDER");
        let data = await response.json();
        counter.innerHTML = `Views: ${data.count}`;
    } catch (error) {
        console.error("Error fetching counter:", error);
        counter.innerHTML = "Couldn't read views";
    }
}
updateCounter();
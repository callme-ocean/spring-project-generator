document.addEventListener("DOMContentLoaded", function() {
    // Find the controllers checkbox by its id ("controllers")
    var controllersCheckbox = document.getElementById("controllers");
    // The API selection section to toggle
    var apiSection = document.getElementById("apiSelectionSection");

    // Function to toggle API section visibility
    function toggleApiSection() {
        if (controllersCheckbox && controllersCheckbox.checked) {
            apiSection.style.display = "block";
        } else {
            apiSection.style.display = "none";
        }
    }

    // Add event listener to the controllers checkbox if it exists
    if (controllersCheckbox) {
        controllersCheckbox.addEventListener("change", toggleApiSection);
        // Initial toggle on page load
        toggleApiSection();
    }

    // Attach click events to all package and API cards for toggling checkboxes
    document.querySelectorAll('.package-card').forEach(function(card) {
        card.addEventListener("click", function() {
            // Toggle for package cards
            var pkg = this.getAttribute("data-pkg");
            if (pkg) {
                var checkbox = document.getElementById(pkg);
                if (checkbox) {
                    checkbox.checked = !checkbox.checked;
                    // If the clicked package is 'controllers', update the API section visibility.
                    if (pkg.toLowerCase() === "controllers") {
                        toggleApiSection();
                    }
                }
            }
            // Toggle for API cards
            var api = this.getAttribute("data-api");
            if (api) {
                var checkbox = document.getElementById(api);
                if (checkbox) {
                    checkbox.checked = !checkbox.checked;
                }
            }
        });
    });
});

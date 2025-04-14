(function () {
    'use strict';

    window.addEventListener('load', function () {
        // Fetch all the forms we want to apply custom Bootstrap validation styles to
        var forms = document.getElementsByClassName('needs-validation');
        // Loop over them and prevent submission
        var validation = Array.prototype.filter.call(forms, function (form) {
            form.addEventListener('submit', function (event) {
                event.preventDefault(); // always stop the browser’s default submit behavior

                if (!form.checkValidity()) {
                    event.stopPropagation();
                    form.classList.add('was-validated');
                    return;
                }

                form.classList.add('was-validated');

                const street = document.getElementById('street').value;
                const city = document.getElementById('city').value;
                const state = document.getElementById('state').value;
                const zipcode = document.getElementById('zipcode').value;

                const queryParams = new URLSearchParams({
                    street,
                    city,
                    state,
                    zipcode
                });

                fetch('/forecasts/search?' + queryParams.toString())
                    .then(response => response.json())
                    .then(data => {
                        // Clear old results
                        const $results = $('#forecast-results');
                        $results.empty();

                        console.log(data);

                        const cacheNotice = data.using_cache ? '<p class="text-info mb-1" style="text-align: right; font-size: 12px">Using Cache <input type="checkbox"  checked></input></p>' : '';

                        // Reload DOM with fetched data
                        const card = `
                              <div class="card mb-3" style="width: 100%;">
                                <div class="card-body">
                                  <h2 class="card-title">Current: ${data.current_temp}°C</h2>
                                  <p>Average: ${data.avg_temp}°C</p>
                                  <p>High: ${data.max_temp}°C</p>
                                  <p>Low: ${data.min_temp}°C</p>
                                  ${cacheNotice}
                                </div>
                              </div>
                            `;
                        $results.html(card);

                        // Display the results
                        $results.removeClass('d-none');
                    })
                    .catch(error => {
                        console.error("API Error:", error);
                        alert("Error fetching forecast.");
                    });
            }, false);
        });
    }, false);


})();
document.addEventListener('DOMContentLoaded', () => {
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');
    const headerTitle = document.getElementById('headerTitle');
    const liveriesContent = document.getElementById('liveries-content');
    const extrasContent = document.getElementById('extras-content');

    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            tabButtons.forEach(btn => btn.classList.remove('active'));
            
            button.classList.add('active');

            tabContents.forEach(content => content.classList.add('hidden'));
            
            const tabName = button.getAttribute('data-tab');
            document.getElementById(`${tabName}-content`).classList.remove('hidden');
            
            headerTitle.textContent = tabName === 'liveries' ? 'Vehicle Liveries' : 'Vehicle Extras';
        });
    });

    const closeBtn = document.querySelector('.close-btn');
    if (closeBtn) {
        closeBtn.addEventListener('click', () => {
            fetch(`https://${GetParentResourceName()}/exit`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            });
        });
    }

    document.addEventListener('click', (e) => {
        const radio = e.target.closest('input[type="radio"]');
        if (radio && radio.name === 'livery') {
            fetch(`https://${GetParentResourceName()}/changeLivery`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    id: parseInt(radio.id.replace('livery', '')) - 1
                })
            });
        }
    });

    let isUpdating = false;

    document.addEventListener('change', (e) => {
        const checkbox = e.target.closest('input[type="checkbox"]');
        if (checkbox && checkbox.closest('.switch') && !isUpdating) {
            const extraId = parseInt(checkbox.dataset.extraId);
            console.log('Checkbox changed for Extra:', extraId);
            console.log('New checkbox state:', checkbox.checked);
            
            fetch(`https://${GetParentResourceName()}/toggleExtra`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    id: extraId,
                    enabled: checkbox.checked
                })
            });
        }
    });

    window.addEventListener('message', (event) => {
        const item = event.data;
        
        if (item.type === "ui") {
            const container = document.getElementById('container');
            const vehicleSetup = document.querySelector('.vehicle-setup');
            
            if (item.status) {
                const liveriesTab = document.querySelector('[data-tab="liveries"]');
                const extrasTab = document.querySelector('[data-tab="extras"]');
                const liveriesContent = document.getElementById('liveries-content');
                const extrasContent = document.getElementById('extras-content');
                
                liveriesTab.classList.add('active');
                extrasTab.classList.remove('active');
                
                liveriesContent.classList.remove('hidden');
                extrasContent.classList.add('hidden');
                
                headerTitle.textContent = 'Vehicle Liveries';
                
                container.style.display = "block";
                vehicleSetup.style.display = "flex";
            } else {
                container.style.display = "none";
                vehicleSetup.style.display = "none";
            }
        }
        
        if (item.type === "update") {
            console.log('Received update:', item);
            
            liveriesContent.innerHTML = item.liveries.map((livery, index) => `
                <div class="option">
                    <input type="radio" name="livery" id="livery${livery.id + 1}" ${livery.current ? 'checked' : ''}>
                    <label for="livery${livery.id + 1}">${livery.name}</label>
                </div>
            `).join('');

            isUpdating = true;
            extrasContent.innerHTML = item.extras.map(extra => {
                const isEnabled = extra.enabled === 1 || extra.enabled === true;
                console.log('Setting extra', extra.id, 'to', isEnabled, '(original value:', extra.enabled, ')');
                return `
                    <div class="option" data-extra-id="${extra.id}">
                        <label class="switch">
                            <input type="checkbox" ${isEnabled ? 'checked' : ''} data-extra-id="${extra.id}">
                            <span class="slider"></span>
                        </label>
                        <span>Extra ${extra.id}</span>
                    </div>
                `;
            }).join('');
            setTimeout(() => { isUpdating = false; }, 100);
        }
    });

    document.addEventListener('keyup', (e) => {
        if (e.key === "Escape") {
            fetch(`https://${GetParentResourceName()}/exit`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            });
        }
    });
});

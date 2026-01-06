// ========================================
// FleetCheck v2 - Inspection Form Logic
// ========================================

// Configuration
const CONFIG = {
    WEBHOOK_URL: 'https://n8n.srv1200431.hstgr.cloud/webhook/fleetcheck-antifat',
    MAX_FILE_SIZE: 10 * 1024 * 1024, // 10MB
    COMPRESSION_QUALITY: 0.8
};

// State
let uploadedPhotos = {
    front: null,
    back: null,
    right: null,
    left: null
};

let selectedDriver = null;
let selectedVehicle = null;

// ========================================
// Initialize
// ========================================
document.addEventListener('DOMContentLoaded', async function() {
    console.log('🚀 FleetCheck v2 initializing...');
    
    // Load drivers
    await loadDrivers();
    
    // Set up event listeners
    document.getElementById('driverSelect').addEventListener('change', handleDriverChange);
    document.getElementById('vehicleSelect').addEventListener('change', handleVehicleChange);
    document.getElementById('inspectionForm').addEventListener('submit', handleFormSubmit);
    document.getElementById('notes').addEventListener('input', updateCharCount);
    
    console.log('✅ FleetCheck v2 initialized');
});

// ========================================
// Load Drivers from Supabase
// ========================================
async function loadDrivers() {
    try {
        console.log('📥 Loading drivers from Supabase...');
        
        const { data: drivers, error } = await supabase
            .from('drivers')
            .select('*')
            .eq('is_active', true)
            .order('full_name');
        
        if (error) throw error;
        
        const driverSelect = document.getElementById('driverSelect');
        driverSelect.innerHTML = '<option value="">-- اختر السائق --</option>';
        
        if (drivers && drivers.length > 0) {
            drivers.forEach(driver => {
                const option = document.createElement('option');
                option.value = driver.id;
                option.textContent = `${driver.full_name} (${driver.driver_code})`;
                option.dataset.driver = JSON.stringify(driver);
                driverSelect.appendChild(option);
            });
            
            console.log(`✅ Loaded ${drivers.length} drivers`);
        } else {
            driverSelect.innerHTML = '<option value="">لا يوجد سائقين متاحين</option>';
            console.warn('⚠️ No drivers found');
        }
        
    } catch (error) {
        console.error('❌ Error loading drivers:', error);
        const driverSelect = document.getElementById('driverSelect');
        driverSelect.innerHTML = '<option value="">خطأ في تحميل السائقين</option>';
        showError('فشل تحميل قائمة السائقين');
    }
}

// ========================================
// Handle Driver Selection
// ========================================
async function handleDriverChange(e) {
    const driverSelect = e.target;
    const selectedOption = driverSelect.options[driverSelect.selectedIndex];
    
    if (!selectedOption || !selectedOption.dataset.driver) {
        // Hide vehicle section
        document.getElementById('vehicleSection').classList.add('hidden');
        selectedDriver = null;
        return;
    }
    
    // Get driver data
    selectedDriver = JSON.parse(selectedOption.dataset.driver);
    console.log('👤 Driver selected:', selectedDriver);
    
    // Load assigned vehicles
    await loadAssignedVehicles(selectedDriver.id);
}

// ========================================
// Load Driver's Assigned Vehicles
// ========================================
async function loadAssignedVehicles(driverId) {
    try {
        console.log('🚗 Loading assigned vehicles for driver:', driverId);
        
        // Get vehicle assignments
        const { data: assignments, error } = await supabase
            .from('driver_vehicle_assignments')
            .select(`
                vehicle_id,
                vehicles (
                    id,
                    van_code,
                    plate_number,
                    location,
                    status
                )
            `)
            .eq('driver_id', driverId)
            .eq('is_current', true);
        
        if (error) throw error;
        
        const vehicleSelect = document.getElementById('vehicleSelect');
        const vehicleSection = document.getElementById('vehicleSection');
        const vehicleInfo = document.getElementById('vehicleInfo');
        
        vehicleSelect.innerHTML = '<option value="">-- اختر المركبة --</option>';
        
        if (assignments && assignments.length > 0) {
            assignments.forEach(assignment => {
                const vehicle = assignment.vehicles;
                const option = document.createElement('option');
                option.value = vehicle.id;
                option.textContent = `${vehicle.van_code} - ${vehicle.plate_number}`;
                option.dataset.vehicle = JSON.stringify(vehicle);
                vehicleSelect.appendChild(option);
            });
            
            // Show vehicle section
            vehicleSection.classList.remove('hidden');
            
            if (assignments.length === 1) {
                // Auto-select if only one vehicle
                vehicleSelect.selectedIndex = 1;
                handleVehicleChange({ target: vehicleSelect });
                vehicleInfo.textContent = `✓ مخصص لك مركبة واحدة فقط`;
            } else {
                vehicleInfo.textContent = `لديك ${assignments.length} مركبات مخصصة`;
            }
            
            console.log(`✅ Loaded ${assignments.length} assigned vehicle(s)`);
        } else {
            vehicleSelect.innerHTML = '<option value="">لا توجد مركبات مخصصة</option>';
            vehicleSection.classList.remove('hidden');
            vehicleInfo.textContent = '⚠️ لم يتم تعيين أي مركبة لك';
            console.warn('⚠️ No vehicles assigned to this driver');
        }
        
    } catch (error) {
        console.error('❌ Error loading vehicles:', error);
        showError('فشل تحميل المركبات المخصصة');
    }
}

// ========================================
// Handle Vehicle Selection
// ========================================
function handleVehicleChange(e) {
    const vehicleSelect = e.target;
    const selectedOption = vehicleSelect.options[vehicleSelect.selectedIndex];
    
    if (selectedOption && selectedOption.dataset.vehicle) {
        selectedVehicle = JSON.parse(selectedOption.dataset.vehicle);
        console.log('🚗 Vehicle selected:', selectedVehicle);
    } else {
        selectedVehicle = null;
    }
}

// ========================================
// Photo Upload Handling
// ========================================
async function handlePhotoUpload(input, side) {
    const file = input.files[0];
    if (!file) return;
    
    // Validate
    if (file.size > CONFIG.MAX_FILE_SIZE) {
        alert('حجم الملف كبير جداً. الحد الأقصى 10 ميجابايت');
        input.value = '';
        return;
    }
    
    try {
        // Compress and convert to base64
        const compressedBase64 = await compressImage(file);
        
        // Store
        uploadedPhotos[side] = {
            base64: compressedBase64,
            filename: file.name,
            size: file.size
        };
        
        // Update UI
        const previewDiv = document.getElementById(`${side}Preview`);
        const parentDiv = previewDiv.parentElement;
        
        parentDiv.style.backgroundImage = `url(${compressedBase64})`;
        parentDiv.classList.add('has-image');
        
        previewDiv.innerHTML = `
            <div class="absolute inset-0 bg-black bg-opacity-40 rounded-lg flex items-center justify-center">
                <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
            </div>
        `;
        
        console.log(`✅ Photo uploaded: ${side}`);
        
    } catch (error) {
        console.error(`❌ Error uploading ${side} photo:`, error);
        alert('حدث خطأ أثناء رفع الصورة');
        input.value = '';
    }
}

// Compress image
function compressImage(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        
        reader.onload = function(e) {
            const img = new Image();
            
            img.onload = function() {
                const canvas = document.createElement('canvas');
                let width = img.width;
                let height = img.height;
                
                const maxWidth = 1920;
                if (width > maxWidth) {
                    height = (height * maxWidth) / width;
                    width = maxWidth;
                }
                
                canvas.width = width;
                canvas.height = height;
                
                const ctx = canvas.getContext('2d');
                ctx.drawImage(img, 0, 0, width, height);
                
                const compressedBase64 = canvas.toDataURL('image/jpeg', CONFIG.COMPRESSION_QUALITY);
                resolve(compressedBase64);
            };
            
            img.onerror = reject;
            img.src = e.target.result;
        };
        
        reader.onerror = reject;
        reader.readAsDataURL(file);
    });
}

// ========================================
// Form Submission
// ========================================
async function handleFormSubmit(e) {
    e.preventDefault();
    
    // Validate
    if (!selectedDriver) {
        showError('يرجى اختيار السائق');
        return;
    }
    
    if (!selectedVehicle) {
        showError('يرجى اختيار المركبة');
        return;
    }
    
    if (!Object.values(uploadedPhotos).every(p => p !== null)) {
        showError('يرجى رفع جميع الصور (4 جهات)');
        return;
    }
    
    if (!document.getElementById('declaration').checked) {
        showError('يرجى الموافقة على إقرار حالة المركبة');
        return;
    }
    
    // Disable button
    const submitBtn = document.getElementById('submitBtn');
    submitBtn.disabled = true;
    submitBtn.innerHTML = `
        <div class="spinner"></div>
        <span>جاري الإرسال...</span>
    `;
    
    try {
        // Prepare data
        const inspectionCode = `INS-${Date.now()}`;
        const formData = {
            inspectionCode: inspectionCode,
            timestamp: new Date().toISOString(),
            driverId: selectedDriver.id,
            driverCode: selectedDriver.driver_code,
            driverName: selectedDriver.full_name,
            vehicleId: selectedVehicle.id,
            vanCode: selectedVehicle.van_code,
            plateNumber: selectedVehicle.plate_number,
            location: selectedVehicle.location,
            notes: document.getElementById('notes').value,
            declarationAccepted: true,
            photos: uploadedPhotos
        };
        
        console.log('📤 Submitting inspection:', formData);
        
        // Save to Supabase
        const { data: inspection, error: supabaseError } = await supabase
            .from('inspections')
            .insert([{
                inspection_code: formData.inspectionCode,
                driver_id: formData.driverId,
                vehicle_id: formData.vehicleId,
                timestamp: formData.timestamp,
                location: formData.location,
                notes: formData.notes,
                declaration_accepted: formData.declarationAccepted
            }])
            .select()
            .single();
        
        if (supabaseError) throw supabaseError;
        
        console.log('✅ Saved to Supabase:', inspection);
        
        // Send to n8n webhook
        const response = await fetch(CONFIG.WEBHOOK_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(formData)
        });
        
        if (!response.ok) {
            throw new Error(`Webhook error: ${response.status}`);
        }
        
        console.log('✅ Sent to n8n webhook');
        
        // Show success
        showSuccess();
        
        // Reset form after 2 seconds
        setTimeout(() => {
            resetForm();
        }, 2000);
        
    } catch (error) {
        console.error('❌ Error submitting inspection:', error);
        showError('حدث خطأ أثناء حفظ البيانات: ' + error.message);
        
        // Re-enable button
        submitBtn.disabled = false;
        submitBtn.innerHTML = `
            <span>تسجيل الفحص</span>
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
        `;
    }
}

// ========================================
// UI Functions
// ========================================
function showSuccess() {
    const successMsg = document.getElementById('successMessage');
    const errorMsg = document.getElementById('errorMessage');
    
    errorMsg.classList.add('hidden');
    successMsg.classList.remove('hidden');
    
    window.scrollTo({ top: 0, behavior: 'smooth' });
    
    setTimeout(() => {
        successMsg.classList.add('hidden');
    }, 5000);
}

function showError(message) {
    const successMsg = document.getElementById('successMessage');
    const errorMsg = document.getElementById('errorMessage');
    const errorText = document.getElementById('errorText');
    
    successMsg.classList.add('hidden');
    errorText.textContent = message;
    errorMsg.classList.remove('hidden');
    
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function resetForm() {
    document.getElementById('inspectionForm').reset();
    
    // Clear photos
    uploadedPhotos = { front: null, back: null, right: null, left: null };
    
    ['front', 'back', 'right', 'left'].forEach(side => {
        const previewDiv = document.getElementById(`${side}Preview`);
        const parentDiv = previewDiv.parentElement;
        
        parentDiv.style.backgroundImage = '';
        parentDiv.classList.remove('has-image');
        
        previewDiv.innerHTML = `
            <svg class="w-8 h-8 text-gray-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            <span class="text-xs font-medium text-gray-600">${side === 'front' ? 'الأمامية - Front' : side === 'back' ? 'الخلفية - Back' : side === 'right' ? 'اليمين - Right' : 'اليسار - Left'}</span>
        `;
    });
    
    // Hide vehicle section
    document.getElementById('vehicleSection').classList.add('hidden');
    
    // Reset selections
    selectedDriver = null;
    selectedVehicle = null;
    
    // Re-enable button
    const submitBtn = document.getElementById('submitBtn');
    submitBtn.disabled = false;
    submitBtn.innerHTML = `
        <span>تسجيل الفحص</span>
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
    `;
    
    console.log('✅ Form reset');
}

function updateCharCount() {
    const notes = document.getElementById('notes');
    const charCount = document.getElementById('noteChar');
    charCount.textContent = `${notes.value.length} / 500 حرف`;
}

// ========================================
console.log('📱 FleetCheck v2 - Inspection Form Loaded');

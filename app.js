// ========================================
// FleetCheck - Main Application Logic
// ========================================

// Configuration
const CONFIG = {
    // n8n Webhook URL - UPDATE THIS with your actual webhook URL
    WEBHOOK_URL: 'https://n8n.srv1200431.hstgr.cloud/webhook-test/fleetcheck-antifat',
    MAX_FILE_SIZE: 10 * 1024 * 1024, // 10MB
    ALLOWED_FILE_TYPES: ['image/jpeg', 'image/jpg', 'image/png'],
    COMPRESSION_QUALITY: 0.8, // 80% quality for faster uploads
};

// State Management
let uploadedPhotos = {
    front: null,
    back: null,
    right: null,
    left: null
};

let currentLanguage = 'ar'; // Default Arabic

// Translations
const translations = {
    ar: {
        formTitle: 'نموذج فحص المركبة',
        formSubtitle: 'يرجى ملء جميع الحقول المطلوبة وتصوير المركبة من 4 جهات',
        labelVan: 'رقم المركبة',
        labelDriver: 'اسم السائق',
        labelLocation: 'الموقع',
        labelPhotos: 'صور المركبة (4 جهات)',
        labelNotes: 'ملاحظات (اختياري)',
        labelFront: 'الأمامية - Front',
        labelBack: 'الخلفية - Back',
        labelRight: 'اليمين - Right',
        labelLeft: 'اليسار - Left',
        optionSelect: '-- اختر رقم المركبة --',
        optionSelectLocation: '-- اختر الموقع --',
        photoHint: 'ⓘ يرجى التقاط صور واضحة من جميع الجهات الأربع للمركبة',
        noteChar: 'حرف / 500',
        btnText: 'تسجيل الفحص',
        successTitle: 'تم التسجيل بنجاح!',
        successText: 'تم حفظ بيانات الفحص بنجاح',
        errorTitle: 'خطأ في التسجيل',
        errorText: 'حدث خطأ أثناء حفظ البيانات. يرجى المحاولة مرة أخرى',
        submitting: 'جاري الإرسال...',
        langBtn: 'English'
    },
    en: {
        formTitle: 'Vehicle Inspection Form',
        formSubtitle: 'Please fill all required fields and photograph the vehicle from 4 sides',
        labelVan: 'Vehicle Number',
        labelDriver: 'Driver Name',
        labelLocation: 'Location',
        labelPhotos: 'Vehicle Photos (4 sides)',
        labelNotes: 'Notes (Optional)',
        labelFront: 'Front',
        labelBack: 'Back',
        labelRight: 'Right Side',
        labelLeft: 'Left Side',
        optionSelect: '-- Select Vehicle Number --',
        optionSelectLocation: '-- Select Location --',
        photoHint: 'ⓘ Please take clear photos from all four sides of the vehicle',
        noteChar: 'characters / 500',
        btnText: 'Submit Inspection',
        successTitle: 'Successfully Submitted!',
        successText: 'Inspection data has been saved successfully',
        errorTitle: 'Submission Error',
        errorText: 'An error occurred while saving data. Please try again',
        submitting: 'Submitting...',
        langBtn: 'العربية'
    }
};

// ========================================
// Initialize on Page Load
// ========================================
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

function initializeApp() {
    // Set up event listeners
    document.getElementById('inspectionForm').addEventListener('submit', handleFormSubmit);
    document.getElementById('langToggle').addEventListener('click', toggleLanguage);
    document.getElementById('notes').addEventListener('input', updateCharCount);
    
    // Load saved language preference
    const savedLang = localStorage.getItem('fleetcheck_language') || 'ar';
    if (savedLang !== currentLanguage) {
        toggleLanguage();
    }
    
    console.log('✅ FleetCheck initialized successfully');
}

// ========================================
// Photo Upload Handling
// ========================================
async function handlePhotoUpload(input, side) {
    const file = input.files[0];
    
    if (!file) return;
    
    // Validate file type
    if (!CONFIG.ALLOWED_FILE_TYPES.includes(file.type)) {
        alert(currentLanguage === 'ar' 
            ? 'يرجى اختيار صورة بصيغة JPG أو PNG فقط' 
            : 'Please select JPG or PNG image only');
        input.value = '';
        return;
    }
    
    // Validate file size
    if (file.size > CONFIG.MAX_FILE_SIZE) {
        alert(currentLanguage === 'ar' 
            ? 'حجم الملف كبير جداً. الحد الأقصى 10 ميجابايت' 
            : 'File size too large. Maximum 10MB');
        input.value = '';
        return;
    }
    
    try {
        // Compress and convert to base64
        const compressedBase64 = await compressImage(file);
        
        // Store in state
        uploadedPhotos[side] = {
            base64: compressedBase64,
            filename: file.name,
            size: file.size
        };
        
        // Update UI with preview
        const previewDiv = document.getElementById(`${side}Preview`);
        const parentDiv = previewDiv.parentElement;
        
        // Add image as background
        parentDiv.style.backgroundImage = `url(${compressedBase64})`;
        parentDiv.classList.add('has-image');
        
        // Update preview content
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
        alert(currentLanguage === 'ar' 
            ? 'حدث خطأ أثناء رفع الصورة. يرجى المحاولة مرة أخرى' 
            : 'Error uploading photo. Please try again');
        input.value = '';
    }
}

// Compress image to base64
function compressImage(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        
        reader.onload = function(e) {
            const img = new Image();
            
            img.onload = function() {
                // Create canvas for compression
                const canvas = document.createElement('canvas');
                let width = img.width;
                let height = img.height;
                
                // Resize if too large (max 1920px width)
                const maxWidth = 1920;
                if (width > maxWidth) {
                    height = (height * maxWidth) / width;
                    width = maxWidth;
                }
                
                canvas.width = width;
                canvas.height = height;
                
                const ctx = canvas.getContext('2d');
                ctx.drawImage(img, 0, 0, width, height);
                
                // Convert to base64 with compression
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
    
    // Validate form
    if (!validateForm()) {
        return;
    }
    
    // Get form data
    const formData = getFormData();
    
    // Disable submit button
    const submitBtn = document.getElementById('submitBtn');
    const btnText = document.getElementById('btnText');
    const originalText = btnText.textContent;
    
    submitBtn.disabled = true;
    btnText.textContent = translations[currentLanguage].submitting;
    submitBtn.innerHTML = `
        <div class="spinner"></div>
        <span>${translations[currentLanguage].submitting}</span>
    `;
    
    try {
        // Send to n8n webhook
        const response = await fetch(CONFIG.WEBHOOK_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(formData)
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        console.log('✅ Form submitted successfully:', result);
        
        // Show success message
        showMessage('success');
        
        // Reset form after 2 seconds
        setTimeout(() => {
            resetForm();
        }, 2000);
        
    } catch (error) {
        console.error('❌ Error submitting form:', error);
        showMessage('error');
        
        // Re-enable button
        submitBtn.disabled = false;
        btnText.textContent = originalText;
        submitBtn.innerHTML = `
            <span>${originalText}</span>
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
        `;
    }
}

// Validate form before submission
function validateForm() {
    // Check if all 4 photos are uploaded
    const allPhotosUploaded = Object.values(uploadedPhotos).every(photo => photo !== null);
    
    if (!allPhotosUploaded) {
        alert(currentLanguage === 'ar' 
            ? 'يرجى رفع صور المركبة من جميع الجهات الأربع' 
            : 'Please upload photos from all 4 sides of the vehicle');
        return false;
    }
    
    // HTML5 validation will handle required fields
    return true;
}

// Get form data
function getFormData() {
    return {
        timestamp: new Date().toISOString(),
        vanNumber: document.getElementById('vanNumber').value,
        driverName: document.getElementById('driverName').value,
        location: document.getElementById('location').value,
        notes: document.getElementById('notes').value,
        photos: uploadedPhotos,
        language: currentLanguage
    };
}

// ========================================
// UI Functions
// ========================================
function showMessage(type) {
    const successMsg = document.getElementById('successMessage');
    const errorMsg = document.getElementById('errorMessage');
    
    // Hide both messages first
    successMsg.classList.add('hidden');
    errorMsg.classList.add('hidden');
    
    // Show appropriate message
    if (type === 'success') {
        successMsg.classList.remove('hidden');
        // Update text based on current language
        document.getElementById('successTitle').textContent = translations[currentLanguage].successTitle;
        document.getElementById('successText').textContent = translations[currentLanguage].successText;
        
        // Scroll to top
        window.scrollTo({ top: 0, behavior: 'smooth' });
        
        // Auto-hide after 5 seconds
        setTimeout(() => {
            successMsg.classList.add('hidden');
        }, 5000);
    } else {
        errorMsg.classList.remove('hidden');
        // Update text based on current language
        document.getElementById('errorTitle').textContent = translations[currentLanguage].errorTitle;
        document.getElementById('errorText').textContent = translations[currentLanguage].errorText;
        
        // Scroll to top
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
}

function resetForm() {
    // Reset form fields
    document.getElementById('inspectionForm').reset();
    
    // Clear uploaded photos state
    uploadedPhotos = {
        front: null,
        back: null,
        right: null,
        left: null
    };
    
    // Reset photo previews
    ['front', 'back', 'right', 'left'].forEach(side => {
        const previewDiv = document.getElementById(`${side}Preview`);
        const parentDiv = previewDiv.parentElement;
        
        parentDiv.style.backgroundImage = '';
        parentDiv.classList.remove('has-image');
        
        const label = translations[currentLanguage][`label${side.charAt(0).toUpperCase() + side.slice(1)}`];
        previewDiv.innerHTML = `
            <svg class="w-8 h-8 text-gray-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            <span class="text-xs font-medium text-gray-600">${label}</span>
        `;
    });
    
    // Reset character count
    updateCharCount();
    
    // Re-enable submit button
    const submitBtn = document.getElementById('submitBtn');
    submitBtn.disabled = false;
    document.getElementById('btnText').textContent = translations[currentLanguage].btnText;
    submitBtn.innerHTML = `
        <span>${translations[currentLanguage].btnText}</span>
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
    `;
    
    console.log('✅ Form reset');
}

function updateCharCount() {
    const notes = document.getElementById('notes');
    const charCount = document.getElementById('noteChar');
    const count = notes.value.length;
    const suffix = currentLanguage === 'ar' ? 'حرف / 500' : 'characters / 500';
    charCount.textContent = `${count} / 500 ${suffix}`;
}

// ========================================
// Language Toggle
// ========================================
function toggleLanguage() {
    currentLanguage = currentLanguage === 'ar' ? 'en' : 'ar';
    
    // Update HTML direction
    const html = document.documentElement;
    html.setAttribute('lang', currentLanguage);
    html.setAttribute('dir', currentLanguage === 'ar' ? 'rtl' : 'ltr');
    
    // Update all text content
    updatePageText();
    
    // Save preference
    localStorage.setItem('fleetcheck_language', currentLanguage);
    
    console.log(`🌐 Language changed to: ${currentLanguage}`);
}

function updatePageText() {
    const t = translations[currentLanguage];
    
    // Update form text
    document.getElementById('formTitle').textContent = t.formTitle;
    document.getElementById('formSubtitle').textContent = t.formSubtitle;
    document.getElementById('labelVan').innerHTML = t.labelVan + ' <span class="text-red-500">*</span>';
    document.getElementById('labelDriver').innerHTML = t.labelDriver + ' <span class="text-red-500">*</span>';
    document.getElementById('labelLocation').innerHTML = t.labelLocation + ' <span class="text-red-500">*</span>';
    document.getElementById('labelPhotos').innerHTML = t.labelPhotos + ' <span class="text-red-500">*</span>';
    document.getElementById('labelNotes').textContent = t.labelNotes;
    
    // Update photo labels
    document.getElementById('labelFront').textContent = t.labelFront;
    document.getElementById('labelBack').textContent = t.labelBack;
    document.getElementById('labelRight').textContent = t.labelRight;
    document.getElementById('labelLeft').textContent = t.labelLeft;
    
    // Update dropdowns
    document.getElementById('optionSelect').textContent = t.optionSelect;
    document.getElementById('optionSelectLocation').textContent = t.optionSelectLocation;
    
    // Update hints and buttons
    document.getElementById('photoHint').textContent = t.photoHint;
    document.getElementById('btnText').textContent = t.btnText;
    document.getElementById('langToggle').textContent = t.langBtn;
    
    // Update character count
    updateCharCount();
    
    // Update placeholders
    document.getElementById('driverName').placeholder = currentLanguage === 'ar' 
        ? 'أدخل اسم السائق' 
        : 'Enter driver name';
    document.getElementById('notes').placeholder = currentLanguage === 'ar' 
        ? 'أضف أي ملاحظات إضافية...' 
        : 'Add any additional notes...';
}

// ========================================
// Utility Functions
// ========================================

// Log for debugging
console.log('🚀 FleetCheck App Loaded');
console.log('📍 Webhook URL:', CONFIG.WEBHOOK_URL);
console.log('⚙️ Configuration:', CONFIG);
